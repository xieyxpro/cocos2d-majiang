--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

GameRecord = {}
GameRecord = Util:newClass(GameRecord,SystemBase)
local workthreadlib = workthreadlib

function GameRecord:OnServiceStart(workthread_global, kindid, serverid, server_ip, server_port)
    workthreadlib = workthread_global
end

--tbUserIds 四个玩家的userid
--[[
    tbGameData = {
        userids             --四个玩家的userid
        basicrecord         --牌局基础信息
        detailrecord        --牌局详细信息
	    roomguid            --房间guid
        playersinfo         --牌局结束时候玩家信息(手牌亮牌积分等<65535个字符)
	    playtime
    }
--]]
function GameRecord:RecordGame(tbGameData)
    tbGameData.gameguid = string.lower(LuaUtil:GenerateGuidString())

    local RecordGame = {}
    RecordGame.playeruids = tbGameData.userids
    RecordGame.gameguid = tbGameData.gameguid
    RecordGame.basicrecord = tbGameData.basicrecord
    RecordGame.detailrecord = tbGameData.detailrecord
    RecordGame.playtime = os.time()   
    RecordGame.roomguid = tbGameData.roomguid

    workthreadlib:PostDataBaseEventMsg(DBR_W2DB.DBR_RECORD_RECORD_GAME,"DBRMsg.Record_RecordGame",RecordGame,tbGameData.userids[1])
    self:StatGameRecord(tbGameData)
end

--[[
    tbRoomData={
        userids         --四个玩家的userid
        roomguid        --
        recorddata      --recorddata 房间基础信息
        createtime      --创建时间
        begintime       --首局开始时间
        totalplayedcount--总共玩的局数
        createrolls     --创建时候选的局数
        createparams    --创建时候勾选的参数char[256]
    }
    --createtime,begintime,dismisstime unix时间戳
--]]
function GameRecord:RecordRoom(tbRoomData)

    if tbRoomData.totalplayedcount <= 0 then return end

    tbRoomData.dismisstime = os.time()

    local RecordRoom = {}
    RecordRoom.playeruids = tbRoomData.userids
    RecordRoom.roomguid = tbRoomData.roomguid
    RecordRoom.recorddata = tbRoomData.recorddata
    RecordRoom.createtime = tbRoomData.createtime
    RecordRoom.begintime = tbRoomData.begintime
    RecordRoom.dismisstime = tbRoomData.dismisstime
    RecordRoom.totalplayedcount = tbRoomData.totalplayedcount
    
    workthreadlib:PostDataBaseEventMsg(DBR_W2DB.DBR_RECORD_RECORD_ROOM,"DBRMsg.Record_RecordRoom",RecordRoom,tbRoomData.userids[1])
    self:StatCreateRoom(tbRoomData)
end
--region 游戏统计信息
function GameRecord:StatCreateRoom(tbRoomData)
    local stat = {}
    stat.playeruids = tbRoomData.userids
	stat.createtime = tbRoomData.createtime
	stat.begintime = tbRoomData.begintime
	stat.dismisstime = tbRoomData.dismisstime
	stat.totalplayedcount = tbRoomData.totalplayedcount
	stat.createrolls = tbRoomData.createrolls
	stat.createparams = tbRoomData.createparams--房间规则
	stat.roomguid = tbRoomData.roomguid
    workthreadlib:PostDataBaseEventMsg(DBR_W2DB.DBR_STAT_CREATE_ROOMS,"DBRMsg.Stat_CreateRooms",stat,tbRoomData.userids[1])
end

function GameRecord:StatGameRecord(tbGameData)
    local stat = {}
    stat.playeruids = tbGameData.userids
    stat.playersinfo = tbGameData.playersinfo
	stat.cards = tbGameData.cards
	stat.scores = tbGameData.scores
	stat.gameguid = tbGameData.gameguid
	stat.roomguid = tbGameData.roomguid
	stat.playtime = tbGameData.playtime
    
    workthreadlib:PostDataBaseEventMsg(DBR_W2DB.DBR_STAT_GAME_RECORDS,"DBRMsg.Stat_GameRecord",stat,tbGameData.userids[1])
end
--endregion

gameSystems[#gameSystems + 1] = GameRecord
--endregion
