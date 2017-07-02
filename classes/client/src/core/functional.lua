--region functional.lua
--Author : Administrator
--Date   : 2014-8-8
--此文件由[BabeLua]插件自动生成

assert = function(cond, fmt, ...)
    if cond then 
        return cond
    end 
    if fmt then 
        local msg = string.format(fmt, ...)
        print(msg)
    end 
    print(debug.traceback("", 2))
    error()
end 

--[[tables是否包含value值]]
function table.is_contain_value(tb,value)
    if not tb then return false end
    for _,v in pairs(tb) do
        if v == value then
            return true
        end
    end
    return false
end

--[[tables是否包含key值]]
function table.is_contain_key(tb,key)
    if not tb then return false end
    if  tb[key] == nil then
        return false
    end
    return  true 
end

--[Comment]
--插入并排序（后插）
--成功则返回插入后的索引值，否则返回0
--tbl: 需要排序的一个有序的array
--val: 需要插入的值
--comp_func: 自定义排序比较函数，声明：function(old, new) end
function table.insert_sort(ary, val, comp_func)
    comp_func = comp_func or function(old, new)
        return old > new
    end 
    local len = table.maxn(ary)
    local i = len
    while i > 0 do 
        local v = ary[i]
        local move = comp_func(v, val)
        if move then 
            ary[i + 1] = v
        else 
            break
        end 
        i = i - 1
    end 
    ary[i + 1] = val
    return i + 1
end 

--[Comment]
--删除数组中对应val的第一个值
--成功则返回删除索引，否则返回0
--cmpr_func: 自定义比较函数，声明：function(element) end
--           相等则返回true, 否则返回false
function table.delete(ary, val, cmpr_func)
    local ndx = 0
    for i, v in ipairs(ary) do 
        local equ = false 
        if cmpr_func then
            equ = cmpr_func(v)
        else 
            equ = v == val
        end 
        if equ then 
            ndx = i
            break
        end 
    end 
    if ndx == 0 then 
        return nil
    end 
    local ele = ary[ndx]
    local i = ndx
    local len = table.maxn(ary)
    while i < len do 
        ary[i] = ary[i + 1]
        i = i + 1
    end 
    ary[len] = nil
    return ele
end 

--[Comment]
--把from对应的元素移动到to对应的位置，其他元素位置依次顺移
function table.move(ary, from, to)
    from = from or 1
    to = to or #ary
    from = from < 1 and 1 or from
    to = to > #ary and #ary or to
    local i = from
    local len = #ary
    local backup = ary[from]
    if from < to then 
        while i < to do 
            ary[i] = ary[i + 1]
            i = i + 1
        end 
    else
        while i > to do 
            ary[i] = ary[i - 1]
            i = i - 1
        end 
    end 
    ary[i] = backup
end 

--[Comment]
--删除数组中对应vals的值
function table.delete_multi(ary, vals)
    local tmp = {}
    for k, v in pairs(vals) do 
        tmp[v] = tmp[v] or {value = v, num = 0}
        tmp[v].num = tmp[v].num + 1
    end 
    local tmpAry = {}
    for i, v in ipairs(ary) do 
        if tmp[v] then 
            tmp[v].num = tmp[v].num - 1
            if tmp[v].num <= 0 then 
                tmp[v] = nil
            end
        else
            table.insert(tmpAry, v)
        end 
    end 
    return tmpAry
end 

function table.clone(t)
    local tmp = {}
    local function __clone(t)
        local tbl = {}
        tmp[t] = tbl
        for k, v in pairs(t) do 
            if type(v) == "table" then 
                if not tmp[v] then 
                    tbl[k] = __clone(v)
                else 
                    tbl[k] = tmp[v]
                end 
            else 
                tbl[k] = v 
            end 
        end 
        return tbl
    end 

    return __clone(t)
end 

