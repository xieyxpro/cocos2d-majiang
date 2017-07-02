--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local PlatformHelper = {}

local LuaBridge
local className
local platform = device.platform

if platform == "android" then
	LuaBridge = require "cocos.cocos2d.luaj"
    className = "com/jzsf/hgmj/Helper"
elseif platform == "ios" then
	LuaBridge = require "cocos.cocos2d.luaoc"
    className = "Helper"
end


function PlatformHelper:InstallApk(apkPath)
    if platform == "android" then
        local sig = "(Ljava/lang/String;)V"
        local ok,ret = LuaBridge.callStaticMethod(className,"InstallApk",{apkPath},sig)
        return ret
    end 
end

function PlatformHelper:exitGame()    
    if platform == "android" then
        local sig = "()V"
        local ok,ret = LuaBridge.callStaticMethod(className,"exitGame",{},sig)
        return ret
    elseif "ios" == platform then        
        local ok,ret = LuaBridge.callStaticMethod(className,"exitGame",{})
        return ret
    end 
end

return PlatformHelper

--endregion
