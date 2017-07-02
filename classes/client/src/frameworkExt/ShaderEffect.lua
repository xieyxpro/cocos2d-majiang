local ShaderEffect = {

        vertDefaultSource = "\n"..
        "attribute vec4 a_position; \n" ..
        "attribute vec2 a_texCoord; \n" ..
        "attribute vec4 a_color; \n"..                                                    
        "#ifdef GL_ES  \n"..
        "varying lowp vec4 v_fragmentColor;\n"..
        "varying mediump vec2 v_texCoord;\n"..
        "#else                      \n" ..
        "varying vec4 v_fragmentColor; \n" ..
        "varying vec2 v_texCoord;  \n"..
        "#endif    \n"..
        "void main() \n"..
        "{\n" ..
        "gl_Position = CC_PMatrix * a_position; \n"..
        "v_fragmentColor = a_color;\n"..
        "v_texCoord = a_texCoord;\n"..
        "}",

        pszFragSource2 = "#ifdef GL_ES \n" ..
        "precision mediump float; \n" ..
        "#endif \n" ..
        "uniform sampler2D u_texture; \n" ..
        "varying vec2 v_texCoord; \n" ..
        "varying vec4 v_fragmentColor;\n"..
        "uniform vec2 pix_size;\n"..
        "void main(void) \n" ..
        "{ \n" ..
        "vec4 sum = vec4(0, 0, 0, 0); \n" ..
        "sum += texture2D(u_texture, v_texCoord - 4.0 * pix_size) * 0.05;\n"..
        "sum += texture2D(u_texture, v_texCoord - 3.0 * pix_size) * 0.09;\n"..
        "sum += texture2D(u_texture, v_texCoord - 2.0 * pix_size) * 0.12;\n"..
        "sum += texture2D(u_texture, v_texCoord - 1.0 * pix_size) * 0.15;\n"..
        "sum += texture2D(u_texture, v_texCoord                 ) * 0.16;\n"..
        "sum += texture2D(u_texture, v_texCoord + 1.0 * pix_size) * 0.15;\n"..
        "sum += texture2D(u_texture, v_texCoord + 2.0 * pix_size) * 0.12;\n"..
        "sum += texture2D(u_texture, v_texCoord + 3.0 * pix_size) * 0.09;\n"..
        "sum += texture2D(u_texture, v_texCoord + 4.0 * pix_size) * 0.05;\n"..
        "gl_FragColor = sum;\n"..
        "}",

        --变灰
        psGrayShader = "#ifdef GL_ES \n" ..
        "precision mediump float; \n" ..
        "#endif \n" ..
        "varying vec4 v_fragmentColor; \n" ..
        "varying vec2 v_texCoord; \n" ..
        "void main(void) \n" ..
        "{ \n" ..
        "vec4 c = texture2D(CC_Texture0, v_texCoord); \n" ..
        "gl_FragColor.xyz = vec3(0.3*c.r + 0.15*c.g +0.11*c.b); \n"..
        "gl_FragColor.w = c.w; \n"..
        "}" ,

        --移除变灰
        psRemoveGrayShader = "#ifdef GL_ES \n" ..
        "precision mediump float; \n" ..
        "#endif \n" ..
        "varying vec4 v_fragmentColor; \n" ..
        "varying vec2 v_texCoord; \n" ..
        "void main(void) \n" ..
        "{ \n" ..
        "gl_FragColor = texture2D(CC_Texture0, v_texCoord); \n" ..
        "}" ,

        pszFragSource1 = "#ifdef GL_ES \n" ..
        "precision mediump float; \n" ..
        "#endif \n" ..
        "varying vec4 v_fragmentColor; \n" ..
        "varying vec2 v_texCoord; \n" ..
        "void main(void) \n" ..
        "{ \n" ..
        "vec4 c = texture2D(CC_Texture0, v_texCoord); \n" ..
        "gl_FragColor.xyz = vec3(0.3*c.r + 0.15*c.g +0.11*c.b); \n"..
        "gl_FragColor.w = c.w; \n"..
        "}" ,

}

