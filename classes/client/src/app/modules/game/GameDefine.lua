--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local GameDefine = {}

GameDefine.PLAY_ACT_GUO = 1
GameDefine.PLAY_ACT_CHI = 2
GameDefine.PLAY_ACT_GANG_WATCH = 3
GameDefine.PLAY_ACT_GANG_INITIATIVE = 9
GameDefine.PLAY_ACT_PENG = 4
GameDefine.PLAY_ACT_HU = 5
GameDefine.PLAY_ACT_SYS = 6
GameDefine.PLAY_ACT_OUT = 7 --玩家出牌
GameDefine.PLAY_ACT_TING = 8 --玩家听牌

GameDefine.PLAY_ACT_GANG_PLAYBACK = 10 --回放的杠
GameDefine.PLAY_ACT_ANIMA_DINGLAI = 11 --动画定赖
GameDefine.PLAY_ACT_ANIMA_SHAIZI = 12 --动画色子

GameDefine.SEAT_ONE = 1
GameDefine.SEAT_TWO = 2
GameDefine.SEAT_THREE = 3
GameDefine.SEAT_FOUR = 4

GameDefine.DIR_LEFT = 1
GameDefine.DIR_BOTTOM = 2
GameDefine.DIR_RIGHT = 3
GameDefine.DIR_TOP = 4

GameDefine.MING_TYPE_CHI_LEFT = 1
GameDefine.MING_TYPE_CHI_MID = 2
GameDefine.MING_TYPE_CHI_RIGHT = 3
GameDefine.MING_TYPE_MING_GANG = 4
GameDefine.MING_TYPE_MING_GANG_SUB_PENG = 41 --碰牌明杠
GameDefine.MING_TYPE_MING_GANG_SUB_WATCH = 42 --听牌明杠
GameDefine.MING_TYPE_MING_GANG_SUB_GANG_PAI = 43 --杠牌明杠
GameDefine.MING_TYPE_AN_GANG = 5
GameDefine.MING_TYPE_PENG = 6

GameDefine.WATCH_PRIORITY_HU = 1
GameDefine.WATCH_PRIORITY_PENG = 2
GameDefine.WATCH_PRIORITY_GANG = 2
GameDefine.WATCH_PRIORITY_CHI = 3

GameDefine.HU_TYPE_NORMAL = 1 --普通小胡
GameDefine.HU_TYPE_ZI_MO = 2 --自摸
GameDefine.HU_TYPE_DIAN_PAO = 3 --点炮
GameDefine.HU_TYPE_QIANG_GANG = 4 --抢杠
GameDefine.HU_TYPE_HAI_DI_LAO = 5 --海底捞
GameDefine.HU_TYPE_TING = 6 --听模式下的胡牌检测
GameDefine.HU_TYPE_GANG_KAI = 7 --杠开

GameDefine.GAME_OVER_TYPE_LIU = 1 --流局
GameDefine.GAME_OVER_TYPE_HU = 2 --胡了

GameDefine.BALANCE_TYPE_NONE = 0 --无结算
GameDefine.BALANCE_TYPE_DIAN_PAO = 1 --点炮方
GameDefine.BALANCE_TYPE_JIE_PAO = 2 --接炮方

GameDefine.CARDS_ARRAY_STATUS_NONE = 1
GameDefine.CARDS_ARRAY_STATUS_NORMAL = 2
GameDefine.CARDS_ARRAY_STATUS_CHI = 3
GameDefine.CARDS_ARRAY_STATUS_AN_GANG = 4

GameDefine.CARD_TYPE_TONG = 1
GameDefine.CARD_TYPE_WAN = 2
GameDefine.CARD_TYPE_SUO = 3
GameDefine.CARD_TYPE_ZI = 4 --字牌（也称风牌）
GameDefine.CARD_TYPE_HUA = 5 --花牌（梅兰竹菊春夏秋冬）

