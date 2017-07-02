
DBR_W2DB = {
    --hotfix
    DBR_HOTFIX = 10000,

    --region logon
	DBR_USER_LOGON_USERID   	= 1, 			--用户登录
    DBR_USER_ROOMCARD_CHANGE    = 2,            --用户房卡改变
    --endregion

    --region gamerecord
    DBR_RECORD_RECORD_GAME          = 11,   --记录游戏
    DBR_RECORD_RECORD_ROOM          = 12,   --房间解散记录房间
    --endregion
    
    DBR_TEST                        = 10000,
    --region stat
    DBR_STAT_ROOMCARD_CHANGE            = 20001,        --用户房卡改变统计
    DBR_STAT_CREATE_ROOMS               = 20002,        --创建房间统计
    DBR_STAT_GAME_RECORDS               = 20003,        --牌局统计
    --endregion
}

--db2workthread request define
DBR_DB2W = {
    --region logon
	DBR_USER_LOGON_RES  			= 1,
    --endregion
    
    DBR_TEST    =   10000,
}
