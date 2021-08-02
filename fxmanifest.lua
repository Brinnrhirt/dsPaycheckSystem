fx_version 'adamant'
game 'common'

server_scripts {
    'config.lua',
    'server/main.lua',
    '@mysql-async/lib/MySQL.lua'
}

client_scripts {
    'config.lua',
    'client/main.lua'
}