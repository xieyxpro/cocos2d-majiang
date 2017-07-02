--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local GameTipNode = class("GameTipNode", cc.Node)

local GameDefine = require("app.modules.game.GameDefine")

function GameTipNode:ctor()
    local uiNode = require("GameScene.GameTipNode"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)
    
    self:enableNodeEvents()

    self.rawDesc = self.lblDesc:getString()
    self.timer = nil
    self.act = nil
    self.mode = GameDefine.GAME_MODE.GAME 

    self:updateModeStatus()
    
end 

function GameTipNode:setMode(mode)
    self.mode = mode 
    self:updateModeStatus()
end 

function GameTipNode:updateModeStatus()
    if self.mode == GameDefine.GAME_MODE.GAME then 
        self.lblDesc:setVisible(true)
    else 
        self.lblDesc:setVisible(false)
    end 
end 

function GameTipNode:onExit()
    if self.timer then 
        self.timer:stop()
    end 
end 

function GameTipNode:newTimer(timeSeconds)
    if self.timer ~= nil then 
        self.timer:stop()
    end 
    if self.act then
       self.imgDir:stopAction(self.act) 
       self.imgDir:setColor(cc.c4b(255, 255, 255, 255))
       self.act = nil
    end 
    self.timer = Timer:create(timeSeconds, self, "on_timer", "on_tick")
    self.timer:start()
end 

function GameTipNode:setProgress(progress)
    self.cardsRemainCnt = progress.cardsRemainCnt
    self.rollsCnt = progress.rollsCnt
    self.totalRolls = progress.totalRolls
    self.lblDesc:setString(string.format(self.rawDesc, self.cardsRemainCnt, self.rollsCnt, self.totalRolls))
end 

function GameTipNode:setDir(dir)
    local act = nil 
    if dir == GameDefine.DIR_LEFT then 
        act = cc.Sequence:create(
                    cc.RotateTo:create(0.1, 90, 90))
    elseif dir == GameDefine.DIR_BOTTOM then 
        act = cc.Sequence:create(
                    cc.RotateTo:create(0.1, 0, 0))
    elseif dir == GameDefine.DIR_RIGHT then 
        act = cc.Sequence:create(
                    cc.RotateTo:create(0.1, 270, 270))
    elseif dir == GameDefine.DIR_TOP then 
        act = cc.Sequence:create(
                    cc.RotateTo:create(0.1, 180, 180))
    else
        error("invalid direction")
    end
    self.imgDir:stopAllActions()
    self.imgDir:runAction(act)
end 

function GameTipNode:on_tick()
    self.lblTime:setString(string.format("%02d", self.timer.remainTime))
end 

function GameTipNode:on_timer()
    --TODO start warnning animation
--    self.timer = nil
    self.lblTime:setString(string.format("%02d", self.timer.remainTime))
    self.act = cc.RepeatForever:create(
                    cc.Sequence:create(
                        cc.TintTo:create(1, 255, 0, 0),
                        cc.TintTo:create(1, 255, 255, 255)))
    self.imgDir:runAction(self.act)
end 

return GameTipNode
--endregion
