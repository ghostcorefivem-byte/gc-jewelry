local QBCore = exports['qb-core']:GetCoreObject()

-- In-memory cache: equippedCache[serverId] = { [itemName] = true }
local equippedCache = {}

-- Cooldown table to prevent snatch spam
local snatchCooldown = {}

-- ============================================================
-- DATABASE (auto-create, single lightweight table)
-- ============================================================
MySQL.ready(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS gc_jewelry (
            citizenid VARCHAR(50) PRIMARY KEY,
            equipped JSON DEFAULT ('{}')
        )
    ]])
end)

-- ============================================================
-- HELPERS
-- ============================================================
local function GetCitizenId(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return nil end
    return Player.PlayerData.citizenid
end

local function GetPlayerGender(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return 'male' end
    local model = Player.PlayerData.charinfo and Player.PlayerData.charinfo.gender
    if model == 1 or model == '1' or model == 'female' then
        return 'female'
    end
    return 'male'
end

-- NON-BLOCKING async save
local function SavePlayerJewelry(src)
    local citizenid = GetCitizenId(src)
    if not citizenid then return end
    local data = json.encode(equippedCache[src] or {})
    MySQL.query('INSERT INTO gc_jewelry (citizenid, equipped) VALUES (?, ?) ON DUPLICATE KEY UPDATE equipped = ?', {
        citizenid, data, data
    })
end

-- ORIGINAL working load — scalar.await is fine here, only called inside SetTimeout so no hitch
local function LoadPlayerJewelry(src)
    local citizenid = GetCitizenId(src)
    if not citizenid then return end

    local result = MySQL.scalar.await('SELECT equipped FROM gc_jewelry WHERE citizenid = ?', { citizenid })
    local equipped = {}
    if result then
        equipped = json.decode(result) or {}
    end

    local valid = {}
    for itemName, _ in pairs(equipped) do
        if Config.Items[itemName] then
            valid[itemName] = true
        end
    end

    equippedCache[src] = valid
    return valid
end

-- ============================================================
-- TOGGLE EQUIP/UNEQUIP
-- ============================================================
local function ToggleJewelry(src, itemName)
    local itemConfig = Config.Items[itemName]
    if not itemConfig then
        print(('[gc-jewelry] ^1Unknown item: %s^0'):format(tostring(itemName)))
        return
    end

    local count = exports.ox_inventory:Search(src, 'count', itemName)
    if not count or count < 1 then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Jewelry',
            description = "You don't have this item",
            type = 'error',
        })
        return
    end

    if not equippedCache[src] then
        equippedCache[src] = {}
    end

    local gender     = GetPlayerGender(src)
    local isEquipped = equippedCache[src][itemName]

    local animData = Config.Animations[itemConfig.category]
    if animData then
        TriggerClientEvent('gc-jewelry:client:playAnim', src, animData)
    end

    local delay = animData and animData.duration or 0

    SetTimeout(delay, function()
        if isEquipped then
            equippedCache[src][itemName] = nil
            TriggerClientEvent('gc-jewelry:client:remove', -1, src, itemName, gender)
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Jewelry',
                description = ('Removed %s'):format(itemConfig.label),
                type = 'inform',
            })
        else
            for equippedItem, _ in pairs(equippedCache[src]) do
                local equippedConf = Config.Items[equippedItem]
                if equippedConf and equippedConf.category == itemConfig.category then
                    equippedCache[src][equippedItem] = nil
                    TriggerClientEvent('gc-jewelry:client:remove', -1, src, equippedItem, gender)
                end
            end

            equippedCache[src][itemName] = true
            TriggerClientEvent('gc-jewelry:client:apply', -1, src, itemName, gender)
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Jewelry',
                description = ('Equipped %s'):format(itemConfig.label),
                type = 'success',
            })
        end

        SavePlayerJewelry(src)
    end)
end

-- ============================================================
-- OX_INVENTORY EXPORT — original working signature
-- ============================================================
exports('UseJewelry', function(event, item, inventory)
    if event ~= 'usingItem' then return end

    local src      = inventory.id or inventory
    local itemName = item.name

    if not src or not itemName then return end

    ToggleJewelry(src, itemName)
end)

-- ============================================================
-- PLAYER LOADED
-- ============================================================
RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local src = source
    SetTimeout(3000, function()
        local equipped = LoadPlayerJewelry(src)
        if equipped and next(equipped) then
            local gender = GetPlayerGender(src)
            TriggerClientEvent('gc-jewelry:client:loadPlayer', -1, src, equipped, gender)
        end
    end)
end)

-- ============================================================
-- CALLBACK: New client asks for everyone's current jewelry
-- ============================================================
lib.callback.register('gc-jewelry:server:getAll', function(_)
    local allData = {}
    for srv, items in pairs(equippedCache) do
        if next(items) then
            allData[srv] = {
                items  = items,
                gender = GetPlayerGender(srv),
            }
        end
    end
    return allData
end)

