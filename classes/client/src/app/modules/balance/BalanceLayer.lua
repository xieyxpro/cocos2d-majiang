--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local BalanceLayer = class("BalanceLayer", cc.Layer)

local GameDefine = require("app.modules.game.GameDefine")
local UIAnGangNode = require("GameScene.AnGangVertiNode")
local UIMingGangNode = require("GameScene.MingGangVertiNode")
local UIMingGangSnglNode = require("GameScene.MingGangSnglVertiNode")
local UIPengNode = require("GameScene.PengVertiNode")
local UIShunNode = require("GameScene.ShunVertiNode")
local GameDefine = require("app.modules.game.GameDefine")
local GameHelper = require("app.modules.game.GameHelper")

function BalanceLayer:ctor()
    local uiNode = require("GameScene.BalanceLayer"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)

    self.panBalanceInfo:setVisible(false)
    
    Event.register("MS_PLAYER_READY", self, "MS_PLAYER_READY")
    Event.register("MS_DISMISS", self, "MS_DISMISS")
--    Event.register("MS_STAND_UP", self, "MS_STAND_UP")
    Event.register("MS_DISMISS_CONFIRM", self, "MS_DISMISS_CONFIRM")
    Event.register("MS_DISMISS_FAIL", self, "MS_DISMISS_FAIL")
--    Event.register("MS_GAME_OVER", self, "MS_GAME_OVER")
end 

function BalanceLayer:addGangCard(pan, cardVal, num)
    local node = UIMingGangSnglNode:create().root
    util.bindUINodes(node, node, node)
    local strPath = Helper.getCardImgPathOfFlatBottom(cardVal)
    node.rootPanel.img11:loadTexture(strPath)
    GameHelper.decorateCardImgWithSpecialMarkFlat(node.rootPanel.img11, cardVal, GameDefine.DIR_BOTTOM)
--    node.rootPanel.priority = #self.gangCardsAry
    node.rootPanel:removeFromParent()
    local rootPanel = node.rootPanel
    rootPanel:setRotation(0)
    rootPanel.txtNum:setText(tostring(num))
    rootPanel:addTo(pan)
end 

function BalanceLayer:createMingCard(cardVal, mingType, subMingType)
    local node = nil
    if mingType == GameDefine.MING_TYPE_CHI_LEFT then 
        node = UIShunNode:create().root
        util.bindUINodes(node, node, node)
        local strPath1 = Helper.getCardImgPathOfFlatBottom(cardVal)
        local strPath2 = Helper.getCardImgPathOfFlatBottom(cardVal + 1)
        local strPath3 = Helper.getCardImgPathOfFlatBottom(cardVal + 2)
        node.rootPanel.img11:loadTexture(strPath1)
        node.rootPanel.img12:loadTexture(strPath2)
        node.rootPanel.img13:loadTexture(strPath3)
    elseif mingType == GameDefine.MING_TYPE_CHI_MID then 
        node = UIShunNode:create().root
        util.bindUINodes(node, node, node)
        local strPath1 = Helper.getCardImgPathOfFlatBottom(cardVal - 1)
        local strPath2 = Helper.getCardImgPathOfFlatBottom(cardVal)
        local strPath3 = Helper.getCardImgPathOfFlatBottom(cardVal + 1)
        node.rootPanel.img11:loadTexture(strPath1)
        node.rootPanel.img12:loadTexture(strPath2)
        node.rootPanel.img13:loadTexture(strPath3)
    elseif mingType == GameDefine.MING_TYPE_CHI_RIGHT then 
        node = UIShunNode:create().root
        util.bindUINodes(node, node, node)
        local strPath1 = Helper.getCardImgPathOfFlatBottom(cardVal - 2)
        local strPath2 = Helper.getCardImgPathOfFlatBottom(cardVal - 1)
        local strPath3 = Helper.getCardImgPathOfFlatBottom(cardVal)
        node.rootPanel.img11:loadTexture(strPath1)
        node.rootPanel.img12:loadTexture(strPath2)
        node.rootPanel.img13:loadTexture(strPath3)
    elseif mingType == GameDefine.MING_TYPE_MING_GANG then 
        if subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_GANG_PAI then 
            node = UIMingGangSnglNode:create().root
            util.bindUINodes(node, node, node)
            local strPath = Helper.getCardImgPathOfFlatBottom(cardVal)
            node.rootPanel.img11:loadTexture(strPath)
            GameHelper.decorateCardImgWithSpecialMarkFlat(node.rootPanel.img11, cardVal, GameDefine.DIR_BOTTOM)
        else
            node = UIMingGangNode:create().root
            util.bindUINodes(node, node, node)
            local strPath = Helper.getCardImgPathOfFlatBottom(cardVal)
            node.rootPanel.img11:loadTexture(strPath)
            node.rootPanel.img12:loadTexture(strPath)
            node.rootPanel.img13:loadTexture(strPath)
            node.rootPanel.img21:loadTexture(strPath)
        end 
    elseif mingType == GameDefine.MING_TYPE_AN_GANG then 
        node = UIAnGangNode:create().root
        util.bindUINodes(node, node, node)
        local strPath = Helper.getCardImgPathOfFlatBottom(cardVal)
        node.rootPanel.img21:loadTexture(strPath)
    elseif mingType == GameDefine.MING_TYPE_PENG then 
        node = UIPengNode:create().root
        util.bindUINodes(node, node, node)
        local strPath = Helper.getCardImgPathOfFlatBottom(cardVal)
        node.rootPanel.img11:loadTexture(strPath)
        node.rootPanel.img12:loadTexture(strPath)
        node.rootPanel.img13:loadTexture(strPath)
    else 
        error("invalid ming card type")
    end 
    local rootPanel = node.rootPanel:removeFromParentAndCleanup(false)
    return rootPanel
