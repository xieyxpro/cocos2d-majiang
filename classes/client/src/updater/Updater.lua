--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local io = io

local Launcher = require("updater.Launcher")
local errdef = require("updater.errdef")

local Updater = class("Updater")

local _instance = nil

local filesCDN = ""

function Updater.getInstance()
    _instance = _instance or Updater:create()
    return _instance
end 

local fileUtils = cc.FileUtils:getInstance()
local scheduler = cc.Director:getInstance():getScheduler()
local writeablePath = Launcher.writeablePath

function Updater:ctor(params)
    self.downloadedSize = 0
    self.totalSize = 0
    self.err = {code = 0, msg = ""}
    self.updatingFiles = {}
    self.tmpFiles = {} --{{fileName = ?, tmpFileName = ?}, ...}
    self.downloadedCnt = 0
    self.fileDownloading = false
    self.totalFilesNeedDownload = 0
    self.totalSize = 0
    self.downloadedSize = 0
    self.status = Launcher.UPDATE_STATUS.NONE
    self.continue = false
    self.downloadIndex = 0
    self.downloadRetryCnt = 0
    self.needReboot = false
    self.curVersion = "未知"
    self.updateVersion = "未知"
end 

function Updater:createUrl(fileName)
    return string.format("%s/%s/%s/%s", filesCDN, Launcher.platform, Launcher.channel, fileName)
end 

function Updater:downloadFirst()
    local downloadURL = string.format("%s/%s/%s/%s?platform=%s&channel=%s&filename=%s&appversion=%s", 
        Launcher.firstCDN, 
        Launcher.platform, 
        Launcher.channel, 
        Launcher.firstFileName,
        Launcher.platform, 
        Launcher.channel, 
        Launcher.firstFileName,
        Launcher.appVersion)
    self:__download(Launcher.firstFileName, downloadURL)
end 

function Updater:downloadFlist()
    self:__download(Launcher.flistFileName)
end 

function Updater:toVersionString(versionTbl)
    local version = ""
    for i, v in ipairs(versionTbl) do
        if i < #versionTbl then 
            version = version .. tostring(v) .. "."
        else 
            version = version .. tostring(v)
        end 
    end 
    return version
end 

function Updater:__checkUpdate()
    local firstRemoteData = ""
    if not DEBUG or DEBUG == 0 then 
        firstRemoteData = self:readFileData(Launcher.firstFileName .. Launcher.tmpSuffix)
    else 
        firstRemoteData = self:readFileData(Launcher.firstFileName .. Launcher.tmpSuffix)
    end 
    Launcher.writeFile(writeablePath.."src/first_tmp."..Launcher.luaSuffix, firstRemoteData)
--    print(firstRemoteData)
    local localFirst = require("first")
    local remoteFirst = require("src.first_tmp")
    assert(remoteFirst, "remoteFirst is nil(table expected)")
--    printInfo("localFirst: " .. table.tostring(localFirst, true))
--    printInfo("remoteFirst: " .. table.tostring(remoteFirst, true))
--    printInfo("Launcher.appVersion: " .. Launcher.appVersion)
    --设置文件更新服务器CDN
    filesCDN = remoteFirst.filesCDN

    --compare version
    local localVersion = self:toVersionString(localFirst.minorVersion or {1, 0, 0, 0})
    local remoteVersion = self:toVersionString(remoteFirst.minorVersion or {1, 0, 0, 0})

    self.updateVersion = remoteVersion

    if Launcher.appVersion ~= remoteFirst.appVersion then --大版本需要更新，需要重新下载安装包
        self.err.code = errdef.E_NEED_BIG_VERSION_UPDATE
        self.err.msg = remoteFirst.packageURL
        self.err.packageURL = remoteFirst.packageURL
        self.err.versionURL = remoteFirst.versionURL
        self.err.lastestAppVersion = remoteFirst.appVersion
        self.err.downloadURL = remoteFirst.downloadURL
        return false
    end 

    if localVersion == remoteVersion then 
        self.status = Launcher.UPDATE_STATUS.CHECK_COMPLETED
    else 
        self.status = Launcher.UPDATE_STATUS.FILES_COMPARE
    end 
