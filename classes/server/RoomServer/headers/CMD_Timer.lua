-------------计时器全局变量--------------------
TIMER = {

	ID_DAILYCLEAR_TIMERID 			    = 1000,		--每日定时清理计时器ID --此ID设置优先级最高(即此ID为最小值)

    ID_FIVE_SECOND_TIMERID               = 1001,        --5秒级的定时器
    PA_FIVE_SECOND_TIMER_ELAPSE     = 5000,             --每5秒刷新一次
	PA_USERITEMCACHE_LIMIT          = 2,                --用户下线后用户信息缓存10秒

    ID_ONE_MINUTE_TIMERID               = 1002,         --分钟级的定时器
    PA_ONE_MINUTE_TIMER_ELAPSE      = 60000,            --每分钟刷新一次

    ID_HALF_HOUR_TIMERID                = 1003,         --半小时级定时器
    PA_HALF_HOUR_TIMER_ELAPSE       = 1800000,          --每半小时刷新一次

    ID_ONE_HOUR_TIMER_ID                = 1004,         --一小时级定时器
    PA_ONE_HOUR_TIMER_ELAPSE        = 3600000,          --一小时刷新一次
        
    ID_SERVER_REGTO_OCS                 = 1011,
    PA_SERVER_REGTO_OCS_ELAPSE          = 2000,


	PA_FOREVER_REPEAT  			= -1, 			--定时器一直计时


    ID_TEST                             = 1000000,

    --region 桌子模块使用的定时器ID
    ID_TABLE_MODULE_START               = 2000000,
    ID_TABLE_MODULE_END                 = 3000000,
    TIME_TABLE_GAME_RANGE               = 100,  --游戏逻辑中使用的定时器范围
    TIME_TABLE_MODULE_RANGE             = 200,  --桌子整个模块中使用的定时器范围
    --endregion

    --region AI模块定时器
    TIME_AI_GAME_RANGE                  = 50, --AI游戏中定时器id范围[1，TIME_AI_GAME_RANGE)
    TIME_AI_MODULE_RANGE                = 100,--[TIME_AI_GAME_RANGE,TIME_AI_MODULE_RANGE)为ai模块内其他功能使用   
}
