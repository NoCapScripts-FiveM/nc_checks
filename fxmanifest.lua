fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
games {'gta5', 'rdr3'}

lua54 'yes'

shared_scripts {
    'config.lua',
    '@mongodb/init.lua',
    '@ncfw/imports.lua',
    '@es_extended/imports.lua',
    '@ncfw/imports.lua'
    
} 

client_scripts {
   -- 'client/cl.lua',
    'client/init.lua',
    
}


server_scripts {

    '@oxmysql/lib/MySQL.lua',
    'modules/utility/utils.lua',
    'modules/user/user.lua',
    'modules/database/db.lua',
    'server/functions.lua',
    'server/qb_sv.lua',
    'server/init.lua',
    'server/vorp_sv.lua',
    'server/esx_sv.lua',
}