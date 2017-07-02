require("function_ext")
require("util/util_Util")
require("util/util_bit")
require("util/banned_char")
beholderlib = require("util/beholder")    --观察者模式
require("thirdparty/protobuf/protobuf")   --pb文件加解密

--gbl_Debugger = require("shared/Debugger")() --测试

require("thirdparty/luaXML/LuaXml")

require("shared/List")
require("headers/CMD_Conf")               --全局配置文件
ErrorDefine = require("errdefine")
require("config/config")

require("engine/AIThreadUtil")          --workthreadlib的扩展封装

require("aimanager/AIUserItem")
require("gameai/AIGame")
require("aimanager/AIManager")