--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local RollListLayer = class("RollListLayer", cc.Layer)

local GameDefine = require("app.modules.game.GameDefine")
local UIAnGangNode = require("GameScene.AnGangVertiNode")
local UIMingGangNode = require("GameScene.MingGangVertiNode")
local UIMingGangSnglNode = require("GameScene.MingGangSnglVertiNode")
local UIPengNode = require("GameScene.PengVertiNode")
local UIShunNode = require("GameScene.ShunVertiNode")
local GameDefine = require("app.modules.game.GameDefine")
local GameHelper = require("app.modules.game.GameHelper")

function RollListLayer:ctor()
    local uiNode = require("HomeScene.achiv.RollListLayer"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)

    self.imgBg.imgContentBg.panItem:setVisible(false)
    self.imgBg.btnCheckOthers:setVisible(false)--TODO 暂时屏蔽分享
    
    Event.register("HTTP_PLAY_RECORDS_DETAIL", self, "HTTP_PLAY_RECORDS_DETAIL")
end 

function RollListLayer:addGangCard(pan, cardVal, num, specialMarkValus)
    local node = UIMingGangSnglNode:create().root
    util.bindUINodes(node, node, node)
    local strPath = Helper.getCardImgPathOfFlatBottom(cardVal)
    node.rootPanel.img11:loadTexture(strPath)
    GameHelper.decorateCardImgWithSpecialMarkFlat(node.rootPanel.img11, cardVal, GameDefine.DIR_BOTTOM, specialMarkValus)
--    node.rootPanel.priority = #self.gangCardsAry
    node.rootPanel:removeFromParent()
    local rootPanel = node.rootPanel
    rootPanel:setRotation(0)
    rootPanel.txtNum:setText(tostring(num))
    rootPanel:addTo(pan)
end 

function RollListLayer:createMingCard(cardVal, mingType, subMingType)
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

function RollListLayer:addMingCard(pan, cardVal, mingType, subMingType)
    local mingCard = self:createMingCard(cardVal, mingType, subMingType)
    mingCard:addTo(pan)
end 

