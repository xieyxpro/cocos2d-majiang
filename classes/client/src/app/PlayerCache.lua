--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local PlayerCache = class("PlayerCache")

function PlayerCache:ctor(arg)
    self.account = ""
    self.userid = 0
    self.password = ""--后面由服务端发过来随机token，登录房间
    self.nickname = ""
    self.roomcardnum = 0
    self.ip = ""
    self.icon = ""
    self.gender = 0
    --region location
    self.city = ""
    self.district = ""
    self.address = ""
    self.jingdu = Define.INVALID_JINGDU
    self.weidu = Define.INVALID_WEIDU
    self.permissiondenied = false
    --endregion
    
    Network:registerMsgProc(Define.SERVER_GAME, "ms_wealth_change", self, "ms_wealth_change")
    Network:registerMsgProc(Define.SERVER_HOME, "ms_wealth_change", self, "ms_wealth_change")
end 

function PlayerCache:reset()
    self.account = ""
    self.userid = 0
    self.password = ""
    self.nickname = ""
    self.roomcardnum = 0
    self.ip = ""
    self.icon = ""
    self.gender = 0
--    --region location定位不需要重置
--    self.city = ""
--    self.district = ""
--    self.address = ""
--    self.jingdu = Define.INVALID_JINGDU
--    self.weidu = Define.INVALID_WEIDU
--    self.permissiondenied = false
--    --endregion
end 

function PlayerCache:realNameValidate(validate)
    UserDefaultExt:set("realname"..self.userid, validate)
end 

function PlayerCache:isRealNameValidated()
    return UserDefaultExt:get("realname"..self.userid, false)
end 

function PlayerCache:ms_wealth_change(data)
    self.roomcardnum = self.roomcardnum + data.roomcardchangenum
    --data.typecode
    Event.dispatch(EventDefine.WEALTH_ROOMCARD_NUM_CHANGE,data)
end

return PlayerCache
--endregion
