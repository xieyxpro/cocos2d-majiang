--region NewFile_1.lua
--Author : Administrator
--Date   : 2014-11-22
--此文件由[BabeLua]插件自动生成

--[[--

armature动画扩展
example:


]]

-- include
local t_anim_equ = require(rw.CLIENT_CONFIG .. ".items.t_anim_equ")
local t_anim = require(rw.CLIENT_CONFIG .. ".fight.t_anim")
local ArmaturePool = require("app.frameworkExt.cocos2dx.ArmaturePool")

local dbFactory = db.DBCCFactoryExt:getInstance()
Armature = db.DBCCArmatureNode
CCArmature = db.DBCCArmatureNode

-- 是否使用pvr.ccz格式
Armature.PVRCCZ = 1
Armature.PVR = 2
Armature.PNG = 3
Armature.IMAGE_FORMAT = Armature.PNG

Armature.NORMAL     = 1 -- 普通文件，xml + plist + png/pvr
Armature.RW         = 2 -- rw格式文件

Armature.RW_FORMAT = ".rw"
Armature.ZIP_FORMAT = ".zip"

-- 帧事件回调
Armature.FrameEventType = {

}

-- flash fps
Armature.FLASH_FPS = 30

-- 装备类型
Armature.EQU_WEAPON1 = "weapon1"  -- 主手武器
Armature.EQU_WEAPON2 = "weapon2"  -- 副手武器
Armature.EQU_CLOTHES = "clothes"  -- 衣服
Armature.EQU_HEAD    = "head"     -- 头部
Armature.EQU_WING    = "wing"     -- 翅膀


-- event
Armature.MovementEventType = Armature.MovementEventType or {}
Armature.MovementEventType.COMPLETE = 7
Armature.MovementEventType.LOOP_COMPLETE = 8

local armatureObjs = {}

--[[

获取全路径

]]
local function getFullName(name, ext)
   return "Models/" .. name .. ext
end


--[[

获取文件名，不包含目录

]]
local function getRealFileName(filename)
    local pos = string.find(filename, "/")
    if not pos then
        pos = string.find(filename, "\\")
    end
    if pos then
        return string.sub(filename, pos + 1, string.len(filename))
    end
    return filename
end

--[[--

去掉"_"符号的名称，如niutouren_1123 --> niutouren

]]
local function getRealShortFileName(realName)
    local realName = realName
    local pos = string.find(realName, "_")
    if pos then
        return string.sub(realName, 0, pos - 1)
    end
    return realName
end

--[[--

同步预加载

]]
function Armature.preload(filename)
    assert(filename)
    local realName = getRealFileName(filename)
    dbFactory:loadFromRW(getFullName(filename, Armature.RW_FORMAT), realName)
end

--[[--

异步预加载

sample:
    -- Test
    -- 加载初始模型
    local posTable = {}
    local posx = 50
    for i=1, 16 do
        table.insert(posTable, posx)
        Armature.new("Effect/effect_fennu"):addTo(self, 1, 100 + i):pos(posx, 300)
        posx = posx + 50
    end

    -- 预加载并回调
    local function preloadArmature(files, callback)
        for _,v in ipairs(files) do
            Armature.preloadAsync(v, function(filename)
                if callback then callback(filename) end
            end)
        end
    end

    local index = 1
    preloadArmature({"suren", "yilidan", "wuyaowang","wasiqi",
                    "honglongnvwang","suren","wasiqi", "honglongnvwang",
                    "suren", "wasiqi", "honglongnvwang","suren",
                    "yilidan", "wuyaowang", "wasiqi", "honglongnvwang"}, function(name)
        local node = self:getChildByTag(100 + index)
        node:removeFromParent()
        Armature.new(name):addTo(self):pos(posTable[index], 300):play("stand")
        index = index + 1
    end)
]]
function Armature.preloadAsync(filename, callback)
    assert(filename)
    local realName = getRealFileName(filename)

    dbFactory:loadFromRWAsync(getFullName(filename, Armature.RW_FORMAT), realName, function(fileName)
        if callback then callback(filename) end
    end)
end

