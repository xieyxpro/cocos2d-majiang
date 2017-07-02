--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local RollData = class("RollData")

local GamePlayer = require("app.modules.game.GamePlayer")
local GameDefine = require("app.modules.game.GameDefine")
 
function RollData:ctor(room, params)
    self.room = room
    self.zhuangChairID = params.zhuangChairID or 0 
    self.laiZiCardVal = params.laiZiCardVal or 0
    self.laiZiPiCardVal = params.laiZiPiCardVal or 0
    self.hongZhongCardVal = GameDefine.CARD_TYPE_ZI * 10 + 5 --红中
    self.actionsQue = {}
    self.shaiZi1Val = params.shaiZi1Val
    self.shaiZi2Val = params.shaiZi2Val
    
    table.insert(self.actionsQue, {
        chairID = 0,
        act = GameDefine.PLAY_ACT_ANIMA_SHAIZI,
        data = {
            shaiZi1Val = self.shaiZi1Val,
            shaiZi2Val = self.shaiZi2Val,
        },
    })
    table.insert(self.actionsQue, {
        chairID = 0,
        act = GameDefine.PLAY_ACT_ANIMA_DINGLAI,
        data = {
            laiZiCardVal = self.laiZiCardVal,
        },
    })
    for _, playAct in ipairs(params.actionsQue) do 
        local actData = {
            chairID = playAct.chairID,
            act = playAct.act,
            data = {
                cardVal = playAct.data.cardVal,
                mingType = playAct.data.mingType,
                subMingType = playAct.data.subMingType,
                whosTurnChairID = playAct.data.whosTurnChairID,
                actions = {},
                chiType = playAct.data.chiType,
                cardsRemainCnt = playAct.data.cardsRemainCnt,
                huType = playAct.data.huType,
                actionWaitTime = playAct.data.actionWaitTime or GameDefine.ACTION_WAIT_TIME,
            },
        }
        for _, actVal in ipairs(playAct.data.actions or {}) do 
            table.insert(actData.data.actions, actVal)
        end 
        table.insert(self.actionsQue, actData)
    end 
    self.players = {}
    for _, playerData in pairs(params.players or {}) do 
        local player = {
            userid = playerData.userid,
            chairID = playerData.chairID,
            isZhuang = playerData.chairID == self.zhuangChairID,
            seatDir = 0, 
            handCards = {},
            mingCards = {},
            uselessCards = {},
        }
        for _, cardVal in ipairs(playerData.handCards) do 
            table.insert(player.handCards, cardVal)
        end 
        self.players[player.chairID] = player
    end 
    --init seat dir
    self:__initSeatDir()

    --------------------
    self.curPlayProgress = 0 --当前播放进度
end
    
function RollData:__initSeatDir()
    local bottomChairID = 0 -- = self.players[PlayerCache.userid]
    --search myself
    for chairID, player in pairs(self.players) do 
        if player.userid == PlayerCache.userid then 
            bottomChairID = chairID
        end 
    end 
    --select the first one as bottom player
    if bottomChairID == 0 then 
        bottomChairID = 1
    end 
    local bottomPlayer = self.players[bottomChairID]
    bottomPlayer.seatDir = GameDefine.DIR_BOTTOM
    --initialize seat dir
    for _, player in pairs(self.players) do 
        if player.chairID ~= bottomChairID then 
            local delta = player.chairID - bottomChairID
            local seatDirNdx = (delta + self.room.people) % self.room.people + 1
            player.seatDir = GameDefine.SeatDirMap[self.room.people][seatDirNdx]
        end
    end 
end 

function RollData:getLastOutAct(progress)
    local i = progress or self.curPlayProgress
    while i > 0 and self.actionsQue[i].act ~= GameDefine.PLAY_ACT_OUT do 
        i = i - 1
    end 
    if i == 0 then 
        return nil
    else 
        return self.actionsQue[i]
    end 
end 

function RollData:forward(step)

end 

function RollData:backward(step)

end 

function RollData:getNextAction()

end 

return RollData


--endregion
