--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local GamePlayLayer = class("GamePlayLayer", cc.Layer)

local CardsArrayBottom = require("app.modules.game.CardsArrayBottom")
local CardsArrayRight = require("app.modules.game.CardsArrayRight")
local CardsArrayTop = require("app.modules.game.CardsArrayTop")
local CardsArrayLeft = require("app.modules.game.CardsArrayLeft")
local GameDefine = require("app.modules.game.GameDefine")
local PlayAction = require("app.modules.game.PlayAction")
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

local scheduler = cc.Director:getInstance():getScheduler()

function GamePlayLayer:ctor()
    local uiNode = require("GameScene.GamePlayLayer"):create().root:addTo(self)
    
    util.bindUINodes(uiNode, self, self)

    self.spWatchMark:setVisible(false)

    self.nodePlayAction = PlayAction:create():addTo(self)--.panBottom.nodePlayAction)
    self.nodePlayAction:setVisible(false)

    self.nodeGameTip = GameTipNode:create():addTo(self.nodeGameTip)

    self.players = {} --[userid] = {userid = ?, handCardsNode = ?, mingCardsNode = ?, uselessCardsNode = ?},...
    self.outCardNode = nil 
    self.outGangCardNode = nil 
    self.opCardNode = nil 

    self:enableNodeEvents()

    if GameCache.roomStatus ~= GameDefine.enum_GameStatus.GS_PLAYING then 
        self:setVisible(false)
    end 

    --start animation coroutine
    self.animaQue = List()
    self.animaNodesCache = List()
    self.canNextAnima = true
    self.scheduleID = 0
    self.scheduleID = scheduler:scheduleScriptFunc(function()
        self:__animaSchedule()
    end, 0, false)

    Event.register("MS_OUT_CARD", self, "MS_OUT_CARD")
    Event.register("MS_SYSTEM_DISPATCH_CARD", self, "MS_SYSTEM_DISPATCH_CARD")
    Event.register("MS_ACTION_GUO", self, "MS_ACTION_GUO")
    Event.register("MS_ACTION_PENG", self, "MS_ACTION_PENG")
    Event.register("MS_ACTION_HU", self, "MS_ACTION_HU")
    Event.register("MS_ACTION_GANG", self, "MS_ACTION_GANG")
    Event.register("MS_ACTION_CHI", self, "MS_ACTION_CHI")
    Event.register("MS_GAME_START", self, "MS_GAME_START")
    Event.register("MS_GAME_OVER", self, "MS_GAME_OVER")
    Event.register("MS_PLAYER_TING", self, "MS_PLAYER_TING")
    Event.register("MS_HAIDILAO", self, "MS_HAIDILAO")
    
    Event.register("OUT_CARD_RESET", self, "OUT_CARD_RESET")
    Event.register("OUT_CARD_AVAILABLE", self, "OUT_CARD_AVAILABLE")
    Event.register("PLAY_ACTION_GANG", self, "PLAY_ACTION_GANG")
    Event.register("UPDATE_ACTION", self, "UPDATE_ACTION")
    Event.register("NEW_TURN", self, "NEW_TURN")

    Event.register("DO_ANIMATION", self, "DO_ANIMATION")
end 

function GamePlayLayer:onEnter()
end 

function GamePlayLayer:onExit()
    Event.unregister("MS_OUT_CARD", self, "MS_OUT_CARD")
    Event.unregister("MS_SYSTEM_DISPATCH_CARD", self, "MS_SYSTEM_DISPATCH_CARD")
    Event.unregister("MS_ACTION_GUO", self, "MS_ACTION_GUO")
    Event.unregister("MS_ACTION_PENG", self, "MS_ACTION_PENG")
    Event.unregister("MS_ACTION_HU", self, "MS_ACTION_HU")
    Event.unregister("MS_ACTION_GANG", self, "MS_ACTION_GANG")
    Event.unregister("MS_ACTION_CHI", self, "MS_ACTION_CHI")
    Event.unregister("MS_GAME_START", self, "MS_GAME_START")
    Event.unregister("MS_GAME_OVER", self, "MS_GAME_OVER")
    Event.unregister("MS_PLAYER_TING", self, "MS_PLAYER_TING")
    Event.unregister("MS_HAIDILAO", self, "MS_HAIDILAO")

    Event.unregister("OUT_CARD_RESET", self, "OUT_CARD_RESET")
    Event.unregister("OUT_CARD_AVAILABLE", self, "OUT_CARD_AVAILABLE")
    Event.unregister("PLAY_ACTION_GANG", self, "PLAY_ACTION_GANG")
    Event.unregister("UPDATE_ACTION", self, "UPDATE_ACTION")
    Event.unregister("NEW_TURN", self, "NEW_TURN")
    
    Event.unregister("DO_ANIMATION", self, "DO_ANIMATION")

    scheduler:unscheduleScriptEntry(self.scheduleID)
