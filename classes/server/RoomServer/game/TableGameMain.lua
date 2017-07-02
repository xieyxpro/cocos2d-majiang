--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local GameDefine = require("lua.RoomServer.game.GameDefine")
local MJLogic = require("lua.RoomServer.game.MJLogic")
require("lua.Commonlua.json.json")


TableGameMain = Util:newClass({}, TableFrame)

function TableGameMain:InitTable()
    self:reset()
end

--复位桌子
function TableGameMain:RepositionTable()
    self:reset()
end

function TableGameMain:reset()
    self.roomInited = false
    self.hongZhongCardVal = GameDefine.CARD_TYPE_ZI * 10 + 5 --红中
    self.beiCardVal = GameDefine.CARD_TYPE_ZI * 10 + 4 --北风
    self.weiCardsNum = 14 --尾墩牌尾14张
    self.options = {}
    self.config = {
        autoOutCard = false
    }

    self.zhuangID = 0     --庄家
    self.systemCards = {}
    self.distributedCardsCnt = 0
    self.totalCardsNum = 0
    self.laiZiCardVal = 0 --赖子
    self.laiZiPiCardVal = 0 --赖子皮
    self.weiCardsDistributedCnt = 0 --尾墩派牌计数
    self.baoZi = 0 --豹子
    self.shaiZi1Val = 0 --色子1的点数
    self.shaiZi2Val = 0 --色子2的点数
    self.fans = 0 --起胡番数
    self.fengDingMulti = 0 --封顶倍数
    --[[
    player = {
        userid = ?,
        chairID = ?,
        watchOpCnt = 0, --看牌操作计数（为TheThird服务）
        laisOwned = ?, --玩家所拥有的赖子牌数量
        isTing = false, --玩家是否听牌模式
        theThird = 0, --第三个被此玩家吃碰杠的玩家座位ID
        handCards = {}, --手牌, {{cardType = ?, num = ?, cards = {{cardVal = ?, num = ?}, ...}},...}
        mingCards = {},--明牌 {{cardVal = ?, mingType = ?, subMingType = ?}, ...}
        uselessCards = {},--已经打出去且没有被别人吃碰杠走的牌{cardVal1, cardVal2, ...}
        score = 0, --积分
        isDelegate = false, --是否托管
    }
    --]]
    self.players = {} --{[chairID] = player, ...}
    self.whosTurnChairID = 0
    self.waitingActions = {} --等待完成的动作
    self.waitingStartTime = 0 --等待开始时间
    self.sysCardVal = 0
    self.watchCard = {chairID = 0, cardVal = 0}
    self.watchQue = {} --听牌队列{chairID, chairID, ...},顺序将按照听牌优先级：胡，碰或者杠，吃
    self.watchProgress = 0 --听牌的进度
    self.jiePaoUsers = {} --接炮方 {{chairID = ?}, ...}
    self.actionsQue = {} --操作队列 {{chairID = ?, act = ?, data = {?}}, ...}
    self.gameResult = nil --牌局结果

    self.statistics = {} --统计每一局的输赢得分结果
    --[[
    牌局记录
    {
        zhuangChairID = 0,
        laiZiCardVal = 0,
        laiZiPiCardVal = 0,
        players = {
            [chairID] = {userid = ?, chairID = ?, score = ?, handCards = {}},...
        },
        actionQue = {},
        startTime = 0,
        roomID = 0,
        result = 0, --牌局结果
        scoreTypes = {}, --得分类型
    }
    --]]
    self.records = {} --牌局记录
end 

function TableGameMain:containsCard(chairid, cardVal, num)
    local player = self.players[chairid]
    local cardType = math.floor(cardVal / 10)
    if not player.handCards[cardType] then 
        return false
    end 
    for _, v in ipairs(player.handCards[cardType].cards or {}) do 
        if v.cardVal == cardVal then
            return v.num >= num
        end 
    end 
    return false
end 

function TableGameMain:__inputCard(chairid, cardVal)
    local player = self.players[chairid]
    local cardType = GameDefine.getCardType(cardVal)
    player.handCards[cardType] = player.handCards[cardType] or {cardType = cardType, num = 0, cards = {}}
    --find card
    local card = nil
    for _, v in ipairs(player.handCards[cardType].cards) do 
        if v.cardVal == cardVal then
            card = v
        end 
    end 
    --insert or update
    if card then 
        card.num = card.num + 1
    else 
        table.insert_sort(player.handCards[cardType].cards, {cardVal = cardVal, cardType = cardType, num = 1}, function(card1, card2)
            return card2.cardVal < card1.cardVal
        end)
    end 
    player.handCards[cardType].num = player.handCards[cardType].num + 1
    return true
end 

function TableGameMain:__outputCard(chairid, cardVal, num)
    local player = self.players[chairid]
    local cardType = GameDefine.getCardType(cardVal)
    local card = nil
    for _, v in ipairs(player.handCards[cardType].cards) do 
        if v.cardVal == cardVal then
            card = v
            break
        end 
    end 
    assert(card)
    assert(card.num >= num)
    card.num = card.num - num
    player.handCards[cardType].num = player.handCards[cardType].num - num
    return true
end 

--玩家是否可主动杠(不包括杠牌)
function TableGameMain:__canPlayerInitiativeGang(chairID) 
    local player = self.players[chairID]
    local gangs = {}
    for _, mingCard in ipairs(player.mingCards) do 
        if mingCard.mingType == GameDefine.MING_TYPE_PENG then 
            --search an available card
            local mingCardType = GameDefine.getCardType(mingCard.cardVal)
            if player.handCards[mingCardType] then 
                for _, card in pairs(player.handCards[mingCardType].cards) do 
                    if card.num == 1 and card.cardVal == mingCard.cardVal then 
                        local gang = {
                            cardVal = card.cardVal, 
                            mingType = GameDefine.MING_TYPE_MING_GANG,
                            subMingType = GameDefine.MING_TYPE_MING_GANG_SUB_PENG,
                        }
                        return true
                    end 
                end 
            end 
        end 
    end 
    for _, snglTypeHandCards in pairs(player.handCards) do 
        if snglTypeHandCards.num > 0 then 
            for _, card in ipairs(snglTypeHandCards.cards) do 
                if (not self:__isGangCard(card.cardVal)) and card.num == 4 then 
                    return true
                end 
            end 
        end 
    end 
    return false
end 

function TableGameMain:__isPlayerKaiKou(chairid)
    local player = self.players[chairid]
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

function TableGameMain:__getPlayerFansCnt(chairid)
    local player = self.players[chairid]
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
            if mingCard.cardVal == self.laiZiCardVal then 
                fansCnt = fansCnt + 2
            elseif mingCard.cardVal == self.laiZiPiCardVal then 
                fansCnt = fansCnt + 1
            elseif mingCard.cardVal == self.hongZhongCardVal then 
                fansCnt = fansCnt + 1
            end 
        end 
    end 
    if isKaiKou then 
        fansCnt = fansCnt + 1
    end 
    return fansCnt
end 

function TableGameMain:__isGangCard(cardVal)
    if cardVal == self.laiZiCardVal or 
        cardVal == self.laiZiPiCardVal or 
        cardVal == self.hongZhongCardVal then 
        return true 
    end 
    return false
end 

function TableGameMain:__resetWatch()
    self.watchQue = {}
    self.watchProgress = 0
    self.watchCard = {cardVal = 0, chairID = 0}
end 

--是否将一色
function TableGameMain:__isJiangYiSe(chairid, extraCardVal)
    local extraCardVal = extraCardVal or 0
    local extraCardType = GameDefine.getCardType(extraCardVal)
    local shortExtraCardVal = extraCardVal % 10

    local player = self.players[chairid]

    local isJiangYiSe = true
    if extraCardVal ~= 0 and shortExtraCardVal ~= 2 and shortExtraCardVal ~= 5 and shortExtraCardVal ~= 8 then 
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
        if not self:__isGangCard(mingCard.cardVal) then 
            if shortCardVal ~= 2 and shortCardVal ~= 5 and shortCardVal ~= 8 then 
                return false
            end 
        end 
    end 
    return true
end 

--是否风一色
function TableGameMain:__isFengYiSe(chairid, extraCardVal)
    local extraCardVal = extraCardVal or 0
    local extraCardType = GameDefine.getCardType(extraCardVal)
    local shortExtraCardVal = extraCardVal % 10

    local player = self.players[chairid]
    
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
        if not self:__isGangCard(mingCard.cardVal) then 
            if cardType ~= GameDefine.CARD_TYPE_ZI then 
                return false
            end 
        end 
    end 
    return true
end 

--是否清一色
function TableGameMain:__isQingYiSe(chairid, extraCardVal)
    local extraCardVal = extraCardVal or 0
    local extraCardType = GameDefine.getCardType(extraCardVal)
    local shortExtraCardVal = extraCardVal % 10

    local player = self.players[chairid]
    
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
        if mingCard.cardVal ~= self.laiZiCardVal and 
            mingCard.cardVal ~= self.hongZhongCardVal and 
            mingCard.cardVal ~= self.laiZiPiCardVal then 
            if cardType ~= snglType then 
                return false
            end 
        end 
    end 
    return true
end 

--是否碰碰胡
function TableGameMain:__isPengPengHu(player, huComps)
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
function TableGameMain:__containsGangPai(chairid, extraCardVal)
    local extraCardVal = extraCardVal or 0
    local extraCardType = GameDefine.getCardType(extraCardVal)
    local shortExtraCardVal = extraCardVal % 10

    local player = self.players[chairid]
    
    if extraCardVal == self.laiZiPiCardVal or extraCardVal == self.hongZhongCardVal then 
        return true
    end 
    for _, handCards in pairs(player.handCards) do 
        if handCards.num > 0 then 
            for _, card in ipairs(handCards.cards) do 
                if card.num > 0 and (card.cardVal == self.laiZiPiCardVal or card.cardVal == self.hongZhongCardVal) then 
                    return true
                end 
            end 
        end 
    end 
    return false
end 

--[Comment]
--初始化赖子牌以及赖子皮
function TableGameMain:__iniLai(cardVal)
    local cardType = GameDefine.getCardType(cardVal)
    if cardType == GameDefine.CARD_TYPE_ZI then 
        if cardVal == self.hongZhongCardVal or cardVal == self.beiCardVal then 
            self.laiZiCardVal = self.hongZhongCardVal + 1 --发财
            self.laiZiPiCardVal = self.beiCardVal
        else 
            self.laiZiPiCardVal = cardVal
            local shortCardVal = (cardVal % 10)
            self.laiZiCardVal = shortCardVal == 7 and (cardType * 10 + 1) or (cardVal + 1)
        end 
    else
        self.laiZiPiCardVal = cardVal
        local shortCardVal = (cardVal % 10)
        self.laiZiCardVal = shortCardVal == 9 and (cardType * 10 + 1) or (cardVal + 1)
    end 
end 

