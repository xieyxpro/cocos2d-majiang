local relativepath = "./lua/RoomServer/";
package.path = string.format("%s;%s?.lua",package.path,relativepath)

require("engine/AIThreadRequireFiles")

aithreadlib = aithreadlib
local aimanager = AIManager:getInstance()

engine_ai_event_service_start = function (aiThread)
    aithreadlib = tolua.cast(aiThread, "CAIThread");
    AIthreadUtil:Init(aithreadlib)

    protobuf.register_file(relativepath .. "headers/pb/Gamemsg.pb")
    protobuf.register_file(relativepath .. "headers/pb/CMD_AIReq.pb")
    aimanager:on_service_start(aithreadlib)
end

engine_ai_event_service_stop = function ()
    aimanager:on_service_stop()
end

engine_ai_event_service_event = function (wRequestID, pDataBuffer, wDataSize)
    if not aimanager:on_service_event(wRequestID, pDataBuffer, wDataSize) then
        assert(false,"engine_ai_event_service_event no hanlders")
    end
    return 0
end

--收到服务器数据
engine_ai_event_service_socket_read = function (socketFd, wMainCmdID, wSubCmdID, pDataBuffer, wDataSize)
    aimanager:on_socket_read_data(socketFd, wMainCmdID, wSubCmdID, pDataBuffer, wDataSize)
    return 0
end

--与服务器断开连接
engine_ai_event_service_socket_disconnect = function (socketFd)
    aimanager:on_socket_close(socketFd)
    return 0
end

--定时器事件
engine_ai_event_timer = function (dwTimerID,dwBindParam)
    aimanager:on_timer_event(dwTimerID,dwBindParam)
end
