
local SampleLayer = class("SampleLayer", cc.Layer)

function SampleLayer:ctor()
    ui.SampleLayer:create().root:addTo(self)
    self:enableNodeEvents()
    self:setTouchEnabled(true)
    util.bindTouchEvents(self, self)

    Event.register("load_finished", self, "on_load_finished")
end

--for Slider
function LoginLayer:onValueChanged_sldrVolume(target, event)
        print(target:getPercent())
end 

--for Layer Touch
function SampleLayer:onTouchBegan(touch, eventTouch)
    print(cc.Director:getInstance():getRunningScene())
    return true
end 

--for Node Event
function SampleLayer:onEnter()
    print("onEnter")
end

--for Node Event
function SampleLayer:onExit()
    print("onexit")
end 

--for Layer Touch
function SampleLayer:onTouchEnded(touch, eventTouch)
    print("BBBBBB")
    Event.dispatch("load_finished")
    return true
end 

function SampleLayer:on_load_finished(arg)
    UIManager:goTo(nil, "app.modules.login.LoginLayer", UIManager.UITYPE_FULL_SCREEN)
end 

--for UIManager
function SampleLayer:onClose()
    Event.unregister("load_finished", self, "on_load_finished")
end 

return SampleLayer
