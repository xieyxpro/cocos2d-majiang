--region *.lua
--Date
--高德地图定位sdk

local LuaBridge
local className
local AMAP_KEY
local platform = device.platform

if platform == "android" then
	LuaBridge = require "cocos.cocos2d.luaj"
    className = "com/jzsf/hgmj/AmapLocationUtil"
    AMAP_KEY = "a3fc9dd49fd68ea18bb1f8cdc73f70ac"
elseif platform == "ios" then
	LuaBridge = require "cocos.cocos2d.luaoc"
    className = "AmapLocationUtil"
    AMAP_KEY = "5c465d9bcf552503006a5ff054e3186d"
end


local AmapSDK = {
    bFirstTime = true,
    bLocating = false,
}

local function AmapLocationCallback(strRes)
    AmapSDK:StopLocation()
    if strRes == "SUCCESS" then
        if AmapSDK.bFirstTime then--首次定位完成后执行一次高精度定位
            AmapSDK.bFirstTime = false
            AmapSDK:ConfigLocationOption(true,true)
            AmapSDK:StartLocation()
        end
        PlayerCache.city = AmapSDK:getStringAttrib("getCity")
        PlayerCache.district = AmapSDK:getStringAttrib("getDistrict")
        PlayerCache.address = AmapSDK:getStringAttrib("getAddress")
        PlayerCache.jingdu = AmapSDK:getJingdu()
        PlayerCache.weidu = AmapSDK:getWeidu()
        printInfo("AmapLocationCallback SUCCESS " .. PlayerCache.jingdu .. ":" .. PlayerCache.weidu)
        Event.dispatch(EventDefine.AMAP_LOCATION_CALLBACK,{res = true})
    else
        PlayerCache.permissiondenied = AmapSDK:isPermissionDenied()
        if not PlayerCache.permissiondenied then
            printError("AmapLocationCallBack " +  strRes)
        else
            Event.dispatch(EventDefine.AMAP_LOCATION_CALLBACK,{res = false})
        end
    end
end

function AmapSDK:Init()
    if platform == "ios" then
        local ok,ret = LuaBridge.callStaticMethod(className,"Init",{key=AMAP_KEY,luaFunctionId=AmapLocationCallback})
        return ret        
    elseif platform == "android" then
        local sig = "(I)V"
        local ok,ret = LuaBridge.callStaticMethod(className,"Init",{AmapLocationCallback},sig)
        return ret
    end
end
--[[
	/***
	 * android
	 * @param high_accuracy 是否选择高精度定位(高精度定位速度慢需要30秒)
	 * @param gps 设置首次定位是否等待GPS定位结果	默认值：false 
	 * @param timeOut 单位是毫秒，默认30000毫秒，建议超时时间不要低于8000毫秒。
	 * @param interval 设置定位间隔,单位毫秒,默认为2000ms，最低1000ms。
	 * @param address 设置是否返回地址信息（默认返回地址信息）
	 * @param onceLocation 获取一次定位结果
	 * @param latest 获取最近3s内精度最高的一次定位结果
	 * @param cache 关闭缓存机制,默认开启
	 */
     high_accuracy==true 时候 gps无效；high_accuracy==false and gps==true时候等于high_accuracy=true
     --]]
     --[[
     ios
     distanceFilter 最小更新距离，小于此值的时候回调一次
     --]]
function AmapSDK:ConfigLocationOption(high_accuracy,gps)
    if platform == "ios" then
        local onceLocation,timeOut,distanceFilter = true,10,200
        local args = {onceLocation=onceLocation,high_accuracy=high_accuracy,timeOut=timeOut,distanceFilter=distanceFilter}
        local ok,ret = LuaBridge.callStaticMethod(className,"ConfigLocationOption",args)
        return ret
    elseif platform == "android" then
        local timeOut,interval,address,onceLocation,latest,cache = 30000,2000,true,true,true,false
        local sig = "(ZZIIZZZZ)V"
        local ok,ret = LuaBridge.callStaticMethod(className,"ConfigLocationOption",{high_accuracy,gps,timeOut,interval,address,onceLocation,latest,cache},sig)
        return ret
    end 
