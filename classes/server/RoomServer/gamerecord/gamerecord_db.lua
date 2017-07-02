--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local gamerecorddb = {}

--region params
local dbconn_gamedb = dbconn_gamedb
function gamerecorddb:OnServiceStart(dbthreadlib_global, dbconn_accountdb_global, dbconn_gamedb_global, dbconn_statdb_global)
    dbconn_gamedb = dbconn_gamedb_global
end
--endregion

function gamerecorddb:handler_dbr_record_record_game(pRecordGame)
    
    dbconn_gamedb:SetSPName("SP_RecordGame",9)
    dbconn_gamedb:setUInt(1,pRecordGame.playeruids[1])
    dbconn_gamedb:setUInt(2,pRecordGame.playeruids[2])
    dbconn_gamedb:setUInt(3,pRecordGame.playeruids[3] or 0)
    dbconn_gamedb:setUInt(4,pRecordGame.playeruids[4] or 0)
    dbconn_gamedb:setString(5,pRecordGame.gameguid)
    dbconn_gamedb:setUInt(6,pRecordGame.playtime)
    dbconn_gamedb:setBlob(7,pRecordGame.basicrecord,pRecordGame.basicrecord:len())
    dbconn_gamedb:setBlob(8,pRecordGame.detailrecord,pRecordGame.detailrecord:len())
    dbconn_gamedb:setString(9,pRecordGame.roomguid)
    dbconn_gamedb:ExecuteCommand(false)

end

function gamerecorddb:handler_dbr_record_record_room(pRecordRoom)
        
    dbconn_gamedb:SetSPName("SP_RecordRoom",10)
    dbconn_gamedb:setUInt(1,pRecordRoom.playeruids[1])
    dbconn_gamedb:setUInt(2,pRecordRoom.playeruids[2])
    dbconn_gamedb:setUInt(3,pRecordRoom.playeruids[3] or 0)
    dbconn_gamedb:setUInt(4,pRecordRoom.playeruids[4] or 0)
    dbconn_gamedb:setString(5,pRecordRoom.roomguid)
    dbconn_gamedb:setUInt(6,pRecordRoom.createtime)
    dbconn_gamedb:setUInt(7,pRecordRoom.begintime)
    dbconn_gamedb:setUInt(8,pRecordRoom.dismisstime)
    dbconn_gamedb:setUInt(9,pRecordRoom.totalplayedcount)
    dbconn_gamedb:setString(10,pRecordRoom.recorddata)
    dbconn_gamedb:ExecuteCommand(false)

end

--region register hanlders
dbModules[#dbModules + 1] = gamerecorddb
--消息句柄绑定
event.register_db_listener(DBR_W2DB.DBR_RECORD_RECORD_GAME,gamerecorddb,gamerecorddb.handler_dbr_record_record_game,"DBRMsg.Record_RecordGame")
event.register_db_listener(DBR_W2DB.DBR_RECORD_RECORD_ROOM,gamerecorddb,gamerecorddb.handler_dbr_record_record_room,"DBRMsg.Record_RecordRoom")
--endregion
--endregion
