local NewDefault = class("NewDefault")

local FILENAME = "NewDefault.data"

local instance
local instanceExt

local scheduler = cc.Director:getInstance():getScheduler()

function NewDefault:ctor(isSelf)
    self.isSelf = isSelf
    self.path = cc.FileUtils:getInstance():getWritablePath() .. FILENAME
    self.dirty = false
    self.noFlush = false
    self.realtimeFlush = false
    local file = io.open(self.path, "rb")
    if file then
        local bin = file:read("*a")
        io.close(file)
        self.set = RWProtocol.unserialize(bin)
        if type(self.set) ~= "table" then
            self.set = {}
        end
    else
        self.set = {}
    end

    self.isReading = true
    if isSelf then
        self.isReading = false
    end
    if isSelf and GlobalCache and  GlobalCache.PlayerCache and  GlobalCache.PlayerCache.role_id~=0 then
        self:refreshRoleId(GlobalCache.PlayerCache.role_id)
    end
end

function NewDefault:refreshRoleId(role_id,client_info_bin)
    self.path = CCFileUtils:getInstance():getWritablePath() ..string.format("NewDefault_%d.data",role_id)
    self.dirty = false
    self.noFlush = false
    self.realtimeFlush = false
    local file = io.open(self.path, "rb")
    if file then
        local bin = file:read("*a")
        io.close(file)
        self.set = RWProtocol.unserialize(bin)
        if type(self.set) ~= "table" then
            self.set = {}
        end
    else
        self.set = {}
    end
    self.isReading = true

    if client_info_bin then
        local client_info = RWProtocol.unserialize(client_info_bin)
        if self:getVersion() < client_info["client_version"] then
            self:replaceSet(client_info)
        end
    end
end

--读取版本号
function NewDefault:getVersion()
    return self:getIntegerForKey("client_version",0)
end

--版本号递增
function NewDefault:addVersion()
    local preVersion = self:getVersion()
    preVersion = preVersion + 1
    self:setIntegerForKey("client_version",preVersion)
end

function NewDefault:dump()
    dump(self.set, "set")
end

function NewDefault:cloneSet()
    return clone(self.set)
end

function NewDefault:replaceSet(set)
    self.set = set
    self.dirty = true
    self:flush()
end

function NewDefault:disableFlush()
    self.noFlush = true
end

function NewDefault:enableRealtimeFlush()
    self.realtimeFlush = true
end

function NewDefault:flush()
    if self.noFlush or not self.isReading then
        return
    end
    if self.dirty then
        --版本号递增
        self:addVersion()
        self.dirty = false
        local bin = RWProtocol.serialize(self.set)
        local file, err = io.open(self.path, "wb+")
        if not file then
            printError("NewDefault: %s", err)
            return
        end
        file:write(bin)
        file:close()
        if self.isSelf then
            --通知服务端
            NetManager:push({"mc_record_client_info", {client_info=bin}})
        end
    end
end

function NewDefault:setValue_(key, value)
    --print(key,value)
    self.set[key] = value
    if self.realtimeFlush then
        self:flush()
    else
        if not self.dirty then
            self.dirty = true
            scheduler.performWithDelayGlobal(function(dt)
                self:flush()
            end, 0.1)
        end
    end
    --self:dump()
end

function NewDefault:getValue(key)
    return self.set[key]
end

function NewDefault:getStringForKey(key, value)
    local ret = self:getValueForKey(key, value or "")
    return tostring(ret)
end

function NewDefault:setStringForKey(key, value)
    self:setValue_(key, tostring(value))
end

function NewDefault:getIntegerForKey(key, value)
    local ret = self:getValueForKey(key, value or 0)
    return tonumber(ret)
end

function NewDefault:setIntegerForKey(key, value)
    self:setValue_(key, tonumber(value))
end

function NewDefault:getBoolForKey(key, value)
    local ret = self:getValueForKey(key, value or false)
    return ret and true or false
end

function NewDefault:setBoolForKey(key, value)
    self:setValue_(key, value and true or false)
end

function NewDefault:getValueForKey(key, value)
    local ret = self:getValue(key)
    if type(ret) ~= "nil" then
        return ret
    else
        return value
    end
end

function NewDefault:setValueForKey(key, value)
    return self:setValue_(key, value)
end

function NewDefault:isExistForKey(key)
    return self:getValue(key) ~= nil
end

function NewDefault:getInstance()
    if not instance then
        instance = NewDefault.new()
    end
    return instance
end

function NewDefault:getInstanceExt()
    if not instanceExt  then
        instanceExt = NewDefault.new(true)
    end
    return instanceExt
end

return NewDefault
