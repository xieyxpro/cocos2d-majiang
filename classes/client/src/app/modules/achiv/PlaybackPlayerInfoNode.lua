--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local PlaybackPlayerInfoNode = class("PlaybackPlayerInfoNode", cc.Node)

local GameDefine = require("app.modules.game.GameDefine")

function PlaybackPlayerInfoNode:ctor(gamePlayer)
    local uiNode = require("HomeScene.achiv.PlaybackPlayerInfoNode"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)

    self.gamePlayer = gamePlayer
    self:refresh()
    
    self:enableNodeEvents()
end 

function PlaybackPlayerInfoNode:onEnter()
end

function PlaybackPlayerInfoNode:onExit()
end

function PlaybackPlayerInfoNode:refresh(gamePlayer)
    self.gamePlayer = gamePlayer or self.gamePlayer
    self.btnHead:loadTextureNormal(self.gamePlayer.playerIcon,0)
    self.btnHead:loadTexturePressed(self.gamePlayer.playerIcon,0)
    self.btnHead.spZhuang:setVisible(self.gamePlayer.isZhuang)
    
    if self.btnHead.lblName:getString() ~= self.gamePlayer.nickname then 
        self.btnHead.lblName:setString(self.gamePlayer.nickname)
    end 
    self:setFans(0)
end 

function PlaybackPlayerInfoNode:setFans(fans)
    self.imgFans.txtFans:setText(string.format("%d番", fans))
end 

function PlaybackPlayerInfoNode:setIcon(iconFileName)
    self.gamePlayer.playerIcon = iconFileName
    self.btnHead:loadTextureNormal(self.gamePlayer.playerIcon,0)
    self.btnHead:loadTexturePressed(self.gamePlayer.playerIcon,0)
end 

return PlaybackPlayerInfoNode
--endregion
