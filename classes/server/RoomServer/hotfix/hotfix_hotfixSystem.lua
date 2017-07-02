--region weapon_WeaponSystem.lua
--Date 2015.8.18


HotfixSystem ={ }

HotfixSystem = Util:newClass(HotfixSystem,SystemBase)

local __HotfixSystem = HotfixSystem:new()

--endregion

function HotfixSystem:getInstance()
    if not __HotfixSystem then 
        __HotfixSystem = HotfixSystem:new()
    else 
        return __HotfixSystem
    end 
end 


function HotfixSystem:handler_cmd_hotfix_work(usrId, buf, sz)
    dofile("./lua/hotfix/script_work.lua")
end 


function HotfixSystem:handler_cmd_hotfix_db(usrId, buf, sz)
    workthreadlib:PostDataBaseEvent(DBR_W2DB.DBR_HOTFIX,nil,0)
end 

gameSystems[#gameSystems + 1] = __HotfixSystem

event.register_socket_listener(CMD_HOTFIX.MAIN,CMD_HOTFIX.SUB_HOTFIX_WORK,__HotfixSystem, __HotfixSystem.handler_cmd_hotfix_work,"Gamemsg.xxx")
event.register_socket_listener(CMD_HOTFIX.MAIN,CMD_HOTFIX.SUB_HOTFIX_DB,__HotfixSystem, __HotfixSystem.handler_cmd_hotfix_db,"DBRMsg.xxx")

--endregion

