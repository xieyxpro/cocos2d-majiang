--region NewFile_1.lua
--Author : Administrator
--Date   : 2015-1-8
--此文件由[BabeLua]插件自动生成

--声音文件后缀
local filePrefix = ""

local Audio = {}

Audio.musicVolume = 1.0
Audio.effectVolume = 1.0
Audio.musicEnabled = true
Audio.effectEnabled = true 
Audio.currentPlayMusicFileName = ""

local audioEngine = cc.SimpleAudioEngine:getInstance()

function Audio:playBGMusic(fileName)
    self.currentPlayMusicFileName = fileName
    if not self.musicEnabled then 
        return 
    end 
    if self.currentPlayMusicFileName == "" then 
        return
    end 
    audioEngine:playMusic(fileName, true)
end 

function Audio:stopBGMusic()
    audioEngine:stopMusic()
end

function Audio:setMusicVolume(volume)
    self.musicVolume = volume
    audioEngine:setMusicVolume(volume)
end 

function Audio:playEffect(fileName)
    if not self.effectEnabled then 
        return 
    end 
    print(fileName)
    audioEngine:playEffect(fileName, false, 1.0, 0.0, 1.0)
end

function Audio:setEffectVolume(volume)
    self.effectVolume = volume
    audioEngine:setEffectsVolume(volume)
end 

function Audio:enableEffect(enabled)
    if self.effectEnabled == enabled then 
        return 
    end 
    self.effectEnabled = enabled
end 

function Audio:enableMusic(enabled)
    if self.musicEnabled == enabled then 
        return 
    end 
    self.musicEnabled = enabled
    if self.musicEnabled then 
        self:playBGMusic(self.currentPlayMusicFileName)
    else 
        self:stopBGMusic()
    end 
end 

return Audio

--endregion