--[[--

withAE: 是否创建包括动画特效

]]
function Armature.new(filename, withAE)
    assert(filename)

    local withAE = withAE or false

    local realName = getRealFileName(filename)
    dbFactory:loadFromRW(getFullName(filename, Armature.RW_FORMAT), realName)
    Armature.addEffectTexture(filename)

    local armature = dbFactory:buildArmature(realName)
    local node = db.DBCCArmatureNode:create(armature)
    assert(node, filename)
    node:setFileName(filename)
    node:setRealFileName(getRealFileName(filename))

    node:setNodeEventEnabled(true)

    -- 加载动画特效
    --[[
	if withAE then
        node:loadArmatureEffect(filename)
    end
	]]
	node:loadArmatureEffect(filename)

    -- 外部没有重载时默认用这个
    local function onAnimationEventInner(info)
        info.armatureNode.tmpMovementId = info.animationName
        if info.type == Armature.MovementEventType.COMPLETE or info.type == Armature.MovementEventType.LOOP_COMPLETE then
            if not info.armatureNode.animFuncs then return end
            local func = info.armatureNode.animFuncs[info.armatureNode.tmpMovementId]
            if func then
                func(info.armatureNode)
            end
        end

        -- 单独对loop end做处理
        if info.type == Armature.MovementEventType.LOOP_COMPLETE then
            if not info.armatureNode.loopAnimFunc then return end
            local func = info.armatureNode.loopAnimFunc[info.armatureNode.tmpMovementId]
            if func then
                func(info.armatureNode)
            end
        end
    end
    node:registerAnimationEventHandler(onAnimationEventInner)

    node.name = filename
    node.realName = realName

    return node
end

function Armature:loadArmatureEffect(filename)
    local armatureEffectName = getRealShortFileName(filename) .. "Effect"
    if cc.FileUtils:getInstance():isFileExist(getFullName(armatureEffectName, ".rw")) then
        local armatureEffect = Armature.new(armatureEffectName)
        if armatureEffect then
            print("Loaded ArmatureEffect:", armatureEffectName)
            self:setArmatureEffect(armatureEffect)
        end
    end
end

function Armature:setArmatureEffect(effectNode)
    assert(effectNode)
    self.armatureEffect = effectNode
    effectNode:addTo(self)
end

function Armature:getArmatureEffect()
    return self.armatureEffect
end

function Armature:setFileName(name)
    self.filename = name
end

-- 不包含路径的文件名
function Armature:setRealFileName(name)
    self.realFileName = name
end

function Armature:getFileName()
    return self.filename
end

function Armature:getRealFileName()
    return self.realFileName
end

local function getAnimEquInfo(armatureName, key, id)
    assert(armatureName)
    local equInfos = t_anim_equ[armatureName]
    if not equInfos then return end
    equInfos = equInfos[key]
    if not equInfos then return end

    if id then
        return equInfos[id]
    end
    return equInfos
end

--[[--

filename:
cid: 套装衣服ID

]]
function Armature.newWithID(filename, cid, weapon1ID, weapon2ID, headID, withAE,wingId)
    local newfilename = filename
    local isNormal = false
    local withAE = withAE or false

    local showList, hideList = nil
    local effectList = {}
    local clothesInfo = getAnimEquInfo(filename, "clothes", cid)
    if cid and clothesInfo then
        newfilename = clothesInfo["res"][1]
        showList = clothesInfo["show"]
        hideList = clothesInfo["hide"]
        effectList = clothesInfo["effect"] or {}
    else
        isNormal = true
    end

    local armature = Armature.new(newfilename, withAE)
    if not armature then return nil end

    if isNormal then
       armature:initNormalEqus()
    else
        armature:hideBones(hideList)
        armature:showBones(showList)
    end
    print("-------------------------------------")
    print("filename: "..tostring(filename))
    print("***************")
    print("cid: "..tostring(cid))
    print("***************")
    print("clothesInfo: "..table.tostring(clothesInfo or {}))
    print("***************")
    print("effectList: "..table.tostring(effectList or {}))

    -- effect addEffectBone(targetName, effectFileName, x, y, scale, zorder, act)
    for _,v in ipairs(effectList) do
        armature:addEffectBone(v[1], v[2], v[3], v[4], v[5], v[6], v[7])
    end    

    armature:switchEquipment(Armature.EQU_WEAPON1, weapon1ID)
    armature:switchEquipment(Armature.EQU_WEAPON2, weapon2ID)
    armature:switchEquipment(Armature.EQU_HEAD, headID)
    armature:switchEquipment(Armature.EQU_WING, wingId)

    return armature
