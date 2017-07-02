--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local PlayerInfoLayer = class("PlayerInfoLayer", cc.Layer)

--params.player =
--{
--    nickname = string,
--    icon = string,
--    userid = int,
--    gender = int,
--    ip = string,
--    city = string,
--    district = string,
--}
function PlayerInfoLayer:ctor(params)
    local uiNode = require("HomeScene.PlayerInfo.PlayerInfoLayer"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)

    util.bindUITouchEvents(self.rootPanel, self)

    self.imgBg.imgGender:ignoreContentAdaptWithSize(true)

    self.player = params.player
end 

function PlayerInfoLayer:onShow()
    self.imgBg.imgHeadFrame.imgHead:loadTexture(self.player.icon)
    WidgetExt.clipPhotoWithFrame(self.imgBg.imgHeadFrame, self.imgBg.imgHeadFrame.imgHead, "public/bg-dinlangtouxiang1.png")
    self.imgBg.lblNickName:setString(self.player.nickname)
    self.imgBg.lblID:setString(tostring(self.player.userid))
    if self.player.gender == Define.GENDER_FEMALE then 
        self.imgBg.imgGender:loadTexture("public/bg-nu.png")
        self.imgBg.lblGender:setString("女生")
    else 
        self.imgBg.imgGender:loadTexture("public/bg-nan.png")
        self.imgBg.lblGender:setString("男生")
    end 
    if self.player.ip and self.player.ip ~= "" then 
        self.imgBg.lblIP:setText(self.player.ip)
    end 

    self.player.city = self.player.city or ""
    self.player.district = self.player.district or ""
    printInfo("City: %s", self.player.city)
    printInfo("District: %s", self.player.district)
    local addr = self.player.city .. self.player.district
    if addr ~= "" then 
        self.imgBg.lblLocation:setText(addr)
    end 
end 

function PlayerInfoLayer:onClose()

end 

function PlayerInfoLayer:onTouchEnded_rootPanel(touch, eventTouch)
    UIManager:goBack()
end 

return PlayerInfoLayer
--endregion
