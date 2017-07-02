
local accountdb = {
}
local dbconn_accountdb = dbconn_accountdb
local dbconn_gamedb = dbconn_gamedb
local dbthreadlib = dbthreadlib

function accountdb:OnServiceStart(dbthreadlib_global, dbconn_accountdb_global, dbconn_gamedb_global, dbconn_statdb_global)
    dbconn_accountdb = dbconn_accountdb_global
    dbthreadlib = dbthreadlib_global
    dbconn_gamedb = dbconn_gamedb_global
end

function accountdb:handler_dbr_user_roomcard_change(pRoomCardChange)
        
    dbconn_accountdb:SetSPName("SP_WriteUserRoomCard",2)
    dbconn_accountdb:setUInt(1,pRoomCardChange.userid)
    dbconn_accountdb:setInt(2,pRoomCardChange.roomcardchange)
    dbconn_accountdb:ExecuteCommand(true)
    
    local curroomcard = dbconn_accountdb:getUInt("roomcardnum")

    local StatRoomCardChange = {};
	StatRoomCardChange.uid = pRoomCardChange.userid
	StatRoomCardChange.cardnumbeforechange = curroomcard - pRoomCardChange.roomcardchange
	StatRoomCardChange.cardnumchange = pRoomCardChange.roomcardchange
	StatRoomCardChange.cardnumafterchange = curroomcard
	StatRoomCardChange.params = pRoomCardChange.params
	StatRoomCardChange.typecode = pRoomCardChange.typecode    
    protobuf.encode("DBRMsg.Stat_RoomCardChange",StatRoomCardChange,
            function(encodebuf, len)
                event.dispatch_db_event( DBR_W2DB.DBR_STAT_ROOMCARD_CHANGE, encodebuf, len )
            end)
end

dbModules[#dbModules + 1] = accountdb

event.register_db_listener(DBR_W2DB.DBR_USER_ROOMCARD_CHANGE,accountdb,accountdb.handler_dbr_user_roomcard_change,"DBRMsg.User_MW_RoomCardChange")
return accountdb
