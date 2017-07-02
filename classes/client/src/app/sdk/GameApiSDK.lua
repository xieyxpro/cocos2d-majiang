--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local GameApiSDK = {}

local URL_FEEDBACK = Define.DATA_SERVER .. "/jzhgmjApi/game/feedback.php"
local WEB_API_KEY = Define.WEB_API_KEY

function GameApiSDK:feedBackReq(userid,telphonenum,msg)
    if string.len(msg) > LENGTH_FEED_BACK_MAX then
        printError("feedback request mst too long:" .. msg)
        return false
    end
    
    local httpreq = cc.XMLHttpRequest:new()
    httpreq.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON

    local timestamp = os.time()
    local signStr = string.format("uid=%s&telphonenum=%s&timestamp=%d&key=%s",userid,telphonenum,timestamp,WEB_API_KEY);
    local sign = utilfile.getDataMD5(string.lower(signStr),signStr:len());
    local params = string.format("uid=%s&telphonenum=%s&timestamp=%d&sign=%s&msg=%s",userid,telphonenum,timestamp,sign,msg)

    httpreq:open("POST",URL_FEEDBACK)

    local function onReadyStateChange()
        if httpreq.status ~= 200 then --http error
            Event.dispatch(EventDefine.FEEDBACK_UPLOAD_FINISH,{success = false})
            return
        end
        
        local tbRes = json.decode(httpreq.response)
        if nil ~= tbRes.errcode and tbRes.errcode ~= 0 then
            printError("feedBackReq Error:%d-%s",tbRes["errcode"],tbRes["errmsg"])
            Event.dispatch(EventDefine.FEEDBACK_UPLOAD_FINISH,{success = false})
            return
        end
        
        Event.dispatch(EventDefine.FEEDBACK_UPLOAD_FINISH,{success = true})
    end

    httpreq:registerScriptHandler(onReadyStateChange)
    httpreq:send(params)

    return true
end


return GameApiSDK


--endregion
