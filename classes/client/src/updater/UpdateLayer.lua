--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local UpdateLayer = class("UpdateLayer", cc.Layer)

local scheduler = cc.Director:getInstance():getScheduler()
local Launcher = require("updater.Launcher")
local errdef = require("updater.errdef")
local Updater = require("updater.Updater")
local PlatformHelper = require("app.sdk.PlatformHelper")
local PhoneState = require("app.sdk.PhoneState")


local function bindUINodes(node, bindTo, eventProcessor)
    local children = node:getChildren()
    for _, child in pairs(children) do 
        local name = child:getName()
        bindTo[name] = child
        bindUINodes(child, bindTo[name], eventProcessor)
        if tolua.type(child) == "ccui.Button" then 
            child:addTouchEventListener(function(target, event)
                if event == ccui.TouchEventType.began then 
                    target:setScale(0.9)
                elseif event == ccui.TouchEventType.ended or
                       event == ccui.TouchEventType.canceled then 
                    target:setScale(1.0)
                end 
                if event == ccui.TouchEventType.ended and eventProcessor and eventProcessor["onClick_"..name] then 
                    eventProcessor["onClick_"..name](eventProcessor, target)
                end 
            end)
        elseif tolua.type(child) == "ccui.Slider" then
            child:addEventListener(function(target, event)
                if eventProcessor and eventProcessor["onValueChanged_"..name] then 
                    eventProcessor["onValueChanged_"..name](eventProcessor, target)
                end
            end)
        elseif tolua.type(child) == "ccui.CheckBox" then
            child:addEventListener(function(target, eventType)
                if eventProcessor and eventProcessor["onChecked_"..name] then 
                    eventProcessor["onChecked_"..name](eventProcessor, target, eventType == ccui.CheckBoxEventType.selected)
                end
            end)
        end 
    end 
end 

function UpdateLayer:ctor()
    local uiNode = require("LaunchScene.UpdateLayer"):create().root:addTo(self)
    bindUINodes(uiNode, self, self)

    self.panMsg:setVisible(false)
    
    uiNode:setCascadeOpacityEnabled(true)
    uiNode:setOpacity(0)

    self.lblProgress:setString("正在更新")
    self.sldProgress:setPercent(0)

    self.sldProgress:setPercent(0)
    self.scheduleID = 0

    local act = cc.Sequence:create(
        cc.FadeIn:create(0.3),
        cc.CallFunc:create(function()
            local updater = Updater.getInstance()
            if updater.err.code ~= 0 then
                return 
            end 
--            self:update()
        end)
    )
    uiNode:runAction(act)
    
    self:update()
--    self:updateStatus()
end

--local function reload()
--    local unReloadModule = {["main"] = 1}
--    for k,v in pairs(package.loaded) do
--        --只有lua模块卸载
--        local path = string.gsub(k, "%.", "/");
--        path = cc.FileUtils:sharedFileUtils():fullPathForFilename("src/"..path..".lua");
--        local file = io.open(path);
--        if file and unReloadModule[k]==nil then
--            file:close();
--            local parent = require(k);
--            if type(parent) == "table" then
--                for k1,_ in pairs(parent) do
--                    parent[k1] = nil;
--                end
--            end                    
--            package.loaded[k] = nil;
--            _G[k] = nil;
--        end
--    end
--end

function UpdateLayer:loading()
    local inits = require("init")
    local loadLen = #inits
    local ndx = 0
    local scheduleID = 0
    scheduleID = scheduler:scheduleScriptFunc(function()
        if ndx >= loadLen then 
            self.lblProgress:setString("加载完成")
            scheduler:unscheduleScriptEntry(scheduleID)
            self:onLoadingCompleted()
        else 
            ndx = ndx + 1
            local iniFunc = inits[ndx]
            xpcall(function()
                iniFunc()
            end, function(errmsg)
                printInfo("Init error: %s", errmsg)
                scheduler:unscheduleScriptEntry(scheduleID)
            end)
            local percent = math.floor(ndx / loadLen * 100)
            self.lblProgress:setString(string.format("正在加载%d", percent) .. "%")
            self.sldProgress:setPercent(percent)
        end 
    end, 0.05, false)
