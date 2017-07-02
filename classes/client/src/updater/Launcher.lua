--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local Launcher = {}

Launcher.CHANNELS = {
    DEV = "dev",
    SHENHE = "shenhe",
    TEST = "test",
}

-- CDN服务器地址
Launcher.firstCDN = "http://ojaqvi3c9.bkt.clouddn.com/hgmj"

-- 更新文件后缀
Launcher.tmpSuffix = ".tmp"

--安装包名称
Launcher.packageNames = {
    android = "__hgmj.apk",
    ios = "",
}

--渠道
Launcher.channel = Launcher.CHANNELS.DEV

--下载重试次数
Launcher.DOWNLOADRETRYTIMES = 10

--当如果下载到的文件路径名包含下面的关键字，将触发重启操作
Launcher.RebootTriggerFileName = "src/updater"

Launcher.writeablePath = cc.FileUtils:getInstance():getWritablePath() .. "patches/"

Launcher.UPDATE_STATUS = {
    NONE = 0, 
    CHECK_UPDATE = 1, --检查更新
    FILES_COMPARE = 2, --文件对比
    CHECK_COMPLETED = 3, --检查完成
    DOWNLOADING = 4, --正在下载更新
    POST_DOWNLOAD = 5, --正在处理已下载内容
    UNZIP = 6, --正在解压
    DONE = 7, --更新完成
}

-- 操作系统
Launcher.platform    = "unknown"

-- 模式
Launcher.model       = "unknown"

local sharedApplication = cc.Application:getInstance()
local sharedDirector = cc.Director:getInstance()
local target = sharedApplication:getTargetPlatform()

cc.PLATFORM_OS_WINDOWS = 0
cc.PLATFORM_OS_LINUX   = 1
cc.PLATFORM_OS_MAC     = 2
cc.PLATFORM_OS_ANDROID = 3
cc.PLATFORM_OS_IPHONE  = 4
cc.PLATFORM_OS_IPAD    = 5
cc.PLATFORM_OS_BLACKBERRY = 6
cc.PLATFORM_OS_NACL    = 7
cc.PLATFORM_OS_EMSCRIPTEN = 8
cc.PLATFORM_OS_TIZEN   = 9
cc.PLATFORM_OS_WINRT   = 10
cc.PLATFORM_OS_WP8     = 11

if target == cc.PLATFORM_OS_WINDOWS then
    Launcher.platform = "windows"
elseif target == cc.PLATFORM_OS_MAC then
    Launcher.platform = "mac"
elseif target == cc.PLATFORM_OS_ANDROID then
    Launcher.platform = "android"
elseif target == cc.PLATFORM_OS_IPHONE or target == cc.PLATFORM_OS_IPAD then
    Launcher.platform = "ios"
    if target == cc.PLATFORM_OS_IPHONE then
        Launcher.model = "iphone"
    else
        Launcher.model = "ipad"
    end
elseif target == cc.PLATFORM_OS_WINRT then
    Launcher.platform = "winrt"
elseif target == cc.PLATFORM_OS_WP8 then
    Launcher.platform = "wp8"
end

--App版本
if target == cc.PLATFORM_OS_WINDOWS then
    Launcher.appVersion = "1.0.2"
else 
    local sharedApplication = cc.Application:getInstance()
    Launcher.appVersion = sharedApplication:getVersion()
end 

-- 更新文件列表文件名
if target ~= cc.PLATFORM_OS_WINDOWS then
    Launcher.luaSuffix = "luac"
else 
    Launcher.luaSuffix = "lua"
end 
-- 更新文件列表文件名
if target ~= cc.PLATFORM_OS_WINDOWS then
    Launcher.firstFileName = "src/first.luac"
    Launcher.firstFileShortName = "first.luac"
    Launcher.flistFileName = "src/flist.luac"
    Launcher.flistFileShortName = "flist.luac"
else 
    Launcher.firstFileName = "src/first.lua"
    Launcher.firstFileShortName = "first.lua"
    Launcher.flistFileName = "src/flist.lua"
    Launcher.flistFileShortName = "flist.lua"
end 


-- 读取文件内容，返回包含文件内容的字符串，如果失败返回 nil
function Launcher.readFile(path)
    local file = io.open(path, "rb")
    if file then
        local content = file:read("*all")
        io.close(file)
        return content
    end

    return nil
end

-- 以字符串内容写入文件，成功返回 true，失败返回 false
function Launcher.writeFile(path, content, mode)
    mode = mode or "w+b"
    local file = io.open(path, mode)
    if file then
        if file:write(content) == nil then return false end
        io.close(file)
        return true
    else
        return false
    end
end

return Launcher
--endregion
