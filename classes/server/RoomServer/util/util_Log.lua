--region util_Log.lua
--Date 2015.8.27

--输出函数
local enumLogEventDebug = CLog:getLogEvent_Debug()
local enumLogEventNormal = CLog:getLogEvent_Normal()
local enumLogEventWarning = CLog:getLogEvent_Warning()
local enumLogEventException = CLog:getLogEvent_Exception()
local LogInstance = CLog:GetInstance()
function logDebug(strOutMsg)
    LogInstance:OutString(strOutMsg, enumLogEventDebug)
end
function logNormal(strOutMsg)
    LogInstance:OutString(strOutMsg, enumLogEventNormal)
end
function logWarning(strOutMsg)
    LogInstance:OutString(strOutMsg, enumLogEventWarning)
end
function logException(strOutMsg)
    LogInstance:OutString(strOutMsg, enumLogEventException)
end
function Util:OutString( strOutMsg, strType )
	if nil == strType or "Debug" == strType then
		CLog:GetInstance():OutString(strOutMsg, enumLogEventDebug)
	elseif "Normal" == strType then
		CLog:GetInstance():OutString(strOutMsg, enumLogEventNormal)
	elseif "Warning" == strType then
		CLog:GetInstance():OutString(strOutMsg, enumLogEventWarning)
	elseif "Exception" == strType then
		CLog:GetInstance():OutString(strOutMsg, enumLogEventException)
	end
end

function logDebug(msg)
    LogInstance:OutString(msg, enumLogEventDebug)
end 

function logNormal(msg)
    LogInstance:OutString(msg, enumLogEventNormal)
end 

function logWarning(msg)
    LogInstance:OutString(msg, enumLogEventWarning)
end 

function logErr(msg)
    LogInstance:OutString(msg, enumLogEventException)
end 

function logDebugf(str,...)
    local msg = string.format(str,...)
    LogInstance:OutString(msg, enumLogEventDebug)
end 

function logNormalf(str,...)
    local msg = string.format(str,...)
    LogInstance:OutString(msg, enumLogEventNormal)
end 

function logWarningf(str,...)
    local msg = string.format(str,...)
    LogInstance:OutString(msg, enumLogEventWarning)
end 

function logErrf(str,...)
    local msg = string.format(str,...)
    LogInstance:OutString(msg, enumLogEventException)
end 

--[Comment]
--打印过期方法的使用的警告信息
function logDeprecatedFunc(old, new)
    if config.DEBUG then
        logWarningf("Deprecated function %s will not be available in the future, new function %s is available now, stack information as below: \n%s\n", 
            old, new, debug.traceback())
    end 
end 

--endregion
