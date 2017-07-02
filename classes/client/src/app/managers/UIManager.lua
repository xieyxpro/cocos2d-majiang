--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local UIManager = class("UIManager")

function UIManager:ctor()
    self.UITYPE_FULL_SCREEN = 1
    self.UITYPE_PROMPT = 2

    self._uiStack = {}
    self.blockLayer = nil 
end

function UIManager:registerSceneNode(sceneName, nodeRequire)
    
end 

function UIManager:clear()
    self._uiStack = {}
end 

function UIManager:getCurrentScene()
    local scene = nil
    if table.maxn(self._uiStack) > 0 then
        local nodeTbl = self._uiStack[table.maxn(self._uiStack)]
        return nodeTbl.scene
    else 
        return nil
    end 
end 

function UIManager:reset()
    local i = table.maxn(self._uiStack)
    while i > 0 do 
        local nodeTbl = self._uiStack[i]
        if nodeTbl.node then 
            if nodeTbl.node.onClose then 
                nodeTbl.node:onClose()
            end 
            nodeTbl.node:removeFromParent()
            nodeTbl.node = nil
        end
        self._uiStack[i] = nil
        i = i - 1
    end 
end 

function UIManager:clearAllAndGoTo(sceneName, uilayerRequireName, uiType, params, closePrevious)
    for _, ui in ipairs(self._uiStack) do 
        if ui.node then 
            ui.node:onClose()
            ui.node:removeFromParent()
        end 
    end 
    self._uiStack = {}
    self:goTo(sceneName, uilayerRequireName, uiType, params, closePrevious)
end 

function UIManager:goTo(sceneName, uilayerRequireName, uiType, params, closePrevious)
    if uiType == self.UITYPE_FULL_SCREEN then 
        closePrevious = closePrevious == nil and true or closePrevious
    elseif uiType == self.UITYPE_PROMPT then  
        closePrevious = closePrevious or false
    end 
    if not uilayerRequireName then 
        printError("go to ui require name reuqired")
        return
    end 
    if not uiType then
        printError("go to uiType required")
        return
    end 
    if uiType ~= self.UITYPE_FULL_SCREEN and
       uiType ~= self.UITYPE_PROMPT then
        printError("invalid uiType: %d", tostring(uiType))
        return
    end 
    if uiType == self.UITYPE_PROMPT then --prompt use current scene 
        assert(table.maxn(self._uiStack) > 0)
        sceneName = self._uiStack[table.maxn(self._uiStack)].sceneName
    end 
    local scene = nil
    if table.maxn(self._uiStack) > 0 then
        local nodeTbl = self._uiStack[table.maxn(self._uiStack)]
        if not sceneName then 
            sceneName = nodeTbl.sceneName
        end 
        if nodeTbl.sceneName ~= sceneName then 
            scene = display.newScene(sceneName)
            cc.Director:getInstance():replaceScene(scene)
        else
            scene = nodeTbl.scene
        end 
    else 
        scene = display.newScene(sceneName)
        if cc.Director:getInstance():getRunningScene() ~= nil then 
            cc.Director:getInstance():replaceScene(scene)
        else 
            cc.Director:getInstance():runWithScene(scene)
        end 
    end 
    if closePrevious then 
        local i = table.maxn(self._uiStack)
        while i > 0 do 
            local nodeTbl = self._uiStack[i]
            if nodeTbl.node then 
                if nodeTbl.node.onClose then 
                    nodeTbl.node:onClose()
                end 
                nodeTbl.node:removeFromParent()
                nodeTbl.node = nil
            else 
                break
            end
            i = i - 1
        end 
    end 
    local layer = self:__createLayer(uilayerRequireName, params)
    if not layer then
        return
    end 
    assert(scene)
--    if not scene then 
--        scene = cc.Director:getInstance():getRunningScene()
--    end 
    scene:addChild(layer)

    table.insert(self._uiStack, {
        requireName = uilayerRequireName, 
        node = layer, 
        uiType = uiType, 
        sceneName = sceneName, 
        scene = scene
    })

    if layer.onShow then
        layer:onShow()
    end 
end

function UIManager:__createLayer(uilayerRequireName, params)
    local layerClass = require(uilayerRequireName)
    if not layerClass then 
        printError("require %s failed", uilayerRequireName)
        return
    end 
    local layer = layerClass:create(params)
    if not layer then
        printError("layer %s create failed", uilayerRequireName)
        return
    end 
    return layer
end 

