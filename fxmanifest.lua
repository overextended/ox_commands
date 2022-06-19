--[[ FX Information ]]--
fx_version   'cerulean'
use_fxv2_oal 'yes'
lua54        'yes'
game         'gta5'

--[[ Resource Information ]]--
name         'ox_commands'
version      '0.0.0'
license      'GPL-3.0-or-later'
author       'overextended'
repository   'https://github.com/overextended/ox_commands'

--[[ Manifest ]]--
shared_script '@ox_lib/init.lua'
server_script 'server.lua'

client_scripts {
    'vendor/freecam/utils.lua',
    'vendor/freecam/config.lua',
    'vendor/freecam/main.lua',
    'vendor/freecam/camera.lua',
	'client/main.lua',
}

client_script 'client.lua'

files {
	'locales/*.json'
}