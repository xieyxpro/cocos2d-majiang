--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local LuaBridge
local className
local platform = device.platform

if platform == "android" then
	LuaBridge = require "cocos.cocos2d.luaj"
    className = "com/jzsf/hgmj/WXUtil";
elseif platform == "ios" then
	LuaBridge = require "cocos.cocos2d.luaoc"
    className = "WXUtil"
end

require("cocos.cocos2d.json");

local WECHAT_APPID = "wx4f403da0489bced2"
local WEB_API_KEY = Define.WEB_API_KEY

local URL_ACCESS_TOKEN = Define.DATA_SERVER.."/jzhgmjApi/wechat_logon_code.php"
local URL_REFRESH_GAMETOKEN = Define.DATA_SERVER.."/jzhgmjApi/wechat_logon_refrestoken.php"

local URL_PAY_UNIFIED_ORDER = Define.DATA_SERVER.."/jzhgmjApi/pay/wechat_pay_unifiedorder.php"--统一下单
local URL_PAY_ORDER_QUERY = Define.DATA_SERVER.."/jzhgmjApi/pay/wechat_pay_orderquery.php"--查询订单状态


local URL_REFRESH_TOKEN = "https://api.weixin.qq.com/sns/oauth2/refresh_token"

local WechatSDK = {
    SCENE_SESSION = 1,--分享到回话
    SCENE_TIMELINE = 2,--分享到朋友圈
    SCENE_FAVORITE = 3,--添加到微信收藏

    AUTH_ERR = {
        RELOGIN = 1,
        HTTP_ERROR = 2,
        USER_CANCLE = 3,
        OTHER_ERR = 4,
    },
    AUTH_ERR_MSG={
        HTTP_ERROR = "请检查您的手机网络",
        REAUTHON = "授权期限已过，正在重新登录",
        OTHER_ERR = "连接服务器失败",
    },

    PAY_ERR = {
        UNIFIED_ORDER_ERROR = 1,
        HTTP_ERROR = 2,
        USER_CANCLE = 3,
        OTHER_ERR = 4,
    },
    PAY_ERR_MSG={
        HTTP_ERROR = "请检查您的手机网络",
        UNIFIED_ORDER_ERROR = "下单失败",
        OTHER_ERR = "连接服务器失败",        
    },
}

function WechatSDK:registerwx()
    if platform == "android" then
        local ok,ret = LuaBridge.callStaticMethod(className,"registerwx",{WECHAT_APPID})
        return ret
    elseif platform == "ios" then    
        local ok,ret = LuaBridge.callStaticMethod(className,"registerwx",{appid=WECHAT_APPID})
        return ret
    end
end

--region logon
local gotoLogon = function (openid,gametoken)
    Event.dispatch(EventDefine.WECHAT_AUTH_RES,{openid=openid,gametoken=gametoken})    
end
function WechatSDK:requestGamePwd(openid,access_token)
    local httpreq = cc.XMLHttpRequest:new()
    httpreq.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    local timestamp = os.time()
    local signStr = string.format("openid=%s&access_token=%s&timestamp=%d&key=%s",openid,access_token,timestamp,WEB_API_KEY);
    local sign = utilfile.getDataMD5(string.lower(signStr),signStr:len());
    local url = string.format("%s?openid=%s&access_token=%s&timestamp=%d&sign=%s", URL_REFRESH_GAMETOKEN,openid,access_token,timestamp,sign)
    httpreq:open("GET",url)

    local function onReadyStateChange()
        if httpreq.status ~= 200 then --http error
            Event.dispatch(EventDefine.WECHAT_AUTH_RES,{err=WechatSDK.AUTH_ERR.HTTP_ERROR,msg=WechatSDK.AUTH_ERR_MSG.HTTP_ERROR})
            return
        end
        local tbRes = json.decode(httpreq.response)
        if nil ~= tbRes.errcode and tbRes.errcode ~= 0 then
            printError("requestGamePwd Error:%d-%s",tbRes["errcode"],tbRes["errmsg"])
            self:eraseWechatAccount()
            Event.dispatch(EventDefine.WECHAT_AUTH_RES,{err=WechatSDK.AUTH_ERR.OTHER_ERR,msg=WechatSDK.AUTH_ERR_MSG.OTHER_ERR,data=tbRes})
            return
        end
        
        return gotoLogon(openid,tbRes["token"])
    end

    httpreq:registerScriptHandler(onReadyStateChange)
    httpreq:send()    
