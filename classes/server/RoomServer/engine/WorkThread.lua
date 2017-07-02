local relativepath = "./lua/RoomServer/";
package.path = string.format("%s;%s?.lua",package.path,relativepath)

gameSystems = {}

require("engine/WTRequireFiles")
--require("headers/core/SystemBaseTest")

local tablemanager = tablemanager or TableManager:getInstance();
local serverusermgr = serverusermgr or ServerUserManager:getInstance()--创建用户管理类
local sessionmanager = require("ocs/SessionManager")
local servermanager = require("ocs/ServerManager")
local rechargemanager = require("ocs/RechargeManager")
local roomnummanager = require("ocs/RoomnumManager")
local logonwork = require("logon/logon_work")

g_MapResources = g_MapResources or {}   --读取出来的xml数据存放在全局变量中
workthreadlib = workthreadlib

--region 辅助函数
local SetDailyClearTimer = function()   --设置每日清理计时器
	local elapse = Util:GetNextDailyClearTimerElapse()
	assert(workthreadlib:SetTimer(TIMER.ID_DAILYCLEAR_TIMERID, elapse * 1000, 1, 0))
end
--endregion

function engine_work_event_service_start( pworkThread, kindid, serverid, server_ip, server_port)

    math.randomseed(tonumber(tostring(os.time_ext()):reverse():sub(1, 6))) 

    workthreadlib = tolua.cast(pworkThread, "CWorkThread")
	--g_MapResources = loadAllXml(workthreadlib)	
	--if (nil == g_MapResources) or (nil == workthreadlib) then return 1 end
    if (nil == workthreadlib) then return 1 end
    workthreadlib.sessionmanager = sessionmanager
    workthreadlib.servermanager = servermanager
    workthreadlib.rechargemanager = rechargemanager
    workthreadlib.roomnummanager = roomnummanager
    workthreadlib.serverusermgr = serverusermgr
    workthreadlib.tablemanager = tablemanager
    workthreadlib.logonwork = logonwork
        
    protobuf.register_file(relativepath .. "../Commonlua/pb/OCSmsg.pb")
    protobuf.register_file(relativepath .. "headers/pb/Gamemsg.pb")
    protobuf.register_file(relativepath .. "headers/pb/CMD_AIReq.pb")
	protobuf.register_file(relativepath .. "headers/pb/CMD_DBReq.pb")
    protobuf.register_file(relativepath .. "headers/pb/CMD_DBStatReq.pb")
    
    WorkThreadUtil:Init(workthreadlib)
    sessionmanager:Init(workthreadlib)
    
    --region service start
    for _, gamesystem in pairs(gameSystems) do
        safecall(gamesystem.OnServiceStart, gamesystem, workthreadlib, kindid, serverid, server_ip, server_port)      --普通系统
    end

    beholderlib.trigger(BEHOLDER_EVENTTYPE.SERVICE_START,workthreadlib)     --广播服务器启动事件(特殊系统会用到)
    --endregion
    --region settimer
	SetDailyClearTimer()    --启动每日清理计时器
    workthreadlib:SetTimer(TIMER.ID_FIVE_SECOND_TIMERID, TIMER.PA_FIVE_SECOND_TIMER_ELAPSE, TIMER.PA_FOREVER_REPEAT, 0)
    workthreadlib:SetTimer(TIMER.ID_ONE_MINUTE_TIMERID, TIMER.PA_ONE_MINUTE_TIMER_ELAPSE, TIMER.PA_FOREVER_REPEAT, 0)
    workthreadlib:SetTimer(TIMER.ID_HALF_HOUR_TIMERID, TIMER.PA_HALF_HOUR_TIMER_ELAPSE, TIMER.PA_FOREVER_REPEAT, 0)
    workthreadlib:SetTimer(TIMER.ID_ONE_HOUR_TIMER_ID, TIMER.PA_ONE_HOUR_TIMER_ELAPSE, TIMER.PA_FOREVER_REPEAT, 0)
	--endregion
    
    if config.DEBUG and config.ENABLE_MEM_PHOTO then 
        collectgarbage("collect")
        gbl_Debugger:TakePhoto("ServiceStart")
        logNormal("Program memory photo token")
        collectgarbage("collect")
    end 

	return 0	--返回值给C++调用者
end

