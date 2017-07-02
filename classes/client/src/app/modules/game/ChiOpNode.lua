--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local ChiOpNode = class("ChiOpNode", cc.Node)

local UIAnGangNode = require("GameScene.AnGangVertiNode")
local UIMingGangNode = require("GameScene.MingGangVertiNode")
local UIMingGangSnglNode = require("GameScene.MingGangSnglVertiNode")
local UIPengNode = require("GameScene.PengVertiNode")
local UIShunNode = require("GameScene.ShunVertiNode")
local GameDefine = require("app.modules.game.GameDefine")
local GameHelper = require("app.modules.game.GameHelper")

function ChiOpNode:ctor()
    self.panMingCards = ccui.Layout:create():addTo(self)
--    self.panMingCards:setBackGroundColorType(1)
--    self.panMingCards:setBackGroundColor({r = 255, g = 2, b = 0})
    self.panMingCards:setCascadeColorEnabled(true)
    self.panMingCards:setAnchorPoint(0.5, 0.5)
--    self.panMingCards:setScale(0.6)
    self.panMingCards:setContentSize({width = 800, height = 30})
    self.mingCards = {}
    self.cardSize = {width = 0, height = 0}
    self.mode = GameDefine.GAME_MODE.GAME 
end

function ChiOpNode:setMode(mode)
    self.mode = mode 
end 

function ChiOpNode:addCards(mingCards)
    for _, mingCard in ipairs(mingCards) do 
        mingCard.mingType = mingCard.mingType or 0
        mingCard.subMingType = mingCard.subMingType or 0
        table.insert(self.mingCards, {
            cardVal = mingCard.cardVal, 
            mingType = mingCard.mingType, 
            subMingType = mingCard.subMingType, 
            node = nil
        })
        if mingCard.mingType == GameDefine.MING_TYPE_MING_GANG and mingCard.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_GANG_PAI then 
            self:addGangCard(mingCard.cardVal)
        end 
    end 
    self:refresh()
end 

function ChiOpNode:addCard(cardVal, mingType, subMingType)
    mingType = mingType or 0
    subMingType = subMingType or 0
    table.insert(self.mingCards, {
        cardVal = cardVal, 
        mingType = mingType, 
        subMingType = subMingType, 
        node = nil
    })
    if mingType == GameDefine.MING_TYPE_MING_GANG and subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_GANG_PAI then 
        self:addGangCard(cardVal)
        return
    end 
    self:refresh()
end 

function ChiOpNode:rmvCard(cardVal, mingType, subMingType)
    mingType = mingType or 0
    subMingType = subMingType or 0
    local card = table.delete(self.mingCards, cardVal, function(ele)
        return ele.cardVal == cardVal and ele.mingType == mingType and ele.subMingType == subMingType
    end)
    assert(card)
    if mingType == GameDefine.MING_TYPE_MING_GANG and subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_GANG_PAI then 
        self:rmvGangCard(cardVal)
        return
    end 
    if card.node then 
        card.node:removeFromParent()
    end 
    self:refresh()
end 

