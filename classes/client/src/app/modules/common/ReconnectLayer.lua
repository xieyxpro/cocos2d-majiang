--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local ReconnectLayer = class("ReconnectLayer", cc.Layer)

local List = require("core.List")

local _reconns = {} --{[ServerName] = layer, ...}
local _reconnsQue = {} --{[ServerName] = {{time = ?}, ...}, ...}

local MAX_RECONN_TIMES = 3
local EXCEP_TIME_SPACE = 10 --单位：秒

--新重连引用计数
--超过次数返回false
local function newReconnCount(reconnServerName)
    _reconnsQue[reconnServerName] = _reconnsQue[reconnServerName] or List()
    local que = _reconnsQue[reconnServerName]
    local nowTime = os.time()
    que:pushBack({time = nowTime})
    if que:getCnt() >= MAX_RECONN_TIMES then 
        local ele = que:popFront()
        if nowTime - ele.time <= EXCEP_TIME_SPACE then 
            return false
        end 
    end 
    return true
end 

function ReconnectLayer.reconn(reconnServerName)
    if _reconns[reconnServerName] then 
        return 
    end 
    if not newReconnCount(reconnServerName) then 
        local function okCallback()
            cc.Director:getInstance():endToLua() 
            PlatformHelper:exitGame()
        end 
        UIManager:showMsgBox({
            msg = "重连次数过于频繁，请检查网络或账号是否异常",
            ok = true,
            okCallback = okCallback,
            disableCancel = true,
        })
        return
    end 
    local layer = ReconnectLayer:create({reconnServerName = reconnServerName}):addTo(cc.Director:getInstance():getRunningScene())
    _reconns[reconnServerName] = layer
end 

function ReconnectLayer:ctor(params)
    if not params or not params.reconnServerName then 
        assert(false)
    end 
    self.reconnServerName = params.reconnServerName
    self.timer = nil

    local uiNode = require("public.ReconnectLayer"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)
    
    self:enableNodeEvents()
    
    local act = cc.RepeatForever:create(cc.Sequence:create(cc.RotateBy:create(1, 360, 360)))
    self.panRoot.spLoading:runAction(act)

    self:on_reconn_timer()
end 

function ReconnectLayer:onEnter()
    UIManager:showTip("与服务器失去连接，正在重连...")
    
    if self.reconnServerName == Define.SERVER_HOME then 
        Event.register("HOME_LOGON_MS_LOGONRES", self, "HOME_LOGON_MS_LOGONRES")
        Event.register("HOME_LOGON_FINISH", self, "HOME_LOGON_FINISH")
        Event.register("MS_DISCONNECT_HOME", self, "MS_DISCONNECT_HOME")
    elseif self.reconnServerName == Define.SERVER_GAME then 
        Event.register("GAME_LOGON_MS_LOGONRES", self, "GAME_LOGON_MS_LOGONRES")
        Event.register("GAME_LOGON_MS_FINISH", self, "GAME_LOGON_MS_FINISH")
        Event.register("MS_ROOM_INFO", self, "MS_ROOM_INFO")
        Event.register("MS_GAME_SCENE_FREE", self, "MS_GAME_SCENE_FREE")
        Event.register("MS_GAME_SCENE_PLAY", self, "MS_GAME_SCENE_PLAY")
        Event.register("MS_DISCONNECT_GAME", self, "MS_DISCONNECT_GAME")
    else 
        assert(false)
    end 
end

function ReconnectLayer:onExit()
    if self.timer then 
        self.timer:stop()
    end 
    
    if self.reconnServerName == Define.SERVER_HOME then 
        Event.unregister("HOME_LOGON_MS_LOGONRES", self, "HOME_LOGON_MS_LOGONRES")
        Event.unregister("HOME_LOGON_FINISH", self, "HOME_LOGON_FINISH")
        Event.unregister("MS_DISCONNECT_HOME", self, "MS_DISCONNECT_HOME")
    elseif self.reconnServerName == Define.SERVER_GAME then 
        Event.unregister("GAME_LOGON_MS_LOGONRES", self, "GAME_LOGON_MS_LOGONRES")
        Event.unregister("GAME_LOGON_MS_FINISH", self, "GAME_LOGON_MS_FINISH")
        Event.unregister("MS_ROOM_INFO", self, "MS_ROOM_INFO")
        Event.unregister("MS_GAME_SCENE_FREE", self, "MS_GAME_SCENE_FREE")
        Event.unregister("MS_GAME_SCENE_PLAY", self, "MS_GAME_SCENE_PLAY")
        Event.unregister("MS_DISCONNECT_GAME", self, "MS_DISCONNECT_GAME")
    else 
        assert(false)
    end 

    _reconns[self.reconnServerName] = nil
