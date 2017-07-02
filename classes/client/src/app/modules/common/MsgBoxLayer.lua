--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local MsgBoxLayer = class("MsgBoxLayer", cc.Layer)

local GamePlayLayer = require("app.modules.game.GamePlayLayer")
local GameReadyLayer = require("app.modules.game.GameReadyLayer")
local GameDefine = require("app.modules.game.GameDefine")

--[Comment]
--@params:
--        {
--            msg = string,
--            ok = boolean,
--            cancel = boolean,
--            okCallback = function,
--            cancelCallback = function,
--            disableOk = boolean,
--            disableCancel = boolean,
--        }
function MsgBoxLayer:ctor(params)
    local uiNode = require("public.MsgBoxLayer"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)
    
    util.bindUITouchEvents(self.panRoot, self)

    self.msg = params.msg or ""
    self.ok = params.ok or false
    self.cancel = params.cancel or false
    self.okCallback = params.okCallback 
    self.cancelCallback = params.cancelCallback
    self.disableOk = params.disableOk or false
    self.disableCancel = params.disableCancel or false
    
    if not self.ok then 
        self.imgBg.panLayout.btnOk:setVisible(false)
    end 
    if not self.cancel then 
        self.imgBg.panLayout.btnCancel:setVisible(false)
    end 
    
    local columns = 1
    if self.ok and self.cancel then 
        columns = 2
    end 
    WidgetExt.panLayoutVertical(self.imgBg.panLayout, {
                autoHeight = false,
                columnIntvl = 30, 
                columns = columns, 
                needSort = false,
                onlyVisible = true})

    self.imgBg.txtMsg:setText(self.msg)
end 

function MsgBoxLayer:onClick_btnOk(sender)
    if self.disableOk then 
        return
    end 
    Helper.playSoundClick()
    local okCallback = self.okCallback
    self:removeFromParent()
    if okCallback then 
        okCallback()
    end 
end 

function MsgBoxLayer:onClick_btnCancel(sender)
    if self.disableCancel then 
        return
    end 
    Helper.playSoundClick()
    local cancelCallback = self.cancelCallback
    self:removeFromParent()
    if cancelCallback then 
        cancelCallback()
    end 
end 

function MsgBoxLayer:onClick_btnClose(sender)
    if self.disableCancel then 
        return
    end 
    Helper.playSoundClick()
    local cancelCallback = self.cancelCallback
    self:removeFromParent()
    if cancelCallback then 
        cancelCallback()
    end 
end 

function MsgBoxLayer:onTouchEnded_panRoot(touch, eventTouch)
    if self.disableCancel then 
        return
    end 
    local cancelCallback = self.cancelCallback
    self:removeFromParent()
    if cancelCallback then 
        cancelCallback()
    end 
end 

return MsgBoxLayer
--endregion
