--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local Server = {}

local Robot = require("app.managers.Robot"):create()

function Server:init()
    self.curSeatNO = 0
end

--[Comment]
--模拟服务器接收消息
--msg: {msgName = ?, data = ?}
function Server:recvMsg(msg)
    if not self[msg.msgName] then 
        printError("No message process function of %s", msg.msgName)
        return
    end 
    self[msg.msgName](self, msg.data)
end 

function Server:newSeat()
    self.curSeatNO = self.curSeatNO + 1
    if self.curSeatNO > 4 then 
        self.curSeatNO = self.curSeatNO - 4
    end 
    return self.curSeatNO
end 

function Server:mc_create_room(data)
end 

function Server.xxx(data)

end 

return Server
--endregion
