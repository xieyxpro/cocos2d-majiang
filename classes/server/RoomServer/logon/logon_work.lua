--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local logonwork = {}
logonwork = Util:newClass(logonwork)

function logonwork:logon_check(wIndex, pConnectInfo, wMainCmdID, wSubCmdID, pDataBuffer, wDataSize )

    if wMainCmdID == CMD_LOGON.MAIN and wSubCmdID == CMD_LOGON.SUB_LOGON_USERID then
        if pConnectInfo.bLogin then return 0 end

        local pData = protobuf.decode("Gamemsg.Logon_MC_LogonByUserID", pDataBuffer, wDataSize)
        --region check user reconnect
        local pServerUserItem = ServerUserManager:getInstance():getOnlineOrOfflineUserItem(pData.userid)
        if nil ~= pServerUserItem then
            local bPwdRight = false
            if pData.pwdtype == "WECHAT_TOKEN" then
                bPwdRight = pServerUserItem:isUserTokenRight(pData.password)
            else
                bPwdRight = pServerUserItem:isUserPwdRight(pData.password)
            end
            if not bPwdRight then
                local LogonRes = {err = 1}
                protobuf.encode("Gamemsg.Logon_MS_LogonRes",LogonRes,
                    function(encodebuf, len)
                        workthreadlib:SendDataToClient(wIndex,pConnectInfo.wRoundID,CMD_LOGON.MAIN,CMD_LOGON.SUB_LOGON_RES,encodebuf,len)
                    end)                
                return
            end
            --TODO
            pConnectInfo:LogonFinish(pServerUserItem)

            if pServerUserItem:isOnline() then--把在线的连接断开
                local wOldConnectIndex = pServerUserItem:getSocketIndex()
                local pOldConnectInfo = ConnectInfos:getConnectInfo(wOldConnectIndex)
                pOldConnectInfo.pServerUserItem = nil
                workthreadlib:CloseSocket(wOldConnectIndex, pOldConnectInfo.wRoundID)
                logNormalf("在clientip:%d下的用户 %d 被ip:%d挤下线",pOldConnectInfo.dwClientIP,pData.userid,pConnectInfo.dwClientIP)
            end

            ServerUserManager:getInstance():OnUserReconnect(pServerUserItem,pConnectInfo.dwClientIP,wIndex)
            
            local LogonRes = {err = 0,tableid = pServerUserItem:getTableID()}
            protobuf.encode("Gamemsg.Logon_MS_LogonRes",LogonRes,
                function(encodebuf, len)
                    workthreadlib:SendDataToClient(wIndex,pConnectInfo.wRoundID,CMD_LOGON.MAIN,CMD_LOGON.SUB_LOGON_RES,encodebuf,len)
                end)
            beholderlib.trigger(BEHOLDER_EVENTTYPE.USER_RECONNECT,pServerUserItem)
            return 0
        end
        --endregion

        local LogonByUserID = {}
        LogonByUserID.index = wIndex
        LogonByUserID.roundid = pConnectInfo.wRoundID
        LogonByUserID.userid = pData.userid
        LogonByUserID.password = pData.password
        if pData.pwdtype == "WECHAT_TOKEN" then
            LogonByUserID.pwdtype = "WECHAT_TOKEN"
        else
            LogonByUserID.pwdtype = "NORMAL"       
        end
        workthreadlib:PostDataBaseEventMsg(DBR_W2DB.DBR_USER_LOGON_USERID, "DBRMsg.Logon_MW_LogonUserID",LogonByUserID, pData.userid)
            
        pConnectInfo:LogonBegin()
        return 0
    end
    return 1
end