end
function WechatSDK:wxAuthAccessToken(code)
    local httpreq = cc.XMLHttpRequest:new()
    httpreq.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    local timestamp = os.time()
    local signStr = string.format("code=%s&timestamp=%d&key=%s",code,timestamp,WEB_API_KEY);
    local sign = utilfile.getDataMD5(string.lower(signStr),signStr:len());
    local url = string.format("%s?code=%s&timestamp=%d&sign=%s&channelId=%s", URL_ACCESS_TOKEN,code,timestamp,sign,Launcher.channel)
    httpreq:open("GET",url)

    local function onReadyStateChange()
        if httpreq.status ~= 200 then --http error
            Event.dispatch(EventDefine.WECHAT_AUTH_RES,{err=WechatSDK.AUTH_ERR.HTTP_ERROR,msg=WechatSDK.AUTH_ERR_MSG.HTTP_ERROR})
            return
        end
        local tbRes = json.decode(httpreq.response)
        table.tostring(tbRes)
        if nil ~= tbRes.errcode and tbRes.errcode ~= 0 then
            printError("wxAuthAccessToken Error:%d-%s",tbRes["errcode"],tbRes["errmsg"])
            Event.dispatch(EventDefine.WECHAT_AUTH_RES,{err=WechatSDK.AUTH_ERR.OTHER_ERR,msg=WechatSDK.AUTH_ERR_MSG.OTHER_ERR,data=tbRes})            
            return
        end
        
        UserDefaultExt:set("wx_openid",tbRes["openid"])
        UserDefaultExt:set("wx_access_token",tbRes["access_token"])
        UserDefaultExt:set("wx_access_token_expires",tbRes["expires_in"] + os.time())
        UserDefaultExt:set("wx_refresh_token",tbRes["refresh_token"])
        return gotoLogon(tbRes["openid"],tbRes["token"])
    end

    httpreq:registerScriptHandler(onReadyStateChange)
    httpreq:send()
end
function WechatSDK:wxRefreshToken(refresh_token)    
    local refreshhttpreq = cc.XMLHttpRequest:new()
    refreshhttpreq.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    local url = string.format("%s?appid=%s&grant_type=refresh_token&refresh_token=%s",
        URL_REFRESH_TOKEN,WECHAT_APPID,refresh_token)
    refreshhttpreq:open("GET",url)

    local function onReadyStateChange()
        if refreshhttpreq.status ~= 200 then --http error
            Event.dispatch(EventDefine.WECHAT_AUTH_RES,{err=WechatSDK.AUTH_ERR.HTTP_ERROR,msg=WechatSDK.AUTH_ERR_MSG.HTTP_ERROR})
            return
        end
        local tbRes = json.decode(refreshhttpreq.response)
        table.tostring(tbRes)
        if nil ~= tbRes.errcode then
            printError("wxRefreshToken Error:%d-%s",tbRes["errcode"],tbRes["errmsg"])
            --需要重新拉起微信授权
            self:eraseWechatAccount()
            Event.dispatch(EventDefine.WECHAT_AUTH_RES,{err=WechatSDK.AUTH_ERR.RELOGIN,msg=WechatSDK.AUTH_ERR_MSG.REAUTHON})
            return 
        end
        UserDefaultExt:set("wx_openid",tbRes["openid"])
        UserDefaultExt:set("wx_access_token",tbRes["access_token"])
        UserDefaultExt:set("wx_access_token_expires",tbRes["expires_in"] + os.time())
        UserDefaultExt:set("wx_refresh_token",tbRes["refresh_token"])
        return self:requestGamePwd(tbRes["openid"],tbRes["access_token"])
    end

    refreshhttpreq:registerScriptHandler(onReadyStateChange)
    refreshhttpreq:send()
end
function WechatSDK:wxAuthRequest()
    local wxLogonCallBack = function (callbackMsg)
        local tbRes = json.decode(callbackMsg)
        assert(nil ~= tbRes)
        local bRes = tbRes.res
        if bRes then
            Event.dispatch(EventDefine.WECHAT_AUTH_NEED_BLOCK_UI,{})
            local code = tbRes.code;
            self:wxAuthAccessToken(code)
        else
            --用户取消登录授权
            Event.dispatch(EventDefine.WECHAT_AUTH_RES,{err=WechatSDK.AUTH_ERR.USER_CANCLE,msg=""})
        end
    end
    if platform == "android" then
        local ok,ret = LuaBridge.callStaticMethod(className,"wxLogon",{wxLogonCallBack,"call back params"})
        return ret
    elseif platform == "ios" then        
        local ok,ret = LuaBridge.callStaticMethod(className,"wxLogon",{luaFunctionId=wxLogonCallBack,state="call back params"})
        return ret
    end    
