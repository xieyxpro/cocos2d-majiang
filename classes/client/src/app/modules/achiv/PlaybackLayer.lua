--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local PlaybackLayer = class("PlaybackLayer", cc.Layer)

local PlaybackPlayLayer = require("app.modules.achiv.PlaybackPlayLayer")
local PlaybackReadyLayer = require("app.modules.achiv.PlaybackReadyLayer")
local GameDefine = require("app.modules.game.GameDefine")

function PlaybackLayer:ctor()
    self.room = AchivCache.curSelectRoom
    --update GameCache
    GameCache.laiZiCardVal = self.room:getCurRollData().laiZiCardVal
    GameCache.laiZiPiCardVal = self.room:getCurRollData().laiZiPiCardVal
    -----------------------------
    local uiNode = require("HomeScene.achiv.PlaybackLayer"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)

    self.gameReadyLayer = PlaybackReadyLayer:create():addTo(self)
    self.gamePlayLayer = PlaybackPlayLayer:create():addTo(self)

    Event.register("MS_GAME_OVER", self, "MS_GAME_OVER")
end 

function PlaybackLayer:onShow()
    self.gameReadyLayer:initialize(self.room)
    self.gamePlayLayer:setVisible(true)
    self.gamePlayLayer:initialize(self.room)
    self.gamePlayLayer:play()
    Helper.playGameBgMusic()
end 

function PlaybackLayer:onClose()
    Event.unregister("MS_GAME_OVER", self, "MS_GAME_OVER")
    Helper.playHomeBgMusic()
end 

return PlaybackLayer
--endregion
