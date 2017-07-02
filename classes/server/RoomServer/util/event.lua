--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local event = {
    socketeventHandler = {},         --{{{instance,function,pbmessage}...}}
    dbeventHandler = {},             --{{instance,function,pbmessage}...}
    timereventHandler = {},          --{{timerid,{instance,function}...}...}
}

--region socket_event
function event.register_socket_listener(main_cmd_id, sub_cmd_id, listener_obj, listener_func, pb_message)
    local socketeventHandler = event.socketeventHandler
    socketeventHandler[main_cmd_id] = socketeventHandler[main_cmd_id] or {}
    socketeventHandler[main_cmd_id][sub_cmd_id] = socketeventHandler[main_cmd_id][sub_cmd_id] or {}

    for _, observer in pairs(socketeventHandler[main_cmd_id][sub_cmd_id]) do
        if observer[1] == listener_obj and observer[2] == listener_func then
            logErrf("Err:duplicate register socket listener:%d-%d", main_cmd_id, sub_cmd_id)
            return false
        end
    end
    
    table.insert(socketeventHandler[main_cmd_id][sub_cmd_id],{listener_obj,listener_func, pb_message})
    return true
end
function event.unregister_socket_listener(main_cmd_id, sub_cmd_id, listener_obj, listener_func)
    local socketeventHandler = event.socketeventHandler
    if nil == socketeventHandler[main_cmd_id] or nil == socketeventHandler[main_cmd_id][sub_cmd_id] then
        logErrf("Err:unregister socket listener err:%d-%d",main_cmd_id, sub_cmd_id)
        return false
    end

    for index,observer in pairs(socketeventHandler[main_cmd_id][sub_cmd_id]) do
        if observer[1] == listener_obj and observer[2] == listener_func then
            table.remove(socketeventHandler[main_cmd_id][sub_cmd_id],index)
            return true
        end
    end

    logErrf("Err:unregister socket listener no such observer err:%d-%d", main_cmd_id, sub_cmd_id)
    return false
end
function event.dipatch_socket_event( wMainCmdID, wSubCmdID, pDataBuffer, wDataSize, pServerUserItem )
    local handlers = event.socketeventHandler[wMainCmdID]
	local observers = handlers and handlers[wSubCmdID] or nil
	if observers then 
        local bsuccess, result = nil, nil
        for _,observer in pairs(observers) do        
            if nil ~= observer[3] then -- decode protobuff message
                local pMsgTbl = protobuf.decode(observer[3], pDataBuffer, wDataSize)
                bsuccess, result = xpcall(function() return observer[2](observer[1], pMsgTbl, pServerUserItem) end, 
                                    function() logErr(debug.traceback()) end)
            else
                bsuccess, result = xpcall(function() return observer[2](observer[1], pDataBuffer, wDataSize, pServerUserItem) end, 
                                    function() logErr(debug.traceback()) end)
            end
            if not bsuccess then
                logErrf("dipatch_socket_event Exception CmdID: %d : %d", wMainCmdID, wSubCmdID)
            end        
        end

        return true, bsuccess, result
	end
end
--endregion

--region db_event
function event.register_db_listener(dbr_cmd_id, listener_obj, listener_func, pb_message)
    local dbeventHandler = event.dbeventHandler
    dbeventHandler[dbr_cmd_id] = dbeventHandler[dbr_cmd_id]  or {}
    for index,observer in pairs(dbeventHandler[dbr_cmd_id]) do
        if observer[1] == listener_obj and observer[2] == listener_func then
            logErrf("Err:duplicate register db listener:%d", dbr_cmd_id)
            return false
        end
    end
    
    table.insert(dbeventHandler[dbr_cmd_id], {listener_obj, listener_func, pb_message})
    return true
end
function event.unregister_db_listener(dbr_cmd_id, listener_obj, listener_func)
    local dbeventHandler = event.dbeventHandler
    if nil == dbeventHandler[dbr_cmd_id] then
        logErrf("Err:unregister db listener err:%d", dbr_cmd_id)
        return false
    end
    for index,observer in pairs(dbeventHandler[dbr_cmd_id]) do
        if observer[1] == listener_obj and observer[2] == listener_func then
            table.remove(dbeventHandler[dbr_cmd_id],index)
            return true
        end
    end
    logErrf("Err:unregister db listener no such observer err:%d", dbr_cmd_id)
    return false
end
function event.dispatch_db_event( wRequestID, pDataBuffer, wDataSize )
    local observers = event.dbeventHandler[wRequestID]
	if observers then         
        local bsuccess, result = nil, nil

        for _,observer in pairs(observers) do
            if nil ~= observer[3] then -- decode protobuff message
                local pMsgTbl = protobuf.decode(observer[3], pDataBuffer, wDataSize)
                bsuccess, result = xpcall(function() return observer[2](observer[1], pMsgTbl) end, 
                                    function() logErr(debug.traceback()) end)
            else
                bsuccess, result = xpcall(function() return observer[2](observer[1], pDataBuffer, wDataSize) end, 
                                    function() logErr(debug.traceback()) end)
            end
            if not bsuccess then
			    logErr("dbthread sink_event_gs_db_work Exception wRequestID:" .. wRequestID)
            end        
        end

        return true, bsuccess, result
	end    
end
--endregion

--region timer_event
function event.register_timer_listener(timerid,listener_obj,listener_func)
    local timereventHandler = event.timereventHandler
    timereventHandler[timerid] = timereventHandler[timerid] or {}
    for _,observer in pairs(timereventHandler[timerid]) do
        if observer[1] == listener_obj and observer[2] == listener_func then
            logErrf("Err:duplicate register timer listener:%d", timerid)
            return false
        end
    end
    
    table.insert(timereventHandler[timerid],{listener_obj, listener_func})
    return true
end

function event.unregister_timer_listener(timerid,listener_obj,listener_func)
    local timereventHandler = event.timereventHandler
    if nil == timereventHandler[timerid] then
        logErrf("Err:unregister timer listener err:%d",timerid)
        return false
    end
    for index,observer in pairs(timereventHandler[timerid]) do
        if observer[1] == listener_obj and observer[2] == listener_func then
            table.remove(timereventHandler[timerid],index)
            return true
        end
    end
    
    logErrf("Err:unregister timer listener no such observer err:%d", timerid)
    return false
end
function event.dipatch_timer_event(dwTimerID, dwBindParam)
    local observers = event.timereventHandler[dwTimerID]
	if observers then         
        local bsuccess, result = nil, nil

        for _,observer in pairs(observers) do
            bsuccess, result = xpcall(function() return observer[2](observer[1], dwBindParam) end, 
                                    function() logErr(debug.traceback()) end)
            if not bsuccess then
                logErr("sink_event_gs_timer Exception dwTimerID:" .. dwTimerID)
            end
        end

        return true, bsuccess, result
	end
end
--endregion

return event
--endregion
