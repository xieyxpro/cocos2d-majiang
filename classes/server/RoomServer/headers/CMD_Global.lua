----------------命令码------------------------

DBTTYPE	= { 

	WORK  = 2,	--与服务器命令码一致 
	--QUERY = 3,  --不用此线程
	STAT  = 4,	

}

--region 游戏
INVALID_TABLE = -1
INVALID_CHAIR = -1

INVALID_JINGDU = 1000
INVALID_WEIDU = 1000

INVALID_IP = 0
INVALID_SOCKET_INDEX = 65535


enum_GameOverReason = {
    NORMAL = 1,         --正常结束
    SERVER_DISMISS = 2,    --服务器强制游戏解散
    AGREE_DISMISS = 3,     --同桌玩家协商解散游戏
}


enum_GameStatus = {
    GS_FREE = 1,
    GS_PLAYING = 3,
}

--endregion

--region 用户

--用户状态
enum_UserStatus = {
    US_NULL         =1,     --没有状态
    US_FREE         =2,     --站立状态
    US_SIT          =3,     --坐下状态
    US_READY        =4,     --同意状态
    --US_LOOKON       =5,     --旁观状态
    US_PLAYING      =6,     --游戏状态
    US_OFFLINE      =7,     --断线状态>=7都是断线状态
    US_OFFLINE_SIT  =8,
}
--endregion






--region 时间
--系统中新的一天开始时间时
enGameSystemTimeParams = {
	enGMT = 8, --时区（北京时间）
	enNewDayHour 			= 6,			--新的一天的开始时刻为6时
	enMinutesPerUserEnergy 	= 6, 			--用户体力值回复1点需要的分钟数
	enMaxValueOfDateTime 	= 32535014400, 	--时间的最大值：3000-12-30 00:00:00
}
CONST_TIME = {
    UINT_MAXVALUE = 4294967295,             --uint.MaxValue
}
--endregion

