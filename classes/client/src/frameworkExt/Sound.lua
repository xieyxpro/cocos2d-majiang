--使用cocos中AudioEngine引擎
local Sound = {}

ccexp.AudioEngine:lazyInit()

Sound.effectVolume = 0.5
Sound.musicVolume = 0.5
Sound.effectEnabled = true
Sound.musicEnabled = true

-- print(string.format("effectVolume:[%f] musicVolume:[%f]", self.effectVolume, self.musicVolume))

--切回来恢复播放
function Sound:resumeAllSound()
	ccexp.AudioEngine:resumeAll()
end
--进入后台停止播放
function Sound:pauseAllSound()
	ccexp.AudioEngine:pauseAll()
end

--region volume
-- @param 音量值0~1
function Sound:setEffectVolume(effectVolume)
	self.effectVolume = effectVolume
end
function Sound:getEffectVolume()
	return self.effectVolume
end

-- @param musicVolume 音乐音量0~1
function Sound:setMusicVolume(musicVolume)
	self.musicVolume = musicVolume

	if self.musicEnabled and self.musicAudioID then
		ccexp.AudioEngine:setVolume(self.musicAudioID, musicVolume)
	end
end

function Sound:getMusicVolume()
	return self.musicVolume
end
function Sound:enableEffect(enabled)
    self.effectEnabled = enabled
end
function Sound:enableMusic(enabled)
    if self.musicEnabled == enabled then
        return
    end
    self.musicEnabled = enabled
    if self.musicEnabled then
		ccexp.AudioEngine:setVolume(self.musicAudioID, self.musicVolume)
    else        
		ccexp.AudioEngine:setVolume(self.musicAudioID, 0)
    end
end
--endregion
function Sound:playEffect(fileName, isLoop)
	-- 关闭声音并且非循环
	if not self.effectEnabled or not fileName or string.len(fileName) == 0 then
		return
	end

	local fileSuffix = "mp3"
	if device.platform == "android" then
		-- fileSuffix = "ogg"
	elseif device.platform == "ios" then
		-- fileSuffix = "caf"
	end
	local filePath = string.format("raw/%s.%s", fileName, fileSuffix)
	isLoop = isLoop or false
	local audioID = ccexp.AudioEngine:play2d(filePath, isLoop, self.effectVolume)

	return audioID
end
function Sound:stopEffect(audioID)
	if not audioID then return end
	ccexp.AudioEngine:stop(audioID)
end
function Sound:pauseEffect(audioID)
	if not audioID then return end
	ccexp.AudioEngine:pause(audioID)
end
function Sound:resumeEffect(audioID)
	if not audioID then return end
	ccexp.AudioEngine:resume(audioID)
end

function Sound:playBGMusic(fileName,isLoop)
	if not fileName or string.len(fileName) == 0 then
		return
	end
	-- print("self.musicVolume = " .. self.musicVolume .. ", isLoop = " .. tostring(isLoop))
	isLoop = true
	self:stopBGMusic()
    local volume = self.musicEnabled and self.musicVolume or 0
	self.musicAudioID = ccexp.AudioEngine:play2d(string.format("raw/%s.mp3", fileName), isLoop, volume)
end
function Sound:stopBGMusic()
	if not self.musicAudioID then
		return
	end

	ccexp.AudioEngine:stop(self.musicAudioID)
	self.musicAudioID = nil
end

return Sound



