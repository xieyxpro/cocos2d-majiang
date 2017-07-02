--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local SettingsLayer = class("SettingsLayer", cc.Layer)

function SettingsLayer:ctor(params)
    local uiNode = require("HomeScene.Settings.SettingsLayer"):create().root:addTo(self)
    util.bindUINodes(uiNode, self, self)

    util.bindUITouchEvents(self.panRoot, self)
    
    self.imgBg.sldMusicVolume:setPercent(AudioExt.musicVolume * 100)
    self.imgBg.sldEffectVolume:setPercent(AudioExt.effectVolume * 100)
    
    self.imgBg.btnMusic.checkedTexture = "HomeScene/Settings/bg-yingxiao.png"
    self.imgBg.btnMusic.uncheckedTexture = "HomeScene/Settings/bg-yingxiao2.png"
    self.imgBg.btnEffect.checkedTexture = "HomeScene/Settings/bg-yingyue.png"
    self.imgBg.btnEffect.uncheckedTexture = "HomeScene/Settings/bg-yingyue2.png"
    self:setButtonChecked(self.imgBg.btnMusic, AudioExt.musicEnabled)
    self:setButtonChecked(self.imgBg.btnEffect, AudioExt.effectEnabled)
end 

function SettingsLayer:onClose()
end 

function SettingsLayer:setButtonChecked(btn, checked)
    btn.checked = checked 
    if btn.checked then 
        btn:loadTextureNormal(btn.checkedTexture,0)
        btn:loadTexturePressed(btn.checkedTexture,0)
        btn:loadTextureDisabled(btn.checkedTexture,0)
    else 
        btn:loadTextureNormal(btn.uncheckedTexture,0)
        btn:loadTexturePressed(btn.uncheckedTexture,0)
        btn:loadTextureDisabled(btn.uncheckedTexture,0)
    end 
end 

function SettingsLayer:onValueChanged_sldMusicVolume(sender)
    SettingsCache:setMusicVolume(sender:getPercent() / 100)
end 

function SettingsLayer:onValueChanged_sldEffectVolume(sender)
    SettingsCache:setEffectVolume(sender:getPercent() / 100)
end 

function SettingsLayer:onClick_btnMusic(sender)
    self:setButtonChecked(sender, not sender.checked)
    local isSelect = sender.checked
    SettingsCache:enableMusic(isSelect)
    Helper.playSoundClick()
end 

function SettingsLayer:onClick_btnEffect(sender)
    self:setButtonChecked(sender, not sender.checked)
    local isSelect = sender.checked
    SettingsCache:enableEffect(isSelect)
    Helper.playSoundClick()
end 

function SettingsLayer:onClick_btnSwitchAccount(sender)
    --reset all
    UIManager:reset()
    AudioExt:stopBGMusic()
    
    PlayerCache:reset()
    LoginCache:reset()
    HomeCache:reset()
    GameCache:reset()
    SettingsCache:reset()
    AchivCache:reset()

    --offline
    LoginCache:disconnHome()
    HomeCache:disconnGame()

    --reset wechat
    WechatSDK:eraseWechatAccount()

    --go to login
    UIManager:goTo(Define.SCENE_LOGIN, "app.modules.login.LoginLayer", UIManager.UITYPE_FULL_SCREEN)
end 

function SettingsLayer:onClick_btnClose(sender)
    Helper.playSoundClick()
    UIManager:goBack()
end 

function SettingsLayer:onTouchEnded_panRoot(touch, eventTouch)
    UIManager:goBack()
end 

return SettingsLayer
--endregion
