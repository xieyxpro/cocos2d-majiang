

print = release_print
math.randomseed(os.time())

--require cocos dependencies
require("config")

local GAME_INTERVAL = 40
cc.Director:getInstance():setAnimationInterval(1 / GAME_INTERVAL)
cc.Director:getInstance():setDisplayStats(DEBUG_FPS)

local openGLView = cc.Director:getInstance():getOpenGLView()
--openGLView:setFrameSize(800, 450)
--openGLView:setFrameSize(1280, 720)

local UILayoutPresets = {
    ["1280x720"] = {width = 1280, height = 720},
}

local frameSize = openGLView:getFrameSize()
local minTolerance = 1.0
local minToleranceLayoutName = nil 
local frameRatio = frameSize.height / frameSize.width
for layoutName, layout in pairs(UILayoutPresets) do 
    local ratio = layout.height / layout.width 
    local tolerance = math.abs(ratio - frameRatio)
    if tolerance < minTolerance then 
        minTolerance = tolerance
        minToleranceLayoutName = layoutName
    end 
end 
local uiPreset = UILayoutPresets[minToleranceLayoutName]
-- for module display
CC_DESIGN_RESOLUTION = {
    width = uiPreset.width,
    height = uiPreset.height,
    autoscale = "SHOW_ALL",
    callback = function(framesize)
--        local ratio = framesize.width / framesize.height
--        if ratio <= 1.34 then
--            -- iPad 768*1024(1536*2048) is 4:3 screen
--            return {autoscale = "SHOW_ALL"}
--        end
        return {autoscale = "SHOW_ALL"}
    end
}

require("cocos.init")

local writablePath = cc.FileUtils:getInstance():getWritablePath()
cc.FileUtils:getInstance():setPopupNotify(false)
--if HOT_UPDATE_ENABLED then 
--    if device.platform == "windows" then
--        cc.FileUtils:getInstance():addSearchPath(writablePath .. "patches\\res\\" .. minToleranceLayoutName .. "\\")
--        cc.FileUtils:getInstance():addSearchPath(writablePath .. "patches\\res\\")
--        cc.FileUtils:getInstance():addSearchPath(writablePath .. "patches\\")
--    else
--        cc.FileUtils:getInstance():addSearchPath(writablePath .. "patches/res/" .. minToleranceLayoutName .. "/")
--        cc.FileUtils:getInstance():addSearchPath(writablePath .. "patches/res/")
--        cc.FileUtils:getInstance():addSearchPath(writablePath .. "patches/")
--    end
--end 
if device.platform == "windows" then
    cc.FileUtils:getInstance():addSearchPath("/res/" .. minToleranceLayoutName .. "/")
    cc.FileUtils:getInstance():addSearchPath("/res/")
else
    cc.FileUtils:getInstance():addSearchPath("res/" .. minToleranceLayoutName .. "/")
    cc.FileUtils:getInstance():addSearchPath("res/")
end
cc.FileUtils:getInstance():addSearchPath("/")
--玩家头像
cc.FileUtils:getInstance():addSearchPath(writablePath .. "playericons/")
cc.FileUtils:getInstance():addSearchPath(writablePath)


if LOG_FILE_WRITE_ENABLE then
    cc.exports.utillog = require("frameworkExt.utillog")
    utillog:Init()
    print = mylogprint
end

openGLView:setDesignResolutionSize(uiPreset.width, uiPreset.height, cc.ResolutionPolicy.SHOW_ALL)

--console listen setup
if DEBUG ~= 0 then 
    local console = cc.Director:getInstance():getConsole()
    console:listenOnTCP(CONSOLE_LISTEN_PORT)
end 

cc.Director:getInstance():setDisplayStats(CC_SHOW_FPS ~= nil and CC_SHOW_FPS or false)

local sharedApplication = cc.Application:getInstance()

--openGLView:setFrameSize(1280, 720)

--local visibleSize = openGLView:getVisibleSize()
--local visibleOrigin = openGLView:getVisibleOrigin()
--local designSize = openGLView:getDesignResolutionSize()
--local devResolution = openGLView:getFrameSize()

local appVersion = sharedApplication:getVersion()
if device.platform == "windows" then 
    appVersion = "1.0.2"
end 
sharedApplication.version = appVersion

printInfo("===================GAME LAUNCH===================")
printInfo("App Version: %s", appVersion)
printInfo("WriteablePath: %s", writablePath)

--检查包版本并删除更新资源
local first = require("first")
if first.appVersion ~= appVersion then 
    local patches = writablePath .. "patches"
    if device.platform == "windows" then 
        os.execute(string.format("del /s /q %s\\", patches))
    else 
        os.execute(string.format("rm -rf %s", patches))
    end 
    package.loaded["first"] = nil
    package.preload["first"] = nil
    cc.FileUtils:getInstance():purgeCachedEntries()
end 

local function main()
    require("updater.LaunchScene").runWithScene()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end