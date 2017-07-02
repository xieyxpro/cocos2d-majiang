--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local PlaybackPlayLayer = class("PlaybackPlayLayer", cc.Layer)

local PlayActionNode = require("app.modules.achiv.PlaybackPlayActionNode")

local CardsArrayBottom = require("app.modules.game.CardsArrayBottom")
local CardsArrayRight = require("app.modules.game.CardsArrayRight")
local CardsArrayTop = require("app.modules.game.CardsArrayTop")
local CardsArrayLeft = require("app.modules.game.CardsArrayLeft")
local GameDefine = require("app.modules.game.GameDefine")
local MJLogic = require("app.modules.game.MJLogic")
local MingCardsNodeBottom = require("app.modules.game.MingCardsNodeBottom")
local MingCardsNodeLeft = require("app.modules.game.MingCardsNodeLeft")
local MingCardsNodeRight = require("app.modules.game.MingCardsNodeRight")
local MingCardsNodeTop = require("app.modules.game.MingCardsNodeTop")
local UselessCardsNodeBottom = require("app.modules.game.UselessCardsNodeBottom")
local UselessCardsNodeLeft = require("app.modules.game.UselessCardsNodeLeft")
local UselessCardsNodeRight = require("app.modules.game.UselessCardsNodeRight")
local UselessCardsNodeTop = require("app.modules.game.UselessCardsNodeTop")
local GameTipNode = require("app.modules.game.GameTipNode")
local GameHelper = require("app.modules.game.GameHelper")
local List = require("core.List")

local PLAY_STATUS = {
    NONE = 0,
    PLAYING = 1,
    PAUSED = 2,
    STOPPED = 3,
}

function PlaybackPlayLayer:ctor()
    local uiNode = require("HomeScene.achiv.PlaybackPlayLayer"):create().root:addTo(self)
    
    util.bindUINodes(uiNode, self, self)

    self.txtProgress.rawText = self.txtProgress:getString()

    self.room = nil
    self.rollData = nil
    self.scheduleID = 0
    self.status = PLAY_STATUS.NONE
    self.waitActionFinished = false

    self.spWatchMark:setVisible(false)

    self.nodeGameTip = GameTipNode:create():addTo(self.nodeGameTip)
    self.nodeGameTip:setMode(GameDefine.GAME_MODE.DEMO)

    self.players = {} --[chairID] = {userid = ?, chairID = ?, handCardsNode = ?, mingCardsNode = ?, uselessCardsNode = ?, playActionNode = ?},...
    
    self:enableNodeEvents()

    self.animatingQue = List()
end 

function PlaybackPlayLayer:onEnter()
    
end 

function PlaybackPlayLayer:onExit()
    if self.scheduleID ~= 0 then 
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(self.scheduleID)
        self.scheduleID = 0
    end 
end 

function PlaybackPlayLayer:getPlayerFans(chairID)
    local player = self.players[chairID]
    assert(player)
    local isKaiKou = false
    local fansCnt = 0
    for _, mingCard in pairs(player.mingCardsNode.mingCards) do 
        if mingCard.mingType == GameDefine.MING_TYPE_CHI_LEFT or 
            mingCard.mingType == GameDefine.MING_TYPE_CHI_MID or 
            mingCard.mingType == GameDefine.MING_TYPE_CHI_RIGHT or 
            mingCard.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_PENG or 
            mingCard.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_WATCH or 
            mingCard.mingType == GameDefine.MING_TYPE_PENG then 
            isKaiKou = true
            if mingCard.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_PENG or 
                mingCard.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_WATCH then 
                fansCnt = fansCnt + 1
            end 
        elseif mingCard.mingType == GameDefine.MING_TYPE_AN_GANG then 
            fansCnt = fansCnt + 2
        elseif mingCard.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_GANG_PAI then 
            if mingCard.cardVal == self.rollData.laiZiCardVal then 
                fansCnt = fansCnt + 2
            elseif mingCard.cardVal == self.rollData.laiZiPiCardVal then 
                fansCnt = fansCnt + 1
            elseif mingCard.cardVal == self.rollData.hongZhongCardVal then 
                fansCnt = fansCnt + 1
            end 
        end 
    end 
    if isKaiKou then 
        fansCnt = fansCnt + 1
    end 
    return fansCnt
end 

function PlaybackPlayLayer:notifyFansUpdate(chairID)
    local player = self.players[chairID]
    assert(player)
    local fans = self:getPlayerFans(chairID)
    Event.dispatch("PLAYBACK_UPD_FANS", {userid = player.userid, fans = fans})
end 

