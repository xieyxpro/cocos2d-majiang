--region AIthreadUtil.lua
--Date2015.9.9
--aithreadlib Helper

local aithreadlib = aithreadlib 
local protobuflib = protobuf
assert(nil ~= protobuflib)

AIthreadUtil ={}

function AIthreadUtil:Init(aithreadlib_global)
    aithreadlib = aithreadlib_global

    aithreadlib.decode = AIthreadUtil.decode
    aithreadlib.SendMsg = AIthreadUtil.SendMsg
end

function AIthreadUtil:decode(strTypeName, pDataBuffer, wLength)
    return protobuflib.decode(strTypeName, pDataBuffer, wLength)
end

function AIthreadUtil:SendMsg(dwSocketFd, wMainCmdId, wSubCmdId, strTypeName, tbMsgContent)
    
    if nil ~= strTypeName then
        return protobuflib.encode(strTypeName,tbMsgContent,
            function (encodebuf, len)
                return aithreadlib:SendData(dwSocketFd, wMainCmdId, wSubCmdId, encodebuf, len)
            end)
    else
        return aithreadlib:SendData(dwSocketFd, wMainCmdId, wSubCmdId, nil, 0)
    end
end
--endregion
