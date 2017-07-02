--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local testData = {
    weiCardsDistributedCnt = 0,
    watchProgress = 0,
    laiZiPiCardVal = 24,
    baoZiVal = 1,
    TableInfo = 
    {
        TotalPlayedCount = 0,
        createParams = '{"mjType":1,"fengDingMulti":1,"fans":3,"robot":true}',
        RoomGuid = 'b54fee12-56f7-4439-9e2f-52eb99a675e9',
        CreateTime = 1486892678,
        RoomNum = 900101,
        BeginTime = 1486892679,
        PlayerNum = 4,
        Rolls = 8
    },
    agreeDismiss = 
    {
    },
    distributedCardsCnt = 0,
    options = 
    {
    },
    whosTurnChairID = 3,
    enGameStatus = 3,
    roomPlayStartTime = 0,
    records = 
    {
    },
    sysCardVal = 0,
    totalCardsNum = 136,
    fengDingMulti = 1,
    weiCardsNum = 14,
    bTableCreated = true,
    jiePaoUsers = 
    {
    },
    watchQue = 
    {
    },
    hongZhongCardVal = 45,
    actionsQue = 
    {
    },
    baoZi = 0,
    players = 
    {
        [1] = 
        {
            theThird = 0,
            score = 1000,
            userid = 689,
            mingCards = 
            {
            },
            watchOpCnt = 2,
            isTing = false,
            uselessCards = 
            {
            },
            handCards = 
            {
            },
            laisOwned = 0,
            chairID = 1
        },
        [2] = 
        {
            theThird = 0,
            score = 1000,
            userid = 20500,
            mingCards = 
            {
            },
            watchOpCnt = 1,
            isTing = false,
            uselessCards = 
            {
            },
            handCards = 
            {
            },
            laisOwned = 0,
            chairID = 2
        },
        [3] = 
        {
            theThird = 0,
            score = 1000,
            userid = 20499,
            mingCards = 
            {
            },
            watchOpCnt = 1,
            isTing = false,
            uselessCards = 
            {
            },
            handCards = 
            {
            },
            laisOwned = 0,
            chairID = 3
        },
        [4] = 
        {
            theThird = 0,
            score = 1000,
            userid = 20498,
            mingCards = 
            {
            },
            watchOpCnt = 2,
            isTing = false,
            uselessCards = 
            {
            },
            handCards = 
            {
            },
            laisOwned = 0,
            chairID = 4
        }
    },
    fans = 6,
    statistics = 
    {
    },
    laiZiCardVal = 25,
    beiCardVal = 44,
    watchCard = 
    {
    },
    systemCards = 
    {
        [1] = 41,
        [2] = 41,
        [3] = 29,
        [4] = 13,
        [5] = 13,
        [6] = 13,
        [7] = 13,
        [8] = 13,
        [9] = 13,
        [10] = 13,
        [11] = 19,
        [12] = 35,
        [13] = 15,
        [14] = 17,
        [15] = 24,
        [16] = 29,
        [17] = 24,
        [18] = 27,
        [19] = 13,
        [20] = 21,
        [21] = 22,
        [22] = 23,
        [23] = 24,
        [24] = 25,
        [25] = 27,
        [26] = 27,
        [27] = 27,
        [28] = 25,
        [29] = 33,
        [30] = 21,
        [31] = 35,
        [32] = 41,
        [33] = 14,
        [34] = 23,
        [35] = 12,
        [36] = 19,
        [37] = 42,
        [38] = 17,
        [39] = 28,
        [40] = 15,
        [41] = 22,
        [42] = 14,
        [43] = 39,
        [44] = 27,
        [45] = 35,
        [46] = 38,
        [47] = 24,
        [48] = 24,
        [49] = 42,
        [50] = 29,
        [51] = 32,
        [52] = 28,
        [53] = 32,
        [54] = 23,
        [55] = 11,
        [56] = 31,
        [57] = 33,
        [58] = 39,
        [59] = 47,
        [60] = 11,
        [61] = 44,
        [62] = 12,
        [63] = 25,
        [64] = 26,
        [65] = 39,
        [66] = 45,
        [67] = 16,
        [68] = 47,
        [69] = 36,
        [70] = 45,
        [71] = 38,
        [72] = 13,
        [73] = 44,
        [74] = 12,
        [75] = 41,
        [76] = 17,
        [77] = 37,
        [78] = 45,
        [79] = 25,
        [80] = 46,
        [81] = 46,
        [82] = 14,
        [83] = 16,
        [84] = 46,
        [85] = 18,
        [86] = 21,
        [87] = 37,
        [88] = 34,
        [89] = 18,
        [90] = 27,
        [91] = 32,
        [92] = 23,
        [93] = 33,
        [94] = 46,
        [95] = 23,
        [96] = 34,
        [97] = 41,
        [98] = 45,
        [99] = 18,
        [100] = 38,
        [101] = 27,
        [102] = 36,
        [103] = 25,
        [104] = 31,
        [105] = 26,
        [106] = 13,
        [107] = 42,
        [108] = 19,
        [109] = 16,
        [110] = 31,
        [111] = 38,
        [112] = 15,
        [113] = 41,
        [114] = 21,
        [115] = 44,
        [116] = 13,
        [117] = 13,
        [118] = 23,
        [119] = 13,
        [120] = 13,
        [121] = 13,
        [122] = 13,
        [123] = 12,
        [124] = 13,
        [125] = 37,
        [126] = 42,
        [127] = 21,
        [128] = 16,
        [129] = 22,
        [130] = 32,
        [131] = 18,
        [132] = 29,
        [133] = 34,
        [134] = 47,
        [135] = 22,
        [136] = 34
    },
    wTableID = 1,
    wChairCount = 4,
    zhuangID = 689
}

