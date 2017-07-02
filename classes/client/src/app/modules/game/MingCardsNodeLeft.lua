--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local MingCardsNodeLeft = class("MingCardsNodeLeft", ccui.Layout)

local UIAnGangNode = require("GameScene.AnGangHoriNode")
local UIMingGangNode = require("GameScene.MingGangHoriNode")
local UIMingGangSnglNode = require("GameScene.MingGangSnglHoriLeftNode")
local UIPengNode = require("GameScene.PengHoriNode")
local UIShunNode = require("GameScene.ShunHoriNode")
local GameDefine = require("app.modules.game.GameDefine")
local GameHelper = require("app.modules.game.GameHelper")

function MingCardsNodeLeft:ctor()
    self.panMingCards = ccui.Layout:create():addTo(self)
--    self.panMingCards:setBackGroundColorType(1)
--    self.panMingCards:setBackGroundColor({r = 255, g = 2, b = 0})
    self.panMingCards:setCascadeColorEnabled(true)
    self.panMingCards:setAnchorPoint(0, 1)
    self.panMingCards:setScale(0.7)
    self.mingCards = {}
    self.cardSize = {width = 0, height = 0}
    self.mode = GameDefine.GAME_MODE.GAME 

    self.panGangCards = ccui.Layout:create():addTo(self)
    self.panGangCards:setAnchorPoint(cc.p(0, 1))
    self.panGangCards:setPosition(cc.p(61, -20))
    self.panGangCards:setScale(0.6)
    self.gangCardsAry = {}
    
    local spSampleCard = cc.Sprite:create("GameScene/left/mingmah_00.png")
    self.gangCardSize = spSampleCard:getContentSize()
    self.gangCardAnpt = spSampleCard:getAnchorPoint()
    self.gangCardMaskSize = {width = 0, height = 18}
    self.gangCardColIntvl = 0
    self.gangCardLineIntvl = 0
    self.gangCardColumns = 9
end

function MingCardsNodeLeft:setMode(mode)
    self.mode = mode 
end 

function MingCardsNodeLeft:findGangCard(cardVal)
    for _, cardData in ipairs(self.gangCardsAry) do 
        if cardData.cardVal == cardVal then 
            return cardData
        end 
    end 
end 

