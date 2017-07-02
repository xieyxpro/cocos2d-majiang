--region *.lua
--Date
--此文件由[BabeLua]插件自动生成


local ServerManager = {
    roomservers = {},
    bHeartTick = false,
    localServer = {
        --region 服务器启动会重新赋值
        kindid = 0,
        serverid = 0,
        ip = "127.0.0.1",
        port = 9000,
        bStoping = false,   --即将停止服务
        --endregion
    }
}

ServerManager = Util:newClass(ServerManager,SystemBase)

local workthreadlib = workthreadlib
local serverusermgr = serverusermgr

function ServerManager:OnServiceStart(workthread_global, kindid, serverid, server_ip, server_port)

    workthreadlib = workthread_global
    serverusermgr = ServerUserManager:getInstance()

    self.localServer.kindid = kindid
    self.localServer.serverid = serverid
    self.localServer.ip = server_ip
    self.localServer.port = server_port

    local serverreg = {}
    serverreg.server = {type = "ROOM_SERVER",serverid = self.localServer.serverid,kindid = self.localServer.kindid}
    serverreg.port = server_port
    serverreg.serverip = server_ip
    workthreadlib:SendMsgToOCS(CMD_OCS_SERVER.MAIN,CMD_OCS_SERVER.SUB_REG,"OCSmsg.mc_server_reg",serverreg)

    workthreadlib:SetTimer(TIMER.ID_SERVER_REGTO_OCS,TIMER.PA_SERVER_REGTO_OCS_ELAPSE,TIMER.PA_FOREVER_REPEAT,0)
end

function ServerManager:OnServiceStop()
    if 0 ~= self.localServer.serverid then
        local serverunreg = {}
        serverunreg.server = {type = "ROOM_SERVER", serverid = self.localServer.serverid,kindid = self.localServer.kindid}
        workthreadlib:SendMsgToOCS(CMD_OCS_SERVER.MAIN,CMD_OCS_SERVER.SUB_UNREG,"OCSmsg.mc_server_unreg",serverunreg)
    else
        assert(false)
    end
end

function ServerManager:OnRegTimer()    
    local serverreg = {}
    serverreg.server = {type = "ROOM_SERVER", serverid = self.localServer.serverid,kindid = self.localServer.kindid}
    serverreg.port = self.localServer.port
    serverreg.serverip = self.localServer.ip
    workthreadlib:SendMsgToOCS(CMD_OCS_SERVER.MAIN,CMD_OCS_SERVER.SUB_REG,"OCSmsg.mc_server_reg",serverreg)
end

function ServerManager:OnTimerFiveSec()
    if bHeartTick then
        local servertick = {}
        servertick.server = {type = "ROOM_SERVER", serverid = self.localServer.serverid,kindid = self.localServer.kindid}
        servertick.onlinenum = serverusermgr:getOnlineNum()
        workthreadlib:SendMsgToOCS(CMD_OCS_SERVER.MAIN,CMD_OCS_SERVER.SUB_TICK,"OCSmsg.mc_server_tick",servertick)
    end
end

function ServerManager:on_oc_data_read(wMainCmdID, wSubCmdID, pDataBuffer, wDataSize)
    if wMainCmdID == CMD_OCS_SERVER.MAIN then
        if wSubCmdID == CMD_OCS_SERVER.SUB_REG then
            local pReg = workthreadlib:decode("OCSmsg.ms_server_reg_res",pDataBuffer,wDataSize)
            if "ROOM_SERVER" == pReg.server.type and 
                self.localServer.kindid == pReg.server.kindid and
                self.localServer.serverid == pReg.server.serverid then

                workthreadlib:KillTimer(TIMER.ID_SERVER_REGTO_OCS)
                bHeartTick = true
                logNormal("Reg to OCS success")
            end
            return 0

        elseif wSubCmdID == CMD_OCS_SERVER.SUB_UNREG then
            
            return 0
        end
    elseif wMainCmdID == CMD_OCS_ADMIN.MAIN then
        if wSubCmdID == CMD_OCS_ADMIN.MC_ROOMSERVERS_STOP_NOW then
            local pTargetServer = workthreadlib:decode("OCSmsg.serverbase",pDataBuffer,wDataSize)
            if pTargetServer.kindid == self.localServer.kindid and pTargetServer.serverid == self.localServer.serverid then
                logNormal("Recv admin stopserver now cmd,service stoping")
                engine_stop_service() 
            end
            return 0

        elseif wSubCmdID == CMD_OCS_ADMIN.MC_ROOMSERVERS_STOP then
            local pTargetServer = workthreadlib:decode("OCSmsg.serverbase",pDataBuffer,wDataSize)
            if pTargetServer.kindid == self.localServer.kindid and pTargetServer.serverid == self.localServer.serverid then
                logNormal("Recv admin stopserver cmd,service stoping")
                self.localServer.bStoping = true
            end
            return 0

        end
    end
end

gameSystems[#gameSystems + 1] = ServerManager
event.register_timer_listener(TIMER.ID_SERVER_REGTO_OCS,ServerManager,ServerManager.OnRegTimer)

return ServerManager



--endregion