end

function AmapSDK:StartLocation()
    assert(not self.bLocating, "AmapSDK:StartLocation Error Locating")
    if platform == "ios" then
        local ok,ret = LuaBridge.callStaticMethod(className,"StartLocation")
        return ret
    elseif platform == "android" then
        local ok,ret = LuaBridge.callStaticMethod(className,"StartLocation")
        return ret
    end 
    self.bLocating = true
end

function AmapSDK:StopLocation()
    self.bLocating = false
    if platform == "ios" then
        local ok,ret = LuaBridge.callStaticMethod(className,"StopLocation")
    elseif platform == "android" then
        local ok,ret = LuaBridge.callStaticMethod(className,"StopLocation")
    end 
end

--region getter
function AmapSDK:getWeidu()
    if platform == "ios" then
        local ok,ret = LuaBridge.callStaticMethod(className,"getLatitude")
        return tonumber(ret)
    elseif platform == "android" then
        local sig = "()Ljava/lang/String;"
        local ok,ret = LuaBridge.callStaticMethod(className,"getLatitude",{},sig)
        return tonumber(ret)
    end 
end
function AmapSDK:getJingdu()
    if platform == "ios" then
        local ok,ret = LuaBridge.callStaticMethod(className,"getLongitude")
        return tonumber(ret)

    elseif platform == "android" then
        local sig = "()Ljava/lang/String;"
        local ok,ret = LuaBridge.callStaticMethod(className,"getLongitude",{},sig)
        return tonumber(ret)
    end 
end
function AmapSDK:getStringAttrib(method)    
    if platform == "ios" then
        local ok,ret = LuaBridge.callStaticMethod(className,method)
        return ret
        
    elseif platform == "android" then
        local sig = "()Ljava/lang/String;"
        local ok,ret = LuaBridge.callStaticMethod(className,method,{},sig)
        return ret
    end
end
function AmapSDK:isPermissionDenied()
    if platform == "ios" then
        local ok,ret = LuaBridge.callStaticMethod(className,"isPermissionDenied")
        return ret
    elseif platform == "android" then
        local sig = "()Z"
        local ok,ret = LuaBridge.callStaticMethod(className,"isPermissionDenied",{},sig)
        return ret
    end
end

function AmapSDK:calculateLineDistance(jingdu1,weidu1,jingdu2,weidu2)
    local longitude1 = tonumber(jingdu1);
	local latitude1 = tonumber(weidu1);
	local longitude2 = tonumber(jingdu2);
	local latitude2 = tonumber(weidu2);
	
	longitude1 = longitude1 * 0.01745329251994329
	latitude1 = latitude1 * 0.01745329251994329
	longitude2 = longitude2 * 0.01745329251994329
	latitude2 = latitude2 * 0.01745329251994329
	local d6 = math.sin(longitude1);
	local d7 = math.sin(latitude1);
	local d8 = math.cos(longitude1);
	local d9 = math.cos(latitude1);
	local d10 = math.sin(longitude2);
	local d11 = math.sin(latitude2);
	local d12 = math.cos(longitude2);
	local d13 = math.cos(latitude2);
    local arrayOfDouble1 = {}
	local arrayOfDouble2 = {}
	arrayOfDouble1[0] = (d9 * d8);
	arrayOfDouble1[1] = (d9 * d6);
	arrayOfDouble1[2] = d7;
	arrayOfDouble2[0] = (d13 * d12);
	arrayOfDouble2[1] = (d13 * d10);
	arrayOfDouble2[2] = d11;
	local d14 = math.sqrt((arrayOfDouble1[0] - arrayOfDouble2[0]) * (arrayOfDouble1[0] - arrayOfDouble2[0]) + (arrayOfDouble1[1] - arrayOfDouble2[1]) * (arrayOfDouble1[1] - arrayOfDouble2[1]) + (arrayOfDouble1[2] - arrayOfDouble2[2]) * (arrayOfDouble1[2] - arrayOfDouble2[2]));
	    
	return math.asin(d14 / 2.0) * 1.27420015798544E7
end
--endregion

AmapSDK:Init()

return AmapSDK
--endregion
