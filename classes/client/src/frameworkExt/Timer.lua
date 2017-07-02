--region RWTimer.lua
--Author : Administrator
--Date   : 2014/6/30

local Timer = class("Timer")

local scheduler = cc.Director:getInstance():getScheduler()

--[Comment]
--timeSeconds: if < 0, then timer will execute forever
function Timer:ctor(timeSeconds, caller, callbackFuncOrFuncName, tickFuncOrName, tickTimeIntvl)
    self._time = timeSeconds
    self._caller = caller
    self._callbackFuncOrFuncName = callbackFuncOrFuncName
    self._scheduleID = 0
    self._tickFuncOrName = tickFuncOrName
    self._tickTimeIntvl = tickTimeIntvl or 1
    self.remainTime = self._time
    if type(callbackFuncOrFuncName) == "string" then 
        if not caller then 
            error("if specified function is a name, then caller must be specified and cannot be nil")
        end 
    end 
    return timer
end

function Timer:__onTimer()
    if not self._callbackFuncOrFuncName or self._callbackFuncOrFuncName == "" then 
        return
    end 
    local funcType = type(self._callbackFuncOrFuncName)
    local func = nil
    if funcType == "string" then 
        if self._caller and self._caller[self._callbackFuncOrFuncName] then 
            func = self._caller[self._callbackFuncOrFuncName]
        end 
    elseif funcType == "function" then 
        func = self._callbackFuncOrFuncName
    else 
        printError("unsupported timer function type: %s", funcType)
    end 
    if not func then
        printError("nil timer function found")
    else 
        if self._caller then
            func(self._caller)
        else 
            func()
        end
    end
end 

function Timer:__tick()
    if not self._tickFuncOrName or self._tickFuncOrName == "" then 
        return
    end 
    local funcType = type(self._tickFuncOrName)
    local func = nil
    if funcType == "string" then 
        if self._caller and self._caller[self._tickFuncOrName] then 
            func = self._caller[self._tickFuncOrName]
        end 
    elseif funcType == "function" then 
        func = self._tickFuncOrName
    else 
        printError("unsupported timer tick function type: %s", funcType)
    end 
    if not func then
        printError("nil timer tick function found")
    else 
        if self._caller then
            func(self._caller)
        else 
            func()
        end
    end
end 

function Timer:start()
    local prevTickTime = 0
    self._startTime = os.time()
    self._scheduleID = scheduler:scheduleScriptFunc(function()
        local nowTime = os.time()
        local delta = nowTime - self._startTime
        self.remainTime = self._time - delta
        self.remainTime = self.remainTime < 0 and 0 or self.remainTime
        if nowTime >= prevTickTime + self._tickTimeIntvl then 
            self:__tick()
            prevTickTime = nowTime
        end 
        if self._time >= 0 and self.remainTime <= 0 then 
            self:__onTimer()
            scheduler:unscheduleScriptEntry(self._scheduleID)
        end 
    end, 0, false)
    self:__tick()
end

function Timer:stop()
    if not self._scheduleID or self._scheduleID == 0 then 
        return
    end
    scheduler:unscheduleScriptEntry(self._scheduleID)
end

return Timer
--endregion
