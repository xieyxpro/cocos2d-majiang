--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local HelpLayer = class("HelpLayer", cc.Layer)

local t_defines = require("res.cn.client_config.t_defines")

function HelpLayer:ctor(params)
    local uiNode = require("HomeScene.Help.HelpLayer"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)
    local containerSz = self.imgBg.svContent:getContentSize()

    local richText =  RichTextEx:create(20)
    richText:setContentSize(containerSz.width,0)
    richText:setMultiLineMode(true)

    richText:setVisible(true)
    richText:setText(t_defines.playMethodIntro.value)
    richText:formatText()
    local textSize = richText:getContentSize()
    self.imgBg.svContent:setInnerContainerSize(textSize)
    print("textSize:"..textSize.height)
    richText:setAnchorPoint(cc.p(0, 0))
    richText:setPosition(cc.p(0, 0))
    self.imgBg.svContent:addChild(richText)

end 

function HelpLayer:onClick_btnClose(sender)
    Helper.playSoundClick()
    UIManager:goBack()
end 

function HelpLayer:onTouchEnded_rootPanel(touch, eventTouch)
    UIManager:goBack()
end 

return HelpLayer
--endregion
