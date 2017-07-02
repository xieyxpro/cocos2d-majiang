--region GlobalScheduler.lua
--Author : Administrator
--Date   : 2014-11-7
--此文件由[BabeLua]插件自动生成
local SchedulerExt = {}

SchedulerExt.EVENT_SECOND = "EVENT_SECOND"
SchedulerExt.EVENT_MINUTE = "EVENT_MINUTE"
SchedulerExt.EVENT_HOUR = "EVENT_HOUR"

local scheduler = cc.Director:getInstance():getScheduler()

local sSchedulerID = 0
local mSchedulerID = 0
local hSchedulerID = 0

function SchedulerExt:start()
    sSchedulerID = scheduler:scheduleScriptFunc(function()
        Event.dispatch(SchedulerExt.EVENT_SECOND)
    end, 1, false)

    mSchedulerID = scheduler:scheduleScriptFunc(function()
        Event.dispatch(SchedulerExt.EVENT_MINUTE)
    end, 60, false)

    mSchedulerID = scheduler:scheduleScriptFunc(function()
        Event.dispatch(SchedulerExt.EVENT_HOUR)
    end, 3600, false)
end

function SchedulerExt:stop()
    scheduler:unscheduleScriptEntry(sCheduleID)
    scheduler:unscheduleScriptEntry(mSchedulerID)
    scheduler:unscheduleScriptEntry(hSchedulerID)
end 

function SchedulerExt:delayExecute(delayTime, func)
    local schedulerID = 0
    schedulerID = scheduler:scheduleScriptFunc(function()
        func()
        scheduler:unscheduleScriptEntry(schedulerID)
    end, delayTime, false)
end 

return SchedulerExt
--endregion
