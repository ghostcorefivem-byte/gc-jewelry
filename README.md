💎 GC-Jewelry
A fully synced wearable jewelry system for FiveM using ox_inventory, ox_lib, and qb-core.

Players can equip chains, watches, bracelets, and accessories directly from their inventory — with animations, persistence, and a chain snatching system.

✨ Features
💍 Wearable jewelry via inventory items
🔄 Fully synced across all players
💾 Persistent (saves to database)
🎭 Custom animations per item type
🧤 Chain snatching system (rob other players)
🚫 Category system (only one item per category)
🔁 Auto remove if item is removed from inventory
🎯 ox_target integration
📦 Dependencies
qb-core
ox_inventory
ox_lib
oxmysql
📁 Installation
Place the resource in your server:
gc-jewelry
Add to your server.cfg:
ensure gc-jewelry
Add your items (see below)

Restart your server

🎒 Adding Items (ox_inventory)
Go to:

ox_inventory/data/items.lua
🟢 NEW OX_INVENTORY (Recommended)
['rope_chain'] = {
    label = 'Thick Rope Chain',
    weight = 1,
    stack = false,
    close = true,
    consume = 0,
    description = 'An exclusive iced out rope chain',
    server = {
        export = 'gc-jewelry.UseJewelry',
    },
    client = {
        image = 'rope_chain.png',
    }
},

['bear_chain'] = {
    label = 'Bear Chain',
    weight = 1,
    stack = false,
    close = true,
    consume = 0,
    description = 'An exclusive big bear face iced out chain',
    server = {
        export = 'gc-jewelry.UseJewelry',
    },
    client = {
        image = 'bear_chain.png',
    }
},
🟡 OLD OX_INVENTORY (If items don’t work)
['rope_chain'] = {
    label = 'Thick Rope Chain',
    weight = 1,
    stack = false,
    close = true,
    consume = 0,
    description = 'An exclusive iced out rope chain',
    export = 'gc-jewelry.UseJewelry',
    client = {
        image = 'rope_chain.png',
    }
},

['bear_chain'] = {
    label = 'Bear Chain',
    weight = 1,
    stack = false,
    close = true,
    consume = 0,
    description = 'An exclusive big bear face iced out chain',
    export = 'gc-jewelry.UseJewelry',
    client = {
        image = 'bear_chain.png',
    }
},
🗄️ Database
Automatically creates:

gc_jewelry
No SQL import needed ✅

🖼️ Item Images
To create inventory images:

Use illenium-appearance
Zoom into the jewelry
Take a screenshot
Use a tool like PhotoRoom to remove background
Resize to 128x128
🎮 How It Works
Wearing Items
Use item from inventory
Animation plays
Item gets equipped
Removing Items
Use item again OR
Removing item from inventory auto-unequips
🧤 Chain Snatching
Using ox_target (third eye):

Walk up to a player
Open target
Click Snatch Chain
Confirm
✔ Includes cooldown, animations, and sync

🧱 Adding New Jewelry
Go to:

config.lua → Config.Items
Example:

['set15c_fem_left'] = {
    label = "Set15 LEFT FEM VVS BLUE",
    type  = 'prop',
    slot  = 11,
    category = 'bracelet',
    male = { drawable = 10, texture = 8 },
    female = { drawable = 10, texture = 8 },
},
💡 Tip: Use illenium-appearance and count drawable IDs from top to find correct values.

🚫 Blacklisting (IMPORTANT)
To hide items from clothing stores:

Go to:

illenium-appearance/shared/blacklist.lua
Example:

scarfAndChains = {
    { drawables = {1} },
    { drawables = {6} },
},
✔ Prevents items from appearing in clothing menu ✔ Forces usage through GC-Jewelry

⚠️ Notes
Item names must match config.lua
ox_target required for snatching
Images must exist in inventory folder
💅 GC Scripts
Custom built & branded for your server.

Enjoy your drip 😏💎
