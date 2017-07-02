local relativepath = "./lua/RoomServer/";
package.path = string.format("%s;%s?.lua",package.path,relativepath)

dbModules = {}
workdbeventHandler = {}
workdbexceptionHanlder = {}

require("engine/DBRequireFiles")

dbconn_gamedb = dbconn_gamedb
dbconn_accountdb = dbconn_accountdb
dbconn_statdb = dbconn_statdb
dbthreadlib = dbthreadlib

function ServiceStart( dataBaseThread, accountdb, gamedb, statdb)

    if nil == dataBaseThread or nil == accountdb or nil == gamedb or nil == statdb then return 1 end
    
    dbconn_accountdb = tolua.cast(accountdb, "CDataBase")
    dbconn_gamedb = tolua.cast(gamedb, "CDataBase")
    dbconn_statdb = tolua.cast(statdb, "CDataBase")
    dbthreadlib = tolua.cast(dataBaseThread, "CDBThread")

    protobuf.register_file(relativepath .. "headers/pb/CMD_DBReq.pb")
    protobuf.register_file(relativepath .. "headers/pb/CMD_DBStatReq.pb")

    DBThreadUtil:Init(dbthreadlib)
    
    for _, dbmodule in pairs(dbModules) do
        dbmodule:OnServiceStart(dbthreadlib, dbconn_accountdb, dbconn_gamedb ,dbconn_statdb)
    end

    return 0
end

function ServiceStop()

end

--handle for the case of EVENT_GS_DB_WORK
function sink_event_gs_db_work( wRequestID, pDataBuffer, wDataSize )

    assert(wDataSize == pDataBuffer:len())

    --region dispatch
    local bHaveObserver,bsuccess,result = event.dispatch_db_event( wRequestID, pDataBuffer, wDataSize )
    if bHaveObserver then
        if bsuccess then return result end
    end
    --endregion

    return 1

end

--region db exception
function database_exception_catch( wRequestID, pDataBuffer, wDataSize )
    assert(pDataBuffer:len() == wDataSize)
    --region dispatch
	local f = workdbexceptionHanlder[wRequestID]
	if f ~= nil then        
        local bsuccess, result = xpcall(function() return f(nil, pDataBuffer, wDataSize) end, 
                                function() Util:OutString(debug.traceback(), "Exception") end)
        if bsuccess then
            return result   --returns all results from the call(f)
        else
			logErr("dbthread database_exception_catch Exception wRequestID:" .. wRequestID)
        end
	end
    --endregion
end

--endregion
