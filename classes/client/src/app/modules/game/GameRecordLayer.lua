--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local GameRecordLayer = class("GameRecordLayer", cc.Layer)

function GameRecordLayer:ctor(statistics)
    self.statistics = statistics

    local uiNode = require("GameScene.GameRecordLayer"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)

    self.imgBg.imgContentBg.panItem:setVisible(false)
end 

function GameRecordLayer:onShow()
    local cnt = 1
    local mapIndex = {}
    for _, playerInfo in pairs(GameCache.players) do 
        local txt = self.imgBg.imgContentBg.panHeader["txtName"..cnt]
        if txt then 
            mapIndex[playerInfo.userid] = {index = cnt, userid = playerInfo.userid}
            txt:setText(playerInfo.nickname)
        else 
            print("ERROR too many people")
        end 
        cnt = cnt + 1
    end 
    local summary = {}
    local tmp = {}
    for _, stat in pairs(self.statistics) do 
        local score = 0
        for _, rollStat in ipairs(stat.rollStats) do 
            tmp[rollStat.rollNO] = tmp[rollStat.rollNO] or {rollNO = rollStat.rollNO, stats = {}}
            tmp[rollStat.rollNO].stats[stat.userid] = rollStat
            score = score + rollStat.score
        end 
        summary[stat.userid] = score
    end 
    local rolls = {}
    for _, roll in pairs(tmp) do 
        table.insert(rolls, roll)
    end 
    table.sort(rolls, function(r1, r2)
        return r1.rollNO < r2.rollNO
    end)
    for i, roll in ipairs(rolls) do 
        local item = self.imgBg.imgContentBg.panItem:clone():addTo(self.imgBg.imgContentBg.svContent)
        util.bindUINodes(item, item, nil)
        item:setVisible(true)
        item.txtSeq:setText(tostring(roll.rollNO))
        for userid, stat in pairs(roll.stats) do 
            if mapIndex[userid] then 
                local txt = item["txtScore"..mapIndex[userid].index]
                txt:setText(tostring(stat.score))
            end 
        end 
    end 
    for i = 1, 4, 1 do 
        local txt = self.imgBg.imgContentBg.panSummary["txtS"..i]
        txt:setText(tostring(0))
    end 
    for userid, score in pairs(summary) do 
        if mapIndex[userid] then 
            local txt = self.imgBg.imgContentBg.panSummary["txtS"..mapIndex[userid].index]
            txt:setText(tostring(score))
        end 
    end 
    self.imgBg.imgContentBg.svContent:layoutVertical1({
        columns = 1,
        lineIntvl = 0,
        needSort = false,
    })
end 

function GameRecordLayer:onClose()
end 

function GameRecordLayer:onClick_btnClose(sender)
    UIManager:goBack()
    Helper.playSoundClick()
end 

return GameRecordLayer
--endregion
