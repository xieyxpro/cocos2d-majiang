--region *.lua
--Date
--此文件由[BabeLua]插件自动生成


local TableInfo = {
    Rolls,          --游戏局数
    createParams,           --可选玩法
        
    TotalPlayedCount,   --玩过的局数

    --region
    RoomNum,            --房号
    RoomGuid,           --房间唯一标识
    CreateTime,         --创建时间
    BeginTime,          --第一局开始时间
    --DismissTime,        --解散时间
    --endregion
}
TableInfo = Util:newClass()

TableFrame = {
--region
    wTableID = 0,                           --  桌子编号
    enGameStatus = enum_GameStatus.GS_FREE, --  桌子状态
    bTableCreated = false,
    pCreaterUserItem,   --创建者useritem
--endregion
--region
    wChairCount = 4,                        --  一张桌子最大座位数
--endregion
--region
    TableInfo = {},
--endregion
--region constant
    dismissRequestTime = 0,--请求解散组局时间
    TIMER_ID_DISMISS_GAME = TIMER.TIME_TABLE_GAME_RANGE + 1,
    TIME_DISMISS_GAME = 10*1000,   --10秒延时
--endregion
}

TableFrame = Util:newClass(TableFrame)
function TableFrame:Init(tableid)
    self.wTableID = tableid
    self:ResetTableFrame()
    self:InitTable()
end

function TableFrame:ResetTableFrame()
    self.enGameStatus = enum_GameStatus.GS_FREE --  桌子状态
    self.bTableCreated = false
    self.pCreaterUserItem = nil

    if nil ~= self.TableInfo.RoomNum then
        local roomnummanager = workthreadlib.roomnummanager
        roomnummanager:releaseRoomNum(self,self.TableInfo.RoomNum)    
    end
    self.TableInfo = TableInfo:new()
    self.TableInfo.TotalPlayedCount = 0

    self.pUserItems = {}
    self.agreeDismiss = {}--同意解散的玩家
    self.bCheatersChecked = false
    self:RepositionTable()
end

--region GameMain需要重写的接口
function TableFrame:RepositionTable()

end

--自定义发送游戏场景数据
function TableFrame:SendGameScene(pServerUserItem)
    
end
function TableFrame:onGameStart()

end
function TableFrame:onGameEnd(endReason)

end
function TableFrame:onDismiss()
    
end
function TableFrame:onGameMessage(wSubCmdID, pDataBuffer, wDataSize, pServerUserItem)
    return true
end
function TableFrame:onGameTimerMessage(dwTimerID, dwBindParam)

end

--region user action
function TableFrame:OnActionUserReconnect(wChairID, pServerUserItem)

end
function TableFrame:OnActionUserOffLine(wChairID, pServerUserItem)

end
function TableFrame:OnActionUserSitDown(wChairID, pServerUserItem)

end
function TableFrame:OnActionUserStandUp(wChairID, pServerUserItem)

end
function TableFrame:OnActionUserOnReady(wChairID, pServerUserItem)

end
--endregion 
--endregion
--region Gamemain 回调函数
function TableFrame:ConcludeGame()
    --region reset status
    self.enGameStatus = enum_GameStatus.GS_FREE
    if self.TableInfo.Rolls <= self.TableInfo.TotalPlayedCount then
        self:onDismiss()
        for _,pUserItem in pairs(self.pUserItems) do
            pUserItem:setUserStatus(enum_UserStatus.US_FREE, INVALID_TABLE, INVALID_CHAIR)
        end
        self:ResetTableFrame()
    else    
        for _, pServerUserItem in pairs(self.pUserItems) do 
            pServerUserItem:setUserStatus(enum_UserStatus.US_SIT, pServerUserItem.UserInfo.TableID, pServerUserItem.UserInfo.ChairID)
        end 
    end
    --endregion
