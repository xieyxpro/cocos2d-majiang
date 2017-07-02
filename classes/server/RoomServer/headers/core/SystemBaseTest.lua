--region SystemBaseTest.lua
--Date2015.8.27
--系统基类测试模块

local workthreadlib = nil
local configs = nil

SystemBaseTest = {
    _mapUserData,       --map<userid,userdata>
}

SystemBaseTest = Util:newClass(SystemBaseTest,SystemBase)

--region 测试系统单例
local __SystemBaseTestInstance = SystemBaseTest:new()
function SystemBaseTest:getInstance()
    if nil == __SystemBaseTestInstance then
        __SystemBaseTestInstance = SystemBaseTest:new()
    end
    return __SystemBaseTestInstance
end
--endregion

function SystemBaseTest:OnServiceStart(workthreadlib_global, configs_global)
    workthreadlib = workthreadlib_global
    configs = configs_global
    self._mapUserData = {}
end

function SystemBaseTest:OnUserLogIn( pServerUserItem )
    self._mapUserData[dwUserID] = {}
    --投递数据库查询
    --workthreadlib:PostDataBaseEventMsg(DBR_DB2W.DBR_TEST, "DBRMsg.xxxx", LogonReq, dwUserID)
end

function SystemBaseTest:OnUserLogOut( pServerUserItem )
    self._mapUserData[dwUserID] = nil
end

function SystemBaseTest:OnUserReconnect( pServerUserItem )
    if nil == self._mapUserData[dwUserID] then
        logWarningf("SystemBaseTest user(%d) reconnect,user's info db quering", dwUserID)
        return
    end
end
function SystemBase:OnTimerFiveSec()--五秒定时器(每隔5秒被调用一次)
end
function SystemBase:OnTimerOneMin()
end
function SystemBase:OnTimerHalfHour()
end
function SystemBase:OnTimerOneHour()
end

function SystemBaseTest:OnTimerDailyRefresh()
   --for k,v in pairs(self._mapUserData) do
   --   if pUserData.needdailyRefresh then
   --       xxxx
   --   end
   --end
   --广播给所有在线用户
   --方法一：
    --local pRes = protobuf.encode("Gamemsg.xxx", RefreshRes)
   --workthreadlib:SendDataToAllClients( CMD_TEST.MAIN, CMD_TEST.SUB_TEST_RES, pRes, pRes:len())
   --方法二(推荐)：
   --workthreadlib:SendMsgToAllClients( CMD_TEST.MAIN, CMD_TEST.SUB_TEST_RES, "Gamemsg.xxx", RequestRes)
end

function SystemBaseTest:handler_cmd_request_test( dwUserID, pDataBuffer, wDataSize )
    if nil == self._mapUserData[dwUserID] then return false end
    --数据解码
    --方法1:
    --local pClientData = protobuf.decode("Gamemsg.xxxx", pDataBuffer, wDataSize)
    --方法2:(推荐)
    --local pClientData = workthreadlib:decode("Gamemsg.xxxx", pDataBuffer, wDataSize)

    --pClientData.messagedata xxxxxx
    --local RequestRes = {}
    --RequestRes.messagedata = xxxx
    --region 加密发送给前端
    --方法一:
    --local pRes = protobuf.encode("Gamemsg.xxx", RequestRes)
    --workthreadlib:SendDataToClient( dwUserID, CMD_TEST.MAIN, CMD_TEST.SUB_TEST_RES, pRes, pRes:len())
    --方法二(推荐):
    --workthreadlib:SendMsgToClient( dwUserID, CMD_TEST.MAIN, CMD_TEST.SUB_TEST_RES,"Gamemsg.xxx", RequestRes)
    return true
end

function SystemBaseTest:handler_dbr_test_logon_info( pDataBuffer, wDataSize )
    --local pDBData = protobuf.decode("DBRMsg.xxx", pDataBuffer, wDataSize)
    --self.__mapUserData[pDBData.dwUserID] = xxxxx
    --send user login data to client
end

function SystemBaseTest:handler_timer_timercallback( dwBindParam )
    --check user data overdue
    --xxx
    --xxx
end

gameSystems[#gameSystems + 1] = __SystemBaseTestInstance

socketeventHandler[CMD_TEST.MAIN] = socketeventHandler[CMD_TEST.MAIN] or {}
socketeventHandler[CMD_TEST.MAIN][CMD_TEST.SUB_TEST_REQ] = {__SystemBaseTestInstance, SystemBaseTest.handler_cmd_request_test}

dbeventHandler[DBR_DB2W.DBR_TEST] = {__SystemBaseTestInstance, SystemBaseTest.handler_dbr_test_logon_info}

event.register_timer_listener(TIMER.ID_TEST, __SystemBaseTestInstance, SystemBaseTest.handler_timer_timercallback)



--endregion
