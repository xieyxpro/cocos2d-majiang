--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local RoomListLayer = class("RoomListLayer", cc.Layer)

local GameDefine = require("app.modules.game.GameDefine")

function RoomListLayer:ctor()
    local uiNode = require("HomeScene.achiv.RoomListLayer"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)

    self.imgBg.imgContentBg.panItem:setVisible(false)
    self.imgBg.btnCheckOthers:setVisible(false)--TODO 暂时屏蔽分享

    self.playersHeadImages = {} --{[userid] = {icon_node, ...}, ...}
    
    Event.register("HTTP_PLAY_RECORDS_BASE", self, "HTTP_PLAY_RECORDS_BASE")
    Event.register(EventDefine.ICON_DOWNLOADED, self, "ICON_DOWNLOADED")
end 

function RoomListLayer:onShow()
    local tmpRooms = {}
    for roomGUID, room in pairs(AchivCache.rooms) do 
        table.insert(tmpRooms, room)
    end 
    table.sort(tmpRooms, function(room1, room2)
        return room1.startTime > room2.startTime
    end)
    if #tmpRooms > 0 then 
        self.imgBg.lblEmptyContentTip:setVisible(false)
        for seq, room in pairs(tmpRooms) do 
            local item = self.imgBg.imgContentBg.panItem:clone():addTo(self.imgBg.imgContentBg.svContent)
            util.bindUINodes(item, item, nil)
            item:setVisible(true)
            item.txtRoomID:setText(tostring(room.roomID))
            local strMonth = os.date("%m月", room.startTime)
            local strDay = os.date("%d日", room.startTime)
            local strTime = os.date("%H:%M:%S", room.startTime)
            item.txtMonth:setText(strMonth)
            item.txtDay:setText(strDay)
            item.txtTime:setText(strTime)
            local cnt = 1
            for _, playerInfo in pairs(room.playersInfo) do 
                local pan = item["panP"..tostring(cnt)]
                if pan then 
                    pan.txtName:setText(playerInfo.nickname)
                    pan.txtScore:setText(tostring(playerInfo.score))
                    pan.imgHead:loadTexture(playerInfo.playerIcon)
                    self.playersHeadImages[playerInfo.userid] = self.playersHeadImages[playerInfo.userid] or {}
                    table.insert(self.playersHeadImages[playerInfo.userid], pan.imgHead)
                else 
                    print("ERROR, too many people")
                end 
                cnt = cnt + 1
            end 
            item:setTouchEnabled(true)
            item:addTouchEventListener(function(sender, event)
                if event == ccui.TouchEventType.ended then 
                    AchivCache.curSelectRoom = room
                    AchivCache:requestBaseRecord(room.guid)
                    UIManager:block()
                end 
            end)
        end 
        self.imgBg.imgContentBg.svContent:layoutVertical1({
            columns = 1,
            lineIntvl = 0,
            needSort = false,
        })
    else 
        self.imgBg.lblEmptyContentTip:setVisible(true)
    end 
end 

function RoomListLayer:onClose()
    Event.unregister("HTTP_PLAY_RECORDS_BASE", self, "HTTP_PLAY_RECORDS_BASE")
    Event.unregister(EventDefine.ICON_DOWNLOADED, self, "ICON_DOWNLOADED")
end 

function RoomListLayer:HTTP_PLAY_RECORDS_BASE(data)
    UIManager:unblock()
    if data.err then 
        printInfo("[HTTP_PLAY_RECORDS_BASE] errCode: %d, msg: %s", data.err.code, data.err.msg or "")
        UIManager:showTip("请求回放数据出错")
        return
    else 
        UIManager:goTo(Define.SCENE_HOME, "app.modules.achiv.RollListLayer", UIManager.UITYPE_FULL_SCREEN, nil, false)
    end 
end 

function RoomListLayer:ICON_DOWNLOADED(data)
    if data.err then 
        return
    end 
    local headImages = self.playersHeadImages[data.userid]
    if not headImages then 
        return 
    end 
    for _, imgHead in ipairs(headImages) do 
        local iconFile = data.iconFileName
        if iconFile or iconFile ~= "" then 
            imgHead:loadTexture(iconFile)
        end 
    end 
end

function RoomListLayer:onClick_btnCheckOthers(sender)
    --TODO share to wechat
    UIManager:showTip("coming soon")
    Helper.playSoundClick()
end 

function RoomListLayer:onClick_btnClose(sender)
    UIManager:goBack()
    Helper.playSoundClick()
end 

return RoomListLayer
--endregion