function PlaybackPlayLayer:updateProgressStatus()
    self.imgOpBg.btnBackward:setEnabled(self.rollData.curPlayProgress > 0)
    self.imgOpBg.btnForward:setEnabled(self.rollData.curPlayProgress < #self.rollData.actionsQue)
    self.txtProgress:setText(string.format(self.txtProgress.rawText, self.rollData.curPlayProgress, #self.rollData.actionsQue))
end 

function PlaybackPlayLayer:pause()
    if self.status == PLAY_STATUS.PAUSED then 
        return
    end 
    self.status = PLAY_STATUS.PAUSED
    self.imgOpBg.btnPlay:setVisible(true)
    self.imgOpBg.btnPause:setVisible(false)
end 

function PlaybackPlayLayer:stop()
    if self.status == PLAY_STATUS.STOPPED then 
        return
    end 
    self.status = PLAY_STATUS.STOPPED
    self.imgOpBg.btnPlay:setVisible(true)
    self.imgOpBg.btnPause:setVisible(false)
    if self.scheduleID ~= 0 then 
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(self.scheduleID)
        self.scheduleID = 0
    end 
end 

function PlaybackPlayLayer:play()
    if self.status == PLAY_STATUS.PLAYING then 
        return
    end 
    self.status = PLAY_STATUS.PLAYING
    self.imgOpBg.btnPlay:setVisible(false)
    self.imgOpBg.btnPause:setVisible(true)

    local nextActTime = 0
    local timeSpace = 0
    local function nextAction()
        local progress = self.rollData.curPlayProgress + 1
        if progress > #self.rollData.actionsQue then 
            self:stop()
            return
        end 
        local actData = self.rollData.actionsQue[progress]
        self:doAction(actData)
        self.rollData.curPlayProgress = progress
        self:updateProgressStatus()
    end 
    local scheduler = cc.Director:getInstance():getScheduler()
    self.scheduleID = scheduler:scheduleScriptFunc(function()
        if self.status == PLAY_STATUS.STOPPED then 
            scheduler:unscheduleScriptEntry(self.scheduleID)
            self.scheduleID = 0
            return
        elseif self.status == PLAY_STATUS.PAUSED then 
            return
        elseif self.status == PLAY_STATUS.PLAYING then
            local nowTime = os.time()
            if not self.waitActionFinished then 
                if nowTime < nextActTime then 
                    return
                end 
                nextAction()
                timeSpace = math.random(0.1, 0.5)
                nextActTime = nowTime + timeSpace
            else 
                nextActTime = nowTime
            end  
        else
            assert(false)
        end 
    end, 0, false)
end 

function PlaybackPlayLayer:doAction(actionData)
    if actionData.act == GameDefine.PLAY_ACT_OUT then 
        self:onPlayActOutCard(actionData.chairID, actionData.data)
    elseif actionData.act == GameDefine.PLAY_ACT_SYS then 
        self:onPlayActSys(actionData.chairID, actionData.data)
    elseif actionData.act == GameDefine.PLAY_ACT_CHI then 
        self:onPlayActChi(actionData.chairID, actionData.data)
    elseif actionData.act == GameDefine.PLAY_ACT_GANG_PLAYBACK then 
        self:onPlayActGang(actionData.chairID, actionData.data)
    elseif actionData.act == GameDefine.PLAY_ACT_PENG then 
        self:onPlayActPeng(actionData.chairID, actionData.data)
    elseif actionData.act == GameDefine.PLAY_ACT_HU then 
        self:onPlayActHu(actionData.chairID, actionData.data)
    elseif actionData.act == GameDefine.PLAY_ACT_GUO then 
        self:onPlayActGuo(actionData.chairID, actionData.data)
    elseif actionData.act == GameDefine.PLAY_ACT_ANIMA_DINGLAI then 
        self:onPlayActAnimaDingLai(actionData.chairID, actionData.data)
    elseif actionData.act == GameDefine.PLAY_ACT_ANIMA_SHAIZI then 
        self:onPlayActAnimaShaiZi(actionData.chairID, actionData.data)
    else
        assert(false)
    end
end

function PlaybackPlayLayer:newTurn(chairID, actionWaitTime)
    local player = self.rollData.players[chairID]
    assert(player)
    self.nodeGameTip:newTimer(actionWaitTime)
    self.nodeGameTip:setProgress({cardsRemainCnt = 0, 
            rollsCnt = 0 + 1, 
            totalRolls = 0})
    self.nodeGameTip:setDir(player.seatDir)
end

function PlaybackPlayLayer:resetOutCardMark()
    self.spWatchMark:setVisible(false)
end

function PlaybackPlayLayer:availOutCardMark(chairID)
    local player = self.players[chairID]
    assert(player)
    local rawPos = player.uselessCardsNode:getLastCardPosition()
    local pos = self:convertToNodeSpace(rawPos)
    pos.y = pos.y + 30
    self.spWatchMark:stopAllActions()
    self.spWatchMark:setPosition(pos)
    self.spWatchMark:setVisible(true)
    local act = cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.7, cc.p(0, 30)),
                                                            cc.MoveBy:create(0.7, cc.p(0, -30))))
    self.spWatchMark:runAction(act)
end

function PlaybackPlayLayer:onPlayActAnimaDingLai(chairID, data)
    self.waitActionFinished = true
    local dingLaiNode
    local function callback()
        self.animatingQue:popByIndex(dingLaiNode)
        self.waitActionFinished = false
    end 
    dingLaiNode = require("app.modules.game.DingLaiLayer")
        :create({
            cardVal = data.laiZiCardVal,
            callback = callback,
        })
        :addTo(self)
        
    self.animatingQue:pushBack({
        act = GameDefine.PLAY_ACT_ANIMA_DINGLAI,
        chairID = chairID,
        data = data,
        dingLaiNode = dingLaiNode,
    }, dingLaiNode)
end 

function PlaybackPlayLayer:onPlayActAnimaShaiZi(chairID, data)
    self.waitActionFinished = true
    local function showEft()
        local animaTime = 1.5
        local shaiZi1Val = data.shaiZi1Val
        local shaiZi2Val = data.shaiZi2Val

        local spriteFrameCache  = cc.SpriteFrameCache:getInstance()
        spriteFrameCache:addSpriteFrames("GameScene/shaizidonghua/shaizi_anima.plist")

        local anima1 = cc.Animation:create()
        for i = 1, 8, 1 do 
            local name = string.format("shaizidonghua_%d.png", i)
            local spriteFrame = spriteFrameCache:getSpriteFrame(name)
            anima1:addSpriteFrame(spriteFrame)
        end 
        anima1:setDelayPerUnit(0.05)
        local animation1 =cc.Animate:create(anima1)
        local sprt1 = cc.Sprite:create(string.format("GameScene/shaizi/shaizi_%d.png", shaiZi1Val))
            :addTo(self)
            :setPosition(cc.p(display.cx - 50, display.cy))
        sprt1:runAction(cc.RepeatForever:create(animation1))

        local anima2 = cc.Animation:create()
        for i = 1, 8, 1 do 
            local name = string.format("shaizidonghua_%d.png", i)
            local spriteFrame = spriteFrameCache:getSpriteFrame(name)
            anima2:addSpriteFrame(spriteFrame)
        end 
        anima2:setDelayPerUnit(0.05)
        local animation2 =cc.Animate:create(anima2)
        local sprt2 = cc.Sprite:create(string.format("GameScene/shaizi/shaizi_%d.png", shaiZi2Val))
            :addTo(self)
            :setPosition(cc.p(display.cx + 50, display.cy))
        sprt2:runAction(cc.RepeatForever:create(animation2))

        local animaNode = cc.Node:create():addTo(self)
        local act = cc.Sequence:create(
            cc.DelayTime:create(animaTime),
            cc.CallFunc:create(function()
                sprt1:stopAllActions()
                sprt2:stopAllActions()
                sprt1:setTexture(string.format("GameScene/shaizi/shaizi_%d.png", shaiZi1Val))
                sprt2:setTexture(string.format("GameScene/shaizi/shaizi_%d.png", shaiZi2Val))
            end),
            cc.DelayTime:create(2),
            cc.CallFunc:create(function()
                self.animatingQue:popByIndex(animaNode)
                sprt1:removeFromParent()
                sprt2:removeFromParent()
                animaNode:removeFromParent()
                self.waitActionFinished = false
            end)
        )
        animaNode:runAction(act)
        
        self.animatingQue:pushBack({
            act = GameDefine.PLAY_ACT_ANIMA_SHAIZI,
            chairID = chairID,
            data = data,
            sprt1 = sprt1,
            sprt2 = sprt2,
            animaNode = animaNode,
        }, animaNode)
    end 
    showEft()