end 

function GamePlayLayer:__animaSchedule()
    if not self.canNextAnima then 
        return 
    end
    if self.animaQue:size() == 0 then 
        return 
    end 
    local animaData = self.animaQue:popFront()
    self.canNextAnima = false
    --UIManager:freeze()
    self:__doAnima(animaData)
end 

function GamePlayLayer:__doAnima(animaData)
    if animaData.animaType == GameDefine.ANIMA_TYPE_OUT_CARD then 
        printInfo("DO PLAY: ANIMA_TYPE_OUT_CARD")
        self:__doAnimaOutCard(animaData.data)
    elseif animaData.animaType == GameDefine.ANIMA_TYPE_CHI then 
        printInfo("DO PLAY: ANIMA_TYPE_CHI")
        self:__doAnimaChi(animaData.data)
    elseif animaData.animaType == GameDefine.ANIMA_TYPE_PENG then 
        printInfo("DO PLAY: ANIMA_TYPE_PENG")
        self:__doAnimaPeng(animaData.data)
    elseif animaData.animaType == GameDefine.ANIMA_TYPE_GANG then 
        printInfo("DO PLAY: ANIMA_TYPE_GANG")
        self:__doAnimaGang(animaData.data)
    elseif animaData.animaType == GameDefine.ANIMA_TYPE_GUO then 
        printInfo("DO PLAY: ANIMA_TYPE_GUO")
        self:__doAnimaGuo(animaData.data)
    elseif animaData.animaType == GameDefine.ANIMA_TYPE_HU then 
        printInfo("DO PLAY: ANIMA_TYPE_HU")
        self:__doAnimaHu(animaData.data)
    elseif animaData.animaType == GameDefine.ANIMA_TYPE_SYS_DISPATCH_CARD then 
        printInfo("DO PLAY: ANIMA_TYPE_SYS_DISPATCH_CARD")
        self:__doAnimaSysDispatchCard(animaData.data)
    elseif animaData.animaType == GameDefine.ANIMA_TYPE_OP_OUT_CARD then 
        printInfo("DO PLAY: ANIMA_TYPE_OP_OUT_CARD")
        self:__doAnimaOpOutCard(animaData.data)
    elseif animaData.animaType == GameDefine.ANIMA_TYPE_OP_OUT_GANG_PAI then 
        printInfo("DO PLAY: ANIMA_TYPE_OP_OUT_GANG_PAI")
        self:__doAnimaOpOutGangPai(animaData.data)
    elseif animaData.animaType == GameDefine.ANIMA_TYPE_HAIDILAO then 
        printInfo("DO PLAY: ANIMA_TYPE_HAIDILAO")
        self:__doAnimaHaiDiLao(animaData.data)
    elseif animaData.animaType == GameDefine.ANIMA_TYPE_GAMEOVER then 
        printInfo("DO PLAY: ANIMA_TYPE_GAMEOVER")
        self:__doAnimaGameOver(animaData.data)
    elseif animaData.animaType == GameDefine.ANIMA_TYPE_DINGLAI then 
        printInfo("DO PLAY: ANIMA_TYPE_DINGLAI")
        self:__doAnimaDingLai(animaData.data)
    elseif animaData.animaType == GameDefine.ANIMA_TYPE_SHAIZI then 
        printInfo("DO PLAY: ANIMA_TYPE_SHAIZI")
        self:__doAnimaShaiZi(animaData.data)
    else
        assert(false)
    end 
end

function GamePlayLayer:__doAnimaOpOutCard(data)
    self.canNextAnima = true
end

