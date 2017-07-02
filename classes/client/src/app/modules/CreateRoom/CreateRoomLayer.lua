--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local GameDefine = require("app.modules.game.GameDefine")
local t_create_room = require("res.cn.client_config.t_create_room")

local CreateRoomLayer = class("CreateRoomLayer", cc.Layer)

function CreateRoomLayer:ctor()
    local uiNode = require("HomeScene.CreateRoom.CreateRoomLayer"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)

    util.bindUITouchEvents(self.rootPanel, self)

    self.imgBg.cbRolls8:setSelectedExt(true)
    self.imgBg.cbRolls16:setSelectedExt(false)
    self.imgBg.cbRolls8.txtDesc:setText(string.format("%d局（房卡x%d）", t_create_room[8].rolls, t_create_room[8].need_room_cards))
    self.imgBg.cbRolls16.txtDesc:setText(string.format("%d局（房卡x%d）", t_create_room[16].rolls, t_create_room[16].need_room_cards))
    
    if Launcher.channel == Launcher.CHANNELS.DEV then
        self.imgBg.cbPeople2:setVisible(true)
        self.imgBg.cbPeople3:setVisible(true)
        self.imgBg.cbPeople4:setVisible(true)
        self.imgBg.cbRobot:setVisible(true)
        self.imgBg.txtPeople:setVisible(true)
        self.imgBg.txtRobot:setVisible(true)
    else
        self.imgBg.cbPeople2:setVisible(false)
        self.imgBg.cbPeople3:setVisible(false)
        self.imgBg.cbPeople4:setVisible(false)
        self.imgBg.cbRobot:setVisible(false)
        self.imgBg.txtPeople:setVisible(false)
        self.imgBg.txtRobot:setVisible(false)
    end  

    do 
        self.imgBg.txtFengDing:setVisible(false)
        self.imgBg.cbOptionalFengDing80:setVisible(false)
        self.imgBg.cbOptionalFengDing160:setVisible(false)
        self.imgBg.cbOptionalFengDingNo:setVisible(false)
    end 

    self.imgBg.cbPeople2:setSelectedExt(false)
    self.imgBg.cbPeople3:setSelectedExt(false)
    self.imgBg.cbPeople4:setSelectedExt(true)

    self.imgBg.cbOptionalBaoZi:setSelectedExt(false)

    self.imgBg.cbRobot:setSelectedExt(false)
    
    self.imgBg.cbOptionalBaoZiNo:setSelectedExt(true)
    self.imgBg.cbOptionalBaoZi:setSelectedExt(false)
    
    self.imgBg.cbOptionalFengDing80:setSelectedExt(true)
    self.imgBg.cbOptionalFengDing160:setSelectedExt(false)
    self.imgBg.cbOptionalFengDingNo:setSelectedExt(false)

    self.fans = 3
    self.imgBg.imgFans.lblFans:setString(tostring(self.fans))

    Event.register("GAME_LOGON_MS_LOGONRES", self, "GAME_LOGON_MS_LOGONRES")
    Event.register("GAME_LOGON_MS_FINISH", self, "GAME_LOGON_MS_FINISH")
    Event.register("MS_CREATE_ROOM", self, "MS_CREATE_ROOM")
    Event.register("MS_ROOM_INFO", self, "MS_ROOM_INFO")
    Event.register("MS_GAME_SCENE_FREE", self, "MS_GAME_SCENE_FREE")
    Event.register("MS_GAME_SCENE_PLAY", self, "MS_GAME_SCENE_PLAY")
end 

function CreateRoomLayer:GAME_LOGON_MS_LOGONRES(data)
    printInfo("CreateRoomLayer:GAME_LOGON_MS_LOGONRES")
    if data.err and data.err ~= 0 then 
        Helper.showError(data.err)
        UIManager:unblock()
    else
--        UIManager:showTip("登录游戏服务器成功")
    end 
end 