end 

function PlaybackPlayLayer:onPlayActSys(chairID, data)
    local player = self.players[data.whosTurnChairID]
    self.waitActionFinished = true
    local function showActions()
        local enabledActions = {}
        if data.actions and #data.actions == 1 and 
            data.actions[1] == GameDefine.PLAY_ACT_OUT then 
            player.playActionNode:setVisible(false)
            self.waitActionFinished = false
            return 
        end 
        for _, actVal in ipairs(data.actions or {}) do 
            table.insert(enabledActions, actVal)
        end 
        if #enabledActions == 0 then 
            player.playActionNode:setVisible(false)
            self.waitActionFinished = false
            return 
        end 
        player.playActionNode:setVisible(true)
        player.playActionNode:enableActions(enabledActions)
        self.waitActionFinished = false
    end 
    if data.cardVal and data.cardVal ~= 0 then
        local pos = player.handCardsNode:getSysCardPosition()
        pos = self:convertToNodeSpace(pos)
        local node = player.handCardsNode:createCardNode(data.cardVal)
        node:setPosition(cc.p(display.cx, display.cy))
        node:setScale(0)
        node:addTo(self)
        local act = cc.Spawn:create(
            cc.FadeIn:create(0.1),
            cc.MoveTo:create(0.3, pos),
            cc.Sequence:create(
                cc.ScaleTo:create(0.3, 1.0, 1.0, 1.0),
                cc.CallFunc:create(function()
                    node:removeFromParent()
                    player.handCardsNode:addSysCard(data.cardVal)
                    showActions()
                    self.animatingQue:popByIndex(node)
                    print(string.format("AnimatingQue Size: %d", self.animatingQue:size()))
                end)
            )
        )
        node:runAction(act)
        self.animatingQue:pushBack({
            act = GameDefine.PLAY_ACT_SYS,
            chairID = chairID,
            data = data,
            node = node,
        }, node)
    else
        showActions()
    end 
    self:newTurn(data.whosTurnChairID, data.actionWaitTime)
end 

function PlaybackPlayLayer:onPlayActOutCard(chairID, data)
    local player = self.players[chairID]
    assert(player)
    self.waitActionFinished = true
    local node = player.uselessCardsNode:createOutCardNode(data.cardVal)
    local cardNode = player.handCardsNode:selectAOutCardNode(data.cardVal)
    cardNode:setVisible(false)
    local newNodePos = WidgetExt.convertSpace(cardNode, self)
    local dspSz = WidgetExt.getNodeDisplaySize(cardNode)
    local nodeSz = node:getContentSize()
    node:addTo(self)
    node:setPosition(newNodePos)
    node:setScaleX(dspSz.width / nodeSz.width)
    node:setScaleY(dspSz.height / nodeSz.height)
    local dstSz = player.uselessCardsNode:getTheNextCardSize()
    dstSz = WidgetExt.getDisplaySizeOf(player.uselessCardsNode, dstSz)
    local dstScale = cc.p(dstSz.width / nodeSz.width, dstSz.height / nodeSz.height)
    local pos = player.uselessCardsNode:getTheNextCardPosition()
    local localPos = self:convertToNodeSpace(pos)
    local act = cc.Spawn:create(
        cc.Sequence:create(
            cc.ScaleTo:create(0, 1.5, 1.5, 1.0),
            cc.DelayTime:create(0.7),
            cc.ScaleTo:create(0.2, dstScale.x, dstScale.y, 1)),
        cc.Sequence:create(
            cc.MoveTo:create(0, cc.p(display.cx, display.cy)),
            cc.DelayTime:create(0.7),
            cc.MoveTo:create(0.2, localPos),
            cc.CallFunc:create(function()
                self.animatingQue:popByIndex(node)
                node:removeFromParent()
                player.handCardsNode:rmvCard(data.cardVal)
                player.uselessCardsNode:addCard(data.cardVal)
                self:availOutCardMark(chairID)
                self.waitActionFinished = false
            end))
        )
    node:runAction(act)
    self.animatingQue:pushBack({
        act = GameDefine.PLAY_ACT_OUT,
        chairID = chairID,
        data = data,
        node = node,
    }, node)
    Helper.playCardSound(player.gender, data.cardVal)
end

function PlaybackPlayLayer:onPlayActGuo(chairID, data)
    local player = self.players[chairID]
    
    self.waitActionFinished = true
    local function callback()
        self.waitActionFinished = false
        self.animatingQue:popByIndex(player.playActionNode)
    end 
    player.playActionNode:doAction(GameDefine.PLAY_ACT_GUO, callback)
    self.animatingQue:pushBack({
        act = GameDefine.PLAY_ACT_GUO,
        chairID = chairID,
        data = data,
        node = nil,
    }, player.playActionNode)
end 

function PlaybackPlayLayer:onPlayActPeng(chairID, data)
    local player = self.players[chairID]
    
    self.waitActionFinished = true
    local function callback()
        player.mingCardsNode:addCard(data.cardVal, GameDefine.MING_TYPE_PENG, 0)
        player.handCardsNode:rmvCards({data.cardVal, data.cardVal})
        self:resetOutCardMark()
        local function showEft()
            Helper.playSoundPeng(player.gender)
            local spEft = cc.Sprite:create("GameScene/bt-donghuapeng.png")
            spEft:setCascadeOpacityEnabled(true)
            local sz = spEft:getContentSize()
            local spBg = cc.Sprite:create("GameScene/bg-donghuadapaidonghuadi.png")
                :addTo(spEft, -1)
                :setPosition(cc.p(sz.width * 0.5, sz.height * 0.5))
            local pos = WidgetExt.convertSpace(player.uselessCardsNode:getParent(), self)
            spEft:addTo(self)
            spEft:setPosition(pos)
            local act = cc.Spawn:create(
                cc.RotateBy:create(1.0, -30, -30),
                cc.Sequence:create(
                    cc.DelayTime:create(1.3),
                    cc.CallFunc:create(function()
                        spEft:removeFromParent()
                    end)
                )
            )
            spBg:runAction(act)
            local act2 = cc.Spawn:create(
                cc.Sequence:create(
                    cc.ScaleTo:create(0.1, 1.1, 1.1, 1),
                    cc.ScaleTo:create(0.1, 1.0, 1.0, 1)
                ),
                cc.Sequence:create(
                    cc.DelayTime:create(1.0),
                    cc.FadeOut:create(0.3)
                )
            )
            spEft:runAction(act2)
        end 
    
        -- search the last out card player
        local lastOutAct = self.rollData:getLastOutAct()
        assert(lastOutAct)
        local watchPlayer = self.players[lastOutAct.chairID]
        watchPlayer.uselessCardsNode:rmvTheLast(lastOutAct.data.cardVal)
        self:notifyFansUpdate(chairID)
        showEft()
        self.waitActionFinished = false
        self.animatingQue:popByIndex(player.playActionNode)
    end 
    player.playActionNode:doAction(GameDefine.PLAY_ACT_PENG, callback)
    self.animatingQue:pushBack({
        act = GameDefine.PLAY_ACT_PENG,
        chairID = chairID,
        data = data,
        node = nil,
    }, player.playActionNode)
