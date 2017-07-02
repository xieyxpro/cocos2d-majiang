--region *.lua
--Date
--房号管理器

local RoomnumManager = {
    FreeNums = {},
    PlayingTables = {}
}
local REQUEST_ROOMNUM_NUM = 50 --单次请求随机房号数量
local REQUEST_ROOMNUM_LEFT_MIN = 10--剩余小于10个的时候请求随机房号

RoomnumManager = Util:newClass(RoomnumManager,SystemBase)

local workthreadlib = workthreadlib
local serverusermgr = serverusermgr
local servermanager = servermanager


function RoomnumManager:OnServiceStart(workthread_global, kindid, serverid, server_ip, server_port)
    workthreadlib = workthread_global
    serverusermgr = workthread_global.serverusermgr
    servermanager = workthread_global.servermanager
end

function RoomnumManager:getTableFrame(roomnum)
    return self.PlayingTables[roomnum] 
end
function RoomnumManager:pickFreeRoomNum(pTableFrame)
    if #self.FreeNums <= 0 then
        return
    end
    local targetRoomnum = table.remove(self.FreeNums)
    assert(nil == self.PlayingTables[targetRoomnum])
    self.PlayingTables[targetRoomnum] = pTableFrame
    if #self.FreeNums < REQUEST_ROOMNUM_LEFT_MIN then
        local req = {
            server = {type = "ROOM_SERVER",serverid = servermanager.localServer.serverid,kindid = servermanager.localServer.kindid},
            num = REQUEST_ROOMNUM_NUM
        }
        workthreadlib:SendMsgToOCS(CMD_OCS_ROOMNUM.MAIN,CMD_OCS_ROOMNUM.MC_ROOMNUM_RAND,"OCSmsg.mc_room_rand_roomnum",req)
    end
    return targetRoomnum
end
function RoomnumManager:releaseRoomNum(pTableFrame,roomnum)
    assert(pTableFrame == self.PlayingTables[roomnum])
    self.PlayingTables[roomnum] = nil
    local req = {
        server = {type = "ROOM_SERVER",serverid = servermanager.localServer.serverid,kindid = servermanager.localServer.kindid},
        roomnum = roomnum
    }
    workthreadlib:SendMsgToOCS(CMD_OCS_ROOMNUM.MAIN,CMD_OCS_ROOMNUM.MC_ROOMNUM_RELEASE,"OCSmsg.mc_room_release_roomnum",req)
end

function RoomnumManager:on_oc_data_read(wMainCmdID, wSubCmdID, pDataBuffer, wDataSize)
    if wMainCmdID == CMD_OCS_ROOMNUM.MAIN then
        if wSubCmdID == CMD_OCS_ROOMNUM.MS_ROOMNUM_RAND then
            local pRandRes = workthreadlib:decode("OCSmsg.ms_room_rand_roomnum",pDataBuffer,wDataSize)
            return self:hanlder_ocs_roomnum_roomnum_rand_res(pRandRes)
        end
    end
    return 1
end

function RoomnumManager:hanlder_ocs_roomnum_roomnum_rand_res(pRandRes)
    for i,roomnum in pairs(pRandRes.roomnums) do
        local bIn = false;
        for i,tmproomnum in pairs(self.FreeNums) do
            if tmproomnum == roomnum then
                bIn = true
                break;
            end            
        end
        if not bIn then
            table.insert(self.FreeNums,1,roomnum)        
        end
    end 
    return 0
end

gameSystems[#gameSystems + 1] = RoomnumManager
return RoomnumManager

--endregion
