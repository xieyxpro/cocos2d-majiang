--region weapon_WeaponDB.lua
--Date 2015.8.20
local hotfixdb = {}
hotfixdb = Util:newClass(hotfixdb, DBBase)

--region handlersa

function hotfixdb:handler_dbr_hotfix( pDataBuffer, wDataSize )
    dofile("./lua/hotfix/script_db.lua")
end

--region 
dbModules[#dbModules + 1] = hotfixdb

--消息句柄绑定
workdbeventHandler[DBR_W2DB.DBR_HOTFIX] = hotfixdb.handler_dbr_hotfix
--endregion

return hotfixdb
--endregion
