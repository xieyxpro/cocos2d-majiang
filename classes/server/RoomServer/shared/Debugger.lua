--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local TimeMarker = Util:class("TimeMarker")

function TimeMarker:__init(params)
    params = params or {}
    self.mark = params.mark or ""
    self.timeStamp = params.timeStamp or 0
end 

function TimeMarker.sub(marker1, marker2)
    return TimeMarker(string.format("%s - %s", marker1.mark, marker2.mark), marker1.timeStamp - marker2.timeStamp)
end 

function TimeMarker.add(marker1, marker2)
    return TimeMarker(string.format("%s + %s", marker1.mark, marker2.mark), marker1.timeStamp + marker2.timeStamp)
end 

function TimeMarker:tostring()
    return string.format("%s: %s", self.mark, tostring(self.timeStamp))
end 

local SnapShot = Util:class("SnapShot")

function SnapShot:__init(mem, cpuTime, pic)
    self.mem = mem or 0
    self.cpuTime = cpuTime or 0
    self.memPic = pic or {}
end

function SnapShot:tostring()
    return string.format("Memory(KB): %s\nCPU Time(ms): %s\nDump Data: \n%s", 
                            tostring(math.floor(self.mem)), 
                            tostring(math.floor(self.cpuTime * 100000) / 100),
                            table.tostring(self.memPic, true))
end 

Debugger = Util:class("Debugger")

function Debugger:__init()
    self.timeSaver = List()
    self.runTimes = 0
    self.runTimesInfoFileName = "Debugger/runs.cnf"
    local file = io.open(self.runTimesInfoFileName, "r")
    if file then 
        local n = file:read("*n") or 0
        self.runTimes = n + 1
    end 
    file:close()
    file = io.open(self.runTimesInfoFileName, "w+")
    file:write(self.runTimes)
    file:close()
end 

function Debugger:__snap_shot(tbl) 
    local addrs = {}
    local refs = {}
    local function ___snap_shot(tbl)
        addrs[tbl] = tbl
        local pic = {}
        for k, v in pairs(tbl) do 
            if k and v then 
                if type(v) == "string" then 
                    pic[string.format("string: %s",tostring(k))] = v
                elseif type(v) == "table" then 
                    if not refs[v] then 
                        refs[v] = {ref = 0, name = tostring(k), type = type(v)}
                    end 
                    refs[v].ref = refs[v].ref + 1
                    if not addrs[v] then
                        pic[string.format("table: %s addr: %s",tostring(k), tostring(v))] = ___snap_shot(v)
                    end 
                elseif type(v) == "function" then 
                    if not refs[v] then 
                        refs[v] = {ref = 0, name = tostring(k), type = type(v)}
                    end 
                    refs[v].ref = refs[v].ref + 1
                    pic[string.format("function: %s addr: %s",tostring(k), tostring(v))] = get_upvalues(v)
                elseif type(v) == "userdata" then 
                    if not refs[v] then 
                        refs[v] = {ref = 0, name = tostring(k), type = type(v)}
                    end 
                    refs[v].ref = refs[v].ref + 1
                    pic[string.format("userdata: %s",tostring(k))] = tostring(v)
                elseif type(v) == "number" then
                    pic[string.format("number: %s",tostring(k))] = v
                end 
            end 
        end 
        return pic
    end 
    return ___snap_shot(tbl), refs
end 

function Debugger:TakePhoto(fileName)
    local mem = collectgarbage("count")
    local clock = os.clock()
    local pic, refs = self:__snap_shot(_G)
    local snapShot = SnapShot(mem, clock, pic)
    if fileName then 
        local ssFileName = string.format("Debugger/logs/%s_%d_snapshot_%s.dbg", fileName, self.runTimes, tostring(clock))
        local file, msg = io.open(ssFileName,"w+")
        if not file then 
            logErrf("Write file %s error", ssFileName)
            return
        else
            file:write(snapShot:tostring())
            file:close()
        end 
        local sfFileName = string.format("Debugger/logs/%s_%d_refs_%s.dbg", fileName, self.runTimes, tostring(clock))
        local file, msg = io.open(sfFileName,"w+")
        if not file then 
            logErrf("Write file %s error", sfFileName)
            return
        else
            local buf = {}
            for addr, ref_item in pairs(refs) do 
                buf[addr] = string.format("ref = %s, type = %s, name = %s", 
                                tostring(ref_item.ref), 
                                tostring(ref_item.type), 
                                tostring(ref_item.name))
            end 
            file:write(table.tostring(buf, true))
            file:close()
        end 
        logNormal("Program picture token")
    else
        logNormal(snapShot:tostring())
    end 
end

function Debugger:PushMark(mark, timeStamp)
    self.timeSaver:pushBack(TimeMarker(mark, timeStamp))
end

function Debugger:Flush()
    local custPairs = self.timeSaver:getIpairs()
    local prevMarker = nil
    for _, marker in custPairs do 
        if not prevMarker then 
            prevMarker = marker 
        else 
            print(TimeMarker.sub(marker, prevMarker):tostring())
        end 
    end 
end 

return Debugger
--endregion
