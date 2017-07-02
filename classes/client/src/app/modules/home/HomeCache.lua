--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local HomeCache = class("HomeCache")

function HomeCache:ctor()
    self.roomID = 0
    self.reconnGameAllowed = false
    self.reconnGameServer = nil
    
    Network:registerMsgProc(Define.SERVER_HOME, "ms_roomnum_query_res", self, "ms_roomnum_query_res")
    
    Network:registerMsgProc(Define.SERVER_GAME, "ms_disconnect", self, "ms_disconnect")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_connect", self, "ms_connect")
    Network:registerMsgProc(Define.SERVER_GAME, "Logon_MS_LogonRes", self, "ms_room_logon_res")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_room_logon_finish", self, "ms_room_logon_finish")
end 

function HomeCache:reset()
    self.roomID = 0
    self.reconnGameAllowed = false
    self.reconnGameServer = nil
end 

function HomeCache:ms_disconnect()
    Event.unregister(EventDefine.AMAP_LOCATION_CALLBACK,self,"amap_location_callback")
    Event.dispatch("MS_DISCONNECT_GAME")
    if self.reconnGameAllowed then 
        require("app.modules.common.ReconnectLayer").reconn(Define.SERVER_GAME)
    end 
end

function HomeCache:ms_connect(data)
    if data.success then 
        printInfo("server connected and login")
        Event.dispatch("MS_CONNECT_GAME", data)
        local logonReq = {
                    userid = tonumber(PlayerCache.userid), 
                    password = PlayerCache.password}

        if (device.platform == "android" or device.platform =="ios") and LOGIN_USE_WECHAT then
            logonReq.pwdtype="WECHAT_TOKEN"
        end
            
        Network:send(Define.SERVER_GAME, "Logon_MC_LogonByUserID", logonReq)
    else 
        printInfo("server failed")
        Event.dispatch("GAME_LOGON_MS_LOGONRES",{err = ErrorDefine.SERVER_CONN_FAILED})
    end 
end

function HomeCache:ms_room_logon_res(data)
    printInfo("HomeCache:ms_room_logon_res")
    if not data.err or data.err == 0 then 
        self.roomID = data.tableid ~= Define.INVALID_TABLE and data.tableid or 0
    else
        self:disconnGame()
    end 
    Event.dispatch("GAME_LOGON_MS_LOGONRES",data)
end

function HomeCache:ms_room_logon_finish(data)
    printInfo("HomeCache:ms_room_logon_finish")
    self:try_send_location()
    self.reconnGameAllowed = true
    --printInfo("ms_room_logon_finish")
    Event.dispatch("GAME_LOGON_MS_FINISH",data)
end

function HomeCache:try_send_location()
    printInfo("HomeCache:try_send_location")
    if PlayerCache.jingdu == Define.INVALID_JINGDU then
        Event.register(EventDefine.AMAP_LOCATION_CALLBACK,self,"amap_location_callback")
        return
    end
    local location = {
        jingdu = PlayerCache.jingdu,
        weidu = PlayerCache.weidu,
        permissiondenied = PlayerCache.permissiondenied,
        city = PlayerCache.city,
        district = PlayerCache.district,
        address = PlayerCache.address
    }
    Network:send(Define.SERVER_GAME,"mc_location",location)
end
function HomeCache:amap_location_callback(data)
    if data.res then
        self:try_send_location()
    end
end

function HomeCache:disconnGame()
    self.reconnGameAllowed = false
    Network:disconnect(Define.SERVER_GAME)
end 

function HomeCache:loginGame(roomserver)
    printInfo("HomeCache:loginGame")
    if Network:isServerConnected(Define.SERVER_GAME) then 
        return false
    end 
    if self.reconnGameAllowed then
        roomserver = roomserver or self.reconnGameServer    
    end
    roomserver = roomserver or LoginCache:pickRoomServer()
    self.reconnGameServer = roomserver
    if not roomserver then 
        SchedulerExt:delayExecute(0, function()
            Event.dispatch("GAME_LOGON_MS_LOGONRES",{err = ErrorDefine.NO_AVAILABLE_ROOM_SERVER})
        end)
        return false
    end 
    Network:connect(Define.SERVER_GAME, roomserver.ip, roomserver.port)
    return true
end 

function HomeCache:queryRoomId(roomid)
    printInfo("HomeCache:queryRoomId")
    local req = {roomnum=roomid}
    Network:send(Define.SERVER_HOME, "mc_roomnum_query", req)
end
function HomeCache:ms_roomnum_query_res(data)
    printInfo("HomeCache:ms_roomnum_query_res")
    if data.serverip ~= "" then        
        Network:connect(Define.SERVER_GAME, data.serverip, data.port)
    else
        Event.dispatch(EventDefine.ROOMNUM_QUERY_ROOM_NUM_ERROR)
    end
end

return HomeCache
--endregion
