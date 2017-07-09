--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local GamePlayer = require("app.modules.game.GamePlayer")
local MJLogic = require("app.modules.game.MJLogic")
local GameDefine = require("app.modules.game.GameDefine")

local GameCache = class("GameCache")

local seatDirMap = GameDefine.SeatDirMap

function GameCache:ctor()
    self:reset()
    
    Network:registerMsgProc(Define.SERVER_GAME, "ms_create_room", self, "ms_create_room")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_join_room", self, "ms_join_room")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_room_info", self, "ms_room_info")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_game_start", self, "ms_game_start")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_game_over", self, "ms_game_over")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_system_dispatch_card", self, "ms_system_dispatch_card")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_room_players_info", self, "ms_room_players_info")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_sit_down", self, "ms_sit_down")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_game_scene_free", self, "ms_game_scene_free")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_game_scene_play", self, "ms_game_scene_play")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_user_offline", self, "ms_user_offline")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_user_reconnect", self, "ms_user_reconnect")    
    Network:registerMsgProc(Define.SERVER_GAME, "mc_ms_talk", self, "mc_ms_talk")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_location", self, "ms_location")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_userstatus_change", self, "ms_userstatus_change")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_cheaters_confirm", self, "ms_cheaters_confirm")

    Network:registerMsgProc(Define.SERVER_GAME, "ms_out_card", self, "ms_out_card")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_action_guo", self, "ms_action_guo")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_action_peng", self, "ms_action_peng")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_action_hu", self, "ms_action_hu")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_action_gang", self, "ms_action_gang")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_action_chi", self, "ms_action_chi")
--    Network:registerMsgProc(Define.SERVER_GAME, "ms_leave_room", self, "ms_leave_room")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_player_ready", self, "ms_player_ready")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_player_ting", self, "ms_player_ting")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_haidilao", self, "ms_haidilao")

    Network:registerMsgProc(Define.SERVER_GAME, "ms_stand_up", self, "ms_stand_up")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_dismiss", self, "ms_dismiss")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_dismiss_confirm", self, "ms_dismiss_confirm")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_dismiss_fail", self, "ms_dismiss_fail")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_game_record", self, "ms_game_record")
    Network:registerMsgProc(Define.SERVER_GAME, "ms_prev_dismiss", self, "ms_prev_dismiss")

    Event.register(EventDefine.VOICE_UPLOAD_FINISH,self,"voice_upload_finish")

    Event.register(EventDefine.ICON_DOWNLOADED, self, "ICON_DOWNLOADED")
end 

function GameCache:reset()
    self.roomID = 0
    self.mjType = GameDefine.MARJIANG_TYPE_ZHUANZHUAN
    self.rolls = 8
    self.people = 4
    self.options = {baoZi = false,}
    self.roomCreaterUserID = 0 --房主
    self.fans = 0
    self.players = {}
    self.laiZiCardVal = 0
    self.laiZiPiCardVal = 0
    self.hongZhongCardVal = GameDefine.CARD_TYPE_ZI * 10 + 9 --红中

    self.zhuangID = 0
    self.whosTurnChairID = 0 --当前轮到的出牌的玩家ID
    self.gameResult = {} --胡牌结果
    self.watchCard = {cardVal, chairID = 0}
    self.cardsRemainCnt = 0
    self.actions = {}
    self.shaiZi1Val = 0
    self.shaiZi2Val = 0
    self.baoZiVal = 0
    self.actionWaitTime = 0

    --local update
    self.playersByChair = {}
    self.roomStatus = 0
end 

function GameCache:__resetActions()
    self.whosTurnChairID = 0
    self.actions = {}
    self.actionWaitTime = 0
end 

function GameCache:__updateSeatDirOf(player)
    if player.userid == PlayerCache.userid then 
        player.seatDir = GameDefine.DIR_BOTTOM
        return
    end 
    local myself = self.players[PlayerCache.userid]
    local myChairID = myself.chairID
    local delta = player.chairID - myChairID
    local seatDirNdx = (delta + self.people) % self.people + 1
    player.seatDir = seatDirMap[self.people][seatDirNdx]
