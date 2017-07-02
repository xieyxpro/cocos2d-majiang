--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

cc.exports.assert = function(cond, fmt, ...)
    if cond then 
        return 
    end 
    printError(fmt, ...)
end 


--endregion
