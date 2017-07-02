--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local PlaybackReadyLayer = class("PlaybackReadyLayer", cc.Layer)

local GameDefine = require("app.modules.game.GameDefine")
local GamePlayerInfoNode = require("app.modules.achiv.PlaybackPlayerInfoNode")
local GamePlayer = require("app.modules.game.GamePlayer")

function PlaybackReadyLayer:ctor()
    local uiNode = require("HomeScene.achiv.PlaybackReadyLayer"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)

    self.room = nil
    self.playersNodes = {} --[userid] = {player = ?, node = ?},...
    
    self:enableNodeEvents()
    
    Event.register(EventDefine.ICON_DOWNLOADED, self, "ICON_DOWNLOADED")
    Event.register("PLAYBACK_UPD_FANS", self, "PLAYBACK_UPD_FANS")
end 

function PlaybackReadyLayer:onEnter()
end 

function PlaybackReadyLayer:onExit()
    Event.unregister(EventDefine.ICON_DOWNLOADED, self, "ICON_DOWNLOADED")
    Event.unregister("PLAYBACK_UPD_FANS", self, "PLAYBACK_UPD_FANS")
end

function PlaybackReadyLayer:addPlayer(player)
    assert(self.playersNodes[player.userid] == nil)
    local infoNode = GamePlayerInfoNode:create(player)
    local playerNode = {player = player, node = infoNode, readyPos = nil, playPos = nil, panel = nil}

    if player.seatDir == GameDefine.DIR_LEFT then 
        playerNode.panel = self.panelLeft
    elseif player.seatDir == GameDefine.DIR_BOTTOM then
        playerNode.panel = self.panelBottom
    elseif player.seatDir == GameDefine.DIR_RIGHT then 
        playerNode.panel = self.panelRight
    elseif player.seatDir == GameDefine.DIR_TOP then 
        playerNode.panel = self.panelTop
    else
        error("invalid direction")
    end 
    infoNode:addTo(playerNode.panel)
    playerNode.playPos = cc.p(playerNode.panel.nodePlayerInfoPlay:getPosition())
    infoNode:setPosition(playerNode.playPos)
    self.playersNodes[player.userid] = playerNode
end 

function PlaybackReadyLayer:initialize(room)
    self.room = room

    local rollData = self.room:getCurRollData()
    --clear
    for _, playerNode in pairs(self.playersNodes) do 
        if playerNode.node then 
            playerNode.node:removeFromParentAndCleanup(true)
        end 
    end 
    self.playersNodes = {}
    --valuation
    for _, playerInfo in pairs(self.room.playersInfo) do 
        local rollPlayer = rollData.players[playerInfo.chairID]
        local gamePlayer = GamePlayer:create({
            userid = playerInfo.userid,
            nickname = playerInfo.nickname,
            playerScore = playerInfo.playerScore or 0,
            chairID = playerInfo.chairID,
            status = GameDefine.enum_GameStatus.GS_PLAYING,
            gender = playerInfo.gender,
            playerIcon = playerInfo.playerIcon,
            isZhuang = rollPlayer.isZhuang,
            location = {},
        })
        gamePlayer.seatDir = rollPlayer.seatDir
        self:addPlayer(gamePlayer)
    end 
    self.imgTitleBg.lblRoomID:setString(tostring(self.room.roomID))
end 

function PlaybackReadyLayer:ICON_DOWNLOADED(data)
    local playerNode = self.playersNodes[data.userid]
    if not playerNode then 
        --it's not my business
        return 
    end 
    if data.err then 
        UIManager:showTip(string.format("获取玩家%s头像错误：%s", playerNode.player.nickname, data.err.msg))
        return
    end 
    if not data.iconFileName or data.iconFileName == "" then 
        printInfo("empty icon downloaded")
        return 
    end 
    playerNode.player.playerIcon = data.iconFileName
    playerNode.node:setIcon(playerNode.player.playerIcon)
end 

function PlaybackReadyLayer:PLAYBACK_UPD_FANS(data)
    local playerNode = self.playersNodes[data.userid]
    if not playerNode then 
        --it's not my business
        return 
    end 
    playerNode.node:setFans(data.fans)
end

return PlaybackReadyLayer
--endregion