end 

function Updater:__compareFlist()
    local flistRemoteData = ""
    if not DEBUG or DEBUG == 0 then 
        flistRemoteData = self:readFileData(Launcher.flistFileName .. Launcher.tmpSuffix)
    else 
        flistRemoteData = self:readFileData(Launcher.flistFileName .. Launcher.tmpSuffix)
    end 
    Launcher.writeFile(writeablePath.."src/flist_tmp."..Launcher.luaSuffix, flistRemoteData)
    local localFlist = require("flist")
    local remoteFlist = require("src.flist_tmp")
    assert(remoteFlist, "remoteFlist is nil(table expected)")
    
    self.updatingFiles = {}
    for fileName, fileInfo in pairs(remoteFlist.files or {}) do 
        local localFileInfo = localFlist.files[fileName]
        if not localFileInfo or localFileInfo.md5 ~= fileInfo.md5 then 
            table.insert(self.updatingFiles, {fileName = fileName, fileInfo = fileInfo})
        end 
    end 
    self.downloadedCnt = 0
    self.totalFilesNeedDownload = 0
    self.totalSize = 0
    self.downloadedSize = 0
    for _, file in pairs(self.updatingFiles) do 
        local fileInfo = file.fileInfo
        self.totalFilesNeedDownload = self.totalFilesNeedDownload + 1
        self.totalSize = self.totalSize + fileInfo.size
        print(file.fileName)
        local i, j = string.find(file.fileName, Launcher.RebootTriggerFileName)
        if i and j then 
            self.needReboot = true
        end 
    end 
end 

function Updater:continueUpdate()
    self.continue = true
end 

function Updater:start()
    --check local version
    local localFirst = require("first")
    self.curVersion = self:toVersionString(localFirst.minorVersion)
    self.updateVersion = self.curVersion

    self.continue = false
    self.status = Launcher.UPDATE_STATUS.CHECK_UPDATE
    local scheduleID = 0
    self:downloadFirst()
    scheduleID = scheduler:scheduleScriptFunc(function()
        if self.err.code ~= 0 then --error occurred
            scheduler:unscheduleScriptEntry(scheduleID)
            return
        end 
        if self.status == Launcher.UPDATE_STATUS.CHECK_UPDATE then --检查更新
            if not self:isFileDownloaded(Launcher.firstFileName) then 
                return
            end 
            self:__checkUpdate()
            if self.status == Launcher.UPDATE_STATUS.FILES_COMPARE then 
                self:downloadFlist()
            end 
        end 
        if self.status == Launcher.UPDATE_STATUS.FILES_COMPARE then --对比版本
            if not self:isFileDownloaded(Launcher.flistFileName) then 
                return
            end 
            self:__compareFlist()
            self.status = Launcher.UPDATE_STATUS.CHECK_COMPLETED
        end 
        if self.status ~= Launcher.UPDATE_STATUS.CHECK_COMPLETED then 
            return 
        end 
        if self.totalFilesNeedDownload == 0 then 
            --no need to update
            self.status = Launcher.UPDATE_STATUS.DONE
            print("no update files")
            scheduler:unscheduleScriptEntry(scheduleID)
        else 
            if not self.continue then 
                return 
            end 
            self:__start()
            self.status = Launcher.UPDATE_STATUS.DOWNLOADING
            scheduler:unscheduleScriptEntry(scheduleID)
        end 
    end, 0, false)
end 

function Updater:readFileData(fileName)
    return Launcher.readFile(writeablePath .. fileName)
--    return fileUtils:getStringFromFile(writeablePath .. fileName)
end 

