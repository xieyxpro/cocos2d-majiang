--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--网络连接管理

ConnectItemInfo = {
    pServerUserItem = nil,
    dwClientIP = 0,
    wRoundID,
    bConnect,
    bLogin,
}
ConnectItemInfo = Util:newClass(ConnectItemInfo)

function ConnectItemInfo:AcceptEvent(wRoundID,clientIP)
    self.bLogin = false
    self.bConnect = true
    self.wRoundID = wRoundID
    self.dwClientIP = clientIP
end

function ConnectItemInfo:CloseEvent()
    self.wRoundID = self.wRoundID + 1
    self.dwClientIP = 0
    self.bConnect = false
    self.bLogin = false
    self.pServerUserItem = nil
end

function ConnectItemInfo:LogonBegin()
    self.bLogin = true
end

function ConnectItemInfo:LogonFinish(pServerUserItem)--pServerUserItem == nil --登录失败
    self.bLogin = false
    self.pServerUserItem = pServerUserItem
end


----------------------------------------------------------------------------------------------------------
ConnectInfos = {
    mapConnectInfos = {}
}

function ConnectInfos:getConnectInfo(wIndex)
    if nil == self.mapConnectInfos[wIndex] then
        self.mapConnectInfos[wIndex] = ConnectItemInfo:new()
    end
    return self.mapConnectInfos[wIndex]
end

--endregion