function GamePlayLayer:__doAnimaOutCard(data)
    local player = self.players[data.userid]
    local node = player.uselessCardsNode:createOutCardNode(data.cardVal)
    local newNodePos = WidgetExt.convertSpace(player.handCardsNode, self)
    node:addTo(self)
    node:setPosition(newNodePos)
    node:setScale(0)
    local nodeSz = node:getContentSize()
    local dstSz = player.uselessCardsNode:getTheNextCardSize()
    dstSz = WidgetExt.getDisplaySizeOf(player.uselessCardsNode, dstSz)
    local dstScale = cc.p(dstSz.width / nodeSz.width, dstSz.height / nodeSz.height)
    local pos = player.uselessCardsNode:getTheNextCardPosition()
    local localPos = self:convertToNodeSpace(pos)
    local act = cc.Spawn:create(
        cc.FadeIn:create(1.0),
        cc.Sequence:create(
            cc.ScaleTo:create(0, 1.5, 1.5, 1.0),
            cc.DelayTime:create(0.7),
            cc.ScaleTo:create(0.2, dstScale.x, dstScale.y, 1)),
        cc.Sequence:create(
            cc.MoveTo:create(0, cc.p(display.cx, display.cy)),
            cc.DelayTime:create(0.7),
            cc.MoveTo:create(0.2, localPos),
            cc.CallFunc:create(function()
                self.animaNodesCache:popByIndex(node)
                node:removeFromParent()
                player.uselessCardsNode:addCard(data.cardVal)
                UIManager:unblock()
                self.canNextAnima = true
                self:enableActionsOp(false)
                self:enableOutCardMark(true, player.userid)
            end))
        )
    node:runAction(act)
    Helper.playCardSound(player.gender, data.cardVal)
    if player.userid == PlayerCache.userid then 
        player.handCardsNode:rmvCard(data.cardVal)
    else 
        player.handCardsNode:decCardsNum(1)
    end 
    self.animaNodesCache:pushBack({
        node = node,
    }, node)
end 

function GamePlayLayer:__doAnimaChi(data)
    local player = self.players[data.userid]
    assert(player)
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
    if player.userid == PlayerCache.userid then 
        if data.chiType == GameDefine.MING_TYPE_CHI_LEFT then 
            player.handCardsNode:rmvCards({data.cardVal + 1, data.cardVal + 2})
        elseif data.chiType == GameDefine.MING_TYPE_CHI_MID then 
            player.handCardsNode:rmvCards({data.cardVal - 1, data.cardVal + 1})
        elseif data.chiType == GameDefine.MING_TYPE_CHI_RIGHT then 
            player.handCardsNode:rmvCards({data.cardVal - 2, data.cardVal - 1})
        else 
            printError("invalid chi type: %d", data.chiType)
        end 
    else 
        player.handCardsNode:decCardsNum(2)
    end 
    local watchPlayer = self.players[data.sponsorUserID]
    watchPlayer.uselessCardsNode:rmvTheLast(data.cardVal)
    showEft()
    UIManager:unblock()
    self.canNextAnima = true
    self:enableOutCardMark(false, 0)
    self:enableActionsOp(false)
--    self:newTurn(player.userid)
    Event.dispatch("UPDATE_FANS", {userid = data.userid})
end 

function GamePlayLayer:__doAnimaPeng(data)
    local player = self.players[data.userid]
    assert(player)
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
    player.mingCardsNode:addCard(data.cardVal, GameDefine.MING_TYPE_PENG, 0)
    if player.userid == PlayerCache.userid then 
        player.handCardsNode:rmvCards({data.cardVal, data.cardVal})
    else 
        player.handCardsNode:decCardsNum(2)
    end 

    local watchPlayer = self.players[data.sponsorUserID]
    watchPlayer.uselessCardsNode:rmvTheLast(data.cardVal)
    UIManager:unblock()
    showEft()
    self.canNextAnima = true
    self:enableOutCardMark(false, 0)
    self:enableActionsOp(false)
--    self:newTurn(player.userid)
    Event.dispatch("UPDATE_FANS", {userid = data.userid})
end 

function GamePlayLayer:__doAnimaOpOutGangPai(data)
    self.canNextAnima = true
end

