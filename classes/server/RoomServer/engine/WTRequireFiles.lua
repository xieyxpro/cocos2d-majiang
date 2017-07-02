require("function_ext")
require("util/util_Util")
require("util/util_bit")
require("util/banned_char")
require("headers/core/SystemBase")
event = require("util/event")
beholderlib = require("util/beholder")    --观察者模式
require("thirdparty/protobuf/protobuf")   --pb文件加解密

require("lua.Commonlua.PerformanceMeasure")

require("shared/List")
require("headers/CMD_Conf")               --全局配置文件
ErrorDefine = require("errdefine")
require("config/config")

require("engine/WorkThreadUtil")          --workthreadlib的扩展封装

require("util/util_Common")

--gbl_Debugger = require("shared/Debugger")() --测试

---------------文件加载模块-----------------
require("thirdparty/luaXML/LuaXml")

--------------热修复----------------
require("hotfix/hotfix_hotfixSystem")

---------------用户管理模块-----------------
require("usermanager/SocketConnectInfo")
require("usermanager/ServerUserItem")
require("usermanager/ServerUserManager")

require("table/TableFrame")
require("game/TableGameMain")
require("table/TableManager")

require("gamerecord/gamerecord")