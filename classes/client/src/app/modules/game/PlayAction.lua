--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local PlayAction = class("PlayAction", cc.Layer)

local GameDefine = require("app.modules.game.GameDefine")
local ChiOpNode = require("app.modules.game.ChiOpNode")
local GangOpNode = require("app.modules.game.GangOpNode")

PlayAction.GUO = "guo"

function PlayAction:ctor(params)
    local node = require("GameScene.PlayActionLayer"):create().root
                    :addTo(self)
    util.bindUINodes(node, self, self)

    self.actions = {
        [GameDefine.PLAY_ACT_GUO] = {button = self.panLayout.btnGuo, index = 1},
        [GameDefine.PLAY_ACT_CHI] = {button = self.panLayout.btnChi, index = 2},
        [GameDefine.PLAY_ACT_GANG_WATCH] = {button = self.panLayout.btnGang, index = 3},
        [GameDefine.PLAY_ACT_GANG_INITIATIVE] = {button = self.panLayout.btnGang, index = 3},
        [GameDefine.PLAY_ACT_PENG] = {button = self.panLayout.btnPeng, index = 4},
        [GameDefine.PLAY_ACT_HU] = {button = self.panLayout.btnHu, index = 5},
    }
    self.enabledActions = {}
--    self:setScale(0.8)
end

--[Comment]
--cardVal is not available
function PlayAction:enableActions(actions, cardVal)
    if self.nodeChiOp.chiOpNode then 
        self.nodeChiOp.chiOpNode:removeFromParent()
        self.nodeChiOp.chiOpNode = nil
    end 
    if self.nodeGangOp.gangOpNode then 
        self.nodeGangOp.gangOpNode:removeFromParent()
        self.nodeGangOp.gangOpNode = nil
    end 
    for _, actionNode in pairs(self.actions) do 
        actionNode.button:setVisible(false)
    end 
    self.enabledActions = {}
    for _, action in pairs(actions) do 
        table.insert(self.enabledActions, action)
    end 
    table.sort(self.enabledActions, function(a, b)
        return self.actions[a].index < self.actions[b].index
    end)
    self:refresh()
end 

function PlayAction:refresh()
    local preBtn = nil 
    for i, action in ipairs(self.enabledActions) do 
        local btn = self.actions[action].button
        btn:setVisible(true)
        local anPt = btn:getAnchorPoint()
        local btnSz = btn:getContentSize()
        btn.priority = #self.enabledActions - i
        preBtn = btn
    end 
    WidgetExt.panLayoutHorizontal(self.panLayout, {
        needSort = true,
        onlyVisible = true,
    })
end 

function PlayAction:onClick_btnGuo(target)
    Network:send(Define.SERVER_GAME, "mc_action_guo", {})
    UIManager:block()
end 

function PlayAction:onClick_btnChi(target)
    if self.nodeChiOp.chiOpNode then 
        return 
    end 