function GamePlayLayer:__doAnimaGang(data)
    local player = self.players[data.userid]
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
    if data.mingType == GameDefine.MING_TYPE_AN_GANG then 
        if player.userid == PlayerCache.userid then 
            player.handCardsNode:rmvCards({data.cardVal, data.cardVal, data.cardVal, data.cardVal})
        else 
            player.handCardsNode:decCardsNum(4)
        end 
    elseif data.mingType == GameDefine.MING_TYPE_MING_GANG then 
        if data.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_PENG then 
            player.mingCardsNode:rmvCard(data.cardVal, GameDefine.MING_TYPE_PENG)
            if player.userid == PlayerCache.userid then 
                player.handCardsNode:rmvCards({data.cardVal})
            else 
                player.handCardsNode:decCardsNum(1)
            end 
        elseif data.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_WATCH then 
            local watchPlayer = self.players[data.sponsorUserID]
            watchPlayer.uselessCardsNode:rmvTheLast(data.cardVal)
            if player.userid == PlayerCache.userid then 
                player.handCardsNode:rmvCards({data.cardVal, data.cardVal, data.cardVal})
            else 
                player.handCardsNode:decCardsNum(3)
            end 
        elseif data.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_GANG_PAI then 
            if player.userid == PlayerCache.userid then 
                player.handCardsNode:rmvCards({data.cardVal})
            else 
                player.handCardsNode:decCardsNum(1)
            end 
        end 
    end 
    player.mingCardsNode:addCard(data.cardVal, data.mingType, data.subMingType)
    UIManager:unblock()
    showEft()
    --UIManager:unfreeze()
    self.canNextAnima = true
    Event.dispatch("UPDATE_FANS", {userid = data.userid})

    self:enableOutCardMark(false, 0)
    self:enableActionsOp(false)
--    self:newTurn(player.userid)
end 

function GamePlayLayer:__doAnimaGuo(data)
    local player = self.players[data.userid]
    assert(player)
    self.canNextAnima = true
    UIManager:unblock()
    --UIManager:unfreeze()
    self:enableActionsOp(false)
end 

function GamePlayLayer:__doAnimaHu(data)
    --胡牌并不取消block, 直到收到gameOver消息
    local player = self.players[data.userid]
    assert(player)
    local function doEft(pos, eftPath)
        local spEft = cc.Sprite:create(eftPath)
        spEft:setCascadeOpacityEnabled(true)
        local sz = spEft:getContentSize()
        local spBg = cc.Sprite:create("GameScene/bg-donghuadapaidonghuadi.png")
            :addTo(spEft, -1)
            :setPosition(cc.p(sz.width * 0.5, sz.height * 0.5))
--            local pos = WidgetExt.convertSpace(player.uselessCardsNode:getParent(), self)
        spEft:addTo(self)
        spEft:setPosition(pos)
        local act = cc.Spawn:create(
            cc.RotateBy:create(1.0, -30, -30),
            cc.Sequence:create(
                cc.DelayTime:create(2.0),
                cc.CallFunc:create(function()
                    self.animaNodesCache:popByIndex(spEft)
                    self.canNextAnima = true
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
        self.animaNodesCache:pushBack({
            node = spEft,
        }, spEft)
    end 
    local function showEft()
        Helper.playSoundHu(player.gender, data.huType == GameDefine.HU_TYPE_ZI_MO)
        if data.huType == GameDefine.HU_TYPE_DIAN_PAO then 
            local eftPath1 = "GameScene/bt-donghuadianpao.png"
            local sponsorData = GameCache.playersByChair[data.sponsorChairID]
            local sponsor = self.players[sponsorData.userid]
            local pos1 = WidgetExt.convertSpace(sponsor.uselessCardsNode:getParent(), self)
            doEft(pos1, eftPath1)
            local eftPath2 = "GameScene/bt-donghuahu.png"
            local pos2 = WidgetExt.convertSpace(player.uselessCardsNode:getParent(), self)
            doEft(pos2, eftPath2)
        elseif data.huType == GameDefine.HU_TYPE_HAI_DI_LAO then 
            local eftPath = "GameScene/bt-donghuahaidilaoyue.png"
            local pos = WidgetExt.convertSpace(player.uselessCardsNode:getParent(), self)
            doEft(pos, eftPath)
        elseif data.huType == GameDefine.HU_TYPE_QIANG_GANG then 
            local eftPath1 = "GameScene/bt-donghuaqianggan.png"
            local sponsorData = GameCache.playersByChair[data.sponsorChairID]
            local sponsor = self.players[sponsorData.userid]
            local pos1 = WidgetExt.convertSpace(sponsor.uselessCardsNode:getParent(), self)
            doEft(pos1, eftPath1)
            local eftPath2 = "GameScene/bt-donghuahu.png"
            local pos2 = WidgetExt.convertSpace(player.uselessCardsNode:getParent(), self)
            doEft(pos2, eftPath2)
        elseif data.huType == GameDefine.HU_TYPE_ZI_MO then 
            local eftPath = "GameScene/bt-donghuazhimo.png"
            local pos = WidgetExt.convertSpace(player.uselessCardsNode:getParent(), self)
            doEft(pos, eftPath)
        end 
    end 
    showEft()
    self:enableOutCardMark(false, 0)
    self:enableActionsOp(false)
end 

function GamePlayLayer:__doAnimaSysDispatchCard(data)
    if data.cardVal ~= 0 then
        local playerData = GameCache.playersByChair[data.whosTurnChairID]
        local player = self.players[playerData.userid]
        local myself = GameCache.players[PlayerCache.userid]
        
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
                    self.animaNodesCache:popByIndex(node)
                    node:removeFromParent()
                    if data.whosTurnChairID == myself.chairID then --need reset
                        player.handCardsNode:addSysCard(data.cardVal)
                    else 
                        player.handCardsNode:incCardsNum(1)
                    end 
                    self.canNextAnima = true
                    --UIManager:unfreeze()
                    if data.actions and #data.actions > 0 then 
                        local myselfData = GameCache.players[PlayerCache.userid]
                        if data.whosTurnChairID == myselfData.chairID then 
                            self:enableActionsOp(true)
                        end 
                    end 
                    self:newTurn(player.userid, data.actionWaitTime)
                    self:updateProgress({
                        cardsRemainCnt = data.cardsRemainCnt,
                        rollsCnt = GameCache.rollsCnt,
                        rolls = GameCache.rolls,
                    })
                end)
            )
        )
        node:runAction(act)
        self.animaNodesCache:pushBack({
            node = node,
        }, node)
    else
        local playerData = GameCache.playersByChair[data.whosTurnChairID]
        self.canNextAnima = true
        --UIManager:unfreeze()
        if playerData.userid == PlayerCache.userid then 
            if data.actions and #data.actions > 0 then 
                local myselfData = GameCache.players[PlayerCache.userid]
                if data.whosTurnChairID == myselfData.chairID then 
                    self:enableActionsOp(true)
                end 
            end
        end 
        self:newTurn(playerData.userid, data.actionWaitTime)
    end 

