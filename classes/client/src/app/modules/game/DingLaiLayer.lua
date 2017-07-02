--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local DingLaiLayer = class("DingLaiLayer", cc.Layer)

function DingLaiLayer:ctor(params)
    self.cardVal = params.cardVal 
    self.callback = params.callback

    local uiNode = require("GameScene.DingLaiLayer"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)

    local imgPath = Helper.getCardImgPathOfFlatBottom(self.cardVal)
    self.nodeRoot.imgCard:loadTexture(imgPath)
    
    local function showEft()
        local act = cc.Spawn:create(
            cc.RotateBy:create(1.0, -30, -30)
        )
        self.nodeRoot.img1:runAction(act)
        local act2 = cc.Spawn:create(
            cc.Sequence:create(
                cc.ScaleTo:create(0.1, 1.1, 1.1, 1),
                cc.ScaleTo:create(0.1, 1.0, 1.0, 1)
            ),
            cc.Sequence:create(
                cc.DelayTime:create(1.0),
                cc.FadeOut:create(0.3)
            )
        )
        self.nodeRoot.img2:runAction(act2)
        local act3 = cc.Spawn:create(
            cc.Sequence:create(
                cc.ScaleTo:create(0.1, 1.1, 1.1, 1),
                cc.ScaleTo:create(0.1, 1.0, 1.0, 1)
            ),
            cc.Sequence:create(
                cc.DelayTime:create(1.0),
                cc.FadeOut:create(0.3),
                cc.CallFunc:create(function()
                    if self.callback then 
                        self.callback()
                    end 
                    self:removeFromParent()
                end)
            )
        )
        self.nodeRoot.imgCard:runAction(act3)
    end 
    showEft()
end 

return DingLaiLayer
--endregion
