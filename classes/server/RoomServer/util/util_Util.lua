
Util = {}

require("util/util_Time")
require("util/util_Log")
require("util/util_String")

local classes = {}

local _mt = {
    __call = function(this,...)
        local obj = {}
        if this._super and this._super.__init then 
            this._super.__init(obj,...)
        end 
        this.__init(obj,...)
        return setmetatable(obj,this)
    end
}

--[Comment]
--function __init(...) is required
--for class super, __init is optional
function Util:class(name, super)
    local this = classes[name]
    if this then 
        return this
    end 
    this = {}
    this._name = name
    this._super = super
    this.__index = function(t,k)
        local tmp = rawget(this, k)
        if tmp then 
            return tmp
        end 
        if this._super and this._super.__index then 
            if type(this._super.__index) == "table" then 
                return this._super.__index[k]
            elseif type(this._super.__index) == "function" then 
                return this._super.__index(t, k)
            else
                return this._super.__index
            end 
        end 
        return nil
--        return rawget(this, k) or (this._super and this._super.__index(t, k))
    end
    classes[name] = this
    return setmetatable(this,_mt)
end 

-- look up for `k' in list of tables 'plist'
local function search (k, plist)
	for i=1, table.getn(plist) do
		local v = plist[i][k] -- try 'i'-th superclass
		if v then 
			return v 
		end
	end
end

function Util:newClass (...)
	local c = {} -- new class
	-- class will search for each method in the list of its
	-- parents (`args' is the list of parents)
	local args = {...}
	setmetatable(c, {__index = 	function (t, k)
									return search(k, args)
								end})
	-- prepare `c' to be the metatable of its instances
	c.__index = c
	
	-- define a new constructor for this new class
	function c:new (o)
		o = o or {}
		setmetatable(o, c)
		return o
	end
	-- return new class
	return c
end
--判断文件是否存在
function Util:file_exists( path )
  local file = io.open(path, "rb")
  if file then file:close() end
  return file ~= nil
end

--功能：读取xml配置文件，读出相应标签下的所有信息
--xmlFilePath：加载xml的文件路径名
--mainTag：加载文件中想要加载的主标签名，比如<weapon>...</weapon>，<hero>...</hero>
--callback：为读出各种主标签属性值的回调函数，在这些回调函数中将对主标签下的每一项进行封装，并放入到适合的映射表中,比如map <SkillID, HeroSkill>。
--2015.04.02 @ huanjia
function Util:readxml( xmlFilePath, mainTag, getInfoCallback )
	if true == Util:file_exists(xmlFilePath) then
		local rawdata = xml.load(xmlFilePath)
		if nil == rawdata then return nil end

		local data = rawdata:find(mainTag)

		return getInfoCallback(nil, data)
	end
	return nil
end

function Util:copy_table(src_table)
    local new_table = {}
    for k, v in pairs(src_table or {}) do
        if type(v) ~= "table" then
            new_table[k] = v
        else
            new_table[k] = Util:copy_table(v)
        end
    end
    return new_table
end

--转化bool值
--将从xml文件中读出的相应布尔类型字段的字符串转化成真布尔类型
function Util:toboolean( value )

	if value == nil then return false end
	if ("string" == type(value)) and (value == "false" or value=="0") then return false end
	if ("number" == type(value)) and (value == 0) then return false end

	return true
end

--字符串分割函数
--传入字符串和分隔符，返回分割后的table
function Util:SplitString(str, delimiter)
	if str==nil or str=='' or delimiter==nil then
		return nil
	end
	
    local matchStr = string.format("[ ]*([^%s ]+)[ ]*%s*",delimiter,delimiter)
    local result = {}
    for match in string.gmatch(str, matchStr) do
        table.insert(result, match)
    end
    return result
end

function Util:ParseArray_Number(str, delimiter)
    local array = {}
    local items = Util:SplitString(str,delimiter)
    for _,item in ipairs(items or {}) do 
        local val = tonumber(str)
        table.insert(array, val)
    end 
    return array
end 

--将字符串分片且格式化输出
function Util:SplitFormatOutput( str, delimiter, format )
    local tab_str = Util:SplitString(str, delimiter)
    if nil == tab_str then return nil end
    local tab_res = {} 
    if "number" == format then
        for index, value in pairs(tab_str) do
            tab_res[#tab_res + 1] = tonumber(value)
            if nil == tab_res[#tab_res] then
                return nil
            end
        end
    elseif nil == format or "string" == format then
        return tab_str
    elseif "boolean" == format then
        for index, value in pairs(tab_str) do
            tab_res[#tab_res + 1] = Util:toboolean(value)
            if nil == tab_res[#tab_res] then
                return nil
            end
        end
    end

    return tab_res
end

--计算等级 
function Util:CalculateLevel( mapLevelLimit, Experience)
	assert("table" == type(mapLevelLimit) and "number" == type(Experience))
	--顺序查找
    local lv = 0
	for i=1, #mapLevelLimit do
		if (mapLevelLimit[i].Experience > Experience) then 
            lv = i - 1 
            lv = lv < 1 and 1 or lv
            return lv
        end
	end
	return #mapLevelLimit
end

local luaUtil = LuaUtil
--生成guid
function Util:CreateGuidString()
	local guidString = luaUtil:GenerateGuidString()
	return guidString
end

--[[
--随机算法
--param tableIndexWeight:权重的数组
--result 随机得到的数组下标
--]]
function Util:RandomIndex(tableIndexWeight)
    local totalweight = 0
    for i = 1, #tableIndexWeight do
        totalweight = totalweight + tableIndexWeight[i]
    end
    local randomvalue = math.random(totalweight)
    totalweight = 0
    local indexres = 1
    for i = 1, #tableIndexWeight do
        totalweight = totalweight + tableIndexWeight[i]
        if  randomvalue <= totalweight then
            indexres = i
            break
        end
    end
    return indexres
end

function safecall(func, ...)
    local args = {...}
	local bsuccess, result = xpcall(function() return func( unpack(args) ) end, 
            function() logErr(debug.traceback()) end)
    if bsuccess then
        return result
    end
    return false
end

--检测一个字符串是否为时间日期
--一个0000-00-00 00:00:00格式的字符串将被认为是时间日期
function Util:IsDatetime(str)
    if not str then 
        return false 
    end 
    if string.match(str,"%d%d%d%d%-%d%d*%-%d%d* %d%d*:%d%d*:%d%d*") then 
        return true 
    end 
    return false 
end 

--检测一个字符串是否为时间
--一个00:00:00格式的字符串将被认为是时间日期
function Util:IsTime(str)
    if not str then 
        return false 
    end 
    if not string.match(str,"[^ %d:]") and 
       string.match(str,"[ ]*%d%d*:%d%d*:%d%d*[ ]*") then 
        return true 
    end 
    return false 
end 

--检测一个字符串是否为数组
--如果字符串中出现";"或者","都会被认为数组
function Util:IsArray(str)
    if not str then 
        return false 
    end 
    if string.match(str,"[^;];[^;]") or string.match(str,",") then 
        return true 
    end 
    return false 
end 

--把数组解析为字符串
--仅支持数组和字符串
function Util:AryToString(ary)
    local str = ""
    for _, item in ipairs(ary) do 
        if type(item) == "table" then 
            local strItem = ""
            for __, i in ipairs(item) do 
                strItem = strItem..tostring(i)..";"
            end 
            str = str..strItem..","
        else 
            str = str..tostring(item)..","
        end
    end 
    return str
end 

--解析字符串为数组
--数组元素优先解析为数字
--字符串格式：xxx;xxx;...,xxx;xxx;...,...
function Util:ParseArray(str)
    local rtn = {}
    if not str then
        return rtn
    end
    local items = Util:SplitString(str,",")
    for _,item in ipairs(items or {}) do 
        local strs = Util:SplitString(item,";") or {}
        if #strs > 1 then 
            itemInfo = {}
            for _,str in ipairs(strs) do 
                local val = tonumber(str)
                val = val or str
                table.insert(itemInfo,val)
            end 
            table.insert(rtn,itemInfo)
        elseif #strs == 1 then
            local val = tonumber(strs[1])
            val = val or strs[1]
            table.insert(rtn,val)
        else
            error("invalid split")
        end 
    end 
    return rtn 
end 

function Util:ParseDatetime(str)
    return Util:datetime2Number(str)
end 

function Util:ParseTime(str)
    local strTime = string.match(str,"%d%d*:%d%d*:%d%d*")
    local funcMatch = string.gmatch(strTime, "%d%d*")
    local h = funcMatch()
    local m = funcMatch()
    local s = funcMatch()
    return h * 3600 + m * 60 + s
end 

function Util:LoadXml(xmlFilePath,mainTag)
    mainTag = mainTag or "root"
    -------------------------------
    local rawdata = xml.load(xmlFilePath)
    if not rawdata then 
        return 
    end 

    local data = rawdata:find(mainTag)

    return data 
end 

--[Comment]
--[[
自动解析xml数据，在主Tag下的各个子Tag将各自解析为一个table, table名称与子Tag一致
@xmlFilePath: xml文件路径
@priKeys: lua表主键数组，支持多个lua表的主键设置，如果是单个表的主键（默认为mainTag表的主键，mainTag默认为root)
    如果设置多个表的主键，则需要显示指定各个表名称对应的主键数组，例如：
    指定单个表的主键：{"id", "seq"},
    指定多个表的主键：{user = {"id"}, items = {"id", "seq"}}
@mainTag: 在xml文件中根标记，默认值为"root"
@strProps: 字符串属性，由于对字符串的解析优先级最低，所以有可能字符串会被误认为其他类型的值，如数组，所以提供接口指定
           具体为字符串类型的属性，指定规则为{propName1 = true, propName2 = true,...}
@custParseFunc: 自定义解析方法（由于解析规则存在不完善地方，有些xml需要自行解析），声明如下：
                function custParseFunc(xmlData) return custTbl end
解析流程如下：
  优先检测已经指定的字符类型的属性
  如果属性值包含字符","或者";"将被解析为数组
  如果属性值包含日期格式0000-00-00 00:00:00，将被解析为日期
  如果属性值为时间 00:00:00，将被解析为时间（单位：秒）
  如果属性值可以被解析为数字，则被解析为数字
  否则解析为字符串
示例：
    简单用法：
    Util:ParseXml("xxx/yy.xml",{"id"})
    Util:ParseXml("xxx/yy.xml",{root = {"id"}, user = {"id"}})
    自定义mainTag,主键以及字符串类型字段：
    Util:ParseXml(
                    "xxx/yy.xml",
                    {"id","color","lv"},
                    "items",
                    {desc = true, name = true}
                  )
    Util:ParseXml(
                    "xxx/yy.xml",
                    {root = {"id","color","lv"}, user = {"aaa", "bbb"}},
                    "items",
                    {desc = true, name = true}
                  )
    自定义解析方法：
    Util:ParseXml(
                    "xxx/yy.xml",
                    nil,
                    "items",
                    nil,
                    parseFunc
                  )
--]]
function Util:ParseXml(xmlFilePath,priKeys,mainTag,strProps,custParseFunc)
    priKeys = priKeys or {}
    strProps = strProps or {}
    ---------------------------------

--    local priKeysLen = #priKeys 
--    local xmlData = self:LoadXml(xmlFilePath,mainTag)
--    if not xmlData then 
--        logErrf("nil xml data got when parse xml(%s) with main tag(%s)",tostring(xmlFilePath),tostring(mainTag))
--        return 
--    end 
    local xmlTotalData = self:LoadXml(xmlFilePath,mainTag)
    if not xmlTotalData then 
        logErrf("nil xml data got when parse xml(%s) with main tag(%s)",tostring(xmlFilePath),tostring(mainTag))
        return 
    end 
    local nextKey, nextVal = next(priKeys)
    if nextVal and type(nextVal) ~= "table" then
        local tmp = {root = priKeys}
        priKeys = tmp
    end 
    local function loadXmlData(parent, parentKey, xmlData)
        if xmlData[1] then 
            parent[xmlData[0]] = parent[xmlData[0]] or {}
            for _, xml in ipairs(xmlData) do 
                loadXmlData(parent[xmlData[0]], xmlData[0], xml)
            end 
        else
            local tblPriKeys = priKeys[parentKey]
            local tblPriKeysLen = tblPriKeys and #tblPriKeys or 0
            local tbl = parent
            if xmlData[0] then 
                local item = {}
                for k, v in pairs(xmlData) do 
                    if strProps[k] then 
                        item[k] = v
                    elseif self:IsArray(v) then 
                        item[k] = self:ParseArray(v)
                    elseif self:IsDatetime(v) then 
                        item[k] = self:ParseDatetime(v)
                    elseif self:IsTime(v) then 
                        item[k] = self:ParseTime(v)
                    elseif tonumber(v) then 
                        item[k] = tonumber(v)
                    else 
                        item[k] = v
                    end 
                end 
                local tmp = tbl 
                if tblPriKeys then 
                    for __,key in ipairs(tblPriKeys) do 
                        if __ < tblPriKeysLen then 
                            local kv = item[key]
                            assert(kv,string.format("specified primary key is not contained in config table(xml: %s, main tag: %s)",tostring(xmlFilePath),tostring(mainTag)))
                            tmp[kv] = tmp[kv] or {}
                            tmp = tmp[kv]
                        end 
                    end 
                    local key = tblPriKeys[tblPriKeysLen]
                    local kv = item[key]
                    assert(kv,string.format("specified primary key is not contained in config table(xml: %s, main tag: %s)",tostring(xmlFilePath),tostring(mainTag)))
                    tmp[kv] = item
                else
                    table.insert(tmp, item)
                end 
            end 
        end
    end
    if custParseFunc then 
        return custParseFunc(xmlTotalData)
    else 
        local tbl = {}
        for _,xmlItem in pairs(xmlTotalData) do 
            loadXmlData(tbl, mainTag or "root", xmlItem)
        end 
        return tbl
    end
--    xmlData:find()
--    if custParseFunc then 
--        return custParseFunc(xmlData)
--    else 
--        assert(priKeysLen > 0,string.format("nil primary keys specified when parse xml(%s) with main tag(%s)",tostring(xmlFilePath),tostring(mainTag)))

--        local tbl = {}
--        for _,xmlItem in pairs(xmlData) do 
--            if xmlItem[0] then 
--                local item = {}
--                for k,v in pairs(xmlItem) do 
--                    if strProps[k] then 
--                        item[k] = v
--                    elseif self:IsArray(v) then 
--                        item[k] = self:ParseArray(v)
--                    elseif self:IsDatetime(v) then 
--                        item[k] = self:ParseDatetime(v)
--                    elseif self:IsTime(v) then 
--                        item[k] = self:ParseTime(v)
--                    elseif tonumber(v) then 
--                        item[k] = tonumber(v)
--                    else 
--                        item[k] = v
--                    end 
--                end 
--                local tmp = tbl 
--                for __,key in ipairs(priKeys) do 
--                    if __ < priKeysLen then 
--                        local kv = item[key]
--                        assert(kv,string.format("specified primary key is not contained in config table(xml: %s, main tag: %s)",tostring(xmlFilePath),tostring(mainTag)))
--                        tmp[kv] = tmp[kv] or {}
--                        tmp = tmp[kv]
--                    end 
--                end 
--                local key = priKeys[priKeysLen]
--                local kv = item[key]
--                assert(kv,string.format("specified primary key is not contained in config table(xml: %s, main tag: %s)",tostring(xmlFilePath),tostring(mainTag)))
--                tmp[kv] = item
--            end 
--        end 
--        return tbl 
--    end 
end 

--[[
获取两个时间间隔天数
--TODO 需要优化，系统时间日期os.time和os.date将是一个很耗时的操作
--]]
function Util:GetPassedDays(from, to)
    local offset = enGameSystemTimeParams.enNewDayHour * 3600
    from = from - offset
    to = to - offset
    from = from > 0 and from or 0
    to = to > 0 and to or 0
    local day1 = os.date("*t",from).day
    local day2 = os.date("*t",to).day
    return day2 - day1
end

function Util:calculateLineDistance(jingdu1,weidu1,jingdu2,weidu2)
    local longitude1 = tonumber(jingdu1);
	local latitude1 = tonumber(weidu1);
	local longitude2 = tonumber(jingdu2);
	local latitude2 = tonumber(weidu2);
	
	longitude1 = longitude1 * 0.01745329251994329
	latitude1 = latitude1 * 0.01745329251994329
	longitude2 = longitude2 * 0.01745329251994329
	latitude2 = latitude2 * 0.01745329251994329
	local d6 = math.sin(longitude1);
	local d7 = math.sin(latitude1);
	local d8 = math.cos(longitude1);
	local d9 = math.cos(latitude1);
	local d10 = math.sin(longitude2);
	local d11 = math.sin(latitude2);
	local d12 = math.cos(longitude2);
	local d13 = math.cos(latitude2);
    local arrayOfDouble1 = {}
	local arrayOfDouble2 = {}
	arrayOfDouble1[0] = (d9 * d8);
	arrayOfDouble1[1] = (d9 * d6);
	arrayOfDouble1[2] = d7;
	arrayOfDouble2[0] = (d13 * d12);
	arrayOfDouble2[1] = (d13 * d10);
	arrayOfDouble2[2] = d11;
	local d14 = math.sqrt((arrayOfDouble1[0] - arrayOfDouble2[0]) * (arrayOfDouble1[0] - arrayOfDouble2[0]) + (arrayOfDouble1[1] - arrayOfDouble2[1]) * (arrayOfDouble1[1] - arrayOfDouble2[1]) + (arrayOfDouble1[2] - arrayOfDouble2[2]) * (arrayOfDouble1[2] - arrayOfDouble2[2]));
	    
	return math.asin(d14 / 2.0) * 1.27420015798544E7
end