--    Event.dispatch("PLAY_ACTION_CHI")
--    self:setVisible(false)
    
    local cards = {}
    local player = GameCache.players[PlayerCache.userid]
    for _, snglTypeCards in pairs(player.handCards) do 
        if snglTypeCards.num > 0 then 
            for _, tmpCards in pairs(snglTypeCards.cards) do 
                for i = 1, tmpCards.num, 1 do 
                    table.insert(cards, {cardVal = tmpCards.cardVal})
                end 
            end 
        end 
    end 
    local cardVal = GameCache.watchCard.cardVal
    
    local tmp = {}
    for i, card in ipairs(cards) do 
        if not GameCache:isGangCard(card.cardVal) and 
            (card.cardVal == cardVal - 1 or 
            card.cardVal == cardVal - 2 or 
            card.cardVal == cardVal + 1 or 
            card.cardVal == cardVal + 2) then
            tmp[card.cardVal] = card
        end 
    end 
    if not tmp[cardVal - 1] then 
        tmp[cardVal - 2] = nil
    end 
    if not tmp[cardVal + 1] then 
        tmp[cardVal + 2] = nil
    end 
    if cardVal % 10 == 8 then 
        tmp[cardVal + 2] = nil
    end 
    if cardVal % 10 == 2 then 
        tmp[cardVal - 2] = nil
    end 
    if cardVal % 10 == 9 then 
        tmp[cardVal + 1] = nil
        tmp[cardVal + 2] = nil
    end 
    if cardVal % 10 == 1 then 
        tmp[cardVal - 1] = nil
        tmp[cardVal - 2] = nil
    end 
    local mingCards = {}
    for _, card in pairs(tmp) do 
        if card.cardVal == cardVal - 2 then 
            table.insert(mingCards, {
                cardVal = cardVal,
                mingType = GameDefine.MING_TYPE_CHI_RIGHT,
                subMingType = 0,
            })
        end 
        if card.cardVal == cardVal - 1 and tmp[cardVal + 1] then 
            table.insert(mingCards, {
                cardVal = cardVal,
                mingType = GameDefine.MING_TYPE_CHI_MID,
                subMingType = 0,
            })
        end 
        if card.cardVal == cardVal + 1 and tmp[cardVal + 2] then 
            table.insert(mingCards, {
                cardVal = cardVal,
                mingType = GameDefine.MING_TYPE_CHI_LEFT,
                subMingType = 0,
            })
        end 
    end 
    if #mingCards == 1 then 
        local mingCard = mingCards[1]
        Network:send(Define.SERVER_GAME, "mc_action_chi", {
            cardVal = mingCard.cardVal, 
            chiType = mingCard.mingType,
        })
        UIManager:block()
    elseif #mingCards > 1 then 
        table.sort(mingCards, function(ming1, ming2)
            return ming1.mingType > ming2.mingType
        end)
        local chiOpNode = ChiOpNode:create():addTo(self.nodeChiOp)
        chiOpNode:addCards(mingCards)
        self.nodeChiOp.chiOpNode = chiOpNode
    else 
        assert(false)
    end 
end 

function PlayAction:onClick_btnGang(target)
    if self.nodeGangOp.gangOpNode then 
        return 
    end 
    local gangAct = 0
    for _, actVal in ipairs(GameCache.actions) do 
        if actVal == GameDefine.PLAY_ACT_GANG_INITIATIVE or 
            actVal == GameDefine.PLAY_ACT_GANG_WATCH then 
            gangAct = actVal
            break 
        end 
    end 
    local gangs
    if gangAct == GameDefine.PLAY_ACT_GANG_INITIATIVE then 
        gangs = GameCache:getGangs()
    elseif gangAct == GameDefine.PLAY_ACT_GANG_WATCH then 
        gangs = {}
        table.insert(gangs, {
            cardVal = GameCache.watchCard.cardVal,
            mingType = GameDefine.MING_TYPE_MING_GANG,
            subMingType = GameDefine.MING_TYPE_MING_GANG_SUB_WATCH,
        })
    else 
        assert(false)
    end 
    if #gangs == 1 then 
        local data = {}
        data.cardVal = gangs[1].cardVal
        data.mingType = gangs[1].mingType
        data.subMingType = gangs[1].subMingType or 0
        Network:send(Define.SERVER_GAME, "mc_action_gang", data)
        UIManager:block()
    elseif #gangs > 1 then 
        local gangOpNode = GangOpNode:create():addTo(self.nodeChiOp)
        gangOpNode:addCards(gangs)
        self.nodeGangOp.gangOpNode = gangOpNode
    else 
        assert(false)
    end 
end 

function PlayAction:onClick_btnPeng(target)
    local data = {
        cardVal = GameCache.watchCard.cardVal
    }
    Network:send(Define.SERVER_GAME, "mc_action_peng", data)
    UIManager:block()
end 

function PlayAction:onClick_btnHu(target)
    Network:send(Define.SERVER_GAME, "mc_action_hu", {})
    UIManager:block()
end 

return PlayAction
--endregion
