--region NewFile_1.lua
--Author : Kevin
--Date   : 2015/3/27
--此文件由[BabeLua]插件自动生成

local ShaderDefine = require("app.frameworkExt.ShaderDefine")

--[[--

变灰 
    img:setEffect("Gray")
]]
function ImageView:setEffect(effectType,...)
    self:setBrightStyle(ccui.BrightStyle.highlight)
    self:getRealRenderer():showShaderEffect(effectType,...)
    self:getVirtualRenderer():showShaderEffect(effectType,...)
    self:setBrightStyle(ccui.BrightStyle.normal)
end 

--[[--

重置效果，还原初始状态

]]
function ImageView:resetEffect()
    self:setBrightStyle(ccui.BrightStyle.highlight)
    self:getRealRenderer():resetShaderEffect()
    self:getVirtualRenderer():resetShaderEffect()
    self:setBrightStyle(ccui.BrightStyle.normal)
end 

--endregion