end 

function GameCache:isGangCard(cardVal)
    if cardVal == self.laiZiCardVal or 
        cardVal == self.laiZiPiCardVal or 
        cardVal == self.hongZhongCardVal then 
        return true 
    end 
    return false
end 

function GameCache:__initSeatDir()
    local myself = self.players[PlayerCache.userid]
    assert(myself, "join room data must includes player itself")
    myself.seatDir = GameDefine.DIR_BOTTOM
    --initialize seat dir
    local myChairID = myself.chairID
    for _, player in pairs(self.players) do 
        if player.userid ~= myself.userid then 
            local delta = player.chairID - myChairID
            local seatDirNdx = (delta + self.people) % self.people + 1
            player.seatDir = seatDirMap[self.people][seatDirNdx]
        end
    end 
end 

function GameCache:isMyTurn()
    if self.roomID == 0 then 
        return false
    end 
    local myself = self.players[PlayerCache.userid]
    return self.whosTurnChairID == myself.chairID
end 

function GameCache:getGangs()
    local gangs = {}
    local player = self.players[PlayerCache.userid]
    for _, mingCard in ipairs(player.mingCards) do 
        if mingCard.mingType == GameDefine.MING_TYPE_PENG then 
            if self:isGangCard(mingCard.cardVal) then --杠牌是不应该被碰的
                assert(false)
            end 
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
                        table.insert(gangs, gang)
                    end 
                end 
            end 
        end 
    end 
    for _, snglTypeHandCards in pairs(player.handCards) do 
        if snglTypeHandCards.num > 0 then 
            for _, card in ipairs(snglTypeHandCards.cards) do 
                if (not self:isGangCard(card.cardVal)) and card.num == 4 then 
                    local gang = {
                        cardVal = card.cardVal, 
                        mingType = GameDefine.MING_TYPE_AN_GANG,
                        subMingType = 0,
                    }
                    table.insert(gangs, gang)
                end 
            end 
        end 
    end 
    return gangs
end 

function GameCache:ms_create_room(data)
    printInfo("GameCache:MS_CREATE_ROOM")
    Event.dispatch("MS_CREATE_ROOM", data)
end

function GameCache:ms_join_room(data)
    printInfo("GameCache:MS_JOIN_ROOM")
    Event.dispatch("MS_JOIN_ROOM", data)
end

function GameCache:ms_room_info(data)
    printInfo("GameCache:MS_ROOM_INFO")
    self:reset()

    self.roomID = data.roomInfo.roomID
    self.roomCreaterUserID = data.roomInfo.roomCreaterUserID
    self.rolls = data.roomInfo.rolls
    self.people = data.roomInfo.people
    self.rollsCnt = data.roomInfo.rollsCnt
    
    local createParams = json.decode(data.roomInfo.createParams)
    self.fans = createParams.fans
    for _, option in pairs(string.split(createParams.options or "", ",")) do 
        self.options[option] = true
    end 

    --initialize
    self.sysCardVal = 0
    self.watchCard = {cardVal = 0, chairID= 0}
    self.action = 0

    --TODO test
    UserDefaultExt:set("roomID", self.roomID)

    Event.dispatch("MS_ROOM_INFO", data)
end 

function GameCache:ms_game_scene_free(data)
    printInfo("GameCache:MS_GAME_SCENE_FREE")
    self:__initSeatDir()
    self.roomStatus = GameDefine.enum_GameStatus.GS_FREE

    Event.dispatch("MS_GAME_SCENE_FREE", data)
end

function GameCache:ms_room_players_info(data)
    printInfo("GameCache:MS_ROOM_PLAYERS_INFO")
    for _, playerData in pairs(data.players) do 
        local player = GamePlayer:create(playerData)
        print("GameCache:ms_room_players_info player userid: %d", player.userid)
        self.players[player.userid] = player
        self.playersByChair[player.chairID] = player
        local localIcon = IconManager:getIcon(playerData.userid, playerData.playerIcon)
        if localIcon then 
            player.playerIcon = localIcon
        end 
    end 
    self:checkOthersCheating()
    Event.dispatch("MS_ROOM_PLAYERS_INFO", data)
