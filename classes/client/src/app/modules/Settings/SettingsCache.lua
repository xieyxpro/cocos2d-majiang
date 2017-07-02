--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local RoomServer = require("app.modules.login.RoomServer")

local SettingsCache = class("SettingsCache")

function SettingsCache:ctor(arg)
    --从userdefaule加载设置
    AudioExt.musicVolume = UserDefaultExt:get("musicVolume", 0.5)
    AudioExt.effectVolume = UserDefaultExt:get("effectVolume", 0.5)
    AudioExt.musicEnabled = UserDefaultExt:get("musicEnabled", true)
    AudioExt.effectEnabled = UserDefaultExt:get("effectEnabled", true)
    printInfo("AudioExt.musicVolume: %s", tostring(AudioExt.musicVolume))
    printInfo("AudioExt.effectVolume: %s", tostring(AudioExt.effectVolume))
    printInfo("AudioExt.musicEnabled: %s", tostring(AudioExt.musicEnabled))
    printInfo("AudioExt.effectEnabled: %s", tostring(AudioExt.effectEnabled))
end

function SettingsCache:reset()
end 

function SettingsCache:setEffectVolume(volume)
    if AudioExt.effectVolume == volume then 
        return
    end 
    UserDefaultExt:set("effectVolume", volume)
    AudioExt:setEffectVolume(volume)
end 

function SettingsCache:setMusicVolume(volume)
    if AudioExt.musicVolume == volume then 
        return
    end 
    UserDefaultExt:set("musicVolume", volume)
    AudioExt:setMusicVolume(volume)
end 

function SettingsCache:enableEffect(enabled)
    if AudioExt.effectEnabled == enabled then 
        return 
    end 
    UserDefaultExt:set("effectEnabled", enabled)
    AudioExt:enableEffect(enabled)
end 

function SettingsCache:enableMusic(enabled)
    if AudioExt.musicEnabled == enabled then 
        return 
    end 
    UserDefaultExt:set("musicEnabled", enabled)
    AudioExt:enableMusic(enabled)
end 

return SettingsCache
--endregion
