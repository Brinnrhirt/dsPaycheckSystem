fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Brinnrhirt'
description 'Paycheck System for ESX'
version '1.2.1'

shared_scripts {
    '@es_extended/imports.lua', -- Only for Legacy ESX, remove if you're not using it
    'config/config.lua',
    'config/locale.lua',
    'locales/*.lua',
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'server/main.lua'
}

client_scripts {
    'config.lua',
    'client/main.lua'
}