end

function Armature:initNormalEqus()
    local normalInfo = getAnimEquInfo(self:getRealName(), "normal")
    if not normalInfo then return end

    -- hide head bones
    local hideList = normalInfo["hide"]
    self:hideBones(hideList)

    local showList = normalInfo["show"]
    self:showBones(showList)
end
--[[

切换翅膀
windid: 翅膀配置ID
bonename={"Effect/effect_nan_wing", 20, 0 ,1.5}
]]
function Armature:switchWing(wingId)
    if not wingId then return end

    local bone = self:getBone("wing")
    if not bone then 
        printf("[WARNING] There is no bone of wing of wing_id: %d",wingId)
        return self 
    end

    if self.wingId and self.wingId == wingId then 
        return 
    end 
    if not tolua.isnull(self.wingArma) then 
        self.wingArma:removeFromParent()
        self.wingArma = nil 
    end 
    self.wingId = wingId 
    local info = table.getsub(t_anim_equ, self:getRealName(), "wing", wingId) or {}
--    dump(info)
    if not info or not info.res or not info.res.bonename then 
        return 
    end 
    local bonename = info.res.bonename

    local wingArmature = Armature.new(bonename[1]):play("run"):pos(bonename[2], bonename[3])
    wingArmature:setScale(bonename[4] or 1)
    self.wingArma = wingArmature
    
    bone:getCCDisplay():setCascadeOpacityEnabled(true)
    bone:getCCDisplay():setCascadeColorEnabled(true)
    bone:getCCDisplay():addChild(wingArmature, -1)

    -- hide bones
    self:hideBones(info.hide)

    return self
end

--[[--

registerAnimationEventHandler(function(info) end)
"<var>" = {
    "animationName"   = "attack_1"
    "armature"        = userdata: 0x07ff5398
    "armatureNode"    = userdata: 0x075d4c40
    "frameLabel"      = ""
    "isLastAnimation" = true
    "type"            = 7
}

动作事件回调(如动作结束回调)
sample:
    local function onAnimationEventInner(info)
        if movementType == Armature.MovementEventType.COMPLETE or movementType == Armature.MovementEventType.LOOP_COMPLETE then
            -- do somethings
        end
    end
    armature:setMovementEventCallFunc(onAnimationEventInner)

]]
function Armature:setMovementEventCallFunc(func)
    self:registerAnimationEventHandler(func)
    return self
end

--[[--

registerFrameEventHandler(function(info) end)
"<var>" = {
    "animationName"   = "attack_1"
    "armature"        = userdata: 0x08773af8
    "armatureNode"    = userdata: 0x08772e98
    "boneName"        = "wuyaowang_youshou"
    "frameLabel"      = "attack"
    "isLastAnimation" = true
    "type"            = 2
}

帧事件回调(如attack..)
sample:
    -- obj：回调对象
    -- eventType: 事件类型
    -- movementId: 播放的动作名称
    -- frameLabel: 回调标签(pre / attack)
    -- currentIndex: 当前帧
    local function setFrameEventCallFunc(info)
        if info.frameLabel == "attack" then
            -- do somethings
        end
    end
    node:setFrameEventFunc(frameCallback)

]]
function Armature:setFrameEventCallFunc(func)
    self:registerFrameEventHandler(func)
    return self
end

-- 注销frameevent
function Armature:removeFrameEventCallFunc()
    self:unregisterFrameEventHandler()
    return self
end

--[[--

设置动画回调，动画结束时调用

sample:
    local function effectCallback(armature)
        armature:removeSelf()
    end
    Armature.new("Effect/effect_beizhenyanmingzhon")
        :addTo(__entity)
        :pos(0, 0)
        :play(ACTION.ACT_RUN)
        :setAnimationEvent(ACTION.ACT_RUN, effectCallback)
]]
function Armature:setAnimationEvent(eventName, func)
    if not self.animFuncs then self.animFuncs = {} end
    self.animFuncs[eventName] = func

    return self
