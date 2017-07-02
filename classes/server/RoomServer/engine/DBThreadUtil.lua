--region DBThreadUtil.lua
--Date2015.9.9
--dbthreadlib Helper

local dbthreadlib = dbthreadlib
local protobuflib = protobuf
assert(nil ~= protobuflib)

DBThreadUtil = {}

function DBThreadUtil:Init(dbthreadlib_global)
    dbthreadlib = dbthreadlib_global
    --扩展dbthreadlib
    dbthreadlib.decode = DBThreadUtil.decode
    dbthreadlib.PostDataBaseEventMsg = DBThreadUtil.PostDataBaseEventMsg
end

function DBThreadUtil:decode(strTypeName, pDataBuffer, wLength)
    return protobuflib.decode(strTypeName, pDataBuffer, wLength)
end
function DBThreadUtil:PostDataBaseEventMsg(wRequestID, strTypeName, tbMsgContent)    
    protobuflib.encode(strTypeName, tbMsgContent,
        function (encodebuf, len)
            dbthreadlib:PostDataBaseEvent(wRequestID, encodebuf, len)
        end)
end


--endregion
