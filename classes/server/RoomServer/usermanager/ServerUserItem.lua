--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

-----------------------用户（指挥官）基本信息类-----------------------
--[[
UserInfo = {
	nickname,				--用户昵称
    --region 用户状态
    UserStatus,             --用户状态enum_UserStatus
    TableID,
    ChairID,
    --endregion
}
--]]

------------------------------用户ServerUserItem--------------------------------
local UserInfo = {
    nickname = "",
    UserStatus = enum_UserStatus.US_NULL,             --用户状态enum_UserStatus
    TableID = INVALID_TABLE,
    ChairID = INVALID_CHAIR,
    Sex=1,
    HeadImageUrl = "",
    
    RoomCardNum = 0,

    City = "",
    District = "",
    Address = "",
    Jingdu = INVALID_JINGDU,--用户位置 经度
    Weidu = INVALID_WEIDU,--用户位置 纬度
    PermissionDenied = false,--用户是否禁止了定位
}
UserInfo = Util:newClass(UserInfo)

ServerUserItem = {

	UserID,					--用户ID
    Password,               --用户密码
    Token,
    TokenRefreshTime,

    SocketIndex=INVALID_SOCKET_INDEX,
    ClientIP = 0,

	UserInfo = {}, 						--保存UserInfo对象

    bLogonSuccess = false,
    bLogonFinish = false,

    bScoreDirty = false,
}

ServerUserItem = Util:newClass(ServerUserItem)

local workthreadlib;
local serverusermgr

local function ServiceStart( globalworkthreadlib)
    workthreadlib = globalworkthreadlib
    serverusermgr = globalworkthreadlib.serverusermgr
end
beholderlib.observe(BEHOLDER_EVENTTYPE.SERVICE_START, nil, ServiceStart)

function ServerUserItem:Init(dwUserID,logonRes)
    self.UserID = dwUserID
    self.Password = logonRes.password
    self.Token = logonRes.token
    self.TokenRefreshTime = logonRes.tokenrefreshtime

    self.UserInfo = UserInfo:new()
    self.UserInfo.nickname = logonRes.nickname
    self.UserInfo.UserStatus = enum_UserStatus.US_NULL
    self.UserInfo.Sex = logonRes.sex
    self.UserInfo.HeadImageUrl = logonRes.headimageurl
    
    self.UserInfo.RoomCardNum = logonRes.roomcardnum
end

--region getter%setter
function ServerUserItem:setLocation(jingdu,weidu,permissiondenied,city,district,address)
    self.UserInfo.City = city
    self.UserInfo.District = district
    self.UserInfo.Address = address
    self.UserInfo.Jingdu = jingdu
    self.UserInfo.Weidu = weidu
    self.UserInfo.PermissionDenied = permissiondenied
end
function ServerUserItem:setLogonFinish()
    self.bLogonFinish = true
    self.UserInfo.UserStatus = enum_UserStatus.US_FREE
end
function ServerUserItem:setConnectInfo(dwClientIP, wSocketIndex)    --登录，重连，断线要调用
    self.SocketIndex = wSocketIndex
    self.ClientIP = dwClientIP
end
function ServerUserItem:setUserStatus(user_status,table_id,chair_id)
    local userinfo = self.UserInfo
    local wOldTableID,wOldChairID = userinfo.TableID, userinfo.ChairID

    userinfo.UserStatus = user_status
    userinfo.TableID = table_id
    userinfo.ChairID = chair_id
    serverusermgr:OnEventUserItemStatus(self,wOldTableID,wOldChairID)
end

--region 用户数据修改
function ServerUserItem:WriteRoomCard(RoomCardChange)
    self.UserInfo.RoomCardNum = self.UserInfo.RoomCardNum + RoomCardChange
end
--endregion

function ServerUserItem:getSocketIndex()
    return self.SocketIndex
end
function ServerUserItem:getUserID()
    return self.UserID
end
function ServerUserItem:getUserStatus()
    return self.UserInfo.UserStatus
end
function ServerUserItem:getTableID()
    return self.UserInfo.TableID
end
function ServerUserItem:getChairID()
    return self.UserInfo.ChairID
end

function ServerUserItem:isUserPwdRight(pwd)
    return (string.lower(pwd) == self.Password)
end
function ServerUserItem:isUserTokenRight(token)
    return (string.lower(token) == string.lower(self.Token))
end
function ServerUserItem:isLogonFinish()
    return self.bLogonFinish
end
function ServerUserItem:isInTable()
    return self.UserInfo.UserStatus >= enum_UserStatus.US_SIT
end
function ServerUserItem:isOnline()
    return self.SocketIndex ~= INVALID_SOCKET_INDEX
end
function ServerUserItem:isPlaying()
    return self.UserInfo.UserStatus == enum_UserStatus.US_PLAYING
end
--endregion
--endregion
