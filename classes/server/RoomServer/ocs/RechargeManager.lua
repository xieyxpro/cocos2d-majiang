--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local RechargeManager = {}

RechargeManager = Util:newClass(RechargeManager,SystemBase)

local workthreadlib = workthreadlib
local serverusermgr = serverusermgr

function RechargeManager:OnServiceStart(workthread_global, kindid, serverid, server_ip, server_port)
    workthreadlib = workthread_global
    serverusermgr = ServerUserManager:getInstance()
end

function RechargeManager:on_oc_data_read(wMainCmdID, wSubCmdID, pDataBuffer, wDataSize)
    if wMainCmdID == CMD_OCS_RECHARGE.MAIN then
        if wSubCmdID == CMD_OCS_RECHARGE.MC_WRITE_WEALTH_SUCCESS then
            local pRecharge = workthreadlib:decode("OCSmsg.mc_recharge_writewealth_success",pDataBuffer,wDataSize)
            local pServerUserItem = serverusermgr:getOnlineOrOfflineUserItem(pRecharge.userid)
            if nil ~= pServerUserItem then
                pServerUserItem.UserInfo.RoomCardNum = pServerUserItem.UserInfo.RoomCardNum + pRecharge.roomcardnum
            end
            return 0
        end
    end
end

gameSystems[#gameSystems + 1] = RechargeManager

return RechargeManager



--endregion
