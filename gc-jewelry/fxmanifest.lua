fx_version 'cerulean'
game 'gta5'

description 'GC-Jewelry - Exclusive wearable jewelry items via inventory'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

dependencies {
    'qb-core',
    'ox_lib',
    'ox_inventory',
    'oxmysql',
}