end 

function PlaybackPlayLayer:onPlayActHu(chairID, data)
    local player = self.players[chairID]
    self.waitActionFinished = true
    local function callback()
        self:resetOutCardMark()
        self.waitActionFinished = true
        local function showEft()
            Helper.playSoundHu(player.gender, data.huType == GameDefine.HU_TYPE_ZI_MO)
            local eftPath = "GameScene/bt-donghuahu.png"
--            if data.huType == GameDefine.HU_TYPE_DIAN_PAO then 
--                eftPath = "GameScene/bt-donghuadianpao.png"
--            elseif data.huType == GameDefine.HU_TYPE_HAI_DI_LAO then 
--                eftPath = "GameScene/bt-donghuahaidilaoyue.png"
--            elseif data.huType == GameDefine.HU_TYPE_NORMAL then 
--                eftPath = "GameScene/bt-donghuahu.png"
--            elseif data.huType == GameDefine.HU_TYPE_QIANG_GANG then 
--                eftPath = "GameScene/bt-donghuaqianggan.png"
--            elseif data.huType == GameDefine.HU_TYPE_ZI_MO then 
--                eftPath = "GameScene/bt-donghuazhimo.png"
--            else
--                assert(false)
--            end 
            local spEft = cc.Sprite:create(eftPath)
            spEft:setCascadeOpacityEnabled(true)
            local sz = spEft:getContentSize()
            local spBg = cc.Sprite:create("GameScene/bg-donghuadapaidonghuadi.png")
                :addTo(spEft, -1)
                :setPosition(cc.p(sz.width * 0.5, sz.height * 0.5))
            local pos = WidgetExt.convertSpace(player.uselessCardsNode:getParent(), self)
            spEft:addTo(self)
            spEft:setPosition(pos)
            local act = cc.Spawn:create(
                cc.RotateBy:create(1.0, -30, -30),
                cc.Sequence:create(
                    cc.DelayTime:create(2.0),
                    cc.CallFunc:create(function()
                        self.canNextAnima = true
                        UIManager:unfreeze()
                        spEft:removeFromParent()
                    end)
                )
            )
            spBg:runAction(act)
            local act2 = cc.Spawn:create(
                cc.Sequence:create(
                    cc.ScaleTo:create(0.1, 1.1, 1.1, 1),
                    cc.ScaleTo:create(0.1, 1.0, 1.0, 1)
                ),
                cc.Sequence:create(
                    cc.DelayTime:create(1.0),
                    cc.FadeOut:create(0.3)
                )
            )
            spEft:runAction(act2)
        end 
        showEft()
        self.waitActionFinished = false
        self.animatingQue:popByIndex(player.playActionNode)
    end 
    player.playActionNode:doAction(GameDefine.PLAY_ACT_HU, callback)
    self.animatingQue:pushBack({
        act = GameDefine.PLAY_ACT_HU,
        chairID = chairID,
        data = data,
        node = nil,
    }, player.playActionNode)
end 

function PlaybackPlayLayer:onPlayActGang(chairID, data)
    local player = self.players[chairID]
    local function showEft()
        Helper.playSoundGang(player.gender)
        local eftPath = "GameScene/bt-donghuagan.png"
        if data.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_GANG_PAI then 
            if data.cardVal == GameCache.laiZiCardVal then 
                eftPath = "GameScene/bt-donghualaizigang.png"
            elseif data.cardVal == GameCache.laiZiPiCardVal then 
                eftPath = "GameScene/bt-donghuapizigan.png"
            elseif data.cardVal == GameCache.hongZhongCardVal then 
                eftPath = "GameScene/bt-donghuahongzhonggan.png"
            else
                assert(false)
            end 
        end 
        local spEft = cc.Sprite:create(eftPath)
        spEft:setCascadeOpacityEnabled(true)
        local sz = spEft:getContentSize()
        local spBg = cc.Sprite:create("GameScene/bg-donghuadapaidonghuadi.png")
            :addTo(spEft, -1)
            :setPosition(cc.p(sz.width * 0.5, sz.height * 0.5))
        local pos = WidgetExt.convertSpace(player.uselessCardsNode:getParent(), self)
        spEft:addTo(self)
        spEft:setPosition(pos)
        local act = cc.Spawn:create(
            cc.RotateBy:create(1.0, -30, -30),
            cc.Sequence:create(
                cc.DelayTime:create(1.3),
                cc.CallFunc:create(function()
                    spEft:removeFromParent()
                end)
            )
        )
        spBg:runAction(act)
        local act2 = cc.Spawn:create(
            cc.Sequence:create(
                cc.ScaleTo:create(0.1, 1.1, 1.1, 1),
                cc.ScaleTo:create(0.1, 1.0, 1.0, 1)
            ),
            cc.Sequence:create(
                cc.DelayTime:create(1.0),
                cc.FadeOut:create(0.3)
            )
        )
        spEft:runAction(act2)
    end 
    if data.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_GANG_PAI then 
        player.handCardsNode:rmvCards({data.cardVal})
        player.mingCardsNode:addCard(data.cardVal, data.mingType, data.subMingType)
        showEft()
        self:resetOutCardMark()
        self:notifyFansUpdate(chairID)
    else 
        self.waitActionFinished = true
        local function callback()
            if data.mingType == GameDefine.MING_TYPE_AN_GANG then 
                player.handCardsNode:rmvCards({data.cardVal, data.cardVal, data.cardVal, data.cardVal})
            elseif data.mingType == GameDefine.MING_TYPE_MING_GANG then 
                if data.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_PENG then 
                    player.mingCardsNode:rmvCard(data.cardVal, GameDefine.MING_TYPE_PENG)
                    player.handCardsNode:rmvCards({data.cardVal})
                elseif data.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_WATCH then 
                    player.handCardsNode:rmvCards({data.cardVal, data.cardVal, data.cardVal})
                    -- search the last out card player
                    local lastOutAct = self.rollData:getLastOutAct()
                    assert(lastOutAct)
                    local watchPlayer = self.players[lastOutAct.chairID]
                    watchPlayer.uselessCardsNode:rmvTheLast(lastOutAct.data.cardVal)
    --            elseif data.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_GANG_PAI then 
    --                player.handCardsNode:rmvCards({data.cardVal})
                end 
            end 
            player.mingCardsNode:addCard(data.cardVal, data.mingType, data.subMingType)
            self:resetOutCardMark()
            self:notifyFansUpdate(chairID)
            showEft()
            self.waitActionFinished = false
            self.animatingQue:popByIndex(player.playActionNode)
        end 
        player.playActionNode:doAction(GameDefine.PLAY_ACT_GANG_PLAYBACK, callback)
        self.animatingQue:pushBack({
            act = GameDefine.PLAY_ACT_GANG_PLAYBACK,
            chairID = chairID,
            data = data,
            node = nil,
        }, player.playActionNode)
    end 
