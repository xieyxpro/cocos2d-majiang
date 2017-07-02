--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local RealNameLayer = class("RealNameLayer", cc.Layer)

function RealNameLayer:ctor(params)
    local uiNode = require("HomeScene.realName.RealNameLayer"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)

    util.bindUITouchEvents(self.panRoot, self)
end 


function RealNameLayer:onClick_btnValidate(sender)
    Helper.playSoundClick()
    local name = self.imgBg.imgNameBg.txtName:getString()
    local id = self.imgBg.imgIDBg.txtID:getString()
	if string.match(name,"[\128-\254]+") ~= name then
		UIManager:showTip("姓名输入有误，请重新输入！")
		return
	end
    if not Helper.validateID(id) then 
		UIManager:showTip("身份证输入有误，请重新输入！")
		return
    end 
    PlayerCache:realNameValidate(true)
    UIManager:showTip("实名认证成功")
    UIManager:goBack()
    Event.dispatch("REAL_NAME_VALIDATE", true)
end 

function RealNameLayer:onClick_btnClose(sender)
    Helper.playSoundClick()
    UIManager:goBack()
end 

function RealNameLayer:onTouchEnded_panRoot(touch, eventTouch)
    UIManager:goBack()
end 

return RealNameLayer
--endregion