--是否胡牌并且分析胡牌的组合
function TableGameMain:__analyseHu(chairid)
    local player = self.players[chairid]

    local ret = {
        success = false,
        chairID = chairid,
        userid = player.userid,
        huType = 0,
        huCardVal = 0,
        huData = {}, --点炮胡：{outCardVal = ?, outChairID = ?}, 抢杠胡：{gangCardVal = ?, gangChairID = ?}
        isJiangYiSe = false,
        isFengYiSe = false,
        isQingYiSe = false,
        isPengPengHu = false,
        isGangKai = false,
        isQuanQiuRen = false,
        isHaiDiLao = false,
        isYingHu = false, 
        isQiangGang = false,
    }

    local function retProc()
        ret.success = ret.success or 
                        ret.isJiangYiSe or 
                        ret.isFengYiSe or 
                        ret.isQingYiSe or 
                        ret.isPengPengHu
        return ret
    end 

    local extraCardVal = 0
    theOtherChairID = theOtherChairID or 0
    
    local result = nil 
    if self:isInWatchMode() then 
        local curWatch = self:currentHuWatch()
        if curWatch and curWatch.action == GameDefine.PLAY_ACT_HU then 
            if curWatch.huType == GameDefine.HU_TYPE_DIAN_PAO then 
                theOtherChairID = curWatch.outChairID
                ret.huType = curWatch.huType
                ret.huData = {
                    outCardVal = curWatch.outCardVal,
                    outChairID = curWatch.outChairID,
                }
                ret.huCardVal = curWatch.outCardVal
                extraCardVal = curWatch.outCardVal
            elseif curWatch.huType == GameDefine.HU_TYPE_QIANG_GANG then 
                theOtherChairID = curWatch.gangChairID
                ret.huType = curWatch.huType
                ret.huData = {
                    gangCardVal = curWatch.gangCardVal,
                    gangChairID = curWatch.gangChairID,
                }
                ret.huCardVal = curWatch.gangCardVal
                extraCardVal = curWatch.gangCardVal
                ret.isQiangGang = true
            elseif curWatch.huType == GameDefine.HU_TYPE_HAI_DI_LAO then 
                ret.huType = curWatch.huType
                ret.huCardVal = curWatch.huCardVal
            else
                logErrf("[userid: %d] other type of HU %d is not available", player.userid, curWatch.huType)
                return retProc()
            end 
        else 
            logErrf("[userid: %d] no hu action detected", player.userid)
            return retProc()
        end 
    else 
        ret.huType = GameDefine.HU_TYPE_ZI_MO
        ret.huCardVal = self.sysCardVal
        local foundGang = false
        local i = #self.actionsQue
        --找到第一个为杠的操作，且之后的操作除了过和听以及系统操作外没有其他操作
        while i > 0 do 
            local action = self.actionsQue[i]
            if action.act ~= GameDefine.PLAY_ACT_GUO and 
                self.actionsQue[i].act ~= GameDefine.PLAY_ACT_SYS and 
                self.actionsQue[i].act ~= GameDefine.PLAY_ACT_TING then 
                break 
            end 
            i = i - 1
        end 
        if i > 0 then 
            local act = self.actionsQue[i]
            if act.chairID == player.chairID and 
                act.act == GameDefine.PLAY_ACT_GANG_PLAYBACK then 
                ret.isGangKai = true
            end 
        end 
    end 
    local extraCardType = GameDefine.getCardType(extraCardVal)
    local shortExtraCardVal = extraCardVal % 10
    

    --是否开口
    if not self:__isPlayerKaiKou(chairid) then 
        logErrf("[userid: %d] kaikou false", player.userid)
        return retProc()
    end 
    --是否海底捞
    local isHaiDiLao = self:__isHaiDiLao()
    ret.isHaiDiLao = isHaiDiLao

    --手牌是否有红中或者赖子皮
    local contains = self:__containsGangPai(chairid, extraCardVal)
    if contains then 
        logErrf("[userid: %d] contains gang card", player.userid)
        return retProc()
    end 
    
    --是否是将一色
    local isJiangYiSe = self:__isJiangYiSe(chairid, extraCardVal)
    if isJiangYiSe then 
        ret.isJiangYiSe = true
    end 

    --是否是风一色
    if not isJiangYiSe then 
        local isFengYiSe = self:__isFengYiSe(chairid, extraCardVal)
        if isFengYiSe then 
            ret.isFengYiSe = true
        end 
    end 
    
    --是否是胡牌类型
    local succ, huComps = MJLogic.canHu(player, extraCardVal, GameDefine.getCardType(extraCardVal))
    if not succ then 
        logErrf("[userid: %d] no hu pai array can be detected", player.userid)
        return retProc()
    end 
    if not ret.isJiangYiSe and not ret.isFengYiSe then 
        --检查是否是清一色
        local isQingYiSe = self:__isQingYiSe(chairid, extraCardVal)
        if isQingYiSe then 
            ret.isQingYiSe = true
        end 
    end 
    --检查是否是碰碰胡
    local isPengPengHu = self:__isPengPengHu(player, huComps)
    if isPengPengHu then 
        ret.isPengPengHu = true
        --检查碰碰胡里边有没有硬胡
        for _, huComp in ipairs(huComps) do 
            local isYingHu = true
            local isPengPeng = true 
            for _, comp in ipairs(huComp) do 
                if comp.compType == GameDefine.COMP_TYPE_SHUN then 
                    isPengPeng = false
                    break 
                else 
                    for _, cardVal in ipairs(comp.needLais) do 
                        if cardVal ~= self.laiZiCardVal then 
                            isYingHu = false
                            break 
                        end 
                    end 
                end 
            end 
            if isPengPeng and isYingHu then 
                ret.isYingHu = true 
                break
            end 
        end 
    end 

    --检查将牌是否是2,5,8
    local huComps258 = {}
    for _, huComp in ipairs(huComps) do 
        for _, comp in ipairs(huComp) do 
            local shortCardVal = comp.cards[1] % 10
            local cardType = GameDefine.getCardType(comp.cards[1])
            if cardType == GameDefine.CARD_TYPE_TONG or 
                cardType == GameDefine.CARD_TYPE_WAN or 
                cardType == GameDefine.CARD_TYPE_SUO then 
                if comp.compType == GameDefine.COMP_TYPE_JIANG then 
                    if shortCardVal == 2 or 
                        shortCardVal == 5 or 
                        shortCardVal == 8  then 
                        table.insert(huComps258, huComp)
                    end
                    break
                end 
            end 
        end
    end 
    if #huComps258 == 0 then 
        logErrf("[userid: %d] no 2,5,8 can be detected", player.userid)
        return retProc()
    end 
    --是否全求人
    if ret.huType == GameDefine.HU_TYPE_DIAN_PAO then 
        --检查手里是否只有一张牌
        local cardsCnt = 0
        for _, handCards in pairs(player.handCards) do 
            cardsCnt = cardsCnt + handCards.num
        end 
        cardsCnt = cardsCnt + player.laisOwned
        if cardsCnt == 1 then 
            --检查action是否对
            local i = #self.actionsQue
            while i > 0 and (self.actionsQue[i].act == GameDefine.PLAY_ACT_GUO or 
                (self.actionsQue[i].act == GameDefine.PLAY_ACT_SYS and 
                self.actionsQue[i].data.cardVal == nil)) do 
                i = i - 1
            end 
            if i > 0 then 
                local act = self.actionsQue[i]
                if act.act == GameDefine.PLAY_ACT_OUT and 
                    act.data.cardVal == self.watchCard.cardVal and 
                    act.chairID ~= player.chairID then 
                    local cardType = GameDefine.getCardType(act.data.cardVal)
                    local shortVal = GameDefine.getCardShortVal(act.data.cardVal)
                    if (cardType == GameDefine.CARD_TYPE_WAN or 
                        cardType == GameDefine.CARD_TYPE_TONG or 
                        cardType == GameDefine.CARD_TYPE_SUO) and 
                        (shortVal == 2 or 
                        shortVal == 5 or 
                        shortVal == 8) then 
                        ret.isQuanQiuRen = true
                    end 
                end 
            end 
        end 
    end 
    if ret.isQingYiSe or 
        ret.isJiangYiSe or 
        ret.isFengYiSe or 
        ret.isGangKai or 
        ret.isQuanQiuRen or 
        ret.isHaiDiLao then 
        if not ret.isYingHu then --检查是否有硬胡
            for _, huComp in ipairs(huComps258) do 
                local isYingHu = true
                for _, comp in ipairs(huComp) do 
                    for _, cardVal in ipairs(comp.needLais) do 
                        if cardVal ~= self.laiZiCardVal then 
                            isYingHu = false
                            break 
                        end 
                    end 
                end 
                if isYingHu then 
                    ret.isYingHu = true 
                    break
                end 
            end 
        end 
    end 
    local isDahu = false
    if ret.isJiangYiSe or 
        ret.isFengYiSe or 
        ret.isQingYiSe or 
        ret.isPengPengHu or 
        ret.isGangKai or 
        ret.isQiangGang or 
        ret.isQuanQiuRen or 
        ret.isHaiDiLao then --大胡
        isDahu = true
    end
    local function checkFans(extraFans)
        extraFans = extraFans or 0
        --番数是否足够
        if theOtherChairID ~= 0 then 
            if extraFans + self:__getPlayerFansCnt(theOtherChairID) + self:__getPlayerFansCnt(chairid) < self.fans then
                return false
            else
                return true
            end 
        else --是属于自摸，那就查看自己和其余的玩家是否达到番数
            local myFans = self:__getPlayerFansCnt(chairid)
            for _chairID, _player in pairs(self.players) do
                if _chairID ~= chairid and (extraFans + myFans + self:__getPlayerFansCnt(_chairID)) < self.fans then 
                    return false
                end 
            end
            return true
        end 
    end 
    if isDahu then 
        ret.success = true 
        return ret
    else --小胡的番数检测
        local fansSucc = false
        if ret.huType == GameDefine.HU_TYPE_ZI_MO then 
            fansSucc = checkFans(1)
        elseif ret.huType == GameDefine.HU_TYPE_DIAN_PAO then 
            local player = self.players[chairid]
            local theOther = self.players[theOtherChairID]
            if player.userid == self.zhuangID or 
                theOther.userid == self.zhuangID then 
                fansSucc = checkFans(2)
            else 
                fansSucc = checkFans(1)
            end 
        else 
            error()
        end 
        if not fansSucc then 
            logErrf("[userid: %d] insurficient fans %d to meet room fans: %d", 
                player.userid, 
                self:__getPlayerFansCnt(player.chairID),
                self.fans)
            ret.success = false 
            return ret
        end 
    end 
    -------------------小胡做如下额外检测------------------
    --不是大胡，检查是否只有一张赖子
    if player.laisOwned > 1 then 
        logErrf("[userid: %d] more than 1 lais owned %d can not be allowed", 
            player.userid, 
            player.laisOwned)
        ret.success = false
        return ret
    end 
    --如果什么大胡都没有，那就是屁胡
    if not ret.isYingHu then --检查小胡是否有硬胡
        for _, huComp in ipairs(huComps258) do 
            local isYingHu = true
            for _, comp in ipairs(huComp) do 
                for _, cardVal in ipairs(comp.needLais) do 
                    if cardVal ~= self.laiZiCardVal then 
                        isYingHu = false
                        break 
                    end 
                end 
            end 
            if isYingHu then 
                ret.isYingHu = true 
                break
            end 
        end 
    end 
    ret.success = true
    return ret
end 

--extraParams: {huType = ?, huData = ?}
function TableGameMain:__canHu(chairid, extraCardVal, theOtherChairID, extraParams)
    local extraCardVal = extraCardVal or 0
    local extraCardType = GameDefine.getCardType(extraCardVal)
    theOtherChairID = theOtherChairID or 0
    local shortExtraCardVal = extraCardVal % 10

    local player = self.players[chairid]

    local function checkFans(chairID1, chairID2, extraFans)
        extraFans = extraFans or 0
        if extraFans + self:__getPlayerFansCnt(chairID1) + self:__getPlayerFansCnt(chairID2) < self.fans then
            return false
        else
            return true
        end 
    end 
    --是否开口
    if not self:__isPlayerKaiKou(player.chairID) then 
        return false 
    end 
    --手牌是否有红中或者赖子皮
    local contains = self:__containsGangPai(chairid, extraCardVal)
    if contains then 
        return false
    end 
    
    --是否是将一色
    local isYiSe = self:__isJiangYiSe(chairid, extraCardVal)
    if isYiSe then 
        return true
    end 

    --是否是风一色
    local isYiSe = self:__isFengYiSe(chairid, extraCardVal)
    if isYiSe then 
        return true
    end 

    --是否是胡牌类型
    local succ, huComps = MJLogic.canHu(player, extraCardVal, GameDefine.getCardType(extraCardVal))
    if not succ then 
        return false
    end 
    --检查是否是清一色
    local isYiSe = self:__isQingYiSe(chairid, extraCardVal)
    if isYiSe then 
        return true
    end 
    --检查是否是碰碰胡
    local isPengPengHu = self:__isPengPengHu(player, huComps)
    if isPengPengHu then 
        return true
    end 

    --不检查将牌是否是2,5,8
    local huComps258 = {}
    for _, huComp in ipairs(huComps) do 
        for _, comp in ipairs(huComp) do 
            local shortCardVal = comp.cards[1] % 10
            local cardType = GameDefine.getCardType(comp.cards[1])
            if cardType == GameDefine.CARD_TYPE_TONG or 
                cardType == GameDefine.CARD_TYPE_WAN or 
                cardType == GameDefine.CARD_TYPE_SUO then 
                if comp.compType == GameDefine.COMP_TYPE_JIANG then 
                    if shortCardVal == 2 or 
                        shortCardVal == 5 or 
                        shortCardVal == 8  then 
                        table.insert(huComps258, huComp)
                    end
                    break
                end 
            end 
        end
    end 
    if #huComps258 == 0 then 
        return false
    end 
    if extraParams.huType == GameDefine.HU_TYPE_DIAN_PAO then --点炮胡
        --是否全求人
        --检查手里是否只有一张牌
        local cardsCnt = 0
        for _, handCards in pairs(player.handCards) do 
            cardsCnt = cardsCnt + handCards.num
        end 
        cardsCnt = cardsCnt + player.laisOwned
        if cardsCnt == 1 then 
            local cardType = GameDefine.getCardType(extraCardVal)
            local shortVal = GameDefine.getCardShortVal(extraCardVal)
            if (cardType == GameDefine.CARD_TYPE_WAN or 
                cardType == GameDefine.CARD_TYPE_TONG or 
                cardType == GameDefine.CARD_TYPE_SUO) and 
                (shortVal == 2 or 
                shortVal == 5 or 
                shortVal == 8) then 
                return true
            end 
        end 
        local fansSucc = false
        local player = self.players[chairid]
        local theOther = self.players[theOtherChairID]
        if player.userid == self.zhuangID or 
            theOther.userid == self.zhuangID then 
            fansSucc = checkFans(chairid, theOtherChairID, 2)
        else 
            fansSucc = checkFans(chairid, theOtherChairID, 1)
        end 
        if not fansSucc then 
            return false
        end 
        --小胡的赖子数量检测
        return player.laisOwned <= 1
    elseif extraParams.huType == GameDefine.HU_TYPE_ZI_MO then --自摸
        local extraFans = 1
        local player = self.players[chairid]
        if player.userid == self.zhuangID then 
            extraFans = extraFans + 1
        end 
        for _chairID, _player in pairs(self.players) do
            if _chairID ~= chairid then 
                local succ = false
                if _player.userid == self.zhuangID then 
                    succ = checkFans(chairid, _chairID, extraFans + 1)
                else 
                    succ = checkFans(chairid, _chairID, extraFans)
                end 
                if not succ then 
                    return false
                end 
            end 
        end
        --小胡的赖子数量检测
        return player.laisOwned <= 1
    elseif extraParams.huType == GameDefine.HU_TYPE_HAI_DI_LAO then --海底捞
        return true
    elseif extraParams.huType == GameDefine.HU_TYPE_GANG_KAI then --点炮胡
        return true
    elseif extraParams.huType == GameDefine.HU_TYPE_QIANG_GANG then --抢杠
        return true
    elseif extraParams.huType == GameDefine.HU_TYPE_TING then --听牌胡牌模式检测
        return true
    else
        error()
    end 
end 

function TableGameMain:__canPeng(chairid, extraCardVal)
    if self:__isGangCard(extraCardVal) then 
        return false
    end 
    local player = self.players[chairid]
    return MJLogic.canPeng(player.handCards, extraCardVal, GameDefine.getCardType(extraCardVal))
end 

function TableGameMain:__canMingGang(chairid, extraCardVal)
    if self:__isGangCard(extraCardVal) then 
        return false
    end 
    local player = self.players[chairid]
    return MJLogic.canMingGang(player.handCards, extraCardVal, GameDefine.getCardType(extraCardVal))
end 

function TableGameMain:__canChi(chairid, extraCardVal)
    if self:__isGangCard(extraCardVal) then 
        return false
    end 
    local cardType = GameDefine.getCardType(extraCardVal)
    if cardType == GameDefine.CARD_TYPE_HUA or cardType == GameDefine.CARD_TYPE_ZI then 
        return false 
    end 
    local player = self.players[chairid]
    local excludeCards = {self.laiZiCardVal, self.laiZiPiCardVal, self.hongZhongCardVal}
    return MJLogic.canChi(player.handCards, extraCardVal, cardType, excludeCards)
end 

function TableGameMain:__canTing(chairid)
    --额外加一张万能牌（赖子），如果能胡，就能听牌
    return self:__canHu(chairid, self.laiZiCardVal, {huType = GameDefine.HU_TYPE_TING})
end 

--[Comment]
--当前所看之牌
function TableGameMain:currentWatches()
    if #self.watchQue == 0 then 
        return {}
    end 
    if not self.watchQue[self.watchProgress] then 
        return {}
    end 
    local curWatch = self.watchQue[self.watchProgress]
    local curChairID = curWatch and curWatch.chairID or 0
    local progress = self.watchProgress
    local watches = {}
    while self.watchQue[progress] do 
        local watch = self.watchQue[progress]
        if watch.chairID ~= curChairID then 
            break 
        end 
        table.insert(watches, watch)
        progress = progress + 1
    end 
    return watches
end 

function TableGameMain:currentHuWatch()
    if #self.watchQue == 0 then 
        return nil
    end 
    if not self.watchQue[self.watchProgress] then 
        return nil
    end 
    local curWatch = self.watchQue[self.watchProgress]
    local curChairID = curWatch.chairID
    local progress = self.watchProgress
    while self.watchQue[progress] do 
        local watch = self.watchQue[progress]
        if watch.chairID ~= curChairID then 
            break 
        end 
        if watch.huType and watch.huType ~= 0 then 
            return watch
        end 
        progress = progress + 1
    end 
    return nil
end 

function TableGameMain:tryNextWatch()
    if #self.watchQue == 0 then 
        return nil
    end 
    if not self.watchQue[self.watchProgress + 1] then 
        return nil
    end 
    local curWatch = self.watchQue[self.watchProgress]
    local curChairID = curWatch and curWatch.chairID or 0
    local progress = self.watchProgress
    while self.watchQue[progress] do 
        local watch = self.watchQue[progress]
        if watch.chairID ~= curChairID then 
            return watch 
        end 
        progress = progress + 1
    end 
    return nil
end 

--[Comment]
--是否处于看牌模式
function TableGameMain:isInWatchMode()
    if #self.watchQue == 0 then 
        return false
    end 
    if not self.watchQue[self.watchProgress] then 
        return false
    end 
    local curWatch = self.watchQue[self.watchProgress]
    return true
end 

--[Comment]
--是否进入了海底捞
function TableGameMain:__isHaiDiLao()
    if self.distributedCardsCnt > self.totalCardsNum - self.weiCardsNum - 4 then 
        return true
    else
        return false 
    end 
end 

function TableGameMain:__watchCard()
    if #self.watchQue == 0 then 
        return
    end 
    --skip watches with same chairID
    if self.watchQue[self.watchProgress] then 
        local curWatchChairID = self.watchQue[self.watchProgress].chairID
        while self.watchQue[self.watchProgress] do 
            local watch = self.watchQue[self.watchProgress]
            if watch.chairID ~= curWatchChairID then 
                break 
            end 
            self.watchProgress = self.watchProgress + 1
        end 
    else 
        self.watchProgress = self.watchProgress + 1
    end 
    if not self.watchQue[self.watchProgress] then 
        self:__resetWatch()
        return
    end 
    local curWatch = self.watchQue[self.watchProgress]
    local curChairID = curWatch and curWatch.chairID or 0
    local progress = self.watchProgress
    local watches = {}
    while self.watchQue[progress] do 
        local watch = self.watchQue[progress]
        if watch.chairID ~= curChairID then 
            break 
        end 
        table.insert(watches, watch)
        progress = progress + 1
    end 
    return watches
end 

function TableGameMain:__getCardsRemainsCnt()
    return self.totalCardsNum - self.weiCardsNum - self.distributedCardsCnt
end 

