--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local LuaBridge
local className
local platform = device.platform

if platform == "android" then
	LuaBridge = require "cocos.cocos2d.luaj"
    className = "com/jzsf/hgmj/PhoneStateUtil"
elseif platform == "ios" then
	LuaBridge = require "cocos.cocos2d.luaoc"
    className = "PhoneStateUtil"
end

require("cocos.cocos2d.json");


local PhoneState = {
    batteryLevel = 100,--[0-100]
    bCharging = false,
    sigLevel = 4,
}

local batteryChanged = function (data)
    local tbData = json.decode(data)
    PhoneState.batteryLevel = tonumber(tbData.level)
    PhoneState.bCharging = tbData.bCharging
    Event.dispatch(EventDefine.PHONE_STATE_BATTERY_CHANGE,{batteryLevel=PhoneState.batteryLevel,bCharging=PhoneState.bCharging})
end

local networkTypeChanged = function (data)
    Event.dispatch(EventDefine.PHONE_STATE_NETWORK_TYPE_CHANGE,{networktype=data})
end;

local sigLevelChanged = function (data)
    PhoneState.sigLevel = tonumber(data)
    Event.dispatch(EventDefine.PHONE_STATE_SIG_CHANGE,{sigLevel=PhoneState.sigLevel})
end

--region init
if platform == "android" then
    local ok,ret = LuaBridge.callStaticMethod(className,"Init",{batteryChanged,networkTypeChanged,sigLevelChanged})
elseif platform == "ios" then
    local ok,ret = LuaBridge.callStaticMethod(className,"Init",{batteryLuaFuncId=batteryChanged,networkTypeChanged=networkTypeChanged,sigLuaFuncId=sigLevelChanged})
end
--endregion

--返回5种值: "WIFI","4G","3G","2G",""
function PhoneState:getNetworkType()
    if platform == "android" then
        local sig = "()Ljava/lang/String;"
        local ok,ret = LuaBridge.callStaticMethod(className,"getNetworkType",{},sig)
        return ret
    elseif platform == "ios" then
        local ok,ret = LuaBridge.callStaticMethod(className,"getNetworkType",{})
        return ret
    else
        return "WIFI"
    end    
end

return PhoneState


--endregion
