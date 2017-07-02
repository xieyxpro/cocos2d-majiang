--region *.lua
--Date
--此文件由[BabeLua]插件自动生成


--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local FeedbackActionLayer = class("FeedbackActionLayer", cc.Layer)

function FeedbackActionLayer:ctor(params)
    local uiNode = require("HomeScene.feedBack.FeedbackActionLayer"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)
    util.bindUITouchEvents(self.panRoot, self)
        
    Event.register(EventDefine.FEEDBACK_UPLOAD_FINISH, self, "FEEDBACK_UPLOAD_FINISH")
end

function FeedbackActionLayer:onClose()
    Event.unregister(EventDefine.FEEDBACK_UPLOAD_FINISH, self, "FEEDBACK_UPLOAD_FINISH")
end

function FeedbackActionLayer:FEEDBACK_UPLOAD_FINISH(data)
    if data.success then       
        UIManager:showTip("提交成功")
    else        
        UIManager:showTip("反馈提交失败")
    end
end

function FeedbackActionLayer:onClick_btnBack(touch, eventTouch)
    UIManager:goBack()
end

function FeedbackActionLayer:onClick_btnTijiao(touch, eventTouch)
    local iphoneNumber = self.imgBg.Image_11.TextIphone:getString()
    local textOpinion = self.imgBg.Image_12.TextFieldOpinion:getString()

    if not string.match(iphoneNumber,"[1][3,4,5,7,8]%d%d%d%d%d%d%d%d%d") then
        UIManager:showTip("请输入正确的手机号码")
    elseif textOpinion == "" or tostring(textOpinion) == nil then
        UIManager:showTip("输入内容不能为空")
    else
        GameApiSDK:feedBackReq(PlayerCache.userid,iphoneNumber,textOpinion)
    end
end

return FeedbackActionLayer
--endregion