end 

function UpdateLayer:onLoadingCompleted()
    require("app.MainApp").run()
end 

function UpdateLayer:onUpdateCompleted()
    local updater = Updater.getInstance()
    self.lblCurVersion:setText(updater.updateVersion or "")
    self.lblUpdateVersion:setVisible(false)
    self.lblUpdateVersionDesc:setVisible(false)

    local updater = Updater.getInstance()
    if updater.needReboot then 
        --clear and re-require
        package.loaded["updater.errdef"] = nil
        package.loaded["updater.Launcher"] = nil
        package.loaded["updater.LaunchLayer"] = nil
        package.loaded["updater.LaunchScene"] = nil
        package.loaded["updater.UpdateLayer"] = nil
        package.loaded["updater.Updater"] = nil

        package.loaded["LaunchScene.LaunchLayer"] = nil
        package.loaded["LaunchScene.UpdateLayer"] = nil
        package.loaded["first"] = nil
        
        package.loaded["app.sdk.PlatformHelper"] = nil
        package.loaded["app.sdk.PhoneState"] = nil

        package.preload["updater.errdef"] = nil
        package.preload["updater.Launcher"] = nil
        package.preload["updater.LaunchLayer"] = nil
        package.preload["updater.LaunchScene"] = nil
        package.preload["updater.UpdateLayer"] = nil
        package.preload["updater.Updater"] = nil

        package.preload["LaunchScene.LaunchLayer"] = nil
        package.preload["LaunchScene.UpdateLayer"] = nil
        package.preload["first"] = nil
        
        package.preload["app.sdk.PlatformHelper"] = nil
        package.preload["app.sdk.PhoneState"] = nil
        cc.FileUtils:getInstance():purgeCachedEntries() --very important

        require("updater.LaunchScene").runWithScene()
    else 
        self:loading()
    end 
end 

--[Comment]
--    local assetsManager = cc.AssetsManager:new(
--        "http://ojaqvi3c9.bkt.clouddn.com/hgmj/aaa.zip",
--        "http://ojaqvi3c9.bkt.clouddn.com/hgmj/version",
--        cc.FileUtils:getInstance():getWritablePath())
function UpdateLayer:downloadPackage(zipURL, versionURL)
    local ErrorCode = {
        CREATE_FILE = 0,
        NETWORK = 1,
        NO_NEW_VERSION = 2,
        UNCOMPRESS = 3,
    }
    local apkPath = cc.FileUtils:getInstance():getWritablePath() .. Launcher.packageNames[device.platform]
    printInfo("apkPath: %s", apkPath)
    local function onError(errno)
        local errMsgs = {
            [0] = "创建文件出错",
            [1] = "网络出错，请检查网络",
            [2] = "无更新版本安装包",
            [3] = "解压文件出错",
        }
        if errno == ErrorCode.NO_NEW_VERSION then 
            self.lblProgress:setString(string.format("最新安装包已下载成功，正在安装"))
            --install
            PlatformHelper:InstallApk(apkPath)
        else 
            local msg = errMsgs[errno] or string.format("Unknown error: %d", errno)
            self:showMsgBox({
                ok = false,
                cancel = true,
                okText = "确定",
                cancelText = "退出游戏",
                cancelCallback = function()
                    cc.Director:getInstance():endToLua() 
                    PlatformHelper:exitGame()
                end,
                desc = msg,
            })
        end 
    end 
    local function onProgress(percent)
        self.lblProgress:setString(string.format("正在下载最新安装包%d", percent).."%")
        self.sldProgress:setPercent(percent)
    end 
    local function onSuccess()
        self.lblProgress:setString(string.format("下载最新安装包成功，正在安装"))
        --install
        PlatformHelper:InstallApk(apkPath)
    end 

    if not zipURL or string.trim(zipURL) == "" then 
        assert(false)
    end 
    if not versionURL or string.trim(versionURL) == "" then 
        assert(false)
    end 
    local assetsManager = cc.AssetsManager:new(
        zipURL,
        versionURL,
        cc.FileUtils:getInstance():getWritablePath()
    )
    if not cc.FileUtils:getInstance():isFileExist(apkPath) then 
        assetsManager:deleteVersion()
    end 
    assetsManager:retain()
    assetsManager:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR )
    assetsManager:setDelegate(onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
    assetsManager:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS )
    assetsManager:setConnectionTimeout(3)
    assetsManager:checkUpdate()
    
    self.lblProgress:setString(string.format("正在下载最新安装包%d", 0).."%")
    self.sldProgress:setPercent(0)
