--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local util = {}

function util.setGlobal(name, value)
    cc.exports[name] = value
end 

function util.convertIPV4ToStr(intStrValue)
    return SharedUtil.convertIPV4ToStr(intStrValue)
end

function util.bindUINodes(node, bindTo, eventProcessor)
    local children = node:getChildren()
    for _, child in pairs(children) do 
        local name = child:getName()
        bindTo[name] = child
        util.bindUINodes(child, bindTo[name], eventProcessor)
        if tolua.type(child) == "ccui.Button" then 
            child:addTouchEventListener(function(target, event)
                if event == ccui.TouchEventType.began then 
                    target:setScale(0.9)
                elseif event == ccui.TouchEventType.ended or
                       event == ccui.TouchEventType.canceled then 
                    target:setScale(1.0)
                end 
                if eventProcessor and event == ccui.TouchEventType.ended and eventProcessor["onClick_"..name] then 
                    eventProcessor["onClick_"..name](eventProcessor, target)
                end 
            end)
        elseif tolua.type(child) == "ccui.Slider" then
            child:addEventListener(function(target, event)
                if eventProcessor and eventProcessor["onValueChanged_"..name] then 
                    eventProcessor["onValueChanged_"..name](eventProcessor, target)
                end
            end)
        elseif tolua.type(child) == "ccui.CheckBox" then
            child:addEventListener(function(target, eventType)
                if eventProcessor and eventProcessor["onChecked_"..name] then 
                    eventProcessor["onChecked_"..name](eventProcessor, target, eventType == ccui.CheckBoxEventType.selected)
                end
            end)
        end 
    end 
end 

function util.bindUITouchEvents(uiNode, eventProcessor)
    local nodeType = tolua.type(uiNode)
    if string.sub(nodeType, 1, 4) ~= "ccui"  then 
        log_err("bindTouch target is untouchable")
        return
    end 
    local name = uiNode:getName()
    uiNode:addTouchEventListener(function(sender, event)
        if event == ccui.TouchEventType.began then 
            if eventProcessor and eventProcessor["onTouchBegan_"..name] then
                local pos = sender:getTouchBeganPosition()
                eventProcessor["onTouchBegan_"..name](eventProcessor, sender, pos)
            end
        elseif event == ccui.TouchEventType.moved then 
            if eventProcessor and eventProcessor["onTouchMoved_"..name] then
                local pos = sender:getTouchMovePosition()
                eventProcessor["onTouchMoved_"..name](eventProcessor, sender, pos)
            end
        elseif event == ccui.TouchEventType.ended then 
            if eventProcessor and eventProcessor["onTouchEnded_"..name] then
                local pos = sender:getTouchEndPosition()
                eventProcessor["onTouchEnded_"..name](eventProcessor, sender, pos)
            end
        elseif event == ccui.TouchEventType.canceled then 
            if eventProcessor and eventProcessor["onTouchCanceled_"..name] then
                eventProcessor["onTouchCanceled_"..name](eventProcessor, sender)
            end
        end 
    end)
end 

--listen touch events by layer
--if this method used, any touch events except someone wallowed it will
--dispatch to the listen layer
function util.addLayerTouchEvents(node, eventProcessor)
    markTag = markTag or ""
    local nodeType = tolua.type(node)
    if nodeType ~= "cc.Layer"  then 
        log_err("touch target is not a layer")
        return
    end 
    local eventDispatcher = node:getEventDispatcher() 
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function(touch, eventTouch)
        if eventProcessor["onTouchBegan"] then 
            eventProcessor:onTouchBegan(touch, eventTouch)
        end 
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(touch, eventTouch)
        if eventProcessor["onTouchMoved"] then 
            eventProcessor:onTouchMoved(touch, eventTouch)
        end 
        return true
    end,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(function(touch, eventTouch)
        if eventProcessor["onTouchEnded"] then 
            eventProcessor:onTouchEnded(touch, eventTouch)
        end 
        return true
    end,cc.Handler.EVENT_TOUCH_ENDED )

    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
end 

function util.setLayerToCenter(layer)
    assert(layer)
    layer:ignoreAnchorPointForPosition(false)
    layer:setAnchorPoint(cc.p(0.5, 0.5))
    layer:setPosition(cc.p(display.cx, display.cy))
end

return util
--endregion
