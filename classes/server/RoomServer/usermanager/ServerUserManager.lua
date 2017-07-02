--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local workthreadlib;
local tablemanager;

local function ServiceStart( globalworkthreadlib)
    workthreadlib = globalworkthreadlib
    tablemanager = globalworkthreadlib.tablemanager
end
beholderlib.observe(BEHOLDER_EVENTTYPE.SERVICE_START, nil, ServiceStart)

-------------------------------用户管理类---------------------------------
ServerUserManager = {

	mapAliveUser={}, 		--保存所有活跃在线用户的信息映射<dwUserID, ServerUserItem对象>
	mapInactiveUser={},		--保存所有不活跃在线用户的信息映射<dwUserID, ServerUserItem对象>
}
ServerUserManager = Util:newClass(ServerUserManager)

--region instance
local __userManageInstance = ServerUserManager:new() --单例模式
function ServerUserManager:getInstance( )
	if nil == __userManageInstance then
		__userManageInstance = ServerUserManager:new()
	end
	return __userManageInstance
end
--endregion

function ServerUserManager:ActiveUser( dwUserID, dwClientIP, wSocketIndex, logonRes )
	if nil ~= self.mapAliveUser[dwUserID] then
		Util:OutString( "ServerUserManager:ActiveUser, The user item is already in the ActiveUser map.", "Exception")
		return false
	end

	local pServerUserItem = ServerUserItem:new()
    pServerUserItem:Init(dwUserID, logonRes)
    pServerUserItem:setConnectInfo(dwClientIP, wSocketIndex)
    pServerUserItem.bLogonSuccess = true
    pServerUserItem.bLogonFinish = true
	self.mapAliveUser[dwUserID] = pServerUserItem
	return pServerUserItem
end

function ServerUserManager:setUserOffline( pServerUserItem )
    local dwUserID = pServerUserItem:getUserID()
    local pServerUserItem = self.mapAliveUser[dwUserID]
	if (nil == pServerUserItem) or (nil ~= self.mapInactiveUser[dwUserID]) then
		logException( "ServerUserManager:setUserOffline, The user UserID=" .. tostring(dwUserID) .. " item is already in the InactiveUser map" )
		return false 
	end

    pServerUserItem:setConnectInfo(INVALID_IP,INVALID_SOCKET_INDEX)
	self.mapInactiveUser[dwUserID] = self.mapAliveUser[dwUserID] --添加到不活跃表中
	self.mapAliveUser[dwUserID] = nil  --删除活跃表中的dwUserID对象
	Util:OutString( "ServerUserManager:InactiveUser, Move the user UserID=" .. tostring(dwUserID) .. " item to the inactive map successfully" )

end

function ServerUserManager:OnUserReconnect(pServerUserItem,dwClientIP,wSocketIndex)
    assert(pServerUserItem == self.mapInactiveUser[pServerUserItem.UserID] or pServerUserItem == self.mapAliveUser[pServerUserItem.UserID])
    if self.mapAliveUser[pServerUserItem.UserID] == nil then    --断线重连
        self.mapAliveUser[pServerUserItem.UserID] = pServerUserItem
        assert(self.mapInactiveUser[pServerUserItem.UserID] == pServerUserItem)
        self.mapInactiveUser[pServerUserItem.UserID] = nil
    else                                                    --被挤下线
        assert(self.mapInactiveUser[pServerUserItem.UserID] == nil and self.mapAliveUser[pServerUserItem.UserID] == pServerUserItem)
    end
    pServerUserItem:setConnectInfo(dwClientIP, wSocketIndex)
end

--写用户财富
local SendWealthChangeToClient = function (pServerUserItem,RoomCardChangeNum,nTypeCode,params)
    local WealthChange = {}
    WealthChange.roomcardchangenum = RoomCardChangeNum
    WealthChange.typecode = nTypeCode
    WealthChange.params = params
    workthreadlib:SendMsgToClient(pServerUserItem, CMD_USER.MAIN, CMD_USER.SUB_MS_WEALTH_CHANGE, "Gamemsg.User_MS_WealthChange", WealthChange)
end;
local WriteRoomCardChangeToDB = function (dwUserID, RoomCardChangeNum, nTypeCode, params)
    local RoomCardChange = {}
	RoomCardChange.userid = dwUserID
    RoomCardChange.roomcardchange = RoomCardChangeNum
    RoomCardChange.typecode = nTypeCode
    RoomCardChange.params = params
    workthreadlib:PostDataBaseEventMsg(DBR_W2DB.DBR_USER_ROOMCARD_CHANGE,"DBRMsg.User_MW_RoomCardChange",RoomCardChange,dwUserID)
