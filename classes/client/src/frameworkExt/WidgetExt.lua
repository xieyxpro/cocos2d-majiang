local WidgetExt = {}

local ShaderEffect = require("frameworkExt.ShaderEffect")

WidgetExt.HorizontalMargin = 
{
    LEFT = 0,
    CENTER = 1,
    RIGHT = 2
}
WidgetExt.VerticalMargin = 
{
    TOP = 0,
    CENTER = 1,
    BOTTOM = 2
}
WidgetExt.Order = 
{
    DESCENDING = 1,
    ASCENDING = 2
}
WidgetExt.CenterType = 
{
    HORIZONTAL = 1,
    VERTICAL = 2,
    BOTH = 3,
}

WidgetExt.MaxZOrder = 999

---------------------------Node扩展--------------------
--param center = {x = ,y = }
--param left_bottom = {x = ,y = }
--param left_top = {x = ,y = }
--param right_bottom = {x = ,y = }
--param right_top = {x = ,y = }
--parama rect
function cc.Node:getAroundAndCenterPos()
    assert(not tolua.isnull(self), "widgetUtil.getAroundAndCenterPos(widget) - widget is not CCNode")
    local poss = {}
    local size = self:getContentSize()
    local anPos = self:getAnchorPoint()
    local scale = self:getScale()
    local size = cc.size(size.width * scale,size.height* scale)
    local pos = self:getParent():convertToWorldSpace(cc.p(self:getPosition()))
    poss.center = {x = pos.x + (size.width/2 - size.width*anPos.x),y = pos.y + (size.height/2 - size.height*anPos.y) }
    poss.left_bottom = {x = pos.x + (0 - size.width*anPos.x),y = pos.y + (0 - size.height*anPos.y) }
    poss.left_top = {x = pos.x + (0 - size.width*anPos.x),y = pos.y + (size.height - size.height*anPos.y) }
    poss.right_bottom = {x = pos.x + (size.width - size.width*anPos.x),y = pos.y + (0 - size.height*anPos.y) }
    poss.right_top = {x = pos.x + (size.width - size.width*anPos.x),y = pos.y + (size.height - size.height*anPos.y) }
    poss.rect = CCRect(poss.left_bottom.x,poss.left_bottom.y,size.width,size.height)
    return poss
end

----------------------------------------------------------

function ccui.CheckBox:setSelectedExt(checked)
    self.checked = checked
    self:setSelected(checked)
end 

function ccui.CheckBox:getSelectedExt(checked)
    return self.checked ~= nil and self.checked or false
end 

--------ScrollView扩展-----------------------

--params
function ccui.ScrollView:scrollingVisibleNodes(appearTime,lostTime,lostDelayTime,...)
    appearTime = appearTime or 1
    lostTime = lostTime or 1
    lostDelayTime = lostDelayTime or 1
    local open = false
    local nodes = {...}
    local state = "stop"

    local function stop(nodes_)
        state = "stop"
        nodes_[1]:stopAllActions()
        local actions = {}
        for _,v in ipairs(nodes_) do
            table.insert(actions,cc.TargetedAction:create(v,cc.FadeTo:create(lostTime,0)))
        end
        if next(actions) then
            local spaw = cc.Spawn:create(unpack(actions))
            transition.execute(nodes_[1],spaw,{delay = lostDelayTime})
        end
    end

    local function run(nodes_)
        if state == "stop" then
            nodes_[1]:stopAllActions()
            state = "runing"
            local actions = {}
            for _,v in ipairs(nodes_) do
                table.insert(actions,cc.TargetedAction:create(v,cc.FadeTo:create(appearTime,255)))
            end
            if  next(actions) then
                local spaw = cc.Spawn:create(unpack(actions))
                transition.execute(nodes_[1],spaw,{onComplete = function() 
                    stop(nodes_)
                end})
            end
        end
    end
    
    local function defaultStop(nodes_)
        state = "stop"
        for _,v in ipairs(nodes_) do
            v:setOpacity(0)
        end
    end
    self:addEventListenerScrollViewExt(function(sender,eventType)
        
        if open then
            run(nodes)
        end
    end)

    self:addTouchEventListenerExt(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then
            open = true
        elseif eventType == ccui.TouchEventType.ended then
            open = false
        elseif eventType == ccui.TouchEventType.canceled then
            open = true
        end
    end)
    --默认消失
    defaultStop(nodes)
end

--点击事件扩展
function ccui.ScrollView:addTouchEventListenerExt(callback)
    self.touchEventScrollListeners =  self.touchEventScrollListeners or {}
    table.insert(self.touchEventScrollListeners,callback)
    if #self.touchEventScrollListeners <= 1  then
        self:addTouchEventListener(function(sender,eventType)
            for _,v in ipairs(self.touchEventScrollListeners) do
                v(sender,eventType)
            end
        end)
    end
end
--滑动事件扩展
function ccui.ScrollView:addEventListenerScrollViewExt(callback)
    self.EventScrollListeners =  self.EventScrollListeners or {}
    table.insert(self.EventScrollListeners,callback)
    if #self.EventScrollListeners <= 1  then
        self:addEventListener(function(sender,eventType)
            for _,v in ipairs(self.EventScrollListeners) do
                v(sender,eventType)
            end
        end)
    end
end

--scrollView所有子孩子排序和确定位置
function ccui.ScrollView:sortAllChildrenExt(isSort,isAdapteHeight)
   lineCount = self.lineCount or 1
   intWidth = self.intWidth or 0
   
   local child  = self:getChildren()
   local count = #child
   if isSort  == nil then
       isSort = true
   end
   if isSort then
       --排序
       table.sort(child,function(a,b) return (a.sortIndex or 0) < (b.sortIndex or 0)  end)
   end
   local dir = self:getDirection()
   local size = self:getContentSize()
   if not child[1] then
        return
   end
   local childSize = child[1]:getContentSize()
   if dir == ccui.ScrollViewDir.vertical then
        if isAdapteHeight and lineCount ==1 then
            local height,height_ = 0,0
            for _,v in ipairs(child) do
                local childSize = v:getContentSize()
                height = height + childSize.height + intWidth
            end
            if height >size.height then
                self:setInnerContainerSize(cc.size(size.width,height))
            else
                self:setInnerContainerSize(cc.size(size.width,size.height))
            end
            local size = self:getInnerContainerSize()
            for _,v in ipairs(child) do
                local childSize = v:getContentSize()
                local index = _ - 1
                v:setAnchorPoint(cc.p(0.5,0.5))
                local horInterval  = (size.width - childSize.width*lineCount)/(lineCount+1) --横排将谔谔
                local x = horInterval+ childSize.width/2 +(childSize.width+horInterval)* (index % lineCount)
                local y = size.height - (height_ + childSize.height/2 + intWidth)
                v:setPosition(cc.p(x,y))
                height_ = height_ + childSize.height + intWidth
            end
        else
            local horInterval  = (size.width - childSize.width*lineCount)/(lineCount+1) --横排将谔谔
            local height = (childSize.height + intWidth )* math.ceil(count/lineCount)
            local innerContainerSize = cc.size(size.width,height < size.height and size.height or height)
            self:setInnerContainerSize(innerContainerSize)
            for _,v in ipairs(child) do
                local index = _ - 1
                v:setAnchorPoint(cc.p(0.5,0.5))
                local x = horInterval+ childSize.width/2 +(childSize.width+horInterval)* (index % lineCount)
                local y = innerContainerSize.height - ((childSize.height + intWidth )* math.floor(index/lineCount) + childSize.height/2 + (intWidth - 1))
                v:setPosition(cc.p(x,y))
            end
        end
   else
        local verInterval  = (size.height - childSize.height*lineCount)/(lineCount+1) --竖排间隔
        local width = (childSize.width + intWidth )* math.ceil(count/lineCount)
        local innerContainerSize = cc.size(width < size.width and size.width or width,size.height)
        self:setInnerContainerSize(innerContainerSize)
        for _,v in ipairs(child) do
            local index = _ - 1
            v:setAnchorPoint(cc.p(0.5,0.5))
            local x =(childSize.width + intWidth )* math.floor(index/lineCount) + childSize.width/2 + intWidth
            local y =size.height - (verInterval+ childSize.height/2 +(childSize.height+verInterval)* (index % lineCount)) 
            v:setPosition(cc.p(x,y))
        end
   end
   if self.slider then
        self.slider:refresh()
   end

end
--自适应子孩子内容大小
function ccui.ScrollView:adaptiveChildsHeight()
    local childs = self:getChildren()
    local height = 0
    for _,v in ipairs(childs) do
        if v:isVisible() then
            height =height +  v:getContentSize().height
        end
    end
    local lSize = self:getContentSize()
    self:setInnerContainerSize(cc.size(lSize.width,height <= self:getContentSize().height and self:getContentSize().height or height))
    return height
end
function ccui.ScrollView:adaptiveChildsWidth()
    local childs = self:getChildren()
    local width = 0
    for _,v in ipairs(childs) do
        if v:isVisible() then
            width =width +  v:getContentSize().width
        end
    end
    local lSize = self:getContentSize()
    self:setInnerContainerSize(cc.size(width <=self:getContentSize().width and self:getContentSize().width or width,lSize.height))
    return width
end
function ccui.ScrollView:listenerScrollVisibleNode(firstNode,secondNode)
   local dir = self:getDirection()
   local size = self:getContentSize() 
   local container = self:getInnerContainer()
   local function listener(sender,eventType)
       if dir == ccui.ScrollViewDir.vertical then
            local innerSize = container:getContentSize()
            firstNode:setVisible(container:getPositionY() > -innerSize.height + size.height)
            secondNode:setVisible(container:getPositionY() < 0)
       else
            local innerSize = container:getContentSize()
            secondNode:setVisible(container:getPositionX() > -innerSize.width + size.width)
            firstNode:setVisible(container:getPositionX() < 0)
       end 
   end

   --播放动画
   firstNode:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.Spawn:create(
                cc.MoveBy:create(1,cc.p(-15,0)),
                cc.FadeTo:create(1,80)
            ),
            cc.Spawn:create(
                cc.MoveBy:create(1,cc.p(15,0)),
                cc.FadeTo:create(1,200)
            )
        )
   ))

    --播放动画
   secondNode:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.Spawn:create(
                cc.MoveBy:create(1,cc.p(15,0)),
                cc.FadeTo:create(1,80)
            ),
            cc.Spawn:create(
                cc.MoveBy:create(1,cc.p(-15,0)),
                cc.FadeTo:create(1,200)
            )
        )
   ))

   self:addEventListenerScrollViewExt(listener)
end
------------------------------------------------
-------Layout扩张------------------
--添加间隙
function ccui.Layout:addLinearInterval(interval)
    interval = interval or 5
    if self:getLayoutType() == ccui.LayoutType.VERTICAL then
        if interval > 0 then
            local intL = ccui.Layout:create():addTo(self)
            intL:setContentSize(cc.size(0,interval))
        end
        return   interval         
    elseif self:getLayoutType() == ccui.LayoutType.HORIZONTAL then
        if interval > 0 then
            local intL = ccui.Layout:create():addTo(self)
            intL:setContentSize(cc.size(interval,0))
        end
        return  interval  
    end
end

--自适应子孩子内容大小
function ccui.Layout:adaptiveChildsHeight()
    local childs = self:getChildren()
    local height = 0
    for _,v in ipairs(childs) do
        height =height +  v:getContentSize().height
    end
    local lSize = self:getContentSize()
    self:setContentSize(cc.size(lSize.width,height))
    return height
end
function ccui.Layout:adaptiveChildsWidth()
    local childs = self:getChildren()
    local width = 0
    for _,v in ipairs(childs) do
        width =width +  v:getContentSize().width
    end
    local lSize = self:getContentSize()
    self:setContentSize(cc.size(width,lSize.height))
    return width
end

function ccui.Layout:adaptiveChildsSize()
    self:adaptiveChildsHeight()
    self:adaptiveChildsWidth()
end
---------------------------------------------------------
----------Widget------------------------
--水平居中----
function ccui.Widget:horCenter()
    -- --水平居中
    local lay = LinearLayoutParameter:create()
    lay:setGravity(ccui.LinearGravity.centerHorizontal)
    self:setLayoutParameter(lay)
    return self
end

--水平靠左
function ccui.Widget:left()
    local lay = LinearLayoutParameter:create()
    lay:setGravity(ccui.LinearGravity.left)
    self:setLayoutParameter(lay)
    return self
end

--水平靠右
function ccui.Widget:right()
    local lay = LinearLayoutParameter:create()
    lay:setGravity(ccui.LinearGravity.right)
    self:setLayoutParameter(lay)
    return self
end

--垂直居中----
function ccui.Widget:verCenter()
    -- --水平居中
    local lay = LinearLayoutParameter:create()
    lay:setGravity(ccui.LinearGravity.centerVertical)
    self:setLayoutParameter(lay)
    return self
end

--垂直靠上
function ccui.Widget:top()
    local lay = LinearLayoutParameter:create()
    lay:setGravity(ccui.LinearGravity.top)
    self:setLayoutParameter(lay)
    return self
end

--垂直靠下
function ccui.Widget:bottom()
    local lay = LinearLayoutParameter:create()
    lay:setGravity(ccui.LinearGravity.bottom)
    self:setLayoutParameter(lay)
    return self
end


--------------------------------------------------