end 

function UpdateLayer:onError(err)
    if err.code == errdef.E_NEED_BIG_VERSION_UPDATE then 
        self.lblCurVersion:setText(cc.Application:getInstance():getVersion())
        self.lblUpdateVersion:setText(err.lastestAppVersion)
--        device.platform = "android" --TODO testing
        if device.platform == "windows" then 
            self:showMsgBox({
                ok = false,
                cancel = true,
                okText = "确定",
                cancelText = "退出游戏",
                cancelCallback = function()
                    cc.Director:getInstance():endToLua() 
                    PlatformHelper:exitGame()
                end,
                desc = "请下载最新安装程序",
            })
        elseif device.platform == "android" then
            local netType = PhoneState:getNetworkType()
--            netType = "WIFI" --TODO testing
            if netType == "WIFI" then 
                self:downloadPackage(err.packageURL, err.versionURL)
--                self:downloadPackage("http://ojaqvi3c9.bkt.clouddn.com/hgmj/packages/android/test/__hgmj.zip", "http://ojaqvi3c9.bkt.clouddn.com/hgmj/packages/android/test/version")
            else 
                self:showMsgBox({
                    ok = true,
                    cancel = true,
                    okText = "确定",
                    cancelText = "退出游戏",
                    okCallback = function()
                        self:downloadPackage(err.packageURL, err.versionURL)
                    end,
                    cancelCallback = function()
                        cc.Director:getInstance():endToLua() 
                        PlatformHelper:exitGame()
                    end,
                    desc = string.format("您正在使用%s网络，点击确定下载最新安装包", netType),
                })
            end 
        elseif device.platform == "ios" then
            self:showMsgBox({
                ok = true,
                cancel = true,
                okText = "确定",
                cancelText = "退出游戏",
                okCallback = function()
                    local sharedApplication = cc.Application:getInstance()
                    sharedApplication:openURL(err.downloadURL)
                end,
                cancelCallback = function()
                    cc.Director:getInstance():endToLua() 
                    PlatformHelper:exitGame()
                end,
                desc = "请下载最新安装包，点击确定去到下载页面",
            })
        end 
    else
        local errMsg = errdef[err.code] or "unknown error: "
        errMsg = errMsg .. (err.msg or "")
        self:showMsgBox({
            ok = true,
            cancel = false,
            okText = "确定",
            okCallback = function()
                cc.Director:getInstance():endToLua() 
                PlatformHelper:exitGame()
            end,
            desc = errMsg,
        })
    end  
end 

