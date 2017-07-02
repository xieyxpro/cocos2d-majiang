--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
-------------------------------桌子管理类---------------------------------
local workthreadlib = workthreadlib
local roomnummanager = roomnummanager
local servermanager = servermanager
TableManager = {
    tableFrameMgr = {},
}
TableManager = Util:newClass(TableManager, SystemBase)

--region instance
local __tableManageInstance = TableManager:new() --单例模式
function TableManager:getInstance( )
	if nil == __tableManageInstance then
		__tableManageInstance = TableManager:new()
	end
	return __tableManageInstance
end
--endregion

function TableManager:OnServiceStart(workthreadlib_global)
    workthreadlib = workthreadlib_global
    roomnummanager = workthreadlib_global.roomnummanager
    servermanager = workthreadlib_global.servermanager
    self:createFreeTables()
end

function TableManager:OnUserLocationChange(pServerUserItem)
    local wTableID = pServerUserItem:getTableID()
    local pTableFrame = self:getTableFrame(wTableID)
    if nil ~= pTableFrame then
        pTableFrame:PerformLocationChangeAction(pServerUserItem)
    end
end

function TableManager:OnUserOffline(pServerUserItem)
    local wTableID = pServerUserItem:getTableID()
    local pTableFrame = self:getTableFrame(wTableID)
    if nil ~= pTableFrame then
        pTableFrame:PerformOfflineAction(pServerUserItem)
    end    
end

function TableManager:OnReconnectCheck(pServerUserItem)
    local wTableID = pServerUserItem:getTableID()
    local pTableFrame = self:getTableFrame(wTableID)
    if nil == pTableFrame then
        return false
    end
    --region send table info
    local room = {}
    room.rolls = pTableFrame.TableInfo.Rolls--游戏局数
    room.people = pTableFrame.wChairCount--人数
    room.createParams = pTableFrame.TableInfo.createParams--可选玩法

    room.roomID = pTableFrame.TableInfo.RoomNum;
    room.roomCreaterUserID = pTableFrame.pCreaterUserItem.UserID
    room.rollsCnt = pTableFrame.TableInfo.TotalPlayedCount
    local msRoomInfo = {roomInfo = room}
    workthreadlib:SendMsgToClient(pServerUserItem, CMD_USER.MAIN, CMD_USER.SUB_MS_TABLE_INFO, "Gamemsg.ms_room_info", msRoomInfo)
    --endregion
end
beholderlib.observe(BEHOLDER_EVENTTYPE.USER_RECONNECT_CHECK_INTABLE,__tableManageInstance,__tableManageInstance.OnReconnectCheck)

function TableManager:createFreeTables()
    for i = 1, config.TABLE_COUNT do
        self.tableFrameMgr[i] = TableGameMain:new()
        self.tableFrameMgr[i]:Init(i)
    end    
end

function TableManager:pickFreeTable()
    for i = 1, config.TABLE_COUNT do
        if self.tableFrameMgr[i]:isTableFree() then
            return i, self.tableFrameMgr[i]
        end
    end    
end
function TableManager:createPrivateTable(tbData,pServerUserItem)
    assert(nil ~= tbData)
    local rolls = tbData.rolls  --游戏局数
    local playernum = tbData.people  --人数
    local createParams = tbData.createParams      --玩法

    local createRes = {err = ErrorDefine.CREATE_ROOM_FAILED}

    --region check param right
    if playernum > config.TABLE_MAX_CHAIR then
        logWarningf("userid:%d createroom playernum %d error",pServerUserItem.UserID,playernum)
        return 1
    end
    --endregion

    if servermanager.localServer.bStoping then
        logException("createPrivateTable while Server Stoping")
    end

    --region check room cardk
    local needRoomCardNum = config.CardPayConfig[rolls]
    if nil == needRoomCardNum then 
        logWarningf("userid:%d createroom rolls %d error",pServerUserItem.UserID,rolls)
        workthreadlib:SendMsgToClient(pServerUserItem, CMD_USER.MAIN, CMD_USER.SUB_MS_TABLE_CREATE, "Gamemsg.ms_create_room", createRes)
        return 1 
    end
    if pServerUserItem.UserInfo.RoomCardNum < needRoomCardNum then
        logWarningf("userid:%d createroom rolls %d, room card not enough",pServerUserItem.UserID,rolls)
        workthreadlib:SendMsgToClient(pServerUserItem, CMD_USER.MAIN, CMD_USER.SUB_MS_TABLE_CREATE, "Gamemsg.ms_create_room", createRes)
        return 1         
    end
    --endregion

    local freeTableid,pTableFrame = self:pickFreeTable();
    --region check game role

    --endregion
    if nil == freeTableid then  --房间满了
        --send create room fail
        workthreadlib:SendMsgToClient(pServerUserItem, CMD_USER.MAIN, CMD_USER.SUB_MS_TABLE_CREATE, "Gamemsg.ms_create_room", createRes)
        return 0 
    end
    --region 
    local freeRoomNum = roomnummanager:pickFreeRoomNum(pTableFrame)
    if nil == freeRoomNum then
        --send create room fail
        workthreadlib:SendMsgToClient(pServerUserItem, CMD_USER.MAIN, CMD_USER.SUB_MS_TABLE_CREATE, "Gamemsg.ms_create_room", createRes)
        return 0         
    end
    --endregion
    --region
    local room = {}
    room.rolls = tbData.rolls--游戏局数
    room.people = tbData.people--人数
    room.createParams = tbData.createParams     --玩法

    room.roomID = freeRoomNum--config.ServerID*100 + freeTableid;
    room.roomCreaterUserID = pServerUserItem.UserID
    room.rollsCnt = 0
    local msRoomInfo = {roomInfo = room}
    workthreadlib:SendMsgToClient(pServerUserItem, CMD_USER.MAIN, CMD_USER.SUB_MS_TABLE_INFO, "Gamemsg.ms_room_info", msRoomInfo)
    --endregion
    --regigon sitdown
    pTableFrame:createTable(room.roomID, rolls, playernum, createParams, pServerUserItem)
    pTableFrame:PerformSitDownAction(pServerUserItem)
    --endregion
    return 0