end;
function ServerUserManager:WriteRoomCard(dwUserID, RoomCardChangeNum, nTypeCode, params)
    assert(0 ~= RoomCardChangeNum)
    local pServerUserItem = self:getOnlineOrOfflineUserItem(dwUserID)
    if nil ~= pServerUserItem then
        --mem
        pServerUserItem:WriteRoomCard(RoomCardChangeNum)
        --send data to client
        SendWealthChangeToClient(pServerUserItem,RoomCardChangeNum, nTypeCode, params)
    end
    --db
    WriteRoomCardChangeToDB(dwUserID, RoomCardChangeNum, nTypeCode, params)
end

function ServerUserManager:OnEventUserItemStatus(pServerUserItem, wOldTableID, wOldChairID)
    local UserStatusChange = {
        userid = pServerUserItem.UserID,
        userstatus = pServerUserItem.UserInfo.UserStatus,
        tableid = pServerUserItem.UserInfo.TableID,
        chairid = pServerUserItem.UserInfo.ChairID
    }
    if wOldTableID ~= INVALID_TABLE then
        local pTableFrame = tablemanager:getTableFrame(wOldTableID)
        pTableFrame:SendTableMsg(CMD_USER.SUB_MS_STATUS_CHANGE,"Gamemsg.User_MS_StatusChange",UserStatusChange,nil,CMD_USER.MAIN)        
    end
    if pServerUserItem.UserInfo.TableID ~= INVALID_CHAIR then
        local pTableFrame = tablemanager:getTableFrame(pServerUserItem.UserInfo.TableID)
        pTableFrame:SendTableMsg(CMD_USER.SUB_MS_STATUS_CHANGE,"Gamemsg.User_MS_StatusChange",UserStatusChange,nil,CMD_USER.MAIN)
    end
end
--删除用户
function ServerUserManager:DeleteServerUserItem( pUserItem )

    local dwUserID = pUserItem:getUserID()

	local pServerUserItem = self:getOnlineOrOfflineUserItem(dwUserID)
    assert(pUserItem == pServerUserItem)
	--待删除用户已经被删除
	if nil == pServerUserItem then 	
		Util:OutString( "ServerUserManager:DeleteServerUserItem, The user UserID=" .. tostring(dwUserID) .. " item is not in mem" )
		return false	
	end

    --[[
    local pUserInfo = pServerUserItem:GetUserInfo()
	--用户数据回写
    if pServerUserItem.bScoreDirty then
        local UpdateScoreInfo = {}
        UpdateScoreInfo.dwUserID = dwUserID
        local pUpdateScoreInfo = protobuf.encode("DBRMsg.User_UpdateScoreInfo",UpdateScoreInfo)
        workthreadlib:PostDataBaseEvent(DBR_W2DB.DBR_UPDATE_USER_SCOREINFO, pUpdateScoreInfo, pUpdateScoreInfo:len(), dwUserID)
    end
	--]]
	self.mapAliveUser[dwUserID] = nil
	self.mapInactiveUser[dwUserID] = nil  --回写成功后删除用户信息
	return true
end

function ServerUserManager:setUserLocation(tbData,pServerUserItem)
    pServerUserItem:setLocation(tbData.jingdu,tbData.weidu,tbData.permissiondenied,tbData.city,tbData.district,tbData.address)
    if pServerUserItem:getTableID() ~= INVALID_TABLE then
        TableManager:getInstance():OnUserLocationChange(pServerUserItem)
    end
end

--获取当前在线人数
function ServerUserManager:getOnlineNum()
    return table.count(self.mapAliveUser)
end
function ServerUserManager:getOnlineUserItem( dwUserID )
    return self.mapAliveUser[dwUserID]
end
function ServerUserManager:getOfflineUserItem( dwUserID )
    return self.mapInactiveUser[dwUserID]
end
function ServerUserManager:getOnlineOrOfflineUserItem( dwUserID )
	return (self.mapAliveUser[dwUserID] or self.mapInactiveUser[dwUserID])
end

function ServerUserManager:GetAllMemUsers()
    local tbUserIds = {}
    for userid,useritem in pairs(self.mapAliveUser) do
        tbUserIds[userid] = useritem
    end
    for userid,useritem in pairs(self.mapInactiveUser) do
        tbUserIds[userid] = useritem
    end
    return tbUserIds
end
event.register_socket_listener(CMD_USER.MAIN, CMD_USER.SUB_MC_LOCATION, __userManageInstance, ServerUserManager.setUserLocation,"Gamemsg.Location_latLng")
--endregion
