
local statdb = {
    dbEventHandlers = {}
}
local dbconn_statdb = dbconn_statdb
local dbthreadlib = dbthreadlib

function statdb:OnServiceStart(dbthreadlib_global, dbconn_accountdb_global, dbconn_gamedb_global, dbconn_statdb_global)
    dbconn_statdb = dbconn_statdb_global
    dbthreadlib = dbthreadlib_global
end

function statdb:handler_dbr_stat_roomcard_change(pRoomCardChange)
    
    dbconn_statdb:SetSPName("SP_Stat_UserRoomCardChange",7)
    dbconn_statdb:setUInt(1,pRoomCardChange.uid)
    dbconn_statdb:setUInt(2,pRoomCardChange.cardnumbeforechange)
    dbconn_statdb:setInt(3,pRoomCardChange.cardnumchange)
    dbconn_statdb:setInt(4,pRoomCardChange.cardnumafterchange)
    dbconn_statdb:setString(5,Util:GetStandardDateTime(os.time()))
    dbconn_statdb:setString(6,pRoomCardChange.params)
    dbconn_statdb:setInt(7,pRoomCardChange.typecode)
    dbconn_statdb:ExecuteCommand(false)

end

function statdb:handler_dbr_stat_create_rooms(pCreateRooms)
        
    dbconn_statdb:SetSPName("SP_Stat_CreateRooms",11)
    dbconn_statdb:setUInt(1,pCreateRooms.playeruids[1])
    dbconn_statdb:setUInt(2,pCreateRooms.playeruids[2])
    dbconn_statdb:setUInt(3,pCreateRooms.playeruids[3] or 0)
    dbconn_statdb:setUInt(4,pCreateRooms.playeruids[4] or 0)
    dbconn_statdb:setString(5,Util:GetStandardDateTime(pCreateRooms.createtime))
    dbconn_statdb:setString(6,Util:GetStandardDateTime(pCreateRooms.begintime))
    dbconn_statdb:setString(7,Util:GetStandardDateTime(pCreateRooms.dismisstime))
    dbconn_statdb:setUInt(8,pCreateRooms.totalplayedcount)
    dbconn_statdb:setUInt(9,pCreateRooms.createrolls)
    dbconn_statdb:setString(10,pCreateRooms.createparams)
    dbconn_statdb:setString(11,pCreateRooms.roomguid)
    dbconn_statdb:ExecuteCommand(false)

end

function statdb:handler_dbr_stat_game_records(pGameRecord)
    dbconn_statdb:SetSPName("SP_Stat_GameRecord",8)
    dbconn_statdb:setUInt(1,pGameRecord.playeruids[1])
    dbconn_statdb:setUInt(2,pGameRecord.playeruids[2])
    dbconn_statdb:setUInt(3,pGameRecord.playeruids[3] or 0)
    dbconn_statdb:setUInt(4,pGameRecord.playeruids[4] or 0)
    dbconn_statdb:setString(5,pGameRecord.playersinfo)
    dbconn_statdb:setString(6,pGameRecord.gameguid)
    dbconn_statdb:setString(7,pGameRecord.roomguid)
    dbconn_statdb:setString(8,Util:GetStandardDateTime(pGameRecord.playtime))
    dbconn_statdb:ExecuteCommand(false)
end

dbModules[#dbModules + 1] = statdb

event.register_db_listener(DBR_W2DB.DBR_STAT_ROOMCARD_CHANGE,statdb,statdb.handler_dbr_stat_roomcard_change,"DBRMsg.Stat_RoomCardChange")
event.register_db_listener(DBR_W2DB.DBR_STAT_CREATE_ROOMS,statdb,statdb.handler_dbr_stat_create_rooms,"DBRMsg.Stat_CreateRooms")
event.register_db_listener(DBR_W2DB.DBR_STAT_GAME_RECORDS,statdb,statdb.handler_dbr_stat_game_records,"DBRMsg.Stat_GameRecord")

return statdb
