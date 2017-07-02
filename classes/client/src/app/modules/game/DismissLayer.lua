--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local DismissLayer = class("DismissLayer", cc.Layer)

local GameDefine = require("app.modules.game.GameDefine")

local _instance = nil

function DismissLayer.show()
    if _instance then 
        _instance:refresh()
        return 
    end 
    _instance = DismissLayer:create()
                        :addTo(UIManager:getCurrentScene())
end 

function DismissLayer.close()
    if not _instance then 
        return 
    end 
    _instance:removeFromParent()
    _instance = nil
end 

function DismissLayer:ctor()
    local uiNode = require("GameScene.DismissLayer"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)

    self.imgBg.panItem:setVisible(false)
    self.imgBg.txtTimeRemain.rawText = self.imgBg.txtTimeRemain:getString()

    self.players = {}
    self.timer = nil
    self.remainTime = 0

    self:refresh()
    
    self:enableNodeEvents()
end 

function DismissLayer:onExit()
    if self.timer then 
        self.timer:stop()
    end 
    _instance = nil
end 

function DismissLayer:on_timer()
    --DO NOTHING
end 

function DismissLayer:on_tick()
    self.imgBg.txtTimeRemain:setText(string.format(self.imgBg.txtTimeRemain.rawText, self.timer.remainTime))
end

function DismissLayer:refresh()
    for _, player in pairs(GameCache.players) do 
        if not self.players[player.userid] then 
            local item = self.imgBg.panItem:clone()
            item:setVisible(true)
            util.bindUINodes(item, item, nil)
            item.txtName:setText(player.nickname)
            if player.userid == GameCache.dismiss.calleruserid then 
                item.priority = 1
                item.txtStatus:setText("解散发起人")
            else 
                item.priority = 2
                item.txtStatus:setText("处理中")
            end 
            item:addTo(self.imgBg.panList)
            self.players[player.userid] = item
        end 
    end 
    WidgetExt.panLayoutVertical(self.imgBg.panList, {
                lines = 1,
                needSort = true,
                autoHeight = false,})
    local foundMyself = false
    if GameCache.dismiss.calleruserid == PlayerCache.userid then 
        foundMyself = true
    end 
    for _, userid in pairs(GameCache.dismiss.agreeuserids) do 
        local item = self.players[userid]
        item.txtStatus:setText("已同意")
        if userid == PlayerCache.userid then 
            foundMyself = true
        end 
    end 
    if foundMyself then 
        self.imgBg.btnAgree:setVisible(false)
        self.imgBg.btnReject:setVisible(false)
    else
        self.imgBg.btnAgree:setVisible(true)
        self.imgBg.btnReject:setVisible(true)
    end 
    self.remainTime = math.floor(GameCache.dismiss.lefttime / 1000)
    if self.timer then 
        self.timer:stop()
    end 
    self.timer = Timer:create(self.remainTime, self, "on_timer", "on_tick")
    self.timer:start()
end 

function DismissLayer:onClick_btnAgree(sender)
    Network:send(Define.SERVER_GAME, "mc_dismiss", {agree = true})
    self.imgBg.btnAgree:setVisible(false)
    self.imgBg.btnReject:setVisible(false)
end 

function DismissLayer:onClick_btnReject(sender)
    Network:send(Define.SERVER_GAME, "mc_dismiss", {agree = false})
    self.imgBg.btnAgree:setVisible(false)
    self.imgBg.btnReject:setVisible(false)
end 

return DismissLayer
--endregion