end 

function PlaybackPlayLayer:onPlayActChi(chairID, data)
    local player = self.players[chairID]
    self.waitActionFinished = true
    local function callback()
        local function showEft()
            Helper.playSoundChi(player.gender)
            local spEft = cc.Sprite:create("GameScene/bt-donghuachi.png")
            spEft:setCascadeOpacityEnabled(true)
            local sz = spEft:getContentSize()
            local spBg = cc.Sprite:create("GameScene/bg-donghuadapaidonghuadi.png")
                :addTo(spEft, -1)
                :setPosition(cc.p(sz.width * 0.5, sz.height * 0.5))
            local pos = WidgetExt.convertSpace(player.uselessCardsNode:getParent(), self)
            spEft:addTo(self)
            spEft:setPosition(pos)
            local act = cc.Spawn:create(
                cc.RotateBy:create(1.0, -30, -30),
                cc.Sequence:create(
                    cc.DelayTime:create(1.3),
                    cc.CallFunc:create(function()
                        spEft:removeFromParent()
                    end)
                )
            )
            spBg:runAction(act)
            local act2 = cc.Spawn:create(
                cc.Sequence:create(
                    cc.ScaleTo:create(0.1, 1.1, 1.1, 1),
                    cc.ScaleTo:create(0.1, 1.0, 1.0, 1)
                ),
                cc.Sequence:create(
                    cc.DelayTime:create(1.0),
                    cc.FadeOut:create(0.3)
                )
            )
            spEft:runAction(act2)
        end 
        player.mingCardsNode:addCard(data.cardVal, data.chiType, nil)
        if data.chiType == GameDefine.MING_TYPE_CHI_LEFT then 
            player.handCardsNode:rmvCards({data.cardVal + 1, data.cardVal + 2})
        elseif data.chiType == GameDefine.MING_TYPE_CHI_MID then 
            player.handCardsNode:rmvCards({data.cardVal - 1, data.cardVal + 1})
        elseif data.chiType == GameDefine.MING_TYPE_CHI_RIGHT then 
            player.handCardsNode:rmvCards({data.cardVal - 2, data.cardVal - 1})
        else 
            printError("invalid chi type: %d", data.chiType)
        end 
        -- search the last out card player
        local lastOutAct = self.rollData:getLastOutAct()
        assert(lastOutAct)
        local watchPlayer = self.players[lastOutAct.chairID]
        watchPlayer.uselessCardsNode:rmvTheLast(lastOutAct.data.cardVal)
        showEft()
        self:resetOutCardMark()
        self:notifyFansUpdate(chairID)
        self.waitActionFinished = false
        self.animatingQue:popByIndex(player.playActionNode)
    end 
    player.playActionNode:doAction(GameDefine.PLAY_ACT_CHI, callback)
    self.animatingQue:pushBack({
        act = GameDefine.PLAY_ACT_CHI,
        chairID = chairID,
        data = data,
        node = nil,
    }, player.playActionNode)
end 

function PlaybackPlayLayer:getPlayerByUserID(userid)
    for _, player in pairs(self.players) do 
        if player.userid == userid then 
            return player 
        end 
    end 
    return nil 
end 

