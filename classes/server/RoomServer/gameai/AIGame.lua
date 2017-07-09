--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local Event = require("lua.RoomServer.gameai.Event")
local GameCache = require("lua.RoomServer.gameai.GameCache")
local msgdefines = require("lua.RoomServer.gameai.msgdefines")
local GameDefine = require("lua.RoomServer.game.GameDefine")
require("lua.RoomServer.gameai.CompatDefine")

AIGame = Util:newClass({},AIUserItem)

function AIGame:InitGame(roominfo)
    self.roomInfo = roominfo
    self.event = Event()
    self.cache = GameCache({event = self.event, myself = self})
    self.userid = self.UserID
    self.lv = 1 --AI等级

    self.event:dispatch("ms_room_info", {roomInfo = roominfo})
    print(string.format("[%d] %s", self.userid, "ms_room_info"))
    
    self.event:register("MS_SYSTEM_DISPATCH_CARD", self, "MS_SYSTEM_DISPATCH_CARD")
    self.event:register("MS_OUT_CARD", self, "MS_OUT_CARD")
    self.event:register("MS_ACTION_GUO", self, "MS_ACTION_GUO")
    self.event:register("MS_ACTION_PENG", self, "MS_ACTION_PENG")
    self.event:register("MS_ACTION_HU", self, "MS_ACTION_HU")
    self.event:register("MS_ACTION_GANG", self, "MS_ACTION_GANG")
    self.event:register("MS_ACTION_CHI", self, "MS_ACTION_CHI")
    self.event:register("MS_GAME_START", self, "MS_GAME_START")
    self.event:register("MS_GAME_OVER", self, "MS_GAME_OVER")

    self.event:register("UPDATE_ACTION", self, "UPDATE_ACTION")

end

function AIGame:onGameMessage(wSubCmdID, pDataBuffer, wDataSize)
    if not msgdefines["game"][200] or not msgdefines["game"][200][wSubCmdID] then 
        logErrf("no msg defined of mainCmd: %d, subCmd: %d", 200, wSubCmdID)
        return
    end 
    local msgDefine = msgdefines["game"][200][wSubCmdID]
    if not msgDefine.proto then 
        logErrf("no proto defined of %s", msgDefine.name)
        return
    end 
--    print(string.format("[%d] %s", self.userid, msgDefine.name))
    if msgDefine.proto == "" then 
        self.event:dispatch(msgDefine.name, pDataBuffer, wDataSize)
    else 
        local data = protobuf.decode(msgDefine.proto, pDataBuffer, wDataSize)
        self.event:dispatch(msgDefine.name, data)
    end 
end

function AIGame:onFrameMessage(wSubCmdID, pDataBuffer, wDataSize)
    if not msgdefines["game"][100] or not msgdefines["game"][100][wSubCmdID] then 
        logErrf("no msg defined of mainCmd: %d, subCmd: %d", 100, wSubCmdID)
        return
    end 
    local msgDefine = msgdefines["game"][100][wSubCmdID]
    if not msgDefine.proto then 
        logErrf("no proto defined of %s", msgDefine.name)
        return
    end 
    if msgDefine.proto == "" then 
        self.event:dispatch(msgDefine.name, pDataBuffer, wDataSize)
    else 
        local data = protobuf.decode(msgDefine.proto, pDataBuffer, wDataSize)
        self.event:dispatch(msgDefine.name, data)
    end 
end

function AIGame:MS_GAME_START(data)
end 

function AIGame:MS_SYSTEM_DISPATCH_CARD(data)
    if not self.cache:isMyTurn() then
        return 
    end 
    --开始做决策
    local time = math.random(0, 1000)
    self:SetGameTiemr(1, time, 1, 0)
end

function AIGame:MS_OUT_CARD(data)

end

function AIGame:MS_ACTION_GUO(data)

end

function AIGame:MS_ACTION_PENG(data)

end

function AIGame:MS_ACTION_HU(data)

end

function AIGame:MS_ACTION_GANG(data)

end

function AIGame:MS_ACTION_CHI(data)

end

function AIGame:MS_GAME_OVER(data)
    if data.err and data.err ~= 0 then 
        return
    end 
    if self.cache.rollsCnt >= self.cache.rolls then 
        --桌子解散， TODO 玩家数据处理
        return
    end 
    self:send("mc_player_ready", {})
end 

function AIGame:send(msgName, data)
    local msgDefine = msgdefines["game"][msgName]
    if not msgDefine then 
        logErrf("no msg %s defined", msgName)
        return
    end 
    if not msgDefine.proto then 
        logErrf("no proto defined of %s", msgDefine.name)
        return
    end 
    if msgDefine.proto ~= "" then 
        self:SendMsg(msgDefine.mainCmd, msgDefine.subCmd, msgDefine.proto, data)
    else 
        self:SendMsg(msgDefine.mainCmd, msgDefine.subCmd)
    end 
