--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local msgdefines = require("res.msgdefines")

local Network = class("Network")

local instance = nil 

cc.exports.connectCallback = function(fd, code)
    xpcall_ext(function()
        local server = instance.serversByFd[fd]
        if not server then 
            printError("server %d not exists", fd)
            return
        end 
        local serverName = server.name
        if instance.DUMP then 
            printInfo("***********[CONNECT RESULT]***********")
            printInfo("[%s] %s", serverName, code ~= 0 and "success" or "failed")
            printInfo("****************************")
        end 
        Event.dispatch(serverName.."ms_connect", {success = code ~= 0})
        if not code then 
            instance.serversByFd[fd] = nil
            instance.serversByName[serverName] = nil
        end 
    end)
end 

cc.exports.recvDataCallback = function(fd, mainCmd, subCmd, pData, sz)
    xpcall_ext(function()
        --printInfo("recvDataCallback")
        local server = instance.serversByFd[fd]
        if not server then 
            printError("server %d not exists", fd)
            return
        end 
        local serverName = server.name
        if not msgdefines[serverName][mainCmd] or not msgdefines[serverName][mainCmd][subCmd] then 
            printError("no msg defined of mainCmd: %d, subCmd: %d", mainCmd, subCmd)
            return
        end 
        local msgDefine = msgdefines[serverName][mainCmd][subCmd]
        if not msgDefine.proto then 
            printError("no proto defined of %s", msgDefine.name)
            return
        end 
        if msgDefine.proto == "" then 
            if instance.DUMP then 
                printInfo("***********[SEND]***********")
                printInfo("[%s\t%s] binary data", serverName, msgDefine.name)
                printInfo("****************************")
            end 
            Event.dispatch(serverName..msgDefine.name, pData, sz)
        else 
            local data = protobuf.decode(msgDefine.proto, pData, sz)
            if instance.DUMP then 
                printInfo("***********[SEND]***********")
                --printInfo("[%s\t%s] %s", serverName, msgDefine.name, table.tostring(data, true))
                printInfo("[%s\t%s]", serverName, msgDefine.name)
                printInfo("****************************")
            end 
            Event.dispatch(serverName..msgDefine.name, data)
        end 
    end)
end 

cc.exports.disconnCallback = function(fd)
    xpcall_ext(function()
        local server = instance.serversByFd[fd]
        if not server then 
            printError("server %d not exists", fd)
            return
        end 
        local serverName = server.name
        if instance.DUMP then 
            printInfo("***********[DISCONNECT]***********")
            printInfo("[%s]", serverName)
            printInfo("****************************")
        end 
        instance.serversByFd[fd] = nil
        instance.serversByName[serverName] = nil
        Event.dispatch(serverName.."ms_disconnect")
    end)
end 

cc.exports.socketDestroyCallback = function(fd)
--    xpcall_ext(function()
--        local server = instance.serversByFd[fd]
--        if not server then 
--            return
--        end 
--        local serverName = server.name
--        Event.dispatch(serverName.."ms_disconnect")
--        instance.serversByFd[fd] = nil
--        instance.serversByName[serverName] = nil
--    end)
end 

cc.exports.logCallback = function(logType, msg)
    printInfo(msg)
end 

--socket initialize
local socketlib = CSocketManager:GetInstance()
socketlib:setCallBack("connectCallback","recvDataCallback","disconnCallback","socketDestroyCallback","logCallback")

function Network:ctor()
    instance = self

    self.serversByFd = {} --{[fd] = {fd = ?, name = ?}, ...}
    self.serversByName = {} --{[fd] = {fd = ?, name = ?}, ...}
    self.DUMP = false --dump all network messages

    local scheduler = cc.Director:getInstance():getScheduler()
    scheduler:scheduleScriptFunc(function()
         socketlib:SocketUpdate()
    end, 0, false)

    local dataProtoHall = CCString:createWithContentsOfFile(cc.FileUtils:getInstance():fullPathForFilename("res/pb/Hallmsg.pb")):getCString();
    protobuf.register(dataProtoHall)
    local dataProtoRoom = CCString:createWithContentsOfFile(cc.FileUtils:getInstance():fullPathForFilename("res/pb/Gamemsg.pb")):getCString();
    protobuf.register(dataProtoRoom)
end 

function Network:setDump(dump)
    self.DUMP = dump
end 

function Network:registerMsgProc(serverName, msgName, caller, callerFuncOrName)
    Event.register(serverName..msgName, caller, callerFuncOrName)
end 

function Network:unregisterMsgProc(serverName, msgName, caller, callerFuncOrName)
    Event.unregister(serverName..msgName, caller, callerFuncOrName)
end

function Network:connect(serverName, ipOrDomain, port)
    assert(self.serversByName[serverName] == nil)
    local fd = socketlib:Connect(ipOrDomain, ipOrDomain:len(), port)
    self.serversByFd[fd] = {fd = fd, name = serverName}
    self.serversByName[serverName] = {fd = fd, name = serverName}
    if self.DUMP then 
        printInfo("***********[CONNECT]***********")
        printInfo("[%s]: IP: %s, Port: %s", serverName, ipOrDomain, tostring(port))
        printInfo("****************************")
    end 
end 

function Network:disconnect(serverName)
    local server = self.serversByName[serverName]
    if not server then 
        return 
    end 
--    self.serversByName[serverName] = nil
--    self.serversByFd[server.fd] = nil
    socketlib:Disconnect(server.fd)
end

--[Comment]
--发送数据
function Network:send(serverName, msgName, data)
    --printInfo("111111111")
    local msgDefine = msgdefines[serverName][msgName]
    if not msgDefine then 
        printError("no msg %s defined", msgName)
        return
    end 
    if not msgDefine.proto then 
        printError("no proto defined of %s", msgDefine.name)
        return
    end 
    --printInfo("22222222222222")
    local buf = msgDefine.proto ~= "" and protobuf.encode(msgDefine.proto, data) or nil
    --printInfo("3333333333333")
    local server = self.serversByName[serverName]
    assert(server, "no server %s connected", serverName)
    if self.DUMP then 
        printInfo("***********[SEND]***********")
        --printInfo("[%s\t%s]: %s", serverName, msgName, table.tostring(data or {}, true))
        printInfo("[%s\t%s]", serverName, msgName)
        printInfo("****************************")
    end 
    socketlib:SendData(server.fd, msgDefine.mainCmd, msgDefine.subCmd, buf, buf and buf:len() or 0)
end 

function Network:sendAdvanced(serverName, msgName, data, len)
    local msgDefine = msgdefines[serverName][msgName]
    if not msgDefine then 
        printError("no msg %s defined", msgName)
        return
    end 
    if not msgDefine.proto then 
        printError("no proto defined of %s", msgDefine.name)
        return
    end 
    local server = self.serversByName[serverName]
    assert(server, "no server %s connected", serverName)
    if self.DUMP then 
        printInfo("***********[SEND]***********")
        printInfo("[%s\t%s]: binary data...", serverName, msgName)
        printInfo("****************************")
    end 
    socketlib:SendData(server.fd, msgDefine.mainCmd, msgDefine.subCmd, data, len)
end 

--[Comment]
--指定的服务器是否连接
function Network:isServerConnected(serverName)
    return self.serversByName[serverName] ~= nil
end 

return Network
--endregion
