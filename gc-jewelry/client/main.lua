local QBCore = exports['qb-core']:GetCoreObject()

-- ============================================================
-- LOCAL STATE
-- ============================================================
local defaults = {}

-- ============================================================
-- HELPERS
-- ============================================================
local function SlotKey(type, slot)
    return ('%s_%d'):format(type, slot)
end

local function GetPedFromServerId(serverId)
    if serverId == GetPlayerServerId(PlayerId()) then
        return PlayerPedId()
    end
    local playerId = GetPlayerFromServerId(serverId)
    if playerId == -1 then return nil end
    local ped = GetPlayerPed(playerId)
    if ped == 0 or not DoesEntityExist(ped) then return nil end
    return ped
end

local function GetGenderData(itemConfig, gender)
    if gender == 'female' then return itemConfig.female end
    return itemConfig.male
end

local function SaveDefault(serverId, ped, itemConfig)
    local key = SlotKey(itemConfig.type, itemConfig.slot)
    if not defaults[serverId] then defaults[serverId] = {} end
    if defaults[serverId][key] then return end

    if itemConfig.type == 'component' then
        defaults[serverId][key] = {
            drawable = GetPedDrawableVariation(ped, itemConfig.slot),
            texture  = GetPedTextureVariation(ped, itemConfig.slot),
        }
    elseif itemConfig.type == 'prop' then
        defaults[serverId][key] = {
            drawable = GetPedPropIndex(ped, itemConfig.slot),
            texture  = GetPedPropTextureIndex(ped, itemConfig.slot),
        }
    end
end

-- ============================================================
-- APPLY / REMOVE
-- ============================================================
local function ApplyItem(serverId, itemName, gender)
    local itemConfig = Config.Items[itemName]
    if not itemConfig then return end

    local ped = GetPedFromServerId(serverId)
    if not ped then return end

    local data = GetGenderData(itemConfig, gender)
    if not data then return end

    SaveDefault(serverId, ped, itemConfig)

    if itemConfig.type == 'component' then
        SetPedComponentVariation(ped, itemConfig.slot, data.drawable, data.texture, 0)
    elseif itemConfig.type == 'prop' then
        SetPedPropIndex(ped, itemConfig.slot, data.drawable, data.texture, true)
    end
end

local function RemoveItem(serverId, itemName, gender)
    local itemConfig = Config.Items[itemName]
    if not itemConfig then return end

    local ped = GetPedFromServerId(serverId)
    if not ped then return end

    local key = SlotKey(itemConfig.type, itemConfig.slot)
    local def = defaults[serverId] and defaults[serverId][key]

    if itemConfig.type == 'component' then
        if def then
            SetPedComponentVariation(ped, itemConfig.slot, def.drawable, def.texture, 0)
        else
            SetPedComponentVariation(ped, itemConfig.slot, 0, 0, 0)
        end
    elseif itemConfig.type == 'prop' then
        if def and def.drawable >= 0 then
            SetPedPropIndex(ped, itemConfig.slot, def.drawable, def.texture, true)
        else
            ClearPedProp(ped, itemConfig.slot)
        end
    end

    if defaults[serverId] then
        defaults[serverId][key] = nil
        if not next(defaults[serverId]) then
            defaults[serverId] = nil
        end
    end
end

-- Safe anim player — loads dict first then plays
local function PlayAnim(ped, dict, anim, duration)
    CreateThread(function()
        lib.requestAnimDict(dict)
        if not IsEntityPlayingAnim(ped, dict, anim, 3) then
            TaskPlayAnim(ped, dict, anim, 4.0, 4.0, duration, 49, 0, false, false, false)
        end
        Wait(duration)
        ClearPedTasksImmediately(ped)
    end)
end

-- ============================================================
-- EVENTS: Apply / Remove / Load
-- ============================================================
RegisterNetEvent('gc-jewelry:client:apply', function(targetServerId, itemName, gender)
    ApplyItem(targetServerId, itemName, gender)
end)

RegisterNetEvent('gc-jewelry:client:remove', function(targetServerId, itemName, gender)
    RemoveItem(targetServerId, itemName, gender)
end)

RegisterNetEvent('gc-jewelry:client:loadPlayer', function(targetServerId, equippedItems, gender)
    if not equippedItems then return end
    for itemName, _ in pairs(equippedItems) do
        ApplyItem(targetServerId, itemName, gender)
    end
end)

