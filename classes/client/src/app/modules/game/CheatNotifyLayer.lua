--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local CheatNotifyLayer = class("CheatNotifyLayer", cc.Layer)

local GameDefine = require("app.modules.game.GameDefine")

function CheatNotifyLayer:ctor()
    local uiNode = require("GameScene.CheatNotifyLayer"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)

    local otherPlayers = {}
    for _,player in pairs(GameCache.players) do
        if player.userid ~= PlayerCache.userid then
            table.insert(otherPlayers, player)
        end
    end
    
    if #otherPlayers < 2 then
        return false
    end
    local cheat = {
        cheatType = 0,
        cheatPlayers = {}, --{{distance = 0, ip = ?}, ...}
    }
    local distanceInfos = {}
    --check distance
    for i = 1, #otherPlayers do
        if otherPlayers[i].jingdu ~= Define.INVALID_JINGDU then
            for j = i+1, #otherPlayers do
                local cheatInfo = {}
                if otherPlayers[j].jingdu ~= Define.INVALID_JINGDU then
                    local distance = 0
                    if device.platform ~= "windows" then
                        distance = AmapSDK:calculateLineDistance(
                            otherPlayers[i].jingdu,otherPlayers[i].weidu,
                            otherPlayers[j].jingdu,otherPlayers[j].weidu
                        )
                    end 
                    if distance < Define.WARING_DISTANCE then
                        cheat.cheatPlayers[otherPlayers[i].userid] = otherPlayers[i]
                        cheat.cheatPlayers[otherPlayers[j].userid] = otherPlayers[j]
                    end
                    distanceInfos[otherPlayers[i].userid] = distanceInfos[otherPlayers[i].userid] or {}
                    distanceInfos[otherPlayers[i].userid][otherPlayers[j].userid]= {distance = distance}
                    distanceInfos[otherPlayers[j].userid] = distanceInfos[otherPlayers[j].userid] or {}
                    distanceInfos[otherPlayers[j].userid][otherPlayers[i].userid]= {distance = distance}
                end
            end
        end 
    end
    --check ip
    local ipPlayers = {}
    for _, gamePlayer in ipairs(otherPlayers) do 
        local i, j = string.find(gamePlayer.playerIP, "%d+%.%d+%.%d+%.")
        local ipHead = string.sub(gamePlayer.playerIP, i, j)
        if ipHead then 
            ipPlayers[ipHead] = ipPlayers[ipHead] or {}
            table.insert(ipPlayers[ipHead], gamePlayer)
        end 
    end 
    for ipHead, players in pairs(ipPlayers) do 
        if #players > 1 then 
            for _, player in ipairs(players) do
                cheat.cheatPlayers[player.userid] = player
            end 
        end 
    end 
    local cheatPlayersAry = {}
    for _, player in pairs(cheat.cheatPlayers) do 
        table.insert(cheatPlayersAry, player)
    end 
    assert(#cheatPlayersAry >= 2)
    local function setDistance(txtNode, player1, player2)
        if not distanceInfos[player1.userid] then 
            txtNode:setString("距离未知")
        else
            if distanceInfos[player1.userid][player2.userid] then 
                txtNode:setString(string.format("距离%s米", 
                    tostring(distanceInfos[player1.userid][player2.userid].distance))
                )
            else 
                txtNode:setString("距离未知")
            end 
        end 
    end 
    local pan
    if #cheatPlayersAry == 2 then 
        self.imgBg.panP2:setVisible(true)
        self.imgBg.panP3:setVisible(false)
        pan = self.imgBg.panP2
        setDistance(pan.txtDesc1, cheatPlayersAry[1], cheatPlayersAry[2])
    elseif #cheatPlayersAry == 3 then 
        self.imgBg.panP2:setVisible(false)
        self.imgBg.panP3:setVisible(true)
        pan = self.imgBg.panP3
        setDistance(pan.txtDesc1, cheatPlayersAry[1], cheatPlayersAry[2])
        setDistance(pan.txtDesc2, cheatPlayersAry[2], cheatPlayersAry[3])
        setDistance(pan.txtDesc3, cheatPlayersAry[3], cheatPlayersAry[1])
    else
        assert(false)
    end 
    for i, player in ipairs(cheatPlayersAry) do 
        pan["imgP"..tostring(i)].txtName:setString(cheatPlayersAry[i].nickname)
        pan["imgP"..tostring(i)].txtIP:setString(cheatPlayersAry[i].playerIP)
    end 
    local myself = GameCache.players[PlayerCache.userid]
    if myself.userid == GameCache.roomCreaterUserID then 
        self.imgBg.btnCloseRoom:setVisible(true)
        self.imgBg.btnLeaveRoom:setVisible(false)
    else 
        self.imgBg.btnCloseRoom:setVisible(false)
        self.imgBg.btnLeaveRoom:setVisible(true)
    end 
    
    Event.register("MS_DISMISS", self, "MS_DISMISS")
    Event.register("MS_STAND_UP", self, "MS_STAND_UP")
    Event.register("MS_PLAYER_READY", self, "MS_PLAYER_READY")
end 

function CheatNotifyLayer:onClose()
    Event.unregister("MS_DISMISS", self, "MS_DISMISS")
    Event.unregister("MS_STAND_UP", self, "MS_STAND_UP")
    Event.unregister("MS_PLAYER_READY", self, "MS_PLAYER_READY")
end 

function CheatNotifyLayer:MS_DISMISS(data)
    UIManager:unblock()
    UIManager:close(self)
end 

function CheatNotifyLayer:MS_STAND_UP(data)
    if data.userid ~= PlayerCache.userid then 
        return
    end 
    UIManager:unblock()
    UIManager:close(self)
end 

function CheatNotifyLayer:MS_PLAYER_READY(data)
    if data.userid ~= PlayerCache.userid then 
        return
    end 
    UIManager:unblock()
    UIManager:close(self)
end 

function CheatNotifyLayer:onClick_btnCloseRoom(sender)
    Helper.playSoundClick()
    Network:send(Define.SERVER_GAME, "mc_dismiss", {agree = true})
    UIManager:block()
end 

function CheatNotifyLayer:onClick_btnLeaveRoom(sender)
    Helper.playSoundClick()
    Network:send(Define.SERVER_GAME, "mc_stand_up", nil)
    UIManager:block()
end 

function CheatNotifyLayer:onClick_btnContinue(sender)
    Network:send(Define.SERVER_GAME, "mc_player_ready", {})
    UIManager:block()
    Helper.playSoundClick()
end 

return CheatNotifyLayer
--endregion
