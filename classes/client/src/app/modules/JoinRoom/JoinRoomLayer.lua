--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local ROOM_ID_LEN = 6

local JoinRoomLayer = class("JoinRoomLayer", cc.Layer)

function JoinRoomLayer:ctor()
    local uiNode = require("HomeScene.joinRoom.JoinRoomLayer"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)

    util.bindUITouchEvents(self.rootPanel, self)
    
    Event.register(EventDefine.ROOMNUM_QUERY_ROOM_NUM_ERROR, self, "ROOMNUM_QUERY_ROOM_NUM_ERROR")
    Event.register("GAME_LOGON_MS_LOGONRES", self, "GAME_LOGON_MS_LOGONRES")
    Event.register("GAME_LOGON_MS_FINISH", self, "GAME_LOGON_MS_FINISH")
    Event.register("MS_JOIN_ROOM", self, "MS_JOIN_ROOM")
    Event.register("MS_ROOM_INFO", self, "MS_ROOM_INFO")
    Event.register("MS_GAME_SCENE_FREE", self, "MS_GAME_SCENE_FREE")
    Event.register("MS_GAME_SCENE_PLAY", self, "MS_GAME_SCENE_PLAY")
    

    self.keyboardMap = {
        [0] = self.imgBg.panKeyboard.btn0,
        [1] = self.imgBg.panKeyboard.btn1,
        [2] = self.imgBg.panKeyboard.btn2,
        [3] = self.imgBg.panKeyboard.btn3,
        [4] = self.imgBg.panKeyboard.btn4,
        [5] = self.imgBg.panKeyboard.btn5,
        [6] = self.imgBg.panKeyboard.btn6,
        [7] = self.imgBg.panKeyboard.btn7,
        [8] = self.imgBg.panKeyboard.btn8,
        [9] = self.imgBg.panKeyboard.btn9,
    }
    self.roomIDMap = {
        [1] = self.imgBg.panRoomID.imgNum1.lbl,
        [2] = self.imgBg.panRoomID.imgNum2.lbl,
        [3] = self.imgBg.panRoomID.imgNum3.lbl,
        [4] = self.imgBg.panRoomID.imgNum4.lbl,
        [5] = self.imgBg.panRoomID.imgNum5.lbl,
        [6] = self.imgBg.panRoomID.imgNum6.lbl,
    }
    for i, btn in pairs(self.keyboardMap) do 
        btn.value = i
    end 
    self.inputProgress = 0

    self:clear()
    --TODO for testing
    if device.platform == "windows" then
        local roomID = tostring(UserDefaultExt:get("roomID", 900101))
        for i = 1, roomID:len(), 1 do 
            self:input(string.sub(roomID, i, i))
        end        
    end 
end 

function JoinRoomLayer:ROOMNUM_QUERY_ROOM_NUM_ERROR(data)    
    Helper.showError(ErrorDefine[ErrorDefine.JOIN_ROOM_FAILED_NOT_EXISTS])
    UIManager:unblock()
end

function JoinRoomLayer:GAME_LOGON_MS_LOGONRES(data)
    if data.err and data.err ~= 0 then 
        Helper.showError(data.err)
        UIManager:unblock()
        HomeCache:disconnGame()
    else
--        UIManager:showTip("登录游戏服务器成功")
    end 
end 

function JoinRoomLayer:GAME_LOGON_MS_FINISH(data)
    local roomIDNumbers = {}
    for _, lbl in ipairs(self.roomIDMap) do 
        table.insert(roomIDNumbers, lbl:getString())
    end 
    local roomID = table.concat(roomIDNumbers)
    Network:send(Define.SERVER_GAME, "mc_join_room", {
        roomID = tonumber(roomID),
    })
end

function JoinRoomLayer:MS_JOIN_ROOM(data)
    if data and data.err ~= 0 then 
        Helper.showError(data.err)
        HomeCache:disconnGame()
        UIManager:unblock()
    end 
end

function JoinRoomLayer:MS_ROOM_INFO(data)
    if data and data.err and data.err ~= 0 then 
        Helper.showError(data.err)
        HomeCache:disconnGame()
        UIManager:unblock()
    else
