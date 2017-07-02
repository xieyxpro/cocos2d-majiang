--region SceneExt.lua
--Author : Administrator
--Date   : 2014-10-11
--此文件由[BabeLua]插件自动生成

local c = cc
local Scene = c.Scene

local ArmaturePool = require("app.frameworkExt.cocos2dx.ArmaturePool")

Scene.RES_TYPE = {
    IMG = 1,
    ARMATURE = 2,
}

function Scene:setAutoCleanupEnabled()
    self:addNodeEventListener(c.NODE_EVENT, function(event)
        if event.name == "exit" then
            if self.autoCleanupRes_ then
                if self.autoCleanupRes_[Scene.RES_TYPE.IMG] then
                    for k,v in pairs(self.autoCleanupRes_[Scene.RES_TYPE.IMG]) do
                        display.removeSpriteFrameByImageName(tostring(v))
                        printInfo("setAutoCleanupEnabled img: %s", tostring(v))
                        self.autoCleanupRes_[Scene.RES_TYPE.IMG][v] = nil
                    end
                end

                -- 移除动画 self:markAutoCleanupRes(cc.Scene.RES_TYPE.ARMATURE, "niutouren_101307")
                if self.autoCleanupRes_[Scene.RES_TYPE.ARMATURE] then
                    for k,v in pairs(self.autoCleanupRes_[Scene.RES_TYPE.ARMATURE]) do
                        if not ArmaturePool.release(v) then
                            Armature.removeRes(tostring(v))
                            printInfo("setAutoCleanupEnabled armtaure: %s", tostring(v))
                            self.autoCleanupRes_[Scene.RES_TYPE.ARMATURE][v] = nil
                        end
                    end
                end
                printInfo(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
            end
        end
    end)
end

function Scene:markAutoCleanupRes(resType, resName)
    if not self.autoCleanupRes_ then self.autoCleanupRes_ = {} end
    if not self.autoCleanupRes_[resType] then self.autoCleanupRes_[resType] = {} end

    -- 不重复添加
    if table.nums(self.autoCleanupRes_[resType]) > 0 then
        if self.autoCleanupRes_[resType][resName] then return self end
    end

    table.insert(self.autoCleanupRes_[resType], resName)
    return self
end

function Scene:getFromArmatureRes(resName)
    if self.autoCleanupRes_ and self.autoCleanupRes_[Scene.RES_TYPE.ARMATURE] then
        return self.autoCleanupRes_[Scene.RES_TYPE.ARMATURE][resName]
    end
    return
end

--endregion
