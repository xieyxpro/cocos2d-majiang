--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local GamePlayer = class("GamePlayer")

local GameDefine = require("app.modules.game.GameDefine")
 
function GamePlayer:ctor(params)
    params = params or {}
    self.userid = params.userid or 0
    self.nickname = Helper.cutNameWithAvaiLen(params.nickname or "")
    self.playerIP = util.convertIPV4ToStr(params.playerIP or "0")
    self.playerScore = params.playerScore or 0 --玩家分数
    self.chairID = params.chairID or 0 --座位号：1, 2, 3, 4，从左方开始逆时针
    self.status = params.status or 0
    self.isOffline = params.isOffline or (self.status == GameDefine.enum_UserStatus.US_OFFLINE or self.status == GameDefine.enum_UserStatus.US_OFFLINE_SIT)
    self.gender = params.gender or Define.GENDER_FEMALE
    self.playerIcon = params.playerIcon
    --默认playerIcon
    if self.gender == Define.GENDER_FEMALE then 
        self.playerIcon = "public/head_female.png"
    else
        self.playerIcon = "public/head_male.png"
    end 

    self.handCards = params.handCards or {} --手牌, {[cardType] = {cardType = ?, num = ?, cards = {{cardVal = ?, num = ?}, ...}}
    self.handCardsNum = params.handCardsNum or 0
    self.uselessCards = params.uselessCards or {} --已经打出去切没有被别人搞走的牌{cardVal1, cardVal2, ...}
    self.mingCards = params.mingCards or {} --明牌 {{cardVal = ?, mingType = ?, subMingType = ?}, ...}
    self.isZhuang = params.isZhuang or false --是否是庄
    self.huType = params.huType or 0
    self.isInTingMode = params.isInTingMode or false
    self.laisOwned = params.laisOwned or 0
    self.score = params.score or GameDefine.INI_SCORE --默认1000分
    self.isDelegate = params.isDelegate or false

    self.jingdu = params.location.jingdu
    self.weidu = params.location.weidu
    self.permissiondenied = params.location.permissiondenied
    self.city = params.location.city
    self.district = params.location.district
    self.address = params.location.address

    self.seatDir = 0
end 

function GamePlayer:incCardsNum(num)
    self.handCardsNum = self.handCardsNum + num
end 

function GamePlayer:decCardsNum(num)
    self.handCardsNum = self.handCardsNum - num
end 

function GamePlayer:inputCard(cardVal)
    local cardType = GameDefine.getCardType(cardVal)
    self.handCards[cardType] = self.handCards[cardType] or {cardType = cardType, num = 0, cards = {}}
    --find card
    local card = nil
    for _, v in ipairs(self.handCards[cardType].cards) do 
        if v.cardVal == cardVal then
            card = v
        end 
    end 
    --insert or update
    if card then 
        card.num = card.num + 1
    else 
        table.insert_sort(self.handCards[cardType].cards, {cardVal = cardVal, cardType = cardType, num = 1}, function(card1, card2)
            return card2.cardVal < card1.cardVal
        end)
    end 
    self.handCards[cardType].num = self.handCards[cardType].num + 1
    self.handCardsNum = self.handCardsNum + 1
end 

function GamePlayer:outputCard(cardVal, num)
    local cardType = GameDefine.getCardType(cardVal)
    local card = nil
    for _, v in ipairs(self.handCards[cardType].cards) do 
        if v.cardVal == cardVal then
            card = v
            break
        end 
    end 
    assert(card)
    assert(card.num >= num)
    card.num = card.num - num
    self.handCards[cardType].num = self.handCards[cardType].num - num
    self.handCardsNum = self.handCardsNum - num
end 

--[Comment]
--cards: {{cardVal = ?, num = ?}, ...}
function GamePlayer:outputCards(cards)
    local tmp = {}
    local cardTypes = {}
    for _, card in pairs(cards) do 
        tmp[card.cardVal] = card
        local cardType = GameDefine.getCardType(card.cardVal)
        cardTypes[cardType] = cardType
    end 
    for _, cardType in pairs(cardTypes) do 
        for _, card in ipairs(self.handCards[cardType].cards) do 
            if tmp[card.cardVal] then 
                card.num = card.num - tmp[card.cardVal].num
                self.handCards[cardType].num = self.handCards[cardType].num - tmp[card.cardVal].num
                self.handCardsNum = self.handCardsNum - tmp[card.cardVal].num
            end 
        end 
    end 
end 

function GamePlayer:getHandCardsCnt()
    local cardsCnt = 0
    for _, handCards in pairs(self.handCards) do 
        cardsCnt = cardsCnt + handCards.num
    end 
    return cardsCnt + self.laisOwned
end 

--是否将一色
function GamePlayer:isJiangYiSe(extraCardVal)
    local extraCardVal = extraCardVal or 0
    local extraCardType = GameDefine.getCardType(extraCardVal)
    local shortExtraCardVal = extraCardVal % 10

    local player = self

    local isJiangYiSe = true
    if shortCardVal ~= 2 and shortCardVal ~= 5 and shortCardVal ~= 8 then 
        return false
    end 
    for _, handCards in pairs(player.handCards) do 
        if handCards.num > 0 then 
            for _, card in ipairs(handCards.cards) do 
                if card.num > 0 then 
                    local shortCardVal = card.cardVal % 10
                    if shortCardVal ~= 2 and shortCardVal ~= 5 and shortCardVal ~= 8 then 
                        return false
                    end 
                end 
            end 
        end 
    end 
    for _, mingCard in pairs(player.mingCards) do 
        local shortCardVal = mingCard.cardVal % 10
        if not GameCache:isGangCard(mingCard.cardVal) then 
            if shortCardVal ~= 2 and shortCardVal ~= 5 and shortCardVal ~= 8 then 
                return false
            end 
        end 
    end 
    return true
end 

--是否风一色
function GamePlayer:isFengYiSe(extraCardVal)
    local extraCardVal = extraCardVal or 0
    local extraCardType = GameDefine.getCardType(extraCardVal)
    local shortExtraCardVal = extraCardVal % 10

    local player = self
    
    if extraCardType ~= 0 and extraCardType ~= GameDefine.CARD_TYPE_ZI then 
        return false
    end 
    for _, handCards in pairs(player.handCards) do 
        if handCards.cardType ~= GameDefine.CARD_TYPE_ZI and handCards.num > 0 then 
            return false
        end 
    end 
    for _, mingCard in pairs(player.mingCards) do 
        local cardType = GameDefine.getCardType(mingCard.cardVal)
        if not GameCache:isGangCard(mingCard.cardVal) then 
            if cardType ~= GameDefine.CARD_TYPE_ZI then 
                return false
            end 
        end 
    end 
    return true
end 

--是否清一色
function GamePlayer:isQingYiSe(extraCardVal)
    local extraCardVal = extraCardVal or 0
    local extraCardType = GameDefine.getCardType(extraCardVal)
    local shortExtraCardVal = extraCardVal % 10

    local player = self
    
    local typesCnt = 0
    local snglType = 0
    for _, handCards in pairs(player.handCards) do 
        if handCards.cardType == extraCardType or handCards.num > 0 then 
            typesCnt = typesCnt + 1
            snglType = handCards.cardType
        end 
    end 
    if typesCnt > 1 then 
        return false
    end 
    for _, mingCard in pairs(player.mingCards) do 
        local cardType = GameDefine.getCardType(mingCard.cardVal)
        if mingCard.cardVal ~= GameCache.laiZiCardVal and 
            mingCard.cardVal ~= GameCache.hongZhongCardVal and 
            mingCard.cardVal ~= GameCache.laiZiPiCardVal then 
            if cardType ~= snglType then 
                return false
            end 
        end 
    end 
    return true
end 

--是否碰碰胡
function GamePlayer:isPengPengHu(huComps)
    local player = self
    for _, mingCard in pairs(player.mingCards) do 
        local cardType = GameDefine.getCardType(mingCard.cardVal)
        if mingCard.mingType == GameDefine.MING_TYPE_CHI_LEFT or 
            mingCard.mingType == GameDefine.MING_TYPE_CHI_MID or
            mingCard.mingType == GameDefine.MING_TYPE_CHI_RIGHT then
            return false
        end 
    end 
    for _, huComp in ipairs(huComps) do 
        local isPengPeng = true
        for _, comp in ipairs(huComp) do 
            if comp.compType == GameDefine.COMP_TYPE_SHUN then 
                isPengPeng = false
                break
            end 
        end 
        if isPengPeng then 
            return true
        end 
    end 
    return false
end 

--[Comment]
--是否包含杠牌
--PS: 杠牌指赖子皮和红中（赖子虽然可以杠，但是另外计算）
function GamePlayer:containsGangPai(extraCardVal)
    local extraCardVal = extraCardVal or 0
    local extraCardType = GameDefine.getCardType(extraCardVal)
    local shortExtraCardVal = extraCardVal % 10

    local player = self
    
    if extraCardVal == GameCache.laiZiPiCardVal or extraCardVal == GameCache.hongZhongCardVal then 
        return true
    end 
    for _, handCards in pairs(player.handCards) do 
        if handCards.num > 0 then 
            for _, card in ipairs(handCards.cards) do 
                if card.num > 0 and (card.cardVal == GameCache.laiZiPiCardVal or card.cardVal == GameCache.hongZhongCardVal) then 
                    return true
                end 
            end 
        end 
    end 
    return false
end 

function GamePlayer:isPlayerKaiKou()
    local player = self
    for _, mingCard in pairs(player.mingCards) do 
        if mingCard.mingType == GameDefine.MING_TYPE_CHI_LEFT or 
            mingCard.mingType == GameDefine.MING_TYPE_CHI_MID or 
            mingCard.mingType == GameDefine.MING_TYPE_CHI_RIGHT or 
            mingCard.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_PENG or 
            mingCard.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_WATCH or 
            mingCard.mingType == GameDefine.MING_TYPE_PENG then 
            return true
        end 
    end 
    return false
end 

function GamePlayer:getPlayerFansCnt()
    local player = self
    local isKaiKou = false
    local fansCnt = 0
    for _, mingCard in pairs(player.mingCards) do 
        if mingCard.mingType == GameDefine.MING_TYPE_CHI_LEFT or 
            mingCard.mingType == GameDefine.MING_TYPE_CHI_MID or 
            mingCard.mingType == GameDefine.MING_TYPE_CHI_RIGHT or 
            mingCard.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_PENG or 
            mingCard.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_WATCH or 
            mingCard.mingType == GameDefine.MING_TYPE_PENG then 
            isKaiKou = true
            if mingCard.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_PENG or 
                mingCard.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_WATCH then 
                fansCnt = fansCnt + 1
            end 
        elseif mingCard.mingType == GameDefine.MING_TYPE_AN_GANG then 
            fansCnt = fansCnt + 2
        elseif mingCard.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_GANG_PAI then 
            if mingCard.cardVal == GameCache.laiZiCardVal then 
                fansCnt = fansCnt + 2
            elseif mingCard.cardVal == GameCache.laiZiPiCardVal then 
                fansCnt = fansCnt + 1
            elseif mingCard.cardVal == GameCache.hongZhongCardVal then 
                fansCnt = fansCnt + 1
            end 
        end 
    end 
    if isKaiKou then 
        fansCnt = fansCnt + 1
    end 
    return fansCnt
end 

function GamePlayer:getChiGroups(chiCardVal)
    local canBeSelectedGroups = {}
    local tmp = {}
    local cards = {}
    for _, handCards in pairs(self.handCards) do 
        if handCards.num > 0 then 
            for _, card in ipairs(handCards.cards) do 
                if card.num > 0 then 
                    if not self.cache:isGangCard(card.cardVal) and 
                        (card.cardVal == chiCardVal - 1 or 
                        card.cardVal == chiCardVal - 2 or 
                        card.cardVal == chiCardVal + 1 or 
                        card.cardVal == chiCardVal + 2) then
                        tmp[card.cardVal] = card
                    end 
                end 
            end 
        end 
    end
    if not tmp[chiCardVal - 1] then 
        tmp[chiCardVal - 2] = nil
    end 
    if not tmp[chiCardVal + 1] then 
        tmp[chiCardVal + 2] = nil
    end 
    if chiCardVal % 10 == 8 then 
        tmp[chiCardVal + 2] = nil
    end 
    if chiCardVal % 10 == 2 then 
        tmp[chiCardVal - 2] = nil
    end 
    if chiCardVal % 10 == 9 then 
        tmp[chiCardVal + 1] = nil
        tmp[chiCardVal + 2] = nil
    end 
    if chiCardVal % 10 == 1 then 
        tmp[chiCardVal - 1] = nil
        tmp[chiCardVal - 2] = nil
    end 
    for _, card in pairs(tmp) do 
        if card.cardVal == chiCardVal - 2 then 
            local group = {data = nil, cards = {tmp[chiCardVal - 2], tmp[chiCardVal - 1]}}
            table.insert(canBeSelectedGroups, group)
        end 
        if card.cardVal == chiCardVal - 1 and tmp[chiCardVal + 1] then 
            local group = {data = nil, cards = {tmp[chiCardVal - 1], tmp[chiCardVal + 1]}}
            table.insert(canBeSelectedGroups, group)
        end 
        if card.cardVal == chiCardVal + 1 and tmp[chiCardVal + 2] then 
            local group = {data = nil, cards = {tmp[chiCardVal + 1], tmp[chiCardVal + 2]}}
            table.insert(canBeSelectedGroups, group)
        end 
    end 
    assert(#canBeSelectedGroups <= 3)

    return canBeSelectedGroups
end 

return GamePlayer


--endregion