function ShaderEffect:init()
    local pGrayProgram = cc.GLProgram:createWithByteArrays(self.vertDefaultSource,self.psGrayShader)
    pGrayProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    pGrayProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
    pGrayProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pGrayProgram:link()
    pGrayProgram:use()
    pGrayProgram:updateUniforms()
    cc.GLProgramCache:getInstance():addGLProgram(pGrayProgram,"pGrayProgram")


    local pRemoveGrayProgram = cc.GLProgram:createWithByteArrays(self.vertDefaultSource,self.psRemoveGrayShader)
    pRemoveGrayProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    pRemoveGrayProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
    pRemoveGrayProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pRemoveGrayProgram:link()
    pRemoveGrayProgram:use()
    pRemoveGrayProgram:updateUniforms()
    cc.GLProgramCache:getInstance():addGLProgram(pRemoveGrayProgram,"pRemoveGrayProgram")
end


function ShaderEffect:setGray(node)
    --变灰的
    local pProgram = cc.GLProgram:createWithByteArrays(self.vertDefaultSource,self.psGrayShader)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)

    pProgram:link()
    pProgram:use()
    pProgram:updateUniforms()
    node:setGLProgram(pProgram)
end

function ShaderEffect:reset(node)

    local pProgram = cc.GLProgram:createWithByteArrays(self.vertDefaultSource,self.psRemoveGrayShader)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)

    pProgram:link()
    pProgram:use()
    pProgram:updateUniforms()
    node:setGLProgram(pProgram)
end

function ShaderEffect:AddBlur(node)
    local fileUtiles = cc.FileUtils:getInstance()
    local vertSource = self.vertDefaultSource
    local fragSource = fileUtiles:getStringFromFile("shaders/example_Blur.fsh")
    local pProgram = cc.GLProgram:createWithByteArrays(vertSource, fragSource)
    node:setGLProgram(pProgram)
    --local glprogramstate = cc.GLProgramState:getOrCreateWithGLProgram(pProgram)
    local size = node:getTexture():getContentSizeInPixels()
    node:getGLProgramState():setUniformVec2("pix_size", size)
    node:getGLProgramState():setUniformFloat("blurRadius", 20.0);
    node:getGLProgramState():setUniformFloat("sampleNum", 0.1);
--    
--    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
--    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
--    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pProgram:link()
    pProgram:use()
    pProgram:updateUniforms()
end

-- 按钮置灰
function ShaderEffect:addGrayButton(button)
    if button == nil then
        cclog("param can't be nil")
        return
    end
    -- 遍历按钮的子节点
    --[[local children = button:getChildren()
    if children and #children>0 then
        for _, aSprite in ipairs(children) do
            if aSprite.getVirtualRenderer then
                self:setGray(aSprite:getVirtualRenderer():getSprite())        
            elseif aSprite.setGLProgram then
                self:setGray(aSprite)
            end
        end
    end
    ]]
    -- 按钮本身
    local sprite9 = button:getVirtualRenderer()     
    local sprite = sprite9:getSprite()
    self:setGray(sprite)
end

-- 按钮返回正常
function ShaderEffect:removeGrayButton(button)
    if button == nil then
        cclog("param can't be nil")
        return
    end
    -- 按钮本身
    local sprite9 = button:getVirtualRenderer()   
    local sprite = sprite9:getSprite()
    self:reset(sprite)
end

--遍历变灰
function ShaderEffect:setGrayAndChild(node,isNotRecursive)
    if node == nil then
        return
    end
    local array = node:getSpriteChildren()
    for key, var in pairs(array) do

        var:setGLProgram(cc.GLProgramCache:getInstance():getGLProgram("pGrayProgram"))
    end
    if isNotRecursive ~= true then
        --children
        local array = node:getChildren()
        for key, var in pairs(array) do
            self:setGrayAndChild(var)
        end
    end
end

--遍历取消变灰
function ShaderEffect:setRemoveGrayAndChild(node,isNotRecursive)
    if node == nil then
        return
    end
    local array = node:getSpriteChildren()
    for key, var in pairs(array) do
        var:setGLProgram(cc.GLProgramCache:getInstance():getGLProgram("pRemoveGrayProgram"))
    end
    if isNotRecursive ~= true then
        --children
        local array = node:getChildren()
        for key, var in pairs(array) do
            self:setRemoveGrayAndChild(var)
        end
    end

end

ShaderEffect:init()

return ShaderEffect