end 

function GamePlayLayer:__doAnimaHaiDiLao(data)
    local varSet = false
    for _, playCard in ipairs(data.cards) do 
        local playerData = GameCache.playersByChair[playCard.chairID]
        local player = self.players[playerData.userid]
        
        local pos = player.handCardsNode:getSysCardPosition()
        pos = self:convertToNodeSpace(pos)
        local node = player.handCardsNode:createCardNode(playCard.cardVal)
        node:setPosition(cc.p(display.cx, display.cy))
        node:setScale(0)
        node:addTo(self)
        local act = cc.Spawn:create(
            cc.FadeIn:create(0.1),
            cc.MoveTo:create(0.3, pos),
            cc.Sequence:create(
                cc.ScaleTo:create(0.3, 1.0, 1.0, 1.0),
                cc.CallFunc:create(function()
                    node:setVisible(false)
                    if player.userid == PlayerCache.userid then 
                        player.handCardsNode:addSysCard(playCard.cardVal)
                    else 
                        player.handCardsNode:incCardsNum(1)
                    end 
                end),
                cc.DelayTime:create(1.0),
                cc.CallFunc:create(function()
                    self.animaNodesCache:popByIndex(node)
                    node:removeFromParent()
                    if not varSet then 
                        self.canNextAnima = true
                        self:updateProgress({
                            cardsRemainCnt = 0,
                            rollsCnt = GameCache.rollsCnt,
                            rolls = GameCache.rolls,
                        })
                        --UIManager:unfreeze()
                    end 
                end)
            )
        )
        node:runAction(act)
        self.animaNodesCache:pushBack({
            node = node,
        }, node)
    end
end

function GamePlayLayer:__doAnimaGameOver(data)
    UIManager:replaceCurrent(Define.SCENE_GAME, "app.modules.balance.BalanceLayer", UIManager.UITYPE_FULL_SCREEN)

    UIManager:unblock()
    self.canNextAnima = true
    --UIManager:unfreeze()
end

function GamePlayLayer:__doAnimaDingLai(data)
    local dingLai
    local function callback()
        self.canNextAnima = true
        self.animaNodesCache:popByIndex(dingLai)
    end 
    dingLai = require("app.modules.game.DingLaiLayer")
        :create({
            cardVal = data.laiZiCardVal,
            callback = callback,
        })
        :addTo(self)
    self.animaNodesCache:pushBack({
        node = dingLai,
    }, dingLai)
end

