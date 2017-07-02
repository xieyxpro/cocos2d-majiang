 --region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local LoginLayer = class("LoginLayer", cc.Layer)

function LoginLayer:ctor()
    local uiNode = require("LaunchScene.LoginLayer"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)
    
    if Launcher.channel == Launcher.CHANNELS.DEV then 
        if device.platform == "windows" then 
            local id = UserDefaultExt:get("userid", 0)
            self.imgPlayerID.txtPlayerID:setString(tostring(id))
--            self.imgPlayerID.txtPlayerID:setString(tostring(1437))
            UserDefaultExt:set("userid", id)
            self.btnWechatLogin:setVisible(false)
        else 
            local id = UserDefaultExt:get("userid", 1000)
            self.imgPlayerID.txtPlayerID:setString(tostring(id))
        end 
    else 
        if device.platform == "windows" then 
            self.btnWechatLogin:setVisible(false)
        else 
            self.imgPlayerID:setVisible(false)
            self.btnLogin:setVisible(false)
        end 
    end 

    Event.register("HOME_LOGON_MS_LOGONRES", self, "HOME_LOGON_MS_LOGONRES")
    Event.register("HOME_LOGON_FINISH", self, "HOME_LOGON_FINISH")
    
    Event.register("GAME_LOGON_MS_LOGONRES", self, "GAME_LOGON_MS_LOGONRES")
    Event.register("GAME_LOGON_MS_FINISH", self, "GAME_LOGON_MS_FINISH")
    Event.register("MS_JOIN_ROOM", self, "MS_JOIN_ROOM")
    Event.register("MS_ROOM_INFO", self, "MS_ROOM_INFO")
    Event.register("MS_GAME_SCENE_FREE", self, "MS_GAME_SCENE_FREE")
    Event.register("MS_GAME_SCENE_PLAY", self, "MS_GAME_SCENE_PLAY")

    Event.register(EventDefine.WECHAT_AUTH_RES,self,"WECHAT_AUTH_RES")
    Event.register(EventDefine.WECHAT_AUTH_NEED_BLOCK_UI,self,"WECHAT_AUTH_NEED_BLOCK_UI")
    
end 

function LoginLayer:onShow()
    if Launcher.channel ~= Launcher.CHANNELS.DEV then 
        if WechatSDK:canAutoLogin() then
            WechatSDK:Logon()
        end
    end 
end

function LoginLayer:on_timer()
    
end 

function LoginLayer:onClose()
    Event.unregister("HOME_LOGON_MS_LOGONRES", self, "HOME_LOGON_MS_LOGONRES")
    Event.unregister("HOME_LOGON_FINISH", self, "HOME_LOGON_FINISH")
    
    Event.unregister("GAME_LOGON_MS_LOGONRES", self, "GAME_LOGON_MS_LOGONRES")
    Event.unregister("GAME_LOGON_MS_FINISH", self, "GAME_LOGON_MS_FINISH")
    Event.unregister("MS_JOIN_ROOM", self, "MS_JOIN_ROOM")
    Event.unregister("MS_ROOM_INFO", self, "MS_ROOM_INFO")
    Event.unregister("MS_GAME_SCENE_FREE", self, "MS_GAME_SCENE_FREE")
    Event.unregister("MS_GAME_SCENE_PLAY", self, "MS_GAME_SCENE_PLAY")
    
    Event.unregister(EventDefine.WECHAT_AUTH_RES,self,"WECHAT_AUTH_RES")
    Event.unregister(EventDefine.WECHAT_AUTH_NEED_BLOCK_UI,self,"WECHAT_AUTH_NEED_BLOCK_UI")
end 

function LoginLayer:onClick_btnLogin(sender)
    local id = self.imgPlayerID.txtPlayerID:getString()
    if id == "" or tonumber(id) == nil then 
        UIManager:showTip("请输入登录ID")
        return
    end 
    LOGIN_USE_WECHAT = false
    LoginCache:loginHome(tonumber(id))
    UIManager:block()
end 

function LoginLayer:onClick_btnWechatLogin(sender)
    LOGIN_USE_WECHAT = true
    WechatSDK:Logon()
end 

function LoginLayer:WECHAT_AUTH_NEED_BLOCK_UI(data)
    UIManager:block(0)
end

function LoginLayer:WECHAT_AUTH_RES(data)
    if nil ~= data.err and data.err ~= 0 then
        if nil ~= data.msg and data.msg ~= "" then
            Helper.showError(data.msg)            
        end
        UIManager:unblock()
        if data.err == WechatSDK.AUTH_ERR.RELOGIN then            
            WechatSDK:Logon()
        end
        return
    end
    LoginCache:loginHome(data.openid,data.gametoken)
end

function LoginLayer:HOME_LOGON_MS_LOGONRES(data)
    if data.err ~= 0 then 
        Helper.showError(data.err)
        UIManager:unblock()
    end 
end

function LoginLayer:HOME_LOGON_FINISH(data) 
    if device.platform ~= "windows" and Launcher.channel == Launcher.CHANNELS.DEV then 
        --保存登录的ID
        UserDefaultExt:set("userid", PlayerCache.userid)
    end
    if HomeCache.reconnGameServer then 
        --connect to room
        HomeCache:loginGame()
    else 
        UIManager:unblock()
        UIManager:replaceCurrent(Define.SCENE_HOME, "app.modules.home.HomeLayer", UIManager.UITYPE_FULL_SCREEN)
    end 
end


function LoginLayer:GAME_LOGON_MS_LOGONRES(data)
    if data.err and data.err ~= 0 then 
        Helper.showError(data.err)
        UIManager:unblock()

        HomeCache:disconnGame()
        UIManager:replaceCurrent(Define.SCENE_HOME, "app.modules.home.HomeLayer", UIManager.UITYPE_FULL_SCREEN)
    else
    end 
end 

function LoginLayer:GAME_LOGON_MS_FINISH(data)
    if HomeCache.roomID <= 0 then 
        HomeCache:disconnGame()
        UIManager:unblock()
        UIManager:replaceCurrent(Define.SCENE_HOME, "app.modules.home.HomeLayer", UIManager.UITYPE_FULL_SCREEN)
    end 
end

function LoginLayer:MS_ROOM_INFO(data)
    if data and data.err and data.err ~= 0 then 
        Helper.showError(data.err)
        HomeCache:disconnGame()
        UIManager:unblock()
        UIManager:replaceCurrent(Define.SCENE_HOME, "app.modules.home.HomeLayer", UIManager.UITYPE_FULL_SCREEN)
    else
        UIManager:showTip("进入房间成功")
        Network:send(Define.SERVER_GAME, "mc_gamescene_load_finish",nil)
    end
end 

function LoginLayer:MS_GAME_SCENE_FREE(data)
    UIManager:replaceCurrent(Define.SCENE_GAME, "app.modules.game.GameLayer", UIManager.UITYPE_FULL_SCREEN)
    UIManager:unblock()
end 

function LoginLayer:MS_GAME_SCENE_PLAY(data)
    UIManager:replaceCurrent(Define.SCENE_GAME, "app.modules.game.GameLayer", UIManager.UITYPE_FULL_SCREEN)
    UIManager:unblock()
end 

return LoginLayer
--endregion
