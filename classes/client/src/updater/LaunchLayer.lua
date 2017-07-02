local Updater = require("updater.Updater")
local Launcher = require("updater.Launcher")

local LaunchLayer = class("LaunchLayer", cc.Layer)

function LaunchLayer:ctor()
    local uiNode = require("LaunchScene.LaunchLayer"):create().root:addTo(self)
    
    uiNode:setCascadeOpacityEnabled(true)
    uiNode:setOpacity(0)
    
    --start updater
    if HOT_UPDATE_ENABLED then 
        Updater.getInstance():start()
    end

    local act = cc.Sequence:create(
        cc.FadeIn:create(0.5), 
        cc.DelayTime:create(1.0), 
        cc.FadeOut:create(0.5),
        cc.CallFunc:create(function()
            self:removeFromParent()
            if not HOT_UPDATE_ENABLED then 
                local updater = Updater.getInstance()
                updater.err.code = 0
                updater.status = Launcher.UPDATE_STATUS.DONE
            end 
            require("updater.UpdateLayer"):create():addTo(cc.Director:getInstance():getRunningScene())
        end)
    )
    uiNode:runAction(act)
end

return LaunchLayer
