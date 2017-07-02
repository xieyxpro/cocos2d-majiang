--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local GameReadyLayer = class("GameReadyLayer", cc.Layer)

local GameDefine = require("app.modules.game.GameDefine")
local GamePlayerInfoNode = require("app.modules.game.GamePlayerInfoNode")

function GameReadyLayer:ctor()
    printInfo("GameReadyLayer create")
    local uiNode = require("GameScene.GameReadyLayer"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)

    util.bindUITouchEvents(self.imgVoice, self)
    self.imgVoice:setVisible(false)

    self.playersNodes = {} --[userid] = {player = ?, node = ?},...
    
    self:enableNodeEvents()
    
    self.panPhoneState.lbBattery.percent = 0
    self:refreshPhoneState()

    local act = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1.0),
                        cc.CallFunc:create(function()
                            self.panPhoneState.txtTime:setText(os.date("%H:%M"))
                        end)))
    self.panPhoneState.txtTime:runAction(act)
    
    Event.register("MS_SIT_DOWN", self, "MS_SIT_DOWN")
    Event.register("MS_STAND_UP", self, "MS_STAND_UP")
    Event.register("MS_GAME_START", self, "MS_GAME_START")
    Event.register(EventDefine.PHONE_STATE_BATTERY_CHANGE, self, "PHONE_STATE_BATTERY_CHANGE")--,{batteryLevel=PhoneState.batteryLevel,bCharging=PhoneState.bCharging})
    Event.register(EventDefine.PHONE_STATE_SIG_CHANGE, self, "PHONE_STATE_SIG_CHANGE")--,{sigLevel=PhoneState.sigLevel})
    Event.register(EventDefine.PHONE_STATE_NETWORK_TYPE_CHANGE, self, "PHONE_STATE_NETWORK_TYPE_CHANGE")--,{networktype=data})
--    Event.register(SchedulerExt.EVENT_SECOND, self, "EVENT_SECOND")
end 

function GameReadyLayer:refreshPhoneState()
    if device.platform == "android" or device.platform == "ios" then
        if self.panPhoneState.lbBattery.bCharging ~= PhoneState.bCharging then 
            self.panPhoneState.lbBattery.bCharging = PhoneState.bCharging
            if self.panPhoneState.lbBattery.bCharging then 
                self.panPhoneState.lbBattery:setColor({r = 255, g = 255, b = 255})
                local act = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(function()
                    self.panPhoneState.lbBattery.percent = self.panPhoneState.lbBattery.percent + 10
                    if self.panPhoneState.lbBattery.percent > 100 then 
                        self.panPhoneState.lbBattery.percent = self.panPhoneState.lbBattery.percent - 100
                    end 
                    local percent = self.panPhoneState.lbBattery.percent
                    self.panPhoneState.lbBattery:setPercent(percent)
                    self.panPhoneState.txtBatteryPercent:setText(tostring(math.floor(PhoneState.batteryLevel)))
                end)))
                self.panPhoneState.lbBattery:runAction(act)
            else 
                self.panPhoneState.lbBattery:stopAllActions()
            end 
        end 
        if not self.panPhoneState.lbBattery.bCharging then 
            self.panPhoneState.lbBattery.percent = PhoneState.batteryLevel
            if self.panPhoneState.lbBattery.percent < 10 then 
                self.panPhoneState.lbBattery:setColor({r = 255, g = 0, b = 0})
            else 
                self.panPhoneState.lbBattery:setColor({r = 255, g = 255, b = 255})
            end 
            local percent = self.panPhoneState.lbBattery.percent
            self.panPhoneState.lbBattery:setPercent(percent)
            self.panPhoneState.txtBatteryPercent:setText(tostring(math.floor(percent)))
        end 
        local sigTextureName = ""
        local networkType = PhoneState:getNetworkType()
        if networkType == "WIFI" then 
            sigTextureName = "wifi"
            self.panPhoneState.imgSig:setVisible(true)
            self.panPhoneState.txtSig:setVisible(false)
            sigTextureName = "public/" .. sigTextureName .. tostring(PhoneState.sigLevel) .. ".png"
            self.panPhoneState.imgSig:loadTexture(sigTextureName)
        else 
            self.panPhoneState.imgSig:setVisible(false)
            self.panPhoneState.txtSig:setVisible(true)
            self.panPhoneState.txtSig:setText(networkType)
        end 
    else 
        self.panPhoneState.lbBattery.percent = 100
        local percent = self.panPhoneState.lbBattery.percent
        self.panPhoneState.lbBattery:setPercent(percent)
        self.panPhoneState.txtBatteryPercent:setText(tostring(math.floor(percent)))
        self.panPhoneState.imgSig:loadTexture("public/sig_pc.png")
        self.panPhoneState.txtSig:setVisible(false)
    end 
    self.panPhoneState.txtTime:setText(os.date("%H:%M"))
end 

function GameReadyLayer:onTouchBegan_imgVoice(touch, eventTouch)
    --TODO
    print("onTouchBegan_imgVoice")
    VoiceSDK:startRecord("params");
    return true
end 

function GameReadyLayer:onTouchMoved_imgVoice(touch, eventTouch)
    --TODO
    print("onTouchMoved_imgVoice")
    return true
end 

function GameReadyLayer:onTouchEnded_imgVoice(touch, eventTouch)
    --TODO
    print("onTouchEnded_imgVoice")
    VoiceSDK:stopRecord();
    return true
end 

