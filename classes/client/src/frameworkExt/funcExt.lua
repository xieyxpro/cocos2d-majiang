--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
cc.exports.xpcall_ext = function(func)
    xpcall(func, function(msg)
        printError(msg)
    end)
end 

--endregion
