--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local Updater = require("src.updater.Updater"):create()

xpcall(function()
    Updater:init()
    if Updater.err.code ~= 0 then 

    else 
        Updater:start()
    end 
end, function(msg)
    print(msg)
end)
--local test = {}

--local function ttt(filename)
--	local fileUtils = cc.FileUtils:getInstance()
--    print(fileUtils:getWritablePath())
--    print(fileUtils:writeStringToFile("bbbbbbbbbbbbbbb", "tmp/bb/cc/ttt.txt"))
--    print(fileUtils:createDirectory("tmp/bb/cc"))
--    print(fileUtils:fullPathForFilename("tmp/bb/cc/ttt.txt"))
--end

--function test.run()
--    Updater:init()
--    if Updater.err.code ~= 0 then 

--    else 
--        Updater:start()
--    end 
--    local xht = cc.XMLHttpRequest:new()
--    xht.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
--    xht:open("GET", "http://192.16dd8.1.87/aaa/errdefine.lua")
--    local function onReadyStateChange()
--        local status = "Http Status Code: " .. xht.statusText
--        print(xht.timeout)
--        print(xht.readyState)
--        print(xht.status)
--        print(xht.statusText)
--        print(xht.responseText)
--        print(xht.response)
--    end 
--    xht:registerScriptHandler(onReadyStateChange)
--    xht:send()
--    ttt()
--    require("updater.init")
--    print(bb)
--    local aa = cc.HttpRequest:getInstance()
--    print(aa)
--    require("init")
--    UIManager:goTo("LaunchScene", "app.modules.launch.LaunchScene", UIManager.UITYPE_FULL_SCREEN)
--    UIManager:goTo("LaunchScene", "app.modules.game.GameLayer", UIManager.UITYPE_FULL_SCREEN)
--    Updater:_downloadFile("http://192.168.1.87/aaa/errdefine.lua", 
--                Launcher.RequestType.RES)
--end 

--return test
--endregion
