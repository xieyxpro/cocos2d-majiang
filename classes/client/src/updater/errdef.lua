--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
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


return {
    SUCCESS = 0, 
        [0] = "",
    E_IO_READ = 1,
        [1] = "文件读取错误",
    E_IO_WRITE = 2,
        [2] = "文件写入错误",
    E_NET_UNREACHABLE = 3,
        [3] = "无法连接网络",
    E_NET_TIMEOUT = 4,
        [4] = "下载超时，请检查网络",
    E_NET_UNKNOWN = 5,
        [5] = "未知网络错误，请检查网络",
    E_IO_CREATE_DIRECTORY = 6,
        [6] = "创建目录错误",
    E_NEED_BIG_VERSION_UPDATE = 7,
        [7] = "请下载最新版本安装包",
    E_NO_NEED_UPDATE = 8,
        [8] = "无更新",
}


--endregion