end 

function ReconnectLayer:on_tick()
--    self.panRoot.lblTickCnt:setString(tostring(self.timer.remainTime))
end 

function ReconnectLayer:retry()
    if self.timer and self.timer.remainTime > 0 then 
        return
    end 
    if self.timer then 
        self.timer:stop()
    end 
    if not newReconnCount(self.reconnServerName) then 
        local function okCallback()
            cc.Director:getInstance():endToLua() 
            PlatformHelper:exitGame()
        end 
        UIManager:showMsgBox({
            msg = "重连次数过于频繁，请检查网络或账号是否异常",
            ok = true,
            okCallback = okCallback,
            disableCancel = true,
        })
        return
    end 

    UIManager:showTip("与服务器失去连接，正在重连...")
--    self.panRoot.lblDesc:setString("重连失败，5s后将重试。。。")
    self.timer = Timer:create(5, self, "on_reconn_timer", "on_tick")
    self.timer:start()
--    self.panRoot.lblTickCnt:setVisible(true)
end

function ReconnectLayer:on_reconn_timer()
    local succ = false
    if self.reconnServerName == Define.SERVER_HOME then 
        succ = LoginCache:loginHome(LoginCache.loginID,LoginCache.loginPwd)
    elseif self.reconnServerName == Define.SERVER_GAME then 
        succ = HomeCache:loginGame()
    else 
        assert(false)
    end 
    if not succ then 
        self:removeFromParent()
    end 
end

function ReconnectLayer:MS_DISCONNECT_HOME(data)
    self:retry()
end 

function ReconnectLayer:MS_DISCONNECT_GAME(data)
    self:retry()
end 

function ReconnectLayer:HOME_LOGON_MS_LOGONRES(data)
    if data.err and data.err > 0 then 
        Helper.showError(data.err)
        self:retry()
        return
    end 
end 

function ReconnectLayer:HOME_LOGON_FINISH(data)
    self:removeFromParent()
    UIManager:unblock()
end 

function ReconnectLayer:GAME_LOGON_MS_LOGONRES(data)
    if data.err and data.err > 0 then 
        Helper.showError(data.err)
        self:retry()
        return
    end 
end 

function ReconnectLayer:GAME_LOGON_MS_FINISH(data)
    if HomeCache.roomID > 0 then 
        --DO NOTHING
    else
        self:removeFromParent()
        HomeCache:disconnGame()
        UIManager:unblock()
        UIManager:replaceCurrent(Define.SCENE_HOME, "app.modules.home.HomeLayer", UIManager.UITYPE_FULL_SCREEN)
        UIManager:showTip("房间不存在或已解散")
    end 
end 

function ReconnectLayer:MS_ROOM_INFO(data)
    if data and data.err and data.err ~= 0 then 
        Helper.showError(data.err)
        HomeCache:disconnGame()
        UIManager:unblock()
        UIManager:goBack(Define.SCENE_HOME, "app.modules.home.HomeLayer", UIManager.UITYPE_FULL_SCREEN)
    else
        UIManager:showTip("进入房间成功")
        Network:send(Define.SERVER_GAME, "mc_gamescene_load_finish",nil)
    end
end 

function ReconnectLayer:MS_GAME_SCENE_FREE(data)
    self:removeFromParent()
    UIManager:unblock()
end 

function ReconnectLayer:MS_GAME_SCENE_PLAY(data)
    self:removeFromParent()
    UIManager:unblock()
end 

return ReconnectLayer
--endregion
