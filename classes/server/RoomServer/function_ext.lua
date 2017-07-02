--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
table.count = function(tbl)
    local cnt = 0
    for _,_ in pairs(tbl) do 
        cnt = cnt + 1
    end 
    return cnt 
end 

function table.tostring(t, format)
	local mark = {}
	local assign = {""}
	local function serialize(tbl, parent, need_format, ident)
        if not tbl then 
            return "\n"..ident.."{\n" .. "nil" .."\n"..ident.."}"
        end 
--        print("tbl: " .. tostring(tbl) .. ", parent: " .. tostring(parent) .. ", need_format: " .. tostring(need_format) .. ", ident: " .. tostring(ident))
        ident = ident or ""
		mark[tbl] = parent
		local tmp = {}
        if need_format then
		    for k, v in pairs(tbl) do
			    local key = type(k) == "number" and "[" .. k .. "]" or k
			    if type(v) == "table" then
				    local dotkey = parent .. (type(k) == "number" and key or "." .. tostring(key))
				    if mark[v] then
					    table.insert(assign, "\n"..ident.."    "..dotkey .. " = " .. mark[v])
				    else
					    table.insert(tmp, "\n"..ident.."    "..tostring(key) .. " = " .. serialize(v, dotkey, need_format, ident.."    "))
				    end
			    else
				    table.insert(tmp, "\n"..ident.."    "..tostring(key) .. " = " .. (type(v) == "string" and "\'" .. v .. "\'" or tostring(v)))
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
				    table.insert(tmp, tostring(key) .. "=" .. (type(v) == "string" and "\'" .. v .. "\'" or tostring(v)))
			    end
		    end
            return "{" .. table.concat(tmp, ",") .. "}"
        end 
	end

    local str_tbl = ""
    xpcall(function()
	    assign[1] = serialize(t, "", format, "")
	    str_tbl = table.concat(assign, " ")
    end, function(msg)
        print(msg)
    end)
    return str_tbl
end

function table.nums(t)
	local n = 0
	for _, _ in pairs(t) do
		n = n + 1
	end
	return n
end

function table.inums(t)
	return #t
end

function table.empty(t)
	return next(t) == nil
end

function table.keys(t)
	local keys = {}
	for k, _ in pairs(t) do
		table.insert(keys, k)
	end
	return keys
end

function table.ifind(t, func)
    for i, v in ipairs(t) do
        if func(v) then
            return i, v
        end
    end
    return nil
end

function table.find(t, func)
    for k, v in pairs(t) do
        if func(v) then
            return k, v
        end
    end
    return nil
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

function time_to_string(sec)
    local date_time = os.date("*t", sec)
    return string.format("%d/%d/%d %d:%d:%d", date_time.year, date_time.month, date_time.day, date_time.hour, date_time.min, date_time.sec)
end

function string.ltrim(str)
    return string.gsub(str, "^[ \t\n\r]+", "")
end

function string.rtrim(str)
    return string.gsub(str, "[ \t\n\r]+$", "")
end

function string.trim(str)
    str = string.gsub(str, "^[ \t\n\r]+", "")
    return string.gsub(str, "[ \t\n\r]+$", "")
end

function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

os.time_offset = 0

function os.time_ext()
    return os.time() + os.time_offset
end 

--[[
获取时间戳转换的具体日期时间字符串
@sec: 如果sec为nil, 则返回当前时间日期
--]]
function os.get_str_of_datetime(sec)
    sec = sec or os.time_ext()
    local datetime = os.date("*t", sec)
    return string.format("%04d-%02d-%02d %02d:%02d:%02d", 
                datetime.year, 
                datetime.month, 
                datetime.day, 
                datetime.hour, 
                datetime.min, 
                datetime.sec)
end

function get_upvalues(func)
    local upvalues = {}
    local i = 1
    while true do 
        local k, v = debug.getupvalue(func, i)
        if not k or not v then 
            break 
        end 
        upvalues[k] = v
        i = i + 1
    end

    return upvalues
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

function os.write_file(path, content, mode)
    mode = mode or "w+b"
    local file = io.open(path, mode)
    if file then
        if file:write(content) == nil then return false end
        io.close(file)
        return true
    else
        return false
    end
end

--endregion