end 

function BalanceLayer:addMingCard(pan, cardVal, mingType, subMingType)
    local mingCard = self:createMingCard(cardVal, mingType, subMingType)
    mingCard:addTo(pan)
end 

function BalanceLayer:onShow()
    local zimoPlayer = nil 
    local myselfBalance = nil 
    local winner = nil
    local sponsor = nil 
    for _, playerData in pairs(GameCache.gameResult.players) do 
        if playerData.score > 0 then 
            winner = playerData
        end 
        if playerData.isSponsor then 
            sponsor = playerData
        end 
    end 
    for _, playerData in pairs(GameCache.gameResult.players) do 
        local player = GameCache.players[playerData.userid]
        if playerData.userid == PlayerCache.userid then 
            myselfBalance = playerData
        end 
        local panBalanceInfo = self.panBalanceInfo:clone():addTo(self.panStatistic)
        panBalanceInfo:setVisible(true)
        util.bindUINodes(panBalanceInfo, panBalanceInfo, nil)
        panBalanceInfo.imgZhuang:setVisible(player.userid == GameCache.zhuangID)
        panBalanceInfo.lblName:setString(player.nickname)
        panBalanceInfo.imgHead:loadTexture(player.playerIcon)
        panBalanceInfo.lblFans:setString(string.format("%d番", playerData.fans))
        panBalanceInfo.lblRecord:setString(tostring(playerData.score))
        panBalanceInfo.imgWin:ignoreContentAdaptWithSize(true)
        panBalanceInfo.imgLoseMark:ignoreContentAdaptWithSize(true)
        panBalanceInfo.imgWin:setVisible(false)
        panBalanceInfo.imgLoseMark:setVisible(false)
        panBalanceInfo.lblRecordTypes:setVisible(false)
        if winner and playerData.userid == winner.userid then 
            panBalanceInfo.imgWin:setVisible(true)
            if winner.huType == GameDefine.HU_TYPE_DIAN_PAO then 
                panBalanceInfo.imgWin:loadTexture("HomeScene/achiv/bg-hu.png")
            elseif winner.huType == GameDefine.HU_TYPE_HAI_DI_LAO then 
                panBalanceInfo.imgWin:loadTexture("HomeScene/achiv/bg-zhimo.png")
            elseif winner.huType == GameDefine.HU_TYPE_QIANG_GANG then 
                panBalanceInfo.imgWin:loadTexture("HomeScene/achiv/bg-hu.png")
            elseif winner.huType == GameDefine.HU_TYPE_ZI_MO then 
                panBalanceInfo.imgWin:loadTexture("HomeScene/achiv/bg-zhimo.png")
            else 
                assert(false)
            end 
            --胡牌类型统计
            local scoreTypesName = {}
            for _, recordType in ipairs(playerData.scoreTypes) do 
                local name = GameDefine.RECORD_TYPE_NAMES[recordType]
                assert(name)
                table.insert(scoreTypesName, name .. ", ")
            end 
            local str = table.concat(scoreTypesName)
            panBalanceInfo.lblRecordTypes:setVisible(true)
            panBalanceInfo.lblRecordTypes:setString(str)
            panBalanceInfo:setBackGroundImage("GameScene/Balance/bf-jieshuandikuang2.png",0) --hight light
        end 
        if sponsor and sponsor.userid == playerData.userid then 
            panBalanceInfo.imgWin:setVisible(true)
            if winner.huType == GameDefine.HU_TYPE_DIAN_PAO then 
                panBalanceInfo.imgWin:loadTexture("HomeScene/achiv/bg-pao.png")
            elseif winner.huType == GameDefine.HU_TYPE_HAI_DI_LAO then 
                panBalanceInfo.imgWin:setVisible(false)
            elseif winner.huType == GameDefine.HU_TYPE_QIANG_GANG then 
                panBalanceInfo.imgWin:loadTexture("HomeScene/achiv/bg-pao.png")
            elseif winner.huType == GameDefine.HU_TYPE_ZI_MO then 
                panBalanceInfo.imgWin:setVisible(false)
            else 
                assert(false)
            end 
        end 
        panBalanceInfo.imgLoseMark:setVisible(true)
        if playerData.score < 0 then 
            if playerData.baoHu then 
                panBalanceInfo.imgLoseMark:loadTexture("GameScene/Balance/bg_baohu.png")
            else 
                local score = math.abs(playerData.score)
                if GameCache.options.baoZi and GameCache.baoZiVal ~= 0 then 
                    score = score / 2
                end 
                if score >= GameDefine.SAN_YANG_KAI_TAI then 
                    panBalanceInfo.imgLoseMark:loadTexture("GameScene/Balance/bg_shangyangkaitai.png")--TODO 三阳开泰标识缺
                elseif score >= GameDefine.HA_DING then 
                    panBalanceInfo.imgLoseMark:loadTexture("GameScene/Balance/bg-hading.png")
                elseif score >= GameDefine.JIN_DING then 
                    panBalanceInfo.imgLoseMark:loadTexture("GameScene/Balance/bg-jinding.png")
                elseif score >= GameDefine.FENG_DING then 
                    panBalanceInfo.imgLoseMark:loadTexture("GameScene/Balance/bg-fengding.png")
                else
                    panBalanceInfo.imgLoseMark:setVisible(false)
                end 
            end 
        else  
            panBalanceInfo.imgLoseMark:setVisible(false)
        end 
        local tmpMingCards = {}
        local gangCards = {}
        for _, mingCard in ipairs(playerData.mingCards) do 
            if mingCard.mingType == GameDefine.MING_TYPE_MING_GANG and 
                mingCard.subMingType == GameDefine.MING_TYPE_MING_GANG_SUB_GANG_PAI then 
                gangCards[mingCard.cardVal] = gangCards[mingCard.cardVal] or {cardVal = mingCard.cardVal, num = 0}
                gangCards[mingCard.cardVal].num = gangCards[mingCard.cardVal].num + 1
            else 
                table.insert(tmpMingCards, {
                    cardVal = mingCard.cardVal, 
                    mingType = mingCard.mingType, 
                    subMingType = mingCard.subMingType,
                })
            end 
        end 
        for _, gangCard in pairs(gangCards) do 
            self:addGangCard(panBalanceInfo.panCards.panGangCards, gangCard.cardVal, gangCard.num)
        end 
        for _, mingCard in ipairs(tmpMingCards) do 
            self:addMingCard(panBalanceInfo.panCards.panMingCards, mingCard.cardVal, mingCard.mingType, mingCard.subMingType)
        end 
        local handCards = {}
        for i, cardVal in ipairs(playerData.handCards) do 
            table.insert(handCards, cardVal)
        end 
        if playerData.score > 0 then 
            if playerData.huType == GameDefine.HU_TYPE_ZI_MO or 
                playerData.huType == GameDefine.HU_TYPE_HAI_DI_LAO then 
                table.delete(handCards, playerData.huCardVal, function(val)
                    return val == playerData.huCardVal
                end)
            end 
        end 
        for i, cardVal in ipairs(handCards) do 
            local node = Helper.getCardSpriteFlatBottom(cardVal)
            GameHelper.decorateCardImgWithSpecialMarkFlat(node, cardVal, GameDefine.DIR_BOTTOM)
            node.priority = i
            node:addTo(panBalanceInfo.panCards.panHandCards)
            if cardVal == GameCache.laiZiCardVal then 
                node.priority = -1
            end 
        end 
        if playerData.score > 0 then 
            --添加胡牌
            local node = Helper.getCardSpriteFlatBottom(playerData.huCardVal)
            node.priority = #playerData.handCards + 1
            node:setScale(0.45)
            node:addTo(panBalanceInfo.panCards)
            GameHelper.decorateCardImgWithSpecialMarkFlat(node, playerData.huCardVal, GameDefine.DIR_BOTTOM)