function CreateRoomLayer:GAME_LOGON_MS_FINISH(data)
    printInfo("CreateRoomLayer:GAME_LOGON_MS_FINISH")    
    local data = {}
    if self.imgBg.cbRolls8:getSelectedExt() then 
        data.rolls = 8
    end 
    if self.imgBg.cbRolls16:getSelectedExt() then 
        data.rolls = 16
    end 
    data.people = 4
    if Launcher.channel == Launcher.CHANNELS.DEV then
        if self.imgBg.cbPeople2:getSelectedExt() then 
            data.people = 2
        end 
        if self.imgBg.cbPeople3:getSelectedExt() then 
            data.people = 3
        end 
        if self.imgBg.cbPeople4:getSelectedExt() then 
            data.people = 4
        end 
    end 
    local createParams = {}
    createParams.mjType = GameDefine.MJ_TYPE_ZHUANZHUAN
    createParams.fans = self.fans
    if Launcher.channel == Launcher.CHANNELS.DEV then
        createParams.robot = self.imgBg.cbRobot:getSelectedExt()
    end 
    if self.imgBg.cbOptionalBaoZi:getSelectedExt() then 
        createParams.options = "baoZi"
    end 
    if self.imgBg.cbOptionalFengDing80:getSelectedExt() then 
        createParams.fengDingMulti = 1
    end 
    if self.imgBg.cbOptionalFengDing160:getSelectedExt() then 
        createParams.fengDingMulti = 2
    end 
    if self.imgBg.cbOptionalFengDingNo:getSelectedExt() then 
        createParams.fengDingMulti = 0
    end 
    data.createParams = json.encode(createParams)
    Network:send(Define.SERVER_GAME, "mc_create_room", data)
end

function CreateRoomLayer:MS_CREATE_ROOM(data)
    printInfo("CreateRoomLayer:MS_CREATE_ROOM")
    if data and data.err ~= 0 then 
        Helper.showError(data.err)
        UIManager:unblock()
    end 
end

function CreateRoomLayer:MS_ROOM_INFO(data)
    printInfo("CreateRoomLayer:MS_ROOM_INFO")
    if data and data.err and data.err ~= 0 then 
        Helper.showError(data.err)
        UIManager:unblock()
    else
--        UIManager:showTip("进入房间成功")
        Network:send(Define.SERVER_GAME, "mc_gamescene_load_finish",nil)
    end
end 

function CreateRoomLayer:MS_GAME_SCENE_FREE(data)
    printInfo("CreateRoomLayer:MS_GAME_SCENE_FREE")
    UIManager:goBack()
    UIManager:goTo(Define.SCENE_GAME, "app.modules.game.GameLayer", UIManager.UITYPE_FULL_SCREEN)
    UIManager:unblock()
end 

function CreateRoomLayer:MS_GAME_SCENE_PLAY(data)
    printInfo("CreateRoomLayer:MS_GAME_SCENE_PLAY")
    UIManager:goBack()
    UIManager:goTo(Define.SCENE_GAME, "app.modules.game.GameLayer", UIManager.UITYPE_FULL_SCREEN)
    UIManager:unblock()
end 

function CreateRoomLayer:onShow()
end 

function CreateRoomLayer:onClose()
    Event.unregister("GAME_LOGON_MS_LOGONRES", self, "GAME_LOGON_MS_LOGONRES")
    Event.unregister("GAME_LOGON_MS_FINISH", self, "GAME_LOGON_MS_FINISH")
    Event.unregister("MS_CREATE_ROOM", self, "MS_CREATE_ROOM")
    Event.unregister("MS_ROOM_INFO", self, "MS_ROOM_INFO")
    Event.unregister("MS_GAME_SCENE_FREE", self, "MS_GAME_SCENE_FREE")
    Event.unregister("MS_GAME_SCENE_PLAY", self, "MS_GAME_SCENE_PLAY")
end 

function CreateRoomLayer:onClick_btnCreateRoom(sender)
    local needRoomCardNum = 0
    if self.imgBg.cbRolls8:getSelectedExt() then 
        needRoomCardNum = t_create_room[8].need_room_cards
    end 
    if self.imgBg.cbRolls16:getSelectedExt() then 
        needRoomCardNum = t_create_room[16].need_room_cards
    end 
    if PlayerCache.roomcardnum < needRoomCardNum then 
        UIManager:showTip("房卡不足")
        return
    end 
    HomeCache:loginGame()
    UIManager:block()
    Helper.playSoundClick()
end 

function CreateRoomLayer:onClick_btnClose(sender)
    Helper.playSoundClick()
    UIManager:goBack()
end 

