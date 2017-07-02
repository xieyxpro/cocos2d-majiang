--region Bag.lua
--Date 2015.8.29
--desc 背包/道具系统开放接口文档

-------------------------------------------背包系统开放函数：
--获取单例对象
function BagSystem:getInstance() end
--region 发放道具
--[Comment]同时创建单个类型的多个数量的道具，(事务：即要么全发放成功，要么不发放)
--result(bsuccess:bool,createRes:enCreateItemRes) 创建道具，成功则返回true，失败则返回false,enCreateItemRes(失败原因)
--params:
--      dwUserID为用户ID
--      ItemContent={itemProtoId=., itemCount=.}
function BagSystem:SafeCreateItem( dwUserID, ItemContent ) end
--[Comment]同时创建多种类型的多个数量的道具，(事务：即要么全发放成功，要么不发放)
--result(bsuccess:bool,createRes:enCreateItemRes) 创建道具，成功则返回true，失败则返回false,enCreateItemRes(失败原因)
--params:
--      dwUserID为用户ID
--      ItemContents为{{itemProtoId=., itemCount=.},...}
function BagSystem:SafeCreateItems( dwUserID, ItemContents ) end
--[Comment]判断是否可以同时创建多种类型的多个数量的道具，(事务：即要么全发放成功，要么不发放)
--result(bsuccess:bool,createRes:enCreateItemRes) 创建道具，成功则返回true，失败则返回false,enCreateItemRes(失败原因)
--params:
--      dwUserID为用户ID
--      ItemContents为{{itemProtoId=., itemCount=.},...}
function BagSystem:CanCreateItems( dwUserID, ItemContents ) end
--endregion

--region 查询道具
--[Comment]
--result(item:table) 返回用户背包中道具ID为strItemGuid 的道具的对象
--params 略
function BagSystem:GetUserItemByItemGuid( dwUserID, strItemGuid ) end

--[Comment]
--result(count:number) 返回用户拥有的道具数量
--params 略
function BagSystem:GetUserItemCountByItemProtoId( dwUserID, itemProtoId ) end
--endregion

--region 删除道具
--[Comment]
--result 返回用户拥有的道具数量
--params 略
function BagSystem:RemoveItemsByProtoId( dwUserID, itemProtoId, itemCount ) end
--endregion

----------------------------------------------道具对象开放函数:

--[Comment]
--result 返回道具的原型ID
--params 无
function Item:GetItemProtoId() end

---------------------------------------------------示例--------------------------------

--背包系统使用方法:
local bagsystem = bagsystem or BagSystem:getInstance() 
--获取用户ID为1的用户拥有多少个600001的道具:
local nItemCount = bagsystem:GetUserItemCountByItemProtoId(1, 600001)
--如果足够五个则扣除
if nItemCount > 5 then
    local bsuccess =  bagsystem:RemoveItemsByProtoId(1, 600001, 5 )
end
--给用户ID为1的用户发放道具10个600001道具
local itemcontent = {};
itemcontent.itemProtoId, itemcontent.itemCount = 600001, 10
local bSuccess,enRes =  BagSystem:getInstance():SafeCreateItem(dwUserID, itemcontent)
if not bSuccess then
    if enRes == enCreateItemRes.enNoFreeSlotError then
        logDebug("背包格子不足，发放邮件去吧")
    end
end
--给用户ID为1的用户发放道具10个600001，1个600002道具
local itemContents = {}
local itemcontent = {};
itemcontent.itemProtoId, itemcontent.itemCount = 600001, 10
itemContents[1] = itemcontent
local itemcontent = {};
itemcontent.itemProtoId, itemcontent.itemCount = 600002, 1
itemContents[2] = itemcontent
local bSuccess,enRes =  BagSystem:getInstance():SafeCreateItems(dwUserID, itemContents)
if not bSuccess then
    if enRes == enCreateItemRes.enNoFreeSlotError then
        logDebug("背包格子不足，发放邮件去吧")
    end
end


--endregion