--            GameHelper.decorateCardImgWithHuMarkFlat(node, playerData.huCardVal, GameDefine.DIR_BOTTOM)
            panBalanceInfo.priority = 1
        elseif playerData.score < 0 then 
            panBalanceInfo.priority = 2
        else
            panBalanceInfo.priority = 3
        end 
        
        panBalanceInfo.panCards.panGangCards:setScale(0.45)
        panBalanceInfo.panCards.panMingCards:setScale(0.45)
        panBalanceInfo.panCards.panHandCards:setScale(0.45)
        WidgetExt.panLayoutCustomHorizontal(panBalanceInfo.panCards.panGangCards, {lines = 1, columnIntvl = -3, margin = WidgetExt.VerticalMargin.BOTTOM})
        WidgetExt.panLayoutCustomHorizontal(panBalanceInfo.panCards.panMingCards, {lines = 1, columnIntvl = 5, margin = WidgetExt.VerticalMargin.BOTTOM})
        WidgetExt.panLayoutCustomHorizontal(panBalanceInfo.panCards.panHandCards, {lines = 1, columnIntvl = -3, margin = WidgetExt.VerticalMargin.BOTTOM})
        WidgetExt.panLayoutCustomHorizontal(panBalanceInfo.panCards, {lines = 1, margin = WidgetExt.VerticalMargin.BOTTOM})
    end 
    if GameCache.gameResult.result == GameDefine.GAME_OVER_TYPE_LIU then --流局
        self.imgResult:loadTexture("GameScene/Balance/bg-liujue.png")
        Helper.playSoundFailed()
    elseif GameCache.gameResult.result == GameDefine.GAME_OVER_TYPE_HU then 
        if myselfBalance.score > 0 then --赢了
            self.imgResult:loadTexture("GameScene/Balance/bg-yingle.png")
            Helper.playSoundWin()
        elseif myselfBalance.score == 0 then --与我无关
            self.imgResult:loadTexture("GameScene/Balance/bg-jieshuang.png")
            Helper.playSoundWin()
        else --输了
            self.imgResult:loadTexture("GameScene/Balance/bg-shule.png")
            Helper.playSoundFailed()
        end 
    else --出错了
        assert(false, string.format("invalid result: %d", GameCache.gameResult.result))
    end 
    WidgetExt.panLayoutVertical(self.panStatistic, {columns = 1, needSort = true})
    
    self.panBtnLayout.btnOneMore:setVisible(GameCache.rollsCnt < GameCache.rolls)
    self.panBtnLayout.btnBackHome:setVisible(false)--GameCache.rollsCnt < GameCache.rolls and PlayerCache.userid ~= GameCache.roomCreaterUserID)
    self.panBtnLayout.btnDismiss:setVisible(GameCache.rollsCnt < GameCache.rolls)
    self.panBtnLayout.btnStatistic:setVisible(GameCache.rollsCnt == GameCache.rolls)
    local columns = 0
    if self.panBtnLayout.btnOneMore:isVisible() then 
        columns = columns + 1
    end 
    if self.panBtnLayout.btnBackHome:isVisible() then 
        columns = columns + 1
    end 
    if self.panBtnLayout.btnDismiss:isVisible() then 
        columns = columns + 1
    end 
    if self.panBtnLayout.btnStatistic:isVisible() then 
        columns = columns + 1
    end 
    WidgetExt.panLayoutVertical(self.panBtnLayout, {
                autoWidth = false,
                autoHeight = false,
                columnIntvl = 30, 
                columns = columns, 
                needSort = false,
                onlyVisible = true})
