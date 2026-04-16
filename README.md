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

✔ Prevents items from appearing in clothing menu ✔ Forces usage through GC-Jewelry

⚠️ Notes
Item names must match config.lua
ox_target required for snatching
Images must exist in inventory folder
💅 GC Scripts
Custom built & branded for your server.

For support go to: https://discord.gg/WZtT8VBm
Buy me a coffee: https://discord.gg/WZtT8VBm

Enjoy your drip 😏💎