local LogonOnEachSystem = function( pServerUserItem ) 
    for _, gamesystem in pairs(gameSystems) do
        safecall(gamesystem.OnUserLogIn, gamesystem, pServerUserItem)
    end
    pServerUserItem:setLogonFinish()
    workthreadlib:SendMsgToClient(pServerUserItem, CMD_LOGON.MAIN, CMD_LOGON.SUB_LOGON_FINISH)
end
beholderlib.observe(BEHOLDER_EVENTTYPE.USER_LOGIN,nil,LogonOnEachSystem)

local OfflineOnEachSystem = function (pServerUserItem)
    for _, gamesystem in pairs(gameSystems) do
        safecall(gamesystem.OnUserOffline, gamesystem, pServerUserItem)
    end
end
beholderlib.observe(BEHOLDER_EVENTTYPE.USER_OFFLINE,nil,OfflineOnEachSystem)

local ReconnectOnEachSystem = function (pServerUserItem)    
    for _, gamesystem in pairs(gameSystems) do
        safecall(gamesystem.OnUserReconnect, gamesystem, pServerUserItem)
    end
    workthreadlib:SendMsgToClient(pServerUserItem, CMD_LOGON.MAIN, CMD_LOGON.SUB_LOGON_FINISH)
    
    beholderlib.trigger(BEHOLDER_EVENTTYPE.USER_RECONNECT_CHECK_INTABLE,pServerUserItem)
end
beholderlib.observe(BEHOLDER_EVENTTYPE.USER_RECONNECT,nil,ReconnectOnEachSystem)

local LogoutOnEachSystem = function (pServerUserItem)        
    for _, gamesystem in pairs(gameSystems) do
        safecall(gamesystem.OnUserLogOut, gamesystem, pServerUserItem)
    end
end;
beholderlib.observe(BEHOLDER_EVENTTYPE.USER_LOGOUT,nil,LogoutOnEachSystem)


--回写DB 删除用户内存（回写数据到DB）
function DeleteUserItem( pServerUserItem )

    beholderlib.trigger(BEHOLDER_EVENTTYPE.USER_LOGOUT,pServerUserItem)
	serverusermgr:DeleteServerUserItem(pServerUserItem)
    logonwork:logout(pServerUserItem.UserID)
    logDebug("DeleteUserItem UserID :" .. pServerUserItem.UserID )
end

function engine_stop_service()
    local tbAllMemUsers = serverusermgr:GetAllMemUsers()
    for userid,useritem in pairs(tbAllMemUsers) do
        DeleteUserItem(useritem)
    end
    --region
    for _, gamesystem in pairs(gameSystems) do
        safecall(gamesystem.OnServiceStop, gamesystem)      --普通系统
    end
    --endregion    
    workthreadlib:LuaStopServiceSuccess()
end
function engine_work_event_socket_accept(wIndex, wRoundID, dwClientIP)
    local pConnectInfo = ConnectInfos:getConnectInfo(wIndex)
    assert(nil == pConnectInfo.pServerUserItem)
    pConnectInfo:AcceptEvent(wRoundID, dwClientIP)
    return 0
end
function engine_work_event_socket_close(wIndex)
    local pConnectInfo = ConnectInfos:getConnectInfo(wIndex)
    local pServerUserItem = pConnectInfo.pServerUserItem
    pConnectInfo:CloseEvent()
    if nil ~= pServerUserItem then
        if pServerUserItem:isInTable() then
            serverusermgr:setUserOffline(pServerUserItem)
            beholderlib.trigger(BEHOLDER_EVENTTYPE.USER_OFFLINE,pServerUserItem)
            return 0 
        end
        DeleteUserItem(pServerUserItem)
    end
    return 0