function UIManager:goBack(sceneName, uilayerRequireName, uiType, params)
    if table.maxn(self._uiStack) <= 1 then
        self:replaceCurrent(sceneName, uilayerRequireName, uiType)
        return
    end
    local topNode = self._uiStack[table.maxn(self._uiStack)]
    local layer = topNode.node
    if layer and layer.onClose then
        layer:onClose()
    end 
    layer:removeFromParent()
    self._uiStack[table.maxn(self._uiStack)] = nil

    local secondTop = self._uiStack[table.maxn(self._uiStack)]

    local scene = nil 
    if secondTop.sceneName ~= topNode.sceneName then 
        scene = display.newScene(secondTop.sceneName)
        cc.Director:getInstance():replaceScene(scene)
        --更新之前的scen引用
        local i = table.maxn(self._uiStack)
        while i > 0 do 
            local ele = self._uiStack[i]
            if ele.sceneName == secondTop.sceneName then 
                ele.scene = scene
            else 
                break 
            end 
            i = i - 1
        end 
    else
        scene = topNode.scene
    end 

    if topNode.uiType == self.UITYPE_FULL_SCREEN then 
        if not secondTop.node then 
            local secondLayer = self:__createLayer(secondTop.requireName, params)
            if not secondLayer then 
                printError("goback failed")
                return
            end 
            scene:addChild(secondLayer)
            secondTop.node = secondLayer
            if secondLayer.onShow then 
                secondLayer:onShow()
            end 
        end 
    elseif topNode.uiType == self.UITYPE_PROMPT then 
        --DO NOTHING
    end

end

function UIManager:showTip(text)
    local scene 
    local topNode = self._uiStack[table.maxn(self._uiStack)]
    if topNode then 
        scene = topNode.scene
    else
        scene = cc.Director:getInstance():getRunningScene()
    end 
    if not scene then 
        return 
    end 
    local tipNode = require("public.TipTextNode"):create().root
                        :addTo(scene)
                        :setPosition(cc.p(display.cx, display.cy))
    tipNode:setCascadeColorEnabled(true)
    tipNode:setCascadeOpacityEnabled(true)
    tipNode:setLocalZOrder(WidgetExt.MaxZOrder)
    util.bindUINodes(tipNode, tipNode, tipNode)
    tipNode.lblTip:setString(text)
    local act = cc.Spawn:create(cc.Sequence:create(
                                    cc.MoveTo:create(1.5, cc.p(display.cx, display.cy + 150)),
                                    cc.CallFunc:create(function()
                                        tipNode:removeFromParent()
                                    end)),
                                cc.Sequence:create( 
                                    cc.DelayTime:create(0.5),
                                    cc.FadeOut:create(1)))
    tipNode:runAction(act)
end 

function UIManager:replaceCurrent(sceneName, uilayerRequireName, uiType, params)
    if table.maxn(self._uiStack) < 1 then
        self:goTo(sceneName, uilayerRequireName, uiType)
        return
    end
    if not uilayerRequireName then 
        printError("go to ui require name reuqired")
        return
    end 
    if not uiType then
        printError("go to uiType required")
        return
    end 
    if uiType ~= self.UITYPE_FULL_SCREEN and
       uiType ~= self.UITYPE_PROMPT then
        log_errf("invalid uiType: %d", tostring(uiType))
        return
    end 
    local scene = nil

    local nodeTbl = self._uiStack[table.maxn(self._uiStack)]
    if nodeTbl.node.onClose then 
        nodeTbl.node:onClose()
    end 
    nodeTbl.node:removeFromParent()
    nodeTbl.node = nil
    self._uiStack[table.maxn(self._uiStack)] = nil

    local layer = self:__createLayer(uilayerRequireName, params)
    if not layer then
        return
    end 

    if nodeTbl.sceneName ~= sceneName then 
        scene = display.newScene(sceneName)
        cc.Director:getInstance():replaceScene(scene)
    else
        scene = nodeTbl.scene
    end 
    scene:addChild(layer)
    if layer.onShow then
        layer:onShow()
    end 
    table.insert(self._uiStack, {
        requireName = uilayerRequireName, 
        node = layer, 
        uiType = uiType, 
        sceneName = sceneName, 
        scene = scene
    })
end 

function UIManager:show(uilayerRequireName, params)
    local scene = self:getCurrentScene()
    if not scene then 
        return 
    end 
    local layer = self:__createLayer(uilayerRequireName, params)
    if not layer then
        return
    end 
    if layer.onShow then
        layer:onShow()
    end 
    scene:addChild(layer)
    return layer
end 

function UIManager:close(node)
    if node.onClose then
        node:onClose()
    end 
    node:removeFromParent()
end 

--[Comment]
--block the whole ui, any operations on UI will be denied
function UIManager:block(delayDspTime)
    require("app.modules.common.BlockLayer").show(delayDspTime)
end 

--[Comment]
--block the blocked ui
function UIManager:unblock()
    require("app.modules.common.BlockLayer").close()
end 

--[Comment]
--freeze the whole ui, any operations on UI will be denied
function UIManager:freeze()
    require("app.modules.common.FreezeLayer").show()
end 

--[Comment]
--unfreeze the blocked ui
function UIManager:unfreeze()
    require("app.modules.common.FreezeLayer").close()
end 

function UIManager:showMsgBox(params)
    require("app.modules.common.MsgBoxLayer")
                        :create(params)
                        :addTo(cc.Director:getInstance():getRunningScene())
end 

return UIManager
--endregion
