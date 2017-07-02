--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local HomeLayer = class("HomeLayer", cc.Layer)

--region 
local ServerConnectPurpose = {
    createroom = 1,
    joinroom = 2,
    reconnect = 3,
}
local connectPurpose = ServerConnectPurpose.createroom
--endregion

function HomeLayer:ctor()
    local uiHomeLayer = require("HomeScene.Home.HomeLayer"):create()
    local uiNode = uiHomeLayer.root:addTo(self)

    util.bindUINodes(uiNode, self, self)

    self.imgHeadFrame:setTouchEnabled(true)
    util.bindUITouchEvents(self.imgHeadFrame, self)

    local panSz = self.imgNoticeBg.panNotice:getContentSize()
    local act = cc.RepeatForever:create(cc.Sequence:create(
                    cc.CallFunc:create(function()
                        self.imgNoticeBg.panNotice.txtNotice:setPosition(cc.p(panSz.width, panSz.height * 0.5))
                    end),
                    cc.MoveBy:create(20, cc.p(-panSz.width * 3, 0))))
    self.imgNoticeBg.panNotice.txtNotice:runAction(act)

    self:startAnimation()
    
    Event.register("REAL_NAME_VALIDATE", self, "REAL_NAME_VALIDATE")
    Event.register("HTTP_PLAY_ROOMS_RECORDS", self, "HTTP_PLAY_ROOMS_RECORDS")
    Event.register(EventDefine.ICON_DOWNLOADED, self, "ICON_DOWNLOADED")
    Event.register(EventDefine.WEALTH_ROOMCARD_NUM_CHANGE, self, "WEALTH_ROOMCARD_NUM_CHANGE")    
end 

function HomeLayer:onShow()
    self.imgHeadFrame.imgHead:loadTexture(PlayerCache.icon)
    self.imgHeadFrame.imgRoomCardBg.lblRoomCard:setString(tostring(PlayerCache.roomcardnum))
    self.imgHeadFrame.lblNickName:setString(PlayerCache.nickname)
    WidgetExt.clipPhotoWithFrame(self.imgHeadFrame, self.imgHeadFrame.imgHead, "public/bg-dinlangtouxiang1.png")
    
    Helper.playHomeBgMusic()
end 

function HomeLayer:onClose()
    Event.unregister("REAL_NAME_VALIDATE", self, "REAL_NAME_VALIDATE")
    Event.unregister("HTTP_PLAY_ROOMS_RECORDS", self, "HTTP_PLAY_ROOMS_RECORDS")
    Event.unregister(EventDefine.ICON_DOWNLOADED, self, "ICON_DOWNLOADED")
    Event.unregister(EventDefine.WEALTH_ROOMCARD_NUM_CHANGE, self, "WEALTH_ROOMCARD_NUM_CHANGE")
end 

