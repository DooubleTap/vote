server_script '@ElectronAC/src/include/server.lua'
client_script '@ElectronAC/src/include/client.lua'
fx_version 'cerulean'
game 'gta5'

author 'RPQC / Seb'
description 'Vote Reward System for Top-Serveurs.net'
version '3.0.0'

lua54 'yes'

-- Fichiers partagés (client + server)
shared_scripts {
    'config.lua',
    'notifications.lua'
}

-- Fichiers client uniquement
client_scripts {
    'client/main.lua'
}

-- Fichiers serveur uniquement
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'oxmysql'
}