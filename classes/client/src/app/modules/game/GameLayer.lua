--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local GameLayer = class("GameLayer", cc.Layer)

local GamePlayLayer = require("app.modules.game.GamePlayLayer")
local GameReadyLayer = require("app.modules.game.GameReadyLayer")
local GameDefine = require("app.modules.game.GameDefine")

function GameLayer:ctor()
    printInfo("GameLayer create")
    local uiNode = require("GameScene.GameLayer"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)

    self.gameReadyLayer = GameReadyLayer:create():addTo(self)
    self.gamePlayLayer = GamePlayLayer:create():addTo(self)
    
    Event.register("MS_CHEATERS_CONFIRM", self, "MS_CHEATERS_CONFIRM")
    Event.register("MS_GAME_OVER", self, "MS_GAME_OVER")
    Event.register("MS_GAME_SCENE_FREE", self, "MS_GAME_SCENE_FREE")
    Event.register("MS_GAME_SCENE_PLAY", self, "MS_GAME_SCENE_PLAY")
    Event.register("MS_DISMISS", self, "MS_DISMISS")
    Event.register("MS_STAND_UP", self, "MS_STAND_UP")
    Event.register("MS_DISMISS_CONFIRM", self, "MS_DISMISS_CONFIRM")
    Event.register("MS_DISMISS_FAIL", self, "MS_DISMISS_FAIL")
end 

function GameLayer:onShow()
    self.gameReadyLayer:initialize()
    if GameCache.roomStatus == GameDefine.enum_GameStatus.GS_PLAYING then 
        self.gamePlayLayer:setVisible(true)
        self.gamePlayLayer:initialize()
    else 
        self.gamePlayLayer:setVisible(false)
    end 
    Helper.playGameBgMusic()
end 

function GameLayer:onClose()
    Event.unregister("MS_CHEATERS_CONFIRM", self, "MS_CHEATERS_CONFIRM")
    Event.unregister("MS_GAME_OVER", self, "MS_GAME_OVER")
    Event.unregister("MS_GAME_SCENE_FREE", self, "MS_GAME_SCENE_FREE")
    Event.unregister("MS_GAME_SCENE_PLAY", self, "MS_GAME_SCENE_PLAY")
    Event.unregister("MS_DISMISS", self, "MS_DISMISS")
    Event.unregister("MS_STAND_UP", self, "MS_STAND_UP")
    Event.unregister("MS_DISMISS_CONFIRM", self, "MS_DISMISS_CONFIRM")
    Event.unregister("MS_DISMISS_FAIL", self, "MS_DISMISS_FAIL")
end 

function GameLayer:MS_GAME_SCENE_FREE(data)
    printInfo("GameLayer:MS_GAME_SCENE_FREE")
    self.gameReadyLayer:initialize()
    self.gamePlayLayer:setVisible(false)
end

function GameLayer:MS_GAME_SCENE_PLAY(data)
    printInfo("GameLayer:MS_GAME_SCENE_PLAY")
    self.gameReadyLayer:initialize()
    self.gamePlayLayer:setVisible(true)
    self.gamePlayLayer:initialize()
end

function GameLayer:MS_GAME_OVER(data)
    if data and data.err ~= 0 then 
        HomeCache:disconnGame()
        local okCallback = function()
            UIManager:goBack(Define.SCENE_HOME, "app.modules.home.HomeLayer", UIManager.UITYPE_FULL_SCREEN)
        end 
        local errMsg = GameDefine.GAME_OVER_ERR[data.err]
        UIManager:showMsgBox({
            msg = errMsg,
            ok = true,
            okCallback = okCallback,
            cancelCallback = okCallback,
        })
        UIManager:unblock()
    end 
end 

function GameLayer:MS_DISMISS(data)
    printInfo("GameLayer:MS_DISMISS")
    HomeCache:disconnGame()
    local okCallback = function()
        if #GameCache.accomplishes.statPlayers > 0 then 
            UIManager:clearAllAndGoTo(Define.SCENE_HOME, "app.modules.home.HomeLayer", UIManager.UITYPE_FULL_SCREEN)
            UIManager:goTo(Define.SCENE_HOME, "app.modules.Statistic.StatisticLayer", UIManager.UITYPE_PROMPT)
        else 
            UIManager:clearAllAndGoTo(Define.SCENE_HOME, "app.modules.home.HomeLayer", UIManager.UITYPE_FULL_SCREEN)
        end 
    end 
    UIManager:showMsgBox({
        msg = "当前组局已被解散",
        ok = true,
        okCallback = okCallback,
        cancelCallback = okCallback,
    })
end 

function GameLayer:MS_STAND_UP(data)
    printInfo("GameLayer:MS_STAND_UP")
    if data.userid ~= PlayerCache.userid then 
        return
    end 
    UIManager:goBack(Define.SCENE_HOME, "app.modules.home.HomeLayer", UIManager.UITYPE_FULL_SCREEN)
    HomeCache:disconnGame()
end 

function GameLayer:MS_DISMISS_CONFIRM(data)
    require("app.modules.game.DismissLayer").show()
end 

function GameLayer:MS_DISMISS_FAIL(data)
    require("app.modules.game.DismissLayer").close()
    local rejecter = GameCache.players[data.notagreeuserid]
    assert(rejecter)
    UIManager:showMsgBox({
        msg = string.format("玩家%s拒绝解散房间", rejecter.nickname),
        ok = true,
    })
end 

function GameLayer:MS_CHEATERS_CONFIRM(data)
    UIManager:show("app.modules.game.CheatNotifyLayer")
end 

return GameLayer
--endregion