function MingCardsNodeLeft:addGangCard(cardVal)
    --find and add
    local card = self:findGangCard(cardVal)
    if not card then 
        card = {cardVal = cardVal, num = 0, node = nil}
        local node = UIMingGangSnglNode:create().root
        util.bindUINodes(node, node, node)
        local strPath = Helper.getCardImgPathOfFlatLeft(cardVal)
        node.rootPanel.img11:loadTexture(strPath)
        GameHelper.decorateCardImgWithSpecialMarkFlat(node.rootPanel.img11, cardVal, GameDefine.DIR_LEFT)
        node.rootPanel.priority = #self.gangCardsAry
        node.rootPanel:removeFromParent()
        local rootPanel = node.rootPanel
        rootPanel:setLocalZOrder(10 - node.rootPanel.priority)
        rootPanel:setRotation(0)
        rootPanel:addTo(self.panGangCards)
        card.node = rootPanel
        table.insert(self.gangCardsAry, card)
        self:layoutGangCard(card, #self.gangCardsAry)
    end
    card.num = card.num + 1
    card.node.txtNum:setText(tostring(card.num))
end 

function MingCardsNodeLeft:rmvGangCard(cardVal)
    local card = self:findGangCard(cardVal)
    assert(card)
    card.num = card.num - 1
    if card.num == 0 then 
        card.node:removeFromParent()
        -- remove from array
        local tmp = {}
        for _, cardData in ipairs(self.gangCardsAry) do 
            if cardData.cardVal ~= cardVal then 
                table.insert(tmp, cardData)
            end 
        end 
        self.gangCardsAry = tmp
        self:layoutGangCardsAll()
    else
        card.node.txtNum:setText(tostring(card.num))
    end 
end 

function MingCardsNodeLeft:calculateGangCardPos(index)
    local line = math.ceil(index / self.gangCardColumns)
    local col = index % self.gangCardColumns
    col = col == 0 and self.gangCardColumns or col
    local pos = cc.p(0, 0)
    pos.x = (line - 1) * (self.gangCardSize.width + self.gangCardColIntvl - self.gangCardMaskSize.width) + 
        self.gangCardSize.width * self.gangCardAnpt.x
    pos.y = -(col - 1) * (self.gangCardSize.height + self.gangCardLineIntvl - self.gangCardMaskSize.height) - 
        self.gangCardSize.height * (1 - self.gangCardAnpt.y)
    return pos
end 

function MingCardsNodeLeft:layoutGangCard(card, layoutIndex)
    card.node:setLocalZOrder(layoutIndex)
    local pos = self:calculateGangCardPos(layoutIndex)
    card.node:setPosition(pos)
end 

function MingCardsNodeLeft:layoutGangCardsAll()
--    WidgetExt.panLayoutCustomHorizontal(self.panGangCards, {
--            columnIntvl = 10, 
--            needSort = true, 
--            margin = WidgetExt.VerticalMargin.BOTTOM
--        })
    for i, gangCard in ipairs(self.gangCardsAry) do 
        local node = gangCard.node
        node:setLocalZOrder(i)
        local pos = self:calculateGangCardPos(i)
        node:setPosition(pos)
    end 
end 

function MingCardsNodeLeft:addCards(mingCards)
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

function MingCardsNodeLeft:addCard(cardVal, mingType, subMingType)
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

function MingCardsNodeLeft:rmvCard(cardVal, mingType, subMingType)
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

function MingCardsNodeLeft:createMingCard(cardVal, mingType, subMingType)
    local node = nil
    if mingType == GameDefine.MING_TYPE_CHI_LEFT then 
        node = UIShunNode:create().root
        util.bindUINodes(node, node, node)
        local strPath1 = Helper.getCardImgPathOfFlatLeft(cardVal)
        local strPath2 = Helper.getCardImgPathOfFlatLeft(cardVal + 1)
        local strPath3 = Helper.getCardImgPathOfFlatLeft(cardVal + 2)
        node.rootPanel.img11:loadTexture(strPath1)
        node.rootPanel.img12:loadTexture(strPath2)
        node.rootPanel.img13:loadTexture(strPath3)
    elseif mingType == GameDefine.MING_TYPE_CHI_MID then 
        node = UIShunNode:create().root
        util.bindUINodes(node, node, node)
        local strPath1 = Helper.getCardImgPathOfFlatLeft(cardVal - 1)
        local strPath2 = Helper.getCardImgPathOfFlatLeft(cardVal)
        local strPath3 = Helper.getCardImgPathOfFlatLeft(cardVal + 1)
        node.rootPanel.img11:loadTexture(strPath1)
        node.rootPanel.img12:loadTexture(strPath2)
        node.rootPanel.img13:loadTexture(strPath3)
    elseif mingType == GameDefine.MING_TYPE_CHI_RIGHT then 
        node = UIShunNode:create().root
        util.bindUINodes(node, node, node)
        local strPath1 = Helper.getCardImgPathOfFlatLeft(cardVal - 2)
        local strPath2 = Helper.getCardImgPathOfFlatLeft(cardVal - 1)
        local strPath3 = Helper.getCardImgPathOfFlatLeft(cardVal)
        node.rootPanel.img11:loadTexture(strPath1)
        node.rootPanel.img12:loadTexture(strPath2)
        node.rootPanel.img13:loadTexture(strPath3)
    elseif mingType == GameDefine.MING_TYPE_MING_GANG then 
        if subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_GANG_PAI then 
            node = UIMingGangSnglNode:create().root
            util.bindUINodes(node, node, node)
            local strPath = Helper.getCardImgPathOfFlatLeft(cardVal)
            node.rootPanel.img11:loadTexture(strPath)
            GameHelper.decorateCardImgWithSpecialMarkFlat(node.rootPanel.img11, cardVal, GameDefine.DIR_LEFT)
        else
            node = UIMingGangNode:create().root
            util.bindUINodes(node, node, node)
            local strPath = Helper.getCardImgPathOfFlatLeft(cardVal)
            node.rootPanel.img11:loadTexture(strPath)
            node.rootPanel.img12:loadTexture(strPath)
            node.rootPanel.img13:loadTexture(strPath)
            node.rootPanel.img21:loadTexture(strPath)
        end 
    elseif mingType == GameDefine.MING_TYPE_AN_GANG then 
        node = UIAnGangNode:create().root
        util.bindUINodes(node, node, node)
        if self.mode == GameDefine.GAME_MODE.GAME then 
            -- DO NOTHING
        else 
            local strPath = Helper.getCardImgPathOfFlatLeft(cardVal)
            node.rootPanel.img21:loadTexture(strPath)
        end 
    elseif mingType == GameDefine.MING_TYPE_PENG then 
        node = UIPengNode:create().root
        util.bindUINodes(node, node, node)
        local strPath = Helper.getCardImgPathOfFlatLeft(cardVal)
        node.rootPanel.img11:loadTexture(strPath)
        node.rootPanel.img12:loadTexture(strPath)
        node.rootPanel.img13:loadTexture(strPath)
    else 
        error("invalid ming card type")
    end 
    local rootPanel = node.rootPanel:removeFromParentAndCleanup(false)
    return rootPanel
end 

function MingCardsNodeLeft:createOutGangCardNode(cardVal)
    local node = Helper.getCardSpriteFlatBottom(cardVal)
    GameHelper.decorateCardImgWithSpecialMarkFlat(node, cardVal, GameDefine.DIR_BOTTOM)
    return node
end 

function MingCardsNodeLeft:createCardNode(cardVal)
    local node = Helper.getCardSpriteFlatLeft(cardVal)
    GameHelper.decorateCardImgWithSpecialMarkFlat(node, cardVal, GameDefine.DIR_LEFT)
    return node
end 

function MingCardsNodeLeft:refresh()
    for i, mingCard in ipairs(self.mingCards) do 
        if not mingCard.node and 
            mingCard.subMingType ~= GameDefine.MING_TYPE_MING_GANG_SUB_GANG_PAI then 
            mingCard.node = self:createMingCard(mingCard.cardVal, mingCard.mingType, mingCard.subMingType)
            mingCard.node:addTo(self.panMingCards)
        end 
        if mingCard.node then 
            mingCard.node.priority = #self.mingCards - i
            mingCard.node:setLocalZOrder(i)
        end 
    end 
    WidgetExt.panLayoutCustomVertical(self.panMingCards, {
        needSort = true, 
        lineIntvl = -5, 
        margin = WidgetExt.HorizontalMargin.LEFT
    })
end 

function MingCardsNodeLeft:getTheNextGangCardPosition(cardVal)
    local card = self:findGangCard(cardVal)
    local pos
    if card then 
        pos = cc.p(card.node.img11:getPosition())
    else 
        pos = self:calculateGangCardPos(#self.mingCards + 1)
    end 
    return self.panGangCards:convertToWorldSpace(pos)
end 

function MingCardsNodeLeft:getTheNextGangCardSize()
    return {
        width = self.gangCardSize.width * self.panGangCards:getScaleX(),
        height = self.gangCardSize.height * self.panGangCards:getScaleY(),
    }
end 

return MingCardsNodeLeft
--endregion