function GamePlayLayer:__doAnimaShaiZi(data)
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
                self.animaNodesCache:popByIndex(sprt1)
                self.animaNodesCache:popByIndex(sprt2)
                self.animaNodesCache:popByIndex(animaNode)
                sprt1:removeFromParent()
                sprt2:removeFromParent()
                animaNode:removeFromParent()
                self.canNextAnima = true
            end)
        )
        animaNode:runAction(act)
        self.animaNodesCache:pushBack({
            node = sprt1,
        }, sprt1)
        self.animaNodesCache:pushBack({
            node = sprt2,
        }, sprt2)
        self.animaNodesCache:pushBack({
            node = animaNode,
        }, animaNode)
    end 
    showEft()
    --UIManager:unfreeze()
end

function GamePlayLayer:DO_ANIMATION(data)
    self.animaQue:pushBack(data)
end

function GamePlayLayer:enableActionsOp(enabled)
    local myself = self.players[PlayerCache.userid]
    myself.handCardsNode:setTouchEnabled(false)
    self.nodePlayAction:setVisible(false)
    if not enabled then 
        return
    end 
    if GameCache.actions and #GameCache.actions == 1 and 
        GameCache.actions[1] == GameDefine.PLAY_ACT_OUT then 
        myself.handCardsNode:setTouchEnabled(true)
        return
    end 
    self.nodePlayAction:setVisible(true)
    local enabledActions = {}
    for _, actVal in ipairs(GameCache.actions) do 
        table.insert(enabledActions, actVal)
    end 
    local myself = self.players[PlayerCache.userid]
    self.nodePlayAction:enableActions(enabledActions)
end 

function GamePlayLayer:newTurn(userid, actionWaitTime)
    local player = GameCache.players[userid]
    assert(player)
    self.nodeGameTip:newTimer(actionWaitTime)
    self.nodeGameTip:setDir(player.seatDir)
end

function GamePlayLayer:moreTipTime()
    self.nodeGameTip:newTimer(15)
end 

function GamePlayLayer:updateProgress(data)
    self.nodeGameTip:setProgress({
        cardsRemainCnt = data.cardsRemainCnt, 
        rollsCnt = data.rollsCnt + 1, 
        totalRolls = data.rolls,
    })
end 

function GamePlayLayer:enableOutCardMark(enabled, forWhomUserID)
    self.spWatchMark:setVisible(enabled)
    if enabled then 
        local player = self.players[forWhomUserID]
        assert(player)
        local rawPos = player.uselessCardsNode:getLastCardPosition()
        local pos = self:convertToNodeSpace(rawPos)
        assert(pos)
        pos.y = pos.y + 30
        self.spWatchMark:stopAllActions()
        self.spWatchMark:setPosition(pos)
        self.spWatchMark:setVisible(true)
        local act = cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.7, cc.p(0, 30)),
                                                                cc.MoveBy:create(0.7, cc.p(0, -30))))
        self.spWatchMark:runAction(act)
    end 
end 

function GamePlayLayer:MS_GAME_START(data)
    self:initialize()
    self:setVisible(true)
    --色子
    Event.dispatch("DO_ANIMATION", {
        animaType = GameDefine.ANIMA_TYPE_SHAIZI,
        data = {
            shaiZi1Val = GameCache.shaiZi1Val,
            shaiZi2Val = GameCache.shaiZi2Val,
        }
    })
    --定赖
    Event.dispatch("DO_ANIMATION", {
        animaType = GameDefine.ANIMA_TYPE_DINGLAI,
        data = {
            laiZiCardVal = GameCache.laiZiCardVal,
        }
    })
end

function GamePlayLayer:MS_GAME_OVER(data)
    Event.dispatch("DO_ANIMATION", {
        animaType = GameDefine.ANIMA_TYPE_GAMEOVER,
        data = {
        }
    })
end 

function GamePlayLayer:MS_PLAYER_TING(data)
    --TODO 暂时先播放个声音先
    UIManager:unblock()
    local player = self.players[data.userid]
    Helper.playSoundTing(player.gender)
end 

function GamePlayLayer:MS_HAIDILAO(data)
    local cards = {}
    for _, playCard in ipairs(data.cards) do 
        table.insert(cards, {
            chairID = playCard.chairID,
            cardVal = playCard.cardVal,
        })
    end
    Event.dispatch("DO_ANIMATION", {
        animaType = GameDefine.ANIMA_TYPE_HAIDILAO,
        data = {
            userid = data.userid,
            node = nil,
            cards = cards,
        }
    })
end 