end

function Armature:setLoopEndEvent(eventName, func)
    if not self.loopAnimFunc then self.loopAnimFunc = {} end
    self.loopAnimFunc[eventName] = func
    return self
end

--[[--

获取实际使用的名称

]]
function Armature:getRealName()
    local name = self.filename --self:getName()
    local pos = string.find(name, "_")
    if pos then
        return string.sub(name, 0, pos - 1)
    end
    return self.filename
end

--[[--

播放动画
animName: 动作名称
loop: 1 无限循环, -1 根据配置

]]
function Armature:play(animName, loop)
    local loop = loop or -1
    if loop == 1 then loop = 0 end

    -- 没有时默认播放第一个动作
    if not self:isContainMovement(animName) then
        self:getAnimation():play()
    else
        self:getAnimation():gotoAndPlay(animName, -1, -1, loop)
    end
    self._movementID = animName

    if self:getArmatureEffect() then
        if self:getArmatureEffect():isContainMovement(animName) then
            self:getArmatureEffect():setVisible(true)
            self:getArmatureEffect():getAnimation():gotoAndPlay(animName, -1, -1, loop)
        else
            self:getArmatureEffect():setVisible(false)
        end
    end

    return self
end

--[[--

支持外部播放多段动画

actname: 动作名称
loop: 可不填

important: 不要在战斗中使用!!!!

]]
function Armature:playExt(actname, loop, callback)
    print("actname",actname)
    -- 不做空判断，没有就直接抛错
    local realname = self:getRealName()
    print("realname",realname)
    local actinfo = table.getsub(t_anim,realname,actname) or {}
    print("actinfo",table.tostring(actinfo))
    --assert(actinfo)

    -- 没有多段，直接播放
    local nextact = actinfo["next_act"]
    if not nextact then
        self:play(actname, loop)
        self:registerAnimationEventHandler(function(info)
            if info.type == Armature.MovementEventType.COMPLETE then
               if callback then callback() end
            end
        end)
        return self
    end

    local function _play(armature, act)
        if not actinfo or not actname then
            if callback then callback() end
            return
        end

        local playtime = actinfo["play_time"]
        armature:play(act, playtime)

        if nextact then
            actinfo = t_anim[realname][nextact]
            actname = nextact
            nextact = actinfo["next_act"]
        else
            actinfo = nil
            actname = nil
        end
    end

    -- callback
    self:registerAnimationEventHandler(function(info)
        --
        if info.type == Armature.MovementEventType.COMPLETE then
            _play(self, actname)
        end
    end)
    _play(self, actname)

    return self
end

--[[--

获取当前播放的动作名称

]]
function Armature:getCurrentMovementID()
    --assert(self._movementID)
    return self._movementID
end

--[[--

暂停动画

]]
function Armature:stop()
    self:getAnimation():stop()
    return self
end

--[[--

镜像
-- value: true or false

]]
function Armature:setFlippedX(value)
    if value == true then
        self:setRotationSkewY(180)
    else
        self:setRotationSkewY(0)
    end
    -- if self:getArmatureEffect() then
    --     self:getArmatureEffect():setFlippedX(value)
    -- end

    return self
end

--[[--

return true: 镜像 false:无镜像

]]
function Armature:isFlipX()
    return self:getRotationSkewY() == 180
end

--[[--

暂停
简化接口

]]
function Armature:pause()
    self:getAnimation():stop()
    if self:getArmatureEffect() then
        self:getArmatureEffect():pause()
    end
    return self
end

function Armature:pauseNode()
    local func = tolua.getcfunction(self, "pause")
    if func then
        func(self)
    end

    return self
end

--[[--

恢复暂停
简化接口

]]
function Armature:resume()
    self:getAnimation():play()
    if self:getArmatureEffect() then
        self:getArmatureEffect():resume()
    end
    return self
end