function GameReadyLayer:onTouchCanceled_imgVoice(touch, eventTouch)
    print("onTouchCanceled_imgVoice")
    VoiceSDK:cancleReocrd()
    UIManager:showTip("取消发送成功")
    return true
end 

function GameReadyLayer:onEnter()
end 

function GameReadyLayer:onExit()
    Event.unregister("MS_SIT_DOWN", self, "MS_SIT_DOWN")
    Event.unregister("MS_STAND_UP", self, "MS_STAND_UP")
    Event.unregister("MS_GAME_START", self, "MS_GAME_START")
    Event.unregister(EventDefine.PHONE_STATE_BATTERY_CHANGE, self, "PHONE_STATE_BATTERY_CHANGE")--,{batteryLevel=PhoneState.batteryLevel,bCharging=PhoneState.bCharging})
    Event.unregister(EventDefine.PHONE_STATE_SIG_CHANGE, self, "PHONE_STATE_SIG_CHANGE")--,{sigLevel=PhoneState.sigLevel})
    Event.unregister(EventDefine.PHONE_STATE_NETWORK_TYPE_CHANGE, self, "PHONE_STATE_NETWORK_TYPE_CHANGE")--,{networktype=data})
--    Event.unregister(SchedulerExt.EVENT_SECOND, self, "EVENT_SECOND")
end

function GameReadyLayer:addPlayer(player)
    printInfo("Player: %s", table.tostring(player, true))
    assert(self.playersNodes[player.userid] == nil)
    local infoNode = GamePlayerInfoNode:create(player)
    infoNode:onCreate()
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
    playerNode.readyPos = cc.p(playerNode.panel.nodePlayerInfoReady:getPosition())
    playerNode.playPos = cc.p(playerNode.panel.nodePlayerInfoPlay:getPosition())
    if GameCache.roomStatus == GameDefine.enum_GameStatus.GS_FREE then 
        infoNode:setPosition(playerNode.readyPos)
    else
        infoNode:setPosition(playerNode.playPos)
    end 
    self.playersNodes[player.userid] = playerNode
end 

function GameReadyLayer:initialize()
    --clear
    for _, playerNode in pairs(self.playersNodes) do 
        if playerNode.node then 
            playerNode.node:onDestroy()
            playerNode.node:removeFromParentAndCleanup(true)
        end 
    end 
    self.playersNodes = {}
    self.btnWechatInvite:setVisible(true)
    --valuation
    for _, player in pairs(GameCache.players) do 
        self:addPlayer(player)
    end 
    self.lblRoomID:setString(tostring(GameCache.roomID))
    if GameCache.roomStatus == GameDefine.enum_GameStatus.GS_PLAYING then 
        self.btnWechatInvite:setVisible(false)
    end 
end 

function GameReadyLayer:EVENT_SECOND(data)
    print("AAAAAAAAAAAA")
    self:refreshPhoneState()
end

function GameReadyLayer:PHONE_STATE_BATTERY_CHANGE(data)
    self:refreshPhoneState()
end

function GameReadyLayer:PHONE_STATE_SIG_CHANGE(data)
    self:refreshPhoneState()
end

function GameReadyLayer:PHONE_STATE_NETWORK_TYPE_CHANGE(data)
    self:refreshPhoneState()
end

function GameReadyLayer:MS_GAME_START(data)
    printInfo("GameReadyLayer:MS_GAME_START")
    for _, playerNode in pairs(self.playersNodes) do 
        local act = cc.Sequence:create(cc.MoveTo:create(1, playerNode.playPos))
        playerNode.node:runAction(act)
    end 
    self.btnWechatInvite:setVisible(false)
end

function GameReadyLayer:MS_SIT_DOWN(data)
    printInfo("GameReadyLayer: MS_SIT_DOWN")
    local player = GameCache.players[data.player.userid]
    self:addPlayer(player)
end 

function GameReadyLayer:MS_STAND_UP(data)
    assert(self.playersNodes[data.userid])
    local playerNode = self.playersNodes[data.userid]
    playerNode.node:removeFromParent()
    self.playersNodes[data.userid] = nil
end 

function GameReadyLayer:onClick_btnWechatInvite(sender)
    Helper.playSoundClick()
--    UIManager:goTo(Define.SCENE_HOME, "app.modules.wechatShare.WechatShareLayer", UIManager.UITYPE_PROMPT, {
--        content = {
--            contentType = Define.WECHAT_SHARE_CONTENT_TYPE_TEXT,
--            title = string.format("房号:【%d】",GameCache.roomID),
--            text = "我正在捷战黄冈麻将中玩游戏,快来加入房间陪我玩。",
--        },
--    })
    if device.platform == "ios" or device.platform == "android" then
        local strTitle = string.format("房号:【%d】",GameCache.roomID)
        local strShareMsg =  string.format("我正在欢乐广东麻将中玩游戏,快来加入房间陪我玩。")

        WechatSDK:shareWebpageToWX(PlayerCache.account .. "web_" .. tostring(os.time()), WechatSDK.SCENE_SESSION ,"http://hgmj.jiezhansifang.com/download/download_jzhgmj.html",strTitle,strShareMsg)
    else 
        printInfo("share function is available only in ios or android")
    end
end 

function GameReadyLayer:onClick_btnMenu(sender)
    Helper.playSoundClick()
    require("app.modules.game.MenuLayer")
                        :create()
                        :addTo(cc.Director:getInstance():getRunningScene())
end 

return GameReadyLayer
--endregion
