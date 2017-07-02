--region UIButtonExt.lua
--Author : Administrator
--Date   : 2014-10-16
--此文件由[BabeLua]插件自动生成

local ShaderDefine = require("app.frameworkExt.ShaderDefine")

-- 点击触发的效果
Button.TouchedEffect = {
    Brightness = 1,
    Outline = 2,
}

Button.grayTextureSmall = "Images/UI/common/button/UI_common_anniu_6.png"
Button.grayTextureBig = "Images/UI/common/button/UI_common_anniu_7.png"

--添加按钮低框
function Button:addFrame(res,fix)
    local img = ImageView:create(res):addTo(self):pos(self:getContentSize().width/2,self:getContentSize().height/2)
    if fix then
        img:setScale9Enabled(true)
        img:setContentSize(cc.size(self:getContentSize().width + fix*2,self:getContentSize().height + fix*2))
    end
end

--[[--

按钮点击效果
sample:
    btn:setTouchedEffect(Button.TouchedEffect.Outline)
    btn:addTouchEventListenerExt(handler(self, self.onTest))

]]
function Button:setTouchedEffect(effectType)
    if effectType == Button.TouchedEffect.Brightness then
        self.touchedEffect = "Brightness"
    elseif effectType == Button.TouchedEffect.Outline then
        self.touchedEffect = "Outline"
    end
    
    if self.touchedEffect == "Brightness" and  self:getClickFileName() == "" then
        --设置点击后的图片
        self:loadTexturePressed(self:getNormalFileName())
    end
end

--[Comment]
--检测变灰状态匹配的纹理
function Button:mappedGrayStateTexture()
    if not self.normalTexture then 
        return 
    end 
    --print("[BUTTON] normal file name: "..tostring(self.normalTexture))
    local mapConfig = ClientConfig.common.t_button_texture_map[self.normalTexture]
    local texturePath = nil --指定使用的置灰状态的文理图片，默认使用一般按钮对应的置灰纹理
    if mapConfig then 
        texturePath = mapConfig.img_gray
    end 
    return texturePath
end 

--[[--

常态下的按钮效果
如变灰 
    btn:setEffect("Gray")

otherParams: 暂时搁置，未启用
]]
function Button:setEffect(effectType,otherParams)
    if not effectType then return end
    otherParams = otherParams or {}

    if not self.normalTexture then 
        self.normalTexture = string.gsub(self:getNormalFileName(),"Resources/","")
    end 
    
    ------------------------------
    local texturePath = self:mappedGrayStateTexture()
    if effectType == "Gray" and texturePath then 
        self:loadTextureNormal(texturePath)
    else 
        self:setBrightStyle(ccui.BrightStyle.highlight)
        self:getRealRenderer():showShaderEffect(effectType)
        self:getVirtualRenderer():showShaderEffect(effectType)
        self:setBrightStyle(ccui.BrightStyle.normal)
    end 
    self.normalEffect = effectType
end

--[[--

重置按钮效果，还原初始状态

]]
function Button:resetEffect()
    if self.normalEffect == "Gray" and self:mappedGrayStateTexture() then 
        self:loadTextureNormal(self.normalTexture)
    else 
        self:setBrightStyle(ccui.BrightStyle.highlight)
        self:getRealRenderer():resetShaderEffect()
        self:getVirtualRenderer():resetShaderEffect()
        self:setBrightStyle(ccui.BrightStyle.normal)
    end 
    self.normalEffect = nil
end

function Button:addTouchEventListenerExt(callback)
    local function reset()
        if not self.normalEffect then
            self:resetEffect()
        end
    end

    local function doCallback(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self:getVirtualRenderer():showShaderEffect(self.touchedEffect)
            self:getRealRenderer():showShaderEffect(self.touchedEffect)

        elseif eventType == ccui.TouchEventType.moved then
            if not self:hitTest(self:getTouchMovePosition()) then
                reset()
            else
                self:getRealRenderer():showShaderEffect(self.touchedEffect)
                self:getVirtualRenderer():showShaderEffect(self.touchedEffect)
            end
        elseif eventType == ccui.TouchEventType.ended then
            reset()

            if self._clickScale then
                self:setScale(self:getScale() + self._clickScale )
            end
        elseif eventType == ccui.TouchEventType.canceled then
            reset()
        end
        --播放点击音效
        if eventType == ccui.TouchEventType.ended then
            -- 播放音效
            local effect = self.normalEffect or ""
            if self.clickedSound and self.clickedSound ~= SOUNDS_DEFINE.CUSTOM then
                print("play sound: "..self.clickedSound)
                audio.playSoundExt(self.clickedSound)
            elseif not self.clickedSound then  
                print("play sound: "..SOUNDS_DEFINE.BTN_OPEN)
                audio.playSoundExt(SOUNDS_DEFINE.BTN_OPEN)
            end
--            if effect ~= "Gray" then 
--                if self.clickedSound and self.clickedSound ~= SOUNDS_DEFINE.CUSTOM then
--                    print("play sound: "..self.clickedSound)
--                    audio.playSoundExt(self.clickedSound)
--                elseif not self.clickedSound then  
--                    print("play sound: "..SOUNDS_DEFINE.BTN_OPEN)
--                    audio.playSoundExt(SOUNDS_DEFINE.BTN_OPEN)
--                end
--            else 
--                print("play sound: "..SOUNDS_DEFINE.DISABLED)
--                if not self.clickedSound or self.clickedSound ~= SOUNDS_DEFINE.CUSTOM then
--                    audio.playSoundExt(SOUNDS_DEFINE.DISABLED)
--                end 
        end
        --处理回调
        if callback then callback(sender, eventType) end
    end   
    self:addTouchEventListener(doCallback)
end

--[[--

增加按钮音效，在Define.lua中定义音效文件
sample:
    btn:setClickedSound(SOUNDS_DEFINE.BTN_OPEN)

]]
function Button:setClickedSound(soundName)
    self.clickedSound = soundName
end

--正常
function Button:setNormal()
    self:resetEffect()
end

--灰度
function Button:setGray(params)
    self:setEffect("Gray",params)
end
--endregion