function HomeLayer:startAnimation()
    local function animateShaiZi(node)
        local delta = math.random(10, 30)
        local iniDelta = math.random(10, 30)
        local time = math.random(1.0, 2.0)
        local rawPos = cc.p(node:getPosition())
        node:setPosition(cc.p(rawPos.x, rawPos.y + iniDelta))
        local act = cc.RepeatForever:create(
            cc.Sequence:create(
                cc.MoveTo:create(time, cc.p(rawPos.x, rawPos.y + delta)),
                cc.MoveTo:create(time, cc.p(rawPos.x, rawPos.y))
            )
        )
        node:runAction(act)
    end 
    local function animateFlower(node)
        local scaleMag = math.random(1100, 1200)
        scaleMag = scaleMag / 1000
        local act = cc.RepeatForever:create(
            cc.Sequence:create(
                cc.CallFunc:create(function()
                end),
                cc.ScaleTo:create(2.0, scaleMag, scaleMag, 1.0),
                cc.ScaleTo:create(2.0, 1.0, 1.0, 1.0)
            )
        )
        node:runAction(act)

        local particle = cc.ParticleFlower:createWithTotalParticles(10)
        local pos = cc.p(node:getPosition())
        pos.y = pos.y + 80
        particle:setPosition(pos)
        node:getParent():addChild(particle)
    end 
    local function animatePetals(node)
        local function createPetal()
            local nodeSz = node:getContentSize()
            local nodeAnpt = node:getAnchorPoint()
            local xDelta = math.random(-nodeSz.width * 0.25, nodeSz.width * 0.25)
            local createPos = cc.p(node:getPosition())
            createPos.x = createPos.x + xDelta
            createPos.y = createPos.y + nodeSz.height * (1 - nodeAnpt.y)
            local sp = cc.Sprite:create("HomeScene/Home/bg_huabang.png")
            sp:setPosition(createPos)
            sp:setOpacity(0)
            sp:setScale(0.5)
            self:addChild(sp)

            local dir = math.random(0, 1)
            dir = dir < 0.5 and -1 or 1
            local moveDelta1 = cc.p(math.random(30, 100), math.random(-50, -150))
            local moveDelta2 = cc.p(math.random(30, 100), math.random(-50, -150))
            local moveDelta3 = cc.p(math.random(30, 100), math.random(-50, -150))
            
            local rotateDelta1 = math.random(5, 30)
            local rotateDelta2 = math.random(5, 30)
            local rotateDelta3 = math.random(5, 30)

            local fadeTime1 = math.random(0.5, 1.5)
            local fadeTime2 = math.random(0.5, 1.5)
            local keepTime = 6 - fadeTime1 - fadeTime2
            local act = cc.Spawn:create(
                cc.Sequence:create(
                    cc.MoveBy:create(2, cc.p(dir * moveDelta1.x, moveDelta1.y)),
                    cc.MoveBy:create(2, cc.p(-dir * moveDelta2.x, moveDelta2.y)),
                    cc.MoveBy:create(2, cc.p(dir * moveDelta3.x, moveDelta3.y))
                ),
                cc.Sequence:create(
                    cc.RotateTo:create(2, dir * rotateDelta1, dir * rotateDelta1),
                    cc.RotateTo:create(2, -dir * rotateDelta1, -dir * rotateDelta1),
                    cc.RotateTo:create(2, dir * rotateDelta1, dir * rotateDelta1)
                ),
                cc.Sequence:create(
                    cc.FadeIn:create(fadeTime1),
                    cc.DelayTime:create(keepTime),
                    cc.FadeOut:create(fadeTime2),
                    cc.CallFunc:create(function()
                        sp:removeFromParent()
                    end)
                )
            )
            sp:runAction(act)
        end 
        
        local nextTime = os.time()
        local delayTime = 0
        local act = cc.RepeatForever:create(
            cc.Sequence:create(
                cc.CallFunc:create(function()
                    local nowTime = os.time()
                    if nowTime < nextTime then 
                        return
                    end 
                    createPetal()
                    nextTime = nowTime + math.random(2, 5)
                end)
            )
        )
        node:runAction(act)
    end 
    animateFlower(self.btnCreateRoom.spFlower)
    animateShaiZi(self.btnCreateRoom.spShaiZi1)
    animateShaiZi(self.btnCreateRoom.spShaiZi2)
    animateShaiZi(self.btnCreateRoom.spShaiZi3)
    animateFlower(self.btnJoinGame.spFlower)
    animateShaiZi(self.btnJoinGame.spShaiZi1)
    animateShaiZi(self.btnJoinGame.spShaiZi2)
    animateShaiZi(self.btnJoinGame.spShaiZi3)
    
    animatePetals(self.btnCreateRoom)
    animatePetals(self.btnJoinGame)
end 