--尾墩牌派牌
function TableGameMain:__systemDispatchCardWei(whosTurnChairID)
    self.whosTurnChairID = whosTurnChairID
    local dispatchCardVal = self.systemCards[self.totalCardsNum - self.weiCardsDistributedCnt]
    self.sysCardVal = dispatchCardVal
    self.weiCardsDistributedCnt = self.weiCardsDistributedCnt + 1
        
    local player = self.players[self.whosTurnChairID]
    if self.sysCardVal == self.laiZiCardVal then 
        player.laisOwned = player.laisOwned + 1
    else 
        self:__inputCard(self.whosTurnChairID, self.sysCardVal)
    end 
    local data = {
        whosTurnChairID = self.whosTurnChairID,
        cardVal = self.sysCardVal,
        cardsRemainCnt = self:__getCardsRemainsCnt(),
        actions = {},
        actionWaitTime = GameDefine.ACTION_WAIT_TIME,
    }
    self.waitingActions = {}
    local canGang = self:__canPlayerInitiativeGang(self.whosTurnChairID)
    if canGang then 
        table.insert(data.actions, GameDefine.PLAY_ACT_GANG_INITIATIVE)
        table.insert(self.waitingActions, GameDefine.PLAY_ACT_GANG_INITIATIVE)
    end 
    local canHu = self:__canHu(player.chairID, nil, nil, {huType = GameDefine.HU_TYPE_GANG_KAI})
    if canHu then 
        table.insert(data.actions, GameDefine.PLAY_ACT_HU)
        table.insert(self.waitingActions, GameDefine.PLAY_ACT_HU)
    end 
    if #self.waitingActions == 0 then 
        table.insert(data.actions, GameDefine.PLAY_ACT_OUT)
        table.insert(self.waitingActions, GameDefine.PLAY_ACT_OUT)
    else
        table.insert(data.actions, GameDefine.PLAY_ACT_GUO)
        table.insert(self.waitingActions, GameDefine.PLAY_ACT_GUO)
    end 
    table.insert(self.actionsQue, {
        chairID = 0,
        act = GameDefine.PLAY_ACT_SYS, 
        data = table.clone(data),
    })
    self.waitingStartTime = os.time()
    local realCardVal = data.cardVal
    for _, player in pairs(self.players) do 
        if player.chairID == self.whosTurnChairID then 
            data.cardVal = realCardVal
        else 
            data.cardVal = -1
        end 
        self:SendTableMsg(CMD_HNMJ.SUB_S_SYSTEM_DISPATCH_CARD, 
                            "Gamemsg.ms_system_dispatch_card", 
                            data,
                            player.chairID) 
    end 
    self:__resetActionTimer()
    self:__newActionTimer()

--logNormalf("[%s]\ninput: %s\noutput: %s, \nresult: %s", 
--                "ms_system_dispatch_card", 
--                table.tostring({}, true), 
--                table.tostring(data, true), 
--                table.tostring(self, true))
end 

function TableGameMain:__indicatePlayerOutCard(whosTurnChairID)
    local data = {
        whosTurnChairID = self.whosTurnChairID,
        actions = {},
        actionWaitTime = GameDefine.ACTION_WAIT_TIME,
    }
    self.waitingActions = {}
    table.insert(data.actions, GameDefine.PLAY_ACT_OUT)
    table.insert(self.waitingActions, GameDefine.PLAY_ACT_OUT)
    table.insert(self.actionsQue, {
        chairID = 0,
        act = GameDefine.PLAY_ACT_SYS, 
        data = table.clone(data),
    })
    self.waitingStartTime = os.time()
    self:SendTableMsg(CMD_HNMJ.SUB_S_SYSTEM_DISPATCH_CARD, 
                        "Gamemsg.ms_system_dispatch_card", 
                        data)
    self:__resetActionTimer()
    self:__newActionTimer()
end

function TableGameMain:__systemDispatchCardNormal(whosTurnChairID)
    local watches = self:__watchCard()
    if watches and #watches > 0 then 
        self.whosTurnChairID = watches[1].chairID
        self.waitingActions = {}
        local data = {
            whosTurnChairID = self.whosTurnChairID,
            actions = {},
            actionWaitTime = GameDefine.ACTION_WAIT_TIME,
        }
        for _, watch in ipairs(watches) do 
            table.insert(self.waitingActions, watch.action)
            table.insert(data.actions, watch.action)
        end 
        table.insert(self.waitingActions, GameDefine.PLAY_ACT_GUO)
        table.insert(data.actions, GameDefine.PLAY_ACT_GUO)
        table.insert(self.actionsQue, {
            chairID = 0,
            act = GameDefine.PLAY_ACT_SYS, 
            data = table.clone(data),
        })
        self.waitingStartTime = os.time()
        self:SendTableMsg(CMD_HNMJ.SUB_S_SYSTEM_DISPATCH_CARD, 
            "Gamemsg.ms_system_dispatch_card", 
            data,
            self.whosTurnChairID) 
        self:__resetActionTimer()
        self:__newActionTimer()

--        logNormalf("[%s]\ninput: %s\noutput: %s, \nresult: %s", 
--                        "ms_system_dispatch_card", 
--                        table.tostring({}, true), 
--                        table.tostring(data, true), 
--                        table.tostring(self, true))
    else
        if #self.jiePaoUsers > 0 then 
            self:gameOver(GameDefine.GAME_OVER_TYPE_HU)
            return
        end 
        if self.distributedCardsCnt >= self.totalCardsNum - self.weiCardsNum then 
            --流局
            self:gameOver(GameDefine.GAME_OVER_TYPE_LIU)
            return
        end 

        local function nextTurnChairID(curTurnChairID)
            curTurnChairID = (curTurnChairID + 1) % self.wChairCount
            curTurnChairID = curTurnChairID == 0 and self.wChairCount or curTurnChairID
            return curTurnChairID
        end 

        local function nextSysCard()
            self.distributedCardsCnt = self.distributedCardsCnt + 1
            local dispatchCardVal = self.systemCards[self.distributedCardsCnt]
            return dispatchCardVal
        end 

        local function dispatch(chairID)
            local player = self.players[chairID]

            local dispatchCardVal = nextSysCard()
            self.sysCardVal = dispatchCardVal

            if self.sysCardVal == self.laiZiCardVal then 
                player.laisOwned = player.laisOwned + 1
            else 
                self:__inputCard(self.whosTurnChairID, self.sysCardVal)
            end 
            local data = {
                whosTurnChairID = self.whosTurnChairID,
                cardVal = self.sysCardVal,
                cardsRemainCnt = self:__getCardsRemainsCnt(),
                actions = {},
                actionWaitTime = GameDefine.ACTION_WAIT_TIME,
            }
            self.waitingActions = {}
            local canGang = self:__canPlayerInitiativeGang(self.whosTurnChairID)
            if canGang then 
                table.insert(data.actions, GameDefine.PLAY_ACT_GANG_INITIATIVE)
                table.insert(self.waitingActions, GameDefine.PLAY_ACT_GANG_INITIATIVE)
            end 
            local canHu = self:__canHu(player.chairID, nil, nil, {huType = GameDefine.HU_TYPE_ZI_MO})
            if canHu then 
                table.insert(data.actions, GameDefine.PLAY_ACT_HU)
                table.insert(self.waitingActions, GameDefine.PLAY_ACT_HU)
            end 
            if #self.waitingActions == 0 then 
                table.insert(data.actions, GameDefine.PLAY_ACT_OUT)
                table.insert(self.waitingActions, GameDefine.PLAY_ACT_OUT)
            else
                table.insert(data.actions, GameDefine.PLAY_ACT_GUO)
                table.insert(self.waitingActions, GameDefine.PLAY_ACT_GUO)
            end 
            table.insert(self.actionsQue, {chairID = 0,
                                            act = GameDefine.PLAY_ACT_SYS, 
                                            data = table.clone(data)})
            self.waitingStartTime = os.time()
            local realCardVal = data.cardVal
            local realActions = data.actions
            for _, _player in pairs(self.players) do 
                if _player.chairID == self.whosTurnChairID then 
                    data.cardVal = realCardVal
                    data.actions = realActions
                else 
                    data.cardVal = -1
                    data.actions = {}
                end 
                self:SendTableMsg(CMD_HNMJ.SUB_S_SYSTEM_DISPATCH_CARD, 
                                    "Gamemsg.ms_system_dispatch_card", 
                                    data,
                                    _player.chairID) 
            end 
            self:__resetActionTimer()
            self:__newActionTimer()
--            logNormalf("[%s]\ninput: %s\noutput: %s, \nresult: %s", 
--                            "ms_system_dispatch_card", 
--                            table.tostring({}, true), 
--                            table.tostring(data, true), 
--                            table.tostring(self, true))
            if player.isInTingMode then 
                --TODO ting 的处理
--                local canHu = self:__canHu(player.chairID)
--                if canHu then 
--                    local result = self:__analyseHu(player.chairID)
--                end 
            end 
        end 
        if self.totalCardsNum - self.weiCardsNum - self.distributedCardsCnt == 4 then --最后4张，进入海底捞
            local turn = self.whosTurnChairID
            self.whosTurnChairID = 0 --牌手回归到系统
            self:__resetWatch()
            local data = {cards = {}}
            local nextChairID = turn
            for i = 1, 4, 1 do 
                nextChairID = nextTurnChairID(nextChairID)
                local haiDiLaoCard = {
                    chairID = nextChairID,
                    cardVal = nextSysCard(),
                }
                table.insert(data.cards, haiDiLaoCard)
                local player = self.players[nextChairID]
                if haiDiLaoCard.cardVal == self.laiZiCardVal then 
                    player.laisOwned = player.laisOwned + 1
                else 
                    self:__inputCard(player.chairID, haiDiLaoCard.cardVal)
                end 
                local canHu = self:__canHu(player.chairID, nil, nil, {huType = GameDefine.HU_TYPE_HAI_DI_LAO})
                if canHu then 
                    watchPlayer = {chairID = nextChairID, 
                                    action = GameDefine.PLAY_ACT_HU, 
                                    huType = GameDefine.HU_TYPE_HAI_DI_LAO,
                                    huCardVal = haiDiLaoCard.cardVal,
                                    priority = GameDefine.WATCH_PRIORITY_HU}
                    table.insert_sort(self.watchQue, watchPlayer, function(old, new)
                        return new.priority < old.priority
                    end)
                end 
            end 
            self:SendTableMsg(CMD_HNMJ.SUB_S_HAIDILAO, 
                                "Gamemsg.ms_haidilao", 
                                data)
--            logNormalf("[%s]\ninput: %s\noutput: %s, \nresult: %s", 
--                            "ms_haidilao", 
--                            table.tostring({}, true), 
--                            table.tostring(data, true), 
--                            table.tostring(self, true))
            if #self.watchQue > 0 then --有人胡牌，开始看牌模式
                self:__systemDispatchCardNormal()
            else
                --流局
                self:gameOver(GameDefine.GAME_OVER_TYPE_LIU)
            end 
            return
        else 
            self.whosTurnChairID = whosTurnChairID or nextTurnChairID(self.whosTurnChairID)
            dispatch(self.whosTurnChairID)
        end 
    end 
end 

function TableGameMain:gameOver(result)
--    PerformanceMeasure.mark("gameOver")
    self.gameResult = self.gameResult or {
        chairID = 0
    }
    local gameResult = self.gameResult
    local ms_game_over = {
        result = 0,
        players = {},
        statPlayers = {},
    }
    ms_game_over.result = result
    local balancePlayers = {}
    for chairID, player in pairs(self.players) do 
        local balancePlayer = {
            userid = player.userid,
            handCards = {}, 
            mingCards = {},
            huType = 0, 
            huCardVal = 0,
            fans = 0,
            score = 0,
            scoreTypes = {}, --得分类型
            baoHu = false,
            isSponsor = false,
        }
        for _, handCards in pairs(player.handCards) do 
            if handCards.num > 0 then 
                for _, card in ipairs(handCards.cards) do 
                    for i = 1, card.num, 1 do 
                        table.insert(balancePlayer.handCards, card.cardVal)
                    end 
                end 
            end 
        end 
        for i = 1, player.laisOwned, 1 do 
            table.insert(balancePlayer.handCards, self.laiZiCardVal)
        end 
        for _, mingCard in ipairs(player.mingCards) do 
            table.insert(balancePlayer.mingCards, {cardVal = mingCard.cardVal, 
                                                    mingType = mingCard.mingType, 
                                                    subMingType = mingCard.subMingType})
        end 
        table.insert(ms_game_over.players, balancePlayer)
        balancePlayers[chairID] = balancePlayer
    end 