function UpdateLayer:updateStatus()
    local updater = Updater.getInstance()
    self.lblCurVersion:setText(updater.curVersion)
    self.lblUpdateVersion:setText(updater.updateVersion)

    if updater.err.code ~= 0 then --error occurred
        if self.scheduleID ~= 0 then 
            scheduler:unscheduleScriptEntry(self.scheduleID)
        end 
        self:onError(updater.err)
        return
    end 
    if updater.status == Launcher.UPDATE_STATUS.CHECK_UPDATE then 
        self.lblProgress:setString("正在检查更新")
    elseif updater.status == Launcher.UPDATE_STATUS.FILES_COMPARE then 
        self.lblProgress:setString("正在检查文件")
    elseif updater.status == Launcher.UPDATE_STATUS.CHECK_COMPLETED then 
        self.lblProgress:setString("检查更新完成")
        updater:continueUpdate()
    elseif updater.status == Launcher.UPDATE_STATUS.DOWNLOADING then 
        local percent = updater.totalFilesNeedDownload > 0 and math.floor(updater.downloadedCnt / updater.totalFilesNeedDownload * 100) or 100
        self.lblProgress:setString(string.format("正在下载更新%d/%d", updater.downloadedCnt, updater.totalFilesNeedDownload))
        self.sldProgress:setPercent(percent)
    elseif updater.status == Launcher.UPDATE_STATUS.POST_DOWNLOAD then 
        self.lblProgress:setString("正在处理已下载内容")
    elseif updater.status == Launcher.UPDATE_STATUS.UNZIP then 
        self.lblProgress:setString("正在解压")
    elseif updater.status == Launcher.UPDATE_STATUS.DONE then 
        self.lblProgress:setString("更新完成")
        self.sldProgress:setPercent(100)
        scheduler:unscheduleScriptEntry(self.scheduleID)
        self:onUpdateCompleted()
    end
end 

function UpdateLayer:update()
    self.scheduleID = scheduler:scheduleScriptFunc(function()
        self:updateStatus()
    end, 0, false)
end 

function UpdateLayer:showMsgBox(params)
    params.ok = params.ok ~= nil and params.ok
    params.cancel = params.cancel ~= nil and params.cancel
    params.okText = params.okText or "确定"
    params.cancelText = params.cancelText or "取消"
    params.okCallback = params.okCallback or nil 
    params.cancelCallback = params.cancelCallback or nil 
    params.desc = params.desc or ""
    
    self.panMsg.okCallback = params.okCallback
    self.panMsg.cancelCallback = params.cancelCallback

    self.panMsg.btnOk:setVisible(params.ok)
    self.panMsg.btnCancel:setVisible(params.cancel)
    self.panMsg.btnOk:setTitleText(params.okText)
    self.panMsg.btnCancel:setTitleText(params.cancelText)
    self.panMsg.lblDesc:setString(params.desc)

    local panSz = self.panMsg:getContentSize()
    local btnSz = self.panMsg.btnOk:getContentSize()
    local btnAnpt = self.panMsg.btnOk:getAnchorPoint()
    local posY = self.panMsg.btnOk:getPositionY()
    if params.ok and params.cancel then 
        local posX1 = panSz.width * 0.5 - 20 - btnSz.width * (1 - btnAnpt.x)
        local posX2 = panSz.width * 0.5 + 20 + btnSz.width * btnAnpt.x 
        self.panMsg.btnOk:setPosition(cc.p(posX1, posY))
        self.panMsg.btnCancel:setPosition(cc.p(posX2, posY))
    elseif params.ok then 
        self.panMsg.btnOk:setPosition(cc.p(panSz.width * 0.5, posY))
    elseif params.cancel then 
        self.panMsg.btnCancel:setPosition(cc.p(panSz.width * 0.5, posY))
    end 

    self.panMsg:setVisible(true)
end 

function UpdateLayer:onClick_btnOk(target)
    if self.panMsg.okCallback then 
        self.panMsg.okCallback()
    end 
    self.panMsg:setVisible(false)
end 

function UpdateLayer:onClick_btnCancel(target)
    if self.panMsg.cancelCallback then 
        self.panMsg.cancelCallback()
    end 
    self.panMsg:setVisible(false)
end 

return UpdateLayer
--endregion
