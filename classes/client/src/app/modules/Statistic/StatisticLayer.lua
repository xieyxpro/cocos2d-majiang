--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local StatisticLayer = class("StatisticLayer", cc.Layer)

local GameDefine = require("app.modules.game.GameDefine")

function StatisticLayer:ctor()
    local uiNode = require("GameScene.StatisticLayer"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)

    self.imgBg.panItem:setVisible(false)
    
    if Launcher.channel == Launcher.CHANNELS.SHENHE then
        self.imgBg.btnShare:setVisible(false)
    end  
end 

function StatisticLayer:onShow()
    local highestScore = 0
    for _, statPlayer in pairs(GameCache.accomplishes.statPlayers) do 
        for _, stat in pairs(statPlayer.stats) do 
            if stat.statType == GameDefine.STAT_TYPE_RECORD then 
                if stat.statValue > highestScore then 
                    highestScore = stat.statValue
                end 
            end 
        end 
    end 
    local winners = {}
    if highestScore > 0 then 
        for _, statPlayer in pairs(GameCache.accomplishes.statPlayers) do 
            for _, stat in pairs(statPlayer.stats) do 
                if stat.statType == GameDefine.STAT_TYPE_RECORD then 
                    if stat.statValue == highestScore then 
                        winners[statPlayer.userid] = statPlayer 
                    end 
                end 
            end 
        end 
    end 
    for _, statPlayer in pairs(GameCache.accomplishes.statPlayers) do 
        local player = GameCache.players[statPlayer.userid]
        assert(player)
        local playerItem = self.imgBg.panItem:clone()
        playerItem:setVisible(true)
        util.bindUINodes(playerItem, playerItem, nil)
        playerItem.txtName:setText(player.nickname)
        playerItem.txtID:setText(tostring(player.userid))
--        playerItem.imgHead:ignoreContentAdaptWithSize(false)
        playerItem.imgHead:loadTexture(player.playerIcon)
        playerItem.panInfoItem:setVisible(false)
        if player.userid == GameCache.roomCreaterUserID then 
            playerItem.imgHead.imgRoomCreator:setVisible(true)
        else
            playerItem.imgHead.imgRoomCreator:setVisible(false)
        end 
        if winners[statPlayer.userid] then 
            playerItem.imgWinner:setVisible(true)
        else 
            playerItem.imgWinner:setVisible(false)
        end 
        for _, stat in pairs(statPlayer.stats) do 
            if stat.statType == GameDefine.STAT_TYPE_RECORD then 
                playerItem.txtTotal:setText(tostring(stat.statValue))
            else 
                local infoItem = playerItem.panInfoItem:clone()
                infoItem:setVisible(true)
                util.bindUINodes(infoItem, infoItem, nil)
                infoItem.txtName:setText(GameDefine.STAT_NAMES[stat.statType])
                infoItem.txtCount:setText(tostring(stat.statValue))
                infoItem.priority = stat.statType
                playerItem.svContent:addChild(infoItem)
            end 
        end 
        playerItem.svContent:layoutVertical1({
            columns = 1,
            lineIntvl = 0,
            needSort = true,
        })
        self.imgBg.panList:addChild(playerItem)
    end 
    local columns = table.maxn(GameCache.accomplishes.statPlayers)
    WidgetExt.panLayoutVertical(self.imgBg.panList, {
                autoHeight = false,
--                columnIntvl = 0, 
                columns = columns, 
                needSort = false,})
end 

function StatisticLayer:onClick_btnShare(sender)
    local tmpFileName = "tmp.jpg"
    -- 移除纹理缓存  
    cc.Director:getInstance():getTextureCache():removeTextureForKey(tmpFileName) 
    -- 截屏  
    cc.utils:captureScreen(function(succeed, outputFile)  
        if succeed then  
            local sp = cc.Sprite:create(outputFile)
            local sz = cc.Director:getInstance():getOpenGLView():getFrameSize()
            local renderTexture = cc.RenderTexture:create(sz.width, sz.height)

            renderTexture:begin()
            sp:setPosition(cc.p(sz.width * 0.5, sz.height * 0.5))
            sp:visit()
            --添加二维码
            local qrcode = cc.Sprite:create("public/qrcode.png")
            local qrSz = qrcode:getContentSize()
            local qranpt = qrcode:getAnchorPoint()
            local pos = cc.p(sz.width - (1 - qranpt.x) * qrSz.width, qranpt.y * qrSz.height)
            qrcode:setPosition(pos)
            qrcode:visit()
            renderTexture:endToLua()

            UIManager:block()
            local fileName = "share.jpg"
            cc.utils:saveRenderTextureToFile(renderTexture, fileName, cc.IMAGE_FORMAT_JPEG, false, function(cobj, savedFileName)
                --delay execute to share to wechat as the thread this callback belongs to is different from the main thread,
                --if we update UI here, crash may be occurred
                local fullPath = savedFileName
                local scheduleID = 0
                scheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
                    UIManager:unblock()
                    printInfo("WechatShare image fullPath: %s", fullPath)
                    UIManager:goTo(Define.SCENE_HOME, "app.modules.wechatShare.WechatShareLightLayer", UIManager.UITYPE_PROMPT, {
                        content = {
                            contentType = Define.WECHAT_SHARE_CONTENT_TYPE_IMAGE,
                            text = fullPath,
                        },
                    })
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleID)
                end, 0.1, false)
            end)
        else  
            UIManager:showTip("截屏失败")  
        end  
    end, tmpFileName)
end 

function StatisticLayer:onClick_btnClose(sender)
    UIManager:goBack(Define.SCENE_HOME, "app.modules.home.HomeLayer", UIManager.UITYPE_FULL_SCREEN)
    Helper.playSoundClick()
end 

return StatisticLayer
--endregion
