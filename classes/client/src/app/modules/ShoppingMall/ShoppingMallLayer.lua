--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local t_shop_items = require("res.cn.client_config.t_shop_items")
local ShoppingMallLayer = class("ShoppingMallLayer", cc.Layer)

function ShoppingMallLayer:ctor(params)
    local uiNode = require("HomeScene.ShoppingMall.ShoppingMallLayer"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)
    util.bindUITouchEvents(self.panRoot, self)
    self.imgBg.imgContentBg.ButtonItem:setVisible(false)
    Event.register(EventDefine.PAY_WECHAT_PAY_RES, self, "PAY_WECHAT_PAY_RES")
    Event.register(EventDefine.PAY_UNIFIED_ORDER_RES, self, "PAY_UNIFIED_ORDER_RES")  
    
    --TODO
    self.agentID = 0  
end

function ShoppingMallLayer:onShow()
    --判断该玩家ID是否绑定推广员,若有，那么不提示下面的窗口
    self.imgBg.ImgId:setVisible(self.agentID == 0)
    local function addShopItem(cfgItem)
        local tmpItem = self.imgBg.imgContentBg.ButtonItem:clone()
        util.bindUINodes(tmpItem, tmpItem, self)
        tmpItem.RoomName:setText(cfgItem["name"])
        tmpItem.TextMoney:setText(cfgItem["moneydisplay"])
        tmpItem.imgIcon:loadTexture(cfgItem["icon"])
        tmpItem.priority = cfgItem["id"]
        tmpItem:addTo(self.imgBg.imgContentBg.svContent)
        local function onClick(sender)
            UIManager:block()
            local orderID = string.format("%d%s%d", PlayerCache.userid, device.platform, os.time())
            WechatSDK:recharge(
                orderID, 
                PlayerCache.userid, 
                "欢乐广东麻将-"..cfgItem["name"], 
                cfgItem["price"]*100, 
                "{\"ShopItemId\": "..cfgItem["id"].."}"
            )
            Helper.playSoundClick()
        end 
        WidgetExt.addClickEvent(tmpItem, onClick, nil)
    end 

    for _, cfgItem in pairs(t_shop_items) do 
        if not(cfgItem["display"] 
            and cfgItem["bindingdisplay"] 
            and self.agentID ~= 0) then 
            addShopItem(cfgItem)
        end 
    end 

    self.imgBg.imgContentBg.svContent:layoutVertical1({
        columns = 2,
        lineIntvl = 20,
        needSort = true,
        marginBottom = 120,
        marginRight = 30,
        marginLeft = 30,
    })
end 

function ShoppingMallLayer:onClose()
    Event.unregister(EventDefine.PAY_WECHAT_PAY_RES, self, "PAY_WECHAT_PAY_RES")
    Event.unregister(EventDefine.PAY_UNIFIED_ORDER_RES, self, "PAY_UNIFIED_ORDER_RES")    
end

function ShoppingMallLayer:PAY_WECHAT_PAY_RES(data)
    if data.err then
        if data.err == WechatSDK.PAY_ERR.USER_CANCLE then
            UIManager:showTip("取消充值")
        end
    else
        UIManager:showTip("充值成功")
    end    
end

function ShoppingMallLayer:PAY_UNIFIED_ORDER_RES(data) 
    UIManager:unblock()
    if data.err then
        if data.err ==WechatSDK.PAY_ERR.HTTP_ERROR then
            UIManager:showTip("网络连接服务器失败")
        else
            UIManager:showTip("下单失败")
        end 
    end   
end

--点击确认按钮判断推广员是否正确。之后得房卡后隐藏该房卡
function ShoppingMallLayer:onClick_ButtonEnter(touch, eventTouch)
    local id =  self.imgBg.ImgId.Image_32.ID:getString()
    id = string.trim(id)
    if id == "" then
        UIManager:showTip("推广员ID有误，请输入正确的推广员ID")
        return
    end
    local matchID = string.match(id, "%d+")
    if matchID ~= id then 
        UIManager:showTip("推广员ID有误，请输入正确的推广员ID")
        return
    end 
    --TODO 绑定推广员
    UIManager:showTip("代理商ID填写有误")
end

function ShoppingMallLayer:onClick_btnClose(touch, eventTouch)
    UIManager:goBack()
end

return ShoppingMallLayer

--endregion
