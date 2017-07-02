--region util_String.lua
--Date 2015.10.17

--计算utf编码字符串的长度
local _utf_arr = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
local _utf_arr_len = #_utf_arr
function Util:utfstrlen(str)
    local len = #str
    local left = len
    local cnt = 0
    while left > 0 do
        local tmp = string.byte(str, -left)
        local i = _utf_arr_len
        while _utf_arr[i] do
            if tmp >=_utf_arr[i] then
                left = left-i
                break
            end
            i=i-1
        end
        cnt=cnt+1
    end
    return cnt
end

function Util:utf_str_cut(str, len)
    local length = #str
    local left = 1
    local cnt = 0
    local ret = ''
    while left <= length do
        local tmp = string.byte(str, left)
        local pre = left
        local i = _utf_arr_len
        while _utf_arr[i] do
            if tmp >=_utf_arr[i] then
                left = left + i
                break
            end
            i=i-1
        end
        cnt=cnt+1
        ret = ret .. string.sub(str, pre, left - 1)
        if cnt == len then
            break
        end
    end
    return ret
end

--检查utf字符串是否含有char(< 0xc0)字符
function Util:utfstr_check_char(str, char)
    --local byte_char = string.byte(char)
    if char < 0 or char >= 0xc0 then
        lua_util.log_game_warning("utfstr_check_char", "")
        return
    end 
    local len = #str
    local left = len
    while left > 0 do
        local tmp = string.byte(str, -left)
        if tmp == char then
            return true
        end
        local i = _utf_arr_len
        while _utf_arr[i] do
            if tmp >=_utf_arr[i] then
                left = left-i
                break
            end
            i=i-1
        end
    end
    return false
end




--endregion
