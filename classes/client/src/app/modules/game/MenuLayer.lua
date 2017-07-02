--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local MenuLayer = class("MenuLayer", cc.Layer)

local GameDefine = require("app.modules.game.GameDefine")

function MenuLayer:ctor()
    local uiNode = require("GameScene.MenuLayer"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)
    
    util.bindUITouchEvents(self.panRoot, self)
    
    self:enableNodeEvents()

    if GameCache.roomStatus == GameDefine.enum_GameStatus.GS_FREE then 
        if GameCache.rollsCnt > 0 or GameCache.roomCreaterUserID == PlayerCache.userid then 
            self.panMenu.btnDismiss:setVisible(true)
            self.panMenu.btnExit:setVisible(false)
        else 
            self.panMenu.btnDismiss:setVisible(false)
            self.panMenu.btnExit:setVisible(true)
        end 
    elseif GameCache.roomStatus == GameDefine.enum_GameStatus.GS_PLAYING then 
        self.panMenu.btnDismiss:setVisible(true)
        self.panMenu.btnExit:setVisible(false)
    end
--    self.panMenu.rawPos = cc.p(self.panMenu:getPosition())
--    self.panMenu:setPosition(cc.p(self.panMenu.rawPos.x + 400, self.panMenu.rawPos.y))

--    local act = cc.Sequence:create(cc.MoveTo:create(0.3, self.panMenu.rawPos))
--    self.panMenu:runAction(act)
end 

function MenuLayer:onEnter()
    Event.register("MS_STAND_UP", self, "MS_STAND_UP")
    Event.register("MS_DISMISS", self, "MS_DISMISS")
    Event.register("MS_DISMISS_CONFIRM", self, "MS_DISMISS_CONFIRM")
    Event.register("MS_GAME_RECORD", self, "MS_GAME_RECORD")
end

function MenuLayer:onExit()
    Event.unregister("MS_STAND_UP", self, "MS_STAND_UP")
    Event.unregister("MS_DISMISS", self, "MS_DISMISS")
    Event.unregister("MS_DISMISS_CONFIRM", self, "MS_DISMISS_CONFIRM")
    Event.unregister("MS_GAME_RECORD", self, "MS_GAME_RECORD")
end 

function MenuLayer:MS_STAND_UP(data)
    if data.userid ~= PlayerCache.userid then 
        return
    end 
    self:removeFromParent()
end 

function MenuLayer:MS_DISMISS(data)
    UIManager:unblock()
    self:removeFromParent()
end 

function MenuLayer:MS_DISMISS_CONFIRM(data)
    UIManager:unblock()
    self:removeFromParent()
end 

function MenuLayer:MS_GAME_RECORD(data)
    UIManager:unblock()
    if #data < GameCache.people then 
        UIManager:showTip("您还没有完成一局游戏")
    else 
        self:removeFromParent()
        UIManager:goTo(Define.SCENE_GAME, "app.modules.game.GameRecordLayer", UIManager.UITYPE_PROMPT, data)
    end 
end 

function MenuLayer:onClick_btnSettings(sender)
    Helper.playSoundClick()
    self:removeFromParent()
    UIManager:goTo(Define.SCENE_GAME, "app.modules.Settings.SettingsLayer", UIManager.UITYPE_PROMPT)
end 

function MenuLayer:onClick_btnRecord(sender)
    Helper.playSoundClick()
    Network:send(Define.SERVER_GAME, "mc_game_record", {})
    UIManager:block()
end 

function MenuLayer:onClick_btnRules(sender)
    Helper.playSoundClick()
    self:removeFromParent()
    UIManager:goTo(Define.SCENE_GAME, "app.modules.game.GameRulesLayer", UIManager.UITYPE_PROMPT)
end 

function MenuLayer:onClick_btnDismiss(sender)
    Helper.playSoundClick()
    if GameCache.roomStatus == GameDefine.enum_GameStatus.GS_PLAYING then 
        Network:send(Define.SERVER_GAME, "mc_dismiss", {agree = true})
        UIManager:block()
    else
        local function okCallback()
            Network:send(Define.SERVER_GAME, "mc_dismiss", {agree = true})
            UIManager:block()
        end 
        UIManager:showMsgBox({
            msg = "你确定要解散当前组局吗？",
            ok = true,
            cancel = true, 
            okCallback = okCallback,
        })
    end
end 

function MenuLayer:onClick_btnExit(sender)
    Helper.playSoundClick()
    Network:send(Define.SERVER_GAME, "mc_stand_up", nil)
    UIManager:block()
end 

function MenuLayer:onTouchEnded_panRoot(touch, eventTouch)
    self:removeFromParent()
end 

return MenuLayer
--endregion
