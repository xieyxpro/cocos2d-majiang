--region Define.lua
--Author : Administrator
--Date   : 2014/7/11
local Define = {}

Define.Server = {
--    IP = "192.168.1.16",
--    IP = "192.168.1.95",
--    IP = "192.168.1.87",
    --IP = "172.18.71.172",
      IP = "localhost",
--    IP = "139.199.155.23",--审核服务器
--    IP = "loginserver.hgmj.jiezhansifang.com",
--    IP = "349848-0.gz.1252485065.clb.myqcloud.com",
    PORT = 9031
}

if device.platform == "android" or device.platform == "ios" then        
    Define.DATA_SERVER = "http://api.hgmj.jiezhansifang.com"
else
    --Define.DATA_SERVER = "http://192.168.1.95:8088"
    --Define.DATA_SERVER = "http://172.18.71.172:8088"  
    Define.DATA_SERVER = "http://localhost:8088"
--    Define.DATA_SERVER = "http://api.hgmj.jiezhansifang.com"
end

Define.FONT_NAME = "font/DFYuanW7-GB2312.ttf"
Define.WEB_API_KEY = "jiezhansifanghgmjapi"

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

Define.WECHAT_SHARE_CONTENT_TYPE_TEXT = 1
Define.WECHAT_SHARE_CONTENT_TYPE_IMAGE = 2

return Define
--endregion