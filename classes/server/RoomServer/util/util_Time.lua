
--格式要求：2015-4-2 18:01:00
function Util:datetime2Number( datetime )

	local formatedtime = {}

	local datetimeTable = Util:SplitString(datetime, " ")
    assert("table" == type(datetimeTable) and 2 == #datetimeTable)
	local date = datetimeTable[1]
	local time = datetimeTable[2]

	local dateTable = Util:SplitString(date, "-")
	formatedtime.year = tonumber(dateTable[1])
	assert(nil ~= formatedtime.year)
	formatedtime.month = tonumber(dateTable[2])
	assert(nil ~= formatedtime.month)
	formatedtime.day = tonumber(dateTable[3])
	assert(nil ~= formatedtime.day)

	local timeTable = Util:SplitString(time, ":")
	formatedtime.hour = tonumber(timeTable[1])
	assert(nil ~= formatedtime.hour and formatedtime.hour <= 24)
	formatedtime.min  = tonumber(timeTable[2])
	assert(nil ~= formatedtime.min and formatedtime.min < 60)
	formatedtime.sec  = tonumber(timeTable[3])
	assert(nil ~= formatedtime.sec and formatedtime.sec < 60)

	--year <= 3000
	return os.time(formatedtime)
end

--获得标准时间格式:2015-5-13 14:20:20
function Util:GetStandardDateTime( mechineTime )
	return os.date("%Y-%m-%d %H:%M:%S", mechineTime)
end
--获得标准时间的日期部分
function Util:GetStandardDate( mechineTime )
	return os.date("%Y-%m-%d", mechineTime)
end
--获得下一天的日期
function Util:GetNextStandardDate( mechineTime )
	return os.date("%Y-%m-%d", mechineTime + 24 * 3600)
end

--获得小时
function Util:GetHourNumber( mechineTime )
	return tonumber(os.date("%H", mechineTime))
end
--获得日
function Util:GetDayNumber( mechineTime )
	return tonumber(os.date("%d", mechineTime))
end


--计算两个日期相差小时数
function Util:TimeDifferenceHours( current, previous )
	local diff = current - previous
	return math.floor(diff / 3600)
end

--计算两个时间的相差分钟数
--时间为格林威治时间,单位为秒
function Util:TimeDifferenceMinutes( current, previous )
	local diff = current - previous
	return math.floor(diff / 60)
end

--计算两个时间相差秒数
function Util:TimeDifferenceSeconds( current, previous )
	return current - previous
end

--不同的一天，日期不同
function Util:IsDifferentDay(current, previous)
	local current_day = Util:GetDayNumber(current)
	local previous_day = Util:GetDayNumber(previous)

	return (current_day ~= previous_day)
end

--每日清理计时器初始化
function Util:GetNextDailyClearTimerElapse()
	--计算当前时间到下一个6:00整的时间间距
	local currenttime = os.time_ext()
	local nextcleartime = nil
	local hour = Util:GetHourNumber(currenttime)
	local nextcleardatestr = nil
	--当前时间小于6点整
	if hour < enGameSystemTimeParams.enNewDayHour then
		nextcleardatestr = Util:GetStandardDate(currenttime)
	--当前时间超过6点整
	else
		nextcleardatestr = Util:GetNextStandardDate(currenttime)
	end

	local nextcleartime = Util:datetime2Number(nextcleardatestr .. " " .. enGameSystemTimeParams.enNewDayHour .. ":00:00")

	return Util:TimeDifferenceSeconds(nextcleartime, currenttime)
end

--判断当前时间是否为新的一天
function Util:IsANewDay( currenttime, previoustime )
    currenttime = currenttime - enGameSystemTimeParams.enNewDayHour * 3600 + enGameSystemTimeParams.enGMT * 3600
    previoustime = previoustime - enGameSystemTimeParams.enNewDayHour * 3600 + enGameSystemTimeParams.enGMT * 3600
    curDay = math.floor(currenttime / (24 * 3600))
    preDay = math.floor(previoustime / (24 * 3600))
    return curDay > preDay
end