function PlaybackPlayLayer:initialize(room)
    for _, player in pairs(self.players) do 
        player.playActionNode:finishAction()
    end 
    self:stopAllPlayingAnimas()

    self.room = room
    local rollData = room:getCurRollData()
    self.rollData = rollData 
    self.rollData.curPlayProgress = 0

    if self.scheduleID ~= 0 then 
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(self.scheduleID)
        self.scheduleID = 0
    end 

    self.scheduleID = 0
    self.status = PLAY_STATUS.NONE
    self.waitActionFinished = false

    self.spWatchMark:setVisible(false)

    self:updateProgressStatus()
    self.imgOpBg.btnPause:setVisible(false)
    for _, player in pairs(self.players) do 
        if player.handCardsNode then 
            player.handCardsNode:removeFromParent()
            player.handCardsNode = nil
        end 
        if player.mingCardsNode then 
            player.mingCardsNode:removeFromParent()
            player.mingCardsNode = nil
        end 
        if player.uselessCardsNode then 
            player.uselessCardsNode:removeFromParent()
            player.uselessCardsNode = nil
        end 
        if player.playActionNode then 
            player.playActionNode:removeFromParent()
            player.playActionNode = nil
        end 
    end 
    self.players = {}
    for _, player in pairs(rollData.players) do 
        local handCardsNode = nil
        local mingCardsNode = nil
        local uselessCardsNode = nil 
        local playActionNode = nil
        if player.seatDir == GameDefine.DIR_BOTTOM then 
            handCardsNode = CardsArrayBottom:create()
                                        :addTo(self.panBottom.nodeHandCards)
            mingCardsNode = MingCardsNodeBottom:create()
                                        :addTo(self.panBottom.nodeMingCards)
            uselessCardsNode = UselessCardsNodeBottom:create()
                                        :addTo(self.panBottom.nodeUselessCards)
            playActionNode = PlayActionNode:create({dir = player.seatDir})
                                        :addTo(self.panBottom.nodePlayAction)
        elseif player.seatDir == GameDefine.DIR_RIGHT then 
            handCardsNode = CardsArrayRight:create()
                                        :addTo(self.panRight.nodeHandCards)
            mingCardsNode = MingCardsNodeRight:create()
                                        :addTo(self.panRight.nodeMingCards)
            uselessCardsNode = UselessCardsNodeRight:create()
                                        :addTo(self.panRight.nodeUselessCards)
            playActionNode = PlayActionNode:create({dir = player.seatDir})
                                        :addTo(self.panRight.nodePlayAction)
        elseif player.seatDir == GameDefine.DIR_TOP then 
            handCardsNode = CardsArrayTop:create()
                                        :addTo(self.panTop.nodeHandCards)
            mingCardsNode = MingCardsNodeTop:create()
                                        :addTo(self.panTop.nodeMingCards)
            uselessCardsNode = UselessCardsNodeTop:create()
                                        :addTo(self.panTop.nodeUselessCards)
            playActionNode = PlayActionNode:create({dir = player.seatDir})
                                        :addTo(self.panTop.nodePlayAction)
        elseif player.seatDir == GameDefine.DIR_LEFT then 
            handCardsNode = CardsArrayLeft:create()
                                        :addTo(self.panLeft.nodeHandCards)
            mingCardsNode = MingCardsNodeLeft:create()
                                        :addTo(self.panLeft.nodeMingCards)
            uselessCardsNode = UselessCardsNodeLeft:create()
                                        :addTo(self.panLeft.nodeUselessCards)
            playActionNode = PlayActionNode:create({dir = player.seatDir})
                                        :addTo(self.panLeft.nodePlayAction)
        else
            error(string.format("player %d, invalid seatDir: %d", player.userid, player.seatDir))
        end 
        handCardsNode:setMode(GameDefine.GAME_MODE.DEMO)
        handCardsNode:addCards(player.handCards)
        mingCardsNode:addCards(player.mingCards)
        uselessCardsNode:addCards(player.uselessCards)
        playActionNode:setVisible(false)
        self.players[player.chairID] = {userid = player.userid, 
                chairID = player.chairID,
                handCardsNode = handCardsNode, 
                mingCardsNode = mingCardsNode, 
                uselessCardsNode = uselessCardsNode,
                playActionNode = playActionNode,}
    end 
    local laiZiImgPath = Helper.getCardImgPathOfBottom(rollData.laiZiCardVal)
    local laiZiPiImgPath = Helper.getCardImgPathOfBottom(rollData.laiZiPiCardVal)
    self.imgLaiZi:loadTexture(laiZiImgPath)
    self.imgLaiZiPi:loadTexture(laiZiPiImgPath)
    GameHelper.decorateCardImgWithSpecialMark(self.imgLaiZi, rollData.laiZiCardVal, GameDefine.DIR_BOTTOM)
    GameHelper.decorateCardImgWithSpecialMark(self.imgLaiZiPi, rollData.laiZiPiCardVal, GameDefine.DIR_BOTTOM)
end 

function PlaybackPlayLayer:stopAllPlayingAnimas()
    local function finishAction(act, chairID, data, animaData)
        if act == GameDefine.PLAY_ACT_OUT then 
            local player = self.players[chairID]
            player.handCardsNode:rmvCard(data.cardVal)
            player.uselessCardsNode:addCard(data.cardVal)
            self:availOutCardMark(chairID)
            self.waitActionFinished = false
        elseif act == GameDefine.PLAY_ACT_SYS then 
            local player = self.players[data.whosTurnChairID]
            if data.cardVal ~= 0 then 
                player.handCardsNode:addSysCard(data.cardVal)
            end 
            self.waitActionFinished = false
        elseif act == GameDefine.PLAY_ACT_CHI then 
            local player = self.players[chairID]
            player.mingCardsNode:addCard(data.cardVal, data.chiType, nil)
            if data.chiType == GameDefine.MING_TYPE_CHI_LEFT then 
                player.handCardsNode:rmvCards({data.cardVal + 1, data.cardVal + 2})
            elseif data.chiType == GameDefine.MING_TYPE_CHI_MID then 
                player.handCardsNode:rmvCards({data.cardVal - 1, data.cardVal + 1})
            elseif data.chiType == GameDefine.MING_TYPE_CHI_RIGHT then 
                player.handCardsNode:rmvCards({data.cardVal - 2, data.cardVal - 1})
            else 
                printError("invalid chi type: %d", data.chiType)
            end 
            -- search the last out card player
            local lastOutAct = self.rollData:getLastOutAct()
            assert(lastOutAct)
            local watchPlayer = self.players[lastOutAct.chairID]
            watchPlayer.uselessCardsNode:rmvTheLast(lastOutAct.data.cardVal)
            self:resetOutCardMark()
            self:notifyFansUpdate(chairID)
            self.waitActionFinished = false
        elseif act == GameDefine.PLAY_ACT_GANG_PLAYBACK then 
            local player = self.players[chairID]
            if data.mingType == GameDefine.MING_TYPE_AN_GANG then 
                player.handCardsNode:rmvCards({data.cardVal, data.cardVal, data.cardVal, data.cardVal})
            elseif data.mingType == GameDefine.MING_TYPE_MING_GANG then 
                if data.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_PENG then 
                    player.mingCardsNode:rmvCard(data.cardVal, GameDefine.MING_TYPE_PENG)
                    player.handCardsNode:rmvCards({data.cardVal})
                elseif data.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_WATCH then 
                    player.handCardsNode:rmvCards({data.cardVal, data.cardVal, data.cardVal})
                    -- search the last out card player
                    local lastOutAct = self.rollData:getLastOutAct()
                    assert(lastOutAct)
                    local watchPlayer = self.players[lastOutAct.chairID]
                    watchPlayer.uselessCardsNode:rmvTheLast(lastOutAct.data.cardVal)
    --            elseif data.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_GANG_PAI then 
    --                player.handCardsNode:rmvCards({data.cardVal})
                end 
            end 
            player.mingCardsNode:addCard(data.cardVal, data.mingType, data.subMingType)
            self:resetOutCardMark()
            self:notifyFansUpdate(chairID)
            self.waitActionFinished = false
        elseif act == GameDefine.PLAY_ACT_PENG then 
            local player = self.players[chairID]
            player.mingCardsNode:addCard(data.cardVal, GameDefine.MING_TYPE_PENG, 0)
            player.handCardsNode:rmvCards({data.cardVal, data.cardVal})
            self:resetOutCardMark()
            -- search the last out card player
            local lastOutAct = self.rollData:getLastOutAct()
            assert(lastOutAct)
            local watchPlayer = self.players[lastOutAct.chairID]
            watchPlayer.uselessCardsNode:rmvTheLast(lastOutAct.data.cardVal)
            self:notifyFansUpdate(chairID)
            self.waitActionFinished = false
        elseif act == GameDefine.PLAY_ACT_HU then 
            self.waitActionFinished = false
        elseif act == GameDefine.PLAY_ACT_GUO then 
            self.waitActionFinished = false
        elseif act == GameDefine.PLAY_ACT_ANIMA_DINGLAI then 
            animaData.dingLaiNode:removeFromParent()
            self.waitActionFinished = false
        elseif act == GameDefine.PLAY_ACT_ANIMA_SHAIZI then 
            animaData.sprt1:removeFromParent()
            animaData.sprt2:removeFromParent()
            animaData.animaNode:removeFromParent()
            self.waitActionFinished = false
            self.waitActionFinished = false
        else
            assert(false)
        end
    end 
    while self.animatingQue:size() > 0 do 
        local animaData = self.animatingQue:popFront()
        if animaData.node then 
            xpcall(function()
                animaData.node:removeFromParent()
            end, function(err)
                printError(err)
            end)
        end 
        finishAction(animaData.act, animaData.chairID, animaData.data, animaData)
    end 
