--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

logNormal("****************Execute script begin****************")
--dofile("./lua/function_ext.lua")
--local xmlrootpath = "./lua/config/xml_Data/"
--    g_MapResources.WeaponStockConf = Util:ParseXml(xmlrootpath.."items/weapons/WeaponStock.xml",{"id"})
--print(table.tostring(g_MapResources.WeaponStockConf))

-----------------------secret-----------------------
-----------------------debug------------------------

local bagSys = BagSystem:getInstance()
bagSys:AddItem(10186,600022,30)

logNormal("****************Execute script end****************")