server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'cerulean'
game 'gta5'

author 'RPQC / Seb'
description 'Universal Vote Reward System for Top-Serveurs.net'
version '3.0.0'

lua54 'yes'

shared_scripts {
    'config.lua',
    'notifications.lua'
}

client_script 'client/main.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'oxmysql'
}