end 

function PlaybackPlayLayer:backward(steps)
    local i = self.rollData.curPlayProgress
    local stepsCnt = 0
    local function procBack(actData)
        if actData.act == GameDefine.PLAY_ACT_GUO then 
            return
        elseif actData.act == GameDefine.PLAY_ACT_CHI then 
            local actPlayer = self.players[actData.chairID]
            actPlayer.mingCardsNode:rmvCard(actData.data.cardVal, actData.data.chiType, actData.data.subMingType)
            if actData.data.chiType == GameDefine.MING_TYPE_CHI_LEFT then 
                actPlayer.handCardsNode:addCards({actData.data.cardVal + 1, actData.data.cardVal + 2})
            elseif actData.data.chiType == GameDefine.MING_TYPE_CHI_RIGHT then 
                actPlayer.handCardsNode:addCards({actData.data.cardVal - 1, actData.data.cardVal - 2})
            elseif actData.data.chiType == GameDefine.MING_TYPE_CHI_MID then 
                actPlayer.handCardsNode:addCards({actData.data.cardVal - 1, actData.data.cardVal + 1})
            else 
                assert(false)
            end
            -- search the last out card player
            local lastOutAct = self.rollData:getLastOutAct(i)
            assert(lastOutAct)
            local watchPlayer = self.players[lastOutAct.chairID]
            watchPlayer.uselessCardsNode:addCard(lastOutAct.data.cardVal)
            self:notifyFansUpdate(actData.chairID)
        elseif actData.act == GameDefine.PLAY_ACT_GANG_PLAYBACK then 
            local actPlayer = self.players[actData.chairID]
            actPlayer.mingCardsNode:rmvCard(actData.data.cardVal, actData.data.mingType, actData.data.subMingType)
            if actData.data.mingType == GameDefine.MING_TYPE_AN_GANG then 
                actPlayer.handCardsNode:addCards({actData.data.cardVal, actData.data.cardVal, actData.data.cardVal, actData.data.cardVal})
            else 
                if actData.data.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_GANG_PAI then 
                    actPlayer.handCardsNode:addCard(actData.data.cardVal)
                elseif actData.data.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_PENG then 
                    actPlayer.handCardsNode:addCard(actData.data.cardVal)
                    actPlayer.mingCardsNode:addCard(actData.data.cardVal, GameDefine.MING_TYPE_PENG, nil)
                elseif actData.data.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_WATCH then 
                    actPlayer.handCardsNode:addCards({actData.data.cardVal, actData.data.cardVal, actData.data.cardVal})
                    -- search the last out card player
                    local lastOutAct = self.rollData:getLastOutAct(i)
                    assert(lastOutAct)
                    local watchPlayer = self.players[lastOutAct.chairID]
                    watchPlayer.uselessCardsNode:addCard(lastOutAct.data.cardVal)
                else 
                    assert(false)
                end 
            end 
            self:notifyFansUpdate(actData.chairID)
        elseif actData.act == GameDefine.PLAY_ACT_PENG then 
            local actPlayer = self.players[actData.chairID]
            actPlayer.mingCardsNode:rmvCard(actData.data.cardVal, GameDefine.MING_TYPE_PENG, nil)
            actPlayer.handCardsNode:addCards({actData.data.cardVal, actData.data.cardVal})
            -- search the last out card player
            local lastOutAct = self.rollData:getLastOutAct(i)
            assert(lastOutAct)
            local watchPlayer = self.players[lastOutAct.chairID]
            watchPlayer.uselessCardsNode:addCard(lastOutAct.data.cardVal)
            self:notifyFansUpdate(actData.chairID)
        elseif actData.act == GameDefine.PLAY_ACT_HU then 
            return 
        elseif actData.act == GameDefine.PLAY_ACT_SYS then 
            local actPlayer = self.players[actData.data.whosTurnChairID]
            if actData.data.cardVal and actData.data.cardVal > 0 then 
                actPlayer.handCardsNode:rmvCard(actData.data.cardVal)
            end 
        elseif actData.act == GameDefine.PLAY_ACT_OUT then 
            local actPlayer = self.players[actData.chairID]
            actPlayer.uselessCardsNode:rmvTheLast(actData.data.cardVal)
            actPlayer.handCardsNode:addCard(actData.data.cardVal)
        elseif actData.act == GameDefine.PLAY_ACT_TING then 

        elseif actData.act == GameDefine.PLAY_ACT_ANIMA_DINGLAI then 
            --empty implementation
        elseif actData.act == GameDefine.PLAY_ACT_ANIMA_SHAIZI then 
            --empty implementation

        else 
            assert(false)
        end 
    end 
    while i > 0 and stepsCnt < steps do 
        local actData = self.rollData.actionsQue[i] 
        procBack(actData)
        i = i - 1
        stepsCnt = stepsCnt + 1
    end 
    self.rollData.curPlayProgress = i
    self:updateProgressStatus()
end 