--------------Text----------
--{方法名,参数}
ccui.Text.effect = 
{
    --描边
    OUTLINE = {"enableOutline",{cc.c4b(0,0,0,255),1}},
    --阴影
    SHADOW  ={"enableShadow",{cc.c4b(27,8,4,255),cc.size(2,-2),0}},
    --荧光
    GLOW = {"enableGlow",{cc.c4b(0,255,0,255)}},
    --渐变
    --GRADIENT_COLOR = {"enableGradientColor",{cc.c4b(255,240,144,255),cc.c4b(201,111,0,255)}},
    GRADIENT_COLOR = {"enableGradientColor",{cc.c4b(255,248,208,255),cc.c4b(201,111,0,255)}},
}

-- 扩展接口
function ccui.Text:setText(value)
    self:setString(value)
end

ccui.Text.OUTLINE            = "OUTLINE"
ccui.Text.SHADOW             = "SHADOW"
ccui.Text.GLOW               = "GLOW"
ccui.Text.GRADIENT_COLOR     = "GRADIENT_COLOR"
function ccui.Text:enableOneEffect(effectName, params)
    local effect = Text.effect[effectName]
    if effect then
        self[effect[1]](self, unpack(params or effect[2]))
    end
end

--[[

@effectTable  {{"OUTLINE",{cc.c4b(0,0,0,255),1}}, {"SHADOW",{cc.c4b(27,8,4,255),cc.size(2,-2),0}}}

]]
function ccui.Text:enableMulEffects(effectTable)
    for _,v in ipairs(effectTable) do
        self:enableOneEffect(v[1], v[2])
    end    
end

-- Label扩展接口
function cc.Label:enableOneEffect(effectName, params)
    local effect = Text.effect[effectName]
    if effect then
        self[effect[1]](self, unpack(params or effect[2]))
    end
end

function cc.Label:enableMulEffects(effectTable)
    for _,v in ipairs(effectTable) do
        self:enableOneEffect(v[1], v[2])
    end
end


--Text一字一字出现
function ccui.Text:showOneByOneText(text,speed,callback)
    text = text or ""
    local count = string.wordLen(text)
    local intVer = speed / 0.01
    GlobalTick:regist(count*intVer,function(index)
        if index%intVer == 0 then
            index = math.floor(index/intVer)
            local desc = string.subWord(text,1,index)
            self:setString(desc)
        end
    end,self,function()
        if callback  then
            callback()
        end
    end)
end

function cc.Node:offset(x, y)
    local pos = cc.p(self:getPosition())
    pos.x = pos.x + x
    pos.y = pos.y + y
    self:setPosition(pos)
end 
--------------------------------



----------RichText----------------
--富文本文字解析(只限于文本)
--function parseContentEasyString(elements,textFontSize)
--    local eles_t = {}
--    --解析颜色，字体，透明度
--    for _,ele in ipairs(string.split(elements,"&")) do
--        local params,content = unpack(string.split(ele,"#"))
--        local ele_t = {}
--        ele_t.type = "text"
--        if params and content then
--            local color,fontSize,opacity = unpack(string.split(params,"$"))
--            ele_t.content = content or ""
--            ele_t.color = {r = tonumber(string.sub(color,1,3)),g = tonumber(string.sub(color,4,6)),b = tonumber(string.sub(color,7,9))}
--            ele_t.fontSize = fontSize or textFontSize
--            ele_t.opacity = opacity or 255
--        elseif params then
--            ele_t.content = params
--        end
--        table.insert(eles_t,ele_t)
--    end
--    elements = {}
--    --解析是否存在换行
--    for _,v in ipairs(eles_t) do
--        local t = {}      -- 存放回车符的位置
--        local i = 0
--        while true do
--            local iEnd = 0
--            i,iEnd = string.find(v.content, "\n", i+1)  -- 查找下一行
--            if i == nil then break end
--            table.insert(t, {i,iEnd})
--        end
--        local function addTextContent(beginPos,endPos)
--            if beginPos > string.len(v.content) or endPos < beginPos then
--                return
--            end
--            local newEle = {}
--            newEle.color = v.color
--            newEle.type = v.type
--            newEle.fontSize = v.fontSize
--            newEle.content = string.sub(v.content,beginPos,endPos)
--            table.insert(elements,newEle)
--        end
--        if #t > 0 then
--            for i,pos in ipairs(t) do
--                addTextContent((table.getsub(t,i-1,2) or 0) + 1 ,pos[1] - 1)