function table.tostring(t, format)
	local mark = {}
	local assign = {""}
    local indent_chars = "!   "
	local function serialize(tbl, parent, need_format, ident)
        ident = ident or ""
		mark[tbl] = parent
		local tmp = {}
        if need_format then
		    for k, v in pairs(tbl) do
			    local key = type(k) == "number" and "[" .. k .. "]" or k
			    if type(v) == "table" then
				    local dotkey = parent .. (type(k) == "number" and key or "." .. tostring(key))
				    if mark[v] then
					    table.insert(assign, "\n"..ident..indent_chars..dotkey .. " = " .. mark[v])
				    else
					    table.insert(tmp, "\n"..ident..indent_chars..tostring(key) .. " = " .. serialize(v, dotkey, need_format, ident..indent_chars))
				    end
			    else
				    table.insert(tmp, "\n"..ident..indent_chars..tostring(key) .. " = " .. (type(v) == "string" and "\"" .. v .. "\"" or tostring(v)))
			    end
		    end
            return "\n"..ident.."{" .. table.concat(tmp, ",") .."\n"..ident.."}"
        else
		    for k, v in pairs(tbl) do
			    local key = type(k) == "number" and "[" .. k .. "]" or k
			    if type(v) == "table" then
				    local dotkey = parent .. (type(k) == "number" and key or "." .. tostring(key))
				    if mark[v] then
					    table.insert(assign, dotkey .. "=" .. mark[v])
				    else
					    table.insert(tmp, tostring(key) .. "=" .. serialize(v, dotkey))
				    end
			    else
				    table.insert(tmp, tostring(key) .. "=" .. (type(v) == "string" and "\"" .. v .. "\"" or tostring(v)))
			    end
		    end
            return "{" .. table.concat(tmp, ",") .. "}"
        end 
	end
	assign[1] = serialize(t, "", format, "")
	return table.concat(assign, " ")
end

function table.tostring_format(t)
    indentation =  0

    local function cIn()
        local t = ""
        for i = 1,indentation,1 do
            t = t.."\t"
        end
        return t
    end

    local function addIn()
        indentation = indentation +1
        return cIn()
    end

    local function subIn()
        indentation = indentation -1
        return cIn()
    end

	local mark = {}
	local assign = {""}
	local function serialize(tbl, parent)
		mark[tbl] = parent
		local tmp = {}
		for k, v in pairs(tbl) do
			local key = type(k) == "number" and "\n"..cIn().."[" .. k .. "]" or k
			if type(v) == "table" then
				local dotkey = parent ..(type(k) == "number" and key or "." .. key)
				if mark[v] then
					table.insert(assign, dotkey .. "=" .. mark[v])
				else
					table.insert(tmp, key .. "=" .. "{\n"..addIn()..serialize(v, dotkey)..subIn().."\n}")
				end
			else
				table.insert(tmp, key .. "=" .. (type(v) == "string" and "\"" .. v .. "\"" or tostring(v)))
			end
		end
		return addIn().. table.concat(tmp, ",")
	end
	assign[1] = "{\n"..addIn()..serialize(t, "")..subIn().."\n}"
	return table.concat(assign, " ")
end


--数组划分
function table.split(tb,num)
    assert(type(tb) == "table")
    local endTb = {}
    num = num or 1
    assert(type(num) == "number")
    local count = #tb
    for i=1,count,num do 
        local subTb = {}
        local max = i+(num - 1)
        if i + num >count then
            max = count
        end
        for n = i,max,1 do
            table.insert(subTb,tb[n])
        end
        table.insert(endTb,subTb)
    end
    return endTb
end

--获取子项
function table.getsub(t, ...)
    local tmp = {...}
    if #tmp<1 then
        return nil
    end
    for _, v in ipairs(tmp) do
        t = t[v]
        if not t then
            return nil
        end
    end
    return t
end

--数组连接
function table.append(t1,...)
    assert(t1)
    for _,v in ipairs({...}) do
        for _1,v1 in ipairs(v) do
            table.insert(t1,v1)
        end
    end
end

--t1是否等于t2
function table.equals(t1,t2)
    if type(t1)~="table" or type(t2)~="table" then
        return false
    end
    return table.contain_table(t1,t2) and table.contain_table(t2,t1)
end
--t1是否包含t2
function table.contain_table(t1,t2)
    for _,v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[_]) ~= "table" then
                return false
            end
            if not table.contain_table(t1[_],v) then
                return false
            end
        else
            if v ~= t1[_] then
                return false
            end
        end
    end
    return true
end

