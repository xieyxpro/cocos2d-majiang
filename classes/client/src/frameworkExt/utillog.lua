--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local utillog = {
    bCheckUpload = false,
}
local ccfileutil = cc.FileUtils:getInstance();
local utilfile = require("frameworkExt.utilfile")

local LOG_FILE_DIR = ccfileutil:getWritablePath() .. "log/"
local LOG_FILE_PATH = LOG_FILE_DIR .. "mjlog";
local LOG_FILE_ZIP_PATH = LOG_FILE_PATH .. ".zip"
local LOG_FILE_AUTO_UPLOAD_SIZE = 1024*1024--当设置log自动上传后
local LOG_FILE_AUTO_DELETE_SIZE = 10*1024*1024;--大于此值10MB，自动删除log文件

local getFileServerName = function ()
    local uid = PlayerCache.userid or 0
    local time = os.date("%Y-%m-%d-%H.%M.%S",os.time())
    return string.format("uid_%s_time_%s.zip",uid,time)
end;

function utillog:Init()
    if not ccfileutil:isDirectoryExist(LOG_FILE_DIR) then
        ccfileutil:createDirectory(LOG_FILE_DIR)
    end
    
    if ccfileutil:getFileSize(LOG_FILE_PATH) > LOG_FILE_AUTO_DELETE_SIZE then
        ccfileutil:removeFile(LOG_FILE_PATH)
    end
end

function utillog:networkTypeChanged(data)
    if data.networktype == "WIFI" then
        --check auto upload logs        
        if not self.bCheckUpload and LOG_FILE_AUTO_UPLOAD and ccfileutil:getFileSize(LOG_FILE_PATH) > LOG_FILE_AUTO_UPLOAD_SIZE then
            utillog:checkUploadLog()
        end
        self.bCheckUpload = true
    end
end

function cc.exports.mylogprint(fmt,...)
    local args = {...}
    xpcall(function()
        release_print(fmt,unpack(args))
        local writestring = fmt
        if #args > 0 then
            writestring = string.format(fmt,unpack(args))
        end
        
        if not io.writefile(LOG_FILE_PATH,"[" .. os.date("%m-%d %H:%M:%S",os.time()) .. "]" .. writestring .. "\n","a+b") then
            printError("write log file err")
        end
    end,
    function() print(debug.traceback()) end)
end

function utillog:checkUploadLog()
    if device.platform == "windows" then
        Event.dispatch(EventDefine.LOG_UPLOAD_FINISH,{success = true})
        return
    end 
    local uploadCallBack = function (bSuccess)
        if bSuccess then
            ccfileutil:removeFile(LOG_FILE_ZIP_PATH)
            printInfo("上传成功")
            Event.dispatch(EventDefine.LOG_UPLOAD_FINISH,{success = true})
        else
            printInfo("上传失败")
            Event.dispatch(EventDefine.LOG_UPLOAD_FINISH,{success = false})
        end
    end
    if ccfileutil:isFileExist(LOG_FILE_PATH) then
        utilfile.compressFile(LOG_FILE_PATH,LOG_FILE_ZIP_PATH)
        FileUpload:UploadLogFiles(getFileServerName(),LOG_FILE_ZIP_PATH,uploadCallBack)
        return true
    end
    return false
end

return utillog


--endregion