function RollListLayer:onShow()
    local room = AchivCache.curSelectRoom
    local cnt = 1
    local mapIndex = {}
    for _, playerInfo in pairs(room.playersInfo) do 
        mapIndex[playerInfo.userid] = {index = cnt, userid = playerInfo.userid}
        cnt = cnt + 1
    end 
    local rolls = {}
    for _, roll in pairs(room.rolls) do 
        table.insert(rolls, roll)
    end 
    table.sort(rolls, function(r1, r2)
        return r1.startTime < r2.startTime
    end)
    for i, roll in ipairs(rolls) do 
        local item = self.imgBg.imgContentBg.panItem:clone():addTo(self.imgBg.imgContentBg.svContent)
        util.bindUINodes(item, item, nil)
        item:setVisible(true)
        item.txtSeq:setText(string.format("第%d局", i))
        item.txtTime:setText(os.toDateTimeString(roll.startTime))
        for userid, stat in pairs(roll.stats) do 
            if mapIndex[userid] then 
                local pan = item["panP"..mapIndex[userid].index]
                local playerInfo = room.playersInfo[userid]
                pan.txtName:setText(playerInfo.nickname)
                pan.txtScore:setText(tostring(stat.score))
            end 
        end 
        item.imgMarkLose:setVisible(false)
        if roll.result == GameDefine.GAME_OVER_TYPE_LIU then 
            item.imgResult:setVisible(true)
            item.imgResult:loadTexture("HomeScene/achiv/bg-liujui.png")
            item.imgMarkHu:setVisible(false)
        else 
            item.imgResult:setVisible(false)
            item.imgMarkHu:setVisible(true)
            local playerData = roll.winner
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
                self:addGangCard(item.panCards.panGangCards, gangCard.cardVal, gangCard.num, roll.rollInfo)
            end 
            for _, mingCard in ipairs(tmpMingCards) do 
                self:addMingCard(item.panCards.panMingCards, mingCard.cardVal, mingCard.mingType, mingCard.subMingType)
            end 
            local handCards = {}
            for i, cardVal in ipairs(playerData.handCards) do 
                table.insert(handCards, cardVal)
            end 
            if playerData.huType == GameDefine.HU_TYPE_ZI_MO or 
                playerData.huType == GameDefine.HU_TYPE_HAI_DI_LAO then 
                table.delete(handCards, playerData.huCardVal, function(val)
                    return val == playerData.huCardVal
                end)
            end 
            for i, cardVal in ipairs(handCards) do 
                local node = Helper.getCardSpriteFlatBottom(cardVal)
                GameHelper.decorateCardImgWithSpecialMarkFlat(node, cardVal, GameDefine.DIR_BOTTOM, roll.rollInfo)
                node.priority = i
                node:addTo(item.panCards.panHandCards)
                if cardVal == GameCache.laiZiCardVal then 
                    node.priority = -1
                end 
            end 
            --添加胡牌
            local node = Helper.getCardSpriteFlatBottom(playerData.huCardVal)
            node.priority = #playerData.handCards + 1
            node:setScale(0.45)
            node:addTo(item.panCards)
            GameHelper.decorateCardImgWithSpecialMarkFlat(node, playerData.huCardVal, GameDefine.DIR_BOTTOM, roll.rollInfo)
            item.panCards.panGangCards:setScale(0.45)
            item.panCards.panMingCards:setScale(0.45)
            item.panCards.panHandCards:setScale(0.45)
            WidgetExt.panLayoutCustomHorizontal(item.panCards.panGangCards, {lines = 1, columnIntvl = -3, margin = WidgetExt.VerticalMargin.BOTTOM})
            WidgetExt.panLayoutCustomHorizontal(item.panCards.panMingCards, {lines = 1, columnIntvl = 5, margin = WidgetExt.VerticalMargin.BOTTOM})
            WidgetExt.panLayoutCustomHorizontal(item.panCards.panHandCards, {lines = 1, columnIntvl = -3, margin = WidgetExt.VerticalMargin.BOTTOM})
            WidgetExt.panLayoutCustomHorizontal(item.panCards, {lines = 1, margin = WidgetExt.VerticalMargin.BOTTOM})

            item.imgMarkHu:ignoreContentAdaptWithSize(true)
            if playerData.huType == GameDefine.HU_TYPE_NORMAL then 
                item.imgMarkHu:loadTexture("HomeScene/achiv/bg-hu.png")
            elseif playerData.huType == GameDefine.HU_TYPE_ZI_MO then 
                item.imgMarkHu:loadTexture("HomeScene/achiv/bg-zhimo.png")
            elseif playerData.huType == GameDefine.HU_TYPE_DIAN_PAO then 
                item.imgMarkHu:loadTexture("HomeScene/achiv/bg-hu.png")
            elseif playerData.huType == GameDefine.HU_TYPE_QIANG_GANG then 
                item.imgMarkHu:loadTexture("HomeScene/achiv/bg-hu.png")
            elseif playerData.huType == GameDefine.HU_TYPE_HAI_DI_LAO then
                item.imgMarkHu:loadTexture("HomeScene/achiv/bg-haidilaoyue.png")
            else
                assert(false)
            end 
            if roll.sponsorUserID ~= 0 then 
                item.imgMarkLose:setVisible(true)
                if playerData.huType == GameDefine.HU_TYPE_NORMAL then 
                    item.imgMarkLose:setVisible(false)
                elseif playerData.huType == GameDefine.HU_TYPE_ZI_MO then 
                    item.imgMarkLose:setVisible(false)
                elseif playerData.huType == GameDefine.HU_TYPE_DIAN_PAO then 
                    item.imgMarkLose:loadTexture("HomeScene/achiv/bg-pao.png")
                elseif playerData.huType == GameDefine.HU_TYPE_QIANG_GANG then 
                    item.imgMarkLose:loadTexture("HomeScene/achiv/bg-qianggang.png")
                elseif playerData.huType == GameDefine.HU_TYPE_HAI_DI_LAO then
                    item.imgMarkLose:setVisible(false)
                else
                    assert(false)
                end 
                if mapIndex[roll.sponsorUserID] then 
                    local pan = item["panP"..mapIndex[roll.sponsorUserID].index]
                    local playerInfo = room.playersInfo[roll.sponsorUserID]
                    local panSz = pan:getContentSize()
                    local pos = cc.p(pan:getPosition())
                    pos.x = pos.x + panSz.width - 40
                    pos.y = pos.y + panSz.height * 0.5
                    item.imgMarkLose:setPosition(pos)
                end 
            else 
                item.imgMarkLose:setVisible(false)
            end 
            local pan = item["panP"..mapIndex[playerData.userid].index]
            local panSz = pan:getContentSize()
            local pos = cc.p(pan:getPosition())
            pos.x = pos.x + panSz.width - 40
            pos.y = pos.y + panSz.height * 0.5
            item.imgMarkHu:setPosition(pos)
        end 
        item:setTouchEnabled(false)
        item.btnShare:setVisible(false) --TODO 暂时屏蔽分享
        item.btnShare:addTouchEventListener(function(sender, event)
            if event == ccui.TouchEventType.began then 
                sender:setScale(0.9)
            elseif event == ccui.TouchEventType.ended or 
                event == ccui.TouchEventType.canceled then 
                sender:setScale(1.0)
            end 
            if event == ccui.TouchEventType.ended then 
                --TODO share to wechat
                UIManager:showTip("coming soon")
            end 
        end)
        item.btnCheck:addTouchEventListener(function(sender, event)
            if event == ccui.TouchEventType.began then 
                sender:setScale(0.9)
            elseif event == ccui.TouchEventType.ended or 
                event == ccui.TouchEventType.canceled then 
                sender:setScale(1.0)
            end 
            if event == ccui.TouchEventType.ended then 
                AchivCache.curSelectRoom.curRollGuid = roll.guid 
                if AchivCache.curSelectRoom:getCurRollData() then 
                    UIManager:goTo(Define.SCENE_HOME, "app.modules.achiv.PlaybackLayer", UIManager.UITYPE_FULL_SCREEN, nil, false)
                else 
                    UIManager:block()
                    AchivCache:requestRollData(roll.guid)
                end 
            end 
        end)
    end 
    self.imgBg.imgContentBg.svContent:layoutVertical1({
        columns = 1,
        lineIntvl = 0,
        needSort = false,
    })
end 

function RollListLayer:onClose()
    Event.unregister("HTTP_PLAY_RECORDS_DETAIL", self, "HTTP_PLAY_RECORDS_DETAIL")
end 

function RollListLayer:HTTP_PLAY_RECORDS_DETAIL(data)
    UIManager:unblock()
    if data.err then 
        printInfo("[HTTP_PLAY_RECORDS_DETAIL] errCode: %d, msg: %s", data.err.code, data.err.msg or "")
        UIManager:showTip("请求牌局数据出错")
        return
    else 
        UIManager:goTo(Define.SCENE_HOME, "app.modules.achiv.PlaybackLayer", UIManager.UITYPE_FULL_SCREEN, nil, false)
    end 
end 

function RollListLayer:onClick_btnCheckOthers(sender)
    --TODO share to wechat
    UIManager:showTip("coming soon")
    Helper.playSoundClick()
end 

function RollListLayer:onClick_btnGoBack(sender)
    UIManager:goBack()
    Helper.playSoundClick()
end 

return RollListLayer
--endregion