--设置子项
function table.setsub(tb,...)
    assert(tb)
    local keys = {...}
    assert(#keys>1 )
    local value = keys[#keys]
    --剔除最后一个value 
    table.remove(keys,#keys)
    local endKey = keys[#keys]
    --剔除最后一个value 
    table.remove(keys,#keys)
    for _,v in ipairs(keys) do
        if tb[v] == nil then
            tb[v] = {}
        end
        tb = tb[v]
    end
    tb[endKey] = value
end

--插入子项内容，最末项为数组
function table.insertsub(tb,...)
    local keys = {...}
    local value = keys[#keys]
    --剔除最后一个value 
    table.remove(keys,#keys)
    for _,v in ipairs(keys) do
        if tb[v] == nil then
            tb[v] = {}
        end
        tb = tb[v]
    end
    if not type(tb) == "table" then
        tb = {}
    end
    table.insert(tb,value)
end

--清空数组
function table.clean(tbs)
    assert(tbs)
    local count =table.nums(tbs)
    while count>0 do
        table.remove(tbs,1)
        count = table.nums(tbs)
    end
end

function  string.subWord(str,beginPos,endPos)
    local t = string.totable(str)
   local allCount = #t
   endPos = endPos or allCount
   beginPos = beginPos or 1

   if endPos > allCount then
     endPos = allCount
   end
   if beginPos > allCount then
     endPos = allCount
   end

   local return_string = ""
   for i= beginPos,endPos,1 do
       return_string = return_string..t[i]
   end

   return return_string,beginPos,endPos
end

function string.totable(str)
    local len  = #str
    local left = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    local t = {}
    local start = 1
    local wordLen = 0
    while len ~= left do
        local tmp = string.byte(str, start)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                break
            end
            i = i - 1
        end
        wordLen = i + wordLen
        local tmpString = string.sub(str, start, wordLen)
        start = start + i
        left = left + i
        t[#t + 1] = tmpString
    end
    return t
end

function string.wordLen(str)
    return #string.totable(str)
end

function os.secondsToHourMinSec(seconds)
    local secs = checkint(seconds)
    local hour = math.modf(secs / (60*60))
    local min = math.modf((secs % (60*60)) / 60)
    local second = secs % 60

    return string.format("%02d:%02d:%02d", hour, min, second)
end

function os.secondsToDayHourMinSec(seconds)
    local secs = checkint(seconds)
    local day = math.modf(secs / (60*60*24))
    local hour = math.modf((secs % (60*60*24))/(60*60))
    local min = math.modf((secs % (60*60)) / 60)
    local second = secs % 60

    return string.format("%dd: %02d:%02d:%02d",day, hour, min, second)
end

function os.secondsToHourMin(seconds)
    local secs = checkint(seconds)
    local hour = math.modf(secs / (60*60))
    local min = math.modf((secs % (60*60)) / 60)

    return string.format("%02d:%02d", hour, min)
end

function os.secondsToMinSec(seconds)
    local secs = checkint(seconds)
    local min = math.modf((secs % (60*60)) / 60)
    local second = secs % 60

    return string.format("%02d:%02d", min, second)
end

-- 获取字符串大写字母个数
function os.getStringUpperNums(str)
    if str == nil then
		return 0
	end

    local upperNums = 0
	local len = string.len(str)
	for i = 1, len do
		local ch = string.sub(str, i, i)
		if ch >= 'A' and ch <= 'Z' then
			upperNums = upperNums + 1
		end
	end

    return upperNums
end

-- 获取字符串小写字母个数
function os.getStringLowerNums(str)
    if str == nil then
		return 0
	end

    local lowerNums = 0
	local len = string.len(str)
	for i = 1, len do
		local ch = string.sub(str, i, i)
		if ch >= 'a' and ch <= 'z' then
			lowerNums = lowerNums + 1
		end
	end

    return lowerNums
end

-- 获取字符串数字个数
function os.getStringNumberNums(str)
    if str == nil then
		return 0
	end

    local numberNums = 0
	local len = string.len(str)
	for i = 1, len do
		local ch = string.sub(str, i, i)
		if ch >= '0' and ch <= '9' then
			numberNums = numberNums + 1
		end
	end

    return numberNums
end

--[Comment]
--获取服务器时间
function os.timeExt()
    local curSysTime = os.time()
    local curServerTime = curSysTime - curServerSubTime
    --print("curServerSubTime"..curServerSubTime)
    --print("curSysTime->"..curSysTime)
    --print("curServerTime->"..curServerTime)
    return curServerTime
end
local zerosecond = os.time({year=1970,month=1,day=5,hour=0,min=0,sec=0})
--获取跨越的自然天数
function os.get_raw_pass_day(from, to)
    local t1 = from - zerosecond
    local t2 = to - zerosecond
    local day1 = math.modf(t1 / (24 * 3600))
    local day2 = math.modf(t2 / (24 * 3600))
    return day2 - day1
end
--获取跨越的天数
function os.get_pass_day(from, to)
    local t1 = from - zerosecond -(GlobalCache.PlayerCache.serverNextday or 0)
    local t2 = to - zerosecond -(GlobalCache.PlayerCache.serverNextday or 0)
    local day1 = math.modf(t1 / (24 * 3600))
    local day2 = math.modf(t2 / (24 * 3600))
    return day2 - day1
end
--获取跨越的周数
function os.get_pass_weak(from, to)
    local t1 = from - zerosecond  -(GlobalCache.PlayerCache.serverNextday or 0)
    local t2 = to - zerosecond -(GlobalCache.PlayerCache.serverNextday or 0)
    local week1 = math.modf(t1 / (24 * 3600 * 7))
    local week2 = math.modf(t2 / (24 * 3600 * 7))
    return week2 - week1
end
--获取当天秒数
function os.get_second_of_day(sec)
    return (sec - zerosecond) % (3600 * 24)
end

--获取离当天结束还有多少时间
function os.get_remain_time(curTime)
    assert(curTime)
    return (3600 * 24) - ((curTime - zerosecond -(GlobalCache.PlayerCache.serverNextday or 0) ) % (3600 * 24))
    --local curTimeTb = os.date("*t",curTime)
    --local zeroTime = os.time({year=curTimeTb.year,month=curTimeTb.month,day=curTimeTb.day,hour=0,min=0,sec=0})
    --return zeroTime - curTime + (GlobalCache.PlayerCache.serverNextday or 0)
end


--获取星期几（0-6）
function os.get_weak_day(sec) 
    local t = sec - zerosecond -(GlobalCache.PlayerCache.serverNextday or 0)
    local day = math.modf(t / (24 * 3600))
    local num = day % 7
    return (num + 1) % 7
end

--是否是白天
function os.isDuringDay()
    local time = tonumber(os.date("%H",os.time()))
    if time>6 and time < 18 then
        return true
    end
    return false  
end

--[Comment]
--把时间戳转换为日期时间
function os.toDateTimeString(timestamp)
    return os.date("%Y/%m/%d %H:%M:%S", timestamp)
end 

--[[--

获取table的minn和maxn

~~~ lua
T = { 
		[1] = { id=1001, multiples=1, weight=10, },
		[2] = { id=1001, multiples=2, weight=20, },
		[3] = { id=1001, multiples=3, weight=30, },
		[4] = { id=1001, multiples=4, weight=40, },
		[5] = { id=1001, multiples=5, weight=50, },
		[6] = { id=1001, multiples=6, weight=60, },
		[7] = { id=1001, multiples=7, weight=70, },
		[8] = { id=1001, multiples=8, weight=80, },
		[9] = { id=1001, multiples=9, weight=90, },
		[10] = { id=1001, multiples=10, weight=100, },
		[11] = { id=1001, multiples=11, weight=110, },
		[12] = { id=1001, multiples=12, weight=120, },
	}
    local minn, maxn = get_min_max_n(T)
print(minn..","..maxn)
-- 输出 1,12

~~~

@param tbl table

@return int,int 最大和最小索引值

]]
--[Comment]
--获取table的minn和maxn
function table.get_min_max_n(tbl)
    local min, max = 0, 0
    local k = 0
    for i,v in pairs(tbl) do 
        if type(i) == "number" then 
            if k == 0 then 
                min = i 
                max = i 
			    k = k + 1 
            else 
                if i < min then 
                    min = i 
                end 
                if i > max then 
                    max = i 
                end 
            end 
        end 
    end 
    return min, max 
end 


--[[--

把输入的秒数转换为时分秒的格式（时：分：秒）字符串

~~~ lua
print(toHHMMSS(12))
-- 输出 00:00:12

~~~

@param sec 秒

@return string 时分秒的格式字符串（时：分：秒）

]]
--[Comment]
--把输入的秒数转换为时分秒的格式（时：分：秒）字符串
function os.toHHMMSS(sec)
    local hour = math.floor(sec / 3600)
    local min = math.floor(sec / 60) % 60
    local sec = math.floor(sec % 60)
	return string.format("%02d:%02d:%02d",hour,min,sec),{hour = hour, min = min, sec = sec} 
end 

--[Comment]
--计算UTF8字符大小
function string.chsize(char)
    if not char then
        return 0
    elseif char > 240 then
        return 4
    elseif char > 225 then
        return 3
    elseif char > 192 then
        return 2
    else
        return 1
    end
end

--[Comment]
--获取UTF8字符串的长度
function string.len_utf8(str)
    local len = 0
    local currentIndex = 1
    while currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + string.chsize(char)
        len = len +1
    end
    return len
end

--[Comment]
--截取UTF-8字符串
function string.sub_utf8(str, startChar, numChars)
    if str == nil then 
        return ""
    end 

    startChar = startChar or 1
    assert(startChar ~= 0)
    startChar = startChar < 0 and (str:len() + startChar + 1) or startChar
    numChars = numChars or (str:len() - startChar + 1)
    local startIndex = 1
    while startChar > 1 do
        local char = string.byte(str, startIndex)
        startIndex = startIndex + string.chsize(char)
        startChar = startChar - 1
    end

    local currentIndex = startIndex

    while numChars > 0 and currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + string.chsize(char)
        numChars = numChars -1
    end
    return str:sub(startIndex, currentIndex - 1)
end

function string.last_index_of(str, char)
    local cv = string.byte(char, 1)
    local i = str:len()
    while i > 0 do 
        local b = string.byte(str, i)
        if b == cv then 
            return i
        end 
        i = i - 1
    end 
    return 0
end 

--[Comment]
--把颜色转换为字符串rrrgggbbb或aaarrrgggbbb
function string.colorToString(color)
    if not color then 
        return 
    end 
    if color.a then 
        return string.format("%03d%03d%03d%03d",color.r,color.g,color.b,color.a)
    else 
        return string.format("%03d%03d%03d",color.r,color.g,color.b)
    end 
end 

--[Comment]
--把颜色字符串转换为颜色
function string.stringToColor(str,force4B)
    if not str then 
        return 
    end 
    local match = string.gmatch(str,"%d%d%d");
    local r = stringToNumber(match())
    local g = stringToNumber(match())
    local b = stringToNumber(match())
    local a = stringToNumber(match())
    if not r or not g or not b then 
        print("[WARNING]:Invalid color string: "..tostring(str))
        return 
    end 
    if force4B then 
        a = a or 255
    end 
    if a then 
        return cc.c4b(r,g,b,a)
    else 
        return cc.c3b(r,g,b)
    end 
end 

--[Comment]
--获取字符串中的第一个数
function string.stringToNumber(str)
    if not str then 
        return 
    end 
    local numStr = string.match(str,"-?%d+")
    if numStr then 
        return tonumber(numStr)
    end 
end 

function math.floatSecond(value)
    if type(value) == "number" and math.floor(value)<value then
            local a,b = math.modf(value)
            value =a+(math.modf(b*100)/100)
    end
    return value
end

--时间转换
function os.convertTime(time)
    local time_t = os.date("*t",os.timeExt())
    time_t.hour = 0
    time_t.min = 0
    time_t.sec = 0
    local cur_time = os.time(time_t)
    if time <cur_time then
        return(os.date("%m-%d",time))
    else
        return(os.date("%H:%M",time))
    end
    --return os.date("%m月%d日 %H:%M",time)
end

--数字转黄
function os.convertNum(num)
    if num <=100000 then
        return ""..num
    else
        return string.format("%d万",math.floor(num/10000))
    end

end
--endregion
