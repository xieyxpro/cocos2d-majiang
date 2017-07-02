--region ShaderDefine.lua
--Author : Administrator
--Date   : 2014-10-16
--此文件由[BabeLua]插件自动生成

local ShaderDefine = {}

function ShaderDefine.getFilter(filterName)
    return clone(ShaderDefine.FILTERS[filterName])
end

ShaderDefine.FILTERS = {
    
    ColorBalance = {"CUSTOM", {
                        frag = "ColorBalance.fsh",
                        -- [-100, 100]
                        u_colorRGB = {60, -55, 70},
                        u_highlight = 1.0,
                        shaderName = "ColorBalance"}
                },

    -- 明度调整
    Bright = {"CUSTOM", {
                        frag = "Bright.fsh",
                        u_bright = 0.6,
                        shaderName = "Bright"}
                },

    -- 明暗调整
    Highlight = {"CUSTOM", {
                        frag = "Highlight.fsh",
                        u_highlight = 2.3,
                        shaderName = "Highlight"}
                },

    -- 冰封效果
    Frozen = {"CUSTOM", {
                        frag = "Frozen.fsh",
			            shaderName = "Frozen"}
                },

    -- 冰冻效果(比较雪白)
    Ice = {"CUSTOM", {
                        frag = "Ice.fsh",
			            shaderName = "Ice"}
                },

    -- 虚化效果，类似透明
    Banish = {"CUSTOM", {
                        frag = "Banish.fsh",
                        shaderName = "Banish"}
                },
  
    -- 中毒效果
    Poison = {"CUSTOM", {
                        frag = "Poison.fsh",
			            shaderName = "Poison"}
                },

    -- 石化效果
    Stone = {"CUSTOM", {
                        frag = "Stone.fsh",
			            shaderName = "Stone"}
                },

    -- 镜像反射
    Mirror = {"CUSTOM", {
                        frag = "Mirror.fsh",
			            shaderName = "Mirror"}
                },



    -- 墨色效果
    Sepia = {"CUSTOM", {
                        frag = "Sepia.fsh",
			            shaderName = "Sepia"}
                },

    -- 高亮，移除透明部分
    Brightness = {"CUSTOM", {
                        frag = "Brightness.fsh",
			            shaderName = "Brightness",
                        u_brightness = 0.3}
                },

    -- 石化效果，有亮度
    SATURATION = {"CUSTOM", {
                        frag = "SATURATION.fsh",
			            shaderName = "SATURATION",
                        u_saturation = 0.3}
                },

    -- 彩色效果，取rgb变化
    RGB = {"CUSTOM", {
                        frag = "RGB.fsh",
			            shaderName = "RGB",
                        u_redAdj = 1,
                        u_greenAdj = 0.5,
                        u_blueAdj = 0.3}
                },

    -- 色相变化
    Hue = {"CUSTOM", {
                        frag = "Hue.fsh",
			            shaderName = "Hue",
                        u_hue = 100,    -- -180 ~ 180
                        u_saturation = 0}
                },

    -- 反差效果                    
    CONTRAST = {"CUSTOM", {
                        frag = "CONTRAST.fsh",
			            shaderName = "CONTRAST",
                        u_contrast = 2}
                },

    -- 曝光效果                    
    EXPOSURE = {"CUSTOM", {
                        frag = "EXPOSURE.fsh",
			            shaderName = "EXPOSURE",
                        u_exposure = 0.9}
                },

    -- 伽马
    GAMMA = {"CUSTOM", {
                        frag = "GAMMA.fsh",
			            shaderName = "GAMMA",
                        u_gamma = 2}
                },

    -- 灰度效果 全0为黑色，{0, 0, 0, 1}为白色                    
    Gray = {"CUSTOM", {
                        frag = "Gray.fsh",
			            shaderName = "Gray"}
                },

    ------------下面只适用静态图片-------------------

    -- 模糊效果
    Blur = {"CUSTOM", {
                        frag = "Blur.fsh",
                        blurSize = {0.002, 0.002},
			            shaderName = "Blur"}
                },

    -- 泛银发亮效果
    Bloom = {"CUSTOM", {
                        frag = "Bloom.fsh",
			            shaderName = "Bloom"}
                },

    -- 描边效果
    Outline = {"CUSTOM", {
                        frag = "Outline.fsh",
			            shaderName = "Outline",
                        u_outlineColor={1.0, 0.96, 0.81},
                        u_threshold = 0.75,
                        u_radius = 0.018 }
                },
}

return ShaderDefine

--endregion