end
function engine_work_event_socket_read( wIndex, wMainCmdID, wSubCmdID, pDataBuffer, wDataSize )
    local pConnectInfo = ConnectInfos:getConnectInfo(wIndex)
    local pServerUserItem = pConnectInfo.pServerUserItem
    if nil == pServerUserItem then
        return logonwork:logon_check(wIndex, pConnectInfo, wMainCmdID, wSubCmdID, pDataBuffer, wDataSize )
    end

	if false == pServerUserItem:isLogonFinish() then
		return 0
	end
    --region tablemessage
    if CMD_GF_FRAME.MAIN == wMainCmdID or MDM_GF_GAME.MAIN == wMainCmdID  then
        return tablemanager:OnTableMesssage(wMainCmdID, wSubCmdID, pDataBuffer, wDataSize, pServerUserItem)
    end
    --endregion
    --region dispatch
    local t1, t2 = nil, nil
    if config.DEBUG then 
        t1 = os.clock()
    end 

    local bHaveObserver,bsuccess,result = event.dipatch_socket_event(wMainCmdID, wSubCmdID, pDataBuffer, wDataSize, pServerUserItem )
    if bHaveObserver then
        if bsuccess then return result end
    else
        logErrf("There is no process function defined for command(%d : %d)",wMainCmdID,wSubCmdID)
    end
    
    if config.DEBUG then 
        t2 = os.clock()
        logNormalf("[REQUEST] command(usr: %d, main_code: %d, sub_code: %d) process time: %sms", 
                    pServerUserItem.UserID, wMainCmdID, wSubCmdID, tostring(math.floor((t2 - t1) * 100000) / 100))
    end 
    --endregion
end

function engine_work_event_timer( dwTimerID, dwBindParam )
        
    --region table timer
    if dwTimerID >= TIMER.ID_TABLE_MODULE_START and dwTimerID <= TIMER.ID_TABLE_MODULE_END then
        return tablemanager:OnTimerMessage(dwTimerID, dwBindParam)
    end
    --endregion
    --region regular timer
    if TIMER.ID_FIVE_SECOND_TIMERID == dwTimerID then
        for _, gamesystem in pairs(gameSystems) do
            safecall(gamesystem.OnTimerFiveSec, gamesystem)
        end
    elseif TIMER.ID_ONE_MINUTE_TIMERID == dwTimerID then
        for _, gamesystem in pairs(gameSystems) do
            safecall(gamesystem.OnTimerOneMin, gamesystem)
        end
    elseif TIMER.ID_HALF_HOUR_TIMERID == dwTimerID then
        for _, gamesystem in pairs(gameSystems) do
            safecall(gamesystem.OnTimerHalfHour, gamesystem)
        end
    elseif TIMER.ID_ONE_HOUR_TIMER_ID == dwTimerID then
        for _, gamesystem in pairs(gameSystems) do
            safecall(gamesystem.OnTimerOneHour, gamesystem)
        end
	elseif TIMER.ID_DAILYCLEAR_TIMERID == dwTimerID then --日常清理计时器
		SetDailyClearTimer()
        for _, gamesystem in pairs(gameSystems) do
            safecall(gamesystem.OnTimerDailyRefresh, gamesystem)
        end
	end
    --endregion
    --region dispatch
    event.dipatch_timer_event( dwTimerID, dwBindParam )
    --endregion

    --region gc
    if TIMER.ID_HALF_HOUR_TIMERID == dwTimerID then --one hour to collect garbage
        collectgarbage("collect")
        local usersCnt = table.nums(serverusermgr.mapAliveUser or {})
        logWarningf("Memory garbage collected..., program occupied(KB): %d, online users count: %d", collectgarbage("count"), usersCnt)
        if config.DEBUG and config.ENABLE_MEM_PHOTO then 
            gbl_Debugger:TakePhoto("Timer")
            logNormal("Program memory photo token")
            collectgarbage("collect")
        end 
    end 
    --endregion
	return 1
end

function engine_work_event_db( wRequestID, pDataBuffer, wDataSize )
	assert(pDataBuffer:len() == wDataSize)
    
    --region dispatch
    local bHaveObserver,bsuccess,result = event.dispatch_db_event( wRequestID, pDataBuffer, wDataSize )
    if bHaveObserver then
        if bsuccess then return result end
    end
    --endregion
	return 1

end

function engine_work_ocs_data_read(wMainCmdID, wSubCmdID, pDataBuffer, wDataSize)
    local nRes = servermanager:on_oc_data_read(wMainCmdID, wSubCmdID, pDataBuffer, wDataSize) 
    if 0 ~= nRes then
        nRes = sessionmanager:on_oc_data_read(wMainCmdID, wSubCmdID, pDataBuffer, wDataSize) 
    end
    if 0 ~= nRes then
        nRes = rechargemanager:on_oc_data_read(wMainCmdID, wSubCmdID, pDataBuffer, wDataSize) 
    end
    if 0 ~= nRes then
        nRes = roomnummanager:on_oc_data_read(wMainCmdID, wSubCmdID, pDataBuffer, wDataSize) 
    end
    assert(0 == nRes)
end