end
function WechatSDK:eraseWechatAccount()    
    UserDefaultExt:set("wx_openid","")
    UserDefaultExt:set("wx_access_token","")
    UserDefaultExt:set("wx_access_token_expires",0)
    UserDefaultExt:set("wx_refresh_token","")
end
function WechatSDK:canAutoLogin()
    if "" == UserDefaultExt:get("wx_openid","") then
        return false
    end
    return true
end
function WechatSDK:Logon()
    
    local openid = UserDefaultExt:get("wx_openid","")
    local access_token = UserDefaultExt:get("wx_access_token","");
    local access_token_expires = UserDefaultExt:get("wx_access_token_expires",0)
    local refresh_token = UserDefaultExt:get("wx_refresh_token","");
    if "" == openid then
        return self:wxAuthRequest()--首次登录
    end
    Event.dispatch(EventDefine.WECHAT_AUTH_NEED_BLOCK_UI,{})
    if access_token_expires > (os.time()-60) then
        return self:requestGamePwd(openid,access_token)--access_token有效期内
    end
    return self:wxRefreshToken(refresh_token)--刷新access_token
end
--endregion

--region share
function WechatSDK:shareTextToWX(transaction,scenetype,text)
    if platform == "android" then
        local sig = "(Ljava/lang/String;ILjava/lang/String;)V"
        local ok,ret = LuaBridge.callStaticMethod(className,"shareTextToWX",{transaction,scenetype,text},sig)
        return ret
    elseif platform == "ios" then
        local ok,ret = LuaBridge.callStaticMethod(className,"shareTextToWX",{scenetype=scenetype,text=text})
        return ret
    end
end

function WechatSDK:shareWebpageToWX(transaction,scenetype,url,title,description)
    if platform == "android" then
        local sig = "(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
        local ok,ret = LuaBridge.callStaticMethod(className,"shareWebpageToWX",{transaction,scenetype,url,title,description},sig)
        return ret
    elseif platform == "ios" then
        local ok,ret = LuaBridge.callStaticMethod(className,"shareWebpageToWX",{scenetype=scenetype,url=url,title=title,description=description})
        return ret
    end
end

function WechatSDK:shareImageToWX(transaction, scenetype, imagepath)
    if not cc.FileUtils:getInstance():isFileExist(imagepath) then
        assert(false,"shareImageToWX path:" .. imagepath .. "not exits");
    end
    if platform == "android" then
        local sig = "(Ljava/lang/String;ILjava/lang/String;)V"
        local ok,ret = LuaBridge.callStaticMethod(className,"shareImageToWX",{transaction,scenetype,imagepath},sig)
        return ret
    elseif platform == "ios" then
        local ok,ret = LuaBridge.callStaticMethod(className,"shareImageToWX",{scenetype=scenetype,imagepath=imagepath})
        return ret
    end    