function GamePlayLayer:MS_SYSTEM_DISPATCH_CARD(data)
    local actions = {}
    for _, actVal in ipairs(data.actions or {}) do 
        table.insert(actions, actVal)
    end 
    Event.dispatch("DO_ANIMATION", {
        animaType = GameDefine.ANIMA_TYPE_SYS_DISPATCH_CARD,
        data = {
            node = nil,
            whosTurnChairID = data.whosTurnChairID,
            cardVal = data.cardVal,
            actions = actions,
            cardsRemainCnt = data.cardsRemainCnt,
            actionWaitTime = data.actionWaitTime,
        }
    })
end 

function GamePlayLayer:MS_OUT_CARD(data)
    if not data.err or data.err == 0 then 
        Event.dispatch("DO_ANIMATION", {
            animaType = GameDefine.ANIMA_TYPE_OUT_CARD,
            data = {
                userid = data.userid,
                node = nil,
                cardVal = data.cardVal,
            }
        })
    else 
        UIManager:unblock()
    end 
end

function GamePlayLayer:MS_ACTION_GUO(data)
    if not data.err or data.err == 0 then 
        Event.dispatch("DO_ANIMATION", {
            animaType = GameDefine.ANIMA_TYPE_GUO,
            data = {
                userid = data.userid,
                node = nil,
            }
        })
    else 
        UIManager:unblock()
    end 
end 

function GamePlayLayer:MS_ACTION_PENG(data)
    if not data.err or data.err == 0 then 
        Event.dispatch("DO_ANIMATION", {
            animaType = GameDefine.ANIMA_TYPE_PENG,
            data = {
                userid = data.userid,
                node = nil,
                cardVal = data.cardVal,
                sponsorUserID = data.sponsorUserID,
            }
        })
    else 
        UIManager:unblock()
    end 
end 

function GamePlayLayer:MS_ACTION_HU(data)
    if not data.err or data.err == 0 then 
        Event.dispatch("DO_ANIMATION", {
            animaType = GameDefine.ANIMA_TYPE_HU,
            data = {
                userid = data.userid,
                node = nil,
                huType = data.huType,
                sponsorChairID = data.sponsorChairID,
            }
        })
    else 
        UIManager:unblock()
    end 
end 

function GamePlayLayer:MS_ACTION_GANG(data)
    if not data.err or data.err == 0 then 
        Event.dispatch("DO_ANIMATION", {
            animaType = GameDefine.ANIMA_TYPE_GANG,
            data = {
                userid = data.userid,
                node = nil,
                cardVal = data.cardVal,
                mingType = data.mingType,
                subMingType = data.subMingType,
                sponsorUserID = data.sponsorUserID,
            }
        })
    else 
        UIManager:unblock()
    end 
end 

function GamePlayLayer:MS_ACTION_CHI(data)
    if not data.err or data.err == 0 then 
        Event.dispatch("DO_ANIMATION", {
            animaType = GameDefine.ANIMA_TYPE_CHI,
            data = {
                userid = data.userid,
                node = nil,
                cardVal = data.cardVal,
                chiType = data.chiType,
                sponsorUserID = data.sponsorUserID,
            }
        })
    else 
        UIManager:unblock()
    end 
end 

function GamePlayLayer:clearAllAnimations()
    while self.animaQue:size() > 0 do 
        self.animaQue:popFront()
    end 
    while self.animaNodesCache:size() > 0 do 
        local animating = self.animaNodesCache:popFront()
        animating.node:removeFromParent()
    end 
end 

