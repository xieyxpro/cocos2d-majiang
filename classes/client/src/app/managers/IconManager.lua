--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local IconManager = class("IconManager")

local fileUtils = cc.FileUtils:getInstance()
local iconSaveDir = fileUtils:getWritablePath() .. "playericons/"
local ICON_SIZE = {width = 89, height = 89}

local function createFileName(userid)
    return iconSaveDir .. tostring(userid) .. ".jpg"
end 

local function createShortFileName(userid)
    return tostring(userid) .. ".jpg"
end 

local function createResourceFileName(userid)
    return iconSaveDir .. tostring(userid) .. ".jpg"
end 

local function createIcon(userid)
    local shortFileName = createResourceFileName(userid)
    local img = ccui.ImageView:create()
    img:loadTexture(shortFileName,0)
    img:setName("imgBg")
    img:setContentSize(ICON_SIZE)
    return img
end 

function IconManager:ctor()
    if not fileUtils:isDirectoryExist(iconSaveDir) then 
        if not fileUtils:createDirectory(iconSaveDir) then 
            printError("create dir %s failed", iconSaveDir)
        end 
    end 
    cc.FileUtils:getInstance():addSearchPath(iconSaveDir)
end 

function IconManager:createIconImage(userid)
    return createIcon(userid)
end 

function IconManager:getIcon(userid, iconURL)
    if device.platform ~= "android" and device.platform ~= "ios" then --for testing purpose
--        iconURL = "http://jzhgmj-1252485065.cosgz.myqcloud.com/headimage/WXo0jfxwjccpCluHWqT0WUxbwLmkpU.jpg"
    end 
    local fileName = createFileName(userid)
    if not fileUtils:isFileExist(fileName) then 
        local function callback(data)
            if not data.err then 
                local success = Launcher.writeFile(fileName, data.data)
                if not success then 
                    Event.dispatch(EventDefine.ICON_DOWNLOADED, {userid = userid, err = {code = -1, msg = "save data to file error"}})
                    return
                end 
                local iconFileName = createResourceFileName(userid)
                Event.dispatch(EventDefine.ICON_DOWNLOADED, {userid = userid, iconFileName = iconFileName})
            else 
                Event.dispatch(EventDefine.ICON_DOWNLOADED, {userid = userid, err = data.err})
            end 
        end 
        Helper.request(iconURL, callback, "GET")
        return nil
    end 
    return createResourceFileName(userid)
end 


return IconManager
--endregion