end

function GameCache:ms_sit_down(data)
    printInfo("GameCache:MS_SIT_DOWN")
    local playerData = data.player
    local player = GamePlayer:create(playerData)
    self:__updateSeatDirOf(player)
    self.players[player.userid] = player
    self.playersByChair[player.chairID] = player
    local localIcon = IconManager:getIcon(playerData.userid, playerData.playerIcon)
    if localIcon then 
        player.playerIcon = localIcon
    end 
    
    self:checkOthersCheating()
    Event.dispatch("MS_SIT_DOWN", data)
end

function GameCache:ms_game_scene_play(data)
    printInfo("GameCache:MS_GAME_SCENE_PLAY")
    self.zhuangID = data.zhuangID
    self.cardsRemainCnt = data.cardsRemainCnt
    self.whosTurnChairID = data.whosTurnChairID
    self.watchCard = {
        cardVal = data.watchCard.cardVal, 
        chairID = data.watchCard.chairID,
    }
    self.laiZiCardVal = data.laiZiCardVal
    self.laiZiPiCardVal = data.laiZiPiCardVal
    self.shaiZi1Val = data.shaiZi1Val
    self.shaiZi2Val = data.shaiZi2Val
    self.baoZiVal = data.baoZiVal
    self.actions = {}
    for _, actVal in ipairs(data.actions) do 
        table.insert(self.actions, actVal)
    end 
    self.actionWaitTime = data.actionWaitTime
    
    self:__initSeatDir()
    self.roomStatus = GameDefine.enum_GameStatus.GS_PLAYING

    for _, rollPlayerData in pairs(data.players) do 
        assert(self.players[rollPlayerData.userid] ~= nil, string.format("player %d join room first", rollPlayerData.userid))
        local player = self.players[rollPlayerData.userid]
        player.huType = rollPlayerData.huType or 0
        player.handCards = {} --clear
        player.isZhuang = rollPlayerData.userid == data.zhuangID
        player.isInTingMode = rollPlayerData.isInTingMode
        player.handCardsNum = rollPlayerData.handCardsNum or 0
        player.score = rollPlayerData.score
        local tmp = {}
        for _, cardVal in ipairs(rollPlayerData.handCards) do 
            local cardType = GameDefine.getCardType(cardVal)
            tmp[cardVal] = tmp[cardVal] or {cardVal = cardVal, cardType = cardType, num = 0}
            tmp[cardVal].num = tmp[cardVal].num + 1
        end 
        for _, card in pairs(tmp) do 
            local cardType = GameDefine.getCardType(card.cardVal)
            player.handCards[cardType] = player.handCards[cardType] or {cardType = cardType, num = 0, cards = {}}
            player.handCards[cardType].num = player.handCards[cardType].num + card.num
            table.insert(player.handCards[card.cardType].cards, card)
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

    Event.dispatch("MS_GAME_SCENE_PLAY", data)
end 

function GameCache:ms_stand_up(data)
    self.players[data.userid] = nil 
    Event.dispatch("MS_STAND_UP", data)
end 

function GameCache:checkOthersCheating()
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then 
        return
    end 
    local otherPlayers = {}
    for _,player in pairs(self.players) do
        if player.userid ~= PlayerCache.userid then
            table.insert(otherPlayers,player)
        end
    end
    
    if #otherPlayers < 2 then
        return false
    end
    for i = 1, #otherPlayers do
        if otherPlayers[i].jingdu ~= Define.INVALID_JINGDU then
            for j = i+1, #otherPlayers do
                if otherPlayers[j].jingdu ~= Define.INVALID_JINGDU then
                    if AmapSDK:calculateLineDistance(otherPlayers[i].jingdu,otherPlayers[i].weidu,otherPlayers[j].jingdu,otherPlayers[j].weidu) < Define.WARING_DISTANCE then
                        local msg = string.format("玩家 %s 与玩家 %s 距离小于 %d 米。",
                            otherPlayers[i].nickname,otherPlayers[j].nickname,Define.WARING_DISTANCE)
                        UIManager:showTip(msg)
                    end
                end
            end            
        end        
    end