function logonwork:handler_dbr_user_logon_res(pLogonRes)
    assert(nil ~= pLogonRes)
    local pConnectInfo = ConnectInfos:getConnectInfo(pLogonRes.index)
    assert(nil ~= pConnectInfo)
    if not pConnectInfo.bConnect or pConnectInfo.wRoundID ~= pLogonRes.roundid then
        logWarning("user (userid)" .. pLogonRes.userid .. " disconnect while logon ing ~")
        return false
    end
    assert(pConnectInfo.bLogin)

    local LogonRes = {}
    LogonRes.err = 2
    if pLogonRes.logonres == "SUCCESS" then
        --send to ocs request roomserver session
        local locServerConfig = workthreadlib.servermanager.localServer;
        local logonreq = {}
        logonreq.server = {type = "ROOM_SERVER",kindid = locServerConfig.kindid,serverid = locServerConfig.serverid}
        logonreq.index = pLogonRes.index
        logonreq.roundid = pLogonRes.roundid
	    logonreq.userid = pLogonRes.userid
	    logonreq.password = pLogonRes.password
	    logonreq.nickname = pLogonRes.nickname
	    logonreq.roomcardnum = pLogonRes.roomcardnum
	    logonreq.sex = pLogonRes.sex
	    logonreq.headimageurl = pLogonRes.headimageurl
	    logonreq.token = pLogonRes.token
	    logonreq.tokenrefreshtime = pLogonRes.tokenrefreshtime
        workthreadlib:SendMsgToOCS(CMD_OCS_SESSION.MAIN,CMD_OCS_SESSION.MC_ROOM_USER_LOGON,"OCSmsg.mc_user_logon",logonreq)
        return 0
    elseif pLogonRes.logonres == "ERR_PWD_WRONG" then
        LogonRes.err = 1
    end
    pConnectInfo:LogonFinish(nil)
    protobuf.encode("Gamemsg.Logon_MS_LogonRes",LogonRes,
        function(encodebuf, len)
            workthreadlib:SendDataToClient(pLogonRes.index,pLogonRes.roundid,CMD_LOGON.MAIN,CMD_LOGON.SUB_LOGON_RES,encodebuf,len)
        end)
end

function logonwork:handler_ocs_user_logon_res(pLogonRes)
    assert(nil ~= pLogonRes)
    local pConnectInfo = ConnectInfos:getConnectInfo(pLogonRes.index)
    assert(nil ~= pConnectInfo)
    if not pConnectInfo.bConnect or pConnectInfo.wRoundID ~= pLogonRes.roundid then
        logWarning("user " .. pLogonRes.account .. " disconnect while logon ing ~")
        return 1
    end
    assert(pConnectInfo.bLogin)
    
    local LogonRes = {}
    LogonRes.err = 3
    local pUserItem = nil
    if pLogonRes.res == "SUCCESS" then
        local pOldUserItem = ServerUserManager:getInstance():getOnlineUserItem(pLogonRes.userid)
        if nil ~= pOldUserItem then
            assert(false)
        end
        LogonRes.err = 0
        pUserItem = ServerUserManager:getInstance():ActiveUser(pLogonRes.userid, pConnectInfo.dwClientIP,pLogonRes.index,pLogonRes)

        assert(nil ~= pUserItem)
    end
    pConnectInfo:LogonFinish(pUserItem)
    protobuf.encode("Gamemsg.Logon_MS_LogonRes",LogonRes,
        function(encodebuf, len)
            workthreadlib:SendDataToClient(pLogonRes.index,pLogonRes.roundid,CMD_LOGON.MAIN,CMD_LOGON.SUB_LOGON_RES,encodebuf,len)
        end)
    if 0 == LogonRes.err then
        beholderlib.trigger(BEHOLDER_EVENTTYPE.USER_LOGIN,pConnectInfo.pServerUserItem)
    end
    return 0
end

function logonwork:logout(userid)
    local locServerConfig = workthreadlib.servermanager.localServer;
    local logoutreq = {}
    logoutreq.server = {type = "ROOM_SERVER",kindid = locServerConfig.kindid,serverid = locServerConfig.serverid}
	logoutreq.userid = userid
    workthreadlib:SendMsgToOCS(CMD_OCS_SESSION.MAIN,CMD_OCS_SESSION.MC_ROOM_USER_LOGOUT,"OCSmsg.mc_user_logout",logoutreq)
end

event.register_db_listener(DBR_DB2W.DBR_USER_LOGON_RES,logonwork,logonwork.handler_dbr_user_logon_res,"DBRMsg.Logon_MD_Res")
--endregion

return logonwork