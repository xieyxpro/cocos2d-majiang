local UserDefauleExt = class("UserDefauleExt")

local userDefault = cc.UserDefault:getInstance()

function UserDefauleExt:ctor()

end 

function UserDefauleExt:set(key, value)
    local typeV = type(value)
    if typeV == "string" then 
        userDefault:setStringForKey(key, value)
    elseif typeV == "boolean" then 
        userDefault:setBoolForKey(key, value)
    elseif typeV == "number" then 
        userDefault:setDoubleForKey(key, value)
    else 
        printError("unsupported data to save: %s", typeV)
        assert(false)
    end 
end

--[Comment]
--default value must be specified
function UserDefauleExt:get(key, default)
    local typeV = type(default)
    if typeV == "string" then 
        local v = userDefault:getStringForKey(key, default)
        return v
    elseif typeV == "boolean" then 
        local v = userDefault:getBoolForKey(key, default)
        return v
    elseif typeV == "number" then 
        local v = userDefault:getDoubleForKey(key, default)
        return v
    else 
        printError("unsupported data to save: %s", typeV)
        assert(false)
    end 
end 

return UserDefauleExt