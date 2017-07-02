
require("./loadxml/tools/LuaXml")

-- look up for `k' in list of tables 'plist'
local function search (k, plist)
	for i=1, table.getn(plist) do
		local v = plist[i][k] -- try 'i'-th superclass
		if v then 
			return v 
		end
	end
end

function newClass (...)
	local c = {} -- new class
	-- class will search for each method in the list of its
	-- parents (`arg' is the list of parents)
	
	setmetatable(c, {__index = 	function (t, k)
									return search(k, arg)
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


--功能：读取xml配置文件，读出相应标签下的所有信息
--xmlFileName：加载xml的文件路径名
--mainTag：加载文件中想要加载的主标签名，比如<weapon>...</weapon>，<hero>...</hero>
--callback：为读出各种主标签属性值的回调函数，在这些回调函数中将对主标签下的每一项进行封装，并放入到适合的映射表中,比如map <SkillID, HeroSkill>。
--2015.04.02 @ huanjia
function readxml( xmlFileName, mainTag, callback )

	local data = xml.load(xmlFileName):find(mainTag)

	return callback(data)

end

--转化bool值
--将从xml文件中读出的相应布尔类型字段的字符串转化成真布尔类型
function toboolean( value )

	if value == nil then return false end
	if ("string" == type(value)) and (value == "false") then return false end
	if ("number" == type(value)) and (value == 0) then return false end

	return true
end

--格式要求：2015-4-2 18:01
function date2Number( datetime )

	local timetable = {}

	local pos = string.find(datetime, " ", 1)
	local date = string.sub(datetime, 1, pos-1)
	local time = string.sub(datetime, pos+1, string.len(datetime))


	pos = string.find(date, "-", 1)
	timetable.year = tonumber(string.sub(date, 1, pos-1))
	local pos2 =  string.find(date, "-", pos+1)
	timetable.month = tonumber(string.sub(date, pos+1, pos2-1))
	timetable.day = tonumber(string.sub(date, pos2+1, string.len(date)))

	pos = string.find(time, ":")
	timetable.hour = tonumber(string.sub(time, 1, pos-1))
	timetable.min = tonumber(string.sub(time, pos+1, string.len(time)))
	
	--print("year=" .. year .. ", month=" .. month .. ",day=" .. day .. ", hour=" .. hour .. ", min=" .. min)
	--print(os.time(timetable))

	return os.time(timetable)

end