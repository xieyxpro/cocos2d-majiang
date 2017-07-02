--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local BlockLayer = class("BlockLayer", cc.Layer)

local _instance = nil 
local _delayDspTime = 5

function BlockLayer.show(delayDspTime)
    if _instance then 
        return 
    end 
    _delayDspTime = delayDspTime or 5
    _instance = BlockLayer:create():addTo(UIManager:getCurrentScene() or cc.Director:getInstance():getRunningScene())
end 

function BlockLayer.close()
    if not _instance then 
        return 
    end 
    _instance:removeFromParent()
    _instance = nil

end 

function BlockLayer:ctor()
    _instance = self

    local uiNode = require("public.BlockLayer"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)
    
    self:enableNodeEvents()

    self.panRoot.spLoading:setVisible(false)
    
    self.timer = Timer:create(_delayDspTime, self, "on_timer", nil)
    self.timer:start()
end 

function BlockLayer:onExit()
    self.timer:stop()
    _instance = nil
end 

function BlockLayer:on_timer()
    local act = cc.RepeatForever:create(cc.Sequence:create(cc.RotateBy:create(1, 360, 360)))
    self.panRoot.spLoading:setVisible(true)
    self.panRoot.spLoading:runAction(act)
end 

return BlockLayer
--endregion