end 

function AIGame:onGameTimerMessage(dwTimerID,dwBindParam)
    function __outCard()
        local myPlayer = self.cache.players[self.UserID]
        local cards = {}
        local gangCards = {}
        for _, handCards in pairs(myPlayer.handCards) do 
            if handCards.num > 0 then 
                for _, card in ipairs(handCards.cards) do 
                    if card.num > 0 then 
                        if self.cache:isGangCard(card.cardVal) then 
                            table.insert(gangCards, card)
                        else
                            table.insert(cards, card)
                        end 
                    end 
                end 
            end 
        end 
        --把赖子杠了
        for _, card in ipairs(gangCards) do 
            if card.num > 1 then
                local data = {}
                data.cardVal = card.cardVal
                data.mingType = GameDefine.MING_TYPE_MING_GANG
                data.subMingType = GameDefine.MING_TYPE_MING_GANG_SUB_GANG_PAI
                self:send("mc_action_gang", data)
                return
            end
        end 
        
        local card = {}
        if (#cards == 0) then 
            local cardNdx = math.random(1, #cards)
            card = cards[cardNdx]
        elseif (#cards == 1) then
            card = cards[1]
        else
            local toDrop = {}
            for index, card in pairs(cards) do
                --PrintTable(card)
                if (card.num < 2) then
                    if (index - 1 == 0) then 
                        if (card.cardType ~= cards[index + 1].cardType or card.cardType ~= cards[index + 1].cardType) then
                            table.insert(toDrop, card)
                        end
                    elseif (index == #cards) then
                        if (card.cardType ~= cards[index - 1].cardType or card.cardType ~= cards[index - 1].cardType) then
                            table.insert(toDrop, card)
                        end
                    else
                        if ((card.cardType ~= cards[index + 1].cardType or card.cardType ~= cards[index + 1].cardType) and (card.cardType ~= cards[index - 1].cardType or card.cardType ~= cards[index - 1].cardType)) then
                            table.insert(toDrop, card)
                        end
                    end
                end 
            end
        
            if (#toDrop ~= 0) then
                local cardNdx = math.random(1, #toDrop)
                card = toDrop[cardNdx]
            else
                local cardNdx = math.random(1, #cards)
                card = cards[cardNdx]
            end
        end
        
        self:send("mc_out_card", {cardVal = card.cardVal})
    end 

    local function hu()
        self:send("mc_action_hu", {})
        return
    end 

    local function peng()
        local data = {
            cardVal = self.cache.watchCard.cardVal
        }
        self:send("mc_action_peng", data)
    end 

    local function gangInitiative()
        local data = {}
        local gangs = self.cache:getGangs()
        data.cardVal = gangs[1].cardVal
        data.mingType = gangs[1].mingType
        data.subMingType = gangs[1].subMingType or 0
        self:send("mc_action_gang", data)
        return
    end 

    local function gangWatch()
        local data = {}
        data.cardVal = self.cache.watchCard.cardVal
        data.mingType = GameDefine.MING_TYPE_MING_GANG
        data.subMingType = GameDefine.MING_TYPE_MING_GANG_SUB_WATCH
        self:send("mc_action_gang", data)
        return
    end 

    local function chi()
        local player = self.cache.players[self.UserID]
        local canBeSelectedGroups = player:getChiGroups(self.cache.watchCard.cardVal)
        local selectGroup = canBeSelectedGroups[1]
        local chiType = GameDefine.calChiType(self.cache.watchCard.cardVal, 
                                                selectGroup.cards[1].cardVal, 
                                                selectGroup.cards[2].cardVal)
        self:send("mc_action_chi", {cardVal = self.cache.watchCard.cardVal, chiType = chiType})
    end 

    local function out()
        __outCard()
    end 

    local function guo()
        self:send("mc_action_guo", {})
    end 

    local function doAction(action)
        if action == GameDefine.PLAY_ACT_CHI then 
            chi()
        elseif action == GameDefine.PLAY_ACT_OUT then 
            out()
        elseif action == GameDefine.PLAY_ACT_HU then 
            hu()
        elseif action == GameDefine.PLAY_ACT_PENG then 
            peng()
        elseif action == GameDefine.PLAY_ACT_GANG_INITIATIVE then 
            gangInitiative()
        elseif action == GameDefine.PLAY_ACT_GANG_WATCH then 
            gangWatch()
        elseif action == GameDefine.PLAY_ACT_GUO then 
            guo()
        else 
            assert(false)
        end 
    end 
    if self.cache.actions and #self.cache.actions > 0 then 
        local actNdx = math.random(1, #self.cache.actions)
        local action = self.cache.actions[actNdx]
        doAction(action)
        return
    end 
    out()
end

--endregion