--清一色
local players = {
    [1] = {
        handCards = {26,26,26,11,11,11,12,12,12,29},
        mingCards = {
            [1] = {cardVal = 39, mingType = 6, subMingType = 0},
            [2] = {cardVal = 32, mingType = 6, subMingType = 0},
            [3] = {cardVal = 27, mingType = 6, subMingType = 0},
            [4] = {cardVal = 24, mingType = 4, subMingType = 43},
        },
        uselessCards = {},
    },
    [2] = {
        handCards = {26,26,26,11,11,11,12,12,12,29},
        mingCards = {
            [1] = {cardVal = 25, mingType = 4, subMingType = 43},
            [2] = {cardVal = 45, mingType = 4, subMingType = 43},
        },
        uselessCards = {},
    },
    [3] = {
        handCards = {26,26,26,11,11,11,12,12,12,29},
        mingCards = {
            [1] = {cardVal = 24, mingType = 4, subMingType = 43},
            [2] = {cardVal = 45, mingType = 4, subMingType = 43},
            [3] = {cardVal = 25, mingType = 4, subMingType = 43},
            [4] = {cardVal = 25, mingType = 4, subMingType = 43},
        },
        uselessCards = {},
    },
    [4] = {
        handCards = {26,26,26,11,11,11,12,12,12,29},
        mingCards = {
            [1] = {cardVal = 26, mingType = 6, subMingType = 0},
            [2] = {cardVal = 31, mingType = 1, subMingType = 0},
            [3] = {cardVal = 24, mingType = 4, subMingType = 43},
            [4] = {cardVal = 45, mingType = 4, subMingType = 43},
        },
        uselessCards = {},
    },
}
for chairID, rollPlayerData in pairs(players) do 
    local player = testData.players[chairID]
    player.handCards = {}
    local tmp = {}
    for _, cardVal in ipairs(rollPlayerData.handCards) do 
        local cardType = math.floor(cardVal / 10)
        tmp[cardVal] = tmp[cardVal] or {cardVal = cardVal, cardType = cardType, num = 0}
        tmp[cardVal].num = tmp[cardVal].num + 1
    end 
    for cardVal, card in pairs(tmp) do 
        if cardVal == testData.laiZiCardVal then 
            player.laisOwned = player.laisOwned + card.num
        else 
            local cardType = math.floor(cardVal / 10)
            player.handCards[cardType] = player.handCards[cardType] or {cardType = cardType, num = 0, cards = {}}
            player.handCards[cardType].num = player.handCards[cardType].num + card.num
            table.insert(player.handCards[cardType].cards, card)
        end 
    end 
    for cardType, cardsNode in pairs(player.handCards)do 
        table.sort(cardsNode.cards, function(card1, card2)
            return card1.cardVal < card2.cardVal
        end)
    end 
    player.mingCards = {}
    for _, mingCard in ipairs(rollPlayerData.mingCards) do 
        table.insert(player.mingCards, {cardVal = mingCard.cardVal, mingType = mingCard.mingType, subMingType = mingCard.subMingType})
    end 
    player.uselessCards = {}
    for _, cardVal in ipairs(rollPlayerData.uselessCards) do 
        table.insert(player.uselessCards, cardVal)
    end 
end 

return testData
--endregion
