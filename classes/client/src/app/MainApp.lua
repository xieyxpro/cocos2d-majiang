--xpcall(function()
--    require("init")
--end, function(err)
--    print(err)
--end)

local MainApp = {}

function MainApp.run()
    UIManager:goTo(Define.SCENE_LOGIN, "app.modules.login.LoginLayer", UIManager.UITYPE_FULL_SCREEN)
end 

function MainApp:onEnterBackground()
    AudioExt:pauseAllSound()
end

function MainApp:onEnterForeground()
    AudioExt:resumeAllSound()
end

local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
local customListenerBg = cc.EventListenerCustom:create("APP_ENTER_BACKGROUND_EVENT",
							handler(MainApp, MainApp.onEnterBackground))
eventDispatcher:addEventListenerWithFixedPriority(customListenerBg, 1)
local customListenerFg = cc.EventListenerCustom:create("APP_ENTER_FOREGROUND_EVENT",
							handler(MainApp, MainApp.onEnterForeground))
eventDispatcher:addEventListenerWithFixedPriority(customListenerFg, 1)

return MainApp