--    PerformanceMeasure.mark("gameOver")
    local statistic = {}
    local loser = nil
    local winnerBalancePlayer = nil
    local sponsorBalancePlayer = nil 
    if result ~= GameDefine.GAME_OVER_TYPE_LIU then 
        --统计各个玩家的番数
        for chairID, balancePlayer in pairs(balancePlayers) do 
            local fans = self:__getPlayerFansCnt(chairID)
            if chairID == gameResult.chairID then 
                if gameResult.isYingHu then --硬胡
                    fans = fans + 1
                end 
            end 
            balancePlayer.fans = fans
        end 
        local baseScore = 1 --基础分
        local winner = self.players[gameResult.chairID]
        winnerBalancePlayer = balancePlayers[gameResult.chairID]
        winnerBalancePlayer.huCardVal = gameResult.huCardVal
        winnerBalancePlayer.huType = gameResult.huType
        --计算大胡基础分（风一色留到最后计算）
        local daHuBaseScore = 0
        if gameResult.isJiangYiSe then 
            daHuBaseScore = daHuBaseScore + 10
            table.insert(winnerBalancePlayer.scoreTypes, GameDefine.RECORD_TYPE_JIANGYISE)
        end 
        if gameResult.isFengYiSe then 
            daHuBaseScore = daHuBaseScore + 10
            table.insert(winnerBalancePlayer.scoreTypes, GameDefine.RECORD_TYPE_FENGYISE)
        end 
        if gameResult.isQingYiSe then 
            daHuBaseScore = daHuBaseScore + 10
            table.insert(winnerBalancePlayer.scoreTypes, GameDefine.RECORD_TYPE_QINGYISE)
        end 
        if gameResult.isPengPengHu then 
            daHuBaseScore = daHuBaseScore + 10
            table.insert(winnerBalancePlayer.scoreTypes, GameDefine.RECORD_TYPE_PENGPENGHU)
        end 
        if gameResult.isGangKai then 
            daHuBaseScore = daHuBaseScore + 10
            table.insert(winnerBalancePlayer.scoreTypes, GameDefine.RECORD_TYPE_GANGKAI)
        end 
        if gameResult.isQuanQiuRen then 
            daHuBaseScore = daHuBaseScore + 10
            table.insert(winnerBalancePlayer.scoreTypes, GameDefine.RECORD_TYPE_QUANQIUREN)
        end 
        if gameResult.isHaiDiLao then 
            daHuBaseScore = daHuBaseScore + 10
            table.insert(winnerBalancePlayer.scoreTypes, GameDefine.RECORD_TYPE_HAIDILAO)
        end 
        if gameResult.isYingHu then 
            table.insert(winnerBalancePlayer.scoreTypes, GameDefine.RECORD_TYPE_YINGHU)
        end 
        if gameResult.isQiangGang then 
            daHuBaseScore = daHuBaseScore + 10
            table.insert(winnerBalancePlayer.scoreTypes, GameDefine.RECORD_TYPE_QIANGGANG)
        end 
        if daHuBaseScore ~= 0 then 
            baseScore = daHuBaseScore
        else
            table.insert(winnerBalancePlayer.scoreTypes, GameDefine.RECORD_TYPE_XIAOHU)
        end 
        if gameResult.huType == GameDefine.HU_TYPE_DIAN_PAO or
           gameResult.huType == GameDefine.HU_TYPE_ZI_MO then 
            if gameResult.isQingYiSe or --这几种类型的胡基础分加5个点
                gameResult.isJiangYiSe or 
                gameResult.isPengPengHu then 
                baseScore = baseScore + 5
            end
        end 
        --检查是否有包胡
        local baoHuChairID = 0
        if gameResult.huType == GameDefine.HU_TYPE_DIAN_PAO then 
            if gameResult.isQuanQiuRen then 
                baoHuChairID = gameResult.huData.outChairID
            else
                loser = self.players[gameResult.huData.outChairID]
            end 
            local balancePlayer = balancePlayers[gameResult.huData.outChairID]
            balancePlayer.isSponsor = true
            sponsorBalancePlayer = balancePlayer
            if not gameResult.isJiangYiSe and 
                not gameResult.isFengYiSe and 
                not gameResult.isQingYiSe and 
                not gameResult.isPengPengHu and 
                not gameResult.isGangKai and 
                not gameResult.isQuanQiuRen and 
                not gameResult.isHaiDiLao then
                --小胡庄加1番
                if loser.userid == self.zhuangID then 
                    local balancePlayer = balancePlayers[loser.chairID]
                    balancePlayer.fans = balancePlayer.fans + 1
                elseif winner.userid == self.zhuangID then 
                    local balancePlayer = balancePlayers[winner.chairID]
                    balancePlayer.fans = balancePlayer.fans + 1
                end 
                local loserBalancePlayer = balancePlayers[loser.chairID]
                loserBalancePlayer.fans = loserBalancePlayer.fans + 1
            end  
        elseif gameResult.huType == GameDefine.HU_TYPE_QIANG_GANG then 
            baoHuChairID = gameResult.huData.gangChairID
            local baoHuBalancePlayer = balancePlayers[baoHuChairID]
            baoHuBalancePlayer.isSponsor = true
            sponsorBalancePlayer = baoHuBalancePlayer
        elseif gameResult.huType == GameDefine.HU_TYPE_HAI_DI_LAO then 

        elseif gameResult.huType == GameDefine.HU_TYPE_ZI_MO then 
            if not gameResult.isJiangYiSe and --小胡自摸加1番
                not gameResult.isFengYiSe and 
                not gameResult.isQingYiSe and 
                not gameResult.isPengPengHu and 
                not gameResult.isGangKai and 
                not gameResult.isQuanQiuRen and 
                not gameResult.isHaiDiLao then
                winnerBalancePlayer.fans = winnerBalancePlayer.fans + 1
                for chairID, balancePlayer in pairs(balancePlayers) do --自摸小胡，庄家加1番
                    local tmpPlayer = self.players[chairID]
                    if balancePlayer.userid == self.zhuangID then 
                        balancePlayer.fans = balancePlayer.fans + 1
                        break 
                    end 
                end
            end 
        else 
            logErrf("No such a huType: %d", gameResult.huType)
            return 
        end 

        --清一色theThird
        if gameResult.isQingYiSe then 
            if winner.theThird ~= 0 then 
                baoHuChairID = winner.theThird
            end 
        end
        if gameResult.isJiangYiSe then 
            if winner.theThird ~= 0 then 
                baoHuChairID = winner.theThird
            end 
        end 
        --TODO TODO TODO
        local fengDingScore = GameDefine.FENG_DING
        local jinDingScore = GameDefine.JIN_DING
        local haDingScore = GameDefine.HA_DING
        local sanYangKaiTaiScore = GameDefine.SAN_YANG_KAI_TAI
        --[[ --TODO 临时注释掉，如果后面需要把封顶翻倍的功能加上，这段代码需要修改
        if self.fengDingMulti ~= 0 then 
            fengDingScore = fengDingScore * self.fengDingMulti
            jinDingScore = jinDingScore * self.fengDingMulti
            haDingScore = haDingScore * self.fengDingMulti
            sanYangKaiTaiScore = sanYangKaiTaiScore * self.fengDingMulti
        end 
        --]]
        --统计得分
        local function calcAllScores()
            local score = 0
            --[[ --TODO 临时注释掉，如果后面需要把封顶翻倍的功能加上，这段代码需要修改
            for chairID, balancePlayer in pairs(balancePlayers) do 
                if chairID ~= gameResult.chairID then 
                    local thisScore = math.pow(2, winnerBalancePlayer.fans + balancePlayer.fans) * baseScore
                    balancePlayer.score = -thisScore
                end 
            end 
            --计算封顶，金顶，哈顶以及三阳开泰
            if self.fengDingMulti == 0 then 
                for chairID, balancePlayer in pairs(balancePlayers) do 
                    if chairID ~= gameResult.chairID then 
                        local thisScore = balancePlayer.score
                        score = score + thisScore
                    end 
                end 
                return score
            end 
            --]]
            local jinDing = true
            local sanYangKaiTai = true
            for chairID, balancePlayer in pairs(balancePlayers) do 
                if chairID ~= gameResult.chairID then 
                    local thisScore = gameResult.isFengYiSe and fengDingScore or (math.pow(2, winnerBalancePlayer.fans + balancePlayer.fans) * baseScore)
                    thisScore = thisScore < fengDingScore and thisScore or fengDingScore
                    if thisScore < fengDingScore then 
                        jinDing = false
                    end 
                    score = score + thisScore
                    balancePlayer.score = -thisScore
                end 
            end 
            --金顶
            if jinDing then 
                score = 0
                for chairID, balancePlayer in pairs(balancePlayers) do 
                    if chairID ~= gameResult.chairID then 
                        local thisScore = jinDingScore
                        if not self:__isPlayerKaiKou(chairID) then 
                            thisScore = haDingScore
                        end 
                        score = score + thisScore
                        balancePlayer.score = -thisScore
                        if thisScore < haDingScore then 
                            sanYangKaiTai = false
                        end 
                    end 
                end 
            end 
            --三阳开泰
            if jinDing and sanYangKaiTai then 
                score = 0
                for chairID, balancePlayer in pairs(balancePlayers) do 
                    if chairID ~= gameResult.chairID then 
                        local thisScore = sanYangKaiTaiScore
                        score = score + thisScore
                        balancePlayer.score = -thisScore
                    end 
                end 
            end 
            return score
        end 

        local losers = {}
        if baoHuChairID ~= 0 then  
            local loser = self.players[baoHuChairID]
            local score = calcAllScores()
            for chairID, balancePlayer in pairs(balancePlayers) do 
                if chairID ~= gameResult.chairID then 
                    if chairID ~= loser.chairID then 
                        balancePlayer.score = 0
                    end 
                end 
            end 
            local loseralancePlayer = balancePlayers[loser.chairID]
            loseralancePlayer.score = -score
            loseralancePlayer.baoHu = true
            local winneralancePlayer = balancePlayers[winner.chairID]
            winneralancePlayer.score = score
        elseif loser ~= nil then 
            local loseralancePlayer = balancePlayers[loser.chairID]
            local score = gameResult.isFengYiSe and fengDingScore or (math.pow(2, (winnerBalancePlayer.fans + loseralancePlayer.fans)) * baseScore)
            if score > fengDingScore then 
                score = fengDingScore
            end 
            loseralancePlayer.score = -score
            winnerBalancePlayer.score = score
        else --所有玩家都要给分 
            local score = calcAllScores()
            winnerBalancePlayer.score = score
        end 
        if self.options.baoZi and self.baoZiVal ~= 0 then 
            for chairID, balancePlayer in pairs(balancePlayers) do 
                balancePlayer.score = balancePlayer.score * 2
            end 
        end 
        --牌局记录 TODO 把之前的得分单词record改成score
        self.records.actionQue = self.actionQue 
        self.records.scoreTypes = winnerBalancePlayer.recordTypes
    end 
--    PerformanceMeasure.mark("gameOver")
    --统计
    for chairID, balancePlayer in pairs(balancePlayers) do 
        --分数保存
        local player = self.players[chairID]
        player.score = player.score + balancePlayer.score
        --统计
        local statRecord = {}
        statRecord[GameDefine.STAT_TYPE_WIN] = balancePlayer.score > 0 and 1 or 0
        statRecord[GameDefine.STAT_TYPE_LOSE] = balancePlayer.score < 0 and 1 or 0
        statRecord[GameDefine.STAT_TYPE_ZIMO] = balancePlayer.huType == GameDefine.HU_TYPE_ZI_MO and 1 or 0
        statRecord[GameDefine.STAT_TYPE_DIANPAO] = 0
        statRecord[GameDefine.STAT_TYPE_JIEPAO] = balancePlayer.huType == GameDefine.HU_TYPE_DIAN_PAO and 1 or 0
        statRecord[GameDefine.STAT_TYPE_RECORD] = balancePlayer.score
        if loser and chairID == loser.chairID and winnerBalancePlayer.huType == GameDefine.HU_TYPE_DIAN_PAO then 
            statRecord[GameDefine.STAT_TYPE_DIANPAO] = 1
        end 
        statistic[balancePlayer.userid] = statRecord
    end 
    for userid, statRecord in pairs(statistic) do 
        self.statistics[userid] = self.statistics[userid] or {}
        table.insert(self.statistics[userid], statRecord)
    end 
--    PerformanceMeasure.mark("gameOver")
    --牌局记录
    self.records.result = result 

    --save record
    local userids = {}
    for _, pServerUserItem in pairs(self.pUserItems) do 
        table.insert(userids, pServerUserItem.UserID)
    end 
    local baseRecord = {
        result = result, --牌局结果
        startTime = self.records.startTime,
        statistics = {},
        winner = winnerBalancePlayer,
        loserUserID = loser and loser.userid or 0,
        sponsorUserID = sponsorBalancePlayer and sponsorBalancePlayer.userid or 0,
        rollInfo = {
            laiZiCardVal = self.laiZiCardVal,
            laiZiPiCardVal = self.laiZiPiCardVal,
            hongZhongCardVal = self.hongZhongCardVal,
        },
    }
    for userid, statRecord in pairs(statistic) do 
        table.insert(baseRecord.statistics, {userid = userid, score = statRecord[GameDefine.STAT_TYPE_RECORD]})
    end 
    local detailRecord = {
        zhuangChairID = self.records.zhuangChairID,
        laiZiCardVal = self.laiZiCardVal,
        laiZiPiCardVal = self.laiZiPiCardVal,
        players = {},
        actionsQue = {},
        shaiZi1Val = self.shaiZi1Val,
        shaiZi2Val = self.shaiZi2Val,
    }
    for _, player in pairs(self.records.players) do 
        local recordPlayer = {
            userid = player.userid, 
            chairID = player.chairID, 
            handCards = {},
        }
        for _, cardVal in ipairs(player.handCards) do 
            table.insert(recordPlayer.handCards, cardVal)
        end 
        table.insert(detailRecord.players, recordPlayer)
    end 
--    PerformanceMeasure.mark("gameOver")
    detailRecord.actionsQue = self.actionsQue
--    PerformanceMeasure.mark("gameOver")
    
--    logNormalf("baseRecord: %s\ndetailRecord: %s", 
--                    table.tostring(baseRecord, true), 
--                    table.tostring(detailRecord, true))
    local bufBaseRecord = protobuf.encode("Gamemsg.record_base", baseRecord)
    local bufDetailRecord = protobuf.encode("Gamemsg.record_detail", detailRecord)

    local lena = bufBaseRecord:len()
    local lenb = bufDetailRecord:len()
--    PerformanceMeasure.mark("gameOver")
--    logNormalf("length of baseRecord: %d", lena)
--    logNormalf("length of detailRecord: %d", lenb)
--    PerformanceMeasure.mark("gameOver")

    local recordData = {
        userids = userids,
        basicrecord = bufBaseRecord,
        detailrecord = bufDetailRecord,
        roomguid = self.TableInfo.RoomGuid,
        playersinfo = json.encode(balancePlayers),
    }
--    PerformanceMeasure.mark("gameOver")
    GameRecord:RecordGame(recordData)
--    PerformanceMeasure.mark("gameOver")
     
    self.TableInfo.TotalPlayedCount = self.TableInfo.TotalPlayedCount + 1

    --统计牌局结果
    if self.TableInfo.TotalPlayedCount == self.TableInfo.Rolls then 
        for _, pServerUserItem in pairs(self.pUserItems) do 
            local userid = pServerUserItem.UserID
            local stats = self.statistics[userid]
            local statPlayer = {
                userid = userid,
                stats = {},
            }
            local playerStats = {}
            for _, stat in pairs(stats) do 
                for statType, value in pairs(stat) do 
                    playerStats[statType] = playerStats[statType] or 0
                    playerStats[statType] = playerStats[statType] + value
                end 
            end 
            for statType, value in pairs(playerStats) do 
                table.insert(statPlayer.stats, {statType = statType, statValue = value})
            end 
            table.insert(ms_game_over.statPlayers, statPlayer)
        end 
    end 
--    PerformanceMeasure.mark("gameOver")

    self:SendTableMsg(CMD_HNMJ.SUB_S_GAME_OVER, 
        "Gamemsg.ms_game_over", 
        ms_game_over) 

    self:__resetActionTimer()
--    PerformanceMeasure.mark("gameOver")

--    logNormalf("[%s]\ninput: %s\noutput: %s, \nresult: %s", 
--                    "ms_game_over", 
--                    table.tostring({}, true), 
--                    table.tostring(ms_game_over, true), 
--                    table.tostring(self, true))
    
    self:ConcludeGame()
--    PerformanceMeasure.mark("gameOver")

--    PerformanceMeasure.dump()
end 

function TableGameMain:__doActionOutCard(pServerUserItem, data)
    local player = self.players[pServerUserItem.UserInfo.ChairID]
    local success = self:__outputCard(pServerUserItem.UserInfo.ChairID, data.cardVal, 1)
    table.insert(player.uselessCards, data.cardVal) --add it to useless
    if not success then 
        logErrf("out card %d failed of player %d", data.cardVal, pServerUserItem.UserID)
        return
    end 
    table.insert(self.actionsQue, {
        chairID = player.chairID, 
        act = GameDefine.PLAY_ACT_OUT, 
        data = {cardVal = data.cardVal}
    })
    local ms_out_card = {userid = pServerUserItem.UserID, cardVal = data.cardVal}
    self:SendTableMsg(CMD_HNMJ.SUB_S_OUT_CARD, 
        "Gamemsg.ms_out_card", 
        ms_out_card) 
    self.sysCardVal = 0
    self:__resetWatch()
    self.watchCard.cardVal = data.cardVal
    self.watchCard.chairID = pServerUserItem.UserInfo.ChairID
    local delta = 0
    local myChairID = pServerUserItem.UserInfo.ChairID
    local nextChairID = (myChairID + 1) % self.wChairCount
    nextChairID = nextChairID == 0 and self.wChairCount or nextChairID
    delta = delta + 1
    while nextChairID ~= myChairID do 
        local canHu = self:__canHu(nextChairID, self.watchCard.cardVal, player.chairID, {huType = GameDefine.HU_TYPE_DIAN_PAO})
        local canGang = self:__canMingGang(nextChairID, self.watchCard.cardVal)
        local canPeng = self:__canPeng(nextChairID, self.watchCard.cardVal)
        local canChi = delta == 1 and self:__canChi(nextChairID, self.watchCard.cardVal) or false
        local watchPlayer = nil --{chairID = ?, action = ?, priority = ?}
        if canHu then 
            watchPlayer = {chairID = nextChairID, 
                            action = GameDefine.PLAY_ACT_HU, 
                            huType = GameDefine.HU_TYPE_DIAN_PAO,
                            outCardVal = data.cardVal, 
                            outChairID = player.chairID, 
                            priority = GameDefine.WATCH_PRIORITY_HU}
            table.insert_sort(self.watchQue, watchPlayer, function(old, new)
                return new.priority < old.priority
            end)
        end 
        if canGang then 
            watchPlayer = {chairID = nextChairID, action = GameDefine.PLAY_ACT_GANG_WATCH, priority = GameDefine.WATCH_PRIORITY_GANG}
            table.insert_sort(self.watchQue, watchPlayer, function(old, new)
                return new.priority < old.priority
            end)
        end 
        if canPeng then 
            watchPlayer = {chairID = nextChairID, action = GameDefine.PLAY_ACT_PENG, priority = GameDefine.WATCH_PRIORITY_PENG}
            table.insert_sort(self.watchQue, watchPlayer, function(old, new)
                return new.priority < old.priority
            end)
        end 
        if canChi then 
            watchPlayer = {chairID = nextChairID, action = GameDefine.PLAY_ACT_CHI, priority = GameDefine.WATCH_PRIORITY_CHI}
            table.insert_sort(self.watchQue, watchPlayer, function(old, new)
                return new.priority < old.priority
            end)
        end 
        nextChairID = (nextChairID + 1) % self.wChairCount
        nextChairID = nextChairID == 0 and self.wChairCount or nextChairID
        delta = delta + 1
    end 

    if #self.watchQue == 0 then --reset watch
        self.watchCard = {cardVal = 0, chairID = 0}
    end 