function HomeLayer:ICON_DOWNLOADED(data)
    if data.userid ~= PlayerCache.userid then 
        --it's not my business
        return 
    end 
    if data.err then 
        UIManager:showTip(string.format("player %s Icon download error: %s", PlayerCache.nickname, data.err.msg))
        return
    end 
    if not data.iconFileName or data.iconFileName == "" then 
        printInfo("empty icon downloaded")
        return 
    end 
    self.imgHeadFrame.imgHead:loadTexture(data.iconFileName)
    local sz = self.imgHeadFrame.imgHead:getContentSize()
    WidgetExt.clipPhotoWithFrame(self.imgHeadFrame, self.imgHeadFrame.imgHead, "public/bg-dinlangtouxiang1.png")
end 

function HomeLayer:WEALTH_ROOMCARD_NUM_CHANGE(data)
    self.imgHeadFrame.imgRoomCardBg.lblRoomCard:setString(tostring(PlayerCache.roomcardnum))
end

function HomeLayer:REAL_NAME_VALIDATE(succ)
--    self.btnValidate:setVisible(not succ)
end 

function HomeLayer:HTTP_PLAY_ROOMS_RECORDS(data)
    UIManager:unblock()
    if data.err then 
        printInfo("[HTTP_PLAY_ROOMS_RECORDS] errCode: %d, msg: %s", data.err.code, data.err.msg or "")
        UIManager:showTip("请求回放数据出错")
        return
    else 
        UIManager:goTo(Define.SCENE_HOME, "app.modules.achiv.RoomListLayer", UIManager.UITYPE_FULL_SCREEN, nil, false)
    end 
end 

function HomeLayer:onTouchEnded_imgHeadFrame(sender, pos)
    UIManager:goTo(Define.SCENE_HOME, "app.modules.playerInfo.PlayerInfoLayer", UIManager.UITYPE_PROMPT, {player = {
                        nickname = PlayerCache.nickname,
                        icon = PlayerCache.icon,
                        userid = PlayerCache.userid,
                        gender = PlayerCache.gender,
                        ip = PlayerCache.ip,
                        city = PlayerCache.city,
                        district = PlayerCache.district,}})
    Helper.playSoundClick()
end 

function HomeLayer:onClick_btnCreateRoom(target)
    UIManager:goTo(Define.SCENE_HOME, "app.modules.CreateRoom.CreateRoomLayer", UIManager.UITYPE_PROMPT)
    Helper.playSoundClick()
end 

function HomeLayer:onClick_btnJoinGame(target)
    UIManager:goTo(Define.SCENE_HOME, "app.modules.JoinRoom.JoinRoomLayer", UIManager.UITYPE_PROMPT)
    Helper.playSoundClick()
end 

function HomeLayer:onClick_btnBuyRoomCard(sender)
    UIManager:showTip("Comming soon...")
    Helper.playSoundClick()
end 

function HomeLayer:onClick_btnSettings(sender)
    UIManager:goTo(Define.SCENE_HOME, "app.modules.Settings.SettingsLayer", UIManager.UITYPE_PROMPT)
    Helper.playSoundClick()
end 

function HomeLayer:onClick_btnAchivs(sender)
    UIManager:block()
    AchivCache:requestRoomsRecords()
end 

function HomeLayer:onClick_btnRecharge(sender)
--    UIManager:block()
--    WechatSDK:recharge(PlayerCache.userid .. device.platform .. tostring(os.time()), PlayerCache.userid, "捷战黄冈麻将-3张房卡", 300, "{\"ShopItemId\": 10001}")
--    Helper.playSoundClick()
    
    UIManager:goTo(Define.SCENE_HOME, "app.modules.ShoppingMall.ShoppingMallLayer", UIManager.UITYPE_PROMPT)
end

function HomeLayer:onClick_btnHelp(sender)
    UIManager:goTo(Define.SCENE_HOME, "app.modules.Help.HelpLayer", UIManager.UITYPE_PROMPT)
    Helper.playSoundClick()
end 