end
--endregion
--region recharge
function WechatSDK:unifiedorder(gameorderid, userid, pay_body, total_fee, callback)
    local httpreq = cc.XMLHttpRequest:new()
    httpreq.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    local timestamp = os.time()
    local signStr = string.format("pay_body=%s&total_fee=%d&userid=%d&timestamp=%d&key=%s",
                            pay_body,total_fee,userid,timestamp,WEB_API_KEY);
    local sign = utilfile.getDataMD5(string.lower(signStr),signStr:len());
    local url = string.format("%s?platform=%s&gameorderid=%s&pay_body=%s&total_fee=%d&userid=%d&callback=%s&timestamp=%d&sign=%s", URL_PAY_UNIFIED_ORDER,
                            platform,gameorderid,string.urlencode(pay_body),total_fee,userid,string.urlencode(callback),timestamp,sign)
    httpreq:open("GET",url)

    local function onReadyStateChange()
        if httpreq.status ~= 200 then --http error
            Event.dispatch(EventDefine.PAY_UNIFIED_ORDER_RES,{err=WechatSDK.PAY_ERR.HTTP_ERROR,msg=WechatSDK.PAY_ERR_MSG.HTTP_ERROR})
            return
        end
        local tbRes = json.decode(httpreq.response)
        table.tostring(tbRes)
        if nil ~= tbRes.errcode and tbRes.errcode ~= 0 then
            printError("unifiedorder Error:%d-%s",tbRes["errcode"],tbRes["errmsg"])
            Event.dispatch(EventDefine.PAY_UNIFIED_ORDER_RES,{err=WechatSDK.PAY_ERR.OTHER_ERR,msg=WechatSDK.PAY_ERR_MSG.OTHER_ERR,data=tbRes})
            return
        end
        Event.dispatch(EventDefine.PAY_UNIFIED_ORDER_RES,{})--下单成功
        local data = tbRes["data"]
        return WechatSDK:wxRecharge(data["appid"],data["partnerid"],data["prepayid"],data["package"],data["noncestr"],data["timestamp"],data["sign"])
    end

    httpreq:registerScriptHandler(onReadyStateChange)
    httpreq:send()    
end
function WechatSDK:orderquery(gameorderid)    
    local httpreq = cc.XMLHttpRequest:new()
    httpreq.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    local timestamp = os.time()
    local signStr = string.format("gameorderid=%s&timestamp=%d&key=%s",gameorderid,timestamp,WEB_API_KEY);
    local sign = utilfile.getDataMD5(string.lower(signStr),signStr:len());
    local url = string.format("%s?gameorderid=%s&timestamp=%d&sign=%s", URL_PAY_ORDER_QUERY,gameorderid,timestamp,sign)
    httpreq:open("GET",url)

    local function onReadyStateChange()
        if httpreq.status ~= 200 then --http error
            printError("%s%s","query order http error",gameorderid)
            return
        end
        local tbRes = json.decode(httpreq.response)
        table.tostring(tbRes)
        if nil ~= tbRes.errcode and tbRes.errcode ~= 0 then
            printError("orderquery orderid:%s Error:%d-%s",gameorderid,tbRes["errcode"],tbRes["errmsg"])
            return
        end
    end

    httpreq:registerScriptHandler(onReadyStateChange)
    httpreq:send()    
end
function WechatSDK:wxRecharge(appid,partnerid,prepayid,package,noncestr,timestamp,sign)    
    local wxRechargeCallBack = function (callbackMsg)
        local tbRes = json.decode(callbackMsg)
        assert(nil ~= tbRes)
        local bRes = tbRes.res
        if bRes then
            Event.dispatch(EventDefine.PAY_WECHAT_PAY_RES,{})--付款成功
        else
            Event.dispatch(EventDefine.PAY_WECHAT_PAY_RES,{err=WechatSDK.PAY_ERR.USER_CANCLE,msg=""})
        end
    end

    if platform == "android" then
        local sig = "(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
        local ok,ret = LuaBridge.callStaticMethod(className,"wxRecharge",{wxRechargeCallBack,appid,partnerid,prepayid,package,noncestr,timestamp,sign},sig)
        return ret
    elseif platform == "ios" then
        local ok,ret = LuaBridge.callStaticMethod(className,"wxRecharge",{luaFunctionId=wxRechargeCallBack,
                            partnerid=partnerid,prepayid=prepayid,packageValue=package,noncestr=noncestr,timestamp=timestamp,sign=sign})
        return ret
    end   
end
--[[
    gameorderid String 40 游戏orderid
    userid 充值玩家的ID
    pay_body String(128) 商品描述交易字段格式根据不同的应用场景按照以下格式：APP——需传入应用市场上的APP名字-实际商品名称，天天爱消除-游戏充值。
    total_fee 订单总金额，单位为分
    callback String 256 回调参数-此参数会原封不动返回给服务端
--]]
function WechatSDK:recharge(gameorderid, userid, pay_body, total_fee, callback)
    if platform == "android" or platform == "ios" then
        self:unifiedorder(gameorderid, userid, pay_body, total_fee, callback)
    else
        Event.dispatch(EventDefine.PAY_UNIFIED_ORDER_RES,{err=WechatSDK.PAY_ERR.OTHER_ERR,msg=WechatSDK.PAY_ERR_MSG.OTHER_ERR})
    end
end

--endregion
return WechatSDK


--endregion
