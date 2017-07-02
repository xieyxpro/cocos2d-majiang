--region User.lua
--Date 2015.8.31
--desc 用户开放接口文档

--desc
--[[
    ServerUserManager 是一个单例类
    ServerUserItem是由ServerUserManager管理的用户数据类
    使用时候可先由ServerUserManager:getInstance():SearchOnlineUserItem(dwUserID) 获取 ServerUserItem判断用户是否在线;再进行后续操作
--]]

------------------------------------------用户管理开放函数:
--[Comment]
--获取单例对象
function ServerUserManager:getInstance() end
--[Comment]
-- 修改用户的财富（金币、钻石）用户离线也会写成功
--result: 无
--params dwUserID, GoldCoinChange, DiamondChange, nTypeCode(财富修改 enum_TypeCode_WealthChange)
function ServerUserManager:WriteUserWealth( dwUserID, GoldCoinChange, DiamondChange, nTypeCode) end
--[Commont]
-- 修改用户的财富（金币、钻石）用户离线也会写成功 方法二：
--result: 无
--params dwUserID, WealthContents(user_WealthContent[]), nTypeCode(财富修改 enum_TypeCode_WealthChange)
function ServerUserManager:WriteUserWealthByArray( dwUserID, WealthContents, nTypeCode) end

--[Comment]
--修改用户的游戏分值（功勋、经验、体力值）
--result: 无
--params pServerUserItem(用户指针), HornorChange, ExpChange, EnergyChange
function ServerUserManager:WriteUserScore( pServerUserItem, HornorChange, ExpChange, EnergyChange ) end

--[Comment] 
-- 获取用户此刻的体力值
--result: (uint)用户此刻的体力值
--params: pServerUserItem
function ServerUserManager:UpdateAndGetUserEnergy( pServerUserItem ) end


--region 通过UserID获取在线用户的指针
function ServerUserManager:SearchOnlineUserItem( dwUserID ) end
--region 通过UserID获取离线用户(用户下线后不会马上离线用户)的指针
function ServerUserManager:SearchOfflineUserItem( dwUserID ) end
--region 通过UserID获取在线或者离线用户的指针
function ServerUserManager:getOnlineOrOfflineUserItem( dwUserID ) end


-----------------------------------------用户开放函数
--[Comment] 获取用户的ID
function ServerUserItem:GetUserID() end

--[Comment] 获取用户的等级
function ServerUserItem:GetUserLevel() end

--[Commont] 获取用户的军功
function ServerUserItem:GetUserHornor() end

--[Comment]
function ServerUserItem:IsGoldCoinEnough(nNeedGoldCoin) end

--[Comment]
function ServerUserItem:IsDiamondEnough(nNeedDiamond) end

--[Commont]
--param WealthContents:user_WealthContent[]
function ServerUserItem:IsWealthEnough(WealthContents) end


-----------------------------------------示例-----------------------------------------

local serverusermgr = ServerUserManager:getInstance()
function handler_cmd_request_xxx(dwUserID, pDataBuffer, wDataSize)
    local pServerUserItem = serverusermgr:SearchOnlineUserItem(1)
    if nil == pServerUserItem then return false end
    
    --判断财富是否足够
    --方法一：
    if not pServerUserItem:IsGoldCoinEnough(10000) then 
        logDebug("用户金币不足")
    end
    
    --方法二:
    local wealthContents = {}
    wealthContents[1] = {enWealthType = enum_WealthType.GOLD, nWealthNum = 1000}
    wealthContents[2] = {enWealthType = enum_WealthType.DIAMOND, nWealthNum = 10}
    if not pServerUserItem:IsWealthEnough(wealthContents) then
        logDebug("用户财富不足")
    end

    --扣除金币
    --方法一：
    serverusermgr:WriteUserWealth(dwUserID, -10000, 0, enum_TypeCode_WealthChange.BUY_SHOPITEM)
    --方法二:
    local wealthContents = {}
    wealthContents[1] = {enWealthType = enum_WealthType.GOLD, nWealthNum = -1000}
    wealthContents[2] = {enWealthType = enum_WealthType.DIAMOND, nWealthNum = -10}
    serverusermgr:WriteUserWealthByArray(dwUserID, wealthContents, enum_TypeCode_WealthChange.BUY_SHOPITEM)
    --发放xxx

    --发送xxx成功
end



--endregion
