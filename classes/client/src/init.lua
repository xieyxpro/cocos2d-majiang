--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local inits = {
    --core require
    function()
        require("core.functional")
    end,
    function()
        cc.exports.Event = require("core.Event")
    end,
    function()
        require("core.protobuf")
    end,
    --require defines
    function()
        cc.exports.EventDefine = require("EventDefine")
    end,
    function()
        cc.exports.Define = require("res.Define")
    end,
    function()
        cc.exports.ErrorDefine = require("res.errdefine")
    end,
    --require frameworkExt
    function()
        require("frameworkExt.funcExt")
    end,
    function()
        cc.exports.util = require("frameworkExt.util")
    end,
    function()
        cc.exports.utilfile = require("frameworkExt.utilfile")
    end,
    function()
        cc.exports.AudioExt = require("frameworkExt.Sound")
    end,
    function()
        cc.exports.SchedulerExt = require("frameworkExt.SchedulerExt")
    end,
    function()
        cc.exports.Timer = require("frameworkExt.Timer")
    end,
    function()
        cc.exports.WidgetExt = require("frameworkExt.WidgetExt")
    end,
    function()
        cc.exports.UserDefaultExt = require("frameworkExt.UserDefaultExt")
    end,
    function()
        cc.exports.RichTextEx = require("frameworkExt.RichTextEx")
    end,
    --require global
    function()
        cc.exports.global = require("global")
    end,
    --require helper
    function()
        cc.exports.Helper = require("Helper")
    end,
    --require config tables

    --require launcher
    function()
        cc.exports.Launcher = require("updater.Launcher")
    end,
    --require manager
    function()
        cc.exports.UIManager = require("app.managers.UIManager"):create()
    end,
    function()
        cc.exports.Network = require("app.managers.Network"):create()
    end,
    function()
        cc.exports.IconManager = require("app.managers.IconManager"):create()
    end,
    --cache require
    function()
        cc.exports.PlayerCache = require("app.PlayerCache"):create()
    end,
    function()
        cc.exports.LoginCache = require("app.modules.login.LoginCache"):create()
    end,
    function()
        cc.exports.HomeCache = require("app.modules.home.HomeCache"):create()
    end,
    function()
        cc.exports.GameCache = require("app.modules.game.GameCache"):create()
    end,
    function()
        cc.exports.SettingsCache = require("app.modules.Settings.SettingsCache"):create()
    end,
    function()
        cc.exports.AchivCache = require("app.modules.achiv.AchivCache"):create()
    end,
    function()
        cc.exports.PhoneState = require("app.sdk.PhoneState")
    end,
    --sdk init
    function()
        local targetPlatform = cc.Application:getInstance():getTargetPlatform()
        cc.exports.GameApiSDK = require("app.sdk.GameApiSDK")
        cc.exports.PlatformHelper = require("app.sdk.PlatformHelper")

        local WechatSDK = require("app.sdk.WechatSDK")
        WechatSDK:registerwx()
        cc.exports.WechatSDK = WechatSDK
        if device.platform == "android" or device.platform == "ios" then       

            local AmapSDK = require("app.sdk.AmapSDK")
            AmapSDK:ConfigLocationOption(false,false)
            AmapSDK:StartLocation()
            cc.exports.AmapSDK = AmapSDK

            local FileUpload = require("app.sdk.FileUpload")
            FileUpload:Init()
            cc.exports.FileUpload = FileUpload
        
            Event.register(EventDefine.PHONE_STATE_NETWORK_TYPE_CHANGE,utillog,"networkTypeChanged")
        end
        local VoiceSDK = require("app.sdk.VoiceSDK")
        cc.exports.VoiceSDK = VoiceSDK
    end,
    -- talkingdata
    function()
        local TalkingDataSDK = require("app.sdk.TalkingDataSDK")
        cc.exports.TalkingDataSDK = TalkingDataSDK
    end,
}
return inits 

--xpcall(function()

--    --core require
--    require("core.functional")
--    cc.exports.Event = require("core.Event")
--    require("core.protobuf")

--    --require defines
--    cc.exports.EventDefine = require("EventDefine")
--    cc.exports.Define = require("res.Define")
--    cc.exports.ErrorDefine = require("res.errdefine")

--    --require frameworkExt
--    require("frameworkExt.funcExt")
--    cc.exports.util = require("frameworkExt.util")
--    cc.exports.utilfile = require("frameworkExt.utilfile")
--    cc.exports.AudioExt = require("frameworkExt.Sound")
--    cc.exports.SchedulerExt = require("frameworkExt.SchedulerExt")
--    cc.exports.Timer = require("frameworkExt.Timer")
--    cc.exports.WidgetExt = require("frameworkExt.WidgetExt")
--    cc.exports.UserDefaultExt = require("frameworkExt.UserDefaultExt")
--    cc.exports.RichTextEx = require("frameworkExt.RichTextEx")

--    --require global
--    cc.exports.global = require("global")

--    --require res
--    cc.exports.Helper = require("Helper")

--    --require config tables

--    cc.exports.Launcher = require("updater.Launcher")

--    --require manager
--    cc.exports.UIManager = require("app.managers.UIManager"):create()
--    cc.exports.Network = require("app.managers.Network"):create()
--    cc.exports.IconManager = require("app.managers.IconManager"):create()

--    --cache require
--    cc.exports.PlayerCache = require("app.PlayerCache"):create()
--    cc.exports.LoginCache = require("app.modules.login.LoginCache"):create()
--    cc.exports.HomeCache = require("app.modules.home.HomeCache"):create()
--    cc.exports.GameCache = require("app.modules.game.GameCache"):create()
--    cc.exports.SettingsCache = require("app.modules.Settings.SettingsCache"):create()
--    cc.exports.AchivCache = require("app.modules.achiv.AchivCache"):create()

--    cc.exports.PhoneState = require("app.sdk.PhoneState")
----    cc.exports.PhoneState = PhoneState

--    --sdk init
--    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
--    cc.exports.GameApiSDK = require("app.sdk.GameApiSDK")
--    cc.exports.PlatformHelper = require("app.sdk.PlatformHelper")

--    local WechatSDK = require("app.sdk.WechatSDK")
--    WechatSDK:registerwx()
--    cc.exports.WechatSDK = WechatSDK
--    if device.platform == "android" or device.platform == "ios" then       

--        local AmapSDK = require("app.sdk.AmapSDK")
--        AmapSDK:ConfigLocationOption(false,false)
--        AmapSDK:StartLocation()
--        cc.exports.AmapSDK = AmapSDK

--        local FileUpload = require("app.sdk.FileUpload")
--        FileUpload:Init()
--        cc.exports.FileUpload = FileUpload

--        Event.register(EventDefine.PHONE_STATE_NETWORK_TYPE_CHANGE,utillog,"networkTypeChanged")
--    end
--    local VoiceSDK = require("app.sdk.VoiceSDK")
--    cc.exports.VoiceSDK = VoiceSDK
--    -- talkingdata
--    local TalkingDataSDK = require("app.sdk.TalkingDataSDK")
--    cc.exports.TalkingDataSDK = TalkingDataSDK

--end, function(msg)
--    assert(false, msg)
--end)
--endregion
