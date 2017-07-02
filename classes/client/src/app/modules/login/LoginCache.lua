--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local RoomServer = require("app.modules.login.RoomServer")

local LoginCache = class("LoginCache")

function LoginCache:ctor(arg)
    self.name = "LoginCache"
    self.roomServers = {}
    self.reconnHomeAllowed = false

    self.loginID = 0
    self.loginPwd = ""
    self.test_password = "e10adc3949ba59abbe56e057f20f883e"
    
    Network:registerMsgProc(Define.SERVER_HOME, "ms_disconnect", self, "ms_disconnect")
    Network:registerMsgProc(Define.SERVER_HOME, "ms_connect", self, "ms_connect")
    Network:registerMsgProc(Define.SERVER_HOME, "Logon_MS_LogonRes", self, "Logon_MS_LogonRes")
    Network:registerMsgProc(Define.SERVER_HOME, "ms_room_servers", self, "ms_room_servers")
    Network:registerMsgProc(Define.SERVER_HOME, "ms_room_session", self, "ms_room_session")
    Network:registerMsgProc(Define.SERVER_HOME, "ms_logon_finish", self, "ms_logon_finish")
    Network:registerMsgProc(Define.SERVER_HOME, "ms_room_server_reg", self, "ms_room_server_reg")
    Network:registerMsgProc(Define.SERVER_HOME, "ms_room_server_unreg", self, "ms_room_server_unreg")

    Event.register(EventDefine.ICON_DOWNLOADED, self, "ICON_DOWNLOADED")
end

function LoginCache:reset()
    self.roomServers = {}
    self.reconnHomeAllowed = false

    self.loginID = 0
    self.loginPwd = ""
end 

function LoginCache:loginHome(loginID, token)
    self.loginID = loginID or self.loginID
    self.loginPwd = token or self.test_password
    PlayerCache.password = self.loginPwd
    if Network:isServerConnected(Define.SERVER_HOME) then 
        return false
    end 
    Network:connect(Define.SERVER_HOME, Define.Server.IP, Define.Server.PORT)
    return true
end 

function LoginCache:disconnHome()
    self.reconnHomeAllowed = false
    Network:disconnect(Define.SERVER_HOME)
end 

function LoginCache:getRoomServer(roomnum)
    --region TODO
    local kindid, serverid = GameDefine.MJTYPE.NORMAL, math.floor(roomnum/100);
    print(kindid .. "  " .. serverid .. " " .. #self.roomServers)
    --endregion
    for _,server in ipairs(self.roomServers) do
        print (server.kindID .. " " .. server.serverID)
        if kindid == server.kindID and serverid == server.serverID then
            return server
        end
    end
end

function LoginCache:pickRoomServer()
    local minOnlineNum,targetserver = 65535, nil
    for _,server in ipairs(self.roomServers) do
        if minOnlineNum > server.onlineUserNum then
            targetserver = server
            minOnlineNum = server.onlineUserNum
        end
    end
    return targetserver
end

--region netmsg
function LoginCache:ms_disconnect()
    Event.dispatch("MS_DISCONNECT_HOME")
    if self.reconnHomeAllowed then 
        require("app.modules.common.ReconnectLayer").reconn(Define.SERVER_HOME)
    end 
end

function LoginCache:ms_connect(data)
    if data.success then 
        if (device.platform == "android" or device.platform =="ios") and LOGIN_USE_WECHAT then
            Network:send(Define.SERVER_HOME, "Logon_MC_WechatLogon", {
                            openid = self.loginID, 
                            token = self.loginPwd})
        else
            Network:send(Define.SERVER_HOME, "Logon_MC_LogonOrRegByUserID", {
                            userid = tonumber(self.loginID), 
                            token = self.loginPwd})
        end
    else
        Event.dispatch("HOME_LOGON_MS_LOGONRES",{err = ErrorDefine.SERVER_CONN_FAILED})
    end 
end

function LoginCache:Logon_MS_LogonRes(data)
    if data.err == 0 then 
        PlayerCache.userid = data.userid
        PlayerCache.nickname = Helper.cutNameWithAvaiLen(data.nickname)
        PlayerCache.account = data.account
        PlayerCache.roomcardnum = data.roomcardnum
        PlayerCache.ip = util.convertIPV4ToStr(data.ip or "0")
        PlayerCache.icon = data.icon
        PlayerCache.gender = data.gender or 0
        local urlIcon = data.icon
        if PlayerCache.gender == Define.GENDER_FEMALE then 
            PlayerCache.icon = "public/head_female.png"
        else
            PlayerCache.icon = "public/head_male.png"
        end 
        local localIcon = IconManager:getIcon(PlayerCache.userid, urlIcon)
        if localIcon then 
            PlayerCache.icon = localIcon
        end 
    end 

    Event.dispatch("HOME_LOGON_MS_LOGONRES", data)
end 

function LoginCache:ms_room_servers(data)
    self.roomServers = {}
    for _,serverinfo in ipairs(data.server_infos) do
        --add server
        local found = false
        for index, server in ipairs(self.roomServers) do           
            if server.kindID == serverinfo.kindid and server.serverID == serverinfo.serverid then
                server:updateInfos(serverinfo)
                found = true
                break
            end
        end
        if not found then 
            table.insert(self.roomServers,RoomServer:create(serverinfo))
        end 
    end
    
end

function LoginCache:ms_room_server_reg(data)
    for _,serverinfo in ipairs(data.server_infos) do
        --add server
        local found = false
        for index, server in ipairs(self.roomServers) do           
            if server.kindID == serverinfo.kindid and server.serverID == serverinfo.serverid then
                server:updateInfos(serverinfo)
                found = true
                break
            end
        end
        if not found then 
            table.insert(self.roomServers,RoomServer:create(serverinfo))
        end 
    end
end

function LoginCache:ms_room_server_unreg(data)
    table.delete(self.roomServers, function(server)
        return server.kindID == data.kindid and server.serverID == data.serverid
    end)
end

function LoginCache:ms_room_session(data)
    HomeCache.reconnGameServer = RoomServer:create(data.connected_server)
    HomeCache.reconnGameAllowed = true
end

function LoginCache:ms_logon_finish(data)
    --goto homelayer
    Event.dispatch("HOME_LOGON_FINISH",data)
    VoiceSDK:Login(PlayerCache.nickname,PlayerCache.userid)
    self.reconnHomeAllowed = true
end

function LoginCache:ICON_DOWNLOADED(data)
    if data.userid ~= PlayerCache.userid then 
        --it's not my business
        return 
    end 
    if data.err then 
        printInfo("[ERROR] [%d] Icon download error: %s", data.userid, data.err.msg)
        return
    end 
    PlayerCache.icon = data.iconFileName
    if not PlayerCache.icon or PlayerCache.icon == "" then 
        if PlayerCache.gender == Define.GENDER_FEMALE then 
            PlayerCache.playerIcon = "public/head_female.png"
        else
            PlayerCache.playerIcon = "public/head_male.png"
        end 
    end 
end

return LoginCache
--endregion
