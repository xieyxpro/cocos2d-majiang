--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local FreezeLayer = class("FreezeLayer", cc.Layer)

local _instance = nil 

function FreezeLayer.show()
    if _instance then 
        return 
    end 
    _instance = FreezeLayer:create():addTo(cc.Director:getInstance():getRunningScene())
end 

function FreezeLayer.close()
    if not _instance then 
        return 
    end 
    _instance:removeFromParent()
    _instance = nil
end 

function FreezeLayer:ctor()
    _instance = self

    local uiNode = require("public.BlockLayer"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)
    
    self:enableNodeEvents()

    self.panRoot.spLoading:setVisible(false)
end 

function FreezeLayer:onExit()
    _instance = nil
end 

return FreezeLayer
--endregion
