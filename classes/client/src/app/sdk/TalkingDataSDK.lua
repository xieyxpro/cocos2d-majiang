--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local platform = device.platform

local TalkingDataSDK = {
    
}

if ("ios" == platform or "android" == platform) and TALKING_DATA_ENABLE then
    Event.register("HOME_LOGON_MS_LOGONRES", TalkingDataSDK, "HOME_LOGON_MS_LOGONRES")
    Event.register(EventDefine.AMAP_LOCATION_CALLBACK,TalkingDataSDK,"amap_location_callback")
end

function TalkingDataSDK:onStart(appkey,channelid)
    if ("ios" == platform or "android" == platform) and TALKING_DATA_ENABLE then
        --TalkingDataSDK:setVerboseLogDisabled()
        TalkingDataGA:onStart(appkey,channelid)
    end
end

function TalkingDataSDK:HOME_LOGON_MS_LOGONRES(data)
    if ("ios" == platform or "android" == platform) and TALKING_DATA_ENABLE then
        if 0 == data.err then
            TDGAAccount:setAccount(data.userid)
            TDGAAccount:setAccountName(data.nickname)
            TDGAAccount:setAccountType(kAccountRegistered)
            if 1 == data.gender then
                TDGAAccount:setGender(kGenderMale)
            else
                TDGAAccount:setGender(kGenderFemale)
            end
        end
    end
end

function TalkingDataSDK:amap_location_callback(data)
    if ("ios" == platform or "android" == platform) and TALKING_DATA_ENABLE then
        if data.res then
            TalkingDataGA:setLocation(PlayerCache.jingdu,PlayerCache.weidu)
        end
    end
end

--[[
    data = {
        orderId char    订单ID，自行构造，最多64 个字符。
        iapId char      充值包ID，最多32 个字符。例如：VIP3 礼包、500 元10000 宝石包
        currencyAmount double   现金金额或现金等价物的额度
        --currencyType char       请使用国际标准组织ISO 4217 中规范的3 位字母代码标记货币类型,例：人民币CNY；美元USD；欧元EUR
        virtualCurrencyAmount double    虚拟币金额
        paymentType char    支付的途径，最多16 个字符。例如：“支付宝”“苹果官方”"AliPay"
    }
--]]
function TalkingDataSDK:onChargeRequest(data)
    if ("ios" == platform or "android" == platform) and TALKING_DATA_ENABLE then
        TDGAVirtualCurrency:onChargeRequest(data.orderId,data.iapId,data.currencyAmount,"CNY",data.virtualCurrencyAmount,data.paymentType)
    end
end

function TalkingDataSDK:onChargeSuccess(orderId)
    if ("ios" == platform or "android" == platform) and TALKING_DATA_ENABLE then
        TDGAVirtualCurrency:onChargeSuccess(orderId)
    end
end

--[[
    item                    某个消费点的编号，最多32 个字符。
    itemNumber              消费数量
    priceInVirtualCurrency  虚拟币单价
--]]
function TalkingDataSDK:purchase(item,itemNumber,priceInVirtualCurrency)
    if ("ios" == platform or "android" == platform) and TALKING_DATA_ENABLE then
        TDGAItem:onPurchase(item,itemNumber,priceInVirtualCurrency)
    end    
end

return TalkingDataSDK

--endregion
