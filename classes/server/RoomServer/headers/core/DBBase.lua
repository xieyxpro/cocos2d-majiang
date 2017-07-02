--region DBBase.lua
--Date 2015.8.27
--DB模块的基类
DBBase = {
    OnServiceStart = nil,
}

DBBase = Util:newClass(DBBase)

--region Description
--[[
    参数为
    1. dbconn_global:
        db的连接操作类似于jdbc，可用函数：http://server-pc:8080/svn/src/trunk/server/tool/tolua++/DataBase.pkg
    2. dbthreadlib_global:
        可与逻辑线程交互
        可调用的函数有:
        > PostDataBaseEvent(ushort id, string pDataBuffer, ushort wDataSize)
        > PostDataBaseEvent(ushort id, userdata pDataBuffer, ushort wDataSize)
        扩展函数(其他函数的封装优化)：
        > decode(strTypeName, pDataBuffer, wLength)
        > PostDataBaseEventMsg(wRequestID, strTypeName, tbMsgContent)
--]]
--endregion
function DBBase:OnServiceStart(dbthreadlib_global, dbconn_accountdb_global, dbconn_gamedb_global, dbconn_statdb_global)

end



--endregion
