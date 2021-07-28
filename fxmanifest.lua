fx_version 'cerulean'
game 'gta5'
description 'Brinnrhirt Paycheck System'
version '1.0.0'

client_scripts {
    'config.lua',
    'server/main.lua'
}

server_scripts {
    'config.lua',
    'client/main.lua',
    '@mysql-async/lib/MySQL.lua'
}
