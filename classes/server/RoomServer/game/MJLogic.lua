--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--算法介绍地址：http://www.xuebuyuan.com/1048915.html
local MJLogic = {}

local GameDefine = require("lua.RoomServer.game.GameDefine")

--[Comment]
--分子赖子牌的胡牌牌型
--snglTypeCardsAry: 单一类型的手牌按照牌的值升序的数组
--cardType: 手牌数组的牌类型
--cardsComps = {
--                {compType = ?, cards = {cardVal, ...}, needLais = {cardVal, ...}},
--                ...
--            }
--container: 每一种可胡牌牌型的数组，{{cardsComps = cardsComps, laisRemain = ?}, ...}
--needLaiNum: 当前所需要的赖子牌的数目
--laisOwned: 当前所拥有的赖子牌数目
function MJLogic.analyseKeShun(snglTypeCardsAry, cardType, cardsComps, container, laisOwned)
    local toEnd = true
    local i = 1
    local len = #snglTypeCardsAry
    for i = 1, len, 1 do 
        local card = snglTypeCardsAry[i]
        local shortCardVal = card.cardVal % 10
        if card.num > 0 then 
            toEnd = false
            ------------------KE-----------------
            --A, x, x
            if laisOwned >= 2 then 
                card.num = card.num - 1
                laisOwned = laisOwned - 2
                local comp = {compType = GameDefine.COMP_TYPE_KE,
                                cards = {card.cardVal, card.cardVal, card.cardVal},
                                needLais = {card.cardVal, card.cardVal},}
                table.insert(cardsComps, comp)
                MJLogic.analyseKeShun(snglTypeCardsAry, cardType, cardsComps, container, laisOwned)
                --recovery
                card.num = card.num + 1
                laisOwned = laisOwned + 2
                cardsComps[#cardsComps] = nil
            end 
            --A, A, x
            if card.num >= 2 and laisOwned >= 1 then 
                card.num = card.num - 2
                laisOwned = laisOwned - 1
                local comp = {compType = GameDefine.COMP_TYPE_KE,
                                cards = {card.cardVal, card.cardVal, card.cardVal},
                                needLais = {card.cardVal},}
                table.insert(cardsComps, comp)
                MJLogic.analyseKeShun(snglTypeCardsAry, cardType, cardsComps, container, laisOwned)
                --recovery
                card.num = card.num + 2
                laisOwned = laisOwned + 1
                cardsComps[#cardsComps] = nil
            end 
            --A, A, A
            if card.num >= 3 then 
                card.num = card.num - 3
                laisOwned = laisOwned - 0
                local comp = {compType = GameDefine.COMP_TYPE_KE,
                                cards = {card.cardVal, card.cardVal, card.cardVal},
                                needLais = {},}
                table.insert(cardsComps, comp)
                MJLogic.analyseKeShun(snglTypeCardsAry, cardType, cardsComps, container, laisOwned)
                --recovery
                card.num = card.num + 3
                laisOwned = laisOwned + 0
                cardsComps[#cardsComps] = nil
            end 
            ------------------SHUN-----------------
            if cardType ~= GameDefine.CARD_TYPE_ZI and cardType ~= GameDefine.CARD_TYPE_HUA then 
                --A, B, x
                if shortCardVal <= 7 and laisOwned >= 1 then 
                    if snglTypeCardsAry[i + 1] and snglTypeCardsAry[i + 1].num > 0 and snglTypeCardsAry[i + 1].cardVal - 1 == card.cardVal then 
                        card.num = card.num - 1
                        snglTypeCardsAry[i + 1].num = snglTypeCardsAry[i + 1].num - 1
                        laisOwned = laisOwned - 1
                        local comp = {compType = GameDefine.COMP_TYPE_SHUN,
                                        cards = {card.cardVal, card.cardVal + 1, card.cardVal + 2},
                                        needLais = {card.cardVal + 2},}
                        table.insert(cardsComps, comp)
                        MJLogic.analyseKeShun(snglTypeCardsAry, cardType, cardsComps, container, laisOwned)
                        --recovery
                        card.num = card.num + 1
                        snglTypeCardsAry[i + 1].num = snglTypeCardsAry[i + 1].num + 1
                        laisOwned = laisOwned + 1
                        cardsComps[#cardsComps] = nil
                    end 
                end 
                --A, x, B
                if shortCardVal <= 7 and laisOwned >= 1 then 
                    if snglTypeCardsAry[i + 1] and snglTypeCardsAry[i + 1].num > 0 and snglTypeCardsAry[i + 1].cardVal - 2 == card.cardVal then 
                        card.num = card.num - 1
                        snglTypeCardsAry[i + 1].num = snglTypeCardsAry[i + 1].num - 1
                        laisOwned = laisOwned - 1
                        local comp = {compType = GameDefine.COMP_TYPE_SHUN,
                                        cards = {card.cardVal, card.cardVal + 1, card.cardVal + 2},
                                        needLais = {card.cardVal + 1},}
                        table.insert(cardsComps, comp)
                        MJLogic.analyseKeShun(snglTypeCardsAry, cardType, cardsComps, container, laisOwned)
                        --recovery
                        card.num = card.num + 1
                        snglTypeCardsAry[i + 1].num = snglTypeCardsAry[i + 1].num + 1
                        laisOwned = laisOwned + 1
                        cardsComps[#cardsComps] = nil
                    elseif snglTypeCardsAry[i + 2] and snglTypeCardsAry[i + 2].num > 0 and snglTypeCardsAry[i + 2].cardVal - 2 == card.cardVal then 
                        card.num = card.num - 1
                        snglTypeCardsAry[i + 2].num = snglTypeCardsAry[i + 2].num - 1
                        laisOwned = laisOwned - 1
                        local comp = {compType = GameDefine.COMP_TYPE_SHUN,
                                        cards = {card.cardVal, card.cardVal + 1, card.cardVal + 2},
                                        needLais = {card.cardVal + 1},}
                        table.insert(cardsComps, comp)
                        MJLogic.analyseKeShun(snglTypeCardsAry, cardType, cardsComps, container, laisOwned)
                        --recovery
                        card.num = card.num + 1
                        snglTypeCardsAry[i + 2].num = snglTypeCardsAry[i + 2].num + 1
                        laisOwned = laisOwned + 1
                        cardsComps[#cardsComps] = nil
                    end 
                end 
                --x, A, B
                if shortCardVal >= 2 and shortCardVal <= 8 and laisOwned >= 1 then 
                    if snglTypeCardsAry[i + 1] and snglTypeCardsAry[i + 1].num > 0 and snglTypeCardsAry[i + 1].cardVal - 1 == card.cardVal then 
                        card.num = card.num - 1
                        snglTypeCardsAry[i + 1].num = snglTypeCardsAry[i + 1].num - 1
                        laisOwned = laisOwned - 1
                        local comp = {compType = GameDefine.COMP_TYPE_SHUN,
                                        cards = {card.cardVal - 1, card.cardVal, card.cardVal + 1},
                                        needLais = {card.cardVal - 1},}
                        table.insert(cardsComps, comp)
                        MJLogic.analyseKeShun(snglTypeCardsAry, cardType, cardsComps, container, laisOwned)
                        --recovery
                        card.num = card.num + 1
                        snglTypeCardsAry[i + 1].num = snglTypeCardsAry[i + 1].num + 1
                        laisOwned = laisOwned + 1
                        cardsComps[#cardsComps] = nil
                    end 
                end 
                --A, B, C
                if shortCardVal <= 7 then 
                    if snglTypeCardsAry[i + 1] and snglTypeCardsAry[i + 1].num > 0 and snglTypeCardsAry[i + 1].cardVal - 1 == card.cardVal and
                        snglTypeCardsAry[i + 2] and snglTypeCardsAry[i + 2].num > 0 and snglTypeCardsAry[i + 2].cardVal - 2 == card.cardVal then 
                        card.num = card.num - 1
                        snglTypeCardsAry[i + 1].num = snglTypeCardsAry[i + 1].num - 1
                        snglTypeCardsAry[i + 2].num = snglTypeCardsAry[i + 2].num - 1
                        laisOwned = laisOwned - 0
                        local comp = {compType = GameDefine.COMP_TYPE_SHUN,
                                        cards = {card.cardVal, card.cardVal + 1, card.cardVal + 2},
                                        needLais = {},}
                        table.insert(cardsComps, comp)
                        MJLogic.analyseKeShun(snglTypeCardsAry, cardType, cardsComps, container, laisOwned)
                        --recovery
                        card.num = card.num + 1
                        snglTypeCardsAry[i + 1].num = snglTypeCardsAry[i + 1].num + 1
                        snglTypeCardsAry[i + 2].num = snglTypeCardsAry[i + 2].num + 1
                        laisOwned = laisOwned + 0
                        cardsComps[#cardsComps] = nil
                    end 
                end 
            end 
        end 
    end 
    if toEnd and #cardsComps > 0 then 
        table.insert(container, {cardsComps = table.clone(cardsComps), laisRemain = laisOwned})
    end 
end 

--[Comment]
--判断是否能够胡牌
--player = {
--    handCards = {[cardType] = {cardType = ?, num = ?, cards = {{cardVal = ?, num = ?}, ...}}, ...},
--    mingCards = {{mingType = ?, subMingType = ?, cardVal = ?}, ...},
--    uselessCards = {cardVal, ...},
--    laisOwned = ?,
--}
--extraCardVal: 额外加入到手牌的牌值
--extraCardType: 额外加入到手牌的牌类型
--@ret: 
--      result: true if success)
--      huComps: 每种胡牌的牌型组合
--              {huCompContainer, ...}
--              关于huCompContainer等同于analyseKeShun的参数container，结构详见analyseKeShun函数说明
function MJLogic.canHu(player, extraCardVal, extraCardType)
    local backup = nil 
    if extraCardVal and extraCardVal ~= 0 and extraCardType then 
        player.handCards[extraCardType] = player.handCards[extraCardType] or {cardType = extraCardType, num = 0, cards = {}}
        local cardsTbl = player.handCards[extraCardType]
--        if not cardsTbl or cardsTbl.num < 1 then 
--            return false
--        end 
        backup = {cardsTbl = cardsTbl, ndx = 0, card = nil}
        for i, card in ipairs(cardsTbl.cards) do 
--            table.insert(backup, card)
            if card.cardVal == extraCardVal then 
                cardsTbl.num = cardsTbl.num + 1
                card.num = card.num + 1
                backup.ndx = i
                backup.card = card
            end 
        end 
        if backup.ndx == 0 then --need insert
            cardsTbl.num = cardsTbl.num + 1
            backup.card = {cardVal = extraCardVal, num = 1}
            backup.ndx = table.insert_sort(cardsTbl.cards, backup.card, function(old, new)
                return new.cardVal < old.cardVal
            end)
        end 
    end 
    local recov = function()
        if not backup then 
            return 
        end 
        backup.card.num = backup.card.num - 1
        backup.cardsTbl.num = backup.cardsTbl.num - 1
    end
    local laisOwned = player.laisOwned
    local handCardsComps = {}
    --手牌分析
    local huComps = {}
    local playerHandCards = {}
    for _, handCards in pairs(player.handCards) do 
        table.insert(playerHandCards, handCards)
    end 

    local function __canHu(handCardsNdx, cardsComps, remainLaisNum)
        local handCards = playerHandCards[handCardsNdx]
        if not handCards then --the end
            if remainLaisNum == 0 then 
                table.insert(huComps, table.clone(cardsComps))
            end 
            return
        end 
        if handCards.num == 0 then 
            __canHu(handCardsNdx + 1, cardsComps, remainLaisNum)
            return
        end 
        local tmpContainer = {}
        local tmpComps = {}
        MJLogic.analyseKeShun(handCards.cards, handCards.cardType, tmpComps, tmpContainer, remainLaisNum)
        if #tmpContainer == 0 then 
            return
        end 
        for _, huComp in ipairs(tmpContainer) do 
            local compsLen = #huComp.cardsComps
            for _, comp in ipairs(huComp.cardsComps) do 
                table.insert(cardsComps, comp)
            end 
            __canHu(handCardsNdx + 1, cardsComps, huComp.laisRemain)
            --recovery
            for i = 1, compsLen, 1 do 
                cardsComps[#cardsComps] = nil
            end 
        end 
    end 

    for _, handCards in ipairs(playerHandCards) do
        local cardType = handCards.cardType
        if handCards.num > 0 then 
            --从原有的牌中抽出两张相同的牌作为将牌
            for _, card in ipairs(handCards.cards) do 
                if card.num >= 2 then 
                    local cardsComps = {}
                    card.num = card.num - 2
                    handCards.num = handCards.num - 2
                    local comp = {compType = GameDefine.COMP_TYPE_JIANG,
                                    cards = {card.cardVal, card.cardVal},
                                    needLais = {},}
                    table.insert(cardsComps, comp)
                    __canHu(1, cardsComps, laisOwned)
                    card.num = card.num + 2
                    handCards.num = handCards.num + 2
                end 
            end 
            --从原有的牌中抽出一张然后和一张赖子牌组合成为将牌
            if laisOwned > 0 then 
                for _, card in ipairs(handCards.cards) do 
                    if card.num >= 1 then 
    --                    local container = {}
                        local cardsComps = {}
                        card.num = card.num - 1
                        laisOwned = laisOwned - 1
                        handCards.num = handCards.num - 1
                        local comp = {compType = GameDefine.COMP_TYPE_JIANG,
                                        cards = {card.cardVal, card.cardVal},
                                        needLais = {card.cardVal},}
                        table.insert(cardsComps, comp)
                        __canHu(1, cardsComps, laisOwned)
                        card.num = card.num + 1
                        laisOwned = laisOwned + 1
                        handCards.num = handCards.num + 1
                    end 
                end 
            end 
        end 
    end 
    recov()
    return #huComps > 0, huComps
end

--[Comment]
--获取牌中的一个杠牌
--allCards: {
--                [cardType] = {
--                                cardType = ?, 
--                                num = ?, 
--                                cards = {{cardVal = ?, num = ?}, ...} --一个根据牌的值排序的有序数组
--                            }
--            }
--cardVal: 需要杠的牌值
--cardType: 需要杠的牌类型
--excludeCards: 暗杠中需要排除的牌数组
function MJLogic.getAnGang(allCards, cardVal, cardType, excludeCards)
    excludeCards = excludeCards or {}
    local tmpExcludeCards = {}
    for _, cardVal in pairs(excludeCards) do 
        tmpExcludeCards[cardVal] = true
    end 
    if cardVal and cardVal ~= 0 and cardType and cardType ~= 0 then 
        if tmpExcludeCards[cardVal] then 
            return nil
        end 
        local snglTypeCards = allCards[cardType]
        for _, card in ipairs(snglTypeCards.cards or {}) do 
            if card.cardVal == cardVal then 
                if card.num == 4 then 
                    return {cardVal = card.cardVal, cardType = snglTypeCards.cardType}
                end 
            end 
        end 
        return nil
    else 
        for _, snglTypeCards in pairs(allCards) do 
            for _, card in ipairs(snglTypeCards.cards) do 
                if card.num == 4 and not tmpExcludeCards[card.cardVal] then 
                    return {cardVal = card.cardVal, cardType = snglTypeCards.cardType}
                end 
            end 
        end 
        return nil
    end 
end 

--[Comment]
--是否明杠牌
--allCards: {
--                [cardType] = {
--                                cardType = ?, 
--                                num = ?, 
--                                cards = {{cardVal = ?, num = ?}, ...} --一个根据牌的值排序的有序数组
--                            }
--            }
--cardVal: 需要杠的牌值
--cardType: 需要杠的牌类型
function MJLogic.canMingGang(allCards, cardVal, cardType)
    local snglTypeCards = allCards[cardType]
    if not snglTypeCards then 
        return false
    end 
    for _, card in ipairs(snglTypeCards.cards) do 
        if card.cardVal == cardVal then 
            if card.num ~= 3 then 
                return false
            else 
                return true
            end 
        end 
    end 
    return false
end 

--[Comment]
--是否碰牌
--allCards: {
--                [cardType] = {
--                                cardType = ?, 
--                                num = ?, 
--                                cards = {{cardVal = ?, num = ?}, ...} --一个根据牌的值排序的有序数组
--                            }
--            }
--cardVal: 需要碰的牌值
--cardType: 需要碰的牌类型
function MJLogic.canPeng(allCards, cardVal, cardType)
    local snglTypeCards = allCards[cardType]
    if not snglTypeCards then 
        return false
    end 
    for _, card in ipairs(snglTypeCards.cards) do 
        if card.cardVal == cardVal then 
            if card.num >= 2 and card.num < 4 then 
                return true
            else 
                return false
            end 
        end 
    end 
    return false
end 

--[Comment]
--是否吃牌
--allCards: {
--                [cardType] = {
--                                cardType = ?, 
--                                num = ?, 
--                                cards = {{cardVal = ?, num = ?}, ...} --一个根据牌的值排序的有序数组
--                            }
--            }
--cardVal: 需要吃的牌值
--cardType: 需要吃的牌类型
function MJLogic.canChi(allCards, cardVal, cardType, excludeCards)
    excludeCards = excludeCards or {}
    local tmpExcludeCards = {}
    for _, cardVal in pairs(excludeCards) do 
        tmpExcludeCards[cardVal] = true
    end 

    local snglTypeCards = allCards[cardType]
    if not snglTypeCards then 
        return false
    end 
    local cards = {}
    for _, card in ipairs(snglTypeCards.cards) do 
        cards[card.cardVal] = card
    end 
    if (not tmpExcludeCards[cardVal - 1] and not tmpExcludeCards[cardVal - 2] and cards[cardVal - 1] and cards[cardVal - 1].num > 0 and cards[cardVal - 2] and cards[cardVal - 2].num > 0) or 
        (not tmpExcludeCards[cardVal + 1] and not tmpExcludeCards[cardVal + 2] and cards[cardVal + 1] and cards[cardVal + 1].num > 0 and cards[cardVal + 2] and cards[cardVal + 2].num > 0) or 
        (not tmpExcludeCards[cardVal - 1] and not tmpExcludeCards[cardVal + 1] and cards[cardVal - 1] and cards[cardVal - 1].num > 0 and cards[cardVal + 1] and cards[cardVal + 1].num > 0) then 
        return true
    end
    return false
end 

return MJLogic
--endregion