function HomeLayer:onClick_btnValidate(sender)
    if PlayerCache:isRealNameValidated() then 
        UIManager:showTip("已认证")
        return 
    end 
    UIManager:goTo(Define.SCENE_HOME, "app.modules.realname.RealNameLayer", UIManager.UITYPE_PROMPT)
    Helper.playSoundClick()
end 

function HomeLayer:onClick_btnWechatShare(sender)
    Helper.playSoundClick()
    UIManager:goTo(Define.SCENE_HOME, "app.modules.wechatShare.WechatShareLayer", UIManager.UITYPE_PROMPT, {
        content = {
            contentType = Define.WECHAT_SHARE_CONTENT_TYPE_TEXT,
            title = "欢乐广东麻将",
            text = "我正在欢乐广东麻将中玩游戏,快来加入房间陪我玩。",
        },
    })
end 

function HomeLayer:onClick_btnFeedback(sender)
    Helper.playSoundClick()
    UIManager:goTo(Define.SCENE_HOME, "app.modules.feedback.FeedbackLayer", UIManager.UITYPE_PROMPT) 
end 

function HomeLayer:onClick_btnScreenShot(sender)
    local function animatePetals(node)
        local function createPetal()
            local nodeSz = node:getContentSize()
            local nodeAnpt = node:getAnchorPoint()
            local xDelta = math.random(-nodeSz.width * 0.25, nodeSz.width * 0.25)
            local createPos = cc.p(node:getPosition())
            createPos.x = createPos.x + xDelta
            createPos.y = createPos.y + nodeSz.height * (1 - nodeAnpt.y)
            local sp = cc.Sprite:create("HomeScene/Home/bg_huabang.png")
            sp:setPosition(createPos)
            sp:setOpacity(0)
            self:addChild(sp)

            local dir = math.random(0, 1)
            dir = dir < 0.5 and -1 or 1
            local moveDelta1 = cc.p(math.random(30, 100), math.random(-50, -150))
            local moveDelta2 = cc.p(math.random(30, 100), math.random(-50, -150))
            local moveDelta3 = cc.p(math.random(30, 100), math.random(-50, -150))
            
            local rotateDelta1 = math.random(5, 30)
            local rotateDelta2 = math.random(5, 30)
            local rotateDelta3 = math.random(5, 30)

            local fadeTime1 = math.random(0.5, 1.5)
            local fadeTime2 = math.random(0.5, 1.5)
            local keepTime = 6.0 - fadeTime1 - fadeTime2
            local act = cc.Spawn:create(
                cc.Sequence:create(
                    cc.MoveBy:create(2.0, cc.p(dir * moveDelta1.x, moveDelta1.y)),
                    cc.MoveBy:create(2.0, cc.p(-dir * moveDelta2.x, moveDelta2.y)),
                    cc.MoveBy:create(2.0, cc.p(dir * moveDelta3.x, moveDelta3.y))
                ),
                cc.Sequence:create(
                    cc.RotateBy:create(2.0, dir * rotateDelta1, dir * rotateDelta1),
                    cc.RotateBy:create(2.0, -dir * rotateDelta1, -dir * rotateDelta1),
                    cc.RotateBy:create(2.0, dir * rotateDelta1, dir * rotateDelta1)
                ),
                cc.Sequence:create(
                    cc.FadeIn:create(fadeTime1),
                    cc.DelayTime:create(keepTime),
                    cc.FadeOut:create(fadeTime2),
                    cc.CallFunc:create(function()
                        sp:removeFromParent()
                    end)
                )
            )
            sp:runAction(act)
        end 
        
                    createPetal()
        local nextTime = os.time()
        local delayTime = 0
        local act = cc.RepeatForever:create(
            cc.Sequence:create(
                cc.CallFunc:create(function()
                    local nowTime = os.time()
                    if nowTime < nextTime then 
                        return
                    end 
                    createPetal()
                    nextTime = nowTime + math.random(1, 3)
                end)
            )
        )
        node:runAction(act)
    end 
    animatePetals(self.btnJoinGame)
end 

return HomeLayer
--endregion
