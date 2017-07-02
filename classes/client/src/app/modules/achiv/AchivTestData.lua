--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

function AchivCache:requestBaseRecord()
    --TODO below block of code is for testing purpose
    local baseRecord = {
    roomID = 1,
    statistics = 
    {
        [1] = 
        {
            score = 0,
            userid = 144
        },
        [2] = 
        {
            score = 80,
            userid = 20499
        },
        [3] = 
        {
            score = 0,
            userid = 20500
        },
        [4] = 
        {
            score = -80,
            userid = 20498
        }
    },
    playersInfo = 
    {
        [1] = 
        {
            nickname = '144',
            userid = 144,
            playerIcon = '',
            chairID = 1
        },
        [2] = 
        {
            nickname = '20500',
            userid = 20500,
            playerIcon = '',
            chairID = 2
        },
        [3] = 
        {
            nickname = '20499',
            userid = 20499,
            playerIcon = '',
            chairID = 3
        },
        [4] = 
        {
            nickname = '20498',
            userid = 20498,
            playerIcon = '',
            chairID = 4
        }
    },
    startTime = 1484976214,
    roomCreaterUserID = 144,
    people = 4
}
    for i = 1, 300, 1 do 
        baseRecord.roomID = (baseRecord.roomID + 1) % 10
        local room = self.rooms[baseRecord.roomID]
        if not room then 
            room = RoomData:create(baseRecord)
        end 
        room:update(tostring(i), baseRecord)
        self.rooms[baseRecord.roomID] = room
    end 
    Event.dispatch("HTTP_PLAY_RECORDS_BASE", {})
    do 
        return 
    end 
    ----------------------------------------------------
    self.rooms = {}
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
                local room = self.rooms[tbl.roomID]
                if not room then 
                    room = RoomData:create(tbl)
                end 
                room:update(guid, tbl)
                self.rooms[tbl.roomID] = room
            end
        end 
        Event.dispatch("HTTP_PLAY_RECORDS_BASE", data)
    end 
    local tm = os.time()
    local signStr = string.format("uid=%d&timestamp=%d&key=%s", PlayerCache.userid, tm, KEY)
    signStr = string.lower(signStr)
    local sign = utilfile.getDataMD5(signStr, signStr:len())
    local url = string.format("%s/gameapi/querybasicrecords.php?uid=%d&timestamp=%d&sign=%s", Define.DATA_SERVER, PlayerCache.userid, tm, sign)
    Helper.request(url, callback, "GET")
end 