end 

function BalanceLayer:onClose()
    Event.unregister("MS_PLAYER_READY", self, "MS_PLAYER_READY")
    Event.unregister("MS_DISMISS", self, "MS_DISMISS")
--    Event.unregister("MS_STAND_UP", self, "MS_STAND_UP")
    Event.unregister("MS_DISMISS_CONFIRM", self, "MS_DISMISS_CONFIRM")
    Event.unregister("MS_DISMISS_FAIL", self, "MS_DISMISS_FAIL")
--    Event.unregister("MS_GAME_OVER", self, "MS_GAME_OVER")
end 

function BalanceLayer:MS_PLAYER_READY(data)
    if data.userid == PlayerCache.userid then 
        UIManager:unblock()
        UIManager:replaceCurrent(Define.SCENE_GAME, "app.modules.game.GameLayer", UIManager.UITYPE_FULL_SCREEN)
    end 
end 

function BalanceLayer:MS_DISMISS(data)
    HomeCache:disconnGame()
    local okCallback = function()
        if #GameCache.accomplishes.statPlayers > 0 then 
            UIManager:clearAllAndGoTo(Define.SCENE_HOME, "app.modules.home.HomeLayer", UIManager.UITYPE_FULL_SCREEN)
            UIManager:goTo(Define.SCENE_HOME, "app.modules.Statistic.StatisticLayer", UIManager.UITYPE_PROMPT)
        else 
            UIManager:clearAllAndGoTo(Define.SCENE_HOME, "app.modules.home.HomeLayer", UIManager.UITYPE_FULL_SCREEN)
        end 
    end 
    UIManager:showMsgBox({
        msg = "当前组局已被解散",
        ok = true,
        okCallback = okCallback,
        cancelCallback = okCallback,
    })
