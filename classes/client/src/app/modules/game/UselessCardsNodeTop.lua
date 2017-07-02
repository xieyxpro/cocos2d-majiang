--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local UselessCardsNodeTop = class("UselessCardsNodeTop", ccui.Layout)
local GameHelper = require("app.modules.game.GameHelper")
local GameDefine = require("app.modules.game.GameDefine")

function UselessCardsNodeTop:ctor()
--    self:setBackGroundColorType(1)
--    self:setBackGroundColor({r = 97, g = 2, b = 0})
    self:setCascadeColorEnabled(true)
    self:setAnchorPoint(0.5, 1)
    self:setScale(0.4)
    self.cards = {} --{{cardVal = ?, node = ?}, ...}
    self.rawPos = nil
    self.rawPos = cc.p(self:getPosition())
    local spSampleCard = cc.Sprite:create("GameScene/vertical/mingmah_00.png")
    self.cardSize = spSampleCard:getContentSize()
    self.cardAnpt = spSampleCard:getAnchorPoint()
    self.cardMaskSize = {width = 0, height = 25}
    self.colIntvl = 0
    self.lineIntvl = 0
    self.columns = 9

    local width = self:calcWidth()
    local sz = {width = width, height = 0}
    self.width = sz.width 
    self.height = sz.height
    self:setContentSize(sz)
end

function UselessCardsNodeTop:addCards(cards)
    for _, cardVal in ipairs(cards) do 
        table.insert(self.cards, {cardVal = cardVal, node = nil})
    end 
    self:layoutCardsAll()
end 

function UselessCardsNodeTop:addCard(cardVal)
    table.insert(self.cards, {cardVal = cardVal, node = nil})
    self:layoutCard(self.cards[#self.cards], #self.cards)
end 

function UselessCardsNodeTop:rmvCard(cardVal)
    local card = table.delete(self.cards, cardVal, function(ele)
        return ele.cardVal == cardVal
    end)
    if card.node then 
        card.node:removeFromParent()
    end 
    self:refresh()
end 

function UselessCardsNodeTop:rmvTheLast(cardVal)
    local card = self.cards[#self.cards]
    assert(card.cardVal == cardVal)
    card.node:removeFromParent()
    self.cards[#self.cards] = nil
end 

function UselessCardsNodeTop:calcWidth()
    local width = (self.columns - 1) * 
        (self.cardSize.width + self.colIntvl - self.cardMaskSize.width) + 
        self.cardSize.width
    return width
end 

function UselessCardsNodeTop:calcHeight()
    --TODO pending implementation
end 

function UselessCardsNodeTop:calculatePos(index)
    local line = math.ceil(index / self.columns)
    local col = index % self.columns
    col = col == 0 and self.columns or col
    local pos = cc.p(0, 0)
    pos.x = self.width - (col - 1) * (self.cardSize.width + self.colIntvl - self.cardMaskSize.width) - 
        self.cardSize.width * (1 - self.cardAnpt.x)
    pos.y = -(line - 1) * (self.cardSize.height + self.lineIntvl - self.cardMaskSize.height) - 
        self.cardSize.height * (1 - self.cardAnpt.y)
    return pos
end 

function UselessCardsNodeTop:layoutCard(card, layoutIndex)
    if not card.node then 
        card.node = Helper.getCardSpriteFlatTop(card.cardVal)
        GameHelper.decorateCardImgWithSpecialMarkFlat(card.node, card.cardVal, GameDefine.DIR_TOP)
        card.node:setRotation(180)
        card.node:addTo(self)
    end 
    card.node:setLocalZOrder(layoutIndex)
    local pos = self:calculatePos(layoutIndex)
    card.node:setPosition(pos)
end 

function UselessCardsNodeTop:layoutCardsAll()
    for i, card in ipairs(self.cards) do 
        self:layoutCard(card, i)
    end 
end 

function UselessCardsNodeTop:createOutCardNode(cardVal)
    local node = Helper.getCardSpriteFlatBottom(cardVal)
    GameHelper.decorateCardImgWithSpecialMarkFlat(node, cardVal, GameDefine.DIR_BOTTOM)
    return node
end 

function UselessCardsNodeTop:createCardNode(cardVal)
    local node = Helper.getCardSpriteFlatTop(cardVal)
    GameHelper.decorateCardImgWithSpecialMarkFlat(node, cardVal, GameDefine.DIR_TOP)
    return node
end 

function UselessCardsNodeTop:refresh()
    for i, card in ipairs(self.cards) do 
        if not card.node then 
            card.node = self:createCardNode(card.cardVal)
            card.node:setRotation(180)
            card.node:addTo(self)
        end 
        card.node.priority = i
    end 
    local columnIntvl = -3
    if #self.cards > 0 then 
        local cardSz = self.cards[1].node:getContentSize()
        local sz = self:getContentSize()
        sz.width = self.columns * cardSz.width + (self.columns - 1) * columnIntvl
        self:setContentSize(sz)
    end 
    WidgetExt.panLayoutVertical(self, {
                horizontalMargin = WidgetExt.HorizontalMargin.RIGHT,
                columnIntvl = columnIntvl, 
                lineIntvl = -25,
                columns = self.columns, 
                reverseCol = true, 
                needSort = true})
end 

function UselessCardsNodeTop:getLastCardPosition()
    if #self.cards == 0 then 
        return nil
    end
    local node = self.cards[#self.cards].node
    local pos = cc.p(node:getPosition())
    return cc.p(node:getParent():convertToWorldSpace(pos))
end 

function UselessCardsNodeTop:getTheNextCardPosition()
    local pos = self:calculatePos(#self.cards + 1)
    return self:convertToWorldSpace(pos)
end 

function UselessCardsNodeTop:getTheNextCardSize()
    return {
        width = self.cardSize.width,
        height = self.cardSize.height,
    }
end 

return UselessCardsNodeTop
--endregion