GameDefine.MJ_HN = 1
GameDefine[GameDefine.MJ_HN] = {
    CardTypes = {
        GameDefine.CARD_TYPE_WAN,
        GameDefine.CARD_TYPE_TONG,
        GameDefine.CARD_TYPE_SUO,
    }
}

GameDefine.MJ_HG = 1
GameDefine[GameDefine.MJ_HN] = {
    CardTypes = {
        GameDefine.CARD_TYPE_WAN,
        GameDefine.CARD_TYPE_TONG,
        GameDefine.CARD_TYPE_SUO,
        GameDefine.CARD_TYPE_ZI,
    },
}

function GameDefine.calChiType(chiCardVal, cardVal1, cardVal2)
    local min = chiCardVal > cardVal1 and cardVal1 or chiCardVal
    min = min > cardVal2 and cardVal2 or min
    local max = chiCardVal > cardVal1 and chiCardVal or cardVal1
    max = max > cardVal2 and max or cardVal2
    if chiCardVal > min and chiCardVal < max then 
        return GameDefine.MING_TYPE_CHI_MID
    elseif chiCardVal <= min then 
        return GameDefine.MING_TYPE_CHI_LEFT
    else
        return GameDefine.MING_TYPE_CHI_RIGHT
    end 
end 

function GameDefine.getCardType(cardVal)
    return math.floor(cardVal / 10)
end 

function GameDefine.getCardShortVal(cardVal)
    return cardVal % 10
end 

--牌型组合类型
GameDefine.COMP_TYPE_JIANG = 1 --将牌
GameDefine.COMP_TYPE_SHUN = 2 --顺子
GameDefine.COMP_TYPE_KE = 3 --刻子

--豹子类型
GameDefine.BAO_ZI_LIANLAI = 1 --连赖
GameDefine.BAO_ZI_FENGLAI = 2 --风赖
GameDefine.BAO_ZI_SHAIZI = 3 --一对色子

--得分类型
GameDefine.RECORD_TYPE_JIANGYISE = 1
GameDefine.RECORD_TYPE_FENGYISE = 2
GameDefine.RECORD_TYPE_QINGYISE = 3
GameDefine.RECORD_TYPE_PENGPENGHU = 4
GameDefine.RECORD_TYPE_GANGKAI = 5
GameDefine.RECORD_TYPE_QUANQIUREN = 6
GameDefine.RECORD_TYPE_HAIDILAO = 7
GameDefine.RECORD_TYPE_YINGHU = 8
GameDefine.RECORD_TYPE_XIAOHU = 9
GameDefine.RECORD_TYPE_QIANGGANG = 10
GameDefine.RECORD_TYPE_NAMES = {
    [GameDefine.RECORD_TYPE_JIANGYISE] = "将一色",
    [GameDefine.RECORD_TYPE_FENGYISE] = "风一色",
    [GameDefine.RECORD_TYPE_QINGYISE] = "清一色",
    [GameDefine.RECORD_TYPE_PENGPENGHU] = "碰碰胡",
    [GameDefine.RECORD_TYPE_GANGKAI] = "杠开",
    [GameDefine.RECORD_TYPE_QUANQIUREN] = "全求人",
    [GameDefine.RECORD_TYPE_HAIDILAO] = "海底捞",
    [GameDefine.RECORD_TYPE_YINGHU] = "硬胡",
    [GameDefine.RECORD_TYPE_XIAOHU] = "屁胡",
    [GameDefine.RECORD_TYPE_QIANGGANG] = "抢杠",
}

--几个顶
GameDefine.FENG_DING = 80
GameDefine.JIN_DING = 100
GameDefine.HA_DING = 120
GameDefine.SAN_YANG_KAI_TAI = 160

GameDefine.MJTYPE = {
    NORMAL = 1,--普通麻将
}

GameDefine.MJ_TYPE_ZHUANZHUAN = 1
GameDefine.MJ_TYPE_CHANGSHA = 2

