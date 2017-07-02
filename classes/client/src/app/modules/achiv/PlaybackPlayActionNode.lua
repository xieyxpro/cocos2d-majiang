--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local PlaybackPlayActionNode = class("PlaybackPlayActionNode", ccui.Layout)

local GameDefine = require("app.modules.game.GameDefine")

PlaybackPlayActionNode.GUO = "guo"
local handImg = "HomeScene/achiv/replayGesture.png"

function PlaybackPlayActionNode:ctor(params)
    local node = require("HomeScene.achiv.PlaybackPlayActionNode"):create().root
                    :addTo(self)
    util.bindUINodes(node, self, self)

    self.actions = {
        [GameDefine.PLAY_ACT_GUO] = {button = self.panRoot.btnGuo, index = 5},
        [GameDefine.PLAY_ACT_CHI] = {button = self.panRoot.btnChi, index = 4},
        [GameDefine.PLAY_ACT_GANG_INITIATIVE] = {button = self.panRoot.btnGang, index = 3},
        [GameDefine.PLAY_ACT_GANG_WATCH] = {button = self.panRoot.btnGang, index = 3},
        [GameDefine.PLAY_ACT_GANG_PLAYBACK] = {button = self.panRoot.btnGang, index = 3},
        [GameDefine.PLAY_ACT_PENG] = {button = self.panRoot.btnPeng, index = 2},
        [GameDefine.PLAY_ACT_HU] = {button = self.panRoot.btnHu, index = 1},
    }
    for _, action in pairs(self.actions) do 
        action.button.priority = action.index
    end 
    self.enabledActions = {}
    self:setScale(0.6)
    self.handSp = nil
    self.actingButton = nil

    self.dir = params.dir
    if self.dir == GameDefine.DIR_BOTTOM then 
        self.panRoot:setAnchorPoint(cc.p(1, 0))
    elseif self.dir == GameDefine.DIR_LEFT then 
        self.panRoot:setAnchorPoint(cc.p(0, 0))
    elseif self.dir == GameDefine.DIR_TOP then 
        self.panRoot:setAnchorPoint(cc.p(0, 1))
    elseif self.dir == GameDefine.DIR_RIGHT then 
        self.panRoot:setAnchorPoint(cc.p(1, 1))
    else 
        assert(false)
    end 
end

--[Comment]
--cardVal is not available
function PlaybackPlayActionNode:enableActions(actions, cardVal)
    for _, actionNode in pairs(self.actions) do 
        actionNode.button:setVisible(false)
    end 
    self.enabledActions = {}
    for _, action in pairs(actions) do 
        table.insert(self.enabledActions, action)
        local btn = self.actions[action].button
        btn:setVisible(true)
    end 
--    table.sort(self.enabledActions, function(a, b)
--        return self.actions[a].index < self.actions[b].index
--    end)
--    for i, action in ipairs(self.enabledActions) do 
--        action.button.priority = i
--    end 
    self:refresh()
end 

function PlaybackPlayActionNode:refresh()
    if self.dir == GameDefine.DIR_BOTTOM then 
        WidgetExt.panLayoutVertical(self.panRoot, {
                    needSort = true,
                    lineIntvl = 0,
                    columns = 10, 
                    horizontalMargin = WidgetExt.HorizontalMargin.RIGHT, 
                    reverseLine = false})
    elseif self.dir == GameDefine.DIR_LEFT then 
        WidgetExt.panLayoutVertical(self.panRoot, {
                    needSort = true,
                    lineIntvl = 0,
                    columns = 1, 
                    horizontalMargin = WidgetExt.HorizontalMargin.LEFT, 
                    reverseLine = false})
    elseif self.dir == GameDefine.DIR_TOP then 
        WidgetExt.panLayoutVertical(self.panRoot, {
                    needSort = true,
                    lineIntvl = 0,
                    columns = 10, 
                    horizontalMargin = WidgetExt.HorizontalMargin.LEFT, 
                    reverseCol = true})
    elseif self.dir == GameDefine.DIR_RIGHT then 
        WidgetExt.panLayoutVertical(self.panRoot, {
                    needSort = true,
                    lineIntvl = 0,
                    columns = 1, 
                    horizontalMargin = WidgetExt.HorizontalMargin.RIGHT, 
                    reverseLine = true})
    else 
        assert(false)
    end 
end 

function PlaybackPlayActionNode:doAction(action, callback)
    local action = self.actions[action]
    assert(action)
    local parent = action.button:getParent()
    local sp = cc.Sprite:create(handImg):addTo(parent)
    sp:setAnchorPoint(cc.p(0.5, 1.0))
    local dstPos = cc.p(action.button:getPosition())
    local srcPos = parent:convertToNodeSpace(cc.p(display.cx, display.cy))
    sp:setPosition(srcPos)
    sp:setOpacity(0)
    local handAct = cc.Spawn:create(cc.FadeIn:create(0.3),cc.MoveTo:create(1.0, dstPos))

    local act = cc.Sequence:create(cc.DelayTime:create(1.0),
                                    cc.ScaleTo:create(0.1, 1.1, 1.1, 1.1), 
                                    cc.ScaleTo:create(0.1, 1.0, 1.0, 1.0), 
                                    cc.CallFunc:create(function()
                                        if callback then 
                                            callback()
                                        end 
                                        self.handSp = nil
                                        self.actingButton = nil
                                        sp:removeFromParent()
                                        self:setVisible(false)
                                    end))
    action.button:runAction(act)
    sp:runAction(handAct)

    self.handSp = sp
    self.actingButton = action.button
end 

function PlaybackPlayActionNode:finishAction()
    if self.handSp then 
        self.handSp:stopAllActions()
        self.handSp:removeFromParent()
        self.handSp = nil
    end 
    if self.actingButton then 
        self.actingButton:stopAllActions()
        self.actingButton = nil
    end 
    self:setVisible(false)
end 

return PlaybackPlayActionNode
--endregion