function Armature:resumeNode()
    local func = tolua.getcfunction(self, "resume")
    if func then
        func(self)
    end
    return self
end

function Armature:isPlaying()
    return self:getAnimation():getIsPlaying()
end

--[[--

显示骨骼

]]
function Armature:showBone(boneName)
    local bone = self:getArmature():getCCSlot(boneName)
    if bone then
        bone:setVisible(true)
    end
    return self
end

--[[--

隐藏骨骼

]]
function Armature:hideBone(boneName)
    local bone = self:getArmature():getCCSlot(boneName)
    if bone then
        bone:setVisible(false)
    end
    return self
end

--[[--


]]
function Armature:showBones(boneNames)
    local boneNames = boneNames or {}
    for _,v in ipairs(boneNames) do
        self:showBone(tostring(v))
    end
end

--[[--


]]
function Armature:hideBones(boneNames)
    local boneNames = boneNames or {}
    for _,v in ipairs(boneNames) do
        self:hideBone(tostring(v))
    end
end

--[[--

获取骨骼

]]
function Armature:getBone(boneName)
    assert(boneName)
    return self:getArmature():getCCSlot(boneName)
end

--[[--

切换装备
equType: 装备类型
Armature.EQU_WEAPON1 = "weapon1"  -- 主手武器
Armature.EQU_WEAPON2 = "weapon2"  -- 副手武器
Armature.EQU_HEAD    = "head"     -- 头部

equID: 装备ID

sample:
    -- 更换主手武器
    armature:switchEquipment(Armature.EQU_WEAPON1, 102)
    -- 更换副手武器
    armature:switchEquipment(Armature.EQU_WEAPON2, 102)
    -- 切换完成后要播放一次动画进行骨骼修正
    armature:play("stand")

]]
function Armature:switchEquipment(equType, equID)
    if not equType then return end
    if (equType == Armature.EQU_WEAPON1) or (equType == Armature.EQU_WEAPON2) then
        if not equID then return end
        return self:switchWeapon(equType, equID)
    elseif equType == Armature.EQU_HEAD then
        return self:switchHead(equID)
    elseif equType == Armature.EQU_WING then
        return self:switchWing(equID)
    end
end

--[[--

切换头部
id: 头部ID，如果id为nil则直接隐藏头盔

统一调用switchEquipment接口

]]
function Armature:switchHead(id)
    self.head = id
    if not id then
        return
    end

    -- 是否有换装
    local isChanged = false

    local equInfos = t_anim_equ[self:getRealName()]
    if not equInfos then return end
    local headInfo = equInfos["head"]
    if not headInfo then return end
    if not headInfo[id] then return end

    -- hide head bones
    local hideList = headInfo[id]["hide"]
    local hideList = hideList or {}

    for _,v in ipairs(hideList) do
        self:hideBone(tostring(v))
    end

    -- show head bones
    local showList = headInfo[id]["show"]
    local showList = showList or {}
    for _,v in ipairs(showList) do
        self:showBone(tostring(v))
    end

    local res = headInfo[id]["res"]
    if not res then return end
    local bone = nil
    for k,v in pairs(res) do
        bone = self:getArmature():getCCSlot(tostring(k))
        if bone and v[1] and v[1]~="" then
            local toukuifile = getFullName("Weapon/" .. v[1], ".png")
            local skin = display.newSprite(toukuifile)
            -- important custom retain
            skin:retain()
            assert(skin, "Armature:switchHead skin is nil")

            local imgSize = skin:getContentSize()
            local x = v[2] or 0
            local y = v[3] or 0

            local scale = 0.85
            local newAnchorX = (-x) * scale / imgSize.width
            local newAnchorY = 1 - (-y) * scale / imgSize.height
            print(newAnchorX, newAnchorY)

            skin:setAnchorPoint(cc.p(newAnchorX, newAnchorY))

            bone:setVisible(true)
            bone:setDisplayImage(skin)

            isChanged = true
        end
    end

    -- effect addEffectBone(targetName, effectFileName, x, y, scale, zorder, act)
    local effectList = headInfo[id]["effect"] or {}
    for _,v in ipairs(effectList) do
        self:addEffectBone(v[1], v[2], v[3], v[4], v[5], v[6], v[7])
    end

    return isChanged