function CreateRoomLayer:onTouchEnded_rootPanel(touch, eventTouch)
    UIManager:goBack()
end 

function CreateRoomLayer:onChecked_cbRolls8(sender, isSelect)
    self.imgBg.cbRolls8:setSelectedExt(true)
    self.imgBg.cbRolls16:setSelectedExt(false)
    Helper.playSoundSelect()
end 

function CreateRoomLayer:onChecked_cbRolls16(sender, isSelect)
    self.imgBg.cbRolls8:setSelectedExt(false)
    self.imgBg.cbRolls16:setSelectedExt(true)
    Helper.playSoundSelect()
end 

function CreateRoomLayer:onChecked_cbOptionalBaoZi(sender, isSelect)
    self.imgBg.cbOptionalBaoZiNo:setSelectedExt(false)
    self.imgBg.cbOptionalBaoZi:setSelectedExt(true)
    Helper.playSoundSelect()
end 

function CreateRoomLayer:onChecked_cbOptionalBaoZiNo(sender, isSelect)
    self.imgBg.cbOptionalBaoZiNo:setSelectedExt(true)
    self.imgBg.cbOptionalBaoZi:setSelectedExt(false)
    Helper.playSoundSelect()
end 

function CreateRoomLayer:onChecked_cbOptionalFengDing80(sender, isSelect)
    self.imgBg.cbOptionalFengDing80:setSelectedExt(true)
    self.imgBg.cbOptionalFengDing160:setSelectedExt(false)
    self.imgBg.cbOptionalFengDingNo:setSelectedExt(false)
    Helper.playSoundSelect()
end 

function CreateRoomLayer:onChecked_cbOptionalFengDing160(sender, isSelect)
    self.imgBg.cbOptionalFengDing80:setSelectedExt(false)
    self.imgBg.cbOptionalFengDing160:setSelectedExt(true)
    self.imgBg.cbOptionalFengDingNo:setSelectedExt(false)
    Helper.playSoundSelect()
end 

function CreateRoomLayer:onChecked_cbOptionalFengDingNo(sender, isSelect)
    self.imgBg.cbOptionalFengDing80:setSelectedExt(false)
    self.imgBg.cbOptionalFengDing160:setSelectedExt(false)
    self.imgBg.cbOptionalFengDingNo:setSelectedExt(true)
    Helper.playSoundSelect()
end 

function CreateRoomLayer:onClick_btnAddFans(sender)
    self.fans = self.fans + 1
    if self.fans > 6 then 
        UIManager:showTip("最大只能设置6番")
    end 
    self.fans = self.fans > 6 and 6 or self.fans
    self.imgBg.imgFans.lblFans:setString(tostring(self.fans))
    Helper.playSoundClick()
end 

function CreateRoomLayer:onClick_btnSubFans(sender)
    self.fans = self.fans - 1
    if self.fans < 3 then 
        UIManager:showTip("至少3番起胡")
    end 
    self.fans = self.fans < 3 and 3 or self.fans
    self.imgBg.imgFans.lblFans:setString(tostring(self.fans))
    Helper.playSoundClick()
end 


function CreateRoomLayer:onChecked_cbPeople2(sender, isSelect)
    self.imgBg.cbPeople2:setSelectedExt(true)
    self.imgBg.cbPeople3:setSelectedExt(false)
    self.imgBg.cbPeople4:setSelectedExt(false)
    Helper.playSoundSelect()
end 

function CreateRoomLayer:onChecked_cbPeople3(sender, isSelect)
    self.imgBg.cbPeople2:setSelectedExt(false)
    self.imgBg.cbPeople3:setSelectedExt(true)
    self.imgBg.cbPeople4:setSelectedExt(false)
    Helper.playSoundSelect()
end 

function CreateRoomLayer:onChecked_cbPeople4(sender, isSelect)
    self.imgBg.cbPeople2:setSelectedExt(false)
    self.imgBg.cbPeople3:setSelectedExt(false)
    self.imgBg.cbPeople4:setSelectedExt(true)
    Helper.playSoundSelect()
end 

function CreateRoomLayer:onChecked_cbRobot(sender, isSelect)
    self.imgBg.cbRobot:setSelectedExt(isSelect)
    Helper.playSoundSelect()
end 

return CreateRoomLayer
--endregion
