--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local SessionManager = {}

local workthreadlib = workthreadlib
local logonwork = logonwork
local serverusermgr = serverusermgr

function SessionManager:Init(workthreadlib_global)
    workthreadlib = workthreadlib_global
    logonwork = workthreadlib_global.logonwork
    serverusermgr = workthreadlib_global.serverusermgr
end

function SessionManager:on_oc_data_read(wMainCmdID, wSubCmdID, pDataBuffer, wDataSize) 
    if wMainCmdID == CMD_OCS_SESSION.MAIN then
        if wSubCmdID == CMD_OCS_SESSION.MS_ROOM_USER_LOGON then
            local pLogonRes = protobuf.decode("OCSmsg.ms_user_logon_res", pDataBuffer, wDataSize)
            return logonwork:handler_ocs_user_logon_res(pLogonRes)

        elseif wSubCmdID == CMD_OCS_SESSION.MS_ROOM_USER_LOGOUT then
            return 0
        elseif wSubCmdID == CMD_OCS_SESSION.MC_HALL_USER_UPDATE_TOKEN then
            local pUpdateToken = protobuf.decode("OCSmsg.mc_hall_user_update_token", pDataBuffer, wDataSize)
            local pServerUserItem = serverusermgr:getOnlineOrOfflineUserItem(pUpdateToken.userid);
            if nil ~= pServerUserItem then
                pServerUserItem.Token = pUpdateToken.token
            end
            return 0
        end
    end
    return 1
end

return SessionManager


--endregion
