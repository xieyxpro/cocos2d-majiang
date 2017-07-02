--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local LuaBridge
local className
local platform = device.platform

if platform == "android" then
	LuaBridge = require "cocos.cocos2d.luaj"
    className = "com/jzsf/hgmj/FileUploadUtil"
elseif platform == "ios" then
	LuaBridge = require "cocos.cocos2d.luaoc"
    className = "FileUploadUtil"
end

require("cocos.cocos2d.json");


local APPID = "1252485065"
local SECRETID = "AKID4ALdtzlEjARXSCzGaj4ILDvSp164pmS9"
local SECRETKEY = "ysdDkBXjkcM2ayPm6HNK6kHfsulQuDLJ"

local BUCKET_JZHGMJ = "jzhgmj"

local SIGN_EXPIRED_TIME = 7776000
local headimage_sign = nil

local FileUpload = {

}

function FileUpload:Init()    
    if platform == "android" then
        local sig = "(Ljava/lang/String;Ljava/lang/String;)V"
        local ok,ret = LuaBridge.callStaticMethod(className,"Init",{APPID,""},sig)
        assert(ok)
    elseif platform == "ios" then
        local ok,ret = LuaBridge.callStaticMethod(className,"Init",{appId=APPID,region="gz"})
        assert(ok)
    end
end

local getSign = function ()
    if nil == headimage_sign then    
        local curtime = os.time()
        local signStr = string.format("a=%s&b=%s&k=%s&e=%d&t=%d&r=%d&f=",APPID,BUCKET_JZHGMJ,SECRETID,
                                curtime+SIGN_EXPIRED_TIME,curtime,math.random(1000000000))
        if platform == "android" then
            local sig = "(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;"
            local ok,ret = LuaBridge.callStaticMethod("com/jzsf/hgmj/Helper","upload_sign",{SECRETKEY,signStr},sig)
            assert(ok)
            headimage_sign = ret
        
        elseif platform == "ios" then
            local ok,ret = LuaBridge.callStaticMethod(className,"upload_sign",{key=SECRETKEY,text=signStr})
            assert(ok)
            headimage_sign = ret
        end
    end
    return headimage_sign
end;

--imageName 远程相对路径下的文件名要带后缀  imagePath 本地绝对路径
function FileUpload:UploadHeadImage(imageName,imagePath,callBack)
    local uploadCallback = function (res)
        local tbRes = json.decode(res)
        if tbRes.res == "success" then
            if nil ~= callBack then callBack(true,tbRes.access_url) end
        else
            if nil ~= callBack then callBack(false) end
        end        
    end;
    
    local serverDir = "/headimage"
    local serverPath = serverDir .. "/" .. imageName
    local sign = getSign()
    if platform == "android" then
        local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
        local ok,ret = LuaBridge.callStaticMethod(className,"UploadFile",{BUCKET_JZHGMJ,serverPath,imagePath,sign,uploadCallback},sig)            
    elseif platform == "ios" then
        local ok,ret = LuaBridge.callStaticMethod(className,"UploadFile",{bucket=BUCKET_JZHGMJ,cosDir=serverDir,fileName=logFileName,cosPath=serverPath,srcPath=imagePath,sign=sign,callback=uploadCallback})
    else
        uploadCallback("{\"res\":\"fail\"}")
    end
end

--logFileName 远程相对路径下的文件名要带后缀  logFilePath 本地绝对路径
function FileUpload:UploadLogFiles(logFileName,logFilePath, callBack)
    local uploadCallback = function (res)
        local tbRes = json.decode(res)
        if tbRes.res == "success" then
            if nil ~= callBack then callBack(true) end
        else
            if nil ~= callBack then callBack(false) end
        end
    end;

    local serverDir = "/logfiles"
    local serverPath = serverDir .. "/" .. logFileName
    local sign = getSign()
    if platform == "android" then
        local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
        local ok,ret = LuaBridge.callStaticMethod(className,"UploadFile",{BUCKET_JZHGMJ,serverPath,logFilePath,sign,uploadCallback},sig)
    elseif platform == "ios" then
        local ok,ret = LuaBridge.callStaticMethod(className,"UploadFile",{bucket=BUCKET_JZHGMJ,cosDir=serverDir,fileName=logFileName,cosPath=serverPath,srcPath=logFilePath,sign=sign,callback=uploadCallback})
    else
        uploadCallback("{\"res\":\"fail\"}")
    end
end

return FileUpload


--endregion