end

function GameCache:voice_upload_finish(data)
    if data.bSuccess then
        Network:send(Define.SERVER_GAME,"mc_ms_talk",{userid = PlayerCache.userid,talkurl=data.fileurl,time=data.time})
        return
    end
    UIManager:showTip("语音发送失败")
end
function GameCache:mc_ms_talk(data)
    local params = {}
    params.userid = data.userid
    params.time = data.time

    VoiceSDK:playRecord(data.talkurl,self.players[data.userid].chairID,json.encode(params))
end

function GameCache:ms_location(data)
    local player = self.players[data.userid] 
    assert(player)
    player.jingdu = data.jingdu
    player.weidu = data.weidu
    player.permissiondenied = data.permissiondenied
    player.city = data.city
    player.district = data.district
    player.address = data.address
--    self:checkOthersCheating()
end

function GameCache:ms_userstatus_change(data)
    if not self.players[data.userid] then
        return
    end
    self.players[data.userid].status = data.userstatus

    Event.dispatch("MS_USERSTATUS_CHANGE", data)
end

function GameCache:ms_cheaters_confirm(data)
    Event.dispatch("MS_CHEATERS_CONFIRM", data)
end

function GameCache:ms_user_reconnect(data)
    if not self.players[data.userid] then 
        printInfo("client not ready yet")
        return
    end 
    self.players[data.userid].isOffline = false
    Event.dispatch("MS_USER_RECONNECT", data)
end 

function GameCache:ms_user_offline(data)
    self.players[data.userid].isOffline = true
    Event.dispatch("MS_USER_OFFLINE", data)
end 

function GameCache:ms_game_ready(data)
    local player = self.players[data.userid]
    if not player then 
        return
    end 
    player.ready = true
    Event.dispatch("MS_GAME_READY", data)
end 

function GameCache:ms_system_dispatch_card(data)
    local player = self.playersByChair[data.whosTurnChairID]
    assert(player ~= nil, string.format("player chair %d room data not found", data.whosTurnChairID))

    if data.cardVal ~= 0 then 
        self.cardsRemainCnt = data.cardsRemainCnt
        if player.userid == PlayerCache.userid then 
            player:inputCard(data.cardVal)
        else 
            player:incCardsNum(1)
        end 
    end 
    self.whosTurnChairID = data.whosTurnChairID
    self.actionWaitTime = data.actionWaitTime

    self.actions = {}
    for _, actVal in ipairs(data.actions or {}) do 
        table.insert(self.actions, actVal)
    end 

    Event.dispatch("MS_SYSTEM_DISPATCH_CARD", data)
end 

function GameCache:ms_out_card(data)
    if not data.err or data.err == 0 then 
        local player = self.players[data.userid]
        assert(player ~= nil, string.format("player %d room data not found", data.userid))
        if player.userid == PlayerCache.userid then 
            player:outputCard(data.cardVal, 1)
        else 
            player:decCardsNum(1)
        end 
        table.insert(player.uselessCards, data.cardVal) --add it to useless cards

        self.watchCard.cardVal = data.cardVal
        self.watchCard.chairID = player.chairID
    
        self:__resetActions()
    end 

    Event.dispatch("MS_OUT_CARD", data)
end 

function GameCache:ms_action_guo(data)
    if not data.err or data.err == 0 then 
        self:__resetActions()
    end 
    Event.dispatch("MS_ACTION_GUO", data)
end

