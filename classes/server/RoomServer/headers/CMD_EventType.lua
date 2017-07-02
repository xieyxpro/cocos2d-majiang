
-------------------OutStringEvent-------------------
OUTSTRING_EVENT = {
	LEVEL_DEBUG = 0,
	LEVEL_NORMAL = 1,
	LEVEL_WARNING = 2,
	LEVEL_EXCEPTION = 3,
}

-------------------事件类型--------------------------

BEHOLDER_EVENTTYPE = {
    SERVICE_START   = "service_start",                  --服务器启动事件
    SERVICE_STOP    = "service_stop",                   --服务器关闭事件

    USER_LOGIN                      = "user_login",
    USER_OFFLINE                    = "user_offline",
    USER_RECONNECT                  = "user_reconnect",
    USER_LOGOUT                     = "user_logout",

    USER_RECONNECT_CHECK_INTABLE    = "user_reconnect_check_intable",
    
    CHAT_GM_CMD                     = "chat_gm_cmd",            --GM命令
    
    --用户事件
    USER = {
        WEALTH_CHANGE               = "user_wealth_change",     --用户财富改变userid,GoldCoinChange, DiamondChange
        SCORE_CHANGE                = "user_score_change",      --用户数据改变userid,HornorChange, ExpChange, EnergyChange
        LEVEL_UP                    = "user_level_up",          --用户升级curlevel
        VIP_CHANGE                  = "user_vip_change",         --用户VIP等级改变userid,curVipLevel
    },
}