end

--[[--

切换武器
weaponType: 主副手武器
weaponID: 武器ID

统一调用switchEquipment接口

important: switchWeapon后调用一次play(xx)播放动画

]]
function Armature:switchWeapon(weaponType, weaponID)
    if not weaponType or not weaponID then return end

    local equInfos = t_anim_equ[self:getRealName()]
    if not equInfos then return end

    -- 是否有换装
    local isChanged = false

    if weaponType and weaponID and type(weaponID)=="number" then
        if not equInfos[weaponType] then return end
        local weaponInfos = equInfos[weaponType][weaponID]
        if weaponInfos then
            local hideList = weaponInfos["hide"]
            local resList = weaponInfos["res"]
            local bone = nil

            -- 保留武器信息
            if not self.weapons then self.weapons = {} end
            self.weapons[weaponType] = weaponID

            --[[
            switch weapon
                res={ 1=武器资源, 2=武器x轴偏移, 3=武器y轴偏移, 4=zorder, 5=rotation）}
            ]]
            local resList = resList or {}
            for k,v in pairs(resList) do
                bone = self:getBone(k)
                if bone then
                    local weaponfile = getFullName("Weapon/" .. v[1], ".png")
                    local skin = display.newSprite(weaponfile)
                    skin:retain()
                    assert(skin, "Armature:switchWeapon skin is nil")

                    bone:setVisible(true)
                    bone:setDisplayImage(skin)

                       -- setpostion
                    local x,y = v[2],v[3]
                    if x and y then
                        bone:setOffset(x, y)
                    end

                    -- set zorder
                    local zorder = v[4] or 0
                    if zorder > 0 then
                        bone:setZOrder(zorder*100)
                    end

                    -- set rotation
                    local rotation = v[5] or nil
                    if rotation then
                        bone:setRotation(math.angle2radian(rotation))
                    end

                    -- 绑定特效
                    local effectList = v[6]
                    if effectList then
                        self:addEffectBone(effectList[1], effectList[2], effectList[3], effectList[4], effectList[5], effectList[6], effectList[7], effectList[8])
                    end

                    isChanged = true
                end
            end

            -- hide weapon bones
            local hideList = hideList or {}
            for _,v in ipairs(hideList) do
                self:hideBone(tostring(v))
            end
        end
    end
    return isChanged
end

--[[--

隐藏武器

]]
function Armature:hideWeapon(weaponType)
    if Armature.EQU_WEAPON1 == weaponType then
        self:hideBone("wuqi1")
    elseif Armature.EQU_WEAPON2 == weaponType then
        self:hideBone("wuqi2_1")
        self:hideBone("wuqi2_2")
    end

    return self
end

