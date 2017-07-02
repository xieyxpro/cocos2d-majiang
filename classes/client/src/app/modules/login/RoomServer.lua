--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local RoomServer = class("RoomServer");

function RoomServer:ctor(params)
    self:updateInfos(params)
end;

function RoomServer:updateInfos(params)
    self.kindID = params.kindid
    self.serverID = params.serverid
    self.ip = params.ip
    self.port = params.port
    self.onlineUserNum = params.onlineusernum    
end

return RoomServer

--endregion