-- ============================================================
-- INVENTORY CHECK: auto-unequip if item removed from inventory
-- ============================================================
RegisterNetEvent('gc-jewelry:server:validate', function()
    local src = source
    if not equippedCache[src] then return end

    local changed = false
    local gender  = GetPlayerGender(src)

    for itemName, _ in pairs(equippedCache[src]) do
        local count = exports.ox_inventory:Search(src, 'count', itemName)
        if not count or count < 1 then
            equippedCache[src][itemName] = nil
            TriggerClientEvent('gc-jewelry:client:remove', -1, src, itemName, gender)
            changed = true
        end
    end

    if changed then SavePlayerJewelry(src) end
end)

-- ============================================================
-- CHAIN SNATCH SYSTEM
-- ============================================================
RegisterNetEvent('gc-jewelry:server:snatchChain', function(targetServerId)
    local src = source

    if not src or not targetServerId then return end
    if src == targetServerId then return end

    local now = os.time()
    if snatchCooldown[src] and (now - snatchCooldown[src]) < 10 then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Chain Snatch',
            description = 'Slow down! Wait before trying again.',
            type = 'error',
        })
        return
    end

    local targetPlayer = QBCore.Functions.GetPlayer(targetServerId)
    if not targetPlayer then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Chain Snatch',
            description = 'Target not found.',
            type = 'error',
        })
        return
    end

    if not equippedCache[targetServerId] then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Chain Snatch',
            description = 'They are not wearing any chains.',
            type = 'error',
        })
        return
    end

    local stolenChain = nil
    for itemName, _ in pairs(equippedCache[targetServerId]) do
        local cfg = Config.Items[itemName]
        if cfg and cfg.category == 'chain' then
            stolenChain = itemName
            break
        end
    end

    if not stolenChain then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Chain Snatch',
            description = "They don't have a chain on.",
            type = 'error',
        })
        return
    end

    snatchCooldown[src] = now

    local removed = exports.ox_inventory:RemoveItem(targetServerId, stolenChain, 1)
    if not removed then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Chain Snatch',
            description = 'Failed to snatch. Try again.',
            type = 'error',
        })
        return
    end

    local targetGender = GetPlayerGender(targetServerId)
    equippedCache[targetServerId][stolenChain] = nil
    TriggerClientEvent('gc-jewelry:client:remove', -1, targetServerId, stolenChain, targetGender)
    SavePlayerJewelry(targetServerId)

    local gave = exports.ox_inventory:AddItem(src, stolenChain, 1)
    if not gave then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Chain Snatch',
            description = ('Snatched %s but your inventory was full!'):format(Config.Items[stolenChain].label),
            type = 'inform',
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = '🏃 Chain Snatched!',
            description = ('You snatched %s!'):format(Config.Items[stolenChain].label),
            type = 'success',
        })
    end

    TriggerClientEvent('ox_lib:notify', targetServerId, {
        title = '😤 Chain Snatched!',
        description = ('Someone snatched your %s!'):format(Config.Items[stolenChain].label),
        type = 'error',
        duration = 6000,
    })

    TriggerClientEvent('gc-jewelry:client:playSnatch', src, targetServerId)

    print(('[gc-jewelry] ^3%s snatched %s from %s^0'):format(
        GetPlayerName(src), stolenChain, GetPlayerName(targetServerId)
    ))
end)

-- Internal: expose equippedCache to other server files
AddEventHandler('gc-jewelry:internal:getEquipped', function(src, cb)
    cb(equippedCache[src] or {})
end)

-- ============================================================
-- MASK TOGGLE
-- ============================================================
RegisterNetEvent('gc-jewelry:server:maskToggle', function(direction)
    local src = source
    if direction ~= 'up' and direction ~= 'down' then return end

    local toggle = Config.MaskToggle
    if not toggle then return end

    -- No cache check — client tells us which mask item to toggle
    -- We just validate direction and broadcast the swap
    local targetVariant = (direction == 'down') and toggle.default.down or toggle.default.up
    if not targetVariant then return end

    TriggerClientEvent('gc-jewelry:client:applyMaskToggle', -1, src, targetVariant.drawable, targetVariant.texture)

    TriggerClientEvent('ox_lib:notify', src, {
        title = '🎭 Mask',
        description = (direction == 'down') and 'Mask pulled down' or 'Mask pulled up',
        type = 'inform',
    })
end)

-- ============================================================
-- PLAYER DROPPED
-- ============================================================
AddEventHandler('playerDropped', function()
    local src = source
    if equippedCache[src] then
        SavePlayerJewelry(src)
        equippedCache[src]  = nil
        snatchCooldown[src] = nil
    end
end)

-- ============================================================
-- RESOURCE STOP: just clear cache, do NOT save
-- Saving here causes the server thread hitch on restart
-- All state is already saved on every equip/unequip/disconnect
-- ============================================================
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    equippedCache  = {}
    snatchCooldown = {}
end)
