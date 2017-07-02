--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

AIUserItem = Util:newClass({})

function AIUserItem:Init(dwSocketFd,dwUserID,RoomNum,wTableID)
    self.SocketFd = dwSocketFd
    self.UserID = dwUserID
    self.TableID = wTableID
    self.RoomNum = RoomNum
    
    --region params
    self.LifeTime = 36000--生存时间 秒数
    self.LifeRolls = 100 --生存局数
    self.TakeScores = 10000--携带的游戏币
    --endregion
    
    self.bLogonSuccess = false
    self.bLogonFinish = false
    self.LogonTime = os.time();
    self:SendLogon()
end

--region 需要重新的接口
--[[
message room_info {
    optional int32 roomID = 1;
    optional int32 roomCreaterUserID = 2; //房主
    optional int32 rolls = 3; //游戏局数
    optional int32 people = 4;//人数
    optional string createParams = 5; //房间创建参数
    optional int32 rollsCnt = 6; //玩的局数计数
}
--]]
--function AIUserItem:InitGame(roominfo)

--end
--function AIUserItem:onGameMessage(wSubCmdID, pDataBuffer, wDataSize)

--end
--function AIUserItem:onGameTimerMessage(dwTimerID,dwBindParam)

--end
--endregion

--region 游戏调用接口
function AIUserItem:SendMsg(wMainCmdId, wSubCmdId, strTypeName, tbMsgContent)
    return aithreadlib:SendMsg(self.SocketFd, wMainCmdId, wSubCmdId, strTypeName, tbMsgContent)
end

--timerid范围[1，TIME_AI_GAME_RANGE)
function AIUserItem:SetGameTiemr(dwTimerID, dwElapse, dwRepeat, wParam)
    assert(dwTimerID < TIMER.TIME_AI_GAME_RANGE)
    return self:SetTimer(dwTimerID, dwElapse, dwRepeat, wParam)
end

function AIUserItem:KillGameTimer(dwTimerID)
    assert(dwTimerID < TIMER.TIME_AI_GAME_RANGE)
    return self:KillTimer(dwTimerID)
end
--endregion

function AIUserItem:SendLogon()
    local logon = {userid=self.UserID,password="e10adc3949ba59abbe56e057f20f883e"}
    self:SendMsg(CMD_LOGON.MAIN,CMD_LOGON.SUB_LOGON_USERID,"Gamemsg.Logon_MC_LogonByUserID",logon)
end

function AIUserItem:OnSocketRead(wMainCmdID, wSubCmdID, pDataBuffer, wDataSize)
    if wMainCmdID == CMD_LOGON.MAIN then
        return self:onLogonMessage(wSubCmdID, pDataBuffer, wDataSize)

    elseif wMainCmdID == CMD_USER.MAIN then
        return self:onUserMessage(wSubCmdID, pDataBuffer, wDataSize)

    elseif wMainCmdID == CMD_GF_FRAME.MAIN then
        return self:onFrameMessage(wSubCmdID, pDataBuffer, wDataSize)

    elseif wMainCmdID == MDM_GF_GAME.MAIN then
        return self:onGameMessage(wSubCmdID, pDataBuffer, wDataSize)

    end
end

function AIUserItem:onLogonMessage(wSubCmdID, pDataBuffer, wDataSize)
    if wSubCmdID == CMD_LOGON.SUB_LOGON_RES then
        local data = protobuf.decode("Gamemsg.Logon_MS_LogonRes",pDataBuffer,wDataSize)
        assert(data.err == 0 and -1 == data.tableid)
        self.bLogonSuccess = true;
    
    elseif wSubCmdID == CMD_LOGON.SUB_LOGON_FINISH then
        local joinroom = {}
        joinroom.roomID = self.RoomNum
        self.bLogonFinish = true
        self:SendMsg(CMD_USER.MAIN,CMD_USER.SUB_MC_TABLE_JOIN,"Gamemsg.mc_join_room",joinroom)
    end
end

function AIUserItem:onUserMessage(wSubCmdID, pDataBuffer, wDataSize)
    if wSubCmdID == CMD_USER.SUB_MS_TABLE_INFO then
        local roominfo = protobuf.decode("Gamemsg.ms_room_info",pDataBuffer,wDataSize)        
        self:InitGame(roominfo.roomInfo)
        self:SendMsg(CMD_GF_FRAME.MAIN,CMD_GF_FRAME.MC_GAMESCENE_LOAD_FINISH)
    end
end

--function AIUserItem:onFrameMessage(wSubCmdID, pDataBuffer, wDataSize)
--    if wSubCmdID == CMD_GF_FRAME.MS_DISMISS_CONFIRM then

--    end
--end

function AIUserItem:SetTimer(dwTimerID, dwElapse, dwRepeat, wParam)
    assert(dwTimerID < TIMER.TIME_AI_MODULE_RANGE)
    dwTimerID = self.UserID * TIMER.TIME_AI_MODULE_RANGE + dwTimerID
    return aithreadlib:SetTimer(dwTimerID, dwElapse, dwRepeat, wParam)
end
function AIUserItem:KillTimer(dwTimerID)
    assert(dwTimerID < TIMER.TIME_AI_MODULE_RANGE)
    dwTimerID = self.UserID * TIMER.TIME_AI_MODULE_RANGE + dwTimerID
    return aithreadlib:KillTimer(dwTimerID)
end

function AIUserItem:onTimerMessage(dwTimerID,dwBindParam)
    if dwTimerID < TIMER.TIME_AI_GAME_RANGE then
        return self:onGameTimerMessage(dwTimerID,dwBindParam)
    end
end
--endregion
