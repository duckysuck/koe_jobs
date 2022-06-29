fx_version 'adamant'

game 'gta5'

version '1.0.0'
lua54 'yes'

client_scripts {
	'client/mining.lua',
	'client/butcher.lua',
	'client/tailoring.lua',
	'client/fueler.lua',
	'shared/xp.lua',
	'shared/config.lua'
 }
 
 server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server/main.lua',
	'shared/xp.lua',
	'shared/config.lua'
 }

 shared_script '@ox_lib/init.lua'