end

function TableManager:joinPrivateTable(tbData,pServerUserItem)
    local pTableFrame = roomnummanager:getTableFrame(tbData.roomID)
    if nil == pTableFrame then
        local joinres = {err = ErrorDefine.JOIN_ROOM_FAILED_NOT_EXISTS}
        workthreadlib:SendMsgToClient(pServerUserItem, CMD_USER.MAIN, CMD_USER.SUB_MS_TABLE_JOIN, "Gamemsg.ms_join_room", joinres)
        return 0
    end
    if pTableFrame:isTableFree() or nil == pTableFrame:getFreeChair() then
        --send join fail
        local joinres = {err = ErrorDefine.JOIN_ROOM_FAILED_FULL}
        workthreadlib:SendMsgToClient(pServerUserItem, CMD_USER.MAIN, CMD_USER.SUB_MS_TABLE_JOIN, "Gamemsg.ms_join_room", joinres)
        return 0
    end
    --region
    local room = {}
    room.rolls = pTableFrame.TableInfo.Rolls--游戏局数
    room.createParams = pTableFrame.TableInfo.createParams--可选玩法
    room.people = pTableFrame.wChairCount--人数

    room.roomID = pTableFrame.TableInfo.RoomNum;
    room.roomCreaterUserID = pTableFrame.pCreaterUserItem.UserID
    room.rollsCnt = pTableFrame.TableInfo.TotalPlayedCount
    local msRoomInfo = {roomInfo = room}
    workthreadlib:SendMsgToClient(pServerUserItem, CMD_USER.MAIN, CMD_USER.SUB_MS_TABLE_INFO, "Gamemsg.ms_room_info", msRoomInfo)
    --endregion
    --region sitdown
    pTableFrame:PerformSitDownAction(pServerUserItem)
    --endregion
end

function TableManager:dismissGame(wTableID)
    
end

--region getter
function TableManager:getTableFrame(wTableID)
    if wTableID <= config.TABLE_COUNT then
        return self.tableFrameMgr[wTableID]
    end
end
--endregion


--region 注册网络接口
function TableManager:OnTableMesssage(wMainCmdID, wSubCmdID, pDataBuffer, wDataSize, pServerUserItem)
    local tableid = pServerUserItem:getTableID()
    assert(tableid > 0 and tableid <= config.TABLE_COUNT,"CMD:" .. wMainCmdID .. "-" .. wSubCmdID)
    local tableframe = self:getTableFrame(tableid)
    if CMD_GF_FRAME.MAIN == wMainCmdID then
        return tableframe:onFrameMessage(wSubCmdID, pDataBuffer, wDataSize, pServerUserItem)    
    elseif MDM_GF_GAME.MAIN == wMainCmdID then    
        return tableframe:onGameMessage(wSubCmdID, pDataBuffer, wDataSize, pServerUserItem)
    end
    assert(false)
end
function TableManager:OnTimerMessage(dwTimerID, dwBindParam)
    local dwTableTimerID = dwTimerID - TIMER.ID_TABLE_MODULE_START
    local tableid = math.floor(dwTableTimerID / TIMER.TIME_TABLE_MODULE_RANGE)
    if tableid > config.TABLE_COUNT then
        assert(false)
    end
    local pTableFrame = self:getTableFrame(tableid);
    pTableFrame:onTimerMessage(dwTableTimerID % TIMER.TIME_TABLE_MODULE_RANGE, dwBindParam)
end
--endregion

gameSystems[#gameSystems + 1] = __tableManageInstance
event.register_socket_listener(CMD_USER.MAIN, CMD_USER.SUB_MC_TABLE_CREATE,__tableManageInstance,TableManager.createPrivateTable,"Gamemsg.mc_create_room")
event.register_socket_listener(CMD_USER.MAIN, CMD_USER.SUB_MC_TABLE_JOIN, __tableManageInstance, TableManager.joinPrivateTable,"Gamemsg.mc_join_room")

--endregion
