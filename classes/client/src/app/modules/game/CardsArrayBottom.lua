--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local CardsArrayBottom = class("CardsArrayBottom", ccui.Layout)

local GameDefine = require("app.modules.game.GameDefine")
local GameHelper = require("app.modules.game.GameHelper")

function CardsArrayBottom:ctor(params)
--    self:setBackGroundColorType(1)
--    self:setBackGroundColor({r = 97, g = 2, b = 0})
    self:setCascadeColorEnabled(true)
    self:setAnchorPoint(1, 0)
    self:setScale(0.9)
    self.cards = {}
    self.cardSize = {width = 0, height = 0}
    self.holdCard = nil
    self.touchBeganPos = nil
    self.lastTouchPos = nil
    self.isClick = true 
    self.status = GameDefine.CARDS_ARRAY_STATUS_NORMAL
    self.statusData = nil
    self.canBeSelectedGroups = {}
    self.clicks = {}
    self.prevClickCard = nil
    self.focusedCardPosOffset = cc.p(0, 10)
    self.rawPos = cc.p(self:getPosition())
    self.sysCardIntvl = 30 --最新系统派牌布局间隔
    self.selectingGroup = nil --当前正在选择的牌组
    self.lastSelectGroup = nil --最近一次选择的牌组
    self.mode = GameDefine.GAME_MODE.GAME 
    
    self:setTouchEnabled(true)
    util.bindUITouchEvents(self, self)
end 

function CardsArrayBottom:setStatus(status, statusData)
    if self.status == status then 
        return 
    end 
    self.status = status
    self.statusData = statusData
    self:__updateStatus()
end 

function CardsArrayBottom:__updateStatus()
    if self.status == GameDefine.CARDS_ARRAY_STATUS_CHI then 
        self:__updAvaiChiCards()
    elseif self.status == GameDefine.CARDS_ARRAY_STATUS_GANG then 
        self:__updGangs()
    elseif self.status == GameDefine.CARDS_ARRAY_STATUS_NORMAL then 
        self:refresh()
    end 
end 

function CardsArrayBottom:__updGangs()
    self.canBeSelectedGroups = {} --clear
    local tmpGangs = {}
    local gangs = self.statusData.gangs
    for _, gang in ipairs(gangs) do 
        tmpGangs[gang.cardVal] = gang
    end
    local tmp = {}
    for i, card in ipairs(self.cards) do 
        if tmpGangs[card.cardVal] then 
            local gang = tmpGangs[card.cardVal]
            local group = nil
            if gang.mingType == GameDefine.MING_TYPE_AN_GANG then 
                group = {data = gang, cards = {self.cards[i + 0], self.cards[i + 1], self.cards[i + 2], self.cards[i + 3]}}
            elseif gang.mingType == GameDefine.MING_TYPE_MING_GANG then 
                if gang.subMingType == GameDefing.MING_TYPE_MING_GANG_SUB_PENG then 
                    group = {data = gang, cards = {self.cards[i + 0]}}
                else 
                    assert(false)
                end 
            else 
                assert(false)
            end 
            table.insert(self.canBeSelectedGroups, group)
            for _, tmpCard in pairs(group.cards) do 
                table.insert(tmp, tmpCard)
            end 
            tmpGangs[card.cardVal] = nil
        end 
    end 
    self:__highLightCards(tmp)
end 