RegisterNetEvent('gc-jewelry:client:playAnim', function(animData)
    PlayAnim(PlayerPedId(), animData.dict, animData.anim, animData.duration)
end)

-- ============================================================
-- CHAIN SNATCH ANIMATIONS
-- ============================================================
RegisterNetEvent('gc-jewelry:client:playSnatch', function(snatcherServerId, victimServerId)
    local myId = GetPlayerServerId(PlayerId())
    local ped  = PlayerPedId()

    if myId == snatcherServerId then
        PlayAnim(ped, 'reaction@intimidation@1h', 'intro', 1500)
    elseif myId == victimServerId then
        PlayAnim(ped, 'reaction@mugged@standing', 'standing_a', 2000)
    end
end)

-- ============================================================
-- ON PLAYER LOADED: sync everyone's jewelry
-- ============================================================
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(5000)

    local allData = lib.callback.await('gc-jewelry:server:getAll', false)
    if not allData then return end

    for serverId, info in pairs(allData) do
        if info.items and next(info.items) then
            for itemName, _ in pairs(info.items) do
                ApplyItem(serverId, itemName, info.gender)
            end
        end
    end
end)

-- ============================================================
-- CHAIN SNATCH — ox_target on nearby players
-- ============================================================
CreateThread(function()
    Wait(2000)

    exports.ox_target:addGlobalPlayer({
        {
            name     = 'snatch_chain',
            icon     = 'fas fa-hand-paper',
            label    = 'Snatch Chain',
            distance = 1.5,

            -- canInteract: find the player ID from the ped entity correctly
            canInteract = function(entity)
                -- Find which player this ped belongs to
                for _, playerId in ipairs(GetActivePlayers()) do
                    if playerId ~= PlayerId() then
                        if GetPlayerPed(playerId) == entity then
                            return true -- show option, server validates chain ownership
                        end
                    end
                end
                return false -- not a valid player ped or it's ourselves
            end,

            onSelect = function(data)
                local entity = data.entity

                -- Find the player ID from the ped
                local targetPlayerId = nil
                for _, playerId in ipairs(GetActivePlayers()) do
                    if playerId ~= PlayerId() and GetPlayerPed(playerId) == entity then
                        targetPlayerId = playerId
                        break
                    end
                end

                if not targetPlayerId then
                    lib.notify({ title = 'Chain Snatch', description = 'Invalid target.', type = 'error' })
                    return
                end

                -- Distance safety check
                local myPed     = PlayerPedId()
                local targetPed = GetPlayerPed(targetPlayerId)
                local dist      = #(GetEntityCoords(myPed) - GetEntityCoords(targetPed))
                if dist > 2.0 then
                    lib.notify({ title = 'Chain Snatch', description = 'Too far away!', type = 'error' })
                    return
                end

                local targetServerId = GetPlayerServerId(targetPlayerId)

                -- Confirm dialog
                local confirmed = lib.alertDialog({
                    header   = '👀 Snatch Chain?',
                    content  = "Snatch this player's chain? This is a crime.",
                    centered = true,
                    cancel   = true,
                })
                if confirmed ~= 'confirm' then return end

                TriggerServerEvent('gc-jewelry:server:snatchChain', targetServerId)
            end,
        }
    })
end)

-- ============================================================
-- INVENTORY CHANGE: validate if item removed
-- ============================================================
RegisterNetEvent('ox_inventory:itemCount', function(itemName, count)
    if not Config.Items[itemName] then return end
    if count < 1 then
        TriggerServerEvent('gc-jewelry:server:validate')
    end
end)

-- ============================================================
-- CLEANUP
-- ============================================================
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    defaults = {}
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    local myId = GetPlayerServerId(PlayerId())
    if defaults[myId] then
        local ped = PlayerPedId()
        for key, def in pairs(defaults[myId]) do
            local t, slot = key:match('(%a+)_(%d+)')
            slot = tonumber(slot)
            if t == 'component' then
                SetPedComponentVariation(ped, slot, def.drawable, def.texture, 0)
            elseif t == 'prop' then
                if def.drawable >= 0 then
                    SetPedPropIndex(ped, slot, def.drawable, def.texture, true)
                else
                    ClearPedProp(ped, slot)
                end
            end
        end
    end

    defaults = {}
end)