--                local w = ccui.Widget:create()
--                w:ignoreContentAdaptWithSize(false)
--                w:setContentSize(cc.size(0,10))
--                table.insert(elements,{type = "widget",content = w})
--                table.insert(elements,{type = "newline"})
--            end
--            addTextContent((table.getsub(t,#t,2) or 0) + 1 ,string.len(v.content))
--        else
--            table.insert(elements,v)
--        end     
--    end
--    return elements
--end

--[Comment]
--从配置表t_color中索引相应的颜色值
function WidgetExt.indexColorFromConfigTable(colorNdx,force4B)
    local colorItem = ClientConfig.common.t_color_ndx[colorNdx] 
    if not colorItem then 
        print("[WARNING] specified color index not found in config table t_color_ndx: "..tostring(colorNdx))
        return 
    end 
    if colorItem[4] then 
        return cc.c4b(colorItem.rgb[1],colorItem.rgb[2],colorItem.rgb[3],colorItem.rgb[4])
    else 
        if force4B then 
            return cc.c4b(colorItem.rgb[1],colorItem.rgb[2],colorItem.rgb[3],255)
        else
            return cc.c3b(colorItem.rgb[1],colorItem.rgb[2],colorItem.rgb[3])
        end 
    end 
end 
--[Comment]
--新的解析富文本（文字）的参数指定解析方式
--新的参数指定方式为&params#text
--其中params指定方式为：
--    key1 = (value1), key2 = (value2), ...
function WidgetExt.parseRichElementTextParamsNew(element,paramsStr)
    local function getColor(parameter,force4B)
        local colorStr = string.match(parameter,"%d+")
        local color = nil 
        if not colorStr or colorStr == "" then 
            return 
        elseif #colorStr < 9 then 
            local colorNdx = stringToNumber(colorStr)
            color = indexColorFromConfigTable(colorNdx,force4B)
        else 
            color = stringToColor(parameter,force4B)
        end 
        return color 
    end 

    local function parseColor(parameter)
        local color = getColor(parameter)
        color = color or cc.c3b(255,255,255)
        element.color = color 
    end 
    local function parseGradient(parameter)
        local enableGradient = true 
        local colorStrs = string.split(parameter,",")
        local gradientColor1 = getColor(colorStrs[1],true)
        local gradientColor2 = getColor(colorStrs[2],true)
        gradientColor1 = gradientColor1 or cc.c4b(255,255,255,255)
        gradientColor2 = gradientColor2 or cc.c4b(0,0,0,255)
        element.enableGradient = enableGradient 
        element.gradientColor1 = gradientColor1
        element.gradientColor2 = gradientColor2 
    end 
    local function parseOutline(parameter)
        local enableOutline = true 
        local params = string.split(parameter,",")
        local outlineColor = getColor(params[1],true)
        local outlineSize = stringToNumber(params[2])
        outlineColor = outlineColor or cc.c4b(0,0,0,255)
        outlineSize = outlineSize or 1
        element.enableOutline = enableOutline 
        element.outlineColor = outlineColor
        element.outlineSize = outlineSize 
    end 
    local function parseGlow(parameter)
        local glowColor = getColor(parameter,true)
        if not glowColor then 
            glowColor = cc.c4b(0,0,0,255)
        end 
        element.enableGlow = true 
        element.glowColor = glowColor
    end 
    local function parseFontSize(parameter)
        local fontSize = stringToNumber(parameter)
        if not fontSize then 
            fontSize = 20 
        end 
        element.fontSize = fontSize 
    end 
    local function parseOpacity(parameter)
        local opacity = stringToNumber(parameter)
        if not opacity then 
            opacity = 255
        end 
        element.opacity = opacity 
    end 
    local function parseShadow(parameter)
        local enableShadow = true 
        local params = string.split(parameter,",")
        local shadowColor = getColor(params[1],true)
        local offsetX = stringToNumber(params[2])
        local offsetY = stringToNumber(params[3])
        local blurRadius = stringToNumber(params[4])
        shadowColor = shadowColor or cc.c4b(0,0,0,255)
        offsetX = offsetX or 2 
        offsetY = offsetY or -2 
        blurRadius = blurRadius or -1 
        element.enableShadow = enableShadow 
        element.shadowColor = shadowColor
        element.shadowOffset = CCSize(offsetX,offsetY)
        element.blurRadius = blurRadius
    end 
    local function parseInherit(parameter)
        local enableInherit = stringToNumber(parameter)
        enableInherit = enableInherit or 1 --默认继承
        element.inherit = enableInherit ~= 0  
    end 
    local parseFuncs = {
                ["color"] = parseColor,
                ["fontsize"] = parseFontSize,
                ["opacity"] = parseOpacity,
                ["gradient"] = parseGradient,
                ["outline"] = parseOutline,
                ["glow"] = parseGlow,
                ["shadow"] = parseShadow,
                ["inherit"] = parseInherit,
                }
	params = string.gsub(paramsStr," ","") --清楚空格
    for parm in string.gmatch(params,"%w*=%([%d*,%-%+]*%)") do --暂时还不能滤除数字开头的单词
		local parts = string.split(parm,"=")
        local key = string.lower(parts[1])
        local value = string.lower(parts[2])
        local func = parseFuncs[key]
        if not func then 
            error("Not supported rich text parameter type: "..tostring(parm))
        end 
        func(value)
    end 

end 
function WidgetExt.parseContentEasyString(elements,textFontSize)
    local eles_t = {}
    local prevTxtElmt = nil 
    --解析颜色，字体，透明度
    for _,ele in ipairs(string.split(elements,"&")) do
        local params,content = unpack(string.split(ele,"#"))
        local ele_t = {}
        ele_t.type = "text"
        if params and content then
            ele_t.content = content or ""
            --由于新增了字体特效，参数指定发生了变化，为了兼容以前的文字，检测富文本的参数指定方式，从而采用不同的参数解析方法
            if string.find(params,"=") then 
                parseRichElementTextParamsNew(ele_t,params)
                if ele_t.inherit == nil then 
                    ele_t.inherit = true 
                end 
                if prevTxtElmt and ele_t.inherit then 
                    --特性继承
                    for key,value in pairs(prevTxtElmt) do 
                        if key ~= "content" and (not ele_t[key]) then 
                            ele_t[key] = value 
                        end 
                    end 
                end 
                prevTxtElmt = ele_t 
            else 
                local color,fontSize,opacity = unpack(string.split(params,"$"))
                if not color or #color < 9 then 
                    ele_t.color = indexColorFromConfigTable(stringToNumber(color)) or cc.c3b(255,255,255)
                else 
                    ele_t.color = {r = tonumber(string.sub(color,1,3)),g = tonumber(string.sub(color,4,6)),b = tonumber(string.sub(color,7,9))}
                end 
                ele_t.fontSize = fontSize or textFontSize
                ele_t.opacity = opacity or 255
            end 
        elseif params then
            ele_t.content = params
        end
        table.insert(eles_t,ele_t)
    end
    elements = {}
    --解析是否存在换行
    for _,v in ipairs(eles_t) do
        local t = {}      -- 存放回车符的位置
        local i = 0
        while true do
            local iEnd = 0
            i,iEnd = string.find(v.content, "\n", i+1)  -- 查找下一行
            if i == nil then break end
            table.insert(t, {i,iEnd})
        end
        local function addTextContent(beginPos,endPos)
            if beginPos > string.len(v.content) or endPos < beginPos then
                return
            end
            local newEle = {}
            newEle.color = v.color
            newEle.type = v.type
            newEle.fontSize = v.fontSize
            newEle.content = string.sub(v.content,beginPos,endPos)
            newEle.enableGradient = v.enableGradient;
            newEle.gradientColor1 = v.gradientColor1;
            newEle.gradientColor2 = v.gradientColor2;
            newEle.enableOutline = v.enableOutline;
            newEle.outlineColor = v.outlineColor;
            newEle.outlineSize = v.outlineSize;
            newEle.enableGlow = v.enableGlow;
            newEle.glowColor = v.glowColor;
            newEle.enableShadow = v.enableShadow;
            newEle.shadowColor = v.shadowColor;
            newEle.shadowOffset = v.shadowOffset;
            newEle.blurRadius = v.blurRadius;

            table.insert(elements,newEle)
        end
        if #t > 0 then
            for i,pos in ipairs(t) do
                addTextContent((table.getsub(t,i-1,2) or 0) + 1 ,pos[1] - 1)

                local w = ccui.Widget:create()
                w:ignoreContentAdaptWithSize(false)
                w:setContentSize(cc.size(0,10))
                table.insert(elements,{type = "widget",content = w})
                table.insert(elements,{type = "newline"})
            end
            addTextContent((table.getsub(t,#t,2) or 0) + 1 ,string.len(v.content))
        else
            table.insert(elements,v)
        end     
    end
    return elements
end

--富文本解析
function ccui.RichText:parseContent(elements,textFontSize,textFontColor)
    textFontSize = textFontSize or 20
    if type(elements) == "string" then
        elements = parseContentEasyString(elements,textFontSize)
    end
    assert(type(elements) == "table")
    for _,element in ipairs(elements) do
        assert(element.type)
        local type = element.type or "text"
        --内容
        local elementContent = element.content
        local color = element.color or (textFontColor and textFontColor or  {r = 255,g = 255,b = 255})
        assert(color.r)
        assert(color.g)
        assert(color.b)
        local opacity = element.opacity or 255
        if element.type == "text" then
            element.enableGradient = element.enableGradient or false ;
            element.gradientColor1 = element.gradientColor1 or cc.c4b(0,0,0,0);
            element.gradientColor2 = element.gradientColor2 or cc.c4b(0,0,0,0);
            element.enableOutline = element.enableOutline or false ;
            element.outlineColor = element.outlineColor or cc.c4b(0,0,0,0);
            element.outlineSize = element.outlineSize or 0;
            element.enableGlow = element.enableGlow or false ;
            element.glowColor = element.glowColor or cc.c4b(0,0,0,0);
            element.enableShadow = element.enableShadow or false ;
            element.shadowColor = element.shadowColor or cc.c4b(0,0,0,0);
            element.shadowOffset = element.shadowOffset or CCSize(0,0);
            element.blurRadius = element.blurRadius or 0;
            local textElement = ccui.RichElementText:create(_,
                                                            color,
                                                            opacity,
                                                            elementContent,
                                                            ClientConfig.FontName,
                                                            element.fontSize or textFontSize,
                                                            element.enableGradient,
                                                            element.gradientColor1,
                                                            element.gradientColor2,
                                                            element.enableOutline,
                                                            element.outlineColor,
                                                            element.outlineSize,
                                                            element.enableGlow,
                                                            element.glowColor,
                                                            element.enableShadow,
                                                            element.shadowColor,
                                                            element.shadowOffset,
                                                            element.blurRadius)
            self:pushBackElement(textElement)
        elseif element.type == "image" then
            local imageElement = ccui.RichElementImage:create(_,color,opacity,elementContent)
            self:pushBackElement(imageElement)
        elseif element.type == "newline" then
            local element = ccui.RichElement:createNewLine(_)
            self:pushBackElement(element)
        elseif element.type == "widget" then
            local widgetElement = nil
            if not tolua.isnull(elementContent) then
                widgetElement = ccui.RichElementCustomNode:create(_,color,opacity,elementContent)
            else
                --解析json生成
                widgetElement = cc.uiloader:load(elementContent):getChildren()[1]
                widgetElement:removeFromParentAndCleanup(false)
            end
            self:pushBackElement(widgetElement)
        elseif element.type == "face" then
            local imgFace = ChatCache:getFaceByTag(element.content)
            if element.size then
                local scale = element.size/imgFace:getContentSize().width
                imgFace:setScale(scale)
                imgFace:setContentSize(cc.size(imgFace:getContentSize().width*scale,imgFace:getContentSize().height*scale))
            end
            local widgetElement = ccui.RichElementCustomNode:create(_,color,opacity,imgFace)
            self:pushBackElement(widgetElement)
        end
    end
    return self
end


--解析策划配置富文本控件table
function WidgetExt.parseRictEasyTable(rt_t)
    assert(type(rt_t) == "table")
    local end_rt = {}
    for _,tile in ipairs(rt_t) do
        local put_tile = {}
        --文本
        if tile[1] == 1 then
            put_tile.type = "text"
            put_tile.fontSize = tile[4]
        --换行
        elseif tile[1] == 2 then
            put_tile.type = "newline"
        --图片
        elseif tile[1] == 3 then
            put_tile.type = "image"
        --表情
        elseif tile[1] == 4 then
            put_tile.type = "face"
            put_tile.size = tile[4]
        end
        --内容
        put_tile.content = tile[2]
        --颜色
        put_tile.color = tile[3]

        if put_tile.color then
            put_tile.color = {r = tile[3][1],g = tile[3][2],b = tile[3][3]}
        end
        --透明度
        put_tile.opacity = tile[5]

        table.insert(end_rt,put_tile)
    end
    return end_rt
end

--一个一个字打印解析富文本
function WidgetExt.parseRichTextPrintEffect(talk_t,fontSize)
    if type(talk_t) == "string" then
        local eles = parseContentEasyString(talk_t,fontSize)
        talk_t = {}
        for _,v in ipairs(eles) do
            local ele = {}
            if v.type == "text" then
                ele[1] = 1
                ele[4] = v.fontSize
            else
                ele[1] = 2
            end
            ele[2] = v.content
            ele[3] = v.color and {v.color.r,v.color.g,v.color.b} or nil
            ele[5] = v.opacity
            table.insert(talk_t,ele)
        end
    end
    --一个一个字显示
    local end_talk_t = {}
    for i,tile in ipairs(talk_t) do
        tile.index = i
        if tile[1] == 1 then
            local count = string.wordLen(tile[2])
            for t_i = 1,count,1 do
                local end_tile = clone(tile)
                end_tile[2] = string.subWord(tile[2],t_i,t_i)
                table.insert(end_talk_t,end_tile)
            end
        else
            table.insert(end_talk_t,tile)
        end
    end
    local end_talk_t_1 = {}
    for i=1,#end_talk_t,1 do
        local end_talk_t_tile  = {}
        local pre_tile = nil
        for ii=1,i,1 do
            if pre_tile and pre_tile.index == end_talk_t[ii].index and pre_tile[1] == 1 then
                pre_tile[2] = pre_tile[2]..end_talk_t[ii][2]
            else
                pre_tile = clone(end_talk_t[ii])
                table.insert(end_talk_t_tile,pre_tile)
            end
        end
        end_talk_t_1[i] = end_talk_t_tile
    end
    --print(table.tostring(end_talk_t_1))
    return end_talk_t_1
end

-------------------------------------

--------------ImageView扩展-------------------
--设置正常
function ccui.ImageView:setNormal()
    if not self.isGray then 
        return 
    end 
    ShaderEffect:reset(self:getVirtualRenderer():getSprite())
    self.isGray = false
    for _, child in pairs(self:getChildren()) do 
        if child.setNormal then 
            child:setNormal()
        end 
    end 
end

--设置灰度
function ccui.ImageView:setGray()
    if self.isGray then 
        return 
    end 
    ShaderEffect:setGray(self:getVirtualRenderer():getSprite())
    self.isGray = true
    for _, child in pairs(self:getChildren()) do 
        if child.setGray then 
            child:setGray()
        end 
    end 
end

--变色
function ccui.ImageView:setColorEffect(color)
    self:getVirtualRenderer():showShaderEffect("RGB", {u_redAdj = color[1], u_greenAdj = color[2], u_blueAdj = color[3]})
end
----------------------------------------------

--[Comment]
--用指定的文本框作为模板（包括字体，颜色，大小参数）创建一个富文本，富文本中的文字为文本框中的文字
--如果需要指定自己的文字，则需要指定text参数，否则指定text为nil
--如果需要换行，则需要明确指定regionSize的大小，当现实的文字会超出regionSize边界时，换行符有效
--新富文本的名字Name将被指定为label:getName().."1"
--container: 富文本组件即将加入到的容器以及包含建立的变量的容器
--label: Label组件，里边指定了文本Size，Font信息，AnchorPoint, Position等信息
--text: 指定富文本的文字（可以包含文本参数），当text为空时，自动启用label中的文字
--hideModel: 指定是否将富文本创建了之后把label隐藏
--deletePrevious: 指定是否删除之前用此label创建的富文本，如果此项指定为true，则之前创建此富文本是必须指定selfVarSetup为true
function WidgetExt.addRichTextUseLabel(container, label,text,hideModel,selfVarSetup,autoAdd,regionSize,deletePrevious)
    assert(label ~= nil, "label cannot be nil")
    hideModel = hideModel == nil and true or hideModel 
    selfVarSetup = selfVarSetup == nil and true or selfVarSetup 
    autoAdd = autoAdd == nil and true or autoAdd 
    deletePrevious = deletePrevious == nil and true or deletePrevious 
    text = text or label:getString()

    local lbl = nil 
    if not string.find(text,"&.+#") then --如果没有指定参数，则使用label自身的信息
        local color = colorToString(label:getColor())
        text = "&"..color.."#"..text 
        local fontSize = label:getFontSize()
        lbl = RichText:create():parseContent(text,fontSize)
    else 
        text = text .. "&color=("..colorToString(label:getColor()).."),fontSize=("..tostring(label:getFontSize())..")#"
        lbl = RichText:create():parseContent(text)
    end 
    lbl:setTouchEnabled(false)
    if regionSize then 
        lbl:setContentSize(regionSize)
        lbl:ignoreContentAdaptWithSize(false)
    elseif not label:isIgnoreContentAdaptWithSize() then 
        lbl:setContentSize(label:getContentSize())
        lbl:ignoreContentAdaptWithSize(false)
    end 
    local name = label:getName().."1"
    if deletePrevious and container[name] and not tolua.isnull(container[name]) then 
        print("[INFO]: previous richText is deleted")
        container[name]:removeFromParentAndCleanup(true)
        container[name] = nil 
    end 
    lbl:setName(name)
    lbl:setAnchorPoint(label:getAnchorPoint())
    lbl:setPositionX(label:getPositionX())
    lbl:setPositionY(label:getPositionY())
    if autoAdd then 
        lbl:addTo(label:getParent())
    end 
    if hideModel then 
        label:setVisible(false)
    end 
    if selfVarSetup then 
        container[name] = lbl 
    end 
    
    return lbl 
end 

--[Comment]
--添加节点退出点击测试（如果点击不在测试组件上，那么节点将退出）
--node: 需要退出的节点
--widget: 包含测试组件的组件引用
--testWidgetOrRegion: 点击测试的组件（组件名称或组件的引用）或者测试区域(x,y,width,height)
--itsDlg: 指定是否是弹出框（默认true）
function WidgetExt.addWidgetExitTestAndAction(node,widget,testWidgetOrRegion,itsDlg)
    assert(node,"node cannot be nil")
    assert(widget,"widget cannot be nil")
    assert(testWidgetOrRegion, "testWidgetOrRegion cannot be nil")
    itsDlg = itsDlg == nil and true or itsDlg 
    local imgBox 
    local testRegion = nil 
    if type(testWidgetOrRegion) == "string" then 
        imgBox = UIHelper:seekWidgetByName(widget,testWidgetOrRegion)
    elseif type(testWidgetOrRegion) == "table" then 
        testRegion = testWidgetOrRegion
    else  
        imgBox = testWidgetOrRegion 
    end 
    widget:addTouchEventListener(function(sender,eventType)
        if eventType ~= ccui.TouchEventType.ended then 
            return 
        end 
        local startPos = widget:getTouchBeganPosition() 
        local endPos = widget:getTouchEndPosition() 

        local touchInBox = false 
        if not testRegion then 
            local imgBoxSize = imgBox:getContentSize()
            local imgBoxAnpt = imgBox:getAnchorPoint()
            local left = imgBox:getPositionX() - imgBoxSize.width * imgBoxAnpt.x 
            local bottom = imgBox:getPositionY() - imgBoxSize.height * imgBoxAnpt.y 

            touchInBox = endPos.x >= left and endPos.x <= left + imgBoxSize.width and 
                         endPos.y >= bottom and endPos.y <= bottom + imgBoxSize.height
        else 
            touchInBox = endPos.x >= testRegion.x and endPos.x <= testRegion.x + testRegion.width and 
                         endPos.y >= testRegion.y and endPos.y <= testRegion.y + testRegion.height
        end 
        local offsetX = math.abs(startPos.x - endPos.x) 
        local offsetY = math.abs(startPos.y - endPos.y)
        local offset = 10 
        if offsetX <= offset and offsetY <= offset and not touchInBox then 
            if itsDlg then 
                local function callback()
                    print("exited")
                    node:removeFromParentAndCleanup(true)
                end
                transition.popExit(widget,callback)
            else 
                node:removeFromParentAndCleanup(true)
            end 
        end 
    end)
end 

--[Comment]
--为组件添加单击事件，事件处理方法将在弹起时被调用
--widget: 需要添加事件的组件
--clickFunc: 单击事件处理方法
--funcOwner: 单击事件处理方法的拥有者（可选）
function WidgetExt.addClickEvent(widget,clickFunc,funcOwner)
    widget:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.began then 
            sender:setScale(0.9)
        elseif eventType == ccui.TouchEventType.canceled or 
                eventType == ccui.TouchEventType.ended then 
            sender:setScale(1.0)
        end 
        if eventType == ccui.TouchEventType.ended then 
            if funcOwner then 
                clickFunc(funcOwner,sender,eventType)
            else 
                clickFunc(sender,eventType)
            end 
        end 
    end)
end 

--[Comment]
--显示红点提示
function WidgetExt.showTaskTipPoint(widget,show,params)
    if show then 
        unfinishedTaskTipAdd(widget,params)
    else 
        unfinishedTaskTipCancel(widget,params)
    end 
end 

--[Comment]
--添加新任务提醒标记
--addToWidget: 提醒标记添加到的组件
function WidgetExt.unfinishedTaskTipAdd(addToWidget,params)
    assert(addToWidget)
    params = params or {}
    local name = "unfinishedTaskTip"
    local tip = addToWidget.tipPoint
    if not tip then 
        tip = ccui.ImageView:create("Images/UI/common/UI_common_tb_hongdian.png")
        tip:setLocalZOrder(1000)
        local widgetSize = addToWidget:getContentSize()
        local pos = params.pos or cc.p(widgetSize.width * 0.89,widgetSize.height * 0.87)
        if params.offset then 
            pos.x = pos.x + params.offset.x 
            pos.y = pos.y + params.offset.y 
        end 
        tip:setPosition(pos)
        tip:setName(name)
        tip:setVisible(true)
        addToWidget:addChild(tip)
        addToWidget.tipPoint = tip 
    end 
end 

--[Comment]
--撤销新任务提醒标记
--addToWidget: 包含提醒标记的组件
function WidgetExt.unfinishedTaskTipCancel(addToWidget)
    assert(addToWidget)
    if addToWidget.tipPoint then 
        addToWidget.tipPoint:removeFromParentAndCleanup(true)
        addToWidget.tipPoint = nil 
    end 
end 

--[Comment]
--对滚动层的子节点进行布局（仅支持每个子节点尺寸一致的情况）
--columns: 指定列的数目（默认为1）
--marginLeft: 指定左边距（默认为0）
--marginRight: 指定右边距（默认为0）
--lineIntvl: 指定行间隔（默认等于列间隔）
--columnIntvl: 指定列间隔（如果不指定，程序自动等列宽分配）
--offsetX: 子节点布局时候给定的一个额外X的偏移值（默认为0）
--offsetY: 子节点布局时候给定的一个额外Y的偏移值（默认为0）
function ccui.ScrollView:layoutVertical(columns,marginLeft,marginRight,lineIntvl,columnIntvl,offsetX,offsetY)
    columns = columns or 1 
    marginLeft = marginLeft or 0 
    marginRight = marginRight or 0 
    offsetX = offsetX or 0 
    offsetY = offsetY or 0 

    local children = self:getChildren() 
    local cnt = #children 
    if cnt == 0 then 
        return 
    end 
    local lines = math.ceil(cnt / columns)
    local itemSize = children[1]:getContentSize() 
    local innerContainerSize = self:getContentSize() 
    --如果没有指定行间隔和列间隔，程序自动计算
    if not columnIntvl and columns > 1 then 
        columnIntvl = (innerContainerSize.width - marginLeft - marginRight - columns * itemSize.width) / (columns - 1)
    else 
        columnIntvl = 0 
    end 
    if not lineIntvl then 
        lineIntvl = columnIntvl 
    end 
    --更新内置滚动区域尺寸
    local height = (lines - 1) * (lineIntvl + itemSize.height) + itemSize.height
    innerContainerSize.height = innerContainerSize.height > height and innerContainerSize.height or height 
    self:setInnerContainerSize(innerContainerSize)
    --开始布局
    marginLeft = (innerContainerSize.width - (itemSize.width + columnIntvl) * (columns - 1) - itemSize.width) / 2 + marginLeft --居中
    local top = innerContainerSize.height 
    local pos = cc.p(marginLeft,top)
    local i = 1 
    while i <= cnt do 
        local child = children[i] 
        local anpt = child:getAnchorPoint()
        local col = (i - 1) % columns + 1
        local line = math.ceil(i / columns) 
        pos.x = marginLeft + (col - 1) * (itemSize.width + columnIntvl) + itemSize.width * anpt.x + offsetX 
        pos.y = top - (line - 1) * (itemSize.height + lineIntvl) - itemSize.height * (1 - anpt.y) + offsetY 
        child:setPosition(pos) 
        i = i + 1 
    end 
end 

--[Comment]
--对滚动层的子节点进行布局（仅支持每个子节点尺寸一致的情况）
--columns: 指定列的数目（默认为1）
--marginLeft: 指定左边距（默认为0）
--marginRight: 指定右边距（默认为0）
--lineIntvl: 指定行间隔（默认等于列间隔）
--columnIntvl: 指定列间隔（如果不指定，程序自动等列宽分配）
--offsetX: 子节点布局时候给定的一个额外X的偏移值（默认为0）
--offsetY: 子节点布局时候给定的一个额外Y的偏移值（默认为0）
--imgLineIntvl: 行间隔显示图片（如果为string, 那么表示的是图片路径）
--needSort: 如果指定此参数为true，则在创建滚动层的孩子节点的时候必须指定priority字段
--sortFunc: 排序比较方法，当needSort设置为true时，此字段生效，且当设置了此字段时，排序将使用
--          此方法进行比较排序
--cmprFunc: 排序比较方法，当needSort设置为true时，此字段生效，且当设置了此字段时，排序将使用
--          此方法进行比较排序
--order: 指定排序类型（升序：Order.ASCENDING, 降序：Order.DESCENDING)
--orderRange: 指定排序范围{min=?, ,max=?}
--startNdx: 指定布局子节点的起始索引（默认为1）
--endNdx: 指定布局子节点的结束索引（默认为子节点的数目）
--onlyVisible: 指定是否只对可见节点布局，默认为false
--minHeight: 最小高度
function ccui.ScrollView:layoutVertical1(params)
    local columns = params.columns or 1 
    local marginLeft = params.marginLeft or 0 
    local marginRight = params.marginRight or 0 
    local marginTop = params.marginTop or 0
    local marginBottom = params.marginBottom or 0
    local lineIntvl = params.lineIntvl or 10
    local columnIntvl = params.columnIntvl 
    local offsetX = params.offsetX or 0 
    local offsetY = params.offsetY or 0 
    local imgLineIntvl = params.imgLineIntvl
    local imgLineIntvl = type(imgLineIntvl) == "string" and ccui.ImageView:create(imgLineIntvl) or imgLineIntvl
    local imgColumnIntvl = params.imgColumnIntvl
    local imgColumnIntvl = type(imgColumnIntvl) == "string" and ccui.ImageView:create(imgColumnIntvl) or imgColumnIntvl
    local lineIntvlImgOffsetX = params.lineIntvlImgOffsetX or 0 
    local lineIntvlImgOffsetY = params.lineIntvlImgOffsetY or 0 
    local lineIntvlImgZOrder = params.lineIntvlImgZOrder or -1000 --默认置底
    local colIntvlImgOffsetX = params.colIntvlImgOffsetX or 0 
    local colIntvlImgOffsetY = params.colIntvlImgOffsetY or 0 
    local colIntvlImgZOrder = params.colIntvlImgZOrder or -1000 --默认置底
    local hasTopLineIntvl = params.hasTopLineIntvl 
    local hasBottomLineIntvl = params.hasBottomLineIntvl 
    local hasLeftIntvl = params.hasLeftIntvl 
    local hasRightIntvl = params.hasRightIntvl 
    local needSort = params.needSort or false 
    local cmprFunc = params.cmprFunc
    local sortFunc = params.sortFunc
    local order = params.order or WidgetExt.Order.ASCENDING
    local orderRange = params.orderRange
    local onlyVisible = params.onlyVisible or false
    local minHeight = params.minHeight 

    --params binding
    self.lineIntvl = lineIntvl 

    local children = self:getChildren() 
    local tmp = {}
    if onlyVisible then 
        for _,child in ipairs(children) do 
            if child:isVisible() then 
                table.insert(tmp,child)
            end 
        end 
        children = tmp 
    end 
    local startNdx = params.startNdx or 1 
    local endNdx = params.endNdx or #children 
    local childrenSort = {}
    local ndx = 1
    while ndx <= #children do 
        if ndx < startNdx or ndx > endNdx then 
            children[ndx]:setVisible(false)
        else 
            children[ndx]:setVisible(true)
            table.insert(childrenSort,children[ndx])
        end 
        ndx = ndx + 1
    end 
    children = childrenSort 

    if needSort then 
        if sortFunc then 
            children = sortFunc(children)
        elseif cmprFunc then 
            table.sort(children,cmprFunc)
        else 
            if orderRange then 
                local rangedChildren = {{},{},{}}
                local min = orderRange.min or 0 
                local max = orderRange.max or 10000
                for _,child in ipairs(children) do 
                    if child.priority < min then 
                        table.insert(rangedChildren[1],child)
                    elseif child.priority > max then 
                        table.insert(rangedChildren[3],child)
                    else 
                        table.insert(rangedChildren[2],child)
                    end 
                end 
                if order == WidgetExt.Order.ASCENDING then 
                    table.sort(rangedChildren[2],function(child1,child2)
                        return child1.priority < child2.priority 
                    end)
                elseif order == WidgetExt.Order.DESCENDING then 
                    table.sort(rangedChildren[2],function(child1,child2)
                        return child1.priority > child2.priority 
                    end)
                end 
                children = {}
                table.append(children,rangedChildren[1],rangedChildren[2],rangedChildren[3])
            else 
                if order == WidgetExt.Order.ASCENDING then 
                    table.sort(children,function(child1,child2)
                        return child1.priority < child2.priority 
                    end)
                elseif order == WidgetExt.Order.DESCENDING then 
                    table.sort(children,function(child1,child2)
                        return child1.priority > child2.priority 
                    end)
                end 
            end 
        end 
    end 
    local cnt = #children 
    if cnt == 0 then 
        return 
    end 
    if imgLineIntvl then 
        imgLineIntvl:setLocalZOrder(lineIntvlImgZOrder)
    end 
    if imgColumnIntvl then 
        imgColumnIntvl:setLocalZOrder(colIntvlImgZOrder)
    end 
    local lines = math.ceil(cnt / columns)
    local itemSize = children[1]:getContentSize() 
    local innerContainerSize = self:getContentSize() 
    --如果没有指定行间隔和列间隔，程序自动计算
    if not columnIntvl and columns > 1 then 
        local intvls = columns - 1 
        if hasLeftIntvl then 
            intvls = intvls + 1 
        end 
        if hasRightIntvl then 
            intvls = intvls + 1 
        end 
        columnIntvl = (innerContainerSize.width - marginLeft - marginRight - columns * itemSize.width) / intvls 
    else 
        columnIntvl = 0 
    end 
    if not lineIntvl then 
        lineIntvl = columnIntvl 
    end 
    --更新内置滚动区域尺寸
    local height = (lines - 1) * (lineIntvl + itemSize.height) + itemSize.height
    if hasTopLineIntvl then 
        height = height + lineIntvl
    end 
    if hasBottomLineIntvl then 
        height = height + lineIntvl
    end 
    height = height + marginTop + marginBottom

    minHeight = minHeight or innerContainerSize.height
    innerContainerSize.height = minHeight > height and minHeight or height 
    self:setInnerContainerSize(innerContainerSize)
    --开始布局
    marginLeft = (innerContainerSize.width - marginLeft - marginRight - (itemSize.width + columnIntvl) * (columns - 1) - itemSize.width) / 2 + marginLeft --居中
    if hasLeftIntvl then 
        marginLeft = marginLeft - columnIntvl
    end 
    local lineIntvlImgPosX = innerContainerSize.width / 2 + lineIntvlImgOffsetX
    local colIntvlImgPosY = innerContainerSize.height / 2 + colIntvlImgOffsetY
    local top = innerContainerSize.height 
    local pos = cc.p(marginLeft,top)
    local i = 1 
    local lastLineNO = 0  
    while i <= cnt do 
        local child = children[i] 
        local anpt = child:getAnchorPoint()
        local col = (i - 1) % columns + 1
        local line = math.ceil(i / columns) 
        pos.x = marginLeft + (col - 1) * (itemSize.width + columnIntvl) + itemSize.width * anpt.x + offsetX 
        pos.y = top - (line - 1) * (itemSize.height + lineIntvl) - itemSize.height * (1 - anpt.y) + offsetY 
        if hasLeftIntvl then 
            pos.x = pos.x + columnIntvl 
        end 
        if hasTopLineIntvl then 
            pos.y = pos.y - lineIntvl 
        end 
        pos.y = pos.y - marginTop
        child:setPosition(pos) 
        if col == 1 then 
            lastLineNO = lastLineNO + 1
        end 
        if imgLineIntvl and i < cnt and col == columns then --保证不是在最后一行添加行间隔图片
            local imgLine = imgLineIntvl:clone() 
            imgLine:setVisible(true)
            imgLine:setPosition(cc.p(lineIntvlImgPosX,pos.y - anpt.y * itemSize.height - lineIntvl / 2.0 + lineIntvlImgOffsetY))
            self:addChild(imgLine)
        end 
        i = i + 1 
    end 
    --添加首行间隔图和末行间隔图
    if hasTopLineIntvl and imgLineIntvl then 
        local imgLine = imgLineIntvl:clone() 
        imgLine:setVisible(true)
        imgLine:setPosition(cc.p(lineIntvlImgPosX,top - lineIntvl / 2.0 + lineIntvlImgOffsetY + offsetY - marginTop))
        self:addChild(imgLine)
    end 
    if hasBottomLineIntvl and imgLineIntvl then 
        local imgLine = imgLineIntvl:clone() 
        imgLine:setVisible(true)
        imgLine:setPosition(cc.p(lineIntvlImgPosX,top - (lastLineNO - 1) * (itemSize.height + lineIntvl) - itemSize.height + offsetY - lineIntvl / 2.0 + lineIntvlImgOffsetY + marginBottom))
        self:addChild(imgLine)
    end 
    --添加列间隔图
    if imgColumnIntvl then 
        local j = 1 
        while j < columns do 
            local x = marginLeft + (j - 1) * (itemSize.width + columnIntvl) + offsetX + itemSize.width 
            if hasLeftIntvl then 
                x = x + columnIntvl / 2.0 + colIntvlImgOffsetX 
            end 
            local imgCol = imgColumnIntvl:clone()
            imgCol:setVisible(true)
            imgCol:setPosition(cc.p(x,colIntvlImgPosY))
            self:addChild(imgCol)
        end 
        if hasLeftIntvl then 
            local imgCol = imgColumnIntvl:clone()
            imgCol:setVisible(true)
            imgCol:setPosition(cc.p(marginLeft + columnIntvl / 2 + offsetX + colIntvlImgOffsetX,colIntvlImgPosY))
            self:addChild(imgCol)
        end 
        if hasRightIntvl then 
            local imgCol = imgColumnIntvl:clone()
            imgCol:setVisible(true)
            local x = marginLeft + (columns - 1) * (itemSize.width + columnIntvl) + offsetX + itemSize.width 
            imgCol:setPosition(cc.p(x + columnIntvl / 2 + colIntvlImgOffsetX,colIntvlImgPosY))
            self:addChild(imgCol)
        end 
    end 
end 

--[Comment]
--对滚动层的子节点进行布局（支持每个子节点尺寸不一致的情况，但仅支持单列）
--columns: 指定列的数目（默认为1）
--marginLeft: 指定左边距（默认为0）
--marginRight: 指定右边距（默认为0）
--lineIntvl: 指定行间隔（默认等于列间隔）
--columnIntvl: 指定列间隔（如果不指定，程序自动等列宽分配）（暂时不支持）
--offsetX: 子节点布局时候给定的一个额外X的偏移值（默认为0）
--offsetY: 子节点布局时候给定的一个额外Y的偏移值（默认为0）
--imgLineIntvl: 行间隔显示图片（如果为string, 那么表示的是图片路径）（暂时不支持）
--needSort: 如果指定此参数为true，则在创建滚动层的孩子节点的时候必须指定priority字段
--order: 指定排序类型（升序：Order.ASCENDING, 降序：Order.DESCENDING)
--orderRange: 指定排序范围{min=?, ,max=?}
--startNdx: 指定布局子节点的起始索引（默认为1）
--endNdx: 指定布局子节点的结束索引（默认为子节点的数目）
--onlyVisible: 指定是否只对可见节点布局，默认为false
--minHeight: 最小高度（暂时不支持）
function ccui.ScrollView:layoutVertical2(params)
    local columns = params.columns or 1 
    local marginLeft = params.marginLeft or 0 
    local marginRight = params.marginRight or 0 
    local marginTop = params.marginTop or 0
    local marginBottom = params.marginBottom or 0
    local lineIntvl = params.lineIntvl or 10
    local offsetX = params.offsetX or 0 
    local offsetY = params.offsetY or 0 
    local needSort = params.needSort or false 
    local order = params.order or WidgetExt.Order.ASCENDING
    local orderRange = params.orderRange
    local onlyVisible = params.onlyVisible or false
    local minHeight = params.minHeight 

    --params binding
    self.lineIntvl = lineIntvl 

    local children = self:getChildren() 
    local tmp = {}
    if onlyVisible then 
        for _,child in ipairs(children) do 
            if child:isVisible() then 
                table.insert(tmp,child)
            end 
        end 
        children = tmp 
    end 
    local startNdx = params.startNdx or 1 
    local endNdx = params.endNdx or #children 
    local childrenSort = {}
    local ndx = 1
    while ndx <= #children do 
        if ndx < startNdx or ndx > endNdx then 
            children[ndx]:setVisible(false)
        else 
            children[ndx]:setVisible(true)
            table.insert(childrenSort,children[ndx])
        end 
        ndx = ndx + 1
    end 
    children = childrenSort 

    if needSort then 
        if orderRange then 
            local rangedChildren = {{},{},{}}
            local min = orderRange.min or 0 
            local max = orderRange.max or 10000
            for _,child in ipairs(children) do 
                if child.priority < min then 
                    table.insert(rangedChildren[1],child)
                elseif child.priority > max then 
                    table.insert(rangedChildren[3],child)
                else 
                    table.insert(rangedChildren[2],child)
                end 
            end 
            if order == WidgetExt.Order.ASCENDING then 
                table.sort(rangedChildren[2],function(child1,child2)
                    return child1.priority < child2.priority 
                end)
            elseif order == WidgetExt.Order.DESCENDING then 
                table.sort(rangedChildren[2],function(child1,child2)
                    return child1.priority > child2.priority 
                end)
            end 
            children = {}
            table.append(children,rangedChildren[1],rangedChildren[2],rangedChildren[3])
        else 
            if order == WidgetExt.Order.ASCENDING then 
                table.sort(children,function(child1,child2)
                    return child1.priority < child2.priority 
                end)
            elseif order == WidgetExt.Order.DESCENDING then 
                table.sort(children,function(child1,child2)
                    return child1.priority > child2.priority 
                end)
            end 
        end 
    end 
    local cnt = #children 
    if cnt == 0 then 
        return 
    end 
    local containerSize = self:getContentSize()
    local pos = cc.p(0,0)
    local height = 0 
    local ndx = #children
    local prevChild = nil 
    while ndx >= 1 do 
        local child = children[ndx]
        ndx = ndx - 1
        pos = cc.p(child:getPosition())
        local size = child:getContentSize()
        local anpt = child:getAnchorPoint()
        pos.x = (containerSize.width - size.width) / 2 + size.width * anpt.x
        if not prevChild then 
            pos.y = size.height * anpt.y 
        else
            local prevSize = prevChild:getContentSize()
            local prevPos = cc.p(prevChild:getPosition()) 
            local prevAnpt = prevChild:getAnchorPoint()
            pos.y = prevPos.y + (1 - prevAnpt.y) * prevSize.height + lineIntvl + size.height * anpt.y
        end 
        pos.x = pos.x + marginLeft + offsetX 
        pos.y = pos.y + marginBottom + offsetY
        child:setPosition(pos)
        pos = cc.p(child:getPosition())
        height =  pos.y + (1 - anpt.y) * size.height

        prevChild = child
    end 
    height = height + marginTop 
    local scrollSize = self:getContentSize()
    if scrollSize.height > height then 
        offset = scrollSize.height - height 
        for _,child in pairs(children) do 
            local pos = cc.p(child:getPosition())
            pos.y = pos.y + offset 
            child:setPosition(pos)
        end
        print("[INFO] revised")
    end 
    height = scrollSize.height > height and scrollSize.height or height 
    containerSize.height = height 
    self:setInnerContainerSize(containerSize)
end 
--[Comment]
--移除滚动框中的一个子孩子
--id: 需要删除的子节点ID（必须）
--step: 子节点删除后，滚动框中其他子节点做相应的位置调整移动步进像素，默认为10
--disappearAction: 子节点的删除动作，由调用者指定，必须为TargetedAction
--callback: 当子节点删除完毕，并且相应的其他子节点移动位置的动作执行完毕后的回调函数
--lineIntvl: 滚动框中子节点之间的行间隔，默认首选调用者指定参数，否则搜索滚动框本身指定的航间隔，否则默认为10
--enableDurAnim: 在执行动画期间，滚动框是否可用（默认不可用）
function ccui.ScrollView:removeChildById(params)
    if not params then 
        return 
    end 
--    if not self.removingChildList then 
--        self.removingChildList = {}
--    end 

    local id = params.id --需要移除的孩子节点ID
    local step = params.step or 10 --动画步进像素
    local disappearAction = params.disappearAction 
    local callback = params.callback --动画执行完毕后的回调
    local lineIntvl = params.lineIntvl or self.lineIntvl or 10 --行间隔
    local enableDurAnim = params.enableDurAnim or false

    -------------------------------
    local children = self:getChildren()
    local childrenCnt = #children 
    --get the child need to be removed
    local child = nil 
    local seq = 0
    for _,v in pairs(children) do 
        if v.id == id then 
            child = v 
            seq = _
            break 
        end 
    end 
    if not child then 
        return 
    end
    local destOffset = 0 
    local function removeFunc()
        if seq == childrenCnt then 
            destOffset = child:getContentSize().height 
        else 
            destOffset = child:getContentSize().height + lineIntvl 
        end 
        child:removeFromParentAndCleanup(true)
--        children = self:getChildren()
--        childrenCnt = #children 
        print("[LOG] destOffset: "..tostring(destOffset))
    end 

    local scrSize = self:getContentSize()
    local innerSize = self:getInnerContainerSize()
    local stepPxAccu = 0 
    local offset = 0 

    local function actEndProcess()
        print("[INFO] Action End process called")
        self:stopActionByTag(id)
--        self:stopAllActions()
        self:setEnabled(true)
        --执行回调
        if callback then 
            callback(self)
        else
            print("[INFO] nil callback of endProcess")
        end 
    end 

    local function removeAnim(obj)
        print("Anim executing...")
        if childrenCnt == 0 then 
            self:setInnerContainerSize(scrSize)
            actEndProcess()
            return 
        end 
        local needStop = false 
        local offset = step 
        stepPxAccu = stepPxAccu + offset 
        print("[LOG] id: "..tostring(id))
        print("[LOG] destOffset: "..tostring(destOffset))
        print("[LOG] stepPxAccu: "..tostring(stepPxAccu))
        if stepPxAccu > destOffset then 
            offset = destOffset - stepPxAccu + offset 
            needStop = true 
        end 
        local index = seq 
        local endNdx = childrenCnt
        while index <= endNdx do 
            local child = children[index]
            if not tolua.isnull(child) then 
                local pos = cc.p(child:getPosition())
                pos.y = pos.y + offset 
                child:setPosition(pos)
            end 
            index = index + 1
        end 
        if needStop then 
            local innerOffset = destOffset
            innerSize.height = innerSize.height - innerOffset  
            if innerSize.height < scrSize.height then 
                innerOffset = innerSize.height + innerOffset - scrSize.height
                innerSize.height = scrSize.height 
            end 
            self:setInnerContainerSize(innerSize)
            if innerOffset > 0 then 
                for _,child in pairs(children) do 
                    if not tolua.isnull(child) then 
                        local pos = cc.p(child:getPosition())
                        pos.y = pos.y - innerOffset 
                        child:setPosition(pos)
                    end 
                end 
            end 

            actEndProcess()
        end 
    end 

    local function actAfterRemoved(obj)
        self:stopActionByTag(id)
        local rptAct = cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(removeAnim)))
        rptAct:setTag(id)
        transition.execute(self,rptAct,{})
    end 

    self:setEnabled(enableDurAnim)
    local act = cc.Sequence:create(
                        disappearAction or cc.CallFunc:create(function() end),
                        cc.CallFunc:create(removeFunc),
                        cc.CallFunc:create(actAfterRemoved))
    act:setTag(id)
    transition.execute(self,act,{})
end 

--[Comment]
--对滚动容器的子节点进行横向布局（暂时只支持单行）
--margin: 指定对齐方式（-1：下对齐，0：中对齐，1：上对齐）（默认中对齐0）
--columnIntvl: 指定列间隔（默认为10）
--needSort: 如果指定此参数为true，则在创建滚动层的孩子节点的时候必须指定priority字段
function ccui.ScrollView:layoutHorizontal(params)
    params = params or {}
    local margin = params.margin or 0 --{-1：下对齐，0：中对齐，1：上对齐}
    local columnIntvl = params.columnIntvl or 10
    local needSort = params.needSort or false 
    -------------------------------------
    local intvl = columnIntvl 
    local children = self:getChildren()
    if needSort then 
        table.sort(children,function(c1,c2)
            return c1.priority < c2.priority 
        end)
    end 
    local childrenCnt = #children 
    local scrSize = self:getContentSize()
    if childrenCnt == 0 then 
        return 
    end 
    local ndx = 1 
    local prevAnpt,prevPos,prevSize = cc.p(0,0),cc.p(0,0),CCSize(0,0)
    local first = 0
    while ndx <= childrenCnt do 
        local child = children[ndx]
        local anpt = child:getAnchorPoint()
        local size = child:getContentSize()
        local pos = cc.p(0,0)
        pos.x = size.width * anpt.x 
        pos.y = size.height * anpt.y 
        if margin == -1 then 
            pos.y = pos.y + 0
        elseif margin == 0 then 
            pos.y = (scrSize.height - size.height) * 0.5 + pos.y 
        elseif margin == 1 then 
            pos.y = scrSize.height - (size.height - pos.y)
        end 
        pos.x = pos.x + prevPos.x + (1 - prevAnpt.x) * prevSize.width + intvl * first 
        child:setPosition(pos)

        prevAnpt = anpt 
        prevPos = pos 
        prevSize = size 
        first = 1

        ndx = ndx + 1
    end 
    local child2 = children[childrenCnt]
    local anpt2 = child2:getAnchorPoint()
    local size2 = child2:getContentSize()
    local pos2 = cc.p(child2:getPosition())
    local totalWidth = pos2.x + size2.width * (1 - anpt2.x)
    scrSize.width = totalWidth 
    self:setInnerContainerSize(scrSize)
end 

--[Comment]
--滚动到指定ID的子节点
--id: 子节点ID(必须）
--autoBottom: 当没有找到指定子节点的时候，自动滚动到底部
function ccui.ScrollView:scrollVerticalToNode(params)
    params = params or {}
    local id = params.id 
    local autoBottom = params.autoBottom == nil and true or params.autoBottom
    -------------------------------
    if not id then 
        return 
    end 
    local children = self:getChildren()
    local childrenCnt = #children 
    --get the child need to be removed
    local child = nil 
    for _,v in pairs(children) do 
        if v.id == id then 
            child = v 
            break 
        end 
    end 
    if not child then 
        if autoBottom then 
            self:scrollToPercentVertical(100,0.3,true)
        end 
        return 
    end
    local innerSize = self:getInnerContainerSize()
    local cntrSize = self:getContentSize()
    local pos = cc.p(child:getPosition())
    local anpt = child:getAnchorPoint()
    local size = child:getContentSize()
    local div = (innerSize.height - cntrSize.height)
    div = div == 0 and 1 or div 
    local rate = 1 - (pos.y + size.height * (1 - anpt.y) - cntrSize.height) / div
    rate = rate > 1 and 1 or rate 
    rate = rate < 0 and 0 or rate
    self:scrollToPercentVertical(rate * 100,0.3,false)
end 

--[Comment]
--对层容器的子节点进行布局（仅支持每个子节点尺寸一致的情况）
--columns: 指定列的数目（默认为1）
--marginLeft: 指定左边距（默认为0）
--marginRight: 指定右边距（默认为0）
--lineIntvl: 指定行间隔（默认等于列间隔）
--columnIntvl: 指定列间隔（如果不指定，程序自动等列宽分配）
--offsetX: 子节点布局时候给定的一个额外X的偏移值（默认为0）
--offsetY: 子节点布局时候给定的一个额外Y的偏移值（默认为0）
--imgLineIntvl: 行间隔显示图片（如果为string, 那么表示的是图片路径）
--needSort: 如果指定此参数为true，则在创建滚动层的孩子节点的时候必须指定priority字段
--startNdx: 指定布局子节点的起始索引（默认为1）
--endNdx: 指定布局子节点的结束索引（默认为子节点的数目）
--onlyVisible: 指定是否只对可见节点布局，默认为true
function WidgetExt.panLayoutVertical(pan,params)
    params = params or {}
    local columns = params.columns or 1 
    local marginLeft = params.marginLeft or 0 
    local marginRight = params.marginRight or 0 
    local marginTop = params.marginTop or 0
    local marginBottom = params.marginBottom or 0
    local lineIntvl = params.lineIntvl or 0 
    local columnIntvl = params.columnIntvl or 0
    local offsetX = params.offsetX or 0 
    local offsetY = params.offsetY or 0 
    local imgLineIntvl = params.imgLineIntvl
    local imgLineIntvl = type(imgLineIntvl) == "string" and ccui.ImageView:create(imgLineIntvl) or imgLineIntvl
    local imgColumnIntvl = params.imgColumnIntvl
    local imgColumnIntvl = type(imgColumnIntvl) == "string" and ccui.ImageView:create(imgColumnIntvl) or imgColumnIntvl
    local lineIntvlImgOffsetX = params.lineIntvlImgOffsetX or 0 
    local lineIntvlImgOffsetY = params.lineIntvlImgOffsetY or 0 
    local lineIntvlImgZOrder = params.lineIntvlImgZOrder or -1000 --默认置底
    local colIntvlImgOffsetX = params.colIntvlImgOffsetX or 0 
    local colIntvlImgOffsetY = params.colIntvlImgOffsetY or 0 
    local colIntvlImgZOrder = params.colIntvlImgZOrder or -1000 --默认置底
    local hasTopLineIntvl = params.hasTopLineIntvl or false
    local hasBottomLineIntvl = params.hasBottomLineIntvl or false
    local hasLeftIntvl = params.hasLeftIntvl or false
    local hasRightIntvl = params.hasRightIntvl or false
    local needSort = params.needSort or false 
    local onlyVisible = params.onlyVisible == nil and true or params.onlyVisible 
    local minHeight = params.minHeight or 0
    local reverseLine = params.reverseLine or false
    local reverseCol = params.reverseCol or false
    local horizontalMargin = params.horizontalMargin or WidgetExt.HorizontalMargin.CENTER
    local autoWidth = params.autoWidth == nil and true or params.autoWidth --not available now
    local autoHeight = params.autoHeight == nil and true  or params.autoHeight

    local children = pan:getChildren() 
    local tmp = {}
    if onlyVisible then 
        for _,child in ipairs(children) do 
            if child:isVisible() then 
                table.insert(tmp,child)
            end 
        end 
    end 
    children = tmp 
    local startNdx = params.startNdx or 1 
    local endNdx = params.endNdx or #children 
    local childrenSort = {}
    local ndx = 1
    while ndx <= #children do 
        if ndx < startNdx or ndx > endNdx then 
            children[ndx]:setVisible(false)
        else 
            children[ndx]:setVisible(true)
            table.insert(childrenSort,children[ndx])
        end 
        ndx = ndx + 1
    end 
    children = childrenSort 
    if needSort then 
        table.sort(children,function(child1,child2)
            return child1.priority < child2.priority 
        end)
    end 
    local cnt = #children 
    if cnt == 0 then 
        return 
    end 
    if imgLineIntvl then 
        imgLineIntvl:setLocalZOrder(lineIntvlImgZOrder)
    end 
    if imgColumnIntvl then 
        imgColumnIntvl:setLocalZOrder(colIntvlImgZOrder)
    end 
    local lines = math.ceil(cnt / columns)
    local itemSize = children[1]:getContentSize() 
    local itemScale = cc.p(children[1]:getScaleX(), children[1]:getScaleY())
    itemSize.width = itemSize.width * itemScale.x
    itemSize.height = itemSize.height * itemScale.y
    local innerContainerSize = pan:getContentSize() 
    --如果没有指定行间隔和列间隔，程序自动计算
    if not columnIntvl then 
        local intvls = columns - 1 
        if hasLeftIntvl then 
            intvls = intvls + 1 
        end 
        if hasRightIntvl then 
            intvls = intvls + 1 
        end 
        columnIntvl = (innerContainerSize.width - marginLeft - marginRight - columns * itemSize.width) / intvls 
    end 
    if not lineIntvl then 
        lineIntvl = columnIntvl 
    end 
    --更新内置滚动区域尺寸
    local height = (lines - 1) * (lineIntvl + itemSize.height) + itemSize.height
    if hasTopLineIntvl then 
        height = height + lineIntvl
    end 
    if hasBottomLineIntvl then 
        height = height + lineIntvl
    end 
    height = height + marginTop + marginBottom

    minHeight = minHeight or height 
    if autoHeight then 
        innerContainerSize.height = minHeight > height and minHeight or height 
    end 
    pan:setContentSize(innerContainerSize)
    --开始布局
    if horizontalMargin == WidgetExt.HorizontalMargin.LEFT then 

    elseif horizontalMargin == WidgetExt.HorizontalMargin.CENTER then 
        marginLeft = (innerContainerSize.width - marginLeft - marginRight - 
                        (itemSize.width + columnIntvl) * (columns - 1) - itemSize.width) / 2 + marginLeft --居中
    elseif horizontalMargin == WidgetExt.HorizontalMargin.RIGHT then 
        marginLeft = (innerContainerSize.width - marginLeft - marginRight) --居右
    end 
    
    if hasLeftIntvl then 
        marginLeft = marginLeft - columnIntvl
    end 
    local lineIntvlImgPosX = innerContainerSize.width / 2 + lineIntvlImgOffsetX
    local colIntvlImgPosY = innerContainerSize.height / 2 + colIntvlImgOffsetY
    local top = innerContainerSize.height 
    local right = innerContainerSize.width
    local pos = cc.p(marginLeft,top)
    local i = 1 
    local lastLineNO = 0  
    while i <= cnt do 
        local child = children[i] 
        local anpt = child:getAnchorPoint()
        local col = (i - 1) % columns + 1
        local line = math.ceil(i / columns) 
        if reverseCol then 
            pos.x = right - marginRight - (col - 1) * (itemSize.width + columnIntvl) - itemSize.width * (1 - anpt.x) - offsetX 
        else 
            pos.x = marginLeft + (col - 1) * (itemSize.width + columnIntvl) + itemSize.width * anpt.x + offsetX 
        end 
        if reverseLine then 
            pos.y = (line - 1) * (itemSize.height + lineIntvl) + itemSize.height * anpt.y + offsetY 
        else 
            pos.y = top - (line - 1) * (itemSize.height + lineIntvl) - itemSize.height * (1 - anpt.y) + offsetY 
        end 
        if hasLeftIntvl then 
            pos.x = pos.x + columnIntvl 
        end 
        if hasTopLineIntvl then 
            pos.y = pos.y - lineIntvl 
        end 
        pos.y = pos.y - marginTop
        child:setPosition(pos) 
        if col == 1 then 
            lastLineNO = lastLineNO + 1
        end 
        if imgLineIntvl and i < cnt and col == columns then --保证不是在最后一行添加行间隔图片
            local imgLine = imgLineIntvl:clone() 
            imgLine:setVisible(true)
            imgLine:setPosition(cc.p(lineIntvlImgPosX,pos.y - anpt.y * itemSize.height - lineIntvl / 2.0 + lineIntvlImgOffsetY))
            pan:addChild(imgLine)
        end 
        i = i + 1 
    end 
    --添加首行间隔图和末行间隔图
    if hasTopLineIntvl and imgLineIntvl then 
        local imgLine = imgLineIntvl:clone() 
        imgLine:setVisible(true)
        imgLine:setPosition(cc.p(lineIntvlImgPosX,top - lineIntvl / 2.0 + lineIntvlImgOffsetY + offsetY - marginTop))
        pan:addChild(imgLine)
    end 
    if hasBottomLineIntvl and imgLineIntvl then 
        local imgLine = imgLineIntvl:clone() 
        imgLine:setVisible(true)
        imgLine:setPosition(cc.p(lineIntvlImgPosX,top - (lastLineNO - 1) * (itemSize.height + lineIntvl) - itemSize.height + offsetY - lineIntvl / 2.0 + lineIntvlImgOffsetY + marginBottom))
        pan:addChild(imgLine)
    end 
    --添加列间隔图
    if imgColumnIntvl then 
        local j = 1 
        while j < columns do 
            local x = marginLeft + (j - 1) * (itemSize.width + columnIntvl) + offsetX + itemSize.width 
            if hasLeftIntvl then 
                x = x + columnIntvl / 2.0 + colIntvlImgOffsetX 
            end 
            local imgCol = imgColumnIntvl:clone()
            imgCol:setVisible(true)
            imgCol:setPosition(cc.p(x,colIntvlImgPosY))
            pan:addChild(imgCol)
        end 
        if hasLeftIntvl then 
            local imgCol = imgColumnIntvl:clone()
            imgCol:setVisible(true)
            imgCol:setPosition(cc.p(marginLeft + columnIntvl / 2 + offsetX + colIntvlImgOffsetX,colIntvlImgPosY))
            pan:addChild(imgCol)
        end 
        if hasRightIntvl then 
            local imgCol = imgColumnIntvl:clone()
            imgCol:setVisible(true)
            local x = marginLeft + (columns - 1) * (itemSize.width + columnIntvl) + offsetX + itemSize.width 
            imgCol:setPosition(cc.p(x + columnIntvl / 2 + colIntvlImgOffsetX,colIntvlImgPosY))
            pan:addChild(imgCol)
        end 
    end 
end 

--[Comment]
--对层容器的子节点进行布局（仅支持每个子节点尺寸一致的情况）
--columns: 指定列的数目（默认为1）
--marginLeft: 指定左边距（默认为0）
--marginRight: 指定右边距（默认为0）
--lineIntvl: 指定行间隔（默认等于列间隔）
--columnIntvl: 指定列间隔（如果不指定，程序自动等列宽分配）
--offsetX: 子节点布局时候给定的一个额外X的偏移值（默认为0）
--offsetY: 子节点布局时候给定的一个额外Y的偏移值（默认为0）
--imgLineIntvl: 行间隔显示图片（如果为string, 那么表示的是图片路径）
--needSort: 如果指定此参数为true，则在创建滚动层的孩子节点的时候必须指定priority字段
--startNdx: 指定布局子节点的起始索引（默认为1）
--endNdx: 指定布局子节点的结束索引（默认为子节点的数目）
--onlyVisible: 指定是否只对可见节点布局，默认为true
function WidgetExt.panLayoutHorizontal(pan,params)
    params = params or {}
    local lines = params.lines or 1 
    local marginLeft = params.marginLeft or 0 
    local marginRight = params.marginRight or 0 
    local marginTop = params.marginTop or 0
    local marginBottom = params.marginBottom or 0
    local lineIntvl = params.lineIntvl or 0
    local columnIntvl = params.columnIntvl or 0
    local offsetX = params.offsetX or 0 
    local offsetY = params.offsetY or 0 
    local imgLineIntvl = params.imgLineIntvl
    local imgLineIntvl = type(imgLineIntvl) == "string" and ccui.ImageView:create(imgLineIntvl) or imgLineIntvl
    local imgColumnIntvl = params.imgColumnIntvl
    local imgColumnIntvl = type(imgColumnIntvl) == "string" and ccui.ImageView:create(imgColumnIntvl) or imgColumnIntvl
    local lineIntvlImgOffsetX = params.lineIntvlImgOffsetX or 0 
    local lineIntvlImgOffsetY = params.lineIntvlImgOffsetY or 0 
    local lineIntvlImgZOrder = params.lineIntvlImgZOrder or -1000 --默认置底
    local colIntvlImgOffsetX = params.colIntvlImgOffsetX or 0 
    local colIntvlImgOffsetY = params.colIntvlImgOffsetY or 0 
    local colIntvlImgZOrder = params.colIntvlImgZOrder or -1000 --默认置底
    local hasTopLineIntvl = params.hasTopLineIntvl or false
    local hasBottomLineIntvl = params.hasBottomLineIntvl or false
    local hasLeftIntvl = params.hasLeftIntvl or false
    local hasRightIntvl = params.hasRightIntvl or false
    local needSort = params.needSort or false 
    local onlyVisible = params.onlyVisible == nil and true or params.onlyVisible 
    local minHeight = params.minHeight or 0
    local minWidth = params.minWidth or 0
    local reverseLine = params.reverseLine or false
    local reverseCol = params.reverseCol or false
    local autoWidth = params.autoWidth == nil and true or params.autoWidth 
    local autoHeight = params.autoHeight == nil and true  or params.autoHeight

    local children = pan:getChildren() 
    local tmp = {}
    if onlyVisible then 
        for _,child in ipairs(children) do 
            if child:isVisible() then 
                table.insert(tmp,child)
            end 
        end 
    end 
    children = tmp 
    local startNdx = params.startNdx or 1 
    local endNdx = params.endNdx or #children 
    local childrenSort = {}
    local ndx = 1
    while ndx <= #children do 
        if ndx < startNdx or ndx > endNdx then 
            children[ndx]:setVisible(false)
        else 
            children[ndx]:setVisible(true)
            table.insert(childrenSort,children[ndx])
        end 
        ndx = ndx + 1
    end 
    children = childrenSort 
    if needSort then 
        table.sort(children,function(child1,child2)
            return child1.priority < child2.priority 
        end)
    end 
    local cnt = #children 
    if cnt == 0 then 
        return 
    end 
    if imgLineIntvl then 
        imgLineIntvl:setLocalZOrder(lineIntvlImgZOrder)
    end 
    if imgColumnIntvl then 
        imgColumnIntvl:setLocalZOrder(colIntvlImgZOrder)
    end 
    local columns = math.ceil(cnt / lines)
    local itemSize = children[1]:getContentSize() 
    local itemScale = cc.p(children[1]:getScaleX(), children[1]:getScaleY())
    itemSize.width = itemSize.width * itemScale.x
    itemSize.height = itemSize.height * itemScale.y
    local innerContainerSize = pan:getContentSize() 
    --如果没有指定行间隔和列间隔，程序自动计算
    if not columnIntvl and columns > 1 then 
        local intvls = columns - 1 
        if hasLeftIntvl then 
            intvls = intvls + 1 
        end 
        if hasRightIntvl then 
            intvls = intvls + 1 
        end 
        columnIntvl = (innerContainerSize.width - marginLeft - marginRight - columns * itemSize.width) / intvls 
    else 
        columnIntvl = columnIntvl or 0 
    end 
    if not lineIntvl then 
        lineIntvl = columnIntvl 
    end 
    --更新内置滚动区域尺寸
    local height = (lines - 1) * (lineIntvl + itemSize.height) + itemSize.height
    if hasTopLineIntvl then 
        height = height + lineIntvl
    end 
    if hasBottomLineIntvl then 
        height = height + lineIntvl
    end 
    height = height + marginTop + marginBottom
    local width = (columns - 1) * (columnIntvl + itemSize.width) + itemSize.width
    if hasLeftIntvl then 
        width = width + columnIntvl
    end 
    if hasRightIntvl then 
        width = width + columnIntvl
    end

    minHeight = minHeight or height 
    minWidth = minWidth or width 
    if autoHeight then 
        innerContainerSize.height = minHeight > height and minHeight or height 
    end 
    if autoWidth then 
        innerContainerSize.width = minWidth > width and minWidth or width
    end 
    pan:setContentSize(innerContainerSize)
    --开始布局
--    marginLeft = (innerContainerSize.width - marginLeft - marginRight - (itemSize.width + columnIntvl) * (columns - 1) - itemSize.width) / 2 + marginLeft --居中
    if hasLeftIntvl then 
        marginLeft = marginLeft - columnIntvl
    end 
    local lineIntvlImgPosX = innerContainerSize.width / 2 + lineIntvlImgOffsetX
    local colIntvlImgPosY = innerContainerSize.height / 2 + colIntvlImgOffsetY
    local top = innerContainerSize.height 
    local right = innerContainerSize.width
    local pos = cc.p(marginLeft,top)
    local i = 1 
    local lastLineNO = 0  
    while i <= cnt do 
        local child = children[i] 
        local anpt = child:getAnchorPoint()
        local line = (i - 1) % lines + 1
        local col = math.ceil(i / lines) 
        if reverseCol then 
            pos.x = right - marginLeft - (col - 1) * (itemSize.width + columnIntvl) - itemSize.width * (1 - anpt.x) - offsetX 
        else 
            pos.x = marginLeft + (col - 1) * (itemSize.width + columnIntvl) + itemSize.width * anpt.x + offsetX 
        end 
        if reverseLine then 
            pos.y = (line - 1) * (itemSize.height + lineIntvl) + itemSize.height * anpt.y + offsetY 
        else 
            pos.y = top - (line - 1) * (itemSize.height + lineIntvl) - itemSize.height * (1 - anpt.y) + offsetY 
        end 
        if hasLeftIntvl then 
            pos.x = pos.x + columnIntvl 
        end 
        if hasTopLineIntvl then 
            pos.y = pos.y - lineIntvl 
        end 
        pos.y = pos.y - marginTop
        child:setPosition(pos) 
        if col == 1 then 
            lastLineNO = lastLineNO + 1
        end 
        if imgLineIntvl and i < cnt and col == 1 and line < lines then --保证不是在最后一行添加行间隔图片
            local imgLine = imgLineIntvl:clone() 
            imgLine:setVisible(true)
            imgLine:setPosition(cc.p(lineIntvlImgPosX,pos.y - anpt.y * itemSize.height - lineIntvl / 2.0 + lineIntvlImgOffsetY))
            pan:addChild(imgLine)
        end 
        i = i + 1 
    end 
    --添加首行间隔图和末行间隔图
    if hasTopLineIntvl and imgLineIntvl then 
        local imgLine = imgLineIntvl:clone() 
        imgLine:setVisible(true)
        imgLine:setPosition(cc.p(lineIntvlImgPosX,top - lineIntvl / 2.0 + lineIntvlImgOffsetY + offsetY - marginTop))
        pan:addChild(imgLine)
    end 
    if hasBottomLineIntvl and imgLineIntvl then 
        local imgLine = imgLineIntvl:clone() 
        imgLine:setVisible(true)
        imgLine:setPosition(cc.p(lineIntvlImgPosX,top - (lastLineNO - 1) * (itemSize.height + lineIntvl) - itemSize.height + offsetY - lineIntvl / 2.0 + lineIntvlImgOffsetY + marginBottom))
        pan:addChild(imgLine)
    end 
    --添加列间隔图
    if imgColumnIntvl then 
        local j = 1 
        while j < columns do 
            local x = marginLeft + (j - 1) * (itemSize.width + columnIntvl) + offsetX + itemSize.width 
            if hasLeftIntvl then 
                x = x + columnIntvl / 2.0 + colIntvlImgOffsetX 
            end 
            local imgCol = imgColumnIntvl:clone()
            imgCol:setVisible(true)
            imgCol:setPosition(cc.p(x,colIntvlImgPosY))
            pan:addChild(imgCol)
        end 
        if hasLeftIntvl then 
            local imgCol = imgColumnIntvl:clone()
            imgCol:setVisible(true)
            imgCol:setPosition(cc.p(marginLeft + columnIntvl / 2 + offsetX + colIntvlImgOffsetX,colIntvlImgPosY))
            pan:addChild(imgCol)
        end 
        if hasRightIntvl then 
            local imgCol = imgColumnIntvl:clone()
            imgCol:setVisible(true)
            local x = marginLeft + (columns - 1) * (itemSize.width + columnIntvl) + offsetX + itemSize.width 
            imgCol:setPosition(cc.p(x + columnIntvl / 2 + colIntvlImgOffsetX,colIntvlImgPosY))
            pan:addChild(imgCol)
        end 
    end 
end 

--[Comment]
--对层容器的不规则子节点进行横向布局（暂时只支持单行）
--margin: 指定对齐方式（-1：下对齐，0：中对齐，1：上对齐）（默认中对齐0）
--columnIntvl: 指定列间隔（默认为10）
--needSort: 如果指定此参数为true，则在创建滚动层的孩子节点的时候必须指定priority字段
--offsetX: 子节点的X坐标偏移（默认为0）
--children: 需要布局的子节点（默认使用pan:getChildren()）
--onlyVisible: 指定是否只对可见节点布局，默认为true
function WidgetExt.panLayoutCustomHorizontal(pan,params)
    params = params or {}
    local margin = params.margin or WidgetExt.VerticalMargin.CENTER --{-1：下对齐，0：中对齐，1：上对齐}
    local columnIntvl = params.columnIntvl or 10
    local needSort = params.needSort or false 
    local offsetX = params.offsetX or 0 
    local adaptSize = params.adaptSize == nil and true or params.adaptSize
    local onlyVisible = params.onlyVisible == nil and true or params.onlyVisible 
    -------------------------------------
    local intvl = columnIntvl 
    local children = params.children or pan:getChildren()
    local tmp = {}
    if onlyVisible then 
        for _,child in ipairs(children) do 
            if child:isVisible() then 
                table.insert(tmp,child)
            end 
        end 
    end 
    children = tmp 
    if needSort then 
        table.sort(children,function(c1,c2)
            return c1.priority < c2.priority 
        end)
    end 
    local childrenCnt = #children 
    local panSize = pan:getContentSize()
    if childrenCnt == 0 then 
        panSize.width = 0
        pan:setContentSize(panSize)
        return 
    end 
    local ndx = 1 
    local prevAnpt,prevPos,prevSize, prevScale = cc.p(0,0),cc.p(0,0),CCSize(0,0), cc.p(1, 1)
    local first = 0
    while ndx <= childrenCnt do 
        local child = children[ndx]
        local scale = cc.p(child:getScaleX(), child:getScaleY())
        local anpt = child:getAnchorPoint()
        local size = child:getContentSize()
        size.width = size.width * scale.x
        size.height = size.height * scale.y
        local pos = cc.p(0,0)
        pos.x = size.width * anpt.x
        pos.y = size.height * anpt.y
        if margin == WidgetExt.VerticalMargin.BOTTOM then 
            pos.y = pos.y + 0
        elseif margin == WidgetExt.VerticalMargin.CENTER then 
            pos.y = (panSize.height - size.height) * 0.5 + pos.y 
        elseif margin == WidgetExt.VerticalMargin.TOP then 
            pos.y = panSize.height - (size.height - pos.y)
        end 
        pos.x = pos.x + prevPos.x + (1 - prevAnpt.x) * prevSize.width + intvl * first 
        child:setPosition(cc.p(pos.x + offsetX, pos.y))

        prevAnpt = anpt 
        prevPos = pos 
        prevSize = size 
        first = 1

        ndx = ndx + 1
    end 
    if adaptSize then 
    --    local child1 = children[1]
        local child2 = children[childrenCnt]
    --    local anpt1 = child1:getAnchorPoint()
    --    local size1 = child1:getContentSize()
    --    local pos1 = cc.p(child1:getPosition())
        local anpt2 = child2:getAnchorPoint()
        local size2 = child2:getContentSize()
        local scale2 = cc.p(child2:getScaleX(), child2:getScaleY())
        local pos2 = cc.p(child2:getPosition())
        size2.width = size2.width * scale2.x
        size2.height = size2.height * scale2.y
        local totalWidth = pos2.x + size2.width * (1 - anpt2.x)
        panSize.width = totalWidth 
        pan:setContentSize(panSize)
    end 
end 

--[Comment]
--对层容器的不规则子节点进行纵向布局（暂时只支持单列）
--margin: 指定对齐方式（-1：左对齐，0：中对齐，1：右对齐）（默认中对齐0）
--lineIntvl: 指定行间隔（默认为10）
--needSort: 如果指定此参数为true，则在创建滚动层的孩子节点的时候必须指定priority字段
--offsetX: 子节点的X坐标偏移（默认为0）
--children: 需要布局的子节点（默认使用pan:getChildren()）
--onlyVisible: 指定是否只对可见节点布局，默认为true
function WidgetExt.panLayoutCustomVertical(pan,params)
    params = params or {}
    local margin = params.margin or WidgetExt.HorizontalMargin.CENTER --{-1：下对齐，0：中对齐，1：上对齐}
    local lineIntvl = params.lineIntvl or 10
    local needSort = params.needSort or false 
    local offsetX = params.offsetX or 0 
    local adaptSize = params.adaptSize == nil and true or params.adaptSize
    local onlyVisible = params.onlyVisible == nil and true or params.onlyVisible 
    -------------------------------------
    local intvl = lineIntvl 
    local children = params.children or pan:getChildren()
    local tmp = {}
    if onlyVisible then 
        for _,child in ipairs(children) do 
            if child:isVisible() then 
                table.insert(tmp,child)
            end 
        end 
    end 
    children = tmp 
    if needSort then 
        table.sort(children,function(c1,c2)
            return c1.priority < c2.priority 
        end)
    end 
    local childrenCnt = #children 
    local panSize = pan:getContentSize()
    if childrenCnt == 0 then 
        panSize.width = 0
        pan:setContentSize(panSize)
        return 
    end 
    local ndx = 1 
    local prevAnpt,prevPos,prevSize, prevScale = cc.p(0,0),cc.p(0,0),CCSize(0,0), cc.p(1, 1)
    local first = 0
    while ndx <= childrenCnt do 
        local child = children[ndx]
        local scale = cc.p(child:getScaleX(), child:getScaleY())
        local anpt = child:getAnchorPoint()
        local size = child:getContentSize()
        size.width = size.width * scale.x
        size.height = size.height * scale.y
        local pos = cc.p(0,0)
        pos.x = size.width * anpt.x
        pos.y = size.height * anpt.y
        if margin == WidgetExt.HorizontalMargin.LEFT then 
            pos.x = pos.x + 0
        elseif margin == WidgetExt.HorizontalMargin.CENTER then 
            pos.x = (panSize.width - size.width) * 0.5
        elseif margin == WidgetExt.HorizontalMargin.RIGHT then 
            pos.x = panSize.width - (size.width - pos.x)
        end 
        pos.y = pos.y + prevPos.y + (1 - prevAnpt.y) * prevSize.height + intvl * first 
        child:setPosition(cc.p(pos.x + offsetX, pos.y))

        prevAnpt = anpt 
        prevPos = pos 
        prevSize = size 
        first = 1

        ndx = ndx + 1
    end 
    if adaptSize then 
    --    local child1 = children[1]
        local child2 = children[childrenCnt]
    --    local anpt1 = child1:getAnchorPoint()
    --    local size1 = child1:getContentSize()
    --    local pos1 = cc.p(child1:getPosition())
        local anpt2 = child2:getAnchorPoint()
        local size2 = child2:getContentSize()
        local scale2 = cc.p(child2:getScaleX(), child2:getScaleY())
        local pos2 = cc.p(child2:getPosition())
        size2.width = size2.width * scale2.x
        size2.height = size2.height * scale2.y
        local totalWidth = pos2.x + size2.width * (1 - anpt2.x)
        local totalHeight = pos2.y + size2.height * (1 - anpt2.y)
        panSize.width = totalWidth 
        panSize.height = totalHeight 
        pan:setContentSize(panSize)
    end 
end 

--[Comment]
--为节点添加简单的例子特效
function WidgetExt.addParticalEffectFor(node)
    assert(node)
    local armature = CCArmature.new("Effect/effect_ui_equ_zhuangdeng")
        :addTo(node):pos(node:getContentSize().width * node:getAnchorPoint().x,0)
        :play(ACTION.ACT_RUN,-1)
        :setAnimationEvent(ACTION.ACT_RUN,function(obj)
            obj:removeFromParentAndCleanup(true)
        end)
    armature:setAnchorPoint(cc.p(0.5,0.5))
    armature:setLocalZOrder(-1)
end 

--[Comment]
--自动为widget添加绿点提示
--widget: 需要添加绿点的widget
--itemId: 物品ID
--itemDetailInfo: 物品详细信息，由BagCache:queryItemInfo(id)获得（可选）
function WidgetExt.autoAddGreenPointFor(widget,itemId,itemDetailInfo)
    -- 信息展示节点
    local id = itemId
    local itemDetailInfo = itemDetailInfo or BagCache:queryItemInfo(id)
    if itemDetailInfo["green_point"] then 
        tip = ccui.ImageView:create("Images/UI/common/UI_common_tb_lvdian.png")
        tip:setLocalZOrder(1000)
        local widgetSize = widget:getContentSize()
        local pos = cc.p(widgetSize.width * 0.9,widgetSize.height * 0.9)
        tip:setPosition(pos)
        tip:setVisible(true)
        widget:addChild(tip)
        return tip 
    end 
end 

function WidgetExt.setWidgetVisibleEnabled(widget,enabled)
    if not widget or tolua.isnull(widget) then 
        return 
    end 
    widget:setVisible(enabled)
end 

--[Comment]
--把Label的文字保存到label.originText中
function WidgetExt.saveOriginText(node,children)
    for _,v in pairs(children) do 
        local name = type(v) == "string" and v or v.key 
        local child = UIHelper:seekWidgetByName(node,name)
        if child and child:getDescription() == "Label" then 
            child.originText = child:getString()
        end 
    end 
end 

--[Comment]
--
function WidgetExt.doShakeActions(object,intvlTime)
    local onceTime = 0.06
    intvlTime = intvlTime or 0.3
    local actions = {}
    actions[#actions +1] = cc.EaseSineOut:create( cc.Spawn:create( cc.MoveBy:create(onceTime,cc.p(0,5)),cc.ScaleBy:create(onceTime,1.12) ) )
    actions[#actions +1] = cc.Repeat:create( cc.Sequence:create(cc.RotateTo:create(onceTime,8), cc.RotateTo:create(onceTime,-8)), 3 )
    actions[#actions +1] = cc.RotateTo:create(onceTime*0.5,0)
    actions[#actions +1] = cc.Spawn:create( cc.MoveBy:create(0.1,cc.p(0,-5)), cc.ScaleBy:create(0.1,1/1.12) )
    actions[#actions +1] = cc.CallFunc:create(function(obj)
        object:setScale(object.initScale or object:getScale())
        object:setPosition(object.initPos or cc.p(object:getPosition()))
    end)
    actions[#actions +1] = cc.DelayTime:create(intvlTime)

    local seq = cc.Sequence:create(actions)
    stopShakeActions(object)
    object:runAction( cc.RepeatForever:create(seq) )
end

function WidgetExt.stopShakeActions(object)
    object:stopAllActions()
    object:setRotation(0)
    object:setScale(object.initScale or object:getScale())
    object:setPosition(object.initPos or cc.p(object:getPosition()))
end

--[Comment]
--让子节点在父节点中居中
function WidgetExt.centerParent(child,centerType)
    centerType = centerType or CenterType.BOTH 
    ---------------------------
    local parent = child:getParent()
    if not parent then 
        return 
    end 
    local size = child:getContentSize()
    local anpt = child:getAnchorPoint()
    local pos = cc.p(child:getPosition())
    local pSize = parent:getContentSize()
    if centerType == CenterType.HORIZONTAL or centerType == CenterType.BOTH then 
        pos.x = (pSize.width - size.width) / 2 + size.width * anpt.x 
    end 
    if centerType == CenterType.VERTICAL or centerType == CenterType.BOTH then 
        pos.y = (pSize.height - size.height) / 2 + size.height * anpt.y 
    end 
    child:setPosition(pos)
end 

--Sprite
function cc.Sprite:setGray()  
    if self.isGray then 
        return 
    end 
    ShaderEffect:setGray(self)
    self.isGray = true
    for _, child in pairs(self:getChildren()) do 
        if child.setGray then 
            child:setGray()
        end 
    end 
end  

function cc.Sprite:setNormal()  
    if not self.isGray then 
        return 
    end 
    ShaderEffect:reset(self)
    self.isGray = false
    for _, child in pairs(self:getChildren()) do 
        if child.setNormal then 
            child:setNormal()
        end 
    end 
end  

--Button
function ccui.Button:setGray()
    if self.isGray then 
        return 
    end 
    ShaderEffect:setGray(self:getVirtualRenderer():getSprite())
    self.isGray = true
    for _, child in pairs(self:getChildren()) do 
        if child.setGray then 
            child:setGray()
        end 
    end 
end 

function ccui.Button:setNormal()
    if not self.isGray then 
        return 
    end 
    self.isGray = false
    ShaderEffect:reset(self:getVirtualRenderer():getSprite())
    for _, child in pairs(self:getChildren()) do 
        if child.setNormal then 
            child:setNormal()
        end 
    end 
end 

function ccui.Button:setSelected(selected)
    if not self.selectedImg then 
        self.selectedImg = self:getClickFileName()
    end 
    if not self.unSelectedImg then 
        self.unSelectedImg = self:getNormalFileName()
    end 
    if selected == true then 
        if self.selectedImg then 
            self:loadTextureNormal(self.selectedImg)
        end 
    else 
        if self.unSelectedImg then 
            self:loadTextureNormal(self.unSelectedImg)
        end 
    end 
end 

function ccui.Button:setSelectedExt(checked)
    self.checked = checked
    self:setSelected(checked)
end 

function ccui.Button:getSelectedExt(checked)
    return self.checked ~= nil and self.checked or false
end 

--裁切图片
--parama res:图片资源
--parama rect:裁切图片的矩形框(默认为图片资源大小)
--return sprite(裁切后的精灵)
function display.clippingImage(res,rect)
    assert(res)
    local sprite = display.newSprite(res)
    sprite:setAnchorPoint(cc.p(0,0))
    local size = sprite:getContentSize()
    rect = rect or cc.rect(0,0,size.width,size.height)
    sprite:pos( - rect.x, - rect.y)
    
    
    local canvas = cc.RenderTexture:create(rect.width,rect.height)
    canvas:begin()
    sprite:visit()
    canvas:endToLua()
    
    local sp = display.newSprite(canvas:getSprite():getTexture())
    printInfo("display.clippingImage: %d, %d", sp:getContentSize().width,sp:getContentSize().height)
    sp:flipY(true)
    return sp
end

--裁切节点，根据传入参数
function display.clippingNode(node,points)
    local stencil =nil
    local clipNode = cc.ClippingNode:create()
    if not tolua.isnull(points) then
        clipNode:setAlphaThreshold(0)
        stencil = display.newNode():setPosition(cc.p(node:getContentSize().width/2,node:getContentSize().height/2))
        points:addTo(stencil)
    else
        stencil  = display.newPolygon(points, {fillColor=cc.c4f(1,1,1,1), borderWidth=1, borderColor=cc.c4f(1,1,1,1)})
    end
    clipNode.tagName = "clipNode"
    clipNode:setStencil(stencil)
    local needRelease = false
    if node:getParent() then
        clipNode:setPosition(cc.p(node:getPosition()).x,cc.p(node:getPosition()).y)
        clipNode:setAnchorPoint(cc.p(node:getAnchorPoint()))
        clipNode:setLocalZOrder(node:getLocalZOrder())
        node:retain()
        node:removeFromParentAndCleanup(true)
        needRelease = true
    end
    node:addTo(clipNode):setPosition(cc.p(node:getAnchorPointInPoints().x,node:getAnchorPointInPoints().y))
    clipNode:setContentSize(node:getContentSize())
    if needRelease then
        node:release()
    end
    clipNode:setInverted(false)
    return clipNode
end

function display.newScreenClippingNode(clipObj)
    local clipY = 0
    if display.height > CONFIG_DESIGN_HEIGHT then
        clipY = display.cy - CONFIG_DESIGN_HEIGHT / 2
    end
    local clipnode = display.newClippingRegionNode(cc.rect(0, clipY, display.width, CONFIG_DESIGN_HEIGHT))
    if clipObj then clipObj:addTo(clipnode) end 

    return clipnode 
end

--[Comment]
--根据框的大小对icon进行剪切，框需要保证为圆形
--裁剪将围绕着icon的中心进行一个直径为frame的宽度-10的圆形的剪切
function WidgetExt.clipPhotoWithFrame(frame,icon, sampleImgPath, scale)
    local sprite = display.newSprite(sampleImgPath)
    local szFrame = frame:getContentSize()
    local szIcon = icon:getContentSize()
    local scale = scale or szFrame.width / szIcon.width
    local parent = icon:getParent()
    icon:ignoreContentAdaptWithSize(false)
    icon:setContentSize(sprite:getContentSize())
    sprite:setScale(0.9)
    local clipImg =  display.clippingNode(icon,sprite)
                        :addTo(parent,-1)
                        :setPosition(cc.p(parent:getContentSize().width/2,parent:getContentSize().height/2))
end 

--[Comment]
--创建截屏精灵
function WidgetExt.createScreenshotSprite()
    local sz = cc.Director:getInstance():getVisibleSize()
    local renderTexture = cc.RenderTexture:create(sz.width, sz.height)

    renderTexture:begin()
    cc.Director:getInstance():getRunningScene():visit()
    renderTexture:endToLua()

    local texture = renderTexture:getSprite():getTexture()
    local sprt = cc.Sprite:createWithTexture(texture)
    sprt:setFlippedY()

    return sprt
end 

--[[
Sprite* utilScreenshot::createScreenshotSprite()  
{  
    GLView* glview = Director::getInstance()->getOpenGLView();  
    Size frameSize = glview->getFrameSize();  

    const int dataLength = frameSize.width * frameSize.height * 4;  
    char* pixelData = new char[dataLength];  
    glReadPixels(0, 0, frameSize.width, frameSize.height, GL_RGBA, GL_UNSIGNED_BYTE, pixelData);  

    Texture2D* texture = new Texture2D();  
    texture->initWithData(pixelData, dataLength, Texture2D::PixelFormat::RGBA8888, frameSize.width, frameSize.height, frameSize);  

    Sprite* sprScreenshot = Sprite::createWithTexture(texture);  
    sprScreenshot->setScaleX(1 / glview->getScaleX());  
    sprScreenshot->setScaleY(1 / glview->getScaleY());  
    sprScreenshot->setFlippedY(true);  

    CC_SAFE_RELEASE(texture);  
    delete[] pixelData;  

    return sprScreenshot;  
}  
--]]

function WidgetExt.convertSpace(from, to, pos)
    pos = pos or cc.p(from:getPosition())
    local worldPos = from:getParent():convertToWorldSpace(pos)
    local localPos = to:convertToNodeSpace(worldPos)
    return localPos
end 

function WidgetExt.getNodeDisplaySize(dstNode)
    local sz = dstNode:getContentSize()
    local function _getScale(node)
        if node:getParent() == nil then 
            return cc.p(1, 1)
        end 
        local scale = cc.p(node:getScaleX(), node:getScaleY())
        local parentScale = _getScale(node:getParent())
        scale.x = scale.x * parentScale.x 
        scale.y = scale.y * parentScale.y 
        return scale
    end 
    local scale = _getScale(dstNode)
    return {
        width = sz.width * scale.x, 
        height = sz.height * scale.y,
    }
end 

function WidgetExt.getDisplaySizeOf(parent, dstSz)
    local sz = dstSz
    local function _getScale(node)
        if node:getParent() == nil then 
            return cc.p(1, 1)
        end 
        local scale = cc.p(node:getScaleX(), node:getScaleY())
        local parentScale = _getScale(node:getParent())
        scale.x = scale.x * parentScale.x 
        scale.y = scale.y * parentScale.y 
        return scale
    end 
    local scale = _getScale(parent)
    return {
        width = sz.width * scale.x, 
        height = sz.height * scale.y,
    }
end 

return WidgetExt