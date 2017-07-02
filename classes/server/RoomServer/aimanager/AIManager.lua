
AIManager = {
    mActiveAIItems = {},
    mAIStroage = {},--AI存储
}
AIManager = Util:newClass(AIManager)
local aithreadlib = aithreadlib
--region instance
local __aiManagerInstance = nil --单例模式
function AIManager:getInstance( )
	if nil == __aiManagerInstance then
		__aiManagerInstance = AIManager:new()
        for i = 1, 500 do
            table.insert(__aiManagerInstance.mAIStroage,(20000+i))            
        end
        
	end
	return __aiManagerInstance
end
--endregion

function AIManager:getAIUserItemByUserID(dwUserID)
    for _,item in pairs(self.mActiveAIItems) do
        if dwUserID == item.UserID then
            return item
        end
    end
    
end

--region ai storage 
function AIManager:getFreeAINum()
    return table.count(self.mAIStroage)
end
function AIManager:pickOneFreeAI()
    local freeAIUserID = table.remove(self.mAIStroage)    
    assert(nil ~= freeAIUserID)
    return freeAIUserID
end
--endregion
--region 
function AIManager:ai_send_logon(socketFd,RoomNum)
    local userid = self:pickOneFreeAI()
    assert(self.mActiveAIItems[socketFd] == nil)
    local pAIItem = AIGame:new()
    pAIItem:Init(socketFd,userid,RoomNum)
    self.mActiveAIItems[socketFd] = pAIItem
end
--endregion

function AIManager:on_service_start(aiThread)
    aithreadlib = aiThread
end

function AIManager:on_service_stop()

end

function AIManager:on_timer_event(dwTimerID,dwBindParam)
    local userid = math.floor(dwTimerID/TIMER.TIME_AI_MODULE_RANGE)
    local pAIItem = self:getAIUserItemByUserID(userid)
    assert(nil ~= pAIItem,"on_timer_event ai item nil timerid:" .. dwTimerID)
    pAIItem:onTimerMessage(dwTimerID-userid*TIMER.TIME_AI_MODULE_RANGE,dwBindParam)
end

function AIManager:on_service_event(wRequestID, pDataBuffer, wDataSize)   
    if wRequestID == AIR_W2AI.REQUEST_AI_SITDOWN then
        local pRequestAI = protobuf.decode("AIRMsg.Service_MW_RequestAI",pDataBuffer,wDataSize)
        --region check ai enough
        local sitdownNum = pRequestAI.needainum
        local leftFreeAI = self:getFreeAINum()
        if leftFreeAI < sitdownNum then
            logErrf("request ai sitdown err no enough ai:need:%d,left:%d",sitdownNum,leftFreeAI)
            sitdownNum = leftFreeAI
        end
        --endregion
        for i = 1, sitdownNum do
            local dwSocketFd = aithreadlib:Connect()
            self:ai_send_logon(dwSocketFd,pRequestAI.roomnum)
        end
        return true
    end
end

function AIManager:on_socket_read_data(socketFd, wMainCmdID, wSubCmdID, pDataBuffer, wDataSize)

    local pAIUserItem = self.mActiveAIItems[socketFd]
    assert(nil ~= pAIUserItem)
    pAIUserItem:OnSocketRead(wMainCmdID, wSubCmdID, pDataBuffer, wDataSize)

end

function AIManager:on_socket_close(socketFd)

    local pAIUserItem = self.mActiveAIItems[socketFd]
    assert(nil ~= pAIUserItem)
    self.mActiveAIItems[socketFd] = nil

end