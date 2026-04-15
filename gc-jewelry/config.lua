Config = {}

--[[
    ============================================================
    GC-JEWELRY CONFIG
    ============================================================

    Each item maps to a ped component (clothing) or ped prop (accessory).
    Male and female peds use DIFFERENT drawable IDs so both must be defined.

    TYPE:
      "component" → SetPedComponentVariation (chains, masks, clothing slots)
      "prop"      → SetPedPropIndex (watches, glasses, hats, earrings)

    COMPONENT SLOT IDS:
      0 = Head        1 = Masks       2 = Hair
      3 = Torso       4 = Legs        5 = Bags
      6 = Shoes       7 = Accessories 8 = Undershirt
      9 = Armor      10 = Decals     11 = Auxiliary

    PROP SLOT IDS:
      0 = Hats    1 = Glasses   2 = Ears
      6 = Watches 7 = Bracelets

    HOW TO FIND YOUR DRAWABLE IDS:
      1. Stream your custom YDD/YTD files (drop them in /stream or your EUP pack)
      2. Go in-game, open illenium-appearance or a trainer
      3. Browse the slot (e.g. Accessories for chains)
      4. Your custom items appear at the END of the list
      5. Write down the drawable ID and texture ID
      6. Do this for BOTH male and female peds
      7. Put the numbers in this config

    SLOT CATEGORY:
      Used to prevent wearing two items in the same category.
      If you equip a new "chain", the old "chain" auto-removes.
      Name these whatever you want.
]]

Config.Animations = {
    chain = {
        dict = 'clothingtie',
        anim = 'try_tie_positive_a',
        duration = 2000,
    },
watch = {
    dict = 'nmt_3_rcm-10',
    anim = 'cs_nigel_dual-10',
    duration = 1200,
},
}

Config.Items = {
    -- ============================================================
    -- CHAINS (Component 7 = Accessories)
    -- ============================================================
    ['doublediamond_chain'] = {
        label = 'Double Diamond Chain',
        type  = 'component',
        slot  = 7,                  -- accessories
        category = 'chain',         -- only one chain at a time
        male = {
            drawable = 1,           -- CHANGE to your male drawable ID
            texture  = 0,           -- CHANGE to your male texture ID
        },
        female = {
            drawable = 0,           -- CHANGE to your female drawable ID
            texture  = 0,           -- CHANGE to your female texture ID
        },
    },

    ['rope_chain'] = {
        label = 'Silver Rope Chain',
        type  = 'component',
        slot  = 7,
        category = 'chain',
        male = {
            drawable = 2,           -- CHANGE
            texture  = 0,           -- CHANGE
        },
        female = {
            drawable = 2,           -- CHANGE
            texture  = 0,           -- CHANGE
        },
    },

        ['bear_chain'] = {
        label = 'Bear Face Chain',
        type  = 'component',
        slot  = 7,
        category = 'chain',
        male = {
            drawable = 20,           -- CHANGE
            texture  = 0,           -- CHANGE
        },
        female = {
            drawable = 2,           -- CHANGE
            texture  = 0,           -- CHANGE
        },
    },

        ['otf_chain'] = {
        label = 'OTF Chain',
        type  = 'component',
        slot  = 7,
        category = 'chain',
        male = {
            drawable = 14,           -- CHANGE
            texture  = 0,           -- CHANGE
        },
        female = {
            drawable = 2,           -- CHANGE
            texture  = 0,           -- CHANGE
        },
    },

        ['gold_diamond_chain'] = {
        label = 'Gold Chain',
        type  = 'component',
        slot  = 7,
        category = 'chain',
        male = {
            drawable = 26,           -- CHANGE
            texture  = 0,           -- CHANGE
        },
        female = {
            drawable = 2,           -- CHANGE
            texture  = 0,           -- CHANGE
        },
    },

            ['cocochannel_chain'] = {
        label = 'CC Chain',
        type  = 'component',
        slot  = 7,
        category = 'chain',
        male = {
            drawable = 23,           -- CHANGE
            texture  = 0,           -- CHANGE
        },
        female = {
            drawable = 2,           -- CHANGE
            texture  = 0,           -- CHANGE
        },
    },

    -- ============================================================
    -- WATCHES (Prop 6 = Watches)
    -- ============================================================
    ['silver_watch'] = {
        label = 'Silver IcedOut Watch',
        type  = 'prop',
        slot  = 6,                  -- watch prop slot
        category = 'watch',
        male = {
            drawable = 2,           -- CHANGE
            texture  = 0,           -- CHANGE
        },
        female = {
            drawable = 0,           -- CHANGE
            texture  = 0,           -- CHANGE
        },
    },

    ['silverblue_watch'] = {
        label = 'Iced out Rolex',
        type  = 'prop',
        slot  = 6,
        category = 'watch',
        male = {
            drawable = 4,           -- CHANGE
            texture  = 0,           -- CHANGE
        },
        female = {
            drawable = 1,           -- CHANGE
            texture  = 0,           -- CHANGE
        },
    },

        ['silverthick_watch'] = {
        label = 'Jacobs Billionaire',
        type  = 'prop',
        slot  = 6,
        category = 'watch',
        male = {
            drawable = 12,           -- CHANGE
            texture  = 0,           -- CHANGE
        },
        female = {
            drawable = 1,           -- CHANGE
            texture  = 0,           -- CHANGE
        },
    },

            ['bigbang_watch'] = {
        label = 'Big Bang Watch',
        type  = 'prop',
        slot  = 6,
        category = 'watch',
        male = {
            drawable = 21,           -- CHANGE
            texture  = 0,           -- CHANGE
        },
        female = {
            drawable = 1,           -- CHANGE
            texture  = 0,           -- CHANGE
        },
    },

    -- ============================================================
    -- MASKS (Component 1 = Masks)
    -- ============================================================
    ['gold_earrings'] = {
        label = 'Gold Round earrings',
        type  = 'prop',
        slot  = 2,                  -- prop slot
        category = 'props',
        male = {
            drawable = 17,           -- CHANGE
            texture  = 0,           -- CHANGE
        },
        female = {
            drawable = 0,           -- CHANGE
            texture  = 0,           -- CHANGE
        },
    },

        ['silver_earrings'] = {
        label = 'Silver round earrings',
        type  = 'prop',
        slot  = 2,                  -- prop slot
        category = 'props',
        male = {
            drawable = 4,           -- CHANGE
            texture  = 0,           -- CHANGE
        },
        female = {
            drawable = 0,           -- CHANGE
            texture  = 0,           -- CHANGE
        },
    },
}