--[[--

切换衣服
由于元件过多，这里直接替换新的动画文件

id: 衣服ID
armature: 要换衣服的动画
frameCallback:
animationCallback: 动画回调

sample:
    self.armature = Armature.new("niutouren")
    self.armature:pos(300, 300)
    self:addChild(self.armature)

    -- switch clothes
    local newer = Armature.switchClothes(101304, self.armature)
    if newer then
        self.armature = nil
        self.armature = newer
    end

套装特效：
effect={{"图层名","特效名", nil, nil, nil, nil, "run"}, {"图层名","特效名", nil, nil, nil, nil, "run2"}, }

]]
function Armature.switchClothes(id, armature, animationCallback, frameCallback)
    if not armature or not id then return nil end

    local equInfos = t_anim_equ[armature:getRealName()]
    if not equInfos then return nil end
    local clothesRes = equInfos["clothes"]
    if not clothesRes then return nil end

    local res = table.getsub(clothesRes,id,"res",1)
    if not res then return nil end

    -- 创建新的动画
    local newArmature = Armature.new(res)
    if not newArmature then return nil end

    -- 显示，隐藏部件
    local hideList = clothesRes[id]["hide"] or {}
    for _,v in ipairs(hideList) do
        newArmature:hideBone(tostring(v))
    end

    -- show
    local showList = clothesRes[id]["show"] or {}
    for _,v in ipairs(showList) do
        newArmature:showBone(tostring(v))
    end

    -- effect addEffectBone(targetName, effectFileName, x, y, scale, zorder, act)
    local effectList = clothesRes[id]["effect"] or {}
    for _,v in ipairs(effectList) do
        newArmature:addEffectBone(v[1], v[2], v[3], v[4], v[5], v[6], v[7])
    end

    -- 记录父节点、坐标、武器等信息
    local parent = armature:getParent()
    local x,y = armature:getPositionX(), armature:getPositionY()
    local weapons = armature.weapons
    local color = armature:getColor()
    local scale = armature:getScale()
    local isflipx = armature:isFlipX()
    local head = armature.head
    local wingId = armature.wingId 

    -- 属性
    newArmature:pos(x, y)
    newArmature:setColor(color)
    newArmature:setScale(scale)
    newArmature:addTo(parent)
    -- 转向
    if isflipx == true then
        newArmature:setRotationSkewY(180)
    else
        newArmature:setRotationSkewY(0)
    end

    -- 绑定回调
    if animationCallback then
        newArmature:registerMovementEventHandler(animationCallback)
    end
    if frameCallback then
        newArmature:registerFrameEventHandler(frameCallback)
    end

    if armature.animFuncs then
        newArmature.animFuncs = armature.animFuncs
    end

    -- 切换武器
    if weapons then
        for k,v in pairs(weapons) do
            newArmature:switchWeapon(k, v)
        end
    end
    -- 切换头盔
    if head then
        newArmature:switchHead(head)
    end
    -- 切换翅膀
    if wingId then
        newArmature:switchWing(wingId)
    end

    -- 动作
    local movID = armature:getCurrentMovementID()
    if movID then
        newArmature:play(movID)
    end

    armature:removeFromParentAndCleanup(true)

    return newArmature
end

--[[

获取动作总时间

return 实际时间（秒）

]]
function Armature:getRealMovTime(movName)
    local frames = self:getAnimation():getMovTime(movName)
    if frames > 0 then
        return frames / Armature.FLASH_FPS
    end
    return frames
end

--[[--

override showShaderEffect method

]]
function Armature:showShaderEffect(effectName, params)
    if not effectName then return end
    local hasalpha = self:getHasAlpha()
    local alphaTextureID = self:getAlphaTextureID()
    local filterState = Node.getEffectState(effectName, params, hasalpha, alphaTextureID)
    assert(filterState)
    self:setGLProgramState(filterState)
    return self
end

--[[--

显示各种效果
effectName: 效果名称， 如 "GRAY"
params: 效果参数

sample:
    armature:showShaderEffect("ColorBalance", {u_colorRGB = {60, 60, 10}, u_highlight = 1.4,})

]]
function Armature:setGLProgramState(state)
    assert(state)
    self:setEffectState(state)
end

--[[--

隐藏图像效果

]]
function Armature:resetShaderEffect()
    self:setEffectState(nil)

    return self
end

--[[--

添加特效节点，如武器上绑定光效等

]]
function Armature:addEffectBone(targetName, effectFileName, x, y, scale, zorder, act, flipx)
    local bone = self:getBone(targetName)
    if (not targetName) or (not effectFileName) or (not bone) then return end

    local x = x or 0
    local y = y or 0
    local scale = scale or 1
    local zorder = zorder or 100

    local effectArmature = Armature.new(effectFileName)
    if not effectArmature then return end

    -- play run时候会将bone移除，这里retain多一次做保存
    ArmaturePool.retain(effectArmature:getRealFileName(), effectArmature:getAlphaTextureName())

    if act then
        effectArmature:play(act)
    else
        effectArmature:getAnimation():play()
    end
    print(targetName, act, flipx)

    if flipx then
       print("flistx....", flipx)
       effectArmature:setFlippedX(flipx)
    end

    -- 获取武器图片的大小
    local size = bone:getCCDisplay():getContentSize()
    effectArmature:setAnchorPoint(cc.p(0.5, 0.5))
    effectArmature:pos(size.width * 0.5 + x, size.height * 0.5 + y)

    bone:getCCDisplay():setCascadeOpacityEnabled(true)
    bone:getCCDisplay():setCascadeColorEnabled(true)
    
    bone:getCCDisplay():addChild(effectArmature)

    return self