function Updater:getFileDir(fileName)
    local cv1 = string.byte("/", 1)
    local cv2 = string.byte("\\", 1)
    local i = fileName:len()
    while i > 0 do 
        local b = string.byte(fileName, i)
        if b == cv1 or b == cv2 then 
            break
        end 
        i = i - 1
    end 
    if i == 0 then 
        return "/"
    end 
    return string.sub(fileName, 1, i)
end 

function Updater:getFileInfo(fileName)
    local cv1 = string.byte("/", 1)
    local cv2 = string.byte("\\", 1)
    local i = fileName:len()
    while i > 0 do 
        local b = string.byte(fileName, i)
        if b == cv1 or b == cv2 then 
            break
        end 
        i = i - 1
    end 
    if i == 0 then 
        return "/", ""
    end 
    local dir = string.sub(fileName, 1, i) or "" 
    local shortFileName = string.sub(fileName, i + 1, fileName:len()) or ""
    return dir, shortFileName
end 

function Updater:writeToFile(fileName, data)
    local file = {
        shortFileName = "", 
        fileName = writeablePath .. fileName, 
        tmpFileName = writeablePath .. fileName .. Launcher.tmpSuffix, 
        path = ""
    }
    local dir, shortFileName = self:getFileInfo(file.fileName)
    file.path = dir
    file.shortFileName = shortFileName
    if not fileUtils:isDirectoryExist(dir) then 
        if not fileUtils:createDirectory(dir) then 
            self.err.code = errdef.E_IO_CREATE_DIRECTORY
            return false
        end 
    end 
--    print(data)
    print(file.tmpFileName)
    local success = Launcher.writeFile(file.tmpFileName, data)
    if not success then 
        self.err.code = errdef.E_IO_WRITE
        self.err.msg = string.format("write file %s error", file.fileName)
        return false
    end 
    self.tmpFiles[fileName] = file
--    table.insert(self.tmpFiles, file)
    print(string.format("File: %s downloaded, %dB", file.fileName, data:len()))
    return true
end 

--update的善后处理
function Updater:postDownload()
    local function copyAndDelete(from, to)
        local content = Launcher.readFile(from)
        if not content then 
            self.err.code = errdef.E_IO_READ
            self.err.msg = string.format("read file %s error", from)
            return 
        end 
        local success = Launcher.writeFile(to, content)
        if not success then 
            self.err.code = errdef.E_IO_WRITE
            self.err.msg = string.format("write file %s error", tmpFile.fileName)
        end 
        fileUtils:removeFile(from)
    end 
    local flistFile = nil 
    local firstFile = nil 
    for _, tmpFile in pairs(self.tmpFiles) do 
        if tmpFile.shortFileName == Launcher.flistFileShortName then 
            flistFile = tmpFile
        elseif tmpFile.shortFileName == Launcher.firstFileShortName then 
            firstFile = tmpFile
        else 
            printInfo("ReplaceShortFileName: %s", tmpFile.shortFileName)
            copyAndDelete(tmpFile.tmpFileName, tmpFile.fileName)
            if self.err.code ~= 0 then 
                return 
            end 
        end 
    end 
    --copy and replace flist.lua
    if not flistFile then 
        error("FList file not downloaded")
    end 
    copyAndDelete(writeablePath.."src/flist_tmp."..Launcher.luaSuffix, flistFile.fileName)
    if self.err.code ~= 0 then 
        return 
    end 
    --copy and replace first.lua
    copyAndDelete(writeablePath.."src/first_tmp."..Launcher.luaSuffix, firstFile.fileName)
    if self.err.code ~= 0 then 
        return 
    end 
    self.status = Launcher.UPDATE_STATUS.DONE
end 

