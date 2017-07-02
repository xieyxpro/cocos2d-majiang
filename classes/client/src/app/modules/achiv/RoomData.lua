--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local RoomData = class("RoomData")

local RollData = require("app.modules.achiv.RollData")

function RoomData:ctor(guid, startTime, baseRecord)
    self.guid = guid or ""
    self.roomID = baseRecord.roomID or 0
    self.people = baseRecord.people or 4
    self.roomCreaterUserID = baseRecord.roomCreaterUserID or 0 --房主
    self.startTime = startTime
    self.playersInfo = {} --{[userid] = {playerIcon = ?, nickname = ?, userid = ?, chairID = ?}, ...}
    self.rolls = {} --{{guid = ?, stats = ?, startTime = ?, rollData = ?}, ...}
    self.curRollGuid = 0

    for _, info in ipairs(baseRecord.playersInfo or {}) do 
        if not self.playersInfo[info.userid] then 
            local playerInfo = {
                userid = info.userid, 
                nickname = Helper.cutNameWithAvaiLen(info.nickname or ""),
                playerIcon = info.playerIcon,
                chairID = info.chairID,
                gender = info.gender or Define.GENDER_FEMALE,
                score = info.score or 0,
                playerIP = util.convertIPV4ToStr(info.playerIP or "0"),
                city = info.city or "",
                district = info.district or "",
                address = info.address or "",
            }
            if playerInfo.gender == Define.GENDER_FEMALE then 
                playerInfo.playerIcon = "public/head_female.png"
            else
                playerInfo.playerIcon = "public/head_male.png"
            end 
            self.playersInfo[info.userid] = playerInfo
            local localIcon = IconManager:getIcon(info.userid, info.playerIcon)
            if localIcon then 
                playerInfo.playerIcon = localIcon
            end 
        end 
    end 
end 

function RoomData:appendRoll(guid, baseRecord)
    local roll = {
        guid = guid, 
        result = baseRecord.result,
        stats = {},
        startTime = baseRecord.startTime or 0,
        winner = nil,
        rollData = nil,
        rollInfo = {
            laiZiCardVal = 0,
            laiZiPiCardVal = 0,
            hongZhongCardVal = 0,
        },
        loserUserID = baseRecord.loserUserID or 0,
        sponsorUserID = baseRecord.sponsorUserID or 0,
    }
    if baseRecord.rollInfo then 
        roll.rollInfo.laiZiCardVal = baseRecord.rollInfo.laiZiCardVal or 0
        roll.rollInfo.laiZiPiCardVal = baseRecord.rollInfo.laiZiPiCardVal or 0
        roll.rollInfo.hongZhongCardVal = baseRecord.rollInfo.hongZhongCardVal or 0
    end 
    for _, statData in pairs(baseRecord.statistics) do 
        roll.stats[statData.userid] = {
            userid = statData.userid, 
            score = statData.score,
        }
    end 
    local playerData = baseRecord.winner
    if playerData then 
        local balancePlayer = {userid = playerData.userid,
            handCards = {}, 
            mingCards = {},
            huType = playerData.huType, 
            huCardVal = playerData.huCardVal,
            fans = playerData.fans,
            record = playerData.score,
            recordTypes = {}, --得分类型
        }
        for _, cardVal in ipairs(playerData.handCards) do 
            table.insert(balancePlayer.handCards, cardVal)
        end 
        for _, mingCard in ipairs(playerData.mingCards) do 
            table.insert(balancePlayer.mingCards, {cardVal = mingCard.cardVal, 
                                                    mingType = mingCard.mingType, 
                                                    subMingType = mingCard.subMingType})
        end 
        for _, recordType in ipairs(playerData.scoreTypes) do 
            table.insert(balancePlayer.recordTypes, recordType)
        end 
        roll.winner = balancePlayer
    end 

    self.rolls[guid] = roll
end 

function RoomData:valueRollData(guid, recordDetail)
    local rollData = RollData:create(self, recordDetail)
    self.rolls[guid].rollData = rollData
end 

function RoomData:getCurRollData()
    if not self.rolls[self.curRollGuid] then 
        return nil
    end 
    return self.rolls[self.curRollGuid].rollData
end 

return RoomData
--endregion