end

--[[--

是否包含指定动作
return true or false

]]
function Armature:isContainMovement(actName)
    return self:getAnimation():hasAnimation(actName)
end

--[[--

]]
function Armature:getContentSize()
    local bb = self:getBoundingBox()
    return cc.size(bb.width, bb.height)
end

--[[--

设置播放速度，直接传递播放倍率即可

]]
function Armature:setSpeed(value)
    self:getAnimation():setTimeScale(value)
    if self:getArmatureEffect() then
        self:getArmatureEffect():setSpeed(value)
    end

    return self
end

function Armature:getSpeed()
    return self:getAnimation():getTimeScale()
end

function Armature.addEffectTexture(realName)
    local shortname = "Models/" .. getRealShortFileName(realName)
    local imgName = shortname .. "_effect.pvr.ccz"
    local pngImgName = shortname .. "_effect.png"
    local plistName = shortname .. "_effect.plist"
    local alphaPng = shortname .. "_effect_alpha.png"

    if cc.FileUtils:getInstance():isFileExist(pngImgName) then
        display.addSpriteFrames(plistName, pngImgName)
        ResourceManager.addUnremoveTexture(alphaPng)
    elseif cc.FileUtils:getInstance():isFileExist(imgName) then
        display.addSpriteFrames(plistName, imgName)
        ResourceManager.addUnremoveTexture(alphaPng)
    end
end

function Armature:onEnter()
    ArmaturePool.retain(self:getRealFileName(), self:getAlphaTextureName())
end

function Armature:onExit()
    ArmaturePool.release(self:getRealFileName())
end

--[[--

添加点击事件

callback: 点击回调 event: began, moved, ended, cancelled
bb: 指定boudingBox

]]
function Armature:addTouch(callback, bb)
    self:setTouchEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        -- event.name 是触摸事件的状态：began, moved, ended, cancelled
        -- event.x, event.y 是触摸点当前位置
        -- event.prevX, event.prevY 是触摸点之前的位置
        printInfo("armature: %s x,y: %0.2f, %0.2f",event.name, event.x, event.y)

        -- 在 began 状态时，如果要让 Node 继续接收该触摸事件的状态变化
        -- 则必须返回 true
        if callback then callback(event.name) end
        if event.name == "began" then
            return true
        end
    end)

    return self
end

--clickLayout锚点设置为（0,0），默认位置为（0,0）
--params.clickRgnOffset: 点击区域的位置偏移（手动设置校准点击区域不精确的情况）
--params.customClickRngSize: 自定义点击区域的尺寸（默认使用Armature的尺寸）
--params.visibleClickRgnEnabled: 是否显示点击区域（方便调试设置点击区域偏移）
function Armature:addTouchEventListenerExt(callback,params)
    local params = params or {}
    if not self.clickLayout then
        local clickLayout = Layout:create()
        self:addChild(clickLayout)
        local size = self:getContentSize()
        clickLayout:setAnchorPoint(ccp(0,0))
        local pos = ccp(0,0)
        if params.clickRgnOffset then
            pos.x = pos.x + params.clickRgnOffset.x
            pos.y = pos.y + params.clickRgnOffset.y
        end
        clickLayout:setPosition(pos)
        if params.customClickRgnSize then
            clickLayout:setContentSize(params.customClickRngSize)
        else
            clickLayout:setContentSize(self:getContentSize())
        end
        clickLayout:setTouchEnabled(true)
        self.clickLayout = clickLayout
        if params.visibleClickRgnEnabled then
            local colorLayer = display.newColorLayer(ccc4(0,0,255,100))
            colorLayer:setContentSize(clickLayout:getContentSize())
            colorLayer:setAnchorPoint(ccp(0,0))
            colorLayer:setPosition(ccp(0,0))
            clickLayout:addChild(colorLayer)
        end
    end
    self.clickLayout:addTouchEventListener(function(sender,eventType)
        if callback then
            callback(self,eventType)
        end
    end)
end

--endregion