function GameCache:ms_action_peng(data)
    if not data.err or data.err == 0 then 
        local player = self.players[data.userid]
        assert(player)
        if player.userid == PlayerCache.userid then 
            player:outputCard(data.cardVal, 2)
        else 
            player:decCardsNum(2)
        end 
        table.insert(player.mingCards, {cardVal = data.cardVal, mingType = GameDefine.MING_TYPE_PENG})
        --reste watch card
        local watchPlayer = self.players[data.sponsorUserID]
        assert(watchPlayer.uselessCards[#watchPlayer.uselessCards] == self.watchCard.cardVal)
        watchPlayer.uselessCards[#watchPlayer.uselessCards] = nil

        self:__resetActions()
    end 

    Event.dispatch("MS_ACTION_PENG", data)
end

function GameCache:ms_action_hu(data)
    if not data.err or data.err == 0 then 
        self:__resetActions()
    end 
    
    Event.dispatch("MS_ACTION_HU", data)
end

function GameCache:ms_action_gang(data)
    if not data.err or data.err == 0 then 
        local player = self.players[data.userid]
        assert(player)
        if data.mingType == GameDefine.MING_TYPE_MING_GANG then 
            if data.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_PENG then 
                for i, mingCard in ipairs(player.mingCards) do 
                    if mingCard.cardVal == data.cardVal and mingCard.mingType == GameDefine.MING_TYPE_PENG then 
                        table.move(player.mingCards, i)
                        break
                    end 
                end 
                if player.userid == PlayerCache.userid then 
                    player:outputCard(data.cardVal, 1)
                else 
                    player:decCardsNum(1)
                end 
                table.insert(player.mingCards, {cardVal = data.cardVal, mingType = data.mingType, subMingType = data.subMingType})
            elseif data.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_WATCH then 
                if player.userid == PlayerCache.userid then 
                    player:outputCard(data.cardVal, 3)
                else 
                    player:decCardsNum(3)
                end 
                table.insert(player.mingCards, {cardVal = data.cardVal, mingType = data.mingType, subMingType = data.subMingType})
                local watchPlayer = self.players[data.sponsorUserID]
                assert(watchPlayer.uselessCards[#watchPlayer.uselessCards] == self.watchCard.cardVal)
                watchPlayer.uselessCards[#watchPlayer.uselessCards] = nil
            elseif data.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_GANG_PAI then 
                if player.userid == PlayerCache.userid then 
                    player:outputCard(data.cardVal, 1)
                else 
                    player:decCardsNum(1)
                end 
                table.insert(player.mingCards, {cardVal = data.cardVal, mingType = data.mingType, subMingType = data.subMingType})
            else
                assert(false)
            end 
        elseif data.mingType == GameDefine.MING_TYPE_AN_GANG then 
            if player.userid == PlayerCache.userid then 
                player:outputCard(data.cardVal, 4)
            else 
                player:decCardsNum(4)
            end 
            table.insert(player.mingCards, {cardVal = data.cardVal, mingType = data.mingType, subMingType = data.subMingType})
        else
            assert(false)
        end 
        self:__resetActions()
    end 

    Event.dispatch("MS_ACTION_GANG", data)
end

function GameCache:ms_action_chi(data)
    if not data.err or data.err == 0 then 
        local player = self.players[data.userid]
        assert(player)
        if player.userid == PlayerCache.userid then 
            if data.chiType == GameDefine.MING_TYPE_CHI_LEFT then 
                player:outputCards({{cardVal = data.cardVal + 1, num = 1}, {cardVal = data.cardVal + 2, num = 1}})
            elseif data.chiType == GameDefine.MING_TYPE_CHI_MID then 
                player:outputCards({{cardVal = data.cardVal + 1, num = 1}, {cardVal = data.cardVal - 1, num = 1}})
            elseif data.chiType == GameDefine.MING_TYPE_CHI_RIGHT then 
                player:outputCards({{cardVal = data.cardVal - 1, num = 1}, {cardVal = data.cardVal - 2, num = 1}})
            else
                assert(false)
            end 
        else 
            player:decCardsNum(2)
        end 
        table.insert(player.mingCards, {cardVal = data.cardVal, mingType = data.chiType})

        local watchPlayer = self.players[data.sponsorUserID]
        assert(watchPlayer.uselessCards[#watchPlayer.uselessCards] == self.watchCard.cardVal)
        watchPlayer.uselessCards[#watchPlayer.uselessCards] = nil
        self:__resetActions()
    end 

    Event.dispatch("MS_ACTION_CHI", data)
end

function GameCache:ms_haidilao(data)
    for _, playCard in ipairs(data.cards) do 
        local player = self.playersByChair[playCard.chairID]
        assert(player ~= nil, string.format("player chair %d room data not found", playCard.chairID))
        self.cardsRemainCnt = self.cardsRemainCnt - 1
        if player.userid == PlayerCache.userid then 
            player:inputCard(playCard.cardVal)
        else 
            player:incCardsNum(1)
        end 
    end
    self:__resetActions()

    --distrubute
    Event.dispatch("MS_HAIDILAO", data)
end

function GameCache:ms_game_start(data)
    printInfo("GameCache:ms_game_start")
    self.zhuangID = data.zhuangID
    self.cardsRemainCnt = data.cardsRemainCnt
    self.whosTurnChairID = 0
    self.watchCard = {
        cardVal = data.watchCard.cardVal, 
        chairID = data.watchCard.chairID,
    }
    self.laiZiCardVal = data.laiZiCardVal
    self.laiZiPiCardVal = data.laiZiPiCardVal
    self.roomStatus = GameDefine.enum_GameStatus.GS_PLAYING
    self.shaiZi1Val = data.shaiZi1Val
    self.shaiZi2Val = data.shaiZi2Val
    self.baoZiVal = data.baoZiVal
    self.actionWaitTime = data.actionWaitTime
    self.actions = {}
    
    self:__initSeatDir()

    for _, rollPlayerData in pairs(data.players) do 
        assert(self.players[rollPlayerData.userid] ~= nil, string.format("player %d join room first", rollPlayerData.userid))
        local player = self.players[rollPlayerData.userid]
        player.huType = rollPlayerData.huType or 0
        player.handCards = {} --clear
        player.handCardsNum = rollPlayerData.handCardsNum or 0
        player.isZhuang = rollPlayerData.userid == data.zhuangID
        player.isInTingMode = rollPlayerData.isInTingMode
        player.score = rollPlayerData.score
        local tmp = {}
        for _, cardVal in ipairs(rollPlayerData.handCards) do 
            local cardType = GameDefine.getCardType(cardVal)
            tmp[cardVal] = tmp[cardVal] or {cardVal = cardVal, cardType = cardType, num = 0}
            tmp[cardVal].num = tmp[cardVal].num + 1
        end 
        for _, card in pairs(tmp) do 
            local cardType = GameDefine.getCardType(card.cardVal)
            player.handCards[cardType] = player.handCards[cardType] or {cardType = cardType, num = 0, cards = {}}
            player.handCards[cardType].num = player.handCards[cardType].num + card.num
            table.insert(player.handCards[card.cardType].cards, card)
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

    Event.dispatch("MS_GAME_START", data)
end

function GameCache:ms_game_over(data)
    if not data.err or data.err == 0 then 
        self.rollsCnt = self.rollsCnt + 1
        self.roomStatus = GameDefine.enum_GameStatus.GS_FREE
        self.gameResult = {
            result = data.result,
            players = {},
            statPlayers = {},
        }
        for k, playerData in ipairs(data.players) do 
            local balancePlayer = {userid = playerData.userid,
                handCards = {}, 
                mingCards = {},
                huType = playerData.huType, 
                huCardVal = playerData.huCardVal,
                fans = playerData.fans,
                score = playerData.score,
                scoreTypes = {}, --得分类型
                baoHu = playerData.baoHu,
                isSponsor = playerData.isSponsor,
            }
            for _, cardVal in ipairs(playerData.handCards) do 
                table.insert(balancePlayer.handCards, cardVal)
            end 
            for _, mingCard in ipairs(playerData.mingCards) do 
                table.insert(balancePlayer.mingCards, {cardVal = mingCard.cardVal, 
                                                        mingType = mingCard.mingType, 
                                                        subMingType = mingCard.subMingType})
            end 
            for _, scoreType in ipairs(playerData.scoreTypes) do 
                table.insert(balancePlayer.scoreTypes, scoreType)
            end 
            table.insert(self.gameResult.players, balancePlayer)
            --更新积分
            local player = self.players[playerData.userid]
            player.score = player.score + balancePlayer.score
        end 
        for k, statPlayerData in ipairs(data.statPlayers) do 
            local statPlayer = {
                userid = statPlayerData.userid,
                stats = {},
            }
            local stats = {}
            for _, stat in pairs(statPlayerData.stats) do 
                table.insert(statPlayer.stats, {statType = stat.statType, statValue = stat.statValue})
            end 
            table.insert(self.gameResult.statPlayers, statPlayer)
        end
        self.accomplishes = {
            statPlayers = self.gameResult.statPlayers,
        }
    end 
    Event.dispatch("MS_GAME_OVER", data)
end

function GameCache:ms_player_ready(data)
    local player = self.players[data.userid]
    if not player then 
        return
    end 
    Event.dispatch("MS_PLAYER_READY", data)
end

function GameCache:ms_player_ting(data)
    local player = self.players[data.userid]
    assert(player)
    player.isInTingMode = true
    Event.dispatch("MS_PLAYER_TING", data)
end

function GameCache:ms_stand_up(data)
    local player = self.players[data.userid]
    if not player then 
        return
    end 
    --remove player from cache
    self.players[data.userid] = nil
    if data.userid == PlayerCache.userid then 
        --TODO clear cache
    end 
    Event.dispatch("MS_STAND_UP", data)
end

function GameCache:ms_dismiss(data)
    --TODO clear cache
    Event.dispatch("MS_DISMISS", data)
end

function GameCache:ms_dismiss_confirm(data)
    self.dismiss = {}
    self.dismiss.calleruserid = data.calleruserid
    self.dismiss.agreeuserids = table.clone(data.agreeuserids)
    self.dismiss.lefttime = data.lefttime
    Event.dispatch("MS_DISMISS_CONFIRM", data)
end

function GameCache:ms_dismiss_fail(data)
    self.dismiss = nil
    Event.dispatch("MS_DISMISS_FAIL", data)
end

function GameCache:ms_game_record(data)
    local statistics = {}
    for _, statData in ipairs(data.statistics) do 
        local stat = {
            userid = statData.userid,
            rollStats = {},
        }
        for _, rollStat in ipairs(statData.rollStats) do 
            table.insert(stat.rollStats, {
                rollNO = rollStat.rollNO,
                score = rollStat.score,
            })
        end 
        table.insert(statistics, stat)
    end 
    Event.dispatch("MS_GAME_RECORD", statistics)
end

function GameCache:ms_prev_dismiss(data)
    self.accomplishes = {
        statPlayers = {},
    }
    if not data.err or data.err == 0 then 
        for k, statPlayerData in ipairs(data.statPlayers) do 
            local statPlayer = {
                userid = statPlayerData.userid,
                stats = {},
            }
            local stats = {}
            for _, stat in pairs(statPlayerData.stats) do 
                table.insert(statPlayer.stats, {statType = stat.statType, statValue = stat.statValue})
            end 
            table.insert(self.accomplishes.statPlayers, statPlayer)
        end
    end 
    Event.dispatch("MS_PREV_DISMISS", data)
end

function GameCache:ICON_DOWNLOADED(data)
    if data.err then 
        printInfo("[ERROR] [%d] Icon download error: %s", data.userid, data.err.msg)
        return
    end 
    local player = self.players[data.userid]
    if not player then 
        return 
    end 
    player.playerIcon = data.iconFileName
    if not player.playerIcon or player.playerIcon == "" then 
        if player.gender == Define.GENDER_FEMALE then 
            player.playerIcon = "public/head_female.png"
        else
            player.playerIcon = "public/head_male.png"
        end 
    end 
end

return GameCache
--endregion
