--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
config = {}

config.DEBUG = true
config.ENABLE_MEM_PHOTO = false

config.CHECK_CHEATERS = true --首局开局前检查玩家作弊
config.CHECK_CHEATERS_DISTANCE = 100 --少于多少米认为是作弊
config.CHECK_CHEATERS_IP = false --是否通过玩家IP相同来判断是否作弊

config.GAME_KIND = 1
config.ServerID = 9001
config.TABLE_COUNT = 500   --服务器50张桌子

config.TABLE_MAX_CHAIR = 4  --桌子内最大椅子数

config.CardPayConfig = {    --房卡支付配置8局1张房卡，16局2张房卡
    [8] = 1,
    [16] = 2
}

--endregion
