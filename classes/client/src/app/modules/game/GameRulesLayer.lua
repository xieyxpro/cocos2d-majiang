--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local GameRulesLayer = class("GameRulesLayer", cc.Layer)

function GameRulesLayer:ctor(params)
    local uiNode = require("GameScene.GameRulesLayer"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)
    
    self.imgBg.imgRoomRules.txtRolls:setText(string.format("%d局", GameCache.rolls))
    self.imgBg.imgRoomRules.txtFans:setText(string.format("%d番起胡", GameCache.fans))
    if GameCache.options.baoZi then 
        self.imgBg.imgRoomRules.txtOptions:setText("豹子")
    else 
        self.imgBg.imgRoomRules.txtOptions:setText("无豹子")
    end 
    
    self.imgBg.cbRoomRules:setSelectedExt(true)
    self.imgBg.cbCardRules:setSelectedExt(false)

    self.imgBg.imgRoomRules:setVisible(self.imgBg.cbRoomRules:getSelectedExt())
    self.imgBg.imgCardRules:setVisible(self.imgBg.cbCardRules:getSelectedExt())
end 

function GameRulesLayer:onChecked_cbRoomRules(sender, isSelect)
    self.imgBg.cbRoomRules:setSelectedExt(true)
    self.imgBg.cbCardRules:setSelectedExt(false)
    Helper.playSoundSelect()
    self.imgBg.imgRoomRules:setVisible(self.imgBg.cbRoomRules:getSelectedExt())
    self.imgBg.imgCardRules:setVisible(self.imgBg.cbCardRules:getSelectedExt())
end 

function GameRulesLayer:onChecked_cbCardRules(sender, isSelect)
    self.imgBg.cbRoomRules:setSelectedExt(false)
    self.imgBg.cbCardRules:setSelectedExt(true)
    Helper.playSoundSelect()
    self.imgBg.imgRoomRules:setVisible(self.imgBg.cbRoomRules:getSelectedExt())
    self.imgBg.imgCardRules:setVisible(self.imgBg.cbCardRules:getSelectedExt())
end 

function GameRulesLayer:onClick_btnClose(sender)
    Helper.playSoundClick()
    UIManager:goBack()
end 

return GameRulesLayer
--endregion
