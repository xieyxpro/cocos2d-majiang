--region *.lua
--Date2016.12.27
--语音聊天模块

local ccfileutil = cc.FileUtils:getInstance()

local VoiceSDK = {
    bTalking = false,
    bCancle = false,
    time = 0,
    voice_store_tmp = ccfileutil:getWritablePath() .. "tallk/tmppath",
    voice_store_dir = ccfileutil:getWritablePath() .. "tallk",
    voice_store_path = ccfileutil:getWritablePath() .. "tallk/myvoice"
}

if not ccfileutil:isDirectoryExist(VoiceSDK.voice_store_dir) then
    ccfileutil:createDirectory(VoiceSDK.voice_store_dir)
end
if not ccfileutil:isDirectoryExist(VoiceSDK.voice_store_tmp) then
    ccfileutil:createDirectory(VoiceSDK.voice_store_tmp)
end

function VoiceSDK:resetParams()
    self.bTalking = false
    self.bCancle = false
    self.time = 0
end

--region callbackmsg
cc.exports.voice_record_finish = function(strfilepath, time, ext)
    printLog("voicesdk","VoiceSDK:voice_record_finish" .. strfilepath ..time .. ext)
    VoiceSDK.time = time
    Event.dispatch(EventDefine.VOICE_RECORD_FINISH,{strfilepath, time, ext})
end
--result为0表示成功，其他失败
cc.exports.voice_upload_finish = function(result, msg, fileurl, percent, ext)
    printLog("voicesdk","VoiceSDK:voice_upload_finish" .. result  .. msg .. fileurl .. percent ..ext)
    local bSuccess = false
    if 0 == result then
        bSuccess = true
    else
        printLog("voicesdk","voice_upload_finish err %d:%s",result,msg)
    end
    if not VoiceSDK.bCancle then
        Event.dispatch(EventDefine.VOICE_UPLOAD_FINISH,{bSuccess=bSuccess, fileurl=fileurl, time=VoiceSDK.time, ext=ext})    
    end
    VoiceSDK:resetParams()
end
cc.exports.voice_download_finish = function(percent, ext)
    printLog("voicesdk","VoiceSDK:voice_download_finish" .. percent  .. ext)    
    if 100 == percent then
        Event.dispatch(EventDefine.VOICE_DOWNLOAD_FINISH,{ext=ext})
    end
end
--播放完成为0,失败为1
cc.exports.voice_play_finish = function(result, describe, ext)
    printLog("voicesdk","VoiceSDK:voice_play_finish" .. result .. describe .. ext)
    local bSuccess = true
    if 0 ~= result then
        bSuccess = false
        printLog("voicesdk","voice_play_finish Error:%d-%s;ext:%s",result,describe,ext);
    end
    Event.dispatch(EventDefine.VOICE_PLAY_FINISH,{bSuccess=bSuccess, ext=ext})
end
--endregion
--region construction
local voicelib = CYYSDKManager:GetInstance()
voicelib:setCallBack("voice_record_finish","voice_upload_finish","voice_download_finish","voice_play_finish")
voicelib:initSDK(1000855,VoiceSDK.voice_store_tmp,false,false)

local scheduler = cc.Director:getInstance():getScheduler()
scheduler:scheduleScriptFunc(function()
        voicelib:YAYADispatchMsg()
end, 0, false)
--region

function VoiceSDK:Login(nickname,userid)
    voicelib:Login(nickname,userid)
end

function VoiceSDK:Logout()
    voicelib:Logout()
end

--开始录音的时候会自动上传
--savePath 带绝对路径的文件名
function VoiceSDK:startRecord( ext)
    printLog("voicesdk","VoiceSDK:startRecord")
    if self.bTalking then 
        return false
    end
    if ccfileutil:isFileExist(self.voice_store_path) then
        ccfileutil:removeFile(self.voice_store_path)
    end
    local bRecording = voicelib:startRecord(self.voice_store_path,ext)
    if bRecording then
        self.bTalking = true
    else
        printLog("voicesdk","VoiceSDK:startRecord fail")
    end
    return bRecording
end

function VoiceSDK:stopRecord()
    printLog("voicesdk","VoiceSDK:stopRecord")
    voicelib:stopRecord()
end

function VoiceSDK:cancleReocrd()
    printLog("voicesdk","VoiceSDK:cancleReocrd")
    self.bCancle = true
    voicelib:stopRecord()
end

function VoiceSDK:playRecord(url,chairid,ext)
    printLog("voicesdk","VoiceSDK:playRecord" .. url .. chairid .. ext)
    local path = self.voice_store_path .. tostring(chairid)
    if ccfileutil:isFileExist(path) then
        ccfileutil:removeFile(path)
    end

    if not voicelib:playRecord(url, path, ext) then
        return false
    end
    return true
end
function VoiceSDK:stopPlay()
    printLog("voicesdk","VoiceSDK:stopPlay")
    voicelib:stopPlay()
end

return VoiceSDK

--endregion
