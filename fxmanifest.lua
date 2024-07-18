fx_version 'cerulean'
game 'gta5'
author 'Jure#0001'

lua54 'yes'

shared_scripts {
	'config.lua',
	'@ox_lib/init.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server/*'
}

client_script 'client/*'

files {
    "json/*.json"
}
