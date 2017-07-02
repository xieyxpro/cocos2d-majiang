--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local FeedbackLayer = class("FeedbackLayer", cc.Layer)



function FeedbackLayer:ctor(params)
    --获取文件添加
    local uiNode = require("HomeScene.feedBack.FeedbackLayer"):create().root:addTo(self)
    --绑定
    util.bindUINodes(uiNode, self, self)
    --绑定触摸监听
    util.bindUITouchEvents(self.panRoot, self)
    
    
    Event.register(EventDefine.LOG_UPLOAD_FINISH, self, "LOG_UPLOAD_FINISH")
end

function FeedbackLayer:onClose()
    Event.unregister(EventDefine.LOG_UPLOAD_FINISH, self, "LOG_UPLOAD_FINISH")
end


function FeedbackLayer:LOG_UPLOAD_FINISH(data)
    UIManager:unblock()
    if data.success then 
        UIManager:showTip("提交成功")
    else 
        UIManager:showTip("日志提交失败")
    end 
end 

function FeedbackLayer:onClick_btnTijiao(touch, eventTouch)
    UIManager:block()
    utillog:checkUploadLog()
end

function FeedbackLayer:onClick_btnFeedback(touch, eventTouch)
    UIManager:goTo(Define.SCENE_HOME, "app.modules.feedback.FeedbackActionLayer", UIManager.UITYPE_PROMPT)
end

function FeedbackLayer:onClick_btnBack(touch, eventTouch)
    UIManager:goBack()
end


return FeedbackLayer
--endregion