function GamePlayLayer:initialize()
    self:clearAllAnimations()
    self.canNextAnima = true 

    self.nodePlayAction:setVisible(false)
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
    end 
    self.players = {}

    for _, player in pairs(GameCache.players) do 
        local handCardsNode = nil
        local mingCardsNode = nil
        local uselessCardsNode = nil 
        local pan = nil 
        if player.seatDir == GameDefine.DIR_BOTTOM then 
            assert(player.userid == PlayerCache.userid, "the bottom position must belong to playerself")
            pan = self.panBottom
            handCardsNode = CardsArrayBottom:create()
                                        :addTo(self.panBottom.nodeHandCards)
            mingCardsNode = MingCardsNodeBottom:create()
                                        :addTo(self.panBottom.nodeMingCards)
            uselessCardsNode = UselessCardsNodeBottom:create()
                                        :addTo(self.panBottom.nodeUselessCards)
        elseif player.seatDir == GameDefine.DIR_RIGHT then 
            pan = self.panRight
            handCardsNode = CardsArrayRight:create()
                                        :addTo(self.panRight.nodeHandCards)
            mingCardsNode = MingCardsNodeRight:create()
                                        :addTo(self.panRight.nodeMingCards)
            uselessCardsNode = UselessCardsNodeRight:create()
                                        :addTo(self.panRight.nodeUselessCards)
        elseif player.seatDir == GameDefine.DIR_TOP then 
            pan = self.panTop
            handCardsNode = CardsArrayTop:create()
                                        :addTo(self.panTop.nodeHandCards)
            mingCardsNode = MingCardsNodeTop:create()
                                        :addTo(self.panTop.nodeMingCards)
            uselessCardsNode = UselessCardsNodeTop:create()
                                        :addTo(self.panTop.nodeUselessCards)
        elseif player.seatDir == GameDefine.DIR_LEFT then 
            pan = self.panLeft
            handCardsNode = CardsArrayLeft:create()
                                        :addTo(self.panLeft.nodeHandCards)
            mingCardsNode = MingCardsNodeLeft:create()
                                        :addTo(self.panLeft.nodeMingCards)
            uselessCardsNode = UselessCardsNodeLeft:create()
                                        :addTo(self.panLeft.nodeUselessCards)
        else
            error(string.format("player %d, invalid seatDir: %d", player.userid, player.seatDir))
        end 
        local tmp = {}
        for _, cardsNode in pairs(player.handCards) do 
            for _, card in pairs(cardsNode.cards) do 
                for i = 1, card.num, 1 do 
                    table.insert(tmp, card.cardVal)
                end 
            end 
        end 
        for i = 1, player.laisOwned, 1 do 
            table.insert(tmp, GameCache.laiZiCardVal)
        end 
        if player.userid == PlayerCache.userid then 
            handCardsNode:addCards(tmp)
        else 
            handCardsNode:incCardsNum(player.handCardsNum)
        end 
        mingCardsNode:addCards(player.mingCards)
        uselessCardsNode:addCards(player.uselessCards)
        self.players[player.userid] = {
            userid = player.userid, 
            handCardsNode = handCardsNode, 
            mingCardsNode = mingCardsNode, 
            uselessCardsNode = uselessCardsNode,
            pan = pan,
        }
    end 
    local laiZiImgPath = Helper.getCardImgPathOfBottom(GameCache.laiZiCardVal)
    local laiZiPiImgPath = Helper.getCardImgPathOfBottom(GameCache.laiZiPiCardVal)
    self.imgLaiZi:loadTexture(laiZiImgPath)
    self.imgLaiZiPi:loadTexture("GameScene/vertical/handmah_666.png")
    GameHelper.decorateCardImgWithSpecialMark(self.imgLaiZi, GameCache.laiZiCardVal, GameDefine.DIR_BOTTOM)
    GameHelper.decorateCardImgWithSpecialMark(self.imgLaiZiPi, GameCache.laiZiPiCardVal, GameDefine.DIR_BOTTOM)
    local turnPlayer = GameCache.playersByChair[GameCache.whosTurnChairID]
    if turnPlayer then 
        if turnPlayer.userid == PlayerCache.userid then 
            if GameCache.actions and #GameCache.actions > 0 then 
                self:enableActionsOp(true)
            else 
                self:enableActionsOp(false)
            end 
        else 
            self:enableActionsOp(false)
        end 
        if GameCache.actions and #GameCache.actions == 1 and 
            GameCache.actions[1] == GameDefine.PLAY_ACT_OUT then 
            self:newTurn(turnPlayer.userid, GameCache.actionWaitTime)
        else 
            self:newTurn(PlayerCache.userid, GameCache.actionWaitTime)
        end 
    else
        self:newTurn(PlayerCache.userid, GameCache.actionWaitTime)
        self:enableActionsOp(false)
    end 
    self:updateProgress({
        cardsRemainCnt = GameCache.cardsRemainCnt,
        rollsCnt = GameCache.rollsCnt,
        rolls = GameCache.rolls,
    })
    local watchPlayerData = GameCache.playersByChair[GameCache.watchCard.chairID]
    if watchPlayerData then 
        self:enableOutCardMark(true, watchPlayerData.userid)
    else
        self:enableOutCardMark(false, 0)
    end 

    local txt = "%s豹子    %d番起胡"
    if GameCache.options.baoZi and GameCache.baoZiVal and GameCache.baoZiVal ~= 0 then 
        txt = string.format(txt, "", GameCache.fans)
    else
        txt = string.format(txt, "无", GameCache.fans)
    end 
    self.imgDescBg.txtDesc:setText(txt)
end 

return GamePlayLayer
--endregion