--        UIManager:showTip("进入房间成功")
        Network:send(Define.SERVER_GAME, "mc_gamescene_load_finish",nil)
    end
end 

function JoinRoomLayer:MS_GAME_SCENE_FREE(data)
    UIManager:goBack()
    UIManager:goTo(Define.SCENE_GAME, "app.modules.game.GameLayer", UIManager.UITYPE_FULL_SCREEN)
    UIManager:unblock()
end 

function JoinRoomLayer:MS_GAME_SCENE_PLAY(data)
    UIManager:goBack()
    UIManager:goTo(Define.SCENE_GAME, "app.modules.game.GameLayer", UIManager.UITYPE_FULL_SCREEN)
    UIManager:unblock()
end 

function JoinRoomLayer:onShow()
end 

function JoinRoomLayer:onClose()
    Event.unregister(EventDefine.ROOMNUM_QUERY_ROOM_NUM_ERROR, self, "ROOMNUM_QUERY_ROOM_NUM_ERROR")
    Event.unregister("GAME_LOGON_MS_LOGONRES", self, "GAME_LOGON_MS_LOGONRES")
    Event.unregister("GAME_LOGON_MS_FINISH", self, "GAME_LOGON_MS_FINISH")
    Event.unregister("MS_JOIN_ROOM", self, "MS_JOIN_ROOM")
    Event.unregister("MS_ROOM_INFO", self, "MS_ROOM_INFO")
    Event.unregister("MS_GAME_SCENE_FREE", self, "MS_GAME_SCENE_FREE")
    Event.unregister("MS_GAME_SCENE_PLAY", self, "MS_GAME_SCENE_PLAY")
end 

function JoinRoomLayer:input(value)
    if self.inputProgress >= ROOM_ID_LEN then 
        return 
    end 
    Helper.playSoundSelect()
    self.inputProgress = self.inputProgress + 1
    self.roomIDMap[self.inputProgress]:setString(tostring(value))
    if self.inputProgress >= ROOM_ID_LEN then
        local roomIDNumbers = {}
        for _, lbl in ipairs(self.roomIDMap) do 
            table.insert(roomIDNumbers, lbl:getString())
        end 
        local roomID = table.concat(roomIDNumbers)
        HomeCache:queryRoomId(roomID)
        UIManager:block()
    end 
end 

function JoinRoomLayer:del()
    if self.inputProgress <= 0 then 
        return
    end 
    self.roomIDMap[self.inputProgress]:setString("")
    self.inputProgress = self.inputProgress - 1
end 

function JoinRoomLayer:clear()
    for i = 1, 6, 1 do 
        self.roomIDMap[i]:setString("")
    end 
    self.inputProgress = 0
end 

function JoinRoomLayer:onClick_btnDelete(sender)
    Helper.playSoundSelect()
    self:del()
end 

function JoinRoomLayer:onClick_btnClear(sender)
    Helper.playSoundSelect()
    self:clear()
end 

function JoinRoomLayer:onClick_btn1(sender)
    self:input(sender.value)
end 

function JoinRoomLayer:onClick_btn2(sender)
    self:input(sender.value)
end 

function JoinRoomLayer:onClick_btn3(sender)
    self:input(sender.value)
end 

function JoinRoomLayer:onClick_btn4(sender)
    self:input(sender.value)
end 

function JoinRoomLayer:onClick_btn5(sender)
    self:input(sender.value)
end 

function JoinRoomLayer:onClick_btn6(sender)
    self:input(sender.value)
end 

function JoinRoomLayer:onClick_btn7(sender)
    self:input(sender.value)
end 

function JoinRoomLayer:onClick_btn8(sender)
    self:input(sender.value)
end 

function JoinRoomLayer:onClick_btn9(sender)
    self:input(sender.value)
end 

function JoinRoomLayer:onClick_btn0(sender)
    self:input(sender.value)
end 

function JoinRoomLayer:onClick_btnClose(sender)
    Helper.playSoundClick()
    UIManager:goBack()
end 

function JoinRoomLayer:onTouchEnded_rootPanel(touch, eventTouch)
    UIManager:goBack()
end 

return JoinRoomLayer
--endregion
