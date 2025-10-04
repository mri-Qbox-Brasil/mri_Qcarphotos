fx_version 'cerulean'
game 'gta5'

author 'mri_Qcarphotos'
description 'Sistema de Screenshots Automáticas de Veículos'
version '1.0.0'

this_is_a_map 'yes'

shared_script 'shared/config.lua'

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/server.lua'
}

dependency '/assetpacks'