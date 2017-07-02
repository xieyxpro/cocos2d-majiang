--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local GamePlayerInfoNode = class("GamePlayerInfoNode", cc.Node)

local GameDefine = require("app.modules.game.GameDefine")

function GamePlayerInfoNode:ctor(gamePlayer)
    local uiNode = require("GameScene.GamePlayerInfoNode"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)

    self.imgHead:setTouchEnabled(true)
    self.imgHead:addTouchEventListener(function(sender, event)
--        if event == ccui.TouchEventType.began then 
--            sender:setScale(0.9)
--        elseif event == ccui.TouchEventType.ended or 
--            event == ccui.TouchEventType.canceled then 
--            sender:setScale(1.0)
--        end 
        if event == ccui.TouchEventType.ended then 
            self:onClick_imgHead(sender)
        end 
    end)

    self.spReady.rawPos = cc.p(self.spReady:getPosition())

    self.gamePlayer = gamePlayer
    self:refresh()
    
    self:enableNodeEvents()

    self.procFuncReged = false
    self:onCreate()
end 

function GamePlayerInfoNode:onCreate()
    if self.procFuncReged then 
        return
    end 
    Event.register("MS_GAME_START", self, "MS_GAME_START")
    Event.register("MS_PLAYER_READY", self, "MS_PLAYER_READY")
    Event.register("MS_USER_OFFLINE", self, "MS_USER_OFFLINE")
    Event.register("MS_USER_RECONNECT", self, "MS_USER_RECONNECT")
    Event.register("MS_USERSTATUS_CHANGE", self, "MS_USERSTATUS_CHANGE")
    Event.register("UPDATE_FANS", self, "UPDATE_FANS")
    Event.register(EventDefine.ICON_DOWNLOADED, self, "ICON_DOWNLOADED")
    self.procFuncReged = true
end 

function GamePlayerInfoNode:onDestroy()
    if not self.procFuncReged then 
        return
    end 
    Event.unregister("MS_GAME_START", self, "MS_GAME_START")
    Event.unregister("MS_PLAYER_READY", self, "MS_PLAYER_READY")
    Event.unregister("MS_USER_OFFLINE", self, "MS_USER_OFFLINE")
    Event.unregister("MS_USER_RECONNECT", self, "MS_USER_RECONNECT")
    Event.unregister("MS_USERSTATUS_CHANGE", self, "MS_USERSTATUS_CHANGE")
    Event.unregister("UPDATE_FANS", self, "UPDATE_FANS")
    Event.unregister(EventDefine.ICON_DOWNLOADED, self, "ICON_DOWNLOADED")
    self.procFuncReged = false
end 

function GamePlayerInfoNode:onEnter()
    self:onCreate()
end

function GamePlayerInfoNode:onExit()
    self:onDestroy()
end

function GamePlayerInfoNode:refresh(gamePlayer)
    self.gamePlayer = gamePlayer or self.gamePlayer
    self.imgHead:loadTexture(self.gamePlayer.playerIcon,0)
    self.imgHead.spZhuang:setVisible(self.gamePlayer.isZhuang and GameCache.roomStatus == GameDefine.enum_GameStatus.GS_PLAYING)
    self.imgHead.spOffline:setVisible(self.gamePlayer.isOffline)
    self.spReady:setVisible(self.gamePlayer.status == GameDefine.enum_UserStatus.US_READY or self.gamePlayer.status == GameDefine.enum_UserStatus.US_OFFLINE)
    self.imgHead.lblScore:setText(self.gamePlayer.score)
    
    if self.imgHead.lblName:getString() ~= self.gamePlayer.nickname then 
        self.imgHead.lblName:setString(self.gamePlayer.nickname)
    end 
    local szHead = self.imgHead:getContentSize()
    local spReadySz = self.spReady:getContentSize()
    local spReadyAnpt = self.spReady:getAnchorPoint()
    if self.gamePlayer.seatDir == GameDefine.DIR_LEFT then 
        self.spReady:setPosition(cc.p(self.spReady.rawPos.x + 100, self.spReady.rawPos.y))
        self.imgHead.spOffline:setPosition(cc.p(0, self.imgHead.spOffline:getPositionY()))
        self.imgHead.imgFans:setPosition(cc.p(szHead.width + 8, self.imgHead.imgFans:getPositionY()))
    elseif self.gamePlayer.seatDir == GameDefine.DIR_BOTTOM then
        self.spReady:setPosition(cc.p(self.spReady.rawPos.x, self.spReady.rawPos.y + 100))
    elseif self.gamePlayer.seatDir == GameDefine.DIR_RIGHT then 
        self.spReady:setPosition(cc.p(self.spReady.rawPos.x - 100, self.spReady.rawPos.y))
        self.imgHead.spOffline:setPosition(cc.p(szHead.width, self.imgHead.spOffline:getPositionY()))
        self.imgHead.imgFans:setPosition(cc.p(-8, self.imgHead.imgFans:getPositionY()))
    elseif self.gamePlayer.seatDir == GameDefine.DIR_TOP then 
        self.spReady:setPosition(cc.p(self.spReady.rawPos.x, self.spReady.rawPos.y - 130))
    else
        error("invalid direction")
    end 
    if GameCache.roomStatus == GameDefine.enum_GameStatus.GS_FREE and 
        self.gamePlayer.status ~= GameDefine.enum_UserStatus.US_READY and 
        self.gamePlayer.userid == PlayerCache.userid then 
        self.btnReady:setVisible(true)
    else
        self.btnReady:setVisible(false)
    end 
    self:updateFans()