function Updater:__download(fileName, downloadURL)
    local http = cc.XMLHttpRequest:new()
    http.responseType = cc.XMLHTTPREQUEST_RESPONSE_BLOB
    local url = downloadURL or self:createUrl(fileName)
    http:open("POST", url)
    local function delayExec(callFunc, delayTime)
        local scheduleID = 0
        scheduleID = scheduler:scheduleScriptFunc(function()
            callFunc()
            scheduler:unscheduleScriptEntry(scheduleID)
        end, delayTime, false)
    end 
    local function scheduleFunc()
        if http.status ~= 200 then 
            if self.downloadRetryCnt < Launcher.DOWNLOADRETRYTIMES then 
                --retry
                self.downloadRetryCnt = self.downloadRetryCnt + 1
                printInfo("download %s failed, retry %d", fileName, self.downloadRetryCnt)
                self:__download(fileName)
            else
                printInfo("download %s failed", fileName)
                self.err.code = errdef.E_NET_UNKNOWN
                self.err.msg = http.statusText
            end 
            return 
        end 
        self.downloadRetryCnt = 0
        local succ = self:writeToFile(fileName, http.response)
        if succ then 
            self.downloadedCnt = self.downloadedCnt + 1
            self.fileDownloading = false
        end 
    end 
    local function onReadyStateChange()
        delayExec(scheduleFunc, 0)
    end 
    http:registerScriptHandler(onReadyStateChange)
    http:send()
end 

function Updater:isFileDownloaded(fileName)
    return self.tmpFiles[fileName] ~= nil
end 

function Updater:__downloadUpdateFiles(index)
    printInfo("DownloadIndex: %d", index)
    local file = self.updatingFiles[index]
    self:__download(file.fileName)
end 

function Updater:__start()
    local mSchedulerID = 0
    self.downloadIndex = 0
    mSchedulerID = scheduler:scheduleScriptFunc(function()
        if self.err.code ~= 0 then --error occurred
            scheduler:unscheduleScriptEntry(mSchedulerID)
            return
        end 
        if self.downloadIndex > 0 then 
            if not self:isFileDownloaded(self.updatingFiles[self.downloadIndex].fileName) then 
                return
            end
        end 
        if self.downloadedCnt >= self.totalFilesNeedDownload then 
            self.status = Launcher.UPDATE_STATUS.POST_DOWNLOAD
            self:postDownload()
            scheduler:unscheduleScriptEntry(mSchedulerID)
            return
        end 
        if self.fileDownloading then 
            return 
        end 
        printInfo(string.format("DownloadCount: %d, NeedDownloadCnt: %d", self.downloadedCnt, self.totalFilesNeedDownload))
        self.downloadIndex = self.downloadIndex + 1
        self.fileDownloading = true
        self:__downloadUpdateFiles(self.downloadIndex)
    end, 0, false)
end 

function Updater:downloadPackage(fileName, downloadURL)
    local http = cc.XMLHttpRequest:new()
    http.responseType = cc.XMLHTTPREQUEST_RESPONSE_BLOB
    local url = downloadURL
    http:open("POST", url)
    local function onReadyStateChange()
        if http.status ~= 200 then 
            if self.downloadRetryCnt < Launcher.DOWNLOADRETRYTIMES then 
                --retry
                self.downloadRetryCnt = self.downloadRetryCnt + 1
                printInfo("download %s failed, retry %d", fileName, self.downloadRetryCnt)
                self:__download(fileName)
            else
                printInfo("download %s failed", fileName)
                self.err.code = errdef.E_NET_UNKNOWN
                self.err.msg = http.statusText
            end 
            return 
        end 
        self.downloadRetryCnt = 0
        local succ = Launcher.writeFile(fileName, http.response, "a+b")
--        local succ = self:writeToFile(fileName, http.response)
        if not succ then 
            self.err.code = errdef.E_IO_WRITE
            self.err.msg = "write package error"
            return
        end 
--        delayExec(scheduleFunc, 0)
    end 
    http:registerScriptHandler(onReadyStateChange)
    http:send()
end 

return Updater
--endregion