--    logNormalf("[%s]\ninput: %s\noutput: %s, \nresult: %s", 
--                    "mc_out_card", 
--                    table.tostring(data, true), 
--                    table.tostring(ms_out_card, true), 
--                    table.tostring(self, true))

    self:__systemDispatchCardNormal()
end 

function TableGameMain:__doActionChi(pServerUserItem, data)
    local player = self.players[pServerUserItem.UserInfo.ChairID]
    if self:__isGangCard(data.cardVal) then 
        logErrf("Chi nor allowed if the card is laizi, laizipi or hongzhong")
        return 
    end
    local cardType = GameDefine.getCardType(data.cardVal)
    if cardType == GameDefine.CARD_TYPE_HUA or cardType == GameDefine.CARD_TYPE_ZI then 
        logErrf("invalid chi action hua or zi")
        return 
    end 
    local delta = (player.chairID - self.watchCard.chairID + self.wChairCount) % self.wChairCount
    if delta ~= 1 then 
        logErrf("CHI action must be followed previous player")
        return
    end 
    if data.chiType == GameDefine.MING_TYPE_CHI_LEFT then 
        if self:__isGangCard(data.cardVal + 1) or self:__isGangCard(data.cardVal + 2) then 
            logErrf("Chi nor allowed if the chi cards contain laizi, laizipi or hongzhong")
            return 
        end
        local contains = self:containsCard(player.chairID, data.cardVal + 1, 1)
        contains = contains and self:containsCard(player.chairID, data.cardVal + 2, 1) or false
        if not contains then 
            logErrf("CHI LEFT failed as insufficient cards in hand card")
            return 
        end 
        local success = self:__outputCard(player.chairID, data.cardVal + 1, 1)
        success = success and self:__outputCard(player.chairID, data.cardVal + 2, 1) or false
        if not success then 
            logErrf("CHI LEFT failed because of failure of remove")
            return 
        end 
    elseif data.chiType == GameDefine.MING_TYPE_CHI_MID then 
        if self:__isGangCard(data.cardVal + 1) or self:__isGangCard(data.cardVal - 1) then 
            logErrf("Chi nor allowed if the chi cards contain laizi, laizipi or hongzhong")
            return 
        end
        local contains = self:containsCard(player.chairID, data.cardVal + 1, 1)
        contains = contains and self:containsCard(player.chairID, data.cardVal - 1, 1) or false
        if not contains then 
            logErrf("CHI MID failed as insufficient cards in hand card")
            return 
        end 
        local success = self:__outputCard(player.chairID, data.cardVal + 1, 1)
        success = success and self:__outputCard(player.chairID, data.cardVal - 1, 1) or false
        if not success then 
            logErrf("CHI MID failed because of failure of remove")
            return 
        end 
    elseif data.chiType == GameDefine.MING_TYPE_CHI_RIGHT then 
        if self:__isGangCard(data.cardVal - 2) or self:__isGangCard(data.cardVal - 1) then 
            logErrf("Chi nor allowed if the chi cards contain laizi, laizipi or hongzhong")
            return 
        end
        local contains = self:containsCard(player.chairID, data.cardVal - 1, 1)
        contains = contains and self:containsCard(player.chairID, data.cardVal - 2, 1) or false
        if not contains then 
            logErrf("CHI RIGHT failed as insufficient cards in hand card")
            return 
        end 
        local success = self:__outputCard(player.chairID, data.cardVal - 1, 1)
        success = success and self:__outputCard(player.chairID, data.cardVal - 2, 1) or false
        if not success then 
            logErrf("CHI RIGHT failed because of failure of remove")
            return 
        end 
    else
        logErrf("invalid chiType")
        return
    end 
    table.insert(player.mingCards, {cardVal = self.watchCard.cardVal, mingType = data.chiType})
    player.watchOpCnt = player.watchOpCnt + 1
    if player.watchOpCnt == 3 then 
        player.theThird = self.watchCard.chairID
    end 
    local watchPlayer = self.players[self.watchCard.chairID]
    assert(watchPlayer.uselessCards[#watchPlayer.uselessCards] == self.watchCard.cardVal)
    watchPlayer.uselessCards[#watchPlayer.uselessCards] = nil --remove from watchplayer's useless cards
    self:__resetWatch()
    table.insert(self.actionsQue, {chairID = player.chairID, 
                                    act = GameDefine.PLAY_ACT_CHI, 
                                    data = {cardVal = data.cardVal,
                                            chiType = data.chiType,}})
    self:SendTableMsg(CMD_HNMJ.SUB_S_ACTION_CHI, 
        "Gamemsg.ms_action_chi", 
        {userid = pServerUserItem.UserID, 
        cardVal = data.cardVal,
        chiType = data.chiType,
        sponsorUserID = watchPlayer.userid,})

--    logNormalf("[%s]\ninput: %s\noutput: %s, \nresult: %s", 
--                    "mc_action_chi", 
--                    table.tostring(data, true), 
--                    table.tostring({userid = pServerUserItem.UserID, 
--                                    cardVal = data.cardVal,
--                                    chiType = data.chiType}, true), 
--                    table.tostring(self, true))
    
    self:__indicatePlayerOutCard(self.whosTurnChairID)
end 

function TableGameMain:__doActionPeng(pServerUserItem, data)
    local player = self.players[pServerUserItem.UserInfo.ChairID]
    local canPeng = MJLogic.canPeng(player.handCards, self.watchCard.cardVal, GameDefine.getCardType(self.watchCard.cardVal))
    if not canPeng then 
        logErrf("validate failed of PENG")
        return
    end 
    local success = self:__outputCard(player.chairID, self.watchCard.cardVal, 2)
    if not success then 
        logErrf("failed remove cards of PENG")
        return
    end 
    table.insert(player.mingCards, {cardVal = self.watchCard.cardVal, mingType = GameDefine.MING_TYPE_PENG})
    player.watchOpCnt = player.watchOpCnt + 1
    if player.watchOpCnt == 3 then 
        player.theThird = self.watchCard.chairID
    end 
    local watchPlayer = self.players[self.watchCard.chairID]
    assert(watchPlayer.uselessCards[#watchPlayer.uselessCards] == self.watchCard.cardVal)
    watchPlayer.uselessCards[#watchPlayer.uselessCards] = nil --remove from watchplayer's useless card
    self:__resetWatch()
    table.insert(self.actionsQue, {chairID = player.chairID, 
                                    act = GameDefine.PLAY_ACT_PENG, 
                                    data = {cardVal = data.cardVal}})
    self:SendTableMsg(CMD_HNMJ.SUB_S_ACTION_PENG, 
        "Gamemsg.ms_action_peng", 
        {userid = pServerUserItem.UserID, 
        cardVal = data.cardVal,
        sponsorUserID = watchPlayer.userid,})

--    logNormalf("[%s]\ninput: %s\noutput: %s, \nresult: %s", 
--                    "mc_action_peng", 
--                    table.tostring(data, true), 
--                    table.tostring({userid = pServerUserItem.UserID, cardVal = data.cardVal}, true), 
--                    table.tostring(self, true))
    
    self:__indicatePlayerOutCard(self.whosTurnChairID)
end 

function TableGameMain:__doActionGang(pServerUserItem, data)
    local player = self.players[pServerUserItem.UserInfo.ChairID]
    local watchPlayer
    if data.mingType == GameDefine.MING_TYPE_MING_GANG then 
        if data.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_PENG then 
            if self:__isGangCard(data.cardVal) then 
                logErrf("MING GANG PENG not allowed with laizi, laizipi or hongzhong")
                return 
            end 
            --search an available gang card
            local tmpMingCards = {}
            local found = false
            for _, mingCard in ipairs(player.mingCards) do 
                if mingCard.cardVal == data.cardVal and mingCard.mingType == GameDefine.MING_TYPE_PENG then 
                    found = true
                else
                    table.insert(tmpMingCards, mingCard)
                end 
            end 
            if not found then 
                logErrf("MING GANG PENG found nothing")
                return
            end 
            local success = self:__outputCard(player.chairID, data.cardVal, 1)
            if not success then 
                logErrf("MING GANG PENG failed as remove card %d failed", data.cardVal)
                return
            end 
            player.mingCards = tmpMingCards
            table.insert(player.mingCards, {cardVal = data.cardVal, 
                                            mingType = GameDefine.MING_TYPE_MING_GANG,
                                            subMingType = data.subMingType})
            self.sysCardVal = 0
        elseif data.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_WATCH then 
            if data.cardVal ~= self.watchCard.cardVal then 
                logErrf("MING GANG TING should equal to sysCardVal")
                return 
            end 
            if self:__isGangCard(data.cardVal) then 
                logErrf("MING GANG WATCH not allowed with laizi, laizipi or hongzhong")
                return 
            end 
            local contains = self:containsCard(player.chairID, data.cardVal, 3)
            if not contains then 
                logErrf("insufficient card to MING GANG TING")
                return
            end 
            local success = self:__outputCard(player.chairID, data.cardVal, 3)
            if not success then 
                logErrf("MING GANG TING failed as remove card %d failed", data.cardVal)
                return
            end 
            table.insert(player.mingCards, {cardVal = self.watchCard.cardVal, 
                                            mingType = GameDefine.MING_TYPE_MING_GANG,
                                            subMingType = data.subMingType})
            watchPlayer = self.players[self.watchCard.chairID]
            assert(watchPlayer.uselessCards[#watchPlayer.uselessCards] == self.watchCard.cardVal)
            watchPlayer.uselessCards[#watchPlayer.uselessCards] = nil --remove from watchplayer's useless cards
            player.watchOpCnt = player.watchOpCnt + 1
            if player.watchOpCnt == 3 then 
                player.theThird = self.watchCard.chairID
            end 
            self:__resetWatch()
        elseif data.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_GANG_PAI then --杠牌明杠
            if data.cardVal == self.hongZhongCardVal or data.cardVal == self.laiZiPiCardVal then 
                local success = self:__outputCard(player.chairID, data.cardVal, 1)
                if not success then 
                    logErrf("MING_TYPE_MING_GANG_SUB_GANG_PAI failed as remove card %d failed", data.cardVal)
                    return
                end 
            elseif data.cardVal == self.laiZiCardVal and player.laisOwned > 0 then 
                player.laisOwned = player.laisOwned - 1
            else 
                logErrf("MING GANG invalid gang pai: %d", data.cardVal)
                return
            end 
            table.insert(player.mingCards, {cardVal = data.cardVal, 
                                            mingType = GameDefine.MING_TYPE_MING_GANG,
                                            subMingType = data.subMingType})
        else
            logErrf("invalid subMingType: %d", data.subMingType)
            return
        end 
    elseif data.mingType == GameDefine.MING_TYPE_AN_GANG then 
        if self.sysCardVal == 0 then 
            logErrf("AN GANG is match non-zero sysCardVal")
            return 
        end 
        if self:__isGangCard(data.cardVal) then 
            logErrf("MING_TYPE_AN_GANG not allowed with laizi, laizipi or hongzhong")
            return 
        end 
        local success = self:__outputCard(player.chairID, data.cardVal, 4)
        if not success then 
            logErrf("AN GANG failed as remove card %d failed", data.cardVal)
            return
        end 
        table.insert(player.mingCards, {cardVal = data.cardVal, 
                                        mingType = GameDefine.MING_TYPE_AN_GANG,
                                        subMingType = data.subMingType})
        self.sysCardVal = 0
    else 
        logErrf("invalid mingType %d", data.mingType)
    end 
    table.insert(self.actionsQue, {chairID = player.chairID, 
                                    act = GameDefine.PLAY_ACT_GANG_PLAYBACK, 
                                    data = {cardVal = data.cardVal,
                                            mingType = data.mingType,
                                            subMingType = data.subMingType,}})
    self:SendTableMsg(CMD_HNMJ.SUB_S_ACTION_GANG, 
        "Gamemsg.ms_action_gang", 
        {userid = pServerUserItem.UserID, 
        cardVal = data.cardVal,
        mingType = data.mingType, 
        subMingType = data.subMingType,
        sponsorUserID = watchPlayer and watchPlayer.userid or 0,})

--    logNormalf("[%s]\ninput: %s\noutput: %s, \nresult: %s", 
--                    "mc_action_gang", 
--                    table.tostring(data, true), 
--                    table.tostring({userid = pServerUserItem.UserID, 
--                        cardVal = data.cardVal,
--                        mingType = data.mingType, 
--                        subMingType = data.subMingType}, true), 
--                    table.tostring(self, true))
    self:__resetWatch()
    if not self:__isGangCard(data.cardVal) and data.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_PENG then
        local myChairID = pServerUserItem.UserInfo.ChairID
        local nextChairID = (myChairID + 1) % self.wChairCount
        nextChairID = nextChairID == 0 and self.wChairCount or nextChairID
        while nextChairID ~= myChairID do 
            local tmpPlayer = self.players[nextChairID]
            local canHu = self:__canHu(tmpPlayer.chairID, data.cardVal, tmpPlayer.chairID, {huType = GameDefine.HU_TYPE_QIANG_GANG})
            local watchPlayer = nil --{chairID = ?, action = ?, priority = ?}
            if canHu then 
                watchPlayer = {chairID = nextChairID, 
                                action = GameDefine.PLAY_ACT_HU, 
                                huType = GameDefine.HU_TYPE_QIANG_GANG,
                                gangCardVal = data.cardVal, 
                                gangChairID = player.chairID, 
                                priority = GameDefine.WATCH_PRIORITY_HU}
                table.insert_sort(self.watchQue, watchPlayer, function(old, new)
                    return new.priority < old.priority
                end)
            end 
            nextChairID = (nextChairID + 1) % self.wChairCount
            nextChairID = nextChairID == 0 and self.wChairCount or nextChairID
        end 
    end 
    --dispatch system card
    if #self.watchQue > 0 then 
        self:__systemDispatchCardNormal()
    else 
        self:__systemDispatchCardWei(player.chairID)
    end 
end 

function TableGameMain:__doActionGuo(pServerUserItem, data)
    local player = self.players[pServerUserItem.UserInfo.ChairID]
    table.insert(self.actionsQue, {chairID = player.chairID, 
                                    act = GameDefine.PLAY_ACT_GUO, 
                                    data = nil})
    self:SendTableMsg(CMD_HNMJ.SUB_S_ACTION_GUO, 
        "Gamemsg.ms_action_guo", 
        {userid = pServerUserItem.UserID}) 

--    logNormalf("[%s]\ninput: %s\noutput: %s, \nresult: %s", 
--                    "mc_action_guo", 
--                    table.tostring(data, true), 
--                    table.tostring({userid = pServerUserItem.UserID}, true), 
--                    table.tostring(self, true))
    if self:isInWatchMode() then 
        local curWatch = self:currentHuWatch()
        if curWatch then 
            if curWatch.huType then 
                if curWatch.huType == GameDefine.HU_TYPE_HAI_DI_LAO then 
                    self:__systemDispatchCardNormal()
                elseif curWatch.huType == GameDefine.HU_TYPE_QIANG_GANG then 
                    local nextWatch = self:tryNextWatch()
                    if not nextWatch then 
                        self:__systemDispatchCardWei(curWatch.gangChairID)
                    else
                        self:__systemDispatchCardNormal()
                    end 
                elseif curWatch.huType == GameDefine.HU_TYPE_DIAN_PAO then 
                    self.whosTurnChairID = self.watchCard.chairID --出牌的轮转回到听牌发起者手中
                    self:__systemDispatchCardNormal()
                else
                    error()
                end 
            else
                self.whosTurnChairID = self.watchCard.chairID --出牌的轮转回到听牌发起者手中
                self:__systemDispatchCardNormal()
            end 
        else
            self.whosTurnChairID = self.watchCard.chairID --出牌的轮转回到听牌发起者手中
            self:__systemDispatchCardNormal()
        end 
    else 
        self:__indicatePlayerOutCard(self.whosTurnChairID)
    end 
end 

function TableGameMain:__doActionHu(pServerUserItem, data)
    local player = self.players[pServerUserItem.UserInfo.ChairID]
    local result = self:__analyseHu(player.chairID)
    if not result.success then 
        logErrf("arbitration failed for %d's turn for HU", pServerUserItem.UserID)
        return 
    end 
    table.insert(self.actionsQue, {
        chairID = player.chairID, 
        act = GameDefine.PLAY_ACT_HU, 
        data = {
            huType = result.huType,
        }
    })
    table.insert(self.jiePaoUsers, {chairID = result.chairID})
    self.gameResult = result
    local ms_action_hu = {
        userid = player.userid, 
        huType = result.huType,
        sponsorChairID = 0,
    }
    if self.gameResult.huType == GameDefine.HU_TYPE_DIAN_PAO then 
        ms_action_hu.sponsorChairID = self.gameResult.huData.outChairID
    elseif self.gameResult.huType == GameDefine.HU_TYPE_QIANG_GANG then 
        ms_action_hu.sponsorChairID = self.gameResult.huData.gangChairID
    end 
    self:SendTableMsg(CMD_HNMJ.SUB_S_ACTION_HU, 
        "Gamemsg.ms_action_hu", 
        ms_action_hu) 

--    logNormalf("[%s]\ninput: %s\noutput: %s, \nresult: %s", 
--                    "mc_action_hu", 
--                    table.tostring(data, true), 
--                    table.tostring(ms_action_hu, true), 
--                    table.tostring(self, true))

    --dispatch system card
    self:gameOver(GameDefine.GAME_OVER_TYPE_HU)
end 

function TableGameMain:__canAction(pServerUserItem, act)
    if self.enGameStatus ~= enum_GameStatus.GS_PLAYING then 
        logErrf("[RoomID: %d][UserID: %d][ChairID: %d][Action: %d] current room status is not in playing", 
            self.TableInfo.RoomNum, 
            pServerUserItem.UserID, 
            pServerUserItem.UserInfo.ChairID,
            act)
        return false
    end 
    if pServerUserItem.UserInfo.ChairID ~= self.whosTurnChairID then 
        logErrf("[RoomID: %d][UserID: %d][ChairID: %d][Action: %d] it's not your turn", 
            self.TableInfo.RoomNum, 
            pServerUserItem.UserID, 
            pServerUserItem.UserInfo.ChairID,
            act)
        return false
    end 
    local player = self.players[pServerUserItem.UserInfo.ChairID]
    if player.isDelegate then 
        logErrf("[RoomID: %d][UserID: %d][ChairID: %d][Action: %d] player is in delegate mode", 
            self.TableInfo.RoomNum, 
            pServerUserItem.UserID, 
            pServerUserItem.UserInfo.ChairID,
            act)
        return false
    end 
    --check if contains specified action
    local contains = false
    for _, actVal in ipairs(self.waitingActions) do 
        if actVal == act then 
            return true
        end 
    end 
    logErrf("[RoomID: %d][UserID: %d][ChairID: %d][Action: %d] no action about this can be found in waiting actions", 
        self.TableInfo.RoomNum, 
        pServerUserItem.UserID, 
        pServerUserItem.UserInfo.ChairID,
        act)
    return false
end 

function TableGameMain:__onActionOutCard(pServerUserItem, data)
    if not self:__canAction(pServerUserItem, GameDefine.PLAY_ACT_OUT) then 
        self:SendTableMsg(
            CMD_HNMJ.SUB_S_OUT_CARD, 
            "Gamemsg.ms_out_card", 
            {err = ErrorDefine.UNAVAILAVLE_ACTION},
            pServerUserItem.UserInfo.ChairID
        ) 
        return 
    end 
    self.waitingActions = {}
    self:__doActionOutCard(pServerUserItem, data)
end 

function TableGameMain:__onActionGuo(pServerUserItem, data)
    if not self:__canAction(pServerUserItem, GameDefine.PLAY_ACT_GUO) then 
        self:SendTableMsg(
            CMD_HNMJ.SUB_S_OUT_CARD, 
            "Gamemsg.ms_action_guo", 
            {err = ErrorDefine.UNAVAILAVLE_ACTION},
            pServerUserItem.UserInfo.ChairID
        ) 
        return 
    end 
    self.waitingActions = {}
    self:__doActionGuo(pServerUserItem, data)
end 

function TableGameMain:__onActionPeng(pServerUserItem, data)
    if not self:__canAction(pServerUserItem, GameDefine.PLAY_ACT_PENG) then 
        self:SendTableMsg(
            CMD_HNMJ.SUB_S_OUT_CARD, 
            "Gamemsg.ms_action_peng", 
            {err = ErrorDefine.UNAVAILAVLE_ACTION},
            pServerUserItem.UserInfo.ChairID
        ) 
        return 
    end 
    if self:__isHaiDiLao() then 
        logErrf("[RoomID: %d][UserID: %d][ChairID: %d][Action: %d] peng will not be allowed in HAIDILAO", 
            self.TableInfo.RoomNum, 
            pServerUserItem.UserID, 
            pServerUserItem.UserInfo.ChairID,
            GameDefine.PLAY_ACT_PENG)
        self:SendTableMsg(
            CMD_HNMJ.SUB_S_OUT_CARD, 
            "Gamemsg.ms_action_peng", 
            {err = ErrorDefine.UNAVAILAVLE_ACTION},
            pServerUserItem.UserInfo.ChairID
        ) 
        return
    end 
    if self.watchCard.cardVal == 0 or data.cardVal ~= self.watchCard.cardVal then 
        logErrf("[RoomID: %d][UserID: %d][ChairID: %d][Action: %d] unmatched watch card", 
            self.TableInfo.RoomNum, 
            pServerUserItem.UserID, 
            pServerUserItem.UserInfo.ChairID,
            GameDefine.PLAY_ACT_PENG)
        self:SendTableMsg(
            CMD_HNMJ.SUB_S_OUT_CARD, 
            "Gamemsg.ms_action_peng", 
            {err = ErrorDefine.UNAVAILAVLE_ACTION},
            pServerUserItem.UserInfo.ChairID
        ) 
        return
    end 
    self.waitingActions = {}
    self:__doActionPeng(pServerUserItem, data)
end 

function TableGameMain:__onActionHu(pServerUserItem, data)
    if not self:__canAction(pServerUserItem, GameDefine.PLAY_ACT_HU) then 
        self:SendTableMsg(
            CMD_HNMJ.SUB_S_OUT_CARD, 
            "Gamemsg.ms_action_hu", 
            {err = ErrorDefine.UNAVAILAVLE_ACTION},
            pServerUserItem.UserInfo.ChairID
        ) 
        return 
    end 
    self.waitingActions = {}
    self:__doActionHu(pServerUserItem, data)
end 

function TableGameMain:__onActionGang(pServerUserItem, data)
    local playAct = 0
    if data.mingType == GameDefine.MING_TYPE_MING_GANG and 
        data.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_GANG_PAI then 
        playAct = GameDefine.PLAY_ACT_OUT
    else 
        if data.mingType == GameDefine.MING_TYPE_AN_GANG or 
            data.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_PENG then 
            playAct = GameDefine.PLAY_ACT_GANG_INITIATIVE
        else 
            playAct = GameDefine.PLAY_ACT_GANG_WATCH
        end 
    end 
    if not self:__canAction(pServerUserItem, playAct) then 
        self:SendTableMsg(
            CMD_HNMJ.SUB_S_OUT_CARD, 
            "Gamemsg.ms_action_gang", 
            {err = ErrorDefine.UNAVAILAVLE_ACTION},
            pServerUserItem.UserInfo.ChairID
        ) 
        return 
    end 
    if self:__isHaiDiLao() then 
        logErrf("[RoomID: %d][UserID: %d][ChairID: %d][Action: %d] action not be allowed in haidilao mode", 
            self.TableInfo.RoomNum, 
            pServerUserItem.UserID, 
            pServerUserItem.UserInfo.ChairID,
            playAct)
        self:SendTableMsg(
            CMD_HNMJ.SUB_S_OUT_CARD, 
            "Gamemsg.ms_action_gang", 
            {err = ErrorDefine.UNAVAILAVLE_ACTION},
            pServerUserItem.UserInfo.ChairID
        ) 
        return
    end 
    if playAct == GameDefine.PLAY_ACT_GANG_WATCH then 
        if self.watchCard.cardVal == 0 or data.cardVal ~= self.watchCard.cardVal then 
            logErrf("[RoomID: %d][UserID: %d][ChairID: %d][Action: %d] unmatched watch card", 
                self.TableInfo.RoomNum, 
                pServerUserItem.UserID, 
                pServerUserItem.UserInfo.ChairID,
                playAct)
            self:SendTableMsg(
                CMD_HNMJ.SUB_S_OUT_CARD, 
                "Gamemsg.ms_action_peng", 
                {err = ErrorDefine.UNAVAILAVLE_ACTION},
                pServerUserItem.UserInfo.ChairID
            ) 
            return
        end 
    end 
    self.waitingActions = {}
    self:__doActionGang(pServerUserItem, data)
end 

function TableGameMain:__onActionChi(pServerUserItem, data)
    if not self:__canAction(pServerUserItem, GameDefine.PLAY_ACT_CHI) then 
        self:SendTableMsg(
            CMD_HNMJ.SUB_S_OUT_CARD, 
            "Gamemsg.ms_action_chi", 
            {err = ErrorDefine.UNAVAILAVLE_ACTION},
            pServerUserItem.UserInfo.ChairID
        ) 
        return 
    end 
    if self:__isHaiDiLao() then 
        logErrf("[RoomID: %d][UserID: %d][ChairID: %d][Action: %d] action not be allowed in haidilao mode", 
            self.TableInfo.RoomNum, 
            pServerUserItem.UserID, 
            pServerUserItem.UserInfo.ChairID,
            GameDefine.PLAY_ACT_CHI)
        self:SendTableMsg(
            CMD_HNMJ.SUB_S_OUT_CARD, 
            "Gamemsg.ms_action_chi", 
            {err = ErrorDefine.UNAVAILAVLE_ACTION},
            pServerUserItem.UserInfo.ChairID
        ) 
        return
    end 
    if self.watchCard.cardVal == 0 or data.cardVal ~= self.watchCard.cardVal then 
        logErrf("[RoomID: %d][UserID: %d][ChairID: %d][Action: %d] unmatched watch card", 
            self.TableInfo.RoomNum, 
            pServerUserItem.UserID, 
            pServerUserItem.UserInfo.ChairID,
            GameDefine.PLAY_ACT_CHI)
        self:SendTableMsg(
            CMD_HNMJ.SUB_S_OUT_CARD, 
            "Gamemsg.ms_action_chi", 
            {err = ErrorDefine.UNAVAILAVLE_ACTION},
            pServerUserItem.UserInfo.ChairID
        ) 
        return
    end 
    self.waitingActions = {}
    self:__doActionChi(pServerUserItem, data)
end 

function TableGameMain:__onPlayerTing(pServerUserItem, data)
    local player = self.players[pServerUserItem.UserInfo.ChairID]
    if player.isInTingMode then 
        logErrf("Player %d is in ting mode already", player.userid)
        return 
    end 
    local canTing = self:__canTing(player.chairID)
    if not canTing then 
        logErrf("Player %d insufficient conditions to go Ting mode", player.userid)
        return 
    end 
    player.isInTingMode = true 
    table.insert(self.actionsQue, {chairID = player.chairID, 
                                    act = GameDefine.PLAY_ACT_TING, 
                                    data = nil})
    self:SendTableMsg(CMD_HNMJ.SUB_S_ACTION_CHI, 
        "Gamemsg.ms_player_ting", 
        {userid = pServerUserItem.UserID})
end 

function TableGameMain:mc_game_record(pServerUserItem, data)
    local player = self.players[pServerUserItem.UserInfo.ChairID]
    
    local ms_game_record = {
        statistics = {},
    }
    for userid, statRecords in pairs(self.statistics) do 
        local statistic = {
            userid = userid, 
            rollStats = {},
        }
        for rollNO, statRecord in ipairs(statRecords) do 
            table.insert(statistic.rollStats, {rollNO = rollNO, score = statRecord[GameDefine.STAT_TYPE_RECORD]})
        end 
        table.insert(ms_game_record.statistics, statistic)
    end 
    self:SendTableMsg(CMD_HNMJ.SUB_S_GAME_RECORD, 
        "Gamemsg.ms_game_record", 
        ms_game_record,
        pServerUserItem.UserInfo.ChairID)
end 

function TableGameMain:mc_game_delegate(pServerUserItem, data)
    local player = self.players[pServerUserItem.UserInfo.ChairID]
    if data.delegate == player.isDelegate then 
        logErrf("[RoomID: %d][UserID: %d][ChairID: %d] Player being in status %s", 
            self.TableInfo.RoomNum, 
            pServerUserItem.UserID, 
            pServerUserItem.UserInfo.ChairID,
            tostring(data.delegate))
        self:SendTableMsg(
            CMD_HNMJ.SUB_S_GAME_DELEGATE, 
            "Gamemsg.ms_game_delegate", 
            {err = ErrorDefine.ILLEGAL_OP,
            userid = pServerUserItem.UserID},
            pServerUserItem.UserInfo.ChairID
        ) 
        return
    end 
    player.isDelegate = data.delegate
    self:SendTableMsg(CMD_HNMJ.SUB_S_GAME_DELEGATE, 
        "Gamemsg.ms_game_delegate", 
        {
            userid = pServerUserItem.UserID,
            delegate = player.isDelegate,
    })
    if self.whosTurnChairID == player.chairID then 
        self:__resetActionTimer()
        local nowTime = os.time()
        local timeLeft = GameDefine.ACTION_WAIT_TIME - (nowTime - self.waitingStartTime)
        if player.isDelegate then 
            self:SetGameTimer(1, 0 * 1000, 1, player.userid)
        else 
            self:SetGameTimer(1, timeLeft * 1000, 1, player.userid)
        end 
    end 
end 

function TableGameMain:mc_chat(pServerUserItem, data)
    local player = self.players[pServerUserItem.UserInfo.ChairID]
    self:SendTableMsg(CMD_HNMJ.SUB_S_CHAT, 
        "Gamemsg.ms_chat", 
        {
            userid = pServerUserItem.UserID,
            typ = data.typ,
            content = data.content,
    })
end 

function TableGameMain:onGameMessage(wSubCmdID, pDataBuffer, wDataSize, pServerUserItem)
    local t1 = os.clock()
    if wSubCmdID == CMD_HNMJ.SUB_C_OUT_CARD then
        local data = protobuf.decode("Gamemsg.mc_out_card", pDataBuffer, pDataSize)
        self:__onActionOutCard(pServerUserItem, data)
    elseif wSubCmdID == CMD_HNMJ.SUB_C_ACTION_GUO then
        local data = protobuf.decode("Gamemsg.mc_action_guo", pDataBuffer, pDataSize)
        self:__onActionGuo(pServerUserItem, data)
    elseif wSubCmdID == CMD_HNMJ.SUB_C_ACTION_PENG then
        local data = protobuf.decode("Gamemsg.mc_action_peng", pDataBuffer, pDataSize)
        self:__onActionPeng(pServerUserItem, data)
    elseif wSubCmdID == CMD_HNMJ.SUB_C_ACTION_HU then
        local data = protobuf.decode("Gamemsg.mc_action_hu", pDataBuffer, pDataSize)
        self:__onActionHu(pServerUserItem, data)
    elseif wSubCmdID == CMD_HNMJ.SUB_C_ACTION_GANG then
        local data = protobuf.decode("Gamemsg.mc_action_gang", pDataBuffer, pDataSize)
        self:__onActionGang(pServerUserItem, data)
    elseif wSubCmdID == CMD_HNMJ.SUB_C_ACTION_CHI then
        local data = protobuf.decode("Gamemsg.mc_action_chi", pDataBuffer, pDataSize)
        self:__onActionChi(pServerUserItem, data)
    elseif wSubCmdID == CMD_HNMJ.SUB_C_PLAYER_TING then
        local data = protobuf.decode("Gamemsg.mc_player_ting", pDataBuffer, pDataSize)
        self:__onPlayerTing(pServerUserItem, data)
    elseif wSubCmdID == CMD_HNMJ.SUB_C_LEAVE_ROOM then
        if self.enGameStatus ~= enum_GameStatus.GS_FREE then 
            logErrf("current room %d status is not in free, operation SUB_C_LEAVE_ROOM denied", self.wTableID)
            return 
        end 
        self:SendTableMsg(CMD_HNMJ.SUB_S_LEAVE_ROOM, 
            "Gamemsg.ms_leave_room", 
            {userid = pServerUserItem.UserID}) 
    elseif wSubCmdID == CMD_HNMJ.SUB_C_GAME_RECORD then
        local data = protobuf.decode("Gamemsg.mc_game_record", pDataBuffer, pDataSize)
        self:mc_game_record(pServerUserItem, data)
    elseif wSubCmdID == CMD_HNMJ.SUB_C_GAME_DELEGATE then
        local data = protobuf.decode("Gamemsg.mc_game_delegate", pDataBuffer, pDataSize)
        self:mc_game_delegate(pServerUserItem, data)
    elseif wSubCmdID == CMD_HNMJ.SUB_C_CHAT then
        local data = protobuf.decode("Gamemsg.mc_chat", pDataBuffer, pDataSize)
        self:mc_chat(pServerUserItem, data)
    else 
        logErrf("no corresponding command process func for game sub command: %d", wSubCmdID)
        return
    end
    local t2 = os.clock()
    local elpase = (math.floor((t2 - t1) * 10000) / 10)
    logNormalf("ROOM SERVER, SubCmd: %d, Elapse: %.1fms", wSubCmdID, elpase)
    return true
end

function TableGameMain:__resetActionTimer()
    self:KillTableTimer(GameDefine.TIMER_ID_AUTO_ACTION)
end 

function TableGameMain:__newActionTimer()
    if not self.config.autoOutCard then 
        return 
    end 
    local player = self.players[self.whosTurnChairID]
    if not player then 
        return 
    end 
    if player.isDelegate then 
        self:SetGameTimer(GameDefine.TIMER_ID_AUTO_ACTION, (GameDefine.DELEGATE_WAIT_TIME) * 1000, 1, player.userid)
    else 
        self:SetGameTimer(GameDefine.TIMER_ID_AUTO_ACTION, (GameDefine.ACTION_WAIT_TIME + 3) * 1000, 1, player.userid)
    end 
end 

function TableGameMain:__resetSysDispatchTimer()
    self:KillTableTimer(GameDefine.TIMER_ID_SYS_DISPATCH_CARD)
end 

function TableGameMain:__newSysDispatchTimer(time, chairID)
    self:SetGameTimer(GameDefine.TIMER_ID_SYS_DISPATCH_CARD, time * 1000, 1, chairID)
end 

function TableGameMain:onGameTimerMessage(dwTimerID, dwBindParam)
    print(string.format("TimerID: %d", dwTimerID))
    if dwTimerID == GameDefine.TIMER_ID_AUTO_ACTION then 
        self:__doTimerAutoAction(dwBindParam)
    elseif dwTimerID == GameDefine.TIMER_ID_SYS_DISPATCH_CARD then 
        self:__doTimerSysDispatchCard(dwBindParam)
    else 
        assert(false)
    end 
end

function TableGameMain:__doTimerSysDispatchCard(dwBindParam)
    local chairID = dwBindParam
    self:__systemDispatchCardNormal(chairID)
end 

function TableGameMain:__doTimerAutoAction(dwBindParam)
    local userid = dwBindParam 
    --find server user item
    local pServerUserItem
    for _, useritem in pairs(self.pUserItems) do 
        if useritem.UserID == userid then 
            pServerUserItem = useritem
            break 
        end 
    end 
    if not pServerUserItem then 
        logWarningf("Player %d may be exited from this room: %d", userid, self.TableInfo.RoomNum)
        return 
    end 
    if self.enGameStatus ~= enum_GameStatus.GS_PLAYING then 
        return false
    end 
    if pServerUserItem.UserInfo.ChairID ~= self.whosTurnChairID then 
        return false
    end 
    if #self.waitingActions == 0 then 
        return false
    end 
    local player = self.players[pServerUserItem.UserInfo.ChairID]
    if not player.isDelegate then 
        player.isDelegate = true
        self:SendTableMsg(CMD_HNMJ.SUB_S_GAME_DELEGATE, 
            "Gamemsg.ms_game_delegate", 
            {
                userid = pServerUserItem.UserID,
                delegate = player.isDelegate,
        })
    end 
    self:__autoAction(pServerUserItem)
end 

function TableGameMain:__autoAction(pServerUserItem)
    local player = self.players[pServerUserItem.UserInfo.ChairID]
    if not player.isDelegate then 
        return false 
    end 
    if #self.waitingActions == 1 and self.waitingActions[1] == GameDefine.PLAY_ACT_OUT then 
        --random a card and out
        local handCardsAry = {}
        for cardType, cards in pairs(player.handCards) do 
            for _, card in ipairs(cards.cards) do 
                for i = 1, card.num, 1 do 
                    table.insert(handCardsAry, card.cardVal)
                end 
            end 
        end 
        for i = 1, player.laisOwned, 1 do 
            table.insert(handCardsAry, self.laiZiCardVal)
        end 
        local function out(outCardVal)
            if self:__isGangCard(outCardVal) then 
                self:__doActionGang(pServerUserItem, {
                    cardVal = outCardVal,
                    mingType = GameDefine.MING_TYPE_MING_GANG,
                    subMingType = GameDefine.MING_TYPE_MING_GANG_SUB_GANG_PAI,
                })
            else 
                self:__doActionOutCard(pServerUserItem, {
                    cardVal = outCardVal,
                })
            end 
        end 
        --查找红中或者赖子皮
        for _, cardVal in pairs(handCardsAry) do 
            if cardVal == self.laiZiPiCardVal or 
                cardVal == self.hongZhongCardVal then 
                out(cardVal)
                return true
            end 
        end 
        --查找单张风牌
        for cardType, cards in pairs(player.handCards) do 
            for _, card in ipairs(cards.cards) do 
                local cardType = GameDefine.getCardType(card.cardVal)
                if card.num == 1 and cardType == GameDefine.CARD_TYPE_ZI then 
                    out(card.cardVal)
                    return true
                end 
            end 
        end 
        --find last dispatched card
        if self.sysCardVal ~= 0 then 
            for _, cardVal in pairs(handCardsAry) do 
                if cardVal == self.sysCardVal then 
                    out(cardVal)
                    return true
                end 
            end 
        end 
        --随机一张牌出去
        local ndx = math.random(1, #handCardsAry)
        local outCardVal = handCardsAry[ndx]
        out(outCardVal)
    else 
        --是否可以胡
        for _, actVal in pairs(self.waitingActions) do 
            if actVal == GameDefine.PLAY_ACT_HU then 
                self:__doActionHu(pServerUserItem, {})
                return true
            end 
        end 
        --do GUO action
        self:__doActionGuo(pServerUserItem, {})
    end 
    return true
end 

--发送当前场景
function TableGameMain:SendGameScene(pServerUserItem)
    --initialize room create params
    local robot = false
    if not self.roomInited then
        local createParams = json.decode(self.TableInfo.createParams or "")
        for _, option in pairs(string.split(createParams.options or "", ",")) do 
            if option ~= "" then 
                self.options[option] = true
            end 
        end 
        robot = createParams.robot or false
        self.fans = createParams.fans or GameDefine.INI_FANS
        self.fengDingMulti = createParams.fengDingMulti or GameDefine.INI_FENG_DING_MULTI
        self.roomType = createParams.roomType or GameDefine.ROOM_TYPE_NORMAL
        self.roomLevel = createParams.roomLevel or 0
        self.roomInited = true
        if self.roomType == GameDefine.ROOM_TYPE_GOLD_MATCH then 
            self.config.autoOutCard = true
        end 
        --TODO need a notify when room be created
    end 
    --send players basic information
    --if free, send a command, if play, send other play information
    for _, item in pairs(self.pUserItems) do 
        local player = self.players[item.UserInfo.ChairID]
        local roomPlayerInfo = {}
        roomPlayerInfo.userid = item.UserID
        roomPlayerInfo.nickname = item.UserInfo.nickname or tostring(item.UserID)
        roomPlayerInfo.playerIcon = item.UserInfo.HeadImageUrl or ""
        roomPlayerInfo.playerIP = tostring(item.ClientIP)
        roomPlayerInfo.playerScore = item.playerScore or 0
        roomPlayerInfo.chairID = item.UserInfo.ChairID
        roomPlayerInfo.status = item.UserInfo.UserStatus
        roomPlayerInfo.gender = item.UserInfo.Sex
        roomPlayerInfo.score = player and player.score or GameDefine.INI_SCORE
        roomPlayerInfo.location = {
            jingdu = item.UserInfo.Jingdu,
	        weidu = item.UserInfo.Weidu,
	        permissiondenied = item.UserInfo.PermissionDenied,
	        userid = item.UserID,
	        city = item.UserInfo.City,
	        district = item.UserInfo.District,
	        address = item.UserInfo.Address
        }
        self:SendTableMsg(CMD_HNMJ.SUB_S_ROOM_PLAYERS_INFO, 
            "Gamemsg.ms_room_players_info", 
            {players = {roomPlayerInfo}}, 
            pServerUserItem.UserInfo.ChairID) 
    end 
    if self.enGameStatus == enum_GameStatus.GS_FREE then 
        self:SendTableMsg(CMD_HNMJ.SUB_S_GAME_SCENE_FREE, 
            "Gamemsg.ms_game_scene_free", 
            {}, 
            pServerUserItem.UserInfo.ChairID) 

--        logNormalf("[%s]\ninput: %s\noutput: %s, \nresult: %s", 
--                        "ms_game_scene_free", 
--                        table.tostring({}, true), 
--                        table.tostring({}, true), 
--                        table.tostring(self, true))
        if robot and pServerUserItem == self.pCreaterUserItem then 
            --TODO play with AI
            self:RequetAIPlay(self.wChairCount - 1)
        end 

    elseif self.enGameStatus == enum_GameStatus.GS_PLAYING then 
        local jiePaoUsers = {}
        for _, jiePao in pairs(self.jiePaoUsers) do 
            jiePaoUsers[jiePao.chairID] = jiePao
        end 
        local actionWaitTime = self.waitingStartTime == 0 and 
            GameDefine.ACTION_WAIT_TIME or 
            (GameDefine.ACTION_WAIT_TIME - (os.time() - self.waitingStartTime))
        actionWaitTime = actionWaitTime < 0 and 0 or actionWaitTime
        local ms_game_scene_play = {
            zhuangID = self.zhuangID,
            cardsRemainCnt = self:__getCardsRemainsCnt(),
            whosTurnChairID = self.whosTurnChairID,
            players = {},
            watchCard = {cardVal = self.watchCard.cardVal, chairID = self.watchCard.chairID},
            actions = {},
            laiZiCardVal = self.laiZiCardVal,
            laiZiPiCardVal = self.laiZiPiCardVal,
            shaiZi1Val = self.shaiZi1Val,
            shaiZi2Val = self.shaiZi2Val,
            baoZiVal = self.baoZiVal,
            actionWaitTime = actionWaitTime,
        }
        for _, actVal in ipairs(self.waitingActions) do 
            table.insert(ms_game_scene_play.actions, actVal)
        end 
        
        local playersHandCards = {}
        local rollPlayers = {}
        for chairID, player in pairs(self.players) do 
            local userid = player.userid 
            local rollPlayer = {
                    userid = userid, 
                    huType = 0, 
                    handCards = {}, 
                    mingCards = {}, 
                    uselessCards = {},
                    handCardsNum = 0,
                    isInTingMode = player.isInTingMode,
                    score = player.score,
                    isDelegate = player.isDelegate,}
            playersHandCards[userid] = {}
            if jiePaoUsers[chairID] then 
                rollPlayer.huType = 1
            end 
            for cardType, cards in pairs(player.handCards) do 
                for _, card in ipairs(cards.cards) do 
                    for i = 1, card.num, 1 do 
                        table.insert(playersHandCards[userid], card.cardVal)
                    end 
                end 
            end 
            for i = 1, player.laisOwned, 1 do 
                table.insert(playersHandCards[userid], self.laiZiCardVal)
            end 
            if player.userid == pServerUserItem.UserID then 
                rollPlayer.handCards = playersHandCards[userid]
            end 
            for _, mingCard in ipairs(player.mingCards) do 
                table.insert(rollPlayer.mingCards, {cardVal = mingCard.cardVal, 
                                                    mingType = mingCard.mingType, 
                                                    subMingType = mingCard.subMingType})
            end 
            for _, cardVal in ipairs(player.uselessCards) do 
                table.insert(rollPlayer.uselessCards, cardVal)
            end 
            rollPlayer.handCardsNum = #playersHandCards[userid]
            table.insert(ms_game_scene_play.players, rollPlayer)
            rollPlayers[userid] = rollPlayer
        end 
        if pServerUserItem.UserInfo.ChairID ~= self.whosTurnChairID then 
            if not (self.waitingActions and #self.waitingActions == 1 and 
                self.waitingActions[1] == GameDefine.PLAY_ACT_OUT) then 
                ms_game_scene_play.actions = {}
                ms_game_scene_play.whosTurnChairID = 0
            end 
        end 
        self:SendTableMsg(CMD_HNMJ.SUB_S_GAME_SCENE_PLAY, 
            "Gamemsg.ms_game_scene_play", 
            ms_game_scene_play,
            pServerUserItem.UserInfo.ChairID)

--    logNormalf("[%s]\ninput: %s\noutput: %s, \nresult: %s", 
--                    "ms_game_scene_play", 
--                    table.tostring({}, true), 
--                    table.tostring(ms_game_scene_play, true), 
--                    table.tostring(self, true))
    end 
end

--游戏开始
function TableGameMain:onGameStart()
    self:__onGameStart()
--    self:__onGameStartTest()
end

function TableGameMain:__onGameStart()
    if self.enGameStatus ~= enum_GameStatus.GS_PLAYING then 
        logErrf("current room %d status is not in playing, operation onGameStart denied", self.wTableID)
        return 
    end 
    --initialize system cards
    local tmp = {}
    --setup cards
    if self.totalCardsNum == 0 then 
        self.systemCards = {}
        for i, cardType in pairs(GameDefine[GameDefine.MJ_HG].CardTypes) do 
            local endCardSeq = 9
            if cardType == GameDefine.CARD_TYPE_ZI then 
                endCardSeq = 7
            end 
            for j = 1, endCardSeq, 1 do 
                local cardVal = cardType * 10 + j
                table.insert(self.systemCards, cardVal)
                table.insert(self.systemCards, cardVal)
                table.insert(self.systemCards, cardVal)
                table.insert(self.systemCards, cardVal)
            end 
        end 

        self.totalCardsNum = #self.systemCards
    end 
    --shuffle
    local cardStart = 1
    local cardEnd = table.maxn(self.systemCards)
    for i = 1, table.maxn(self.systemCards), 1 do 
        local idx = math.random(cardStart, cardEnd)
        self.systemCards[idx], self.systemCards[cardEnd] = self.systemCards[cardEnd], self.systemCards[idx]
        cardEnd = cardEnd - 1
    end 
    --last roll data
    local oldGameResult = self.gameResult
    --reset data
    self.distributedCardsCnt = 0
    self.weiCardsDistributedCnt = 0
    self.whosTurnChairID = 0
    self.sysCardVal = 0
    self:__resetWatch()
    self.jiePaoUsers = {}
    self.actionsQue = {}
    self.gameResult = nil
    self.waitingActions = {}
    self.waitingStartTime = 0

    --distribute cards to each player
    local zhuangChairID = 0
    if not oldGameResult then--第一局
        zhuangChairID = self.pCreaterUserItem.UserInfo.ChairID -- math.random(1, #self.pUserItems)
    elseif oldGameResult.chairID == 0 then --上一局流局
        for _, player in pairs(self.players) do 
            if player.userid == self.zhuangID then 
                zhuangChairID = player.chairID
                break
            end 
        end 
    else
        zhuangChairID = oldGameResult.chairID
    end 
    self.zhuangID = self.pUserItems[zhuangChairID].UserID
    
    --指定赖子
    local oldLaiZiCardVal = self.laiZiCardVal
    self.distributedCardsCnt = self.distributedCardsCnt + 1
    self:__iniLai(self.systemCards[self.distributedCardsCnt])
    self.baoZiVal = 0
    self.shaiZi1Val = math.random(1, 6)
    self.shaiZi2Val = math.random(1, 6)
    if self.options.baoZi then 
        local laiZiCardType = GameDefine.getCardType(self.laiZiCardVal)
        if laiZiCardType == GameDefine.CARD_TYPE_ZI then --风赖
            self.baoZiVal = GameDefine.BAO_ZI_FENGLAI
        end 
        if self.laiZiCardVal == oldLaiZiCardVal then --连赖
            self.baoZiVal = GameDefine.BAO_ZI_LIANLAI
        end 
        if self.shaiZi1Val == self.shaiZi2Val then --色子一对
            self.baoZiVal = GameDefine.BAO_ZI_SHAIZI
        end 
    end 

    local ms_game_start = {
        zhuangID = self.zhuangID,
        cardsRemainCnt = 0,
        players = {},
        watchCard = {chairID = 0, cardVal = 0},
        laiZiCardVal = 0,
        laiZiPiCardVal = 0,
        shaiZi1Val = self.shaiZi1Val,
        shaiZi2Val = self.shaiZi2Val,
        baoZiVal = self.baoZiVal,
        actionWaitTime = GameDefine.ACTION_WAIT_TIME,
    }
    local playersHandCards = {}
    local rollPlayers = {}
    for chairID, item in pairs(self.pUserItems) do 
        local oldPlayerData = self.players[chairID]
        local userid = item.UserID 
        local player = {userid = userid, 
                        chairID = chairID, 
                        watchOpCnt = 0,
                        laisOwned = 0,
                        isTing = false,
                        theThird = 0,
                        handCards = {}, 
                        mingCards = {}, 
                        uselessCards = {},
                        score = oldPlayerData and oldPlayerData.score or GameDefine.INI_SCORE,
                        isDelegate = false,}
        --reset
        player.laisOwned = 0
        player.isTing = false
        player.theThird = 0
        player.handCards = {}
        player.mingCards = {}
        player.uselessCards = {}

        local rollPlayer = {
                userid = userid, 
                huType = 0, 
                handCards = {}, 
                mingCards = {}, 
                uselessCards = {},
                handCardsNum = 0,
                isInTingMode = player.isInTingMode,
                score = player.score,
                isDelegate = false,}
        playersHandCards[userid] = {}
        local cardsNum = 13
        local tmp = {} 
        for i = 1, cardsNum, 1 do 
            self.distributedCardsCnt = self.distributedCardsCnt + 1
            local cardVal = self.systemCards[self.distributedCardsCnt]
            table.insert(playersHandCards[userid], cardVal)
            tmp[cardVal] = tmp[cardVal] or {cardVal = cardVal, num = 0}
            tmp[cardVal].num = tmp[cardVal].num + 1
        end 
        for cardVal, card in pairs(tmp) do 
            if cardVal == self.laiZiCardVal then 
                player.laisOwned = player.laisOwned + card.num
            else 
                local cardType = GameDefine.getCardType(cardVal)
                player.handCards[cardType] = player.handCards[cardType] or {cardType = cardType, num = 0, cards = {}}
                player.handCards[cardType].num = player.handCards[cardType].num + card.num
                table.insert(player.handCards[cardType].cards, card)
            end 
        end 
        for _, cardsNode in pairs(player.handCards) do 
            table.sort(cardsNode.cards, function(card1, card2)
                return card1.cardVal < card2.cardVal
            end)
        end 
        self.players[chairID] = player
        rollPlayer.handCardsNum = #playersHandCards[userid]
        table.insert(ms_game_start.players, rollPlayer)
        rollPlayers[userid] = rollPlayer
    end 

    ms_game_start.laiZiCardVal = self.laiZiCardVal
    ms_game_start.laiZiPiCardVal = self.laiZiPiCardVal
    ms_game_start.cardsRemainCnt = self:__getCardsRemainsCnt()

    --牌局记录
    self.records.zhuangChairID = zhuangChairID
    self.records.laiZiCardVal = self.laiZiCardVal
    self.records.laiZiPiCardVal = self.laiZiPiCardVal
    self.records.players = {}
    for chairID, playerData in pairs(ms_game_start.players) do 
        self.records.players[chairID] = {
            userid = playerData.userid,
            chairID = chairID,
            score = 0, 
            handCards = table.clone(playersHandCards[playerData.userid]),
        }
    end 
    self.records.startTime = os.time()
    self.records.roomID = self.wTableID
    
    for _, player in pairs(self.players) do 
        local rollPlayer = rollPlayers[player.userid]
        rollPlayer.handCards = playersHandCards[player.userid]
        self:SendTableMsg(CMD_HNMJ.SUB_S_GAME_START, 
            "Gamemsg.ms_game_start", 
            ms_game_start,
            player.chairID) 
        rollPlayer.handCards = {}
    end 

--    logNormalf("[%s]\ninput: %s\noutput: %s, \nresult: %s", 
--                    "ms_game_start", 
--                    table.tostring({}, true), 
--                    table.tostring(ms_game_start, true), 
--                    table.tostring(self, true))
    --向庄家发牌
    self:__resetSysDispatchTimer()
    self:__newSysDispatchTimer(5, self.pUserItems[zhuangChairID].UserInfo.ChairID)
end

function TableGameMain:__onGameStartTest()
    local GameTestData = require("lua.RoomServer.game.GameTestData_P4")
    if self.enGameStatus ~= enum_GameStatus.GS_PLAYING then 
        logErrf("current room %d status is not in playing, operation onGameStart denied", self.wTableID)
        return 
    end 
    --reset data
    self.distributedCardsCnt = 0
    self.weiCardsDistributedCnt = 0
    self.whosTurnChairID = 0
    self.sysCardVal = 0
    self:__resetWatch()
    self.jiePaoUsers = {}
    self.actionsQue = {}
    self.gameResult = nil
    self.waitingActions = {}
    self.waitingStartTime = 0
    --指定赖子
    self.laiZiCardVal = GameTestData.laiZiCardVal
    self.laiZiPiCardVal = GameTestData.laiZiPiCardVal
    self.options = table.clone(GameTestData.options)
    self.baoZiVal = GameTestData.baoZiVal or 0
    self.fans = GameTestData.fans
    self.shaiZi1Val = math.random(1, 6)
    self.shaiZi2Val = math.random(1, 6)
    --initialize system cards
    local tmp = {}
    --setup cards
    self.totalCardsNum = GameTestData.totalCardsNum
    self.systemCards = table.clone(GameTestData.systemCards)

    self.distributedCardsCnt = GameTestData.distributedCardsCnt
    self.weiCardsDistributedCnt = GameTestData.weiCardsDistributedCnt

    self.jiePaoUsers = table.clone(GameTestData.jiePaoUsers)
    self.whosTurnChairID = GameTestData.whosTurnChairID
    if self.whosTurnChairID == 0 then 
        self.whosTurnChairID = self.pCreaterUserItem.UserInfo.ChairID
    end 
    self.sysCardVal = GameTestData.sysCardVal
    self.watchCard = table.clone(GameTestData.watchCard)
    self.watchQue = table.clone(GameTestData.watchQue)
    self.watchProgress = GameTestData.watchProgress

    local ms_game_start = {
        zhuangID = self.zhuangID,
        cardsRemainCnt = 0,
        players = {},
        watchCard = {cardVal = self.watchCard.cardVal, chairID = self.watchCard.chairID},
        laiZiCardVal = 0,
        laiZiPiCardVal = 0,
        shaiZi1Val = self.shaiZi1Val,
        shaiZi2Val = self.shaiZi2Val,
        baoZiVal = self.baoZiVal,
        actionWaitTime = GameDefine.ACTION_WAIT_TIME,
    }
    local playersHandCards = {}
    local rollPlayers = {}
    for chairID, item in pairs(self.pUserItems) do 
        local userid = item.UserID 
        local player = table.clone(GameTestData.players[chairID])
        player.userid = userid
        
        local rollPlayer = {
                userid = userid, 
                huType = 0, 
                handCards = {}, 
                mingCards = {}, 
                uselessCards = {},
                handCardsNum = 0,
                isInTingMode = player.isInTingMode,
                score = player.score,
                isDelegate = false,}
        playersHandCards[userid] = {}
        for cardType, cards in pairs(player.handCards) do 
            for _, card in ipairs(cards.cards) do 
                for i = 1, card.num, 1 do 
                    table.insert(playersHandCards[userid], card.cardVal)
                end 
            end 
        end 
        for i = 1, player.laisOwned, 1 do 
            table.insert(playersHandCards[userid], self.laiZiCardVal)
        end 
        for _, mingCard in ipairs(player.mingCards) do 
            table.insert(rollPlayer.mingCards, {cardVal = mingCard.cardVal, 
                                                mingType = mingCard.mingType, 
                                                subMingType = mingCard.subMingType})
        end 
        for _, cardVal in ipairs(player.uselessCards) do 
            table.insert(rollPlayer.uselessCards, cardVal)
        end 
        self.players[chairID] = player
        rollPlayer.handCardsNum = #playersHandCards[userid]
        table.insert(ms_game_start.players, rollPlayer)
        rollPlayers[userid] = rollPlayer
    end 
    self.zhuangID = self.players[self.whosTurnChairID].userid

    ms_game_start.laiZiCardVal = self.laiZiCardVal
    ms_game_start.laiZiPiCardVal = self.laiZiPiCardVal
    ms_game_start.cardsRemainCnt = self:__getCardsRemainsCnt()
    ms_game_start.zhuangID = self.zhuangID
    
    --牌局记录
    self.records.zhuangChairID = self.whosTurnChairID
    self.records.laiZiCardVal = self.laiZiCardVal
    self.records.laiZiPiCardVal = self.laiZiPiCardVal
    self.records.players = {}
    for chairID, playerData in pairs(ms_game_start.players) do 
        self.records.players[chairID] = {
            userid = playerData.userid,
            chairID = chairID,
            score = 0, 
            handCards = table.clone(playersHandCards[playerData.userid]),
        }
    end 
    self.records.startTime = os.time()
    self.records.roomID = self.wTableID
    
    for _, player in pairs(self.players) do 
        local rollPlayer = rollPlayers[player.userid]
        rollPlayer.handCards = playersHandCards[player.userid]
        self:SendTableMsg(CMD_HNMJ.SUB_S_GAME_START, 
            "Gamemsg.ms_game_start", 
            ms_game_start,
            player.chairID) 
        rollPlayer.handCards = {}
    end 

--    logNormalf("[%s]\ninput: %s\noutput: %s, \nresult: %s", 
--                    "ms_game_start", 
--                    table.tostring({}, true), 
--                    table.tostring(ms_game_start, true), 
--                    table.tostring(self, true))
    --向庄家发牌
--    self:__systemDispatchCardWei(GameTestData.whosTurnChairID)
    self:__systemDispatchCardNormal(self.whosTurnChairID)
end

--游戏结束
function TableGameMain:onGameEnd(endReason)
    self.players = {}
    self.whosTurnChairID = 0
    self.sysCardVal = 0
    self:__resetWatch()
    self.dianPaoChairID = 0
    self.jiePaoUsers = {}
end

function TableGameMain:OnActionUserReconnect(wChairID, pServerUserItem)
end

function TableGameMain:OnActionUserOffLine(wChairID, pServerUserItem)
end

function TableGameMain:OnActionUserSitDown(wChairID, pServerUserItem)
end

function TableGameMain:OnActionUserStandUp(wChairID, pServerUserItem)
end

function TableGameMain:OnActionUserOnReady(wChairID, pServerUserItem)
end

function TableGameMain:onDismiss()
--    PerformanceMeasure.mark("onDismiss")
    local roomRecord = {
        roomID = self.TableInfo.RoomNum,
        people = self.wChairCount,
        roomCreaterUserID = self.pCreaterUserItem.UserID,
        playersInfo = {},
    }
--    PerformanceMeasure.mark("onDismiss")
    local scores = {}
    for userid, statRecords in pairs(self.statistics) do 
        local score = 0
        for _, statRecord in ipairs(statRecords) do 
            score = score + statRecord[GameDefine.STAT_TYPE_RECORD]
        end 
        scores[userid] = scores[userid] or {userid = userid, score = score}
    end 
--    PerformanceMeasure.mark("onDismiss")
    for _, pServerUserItem in pairs(self.pUserItems) do 
        table.insert(roomRecord.playersInfo, {
            userid = pServerUserItem.UserID,
            nickname = pServerUserItem.UserInfo.nickname or tostring(pServerUserItem.UserID),
            playerIcon = pServerUserItem.UserInfo.HeadImageUrl or "",
            gender = pServerUserItem.UserInfo.Sex,
            chairID = pServerUserItem.UserInfo.ChairID,
            score = scores[pServerUserItem.UserID] and scores[pServerUserItem.UserID].score or 0,
        })
    end 
--    PerformanceMeasure.mark("onDismiss")

--    logNormalf("record_room: %s", table.tostring(roomRecord, true))

    local bufRoomRecord = protobuf.encode("Gamemsg.record_room", roomRecord)
--    PerformanceMeasure.mark("onDismiss")
    
    local userids = {}
    for _, pServerUserItem in pairs(self.pUserItems) do 
        table.insert(userids, pServerUserItem.UserID)
    end 
    local roomData = {
        userids = userids,
        roomguid = self.TableInfo.RoomGuid,
        recorddata = bufRoomRecord,
        createtime = self.TableInfo.CreateTime,
        begintime = self.TableInfo.BeginTime,
        dismisstime = os.time(),
        totalplayedcount = self.TableInfo.TotalPlayedCount,
        createrolls = self.TableInfo.Rolls,
        createParams = self.TableInfo.createParams,
    }
--    PerformanceMeasure.mark("onDismiss")
    
    GameRecord:RecordRoom(roomData)
--    PerformanceMeasure.mark("onDismiss")

    --notify client
    
    local ms_prev_dismiss = {
        err = 0,
        statPlayers = {},
    }
    for _, pServerUserItem in pairs(self.pUserItems) do 
        local userid = pServerUserItem.UserID
        local stats = self.statistics[userid]
        if stats then 
            local statPlayer = {
                userid = userid,
                stats = {},
            }
            local playerStats = {}
            for _, stat in pairs(stats) do 
                for statType, value in pairs(stat) do 
                    playerStats[statType] = playerStats[statType] or 0
                    playerStats[statType] = playerStats[statType] + value
                end 
            end 
            for statType, value in pairs(playerStats) do 
                table.insert(statPlayer.stats, {statType = statType, statValue = value})
            end 
            table.insert(ms_prev_dismiss.statPlayers, statPlayer)
        end 
    end 
--    PerformanceMeasure.mark("onDismiss")

    self:SendTableMsg(CMD_HNMJ.SUB_S_PREV_DISMISS, 
        "Gamemsg.ms_prev_dismiss", 
        ms_prev_dismiss) 
--    PerformanceMeasure.mark("onDismiss")
--    PerformanceMeasure.dump()
end 


--endregion