end 

function GamePlayerInfoNode:updateFans()
    if GameCache.roomStatus == GameDefine.enum_GameStatus.GS_FREE then 
        self.imgHead.imgFans:setVisible(false)
    else
        self.imgHead.imgFans:setVisible(true)
        local fans = self.gamePlayer:getPlayerFansCnt()
        self.imgHead.imgFans.txtFans.oldFans = self.imgHead.imgFans.txtFans.oldFans
        if fans ~= self.imgHead.imgFans.txtFans.oldFans then 
            self.imgHead.imgFans.txtFans:setText(string.format("%d番", fans))
            self.imgHead.imgFans.txtFans.oldFans = fans
        end 
    end 
end 

function GamePlayerInfoNode:UPDATE_FANS(data)
    if data.userid ~= self.gamePlayer.userid then 
        return 
    end 
    self:updateFans()
end

function GamePlayerInfoNode:MS_GAME_START(data)
    self.imgHead.lblScore:setText(self.gamePlayer.score)
    self.spReady:setVisible(false)
    self.btnReady:setVisible(false)
    self.imgHead.spZhuang:setVisible(self.gamePlayer.isZhuang)
    self:updateFans()
end

function GamePlayerInfoNode:MS_PLAYER_READY(data)
    if data.userid ~= self.gamePlayer.userid then 
        return
    end 
    self.spReady:setVisible(true)
    self.btnReady:setVisible(false)
    UIManager:unblock()
end

function GamePlayerInfoNode:MS_USER_OFFLINE(data)
    if data.userid ~= self.gamePlayer.userid then 
        return
    end 
    self.imgHead.spOffline:setVisible(true)
end 

function GamePlayerInfoNode:MS_USER_RECONNECT(data)
    if data.userid ~= self.gamePlayer.userid then 
        return
    end 
    self.imgHead.spOffline:setVisible(false)
end 

function GamePlayerInfoNode:MS_USERSTATUS_CHANGE(data)
    if data.userid ~= self.gamePlayer.userid then 
        return
    end 
    self.imgHead.spOffline:setVisible(false)
end 

function GamePlayerInfoNode:ICON_DOWNLOADED(data)
    if data.userid ~= self.gamePlayer.userid then 
        --it's not my business
        return 
    end 
    if data.err then 
        UIManager:showTip(string.format("获取玩家%s头像错误：%s", self.gamePlayer.nickname, data.err.msg))
        return
    end 
    self.gamePlayer.playerIcon = data.iconFileName
    self.imgHead:loadTexture(self.gamePlayer.playerIcon,0)
end 

function GamePlayerInfoNode:onClick_imgHead(target)
    UIManager:goTo(Define.SCENE_GAME, "app.modules.playerInfo.PlayerInfoLayer", UIManager.UITYPE_PROMPT, {player = {
                        icon = self.gamePlayer.playerIcon,
                        nickname = self.gamePlayer.nickname,
                        userid = self.gamePlayer.userid,
                        gender = self.gamePlayer.gender,
                        ip = self.gamePlayer.playerIP,
                        city = self.gamePlayer.city,
                        district = self.gamePlayer.district,}})
end 

function GamePlayerInfoNode:onClick_btnReady(target)
    Network:send(Define.SERVER_GAME, "mc_player_ready", {})
    UIManager:block()
    Helper.playSoundClick()
end 

return GamePlayerInfoNode
--endregion