function PlaybackPlayLayer:forward(steps)
    local i = self.rollData.curPlayProgress + 1
    local stepsCnt = 0
    local function procForward(actData)
        if actData.act == GameDefine.PLAY_ACT_GUO then 
            return
        elseif actData.act == GameDefine.PLAY_ACT_CHI then 
            local actPlayer = self.players[actData.chairID]
            actPlayer.mingCardsNode:addCard(actData.data.cardVal, actData.data.chiType, nil)
            if actData.data.chiType == GameDefine.MING_TYPE_CHI_LEFT then 
                actPlayer.handCardsNode:rmvCards({actData.data.cardVal + 1, actData.data.cardVal + 2})
            elseif actData.data.chiType == GameDefine.MING_TYPE_CHI_RIGHT then 
                actPlayer.handCardsNode:rmvCards({actData.data.cardVal - 1, actData.data.cardVal - 2})
            elseif actData.data.chiType == GameDefine.MING_TYPE_CHI_MID then 
                actPlayer.handCardsNode:rmvCards({actData.data.cardVal - 1, actData.data.cardVal + 1})
            else 
                assert(false)
            end
            -- search the last out card player
            local lastOutAct = self.rollData:getLastOutAct(i)
            assert(lastOutAct)
            local watchPlayer = self.players[lastOutAct.chairID]
            watchPlayer.uselessCardsNode:rmvTheLast(lastOutAct.data.cardVal)
            self:notifyFansUpdate(actData.chairID)
        elseif actData.act == GameDefine.PLAY_ACT_GANG_PLAYBACK then 
            local actPlayer = self.players[actData.chairID]
            actPlayer.mingCardsNode:addCard(actData.data.cardVal, actData.data.mingType, actData.data.subMingType)
            if actData.data.mingType == GameDefine.MING_TYPE_AN_GANG then 
                actPlayer.handCardsNode:rmvCards({actData.data.cardVal, actData.data.cardVal, actData.data.cardVal, actData.data.cardVal})
            else 
                if actData.data.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_GANG_PAI then 
                    actPlayer.handCardsNode:rmvCard(actData.data.cardVal)
                elseif actData.data.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_PENG then 
                    actPlayer.handCardsNode:rmvCard(actData.data.cardVal)
                    actPlayer.mingCardsNode:rmvCard(actData.data.cardVal, GameDefine.MING_TYPE_PENG, nil)
                elseif actData.data.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_WATCH then 
                    actPlayer.handCardsNode:rmvCards({actData.data.cardVal, actData.data.cardVal, actData.data.cardVal})
                    -- search the last out card player
                    local lastOutAct = self.rollData:getLastOutAct(i)
                    assert(lastOutAct)
                    local watchPlayer = self.players[lastOutAct.chairID]
                    watchPlayer.uselessCardsNode:rmvTheLast(lastOutAct.data.cardVal)
                else 
                    assert(false)
                end 
            end 
            self:notifyFansUpdate(actData.chairID)
        elseif actData.act == GameDefine.PLAY_ACT_PENG then 
            local actPlayer = self.players[actData.chairID]
            actPlayer.mingCardsNode:addCard(actData.data.cardVal, GameDefine.MING_TYPE_PENG, nil)
            actPlayer.handCardsNode:rmvCards({actData.data.cardVal, actData.data.cardVal})
            -- search the last out card player
            local lastOutAct = self.rollData:getLastOutAct(i)
            assert(lastOutAct)
            local watchPlayer = self.players[lastOutAct.chairID]
            watchPlayer.uselessCardsNode:rmvTheLast(lastOutAct.data.cardVal)
            self:notifyFansUpdate(actData.chairID)
        elseif actData.act == GameDefine.PLAY_ACT_HU then 
            return 
        elseif actData.act == GameDefine.PLAY_ACT_SYS then 
            local actPlayer = self.players[actData.data.whosTurnChairID]
            if actData.data.cardVal and actData.data.cardVal > 0 then 
                actPlayer.handCardsNode:addCard(actData.data.cardVal)
            end 
        elseif actData.act == GameDefine.PLAY_ACT_OUT then 
            local actPlayer = self.players[actData.chairID]
            actPlayer.uselessCardsNode:addCard(actData.data.cardVal)
            actPlayer.handCardsNode:rmvCard(actData.data.cardVal)
        elseif actData.act == GameDefine.PLAY_ACT_TING then 

        elseif actData.act == GameDefine.PLAY_ACT_ANIMA_DINGLAI then 
            --empty implementation
        elseif actData.act == GameDefine.PLAY_ACT_ANIMA_SHAIZI then 
            --empty implementation

        else 
            assert(false)
        end 
    end 
    printInfo("Progress: %d", i)
    while i <= #self.rollData.actionsQue and stepsCnt < steps do 
        local actData = self.rollData.actionsQue[i] 
        procForward(actData)
        i = i + 1
        stepsCnt = stepsCnt + 1
    end 
    self.rollData.curPlayProgress = i - 1
    self:updateProgressStatus()
end 

function PlaybackPlayLayer:replay()
    self:initialize(self.room)
    self:play()
end 

function PlaybackPlayLayer:onClick_btnBackward(target)
    self.waitActionFinished = false
    for _, player in pairs(self.players) do 
        player.playActionNode:finishAction()
    end 
    self:stopAllPlayingAnimas()

    local oldStatus = self.status
    self:stop()
    self:backward(3)
    if oldStatus == PLAY_STATUS.PLAYING then 
        self:play()
    elseif oldStatus == PLAY_STATUS.PAUSED then
        self:play()
        self:pause()
    else
        self.status = oldStatus
    end 
end 

function PlaybackPlayLayer:onClick_btnForward(target)
    self.waitActionFinished = false
    for _, player in pairs(self.players) do 
        player.playActionNode:finishAction()
    end 
    self:stopAllPlayingAnimas()

    local oldStatus = self.status
    self:stop()
    self:forward(3)
    if oldStatus == PLAY_STATUS.PLAYING then 
        self:play()
    elseif oldStatus == PLAY_STATUS.PAUSED then
        self:play()
        self:pause()
    else
        self.status = oldStatus
    end 
end 

function PlaybackPlayLayer:onClick_btnPause(target)
    self:pause()
end 

function PlaybackPlayLayer:onClick_btnPlay(target)
    if self.rollData.curPlayProgress >= #self.rollData.actionsQue then 
        self:initialize(self.room)
    end 
    self:play()
end 

function PlaybackPlayLayer:onClick_btnGoBack(target)
    UIManager:goBack()
end 

return PlaybackPlayLayer
--endregion
