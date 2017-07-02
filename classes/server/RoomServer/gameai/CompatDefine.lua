--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

--===================================
function printInfo(format, ...)
--    logNormalf(format, ...)
end 

cc = {}
cc.PLATFORM_OS_WINDOWS = "PLATFORM_OS_WINDOWS"
cc.Application = {}

cc.Application.Platform = {}
function cc.Application.Platform:getTargetPlatform()
    return "PLATFORM_OS_WINDOWS"
end 
function cc.Application:getInstance()
    return cc.Application.Platform
end 

--===================================
UserDefaultExt = {}

function UserDefaultExt:set()
    --DO NOTHING
end 

--===================================
Define = {}

Define.Server = {
    IP = "192.168.1.16",
    --IP = "192.168.1.95",
--    IP = "192.168.1.87",
--    IP = "139.199.65.56",
    PORT = 9031
}

Define.INVALID_TABLE = -1
Define.INVALID_CHAIR = -1

Define.INVALID_JINGDU = 1000
Define.INVALID_WEIDU = 1000
Define.WARING_DISTANCE = 100--其他两家玩家小于100米时候提醒玩家

Define.SERVER_HOME = "home"
Define.SERVER_GAME = "game"

Define.GENDER_MALE = 1
Define.GENDER_FEMALE = 2

Define.SCENE_LOGIN = "login"
Define.SCENE_HOME = "home"
Define.SCENE_GAME = "game"

--===================================

--endregion