function AchivCache:requestRollData(guid)
    --TODO below block of code is for testing purpose
    local detailRecord = {
    players = 
    {
        [1] = 
        {
            userid = 144,
            handCards = 
            {
                [1] = 28,
                [2] = 47,
                [3] = 17,
                [4] = 23,
                [5] = 33,
                [6] = 11,
                [7] = 46,
                [8] = 32,
                [9] = 44,
                [10] = 23,
                [11] = 45,
                [12] = 22,
                [13] = 25
            },
            chairID = 1
        },
        [2] = 
        {
            userid = 20500,
            handCards = 
            {
                [1] = 35,
                [2] = 47,
                [3] = 45,
                [4] = 37,
                [5] = 39,
                [6] = 16,
                [7] = 42,
                [8] = 15,
                [9] = 39,
                [10] = 44,
                [11] = 47,
                [12] = 11,
                [13] = 28
            },
            chairID = 2
        },
        [3] = 
        {
            userid = 20499,
            handCards = 
            {
                [1] = 16,
                [2] = 47,
                [3] = 44,
                [4] = 38,
                [5] = 13,
                [6] = 15,
                [7] = 22,
                [8] = 31,
                [9] = 27,
                [10] = 35,
                [11] = 36,
                [12] = 33,
                [13] = 25
            },
            chairID = 3
        },
        [4] = 
        {
            userid = 20498,
            handCards = 
            {
                [1] = 18,
                [2] = 37,
                [3] = 27,
                [4] = 46,
                [5] = 17,
                [6] = 24,
                [7] = 35,
                [8] = 32,
                [9] = 45,
                [10] = 28,
                [11] = 29,
                [12] = 42,
                [13] = 14
            },
            chairID = 4
        }
    },
    laiZiCardVal = 25,
    actionsQue = 
    {
        [1] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 46,
                cardsRemainCnt = 68,
                whosTurnChairID = 1
            },
            act = 6
        },
        [2] = 
        {
            chairID = 1,
            data = 
            {
                cardVal = 47
            },
            act = 7
        },
        [3] = 
        {
            chairID = 0,
            data = 
            {
                action = 4,
                whosTurnChairID = 2
            },
            act = 6
        },
        [4] = 
        {
            chairID = 2,
            data = 
            {
                cardVal = 47
            },
            act = 4
        },
        [5] = 
        {
            chairID = 2,
            data = 
            {
                cardVal = 45,
                subMingType = 43,
                mingType = 4
            },
            act = 3
        },
        [6] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 43,
                cardsRemainCnt = 68,
                whosTurnChairID = 2
            },
            act = 6
        },
        [7] = 
        {
            chairID = 2,
            data = 
            {
                cardVal = 43
            },
            act = 7
        },
        [8] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 43,
                cardsRemainCnt = 67,
                whosTurnChairID = 3
            },
            act = 6
        },
        [9] = 
        {
            chairID = 3,
            data = 
            {
                cardVal = 33
            },
            act = 7
        },
        [10] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 35,
                cardsRemainCnt = 66,
                whosTurnChairID = 4
            },
            act = 6
        },
        [11] = 
        {
            chairID = 4,
            data = 
            {
                cardVal = 24,
                subMingType = 43,
                mingType = 4
            },
            act = 3
        },
        [12] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 33,
                cardsRemainCnt = 66,
                whosTurnChairID = 4
            },
            act = 6
        },
        [13] = 
        {
            chairID = 4,
            data = 
            {
                cardVal = 45,
                subMingType = 43,
                mingType = 4
            },
            act = 3
        },
        [14] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 15,
                cardsRemainCnt = 66,
                whosTurnChairID = 4
            },
            act = 6
        },
        [15] = 
        {
            chairID = 4,
            data = 
            {
                cardVal = 35
            },
            act = 7
        },
        [16] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 12,
                cardsRemainCnt = 65,
                whosTurnChairID = 1
            },
            act = 6
        },
        [17] = 
        {
            chairID = 1,
            data = 
            {
                cardVal = 45,
                subMingType = 43,
                mingType = 4
            },
            act = 3
        },
        [18] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 26,
                cardsRemainCnt = 65,
                whosTurnChairID = 1
            },
            act = 6
        },
        [19] = 
        {
            chairID = 1,
            data = 
            {
                cardVal = 44
            },
            act = 7
        },
        [20] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 31,
                cardsRemainCnt = 64,
                whosTurnChairID = 2
            },
            act = 6
        },
        [21] = 
        {
            chairID = 2,
            data = 
            {
                cardVal = 42
            },
            act = 7
        },
        [22] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 31,
                cardsRemainCnt = 63,
                whosTurnChairID = 3
            },
            act = 6
        },
        [23] = 
        {
            chairID = 3,
            data = 
            {
                cardVal = 35
            },
            act = 7
        },
        [24] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 24,
                cardsRemainCnt = 62,
                whosTurnChairID = 4
            },
            act = 6
        },
        [25] = 
        {
            chairID = 4,
            data = 
            {
                cardVal = 24,
                subMingType = 43,
                mingType = 4
            },
            act = 3
        },
        [26] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 29,
                cardsRemainCnt = 62,
                whosTurnChairID = 4
            },
            act = 6
        },
        [27] = 
        {
            chairID = 4,
            data = 
            {
                cardVal = 15
            },
            act = 7
        },
        [28] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 34,
                cardsRemainCnt = 61,
                whosTurnChairID = 1
            },
            act = 6
        },
        [29] = 
        {
            chairID = 1,
            data = 
            {
                cardVal = 17
            },
            act = 7
        },
        [30] = 
        {
            chairID = 0,
            data = 
            {
                action = 2,
                whosTurnChairID = 2
            },
            act = 6
        },
        [31] = 
        {
            chairID = 2,
            data = 
            {
                cardVal = 17,
                chiType = 3
            },
            act = 2
        },
        [32] = 
        {
            chairID = 2,
            data = 
            {
                cardVal = 28
            },
            act = 7
        },
        [33] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 22,
                cardsRemainCnt = 60,
                whosTurnChairID = 3
            },
            act = 6
        },
        [34] = 
        {
            chairID = 3,
            data = 
            {
                cardVal = 27
            },
            act = 7
        },
        [35] = 
        {
            chairID = 0,
            data = 
            {
                action = 2,
                whosTurnChairID = 4
            },
            act = 6
        },
        [36] = 
        {
            chairID = 4,
            data = 
            {
                cardVal = 27,
                chiType = 1
            },
            act = 2
        },
        [37] = 
        {
            chairID = 4,
            data = 
            {
                cardVal = 14
            },
            act = 7
        },
        [38] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 42,
                cardsRemainCnt = 59,
                whosTurnChairID = 1
            },
            act = 6
        },
        [39] = 
        {
            chairID = 1,
            data = 
            {
                cardVal = 42
            },
            act = 7
        },
        [40] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 13,
                cardsRemainCnt = 58,
                whosTurnChairID = 2
            },
            act = 6
        },
        [41] = 
        {
            chairID = 2,
            data = 
            {
                cardVal = 35
            },
            act = 7
        },
        [42] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 39,
                cardsRemainCnt = 57,
                whosTurnChairID = 3
            },
            act = 6
        },
        [43] = 
        {
            chairID = 3,
            data = 
            {
                cardVal = 38
            },
            act = 7
        },
        [44] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 24,
                cardsRemainCnt = 56,
                whosTurnChairID = 4
            },
            act = 6
        },
        [45] = 
        {
            chairID = 4,
            data = 
            {
                cardVal = 24,
                subMingType = 43,
                mingType = 4
            },
            act = 3
        },
        [46] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 23,
                cardsRemainCnt = 56,
                whosTurnChairID = 4
            },
            act = 6
        },
        [47] = 
        {
            chairID = 4,
            data = 
            {
                cardVal = 35
            },
            act = 7
        },
        [48] = 
        {
            chairID = 0,
            data = 
            {
                action = 2,
                whosTurnChairID = 1
            },
            act = 6
        },
        [49] = 
        {
            chairID = 1,
            data = 
            {
                cardVal = 35,
                chiType = 3
            },
            act = 2
        },
        [50] = 
        {
            chairID = 1,
            data = 
            {
                cardVal = 11
            },
            act = 7
        },
        [51] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 38,
                cardsRemainCnt = 55,
                whosTurnChairID = 2
            },
            act = 6
        },
        [52] = 
        {
            chairID = 2,
            data = 
            {
                cardVal = 31
            },
            act = 7
        },
        [53] = 
        {
            chairID = 0,
            data = 
            {
                action = 4,
                whosTurnChairID = 3
            },
            act = 6
        },
        [54] = 
        {
            chairID = 3,
            data = 
            {
                cardVal = 31
            },
            act = 4
        },
        [55] = 
        {
            chairID = 3,
            data = 
            {
                cardVal = 44
            },
            act = 7
        },
        [56] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 28,
                cardsRemainCnt = 54,
                whosTurnChairID = 4
            },
            act = 6
        },
        [57] = 
        {
            chairID = 4,
            data = 
            {
                cardVal = 29
            },
            act = 7
        },
        [58] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 27,
                cardsRemainCnt = 53,
                whosTurnChairID = 1
            },
            act = 6
        },
        [59] = 
        {
            chairID = 1,
            data = 
            {
                cardVal = 32
            },
            act = 7
        },
        [60] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 21,
                cardsRemainCnt = 52,
                whosTurnChairID = 2
            },
            act = 6
        },
        [61] = 
        {
            chairID = 2,
            data = 
            {
                cardVal = 44
            },
            act = 7
        },
        [62] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 36,
                cardsRemainCnt = 51,
                whosTurnChairID = 3
            },
            act = 6
        },
        [63] = 
        {
            chairID = 3,
            data = 
            {
                cardVal = 47
            },
            act = 7
        },
        [64] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 36,
                cardsRemainCnt = 50,
                whosTurnChairID = 4
            },
            act = 6
        },
        [65] = 
        {
            chairID = 4,
            data = 
            {
                cardVal = 32
            },
            act = 7
        },
        [66] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 41,
                cardsRemainCnt = 49,
                whosTurnChairID = 1
            },
            act = 6
        },
        [67] = 
        {
            chairID = 1,
            data = 
            {
                cardVal = 41
            },
            act = 7
        },
        [68] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 29,
                cardsRemainCnt = 48,
                whosTurnChairID = 2
            },
            act = 6
        },
        [69] = 
        {
            chairID = 2,
            data = 
            {
                cardVal = 29
            },
            act = 7
        },
        [70] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 39,
                cardsRemainCnt = 47,
                whosTurnChairID = 3
            },
            act = 6
        },
        [71] = 
        {
            chairID = 3,
            data = 
            {
                cardVal = 43
            },
            act = 7
        },
        [72] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 41,
                cardsRemainCnt = 46,
                whosTurnChairID = 4
            },
            act = 6
        },
        [73] = 
        {
            chairID = 4,
            data = 
            {
                cardVal = 41
            },
            act = 7
        },
        [74] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 23,
                cardsRemainCnt = 45,
                whosTurnChairID = 1
            },
            act = 6
        },
        [75] = 
        {
            chairID = 1,
            data = 
            {
                cardVal = 46
            },
            act = 7
        },
        [76] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 25,
                cardsRemainCnt = 44,
                whosTurnChairID = 2
            },
            act = 6
        },
        [77] = 
        {
            chairID = 2,
            data = 
            {
                cardVal = 39
            },
            act = 7
        },
        [78] = 
        {
            chairID = 0,
            data = 
            {
                action = 4,
                whosTurnChairID = 3
            },
            act = 6
        },
        [79] = 
        {
            chairID = 3,
            data = 
            {
                cardVal = 39
            },
            act = 4
        },
        [80] = 
        {
            chairID = 3,
            data = 
            {
                cardVal = 15
            },
            act = 7
        },
        [81] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 32,
                cardsRemainCnt = 43,
                whosTurnChairID = 4
            },
            act = 6
        },
        [82] = 
        {
            chairID = 4,
            data = 
            {
                cardVal = 27
            },
            act = 7
        },
        [83] = 
        {
            chairID = 0,
            data = 
            {
                action = 2,
                whosTurnChairID = 1
            },
            act = 6
        },
        [84] = 
        {
            chairID = 1,
            data = 
            {
            },
            act = 1
        },
        [85] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 18,
                cardsRemainCnt = 42,
                whosTurnChairID = 1
            },
            act = 6
        },
        [86] = 
        {
            chairID = 1,
            data = 
            {
                cardVal = 46
            },
            act = 7
        },
        [87] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 12,
                cardsRemainCnt = 41,
                whosTurnChairID = 2
            },
            act = 6
        },
        [88] = 
        {
            chairID = 2,
            data = 
            {
                cardVal = 11
            },
            act = 7
        },
        [89] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 26,
                cardsRemainCnt = 40,
                whosTurnChairID = 3
            },
            act = 6
        },
        [90] = 
        {
            chairID = 3,
            data = 
            {
                cardVal = 13
            },
            act = 7
        },
        [91] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 46,
                cardsRemainCnt = 39,
                whosTurnChairID = 4
            },
            act = 6
        },
        [92] = 
        {
            chairID = 4,
            data = 
            {
                cardVal = 17
            },
            act = 7
        },
        [93] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 11,
                cardsRemainCnt = 38,
                whosTurnChairID = 1
            },
            act = 6
        },
        [94] = 
        {
            chairID = 1,
            data = 
            {
                cardVal = 22
            },
            act = 7
        },
        [95] = 
        {
            chairID = 0,
            data = 
            {
                action = 4,
                whosTurnChairID = 3
            },
            act = 6
        },
        [96] = 
        {
            chairID = 3,
            data = 
            {
                cardVal = 22
            },
            act = 4
        },
        [97] = 
        {
            chairID = 3,
            data = 
            {
                cardVal = 16
            },
            act = 7
        },
        [98] = 
        {
            chairID = 0,
            data = 
            {
                cardVal = 32,
                cardsRemainCnt = 37,
                whosTurnChairID = 4
            },
            act = 6
        },
        [99] = 
        {
            chairID = 4,
            data = 
            {
                cardVal = 36
            },
            act = 7
        },
        [100] = 
        {
            chairID = 0,
            data = 
            {
                action = 5,
                whosTurnChairID = 3
            },
            act = 6
        }
    },
    laiZiPiCardVal = 24,
    zhuangChairID = 1
}
    self.curSelectRoom:valueRollData(guid, detailRecord)
    Event.dispatch("HTTP_PLAY_RECORDS_DETAIL", {})
    do 
        return 
    end 
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

--endregion
