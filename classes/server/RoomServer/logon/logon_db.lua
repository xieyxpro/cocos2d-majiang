--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local logondb = {}
logondb = Util:newClass(logondb)

--region handlers
local dbconn_gamedb = dbconn_gamedb
local dbconn_accountdb = dbconn_accountdb
local dbthreadlib = dbthreadlib
function logondb:OnServiceStart(dbthreadlib_global, dbconn_accountdb_global, dbconn_gamedb_global, dbconn_statdb_global)
    dbconn_gamedb = dbconn_gamedb_global
    dbconn_accountdb = dbconn_accountdb_global
    dbthreadlib = dbthreadlib_global
end
--endregion

function logondb:handler_dbr_user_logon_byuserid(pLogonByUserID)
    assert(nil ~= pLogonByUserID)

    dbconn_accountdb:SetSPName("SP_GetAccountByUserID",1)
    dbconn_accountdb:setUInt(1,pLogonByUserID.userid)
    dbconn_accountdb:ExecuteCommand(true)

    local LogonRes = {}
    LogonRes.index = pLogonByUserID.index
    LogonRes.roundid = pLogonByUserID.roundid
    LogonRes.userid = pLogonByUserID.userid
    LogonRes.logonres = "ERR_PWD_WRONG"
    local dbpwd = dbconn_accountdb:getString("password")
    local dbtoken = dbconn_accountdb:getString("token");
    local bPwdRight = false
    if pLogonByUserID.pwdtype == "WECHAT_TOKEN" then
        bPwdRight = (string.lower(pLogonByUserID.password) == string.lower(dbtoken))
    else
        bPwdRight = (string.lower(pLogonByUserID.password) == string.lower(dbpwd))
    end
    if bPwdRight then
        LogonRes.logonres = "SUCCESS"
        LogonRes.nickname = dbconn_accountdb:getString("nickname")
        LogonRes.roomcardnum = dbconn_accountdb:getUInt("roomcardnum")
        LogonRes.password = dbpwd
        LogonRes.token = dbtoken
        LogonRes.sex = dbconn_accountdb:getUInt("sex")
        LogonRes.headimageurl = dbconn_accountdb:getString("headimageurl")
        LogonRes.tokenrefreshtime = dbconn_accountdb:getUInt("tokenrefreshtime")
    end

    dbthreadlib:PostDataBaseEventMsg(DBR_DB2W.DBR_USER_LOGON_RES,"DBRMsg.Logon_MD_Res",LogonRes)
end

function logondb:handler_dbr_user_logon_byuserid_dbexception(pDataBuffer, wDataSize)
    local pLogonByUserID = protobuf.decode("DBRMsg.Logon_MW_LogonUserID",pDataBuffer,wDataSize)
    assert(nil ~= pLogonByUserID)
    
    local LogonRes = {}
    LogonRes.index = pLogonByUserID.index
    LogonRes.roundid = pLogonByUserID.roundid
    LogonRes.logonres = "ERR_DB"

    dbthreadlib:PostDataBaseEventMsg(DBR_DB2W.DBR_USER_LOGON_RES,"DBRMsg.Logon_MD_Res",LogonRes)
end


--region 
dbModules[#dbModules + 1] = logondb
--消息句柄绑定
event.register_db_listener(DBR_W2DB.DBR_USER_LOGON_USERID,logondb,logondb.handler_dbr_user_logon_byuserid,"DBRMsg.Logon_MW_LogonUserID")
workdbexceptionHanlder[DBR_W2DB.DBR_USER_LOGON_USERID] = logondb.handler_dbr_user_logon_byuserid_dbexception
--endregion

return logondb


--endregion