function ChiOpNode:createMingCard(cardVal, mingType, subMingType)
    local node = nil
    if mingType == GameDefine.MING_TYPE_CHI_LEFT then 
        node = UIShunNode:create().root
        util.bindUINodes(node, node, node)
        local strPath1 = Helper.getCardImgPathOfFlatBottom(cardVal)
        local strPath2 = Helper.getCardImgPathOfFlatBottom(cardVal + 1)
        local strPath3 = Helper.getCardImgPathOfFlatBottom(cardVal + 2)
        node.rootPanel.img11:loadTexture(strPath1)
        node.rootPanel.img12:loadTexture(strPath2)
        node.rootPanel.img13:loadTexture(strPath3)
        node.rootPanel.img11:setColor({r = 100, g = 255, b = 255})
    elseif mingType == GameDefine.MING_TYPE_CHI_MID then 
        node = UIShunNode:create().root
        util.bindUINodes(node, node, node)
        local strPath1 = Helper.getCardImgPathOfFlatBottom(cardVal - 1)
        local strPath2 = Helper.getCardImgPathOfFlatBottom(cardVal)
        local strPath3 = Helper.getCardImgPathOfFlatBottom(cardVal + 1)
        node.rootPanel.img11:loadTexture(strPath1)
        node.rootPanel.img12:loadTexture(strPath2)
        node.rootPanel.img13:loadTexture(strPath3)
        node.rootPanel.img12:setColor({r = 100, g = 255, b = 255})
    elseif mingType == GameDefine.MING_TYPE_CHI_RIGHT then 
        node = UIShunNode:create().root
        util.bindUINodes(node, node, node)
        local strPath1 = Helper.getCardImgPathOfFlatBottom(cardVal - 2)
        local strPath2 = Helper.getCardImgPathOfFlatBottom(cardVal - 1)
        local strPath3 = Helper.getCardImgPathOfFlatBottom(cardVal)
        node.rootPanel.img11:loadTexture(strPath1)
        node.rootPanel.img12:loadTexture(strPath2)
        node.rootPanel.img13:loadTexture(strPath3)
        node.rootPanel.img13:setColor({r = 100, g = 255, b = 255})
    elseif mingType == GameDefine.MING_TYPE_MING_GANG then 
        if subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_GANG_PAI then 
            node = UIMingGangSnglNode:create().root
            util.bindUINodes(node, node, node)
            local strPath = Helper.getCardImgPathOfFlatBottom(cardVal)
            node.rootPanel.img11:loadTexture(strPath)
            GameHelper.decorateCardImgWithSpecialMarkFlat(node.rootPanel.img11, cardVal, GameDefine.DIR_BOTTOM)
        else
            node = UIMingGangNode:create().root
            util.bindUINodes(node, node, node)
            local strPath = Helper.getCardImgPathOfFlatBottom(cardVal)
            node.rootPanel.img11:loadTexture(strPath)
            node.rootPanel.img12:loadTexture(strPath)
            node.rootPanel.img13:loadTexture(strPath)
            node.rootPanel.img21:loadTexture(strPath)
        end 
    elseif mingType == GameDefine.MING_TYPE_AN_GANG then 
        node = UIAnGangNode:create().root
        util.bindUINodes(node, node, node)
        if self.mode == GameDefine.GAME_MODE.GAME then 
            local strPath = Helper.getCardImgPathOfFlatBottom(cardVal)
            node.rootPanel.img21:loadTexture(strPath)
        else 
            local strPath = Helper.getCardImgPathOfFlatBottom(cardVal)
            node.rootPanel.img21:loadTexture(strPath)
        end 
    elseif mingType == GameDefine.MING_TYPE_PENG then 
        node = UIPengNode:create().root
        util.bindUINodes(node, node, node)
        local strPath = Helper.getCardImgPathOfFlatBottom(cardVal)
        node.rootPanel.img11:loadTexture(strPath)
        node.rootPanel.img12:loadTexture(strPath)
        node.rootPanel.img13:loadTexture(strPath)
    else 
        error("invalid ming card type")
    end 
    local rootPanel = node.rootPanel:removeFromParentAndCleanup(false)
    return rootPanel
end 

function ChiOpNode:refresh()
    for i, mingCard in ipairs(self.mingCards) do 
        if not mingCard.node and 
            mingCard.mingType ~= GameDefine.MING_TYPE_MING_GANG and 
            mingCard.subMingType ~= GameDefine.MING_TYPE_MING_GANG_SUB_GANG_PAI then 
            mingCard.node = self:createMingCard(mingCard.cardVal, mingCard.mingType, mingCard.subMingType)
            mingCard.node:setAnchorPoint(cc.p(0.5, 0.5))
            mingCard.node:addTo(self.panMingCards)

            mingCard.node:setTouchEnabled(true)
            mingCard.node:addTouchEventListener(function(sender, event)
                if event == ccui.TouchEventType.began then 
                    sender:setScale(0.9)
                elseif event == ccui.TouchEventType.ended or 
                    event == ccui.TouchEventType.canceled then 
                    sender:setScale(1.0)
                end 
                if event == ccui.TouchEventType.ended then 
                    Network:send(Define.SERVER_GAME, "mc_action_chi", {cardVal = mingCard.cardVal, chiType = mingCard.mingType})
                    UIManager:block()
                end 
            end)
        end 
        if mingCard.node then 
            mingCard.node.priority = i
        end 
    end 
    WidgetExt.panLayoutVertical(self.panMingCards, {
        columnIntvl = 50,
        columns = #self.mingCards,
        needSort = true, 
        margin = WidgetExt.VerticalMargin.CENTER
    })
end 

return ChiOpNode
--endregion
