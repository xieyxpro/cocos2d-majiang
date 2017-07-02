--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local GamePlayer = require("app.modules.game.GamePlayer")
local MJLogic = require("app.modules.game.MJLogic")
local GameDefine = require("app.modules.game.GameDefine")
local RoomData = require("app.modules.achiv.RoomData")

local AchivCache = class("AchivCache")

local KEY = "jiezhansifanghgmjapi"

function AchivCache:ctor()
    self.rooms = {} --{[roomID] = RoomData, ...}

    self.curSelectRoom = nil 
    self.playersInfo = {} ---{[userid] = {info1, ...}, ...}

    Event.register(EventDefine.ICON_DOWNLOADED, self, "ICON_DOWNLOADED")
end 

function AchivCache:reset()
    self.rooms = {} --{[roomID] = RoomData, ...}
    self.playersInfo = {} ---{[userid] = {info1, ...}, ...}

    self.curSelectRoom = nil 
end 

function AchivCache:requestRoomsRecords()
    self.rooms = {}
    self.playersInfo = {}
    local function callback(data)
        if not data.err then 
            local params = json.decode(data.data)
            if params.errcode and params.errcode ~= 0 then 
                Event.dispatch("HTTP_PLAY_ROOMS_RECORDS", {err = {code = params.errcode, msg = params.errmsg}})
                return
            end 
            for _, record in pairs(params.recordsarray) do
                local guid = record.roomguid
                local decodeData = utilfile.base64_decode(record.recorddata, record.recorddata:len())
                local len = decodeData:len()
                local tbl, errmsg = protobuf.decode("Gamemsg.record_room", decodeData, len)
                if errmsg then 
                    printInfo("ErrorMsg: %s, dataLen: %d", errmsg, len)
                    Event.dispatch("HTTP_PLAY_ROOMS_RECORDS", {err = {code = -1, msg = errmsg}})
                    return
                end 
                assert(self.rooms[guid] == nil)
                local room = RoomData:create(guid, record.begintime, tbl)
                for _, playerInfo in pairs(room.playersInfo) do 
                    self.playersInfo[playerInfo.userid] = self.playersInfo[playerInfo.userid] or {}
                    table.insert(self.playersInfo[playerInfo.userid], playerInfo)
                end 
                self.rooms[guid] = room
            end
        end 
        Event.dispatch("HTTP_PLAY_ROOMS_RECORDS", data)
    end 
    local tm = os.time()
    local signStr = string.format("uid=%d&timestamp=%d&key=%s", PlayerCache.userid, tm, KEY)
    signStr = string.lower(signStr)
    printInfo("signStr: %s", signStr)
    local sign = utilfile.getDataMD5(signStr, signStr:len())
    printInfo("sign: %s", sign)
    local url = string.format("%s/gameapi/queryroomsplayed.php?uid=%d&timestamp=%d&sign=%s", 
        Define.DATA_SERVER, PlayerCache.userid, tm, sign)
    printInfo("URL: %s", url)
    Helper.request(url, callback, "GET")
end 

function AchivCache:requestBaseRecord(roomGUID)
    local function callback(data)
        if not data.err then 
            local params = json.decode(data.data)
            if params.errcode and params.errcode ~= 0 then 
                Event.dispatch("HTTP_PLAY_RECORDS_BASE", {err = {code = params.errcode, msg = params.errmsg}})
                return
            end 
            for _, record in pairs(params.recordsarray) do
                local guid = record.gameguid
--                local str = string.gsub(record.basicrecord, "\\", "")
                local decodeData = utilfile.base64_decode(record.basicrecord, record.basicrecord:len())
                local len = decodeData:len()
                local tbl, errmsg = protobuf.decode("Gamemsg.record_base", decodeData, len)
                if errmsg then 
                    printInfo("ErrorMsg: %s, dataLen: %d", errmsg, len)
                    Event.dispatch("HTTP_PLAY_RECORDS_BASE", {err = {code = -1, msg = errmsg}})
                    return
                end 
                local room = self.rooms[roomGUID]
                assert(room)
                room:appendRoll(guid, tbl)
            end
        end 
        Event.dispatch("HTTP_PLAY_RECORDS_BASE", data)
    end 
    local tm = os.time()
    local signStr = string.format("uid=%d&roomguid=%s&timestamp=%d&key=%s", PlayerCache.userid, roomGUID, tm, KEY)
    signStr = string.lower(signStr)
    printInfo("signStr: %s", signStr)
    local sign = utilfile.getDataMD5(signStr, signStr:len())
    printInfo("sign: %s", sign)
    local url = string.format("%s/gameapi/queryroomrecords.php?uid=%d&roomguid=%s&timestamp=%d&sign=%s", 
        Define.DATA_SERVER, PlayerCache.userid, roomGUID, tm, sign)
    printInfo("URL: %s", url)
    Helper.request(url, callback, "GET")
end 

function AchivCache:requestRollData(guid)
    local function callback(data)
        if not data.err then 
            local params = json.decode(data.data)
            if params.errcode and params.errcode ~= 0 then 
                Event.dispatch("HTTP_PLAY_RECORDS_DETAIL", {err = {code = params.errcode, msg = params.errmsg}})
                return
            end 
            local binData = utilfile.base64_decode(params.recorddata, params.recorddata:len())
            local tbl = protobuf.decode("Gamemsg.record_detail", binData, binData:len())
            self.curSelectRoom:valueRollData(guid, tbl)
        end 
        Event.dispatch("HTTP_PLAY_RECORDS_DETAIL", data)
    end 
    local tm = os.time()
    local signStr = string.format("gameguid=%s&timestamp=%d&key=%s", guid, tm, KEY)
    signStr = string.lower(signStr)
    printInfo("signStr: %s", signStr)
    local sign = utilfile.getDataMD5(signStr, signStr:len())
    printInfo("sign: %s", sign)
    local url = string.format("%s/gameapi/querydetailrecord.php?gameguid=%s&timestamp=%d&sign=%s", Define.DATA_SERVER, guid, tm, sign)
    printInfo("URL: %s", url)
    Helper.request(url, callback, "GET")
end 

function AchivCache:ICON_DOWNLOADED(data)
    if data.err then 
        printInfo("[ERROR] [%d] Icon download error: %s", data.userid, data.err.msg)
        return
    end 
    local players = self.playersInfo[data.userid]
    if not players then 
        return 
    end 
    for _, player in ipairs(players) do 
        player.playerIcon = data.iconFileName
        if not player.playerIcon or player.playerIcon == "" then 
            if player.gender == Define.GENDER_FEMALE then 
                player.playerIcon = "public/head_female.png"
            else
                player.playerIcon = "public/head_male.png"
            end 
        end 
    end 
end

return AchivCache
--endregion