end
--endregion
--region 框架消息
function TableFrame:onFrameMessage(wSubCmdID, pDataBuffer, wDataSize, pServerUserItem)
    if wSubCmdID == CMD_GF_FRAME.MC_GAMESCENE_LOAD_FINISH then
        --client ready
        if pServerUserItem:getUserStatus() >= enum_UserStatus.US_OFFLINE then
            self:PerformReconnectAction(pServerUserItem)
            return true
        end
        self:SendGameScene(pServerUserItem)
        if self.enGameStatus ~= enum_GameStatus.GS_PLAYING then
            self:PerformReadyAction(pServerUserItem)
        end
        return true

    elseif wSubCmdID == CMD_GF_FRAME.MC_USER_READY then
        self:PerformReadyAction(pServerUserItem)
        return true

    elseif wSubCmdID == CMD_GF_FRAME.MC_STAND_UP then
        self:PerformStandUpAction(pServerUserItem)
        return true

    elseif wSubCmdID == CMD_GF_FRAME.MCMS_TABLE_TALK then
        self:SendTableData(wSubCmdID, pDataBuffer, wDataSize, nil, CMD_GF_FRAME.MAIN)
        return true
    elseif wSubCmdID == CMD_GF_FRAME.MC_DISMISS then
        return self:PerformDismissAction(pDataBuffer, wDataSize, pServerUserItem)
    end
end
function TableFrame:onTimerMessage(dwTimerID, dwBindParam)
    if dwTimerID < TIMER.TIME_TABLE_GAME_RANGE then
        return self:onGameTimerMessage(dwTimerID, dwBindParam)
    end
    return self:onFrameTimerMessage(dwTimerID, dwBindParam)
end
function TableFrame:onFrameTimerMessage(dwTimerID, dwBindParam)
    if self.TIMER_ID_DISMISS_GAME == dwTimerID then--解散游戏
        self:DismissGame(enum_GameOverReason.AGREE_DISMISS)
        return true
    end