function CardsArrayBottom:__updAvaiChiCards()
    self.canBeSelectedGroups = {} --clear
    local tmp = {}
    for i, card in ipairs(self.cards) do 
        if not GameCache:isGangCard(card.cardVal) and 
            (card.cardVal == self.statusData.cardVal - 1 or 
            card.cardVal == self.statusData.cardVal - 2 or 
            card.cardVal == self.statusData.cardVal + 1 or 
            card.cardVal == self.statusData.cardVal + 2) then
            tmp[card.cardVal] = card
        end 
    end 
    if not tmp[self.statusData.cardVal - 1] then 
        tmp[self.statusData.cardVal - 2] = nil
    end 
    if not tmp[self.statusData.cardVal + 1] then 
        tmp[self.statusData.cardVal + 2] = nil
    end 
    if self.statusData.cardVal % 10 == 8 then 
        tmp[self.statusData.cardVal + 2] = nil
    end 
    if self.statusData.cardVal % 10 == 2 then 
        tmp[self.statusData.cardVal - 2] = nil
    end 
    if self.statusData.cardVal % 10 == 9 then 
        tmp[self.statusData.cardVal + 1] = nil
        tmp[self.statusData.cardVal + 2] = nil
    end 
    if self.statusData.cardVal % 10 == 1 then 
        tmp[self.statusData.cardVal - 1] = nil
        tmp[self.statusData.cardVal - 2] = nil
    end 
    for _, card in pairs(tmp) do 
        if card.cardVal == self.statusData.cardVal - 2 then 
            local group = {data = nil, cards = {tmp[self.statusData.cardVal - 2], tmp[self.statusData.cardVal - 1]}}
            table.insert(self.canBeSelectedGroups, group)
        end 
        if card.cardVal == self.statusData.cardVal - 1 and tmp[self.statusData.cardVal + 1] then 
            local group = {data = nil, cards = {tmp[self.statusData.cardVal - 1], tmp[self.statusData.cardVal + 1]}}
            table.insert(self.canBeSelectedGroups, group)
        end 
        if card.cardVal == self.statusData.cardVal + 1 and tmp[self.statusData.cardVal + 2] then 
            local group = {data = nil, cards = {tmp[self.statusData.cardVal + 1], tmp[self.statusData.cardVal + 2]}}
            table.insert(self.canBeSelectedGroups, group)
        end 
    end 
    assert(#self.canBeSelectedGroups <= 3)

    self:__highLightCards(tmp)
end 

function CardsArrayBottom:__highLightCards(cards)
    local highLightNodes = {} --{[nodeID] = node, ...}
    for _, card in pairs(cards or {}) do
        highLightNodes[card.node.id] = card.node
    end 
    for _, card in pairs(self.cards) do 
        if not highLightNodes[card.node.id] then 
            card.node:setGray()
        else 
            card.node:setNormal()
        end 
    end 
end 

function CardsArrayBottom:__unfocusCards(cards)
    for _, card in pairs(cards or {}) do 
        local pos = cc.p(card.node:getPosition())
        pos.x = pos.x - self.focusedCardPosOffset.x
        pos.y = pos.y - self.focusedCardPosOffset.y
        card.node:setPosition(pos)
    end 
end 

function CardsArrayBottom:__focusCards(cards)
    for _, card in pairs(cards or {}) do 
        local pos = cc.p(card.node:getPosition())
        pos.x = pos.x + self.focusedCardPosOffset.x
        pos.y = pos.y + self.focusedCardPosOffset.y
        card.node:setPosition(pos)
    end 
end 

function CardsArrayBottom:__outCard(selectGroup)
    if self.status == GameDefine.CARDS_ARRAY_STATUS_CHI then 
        local chiType = GameDefine.calChiType(self.statusData.cardVal, 
                                                selectGroup.cards[1].cardVal, 
                                                selectGroup.cards[2].cardVal)
        Network:send(Define.SERVER_GAME, "mc_action_chi", {cardVal = self.statusData.cardVal, chiType = chiType})
        UIManager:block()
    elseif self.status == GameDefine.CARDS_ARRAY_STATUS_GANG then 
        Network:send(Define.SERVER_GAME, "mc_action_gang", {
            cardVal = selectGroup.data.cardVal, 
            mingType = selectGroup.data.mingType, 
            subMingType = selectGroup.data.subMingType, 
        })
        UIManager:block()
    elseif self.status == GameDefine.CARDS_ARRAY_STATUS_NORMAL then 
        if selectGroup.cards[1].cardVal == GameCache.laiZiCardVal or 
            selectGroup.cards[1].cardVal == GameCache.laiZiPiCardVal or 
            selectGroup.cards[1].cardVal == GameCache.hongZhongCardVal then 
            local data = {}
            data.cardVal = selectGroup.cards[1].cardVal
            data.mingType = GameDefine.MING_TYPE_MING_GANG
            data.subMingType = GameDefine.MING_TYPE_MING_GANG_SUB_GANG_PAI
            Network:send(Define.SERVER_GAME, "mc_action_gang", data)
        else 
            Network:send(Define.SERVER_GAME, "mc_out_card", {
                cardVal = selectGroup.cards[1].cardVal
            })
            Event.dispatch("DO_ANIMATION", {
                animaType = GameDefine.ANIMA_TYPE_OP_OUT_CARD,
                data = {
                    userid = PlayerCache.userid,
                    node = selectGroup.cards[1].node,
                    cardVal = selectGroup.cards[1].cardVal,
                }
            })
        end 
        UIManager:block()
    end 
end 

function CardsArrayBottom:getCard(pos)
    print("DownPos: "..table.tostring(pos))
    if self.cardSize.width == 0 or self.cardSize.height == 0 then 
        return 
    end 
    for _, card in pairs(self.cards) do 
        local sz = card.node:getContentSize()
        local anpt = card.node:getAnchorPoint()
        local cardPos = cc.p(card.node:getPosition())
        local rect = {
            left = cardPos.x - sz.width * anpt.x,
            right = cardPos.x + sz.width * (1 - anpt.x),
            top = cardPos.y + sz.height * (1 - anpt.y), 
            bottom = cardPos.y - sz.height * anpt.y,
        }
    print("Rect: "..table.tostring(rect))
        if pos.x >= rect.left and 
            pos.x < rect.right and 
            pos.y >= rect.bottom and 
            pos.y < rect.top then 
            return card
        end 
    end 
    return nil
end 

function CardsArrayBottom:onTouchBegan_(sender, pos)
    if self.mode == GameDefine.GAME_MODE.DEMO then 
        return 
    end 
    print("11111111111")
    if not GameCache:isMyTurn() then 
        return 
    end
    print("22222222")
    pos = self:convertToNodeSpace(pos)
    local card = self:getCard(pos)
    print("33333333333")
    if not card then 
        return
    end 
    print("444444444444444")
    if self.lastSelectGroup then 
        for _, card in pairs(self.lastSelectGroup.cards) do 
            card.node:setPosition(card.node.rawPos)
            card.node:setLocalZOrder(card.node.rawZOrder)
        end 
        self.lastSelectGroup = nil
    end 
    self.selectingGroup = nil
    if self.status ~= GameDefine.CARDS_ARRAY_STATUS_NORMAL then 
        local valid = false
        for _, group in ipairs(self.canBeSelectedGroups) do 
            for _, cardNode in ipairs(group.cards) do 
                if card.node.id == cardNode.node.id then 
                    valid = true
                    self.selectingGroup = group
                    break
                end 
            end 
            if valid then 
                break
            end 
        end 
        if not valid then 
            return 
        end 
    end 
    print("5555555555555")
    self.isClick = true
    self.holdCard = card
    self.selectingGroup = self.selectingGroup or {cards = {card}}
    self.lastTouchPos = pos
    self.touchBeganPos = pos
    for _, card in pairs(self.selectingGroup.cards) do 
        card.node.rawPos = cc.p(card.node:getPosition())
        card.node.rawZOrder = card.node:getLocalZOrder()
        card.node:setLocalZOrder(1000)
    end 
end 

function CardsArrayBottom:onTouchMoved_(sender, pos)
    if self.mode == GameDefine.GAME_MODE.DEMO then 
        return 
    end 
    if not self.holdCard then 
        return 
    end
    pos = self:convertToNodeSpace(pos)
    if self.isClick then 
        if math.abs(pos.x - self.touchBeganPos.x) > 10 or 
            math.abs(pos.y - self.touchBeganPos.y) > 10 then 
            self.isClick = false
            self.clicks = {}
        end 
    end 
    if self.isClick then 
        return 
    end 
    local deltaX = pos.x - self.lastTouchPos.x
    local deltaY = pos.y - self.lastTouchPos.y
    for _, card in pairs(self.selectingGroup.cards) do 
        local nodePos = cc.p(card.node:getPosition())
        nodePos.x = nodePos.x + deltaX
        nodePos.y = nodePos.y + deltaY
        card.node:setPosition(nodePos)
    end 
    self.lastTouchPos = pos
end 

function CardsArrayBottom:onTouchEnded_(sender, pos)
    if self.mode == GameDefine.GAME_MODE.DEMO then 
        return 
    end 
    if not self.holdCard then 
        return 
    end
    pos = self:convertToNodeSpace(pos)
    if self.isClick then 
        table.insert(self.clicks, self.holdCard)
        self.lastSelectGroup = self.selectingGroup
        if #self.clicks == 1 then 
            self:__focusCards(self.selectingGroup.cards)
        elseif #self.clicks == 2 then 
            if self.clicks[1].node.id == self.clicks[2].node.id then 
                self:__outCard(self.selectingGroup)
                self.clicks = {}
                self.prevClickCard = nil
                self.lastSelectGroup = nil
            else
                self.clicks = {self.holdCard}
                self:__focusCards(self.selectingGroup.cards)
            end 
        end 
    else 
        for _, card in pairs(self.selectingGroup.cards) do 
            card.node:setPosition(card.node.rawPos)
            card.node:setLocalZOrder(card.node.rawZOrder)
        end 
    end 
    --just reset
    self.holdCard = nil
    self.lastTouchPos = nil
    self.rawCardPos = nil
    self.selectingGroup = nil
end 

function CardsArrayBottom:onTouchCanceled_(sender)
    if self.mode == GameDefine.GAME_MODE.DEMO then 
        return 
    end 
    if not self.holdCard then 
        return 
    end
    if self.lastTouchPos.y < self:getContentSize().height then
        for _, card in pairs(self.selectingGroup.cards) do 
            card.node:setPosition(card.node.rawPos)
            card.node:setLocalZOrder(card.node.rawZOrder)
        end 
    else
        self:__outCard(self.selectingGroup)
    end 
    self.clicks = {}
    self.holdCard = nil
    self.lastTouchPos = nil
    self.rawCardPos = nil
    self.selectingGroup = nil
end 

function CardsArrayBottom:setMode(mode)
    self.mode = mode 
end 

function CardsArrayBottom:incCardsNum(num)
    -- empty implementation
end 

function CardsArrayBottom:decCardsNum(num)
    -- empty implementation
end 

function CardsArrayBottom:addCard(cardVal)
    self:__resetSysCard()
    table.insert_sort(self.cards, {cardVal = cardVal, node = nil}, function(card1, card2)
        return card2.cardVal < card1.cardVal
    end)
    self:refresh()
end 

function CardsArrayBottom:addSysCard(cardVal)
    if self.sysCard then 
        return 
    end 
    local card = {cardVal = cardVal, node = nil}
    table.insert_sort(self.cards, card, function(card1, card2)
        return card2.cardVal < card1.cardVal
    end)
    card.node = Helper.getCardSpriteBottom(card.cardVal)
    GameHelper.decorateCardImgWithSpecialMark(card.node, card.cardVal, GameDefine.DIR_BOTTOM)
    card.node:setLocalZOrder(0)
    card.node:addTo(self)
    local selfSz = self:getContentSize()
    local contentSz = card.node:getContentSize()
    local anpt = card.node:getAnchorPoint()

    card.node:setPosition(cc.p(selfSz.width + self.sysCardIntvl + contentSz.width * anpt.x, contentSz.height * anpt.y))
    selfSz.width = selfSz.width + contentSz.width + self.sysCardIntvl
    local selfPos = cc.p(self.rawPos.x + (contentSz.width + self.sysCardIntvl) * self:getScaleX(), self.rawPos.y)
    self:setPosition(selfPos)
    self:setContentSize(selfSz)
    self.sysCard = card
end 

function CardsArrayBottom:__resetSysCard()
    if not self.sysCard then 
        return 
    end 
    local selfSz = self:getContentSize()
    local selfPos = cc.p(self:getPosition())
    local contentSz = self.sysCard.node:getContentSize()
    
    selfSz.width = selfSz.width - contentSz.width - self.sysCardIntvl
    selfPos = cc.p(selfPos.x - (contentSz.width + self.sysCardIntvl) * self:getScaleX(), selfPos.y)
    self:setPosition(selfPos)
    self:setContentSize(selfSz)
    self.sysCard = nil
--    self:refresh()
end 

--[Comment]
--resetSysCard doesn't refresh current cards' position
function CardsArrayBottom:rmvCard(cardVal)
    self:__resetSysCard()
    local card = table.delete(self.cards, cardVal, function(ele)
        return ele.cardVal == cardVal
    end)
    if card.node then 
        card.node:removeFromParent()
    end 
    self:refresh()
end 

function CardsArrayBottom:addCards(cards)
    self:__resetSysCard()
    for k, v in pairs(cards) do 
        table.insert(self.cards, {cardVal = v, node = nil})
    end 
    table.sort(self.cards, function(card1, card2)
        return card1.cardVal < card2.cardVal
    end)
    self:refresh()
end 

function CardsArrayBottom:rmvCards(cards)
    self:__resetSysCard()
    local tmp = {}
    for k, v in pairs(cards) do 
        tmp[v] = tmp[v] or {cardVal = v, num = 0}
        tmp[v].num = tmp[v].num + 1
    end 
    local tmpCards = {}
    for i, card in ipairs(self.cards) do 
        if tmp[card.cardVal] and tmp[card.cardVal].num > 0 then 
            card.node:removeFromParent()
            tmp[card.cardVal].num = tmp[card.cardVal].num - 1
        else
            table.insert(tmpCards, card)
        end 
    end 
    self.cards = tmpCards
    self:refresh()
end 

function CardsArrayBottom:createCardNode(cardVal)
    local node 
    if self.mode == GameDefine.GAME_MODE.GAME then 
        node = Helper.getCardSpriteBottom(cardVal)
        GameHelper.decorateCardImgWithSpecialMark(node, cardVal, GameDefine.DIR_BOTTOM)
    elseif self.mode == GameDefine.GAME_MODE.DEMO then --it's same with game mode
        node = Helper.getCardSpriteBottom(cardVal)
        GameHelper.decorateCardImgWithSpecialMark(node, cardVal, GameDefine.DIR_BOTTOM)
    end 
    return node
end 

function CardsArrayBottom:refresh()
    for i, card in ipairs(self.cards) do 
        if not card.node then 
            card.node = self:createCardNode(card.cardVal)
            card.node:setLocalZOrder(0)
            card.node:addTo(self)
        end 
        if card.cardVal == GameCache.laiZiCardVal then 
            card.node.priority = -1
        elseif card.cardVal == GameCache.laiZiPiCardVal then 
            card.node.priority = -2
        elseif card.cardVal == GameCache.hongZhongCardVal then 
            card.node.priority = -3
        else  
            card.node.priority = i
        end 
        card.node.id = i
        card.node:setNormal()
        if self.cardSize.width == 0 or self.cardSize.width == 0 then 
            self.cardSize = card.node:getContentSize()
        end
    end 
    WidgetExt.panLayoutHorizontal(self, {
        needSort = true,
        columnIntvl = -3,
    })
end 

function CardsArrayBottom:getSysCardPosition()
    local selfSz = self:getContentSize()
    local nodeSz = self:createCardNode(11):getContentSize()
    local pos = cc.p(selfSz.width + self.sysCardIntvl + nodeSz.width * 0.5, nodeSz.height * 0.5)
    return self:convertToWorldSpace(pos)
end 

function CardsArrayBottom:getSysCardSize()
    local nodeSz = self:createCardNode(11):getContentSize()
    return {
        width = nodeSz.width * self:getScaleX(),
        height = nodeSz.height * self:getScaleY(),
    }
end 

function CardsArrayBottom:selectAOutCardNode(cardVal)
    for _, card in ipairs(self.cards) do 
        if card.cardVal == cardVal then 
            return card.node
        end 
    end 
    assert(false)
end 

return CardsArrayBottom
--endregion