end 

--function BalanceLayer:MS_STAND_UP(data)
--    if data.userid ~= PlayerCache.userid then 
--        return
--    end 
--    UIManager:goBack(Define.SCENE_HOME, "app.modules.home.HomeLayer", UIManager.UITYPE_FULL_SCREEN)
--    HomeCache:disconnGame()
--end 

function BalanceLayer:MS_DISMISS_CONFIRM(data)
    UIManager:unblock()
    require("app.modules.game.DismissLayer").show()
end 

function BalanceLayer:MS_DISMISS_FAIL(data)
    UIManager:unblock()
    require("app.modules.game.DismissLayer").close()
    local rejecter = GameCache.players[data.notagreeuserid]
    assert(rejecter)
    UIManager:showMsgBox({
        msg = string.format("玩家%s拒绝解散房间", rejecter.nickname),
        ok = true,
    })
end 

--function BalanceLayer:MS_GAME_OVER(data)
--    if data and data.err ~= 0 then 
--        HomeCache:disconnGame()
--        local okCallback = function()
--            UIManager:goBack(Define.SCENE_HOME, "app.modules.home.HomeLayer", UIManager.UITYPE_FULL_SCREEN)
--        end 
--        local errMsg = GameDefine.GAME_OVER_ERR[data.err]
--        UIManager:showMsgBox({
--            msg = errMsg,
--            ok = true,
--            okCallback = okCallback,
--            cancelCallback = okCallback,
--        })
--    end 
--    UIManager:unblock()
--end 

function BalanceLayer:onClick_btnBackHome(sender)
--    Helper.playSoundClick()
--    Network:send(Define.SERVER_GAME, "mc_stand_up", nil)
--    UIManager:block()
end 

function BalanceLayer:onClick_btnDismiss(sender)
    Helper.playSoundClick()
    Network:send(Define.SERVER_GAME, "mc_dismiss", {agree = true})
    UIManager:block()
end 

function BalanceLayer:onClick_btnOneMore(sender)
    Network:send(Define.SERVER_GAME, "mc_player_ready", {})
    UIManager:block()
    Helper.playSoundClick()
end 

function BalanceLayer:onClick_btnStatistic(sender)
    Helper.playSoundClick()
    HomeCache:disconnGame()
    UIManager:goBack(Define.SCENE_HOME, "app.modules.home.HomeLayer", UIManager.UITYPE_FULL_SCREEN)
    UIManager:goTo(Define.SCENE_HOME, "app.modules.Statistic.StatisticLayer", UIManager.UITYPE_PROMPT)
end 

return BalanceLayer
--endregion