end
--endregion
--region 玩家控制
function TableFrame:trySendDismissGame(wChairID)
    if #self.agreeDismiss > 0 then        
        local agreelefttime = self.TIME_DISMISS_GAME - (os.time() - self.dismissRequestTime) * 1000
        local dismiss = {calleruserid=self.agreeDismiss[1],agreeuserids={},lefttime=agreelefttime};
        for i = 2, #self.agreeDismiss do
            dismiss.agreeuserids[#dismiss.agreeuserids+1]=self.agreeDismiss[i]
        end
        self:SendTableMsg(CMD_GF_FRAME.MS_DISMISS_CONFIRM,"Gamemsg.ms_dismiss_confirm",dismiss,wChairID,CMD_GF_FRAME.MAIN)    
    end
end
function TableFrame:PerformSitDownAction(pServerUserItem,wChairID)
    wChairID = wChairID or self:getFreeChair()
    assert(wChairID <= self.wChairCount)
    assert(self.bTableCreated)
    if nil == self.pUserItems[wChairID] then                    --首次坐下
        pServerUserItem:setUserStatus(enum_UserStatus.US_SIT, self.wTableID, wChairID)
        self.pUserItems[wChairID] = pServerUserItem
        self:OnActionUserSitDown(wChairID, pServerUserItem)

    elseif self.pUserItems[wChairID] == pServerUserItem then    --返回座位
        
    else
        assert(false)
    end
    --region send user sitdown    
    local roomPlayerInfo = {}
    roomPlayerInfo.userid = pServerUserItem.UserID
    roomPlayerInfo.nickname = pServerUserItem.UserInfo.nickname  or tostring(pServerUserItem.UserID)
    roomPlayerInfo.playerIcon = pServerUserItem.UserInfo.HeadImageUrl or ""
    roomPlayerInfo.playerIP = tostring(pServerUserItem.ClientIP)
    roomPlayerInfo.playerScore = pServerUserItem.playerScore or 0
    roomPlayerInfo.chairID = pServerUserItem.UserInfo.ChairID
    roomPlayerInfo.status = pServerUserItem.UserInfo.UserStatus
    roomPlayerInfo.gender = pServerUserItem.UserInfo.Sex    
    roomPlayerInfo.location = {
        jingdu = pServerUserItem.UserInfo.Jingdu,
	    weidu = pServerUserItem.UserInfo.Weidu,
	    permissiondenied = pServerUserItem.UserInfo.PermissionDenied,
	    userid = pServerUserItem.UserID,
	    city = pServerUserItem.UserInfo.City,
	    district = pServerUserItem.UserInfo.District,
	    address = pServerUserItem.UserInfo.Address
    }
    self:SendTableMsg(CMD_GF_FRAME.MS_USER_SITDOWN, 
        "Gamemsg.ms_room_player_join", 
        {player = roomPlayerInfo},nil,CMD_GF_FRAME.MAIN)

--    logNormalf("[%s]\ninput: %s\noutput: %s, \nresult: %s", 
--                    "ms_room_player_join", 
--                    table.tostring({}, true), 
--                    table.tostring({player = roomPlayerInfo}, true), 
--                    table.tostring(self, true))
    --endregion
end

function TableFrame:PerformReadyAction(pServerUserItem)    
    if self.enGameStatus ~= enum_GameStatus.GS_FREE then 
        logErrf("current room %d status is not in free, operation SUB_C_PLAYER_READY denied", self.wTableID)
        return 
    end 
    pServerUserItem:setUserStatus(enum_UserStatus.US_READY, self.wTableID, pServerUserItem:getChairID())
    self:OnActionUserOnReady(pServerUserItem:getChairID(),pServerUserItem)
        
    self:SendTableMsg(CMD_GF_FRAME.MS_USER_READY, 
        "Gamemsg.ms_player_ready", 
        {userid = pServerUserItem.UserID},nil,CMD_GF_FRAME.MAIN)

--    logNormalf("[%s]\ninput: %s\noutput: %s, \nresult: %s", 
--                    "ms_player_ready", 
--                    table.tostring({}, true), 
--                    table.tostring({userid = pServerUserItem.UserID}, true), 
--                    table.tostring(self, true))
    
    self:CheckStartGame()
end

function TableFrame:PerformDismissAction(pDataBuffer, wDataSize, pServerUserItem)
    local tbData = protobuf.decode("Gamemsg.mc_dismiss",pDataBuffer, wDataSize)
    if nil == tbData then return false end

    if self.enGameStatus == enum_GameStatus.GS_FREE and 0 == self.TableInfo.TotalPlayedCount then
        if pServerUserItem ~= self.pCreaterUserItem then
            return false
        end
        self:DismissGame(enum_GameOverReason.AGREE_DISMISS)
    else
        --region caller
        if #self.agreeDismiss == 0 then
            if not tbData.agree then return false end
            self.agreeDismiss[#self.agreeDismiss + 1] = pServerUserItem.UserID
            self.dismissRequestTime = os.time()
            self:SetFrameTimer(self.TIMER_ID_DISMISS_GAME,self.TIME_DISMISS_GAME,1,0)--启动解散定时器
            local dismiss = {calleruserid=pServerUserItem.UserID,lefttime=self.TIME_DISMISS_GAME};
            self:SendTableMsg(CMD_GF_FRAME.MS_DISMISS_CONFIRM,"Gamemsg.ms_dismiss_confirm",dismiss,nil,CMD_GF_FRAME.MAIN)
            return true
        end
        --endregion
        --region disagree
        if not tbData.agree then
            self.agreeDismiss = {}
            self:KillTableTimer(self.TIMER_ID_DISMISS_GAME)
            local dismissfail = {notagreeuserid = pServerUserItem.UserID}
            self:SendTableMsg(CMD_GF_FRAME.MS_DISMISS_FAIL,"Gamemsg.ms_dismiss_fail",dismissfail,nil,CMD_GF_FRAME.MAIN)
            return true
        end
        --endregion
        --region follow agree
        if #self.agreeDismiss >= self.wChairCount then return false end
        self.agreeDismiss[#self.agreeDismiss + 1] = pServerUserItem.UserID
        if #self.agreeDismiss >= self.wChairCount then
            self:KillTableTimer(self.TIMER_ID_DISMISS_GAME)
            self:DismissGame(enum_GameOverReason.AGREE_DISMISS)
            return true
        else
            self:trySendDismissGame();
        end
        --endregion
    end
    return true
end

function TableFrame:PerformStandUpAction(pServerUserItem)
    local userTableID,userChairID = pServerUserItem:getTableID(), pServerUserItem:getChairID()
    if self.wTableID ~= userTableID or userChairID > self.wChairCount or self.pUserItems[userChairID] ~= pServerUserItem then
        assert(false)
    end
    if self.enGameStatus ~= enum_GameStatus.GS_FREE then
        logErrf("current room %d status is not in free, user:%d operation PerformStandUpAction denied", self.wTableID,pServerUserItem.UserID)
        return
    end
    if 0 < self.TableInfo.TotalPlayedCount then
        logErrf("current room %d TotalPlayedCount > 0, user:%d operation PerformStandUpAction denied", self.wTableID,pServerUserItem.UserID)
        return
    end
    --创建者不可以起立，只可以解散游戏
    if self.pCreaterUserItem == pServerUserItem then        
        logErrf("creater can not stand up")
        return
    end
    pServerUserItem:setUserStatus(enum_UserStatus.US_FREE, INVALID_TABLE, INVALID_CHAIR)
    self:OnActionUserStandUp(userChairID,pServerUserItem)
    local standup = {userid = pServerUserItem.UserID};
    self:SendTableMsg(CMD_GF_FRAME.MS_STAND_UP,"Gamemsg.ms_standup",standup,nil,CMD_GF_FRAME.MAIN)
    self.pUserItems[userChairID] = nil
    self.bCheatersChecked = false
end

function TableFrame:PerformOfflineAction(pServerUserItem)
    local userTableID,userChairID = pServerUserItem:getTableID(), pServerUserItem:getChairID()
    if self.wTableID ~= userTableID or userChairID > self.wChairCount or self.pUserItems[userChairID] ~= pServerUserItem then
        assert(false)
    end
    if pServerUserItem:getUserStatus() == enum_UserStatus.US_SIT then
        pServerUserItem:setUserStatus(enum_UserStatus.US_OFFLINE_SIT, self.wTableID, userChairID)        
    else
        pServerUserItem:setUserStatus(enum_UserStatus.US_OFFLINE, self.wTableID, userChairID)
    end
    self:OnActionUserOffLine(userChairID,pServerUserItem)

    self:SendTableMsg(CMD_GF_FRAME.MS_USER_OFFLINE, 
        "Gamemsg.ms_player_offline", 
        {userid = pServerUserItem.UserID},nil,CMD_GF_FRAME.MAIN)

--    logNormalf("[%s]\ninput: %s\noutput: %s, \nresult: %s", 
--                    "ms_player_offline", 
--                    table.tostring({}, true), 
--                    table.tostring({userid = pServerUserItem.UserID}, true), 
--                    table.tostring(self, true))
end

function TableFrame:PerformReconnectAction(pServerUserItem)
    self.bCheatersChecked = false

    local userTableID,userChairID = pServerUserItem:getTableID(), pServerUserItem:getChairID()
    if self.wTableID ~= userTableID or userChairID > self.wChairCount or self.pUserItems[userChairID] ~= pServerUserItem then
        assert(false)
    end
    if self.enGameStatus == enum_GameStatus.GS_PLAYING then
        pServerUserItem:setUserStatus(enum_UserStatus.US_PLAYING, self.wTableID, userChairID)
    elseif pServerUserItem:getUserStatus() == enum_UserStatus.US_OFFLINE_SIT then
        pServerUserItem:setUserStatus(enum_UserStatus.US_SIT, self.wTableID, userChairID)
    else
        pServerUserItem:setUserStatus(enum_UserStatus.US_READY, self.wTableID, userChairID)        
    end
    self:OnActionUserReconnect(userChairID,pServerUserItem)
    self:SendTableMsg(CMD_GF_FRAME.MS_USER_RECONNECT, 
        "Gamemsg.ms_player_online", 
        {userid = pServerUserItem.UserID},nil,CMD_GF_FRAME.MAIN)
    
    self:SendGameScene(pServerUserItem)
    if pServerUserItem:getUserStatus() == enum_UserStatus.US_SIT then
        self:PerformReadyAction(pServerUserItem)
    end

    self:trySendDismissGame(userChairID)
end

function TableFrame:PerformLocationChangeAction(pServerUserItem)
    local location = {}
    location.userid = pServerUserItem.UserID
    location.jingdu = pServerUserItem.UserInfo.Jingdu
    location.weidu = pServerUserItem.UserInfo.Weidu
    location.permissiondenied = pServerUserItem.UserInfo.PermissionDenied
    location.city = pServerUserItem.UserInfo.City
    location.district = pServerUserItem.UserInfo.District
    location.address = pServerUserItem.UserInfo.Address
    self:SendTableMsg(CMD_GF_FRAME.MS_LOCATION,"Gamemsg.Location_latLng",location,nil,CMD_GF_FRAME.MAIN)
end

--endregion

--region 游戏控制
--region setter
function TableFrame:createTable(roomnum, rolls, playernum, createParams, pCreaterUserItem)

    assert(not self.bTableCreated)
    self.wChairCount = playernum
    
    self.TableInfo.Rolls = rolls
    self.TableInfo.PlayerNum = playernum
    self.TableInfo.createParams = createParams
    self.TableInfo.RoomNum = roomnum
    self.TableInfo.TotalPlayedCount = 0
    self.TableInfo.RoomGuid = string.lower(LuaUtil:GenerateGuidString())
    self.TableInfo.CreateTime = os.time();

    self.pCreaterUserItem = pCreaterUserItem
    self.bTableCreated = true
end
--endregion
--region check cheaters arithmetic
function TableFrame:checkCheatersConfirm()
    local tbUsers = self.pUserItems
    if config.CHECK_CHEATERS_IP then
        for i = 1, #tbUsers-1 do
            for j= i+1, #tbUsers do
                if tbUsers[i].ClientIP == tbUsers[j].ClientIP then
                    return true
                end 
            end                    
        end                
    end
            
    for i = 1, #tbUsers-1 do
        if tbUsers[i].UserInfo.Jingdu ~= INVALID_JINGDU then                    
            for j= i+1, #tbUsers do
                if tbUsers[j].UserInfo.Jingdu ~= INVALID_JINGDU and 
                    Util:calculateLineDistance(tbUsers[i].UserInfo.Jingdu,tbUsers[i].UserInfo.Weidu,
                    tbUsers[j].UserInfo.Jingdu,tbUsers[j].UserInfo.Weidu) <= config.CHECK_CHEATERS_DISTANCE then
                    return true
                end 
            end       
        end             
    end
    return false
end
--endregion 
function TableFrame:CheckStartGame()
    local pUserItems = self.pUserItems
    for i = 1,self.wChairCount do
        if nil == pUserItems[i] then return false end
        local userstatus = pUserItems[i]:getUserStatus() 
        if userstatus ~= enum_UserStatus.US_READY and userstatus ~= enum_UserStatus.US_OFFLINE then
            return false
        end
    end
    --region check cheaters
    if config.CHECK_CHEATERS and 0 == self.TableInfo.TotalPlayedCount and not self.bCheatersChecked and
        self:checkCheatersConfirm() then
        self.bCheatersChecked = true
        for i = 1,self.wChairCount do
            if pUserItems[i]:getUserStatus() ~= enum_UserStatus.US_OFFLINE then
                pUserItems[i]:setUserStatus(enum_UserStatus.US_SIT, self.wTableID, pUserItems[i]:getChairID())
            else
                pUserItems[i]:setUserStatus(enum_UserStatus.US_OFFLINE_SIT, self.wTableID, pUserItems[i]:getChairID())                
            end
        end
        self:SendTableMsg(CMD_GF_FRAME.MS_CHEATERES_CONFIRM,nil,nil,nil,CMD_GF_FRAME.MAIN)
        return false
    end
    --endregion

    --region set status
    self.enGameStatus = enum_GameStatus.GS_PLAYING
    for i = 1,self.wChairCount do
        if pUserItems[i]:getUserStatus() ~= enum_UserStatus.US_OFFLINE then
            pUserItems[i]:setUserStatus(enum_UserStatus.US_PLAYING, self.wTableID, pUserItems[i]:getChairID())
        end
    end
    if 0 == self.TableInfo.TotalPlayedCount then
        self.TableInfo.BeginTime = os.time()--设置第一局开始时间
        --region 扣除房卡
        ServerUserManager:getInstance():WriteRoomCard(self.pCreaterUserItem.UserID,0-config.CardPayConfig[self.TableInfo.Rolls],
                            enum_TypeCode_WealthChange.CREATE_ROOM,self.TableInfo.RoomGuid)
        --endregion
    end
    --endregion

    self:onGameStart()
    return true
end
function TableFrame:DismissGame(endReason)
    if self.enGameStatus == enum_GameStatus.GS_PLAYING then
        self:onGameEnd(endReason)
    end
    self:onDismiss()

    self:SendTableMsg(CMD_GF_FRAME.MS_DISMISS,nil,nil,nil,CMD_GF_FRAME.MAIN)
    for _,pUserItem in pairs(self.pUserItems) do
        pUserItem:setUserStatus(enum_UserStatus.US_FREE, INVALID_TABLE, INVALID_CHAIR)
    end
    self:ResetTableFrame()
end
--endregion 

--region getter
function TableFrame:getTableID()
    return self.wTableID
end
function TableFrame:getChairCount()
    return self.wChairCount
end
function TableFrame:getFreeChair()
    for i = 1, self.wChairCount do
        if nil == self.pUserItems[i] then
            return i
        end
    end
end
function TableFrame:getServerUserItem(wChairID)
    return self.pUserItems[wChairID]
end
function TableFrame:getGameStus()
    return self.enGameStatus
end
function TableFrame:isTableFree()
    return (not self.bTableCreated)
end
--endregion

--region 接口
function TableFrame:RequetAIPlay(needNum)
    if nil == self.TableInfo.RoomNum then
        logErr("RequetAIPlay self.TableInfo.RoomNum == nil")
        return 
    end
    local requestAI = {needainum = needNum,tableid = self.wTableID,roomnum =self.TableInfo.RoomNum}
    workthreadlib:PostAIServiceEventMsg(AIR_W2AI.REQUEST_AI_SITDOWN,"AIRMsg.Service_MW_RequestAI",requestAI)
end
--wChairID为nil时为桌子群发
function TableFrame:SendTableMsg(wSubCmdID, strTypeName, tbMsgContent, wChairID, wMainCmdId)
    if nil == wMainCmdId then wMainCmdId = MDM_GF_GAME.MAIN end
    if nil == wChairID then
        for _,pServerUserItem in pairs(self.pUserItems) do
            if pServerUserItem:getUserStatus() < enum_UserStatus.US_OFFLINE  then
                workthreadlib:SendMsgToClient(pServerUserItem, wMainCmdId, wSubCmdID, strTypeName, tbMsgContent)            
            end
        end
        return true
    end
    assert(wChairID <= self.wChairCount)
    if self.pUserItems[wChairID] then
        workthreadlib:SendMsgToClient(self.pUserItems[wChairID], wMainCmdId, wSubCmdID, strTypeName, tbMsgContent)
        return true
    end
    return false
end
function TableFrame:SendTableData(wSubCmdID, pDataBuffer, wDataSize, wChairID, wMainCmdId)    
    if nil == wMainCmdId then wMainCmdId = MDM_GF_GAME.MAIN end
    if nil == wChairID then
        for _,pServerUserItem in pairs(self.pUserItems) do        
            if pServerUserItem:getUserStatus() < enum_UserStatus.US_OFFLINE  then
                workthreadlib:SendDataToUserItem(pServerUserItem, wMainCmdId, wSubCmdID, pDataBuffer, wDataSize)
            end
        end
        return true
    end
    assert(wChairID <= self.wChairCount)
    if self.pUserItems[wChairID] then
        workthreadlib:SendDataToUserItem(self.pUserItems[wChairID], wMainCmdId, wSubCmdID, pDataBuffer, wDataSize)
        return true
    end
    return false
end
function TableFrame:SendUserMsg(pServerUserItem, wSubCmdID, strTypeName, tbMsgContent, wMainCmdId)
    if nil == wMainCmdId then wMainCmdId = MDM_GF_GAME.MAIN end
    workthreadlib:SendMsgToClient(pServerUserItem, wMainCmdId, wSubCmdID, strTypeName, tbMsgContent)
end
function TableFrame:SetGameTimer(dwTimerID, dwElapse, dwRepeat, dwBindParameter)
    assert(dwTimerID < TIMER.TIME_TABLE_GAME_RANGE)
    local dwRealTimerID = TIMER.ID_TABLE_MODULE_START+self.wTableID*TIMER.TIME_TABLE_MODULE_RANGE
    workthreadlib:SetTimer(dwRealTimerID + dwTimerID, dwElapse, dwRepeat, dwBindParameter)
end
function TableFrame:SetFrameTimer(dwTimerID, dwElapse, dwRepeat, dwBindParameter)
    assert(dwTimerID > TIMER.TIME_TABLE_GAME_RANGE and dwTimerID < TIMER.TIME_TABLE_MODULE_RANGE)
    local dwRealTimerID = TIMER.ID_TABLE_MODULE_START+self.wTableID*TIMER.TIME_TABLE_MODULE_RANGE
    workthreadlib:SetTimer(dwRealTimerID + dwTimerID, dwElapse, dwRepeat, dwBindParameter)
end
function TableFrame:KillTableTimer(dwTimerID)
    assert(dwTimerID < TIMER.TIME_TABLE_MODULE_RANGE)
    local dwRealTimerID = TIMER.ID_TABLE_MODULE_START+self.wTableID*TIMER.TIME_TABLE_MODULE_RANGE
    workthreadlib:KillTimer(dwRealTimerID + dwTimerID)
end
--endregion


--endregion
