--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local utilfile = {}

--srcfilename, dstfilename 绝对路径
function utilfile.compressFile(srcfilename, dstfilename)
    assert("string" == type(srcfilename) and "" ~= srcfilename and "string" == type(dstfilename) and "" ~= dstfilename)
    SharedUtil.compressFile(srcfilename, dstfilename)
end

--srcfilename, dstfilename 绝对路径
function utilfile.decompressFile(srcfilename, dstfilename)
    assert("string" == type(srcfilename) and "" ~= srcfilename and "string" == type(dstfilename) and "" ~= dstfilename)
    SharedUtil.decompressFile(srcfilename, dstfilename)
end


function utilfile.getDataMD5(data,len)
    return SharedUtil.getDataMD5(data,len)
end

function utilfile.getFileMD5(filepath)
    return SharedUtil.getFileMD5(filepath)
end

function utilfile.base64_encode(data,len)
    return SharedUtil.base64_encode(data,len)
end

function utilfile.base64_decode(data,len)
    return SharedUtil.base64_decode(data,len)
end

return utilfile

--endregion
