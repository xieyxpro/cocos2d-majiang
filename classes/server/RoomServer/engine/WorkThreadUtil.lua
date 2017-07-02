--region WorkthreadUtil.lua
--Date2015.9.9
--workthreadlib Helper

local workthreadlib = workthreadlib 
local protobuflib = protobuf
assert(nil ~= protobuflib)

WorkThreadUtil ={}

function WorkThreadUtil:Init(workthreadlib_global)
    workthreadlib = workthreadlib_global

    workthreadlib.decode = WorkThreadUtil.decode
    workthreadlib.SendMsgToClient = WorkThreadUtil.SendMsgToClient
    workthreadlib.SendDataToUserItem = WorkThreadUtil.SendDataToUserItem
    workthreadlib.SendMsgToAllClients = WorkThreadUtil.SendMsgToAllClients
    workthreadlib.SendMsgToOCS = WorkThreadUtil.SendMsgToOCS

    workthreadlib.PostDataBaseEventMsg = WorkThreadUtil.PostDataBaseEventMsg
    workthreadlib.PostAIServiceEventMsg = WorkThreadUtil.PostAIServiceEventMsg
end

function WorkThreadUtil:decode(strTypeName, pDataBuffer, wLength)
    return protobuflib.decode(strTypeName, pDataBuffer, wLength)
end

function WorkThreadUtil:SendMsgToClient(pServerUserItem, wMainCmdId, wSubCmdId, strTypeName, tbMsgContent)
    
    if nil ~= strTypeName then
        return protobuflib.encode(strTypeName,tbMsgContent,
            function (encodebuf, len)
                return workthreadlib:SendDataToUserItem(pServerUserItem, wMainCmdId, wSubCmdId, encodebuf, len)
            end)
    else
        return workthreadlib:SendDataToUserItem(pServerUserItem, wMainCmdId, wSubCmdId, nil, 0)
    end
end
function WorkThreadUtil:SendDataToUserItem(pServerUserItem, wMainCmdId, wSubCmdId, pDataBuffer, wDataSize)
    
    assert(nil ~= pServerUserItem)
    local wSocketIndex = pServerUserItem:getSocketIndex()
    if INVALID_SOCKET_INDEX == wSocketIndex then return false end

    local pConnectInfo = ConnectInfos:getConnectInfo(wSocketIndex)
    if pConnectInfo.pServerUserItem ~= pServerUserItem then return false end
    
    workthreadlib:SendDataToClient(wSocketIndex, pConnectInfo.wRoundID, wMainCmdId, wSubCmdId, pDataBuffer, wDataSize)
    return true
end
function WorkThreadUtil:SendMsgToAllClients(wMainCmdId, wSubCmdId, strTypeName, tbMsgContent)
    if nil ~= strTypeName then
        protobuflib.encode(strTypeName,tbMsgContent,
            function (encodebuf, len)
                workthreadlib:SendDataToAllClients( wMainCmdId, wSubCmdId, encodebuf, len)
            end)
    else
        workthreadlib:SendDataToAllClients( wMainCmdId, wSubCmdId, nil, 0)
    end
end

function WorkThreadUtil:SendMsgToOCS(wMainCmd, wSubCmd, strTypeName, tbMsgContent)
    protobuflib.encode(strTypeName, tbMsgContent,
    function(encodebuf,len)
        workthreadlib:SendSocketData(wMainCmd, wSubCmd, DATATO_UNIQUEID.OCS,encodebuf,len,DATATO_SERVER_TYPE.OCS)
    end
    )
end

function WorkThreadUtil:PostDataBaseEventMsg(wRequestId, strTypeName, tbMsgContent ,dwUserID, dbtype)
    protobuflib.encode(strTypeName,tbMsgContent,
        function (encodebuf, len)
            if not dbtype then
                workthreadlib:PostDataBaseEvent(wRequestId, encodebuf, len, dwUserID)
            else
                workthreadlib:PostDataBaseEvent(wRequestId, encodebuf, len, dwUserID, dbtype)
            end
        end)    
end

function WorkThreadUtil:PostAIServiceEventMsg(wRequestId, strTypeName, tbMsgContent)
    protobuflib.encode(strTypeName, tbMsgContent,
        function (encodebuf, len)
            workthreadlib:PostAIServiceEvent(wRequestId, encodebuf, len)
        end)
end



--endregion
