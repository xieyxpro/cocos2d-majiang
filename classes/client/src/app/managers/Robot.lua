--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local Robot = class("Robot")

local GameDefine = require("app.modules.game.GameDefine")

function Robot:ctor()
    self.cards = {}
    self.distributedCards = 0
    self.cardsNum = 0
end 

function Robot:newRoll(rollType)
    self.cards = {}
    self.distributedCards = 0

    local tmp = {}
    --setup cards
    for _, id in pairs(GameDefine.CardTypes) do 
        for j = 1, 9, 1 do 
            local cardVal = i * 10 + j
            table.insert(tmp, cardVal)
            table.insert(tmp, cardVal)
            table.insert(tmp, cardVal)
            table.insert(tmp, cardVal)
        end 
    end 
    --shuffle
    local cardStart = 1
    local cardEnd = table.maxn(tmp)
    for i = 1, table.maxn(tmp), 1 do 
        local idx = math.random(cardStart, cardEnd + 1)
        table.insert(self.cards, tmp[idx])
        tmp[idx], tmp[cardEnd] = tmp[cardEnd], tmp[idx]
        cardEnd = cardEnd - 1
    end 

    self.cardsNum = table.maxn(self.cards)
end 

function Robot:distributePlayerCards(isZhuangJia)
    local cards = {}
    local cardsNum = 13
    if isZhuangJia then 
        cardsNum = 14
    end 
    for i = 1, cardsNum, 1 do 
        self.distributedCards = self.distributedCards + 1
        table.insert(cards, self.cards[self.distributedCards])
    end 
    return cards
end

function Robot:distributeSingleCard()
    self.distributedCards = self.distributedCards + 1
    return self.cards[self.distributedCards]
end 

function Robot:isOver()
    return self.distributedCards >= self.cardsNum
end 


return Robot
--endregion
