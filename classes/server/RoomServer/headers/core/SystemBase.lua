--region SystemBase.lua
--Date 2015.8.27
--各系统模块的基类

--基类函数使用不到可不重写
SystemBase = {
    OnServiceStart = nil,
    OnServiceStop = nil,

    OnUserLogIn = nil,
    OnUserLogOut = nil,

    OnUserOffline = nil,
    OnUserReconnect = nil,

    OnTimerFiveSec = nil,
    OnTimerOneMin = nil,
    OnTimerHalfHour = nil,
    OnTimerOneHour = nil,
}
SystemBase = Util:newClass(SystemBase)
--region Description
--[[
    参数为
    1. workthreadlib_global:
        可与前端 以及 DB线程交互 可设置自己的定时器(ID要唯一)
        可调用的函数有:
        -- dbservice
        > PostDataBaseEvent(ushort id, string pDataBuffer, ushort wDataSize, uint userid(不知道可填0),DBTTYPE.WORK(工作、统计DB;工作DB默认可不填))
        > PostDataBaseEvent(ushort id, userdata pDataBuffer, ushort wDataSize, uint userid(不知道可填0),DBTTYPE.WORK(工作、统计DB;工作DB默认可不填))
        
        -- timerservice
        > SetTimer(uint id, uint 时间间隔, uint 循环次数（-1为无限循环）,uint 绑定参数(回调时候会原值返回))
        > KillTimer(uint id)
        > KillAllTimer()

        -- netservice
        > SendDataToClient(uint userid, ushort wMainCmdID, ushort wSubCmdID, string pDataBuffer, ushort wDataSize)
        > SendDataToClient(uint userid, ushort wMainCmdID, ushort wSubCmdID, userdata pDataBuffer, ushort wDataSize)
        > SendDataToAllClients(ushort wMainCmdID, ushort wSubCmdID, string pDataBuffer, ushort wDataSize)
        > SendDataToAllClients(ushort wMainCmdID, ushort wSubCmdID, userdata pDataBuffer, ushort wDataSize)

        扩展函数(其他函数的封装优化)：
        > decode(strTypeName, pDataBuffer, wLength)
        > SendMsgToClient(pServerUserItem, wMainCmdId, wSubCmdId, strTypeName, tbMsgContent)
        > SendMsgToAllClients(wMainCmdId, wSubCmdId, strTypeName, tbMsgContent)

        > PostDataBaseEventMsg(wRequestId, strTypeName, tbMsgContent ,dwUserID(不知道可填0), dbtype(工作、统计DB;工作DB默认可不填))

    2. configs_global:
        所有配置文件的table，具体可参见 config/config_MainLoadAllXMLData.lua
--]]
--endregion
function SystemBase:OnServiceStart(workthreadlib_global, configs_global)--此函数将两个参数保存到本地的local变量，可加快访问速度
end

function SystemBase:OnServiceStop()
end

function SystemBase:OnUserLogIn( pServerUserItem )
end

function SystemBase:OnUserLogOut( pServerUserItem )
end

function SystemBase:OnUserOffline(pServerUserItem)
end

function SystemBase:OnUserReconnect(pServerUserItem)
end

function SystemBase:OnTimerDailyRefresh()--每日六点更新--定时器
end
function SystemBase:OnTimerFiveSec()--五秒定时器(每隔5秒被调用一次)
end
function SystemBase:OnTimerOneMin()
end
function SystemBase:OnTimerHalfHour()
end
function SystemBase:OnTimerOneHour()
end

--region Description
--[[
    本地函数注册 网络、DB、Timer时间 的方法:(根据ID注册本地函数)
    socketeventHandler  dbeventHandler timereventHandler 三个为全局变量
    网络注册(客户端发消息到服务端):
    例子:
    socketeventHandler[CMD_BATTLE.MAIN] = socketeventHandler[CMD_BATTLE.MAIN] or {}
    socketeventHandler[CMD_BATTLE.MAIN][CMD_BATTLE.SUB_BATTLE_REQUEST_CHAPTER_INFO] = {__battleManagerInstance,BattleManager.handler_cmd_request_chapter_info}
    DB注册(DB sql操作完成后的回调):
    例子:
    dbeventHandler[DBR_DB2W.DBR_USER_LOGON_BATTLEINFO_RES] = {__battleManagerInstance, BattleManager.handler_dbr_logon_battleinfo_res}
    Timer注册(自定义的Timer回调):
    例子:
    event.register_timer_listener(TIMER.ID_SHOP_REFRESH_TIMERID, ShopSystem, ShopSystem.handler_timer_shop_refresh)
--]]
--[[
    注册本系统模块到游戏engine中
    gameSystems 为全局变量
    gameSystems[#gameSystems + 1] = __SystemBaseTestInstance
--]]
--endregion

--endregion