GameDefine.enum_GameStatus = {
    GS_FREE = 1,--准备阶段
    GS_PLAYING = 3,--正在游戏
}

GameDefine.STAT_TYPE_WIN = 1
GameDefine.STAT_TYPE_LOSE = 2
GameDefine.STAT_TYPE_ZIMO = 3
GameDefine.STAT_TYPE_DIANPAO = 4
GameDefine.STAT_TYPE_JIEPAO = 5
GameDefine.STAT_TYPE_RECORD = 6 --得分

GameDefine.STAT_NAMES = {
    [GameDefine.STAT_TYPE_WIN] = "胜利",
    [GameDefine.STAT_TYPE_LOSE] = "失败",
    [GameDefine.STAT_TYPE_ZIMO] = "自摸",
    [GameDefine.STAT_TYPE_DIANPAO] = "点炮",
    [GameDefine.STAT_TYPE_JIEPAO] = "接炮",
    [GameDefine.STAT_TYPE_RECORD] = "得分",
}

GameDefine.enum_GameOverReason = {
    NORMAL = 1,         --正常结束
    SERVER_DISMISS = 2,    --服务器强制游戏解散
    AGREE_DISMISS = 3,     --同桌玩家协商解散游戏
}
GameDefine.GAME_OVER_ERR = {
    [GameDefine.enum_GameOverReason.NORMAL] = "正常结束",
    [GameDefine.enum_GameOverReason.SERVER_DISMISS] = "服务器强制结束牌局",
    [GameDefine.enum_GameOverReason.AGREE_DISMISS] = "牌局解散",
}

GameDefine.SeatDirMap = {
    [4] = {GameDefine.DIR_BOTTOM, GameDefine.DIR_RIGHT, GameDefine.DIR_TOP, GameDefine.DIR_LEFT},
    [3] = {GameDefine.DIR_BOTTOM, GameDefine.DIR_RIGHT, GameDefine.DIR_LEFT},
    [2] = {GameDefine.DIR_BOTTOM, GameDefine.DIR_TOP},
}

GameDefine.GAME_MODE = {
    GAME = 1, --游戏
    DEMO = 2, --演示
}

GameDefine.INI_SCORE = 1000 --初始分数
GameDefine.INI_FANS = 3 --初始3番
GameDefine.INI_FENG_DING_MULTI = 1 --初始封顶倍数

GameDefine.ACTION_WAIT_TIME = 15 --动作等待时间（单位：秒）

GameDefine.ANIMA_TYPE_OUT_CARD = 1
GameDefine.ANIMA_TYPE_CHI = 2
GameDefine.ANIMA_TYPE_PENG = 3
GameDefine.ANIMA_TYPE_GANG = 4
GameDefine.ANIMA_TYPE_GUO = 5
GameDefine.ANIMA_TYPE_HU = 6
GameDefine.ANIMA_TYPE_SYS_DISPATCH_CARD = 7
GameDefine.ANIMA_TYPE_OP_OUT_CARD = 8
GameDefine.ANIMA_TYPE_OP_OUT_GANG_PAI = 9
GameDefine.ANIMA_TYPE_HAIDILAO = 10
GameDefine.ANIMA_TYPE_GAMEOVER = 11
GameDefine.ANIMA_TYPE_DINGLAI = 12
GameDefine.ANIMA_TYPE_SHAIZI = 13 

---------------------------------------------------
GameDefine.enum_UserStatus = {
    US_NULL         =1,     --没有状态
    US_FREE         =2,     --站立状态
    US_SIT          =3,     --坐下状态
    US_READY        =4,     --同意状态
    --US_LOOKON       =5,     --旁观状态
    US_PLAYING      =6,     --游戏状态
    US_OFFLINE      =7,     --断线状态
    US_OFFLINE_SIT  =8,
}


return GameDefine
--endregion
