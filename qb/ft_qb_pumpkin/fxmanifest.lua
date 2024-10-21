fx_version 'cerulean'
game 'gta5'

name "ft_qb_pumpkin"
author "PAPU (!PAPU.・ᶠᵀ#6969)"
version "1.0"

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
	'locales/en.lua',
}

client_scripts { 
    'client/client.lua'
}

server_scripts { 
    'server/server.lua'
}

escrow_ignore {
    'config.lua',
    'Install-First/*',
	'locales/en.lua',
}

lua54 'yes'