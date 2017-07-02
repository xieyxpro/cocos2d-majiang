-- region NewFile_1.lua
-- Author : Administrator
-- Date   : 2015-1-13
-- 此文件由[BabeLua]插件自动生成

local ArmaturePool = {}

local dbFactory = db.DBCCFactoryExt:getInstance()

-- init unremovepool
local unremovePool = unremovePool or {}

-- 针对性优化
local needRemove = needRemove or {}
local objPool = objPool or {}
local chapterPool = chapterPool or {}
local armaturesAlphaPool = armaturesAlphaPool or {}

local inited = false

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

function ArmaturePool.init()
    if not inited then
        -- 主城、打击
        local uns = {
            "effect_xue"                   ,
            "effect_dianji"                ,
            "effect_fashigongjishouji"     ,
            "effect_lierenshouji"          ,
            "effect_niutourenshouji"       ,
            "effect_wugong"                ,
            "effect_main_fanshu"           ,
            "effect_jiazai"                ,
            "effect_heiying"               ,
            "effect_guochang"              ,
            "effect_ui_guochang"           ,
            "effect_smoke"                 ,
            "effect_ui_fight_shifarenwu"   ,
            "effect_ui_shijian"            ,
            "effect_ui_zdjs_jiesuan"       ,
            "effect_ui_jiesuan2"           ,
            "effect_ui_jiesuan_zc"         ,
            "effect_ui_jiesuan"            ,
            "effect_jiesuanshengliq"       ,
            "effect_ui_zdjs_shengli"       ,
            "effect_ui_zdjs_shibai"        ,
            "effect_tongyongchuchang"      ,
        }
        ArmaturePool.parseUnremoves(uns)

        inited = true
    end
end

function ArmaturePool.parseUnremoves(uns)
    local tbls = checktable(uns)
    for _,v in ipairs(tbls) do
        ArmaturePool.addUnremove(getRealFileName(v))    
    end
end

function ArmaturePool.updateUnremove(objName)
    if string.find(objName, "Effect")
    then
        -- is Effect? don't remove
        ArmaturePool.addUnremove(objName)
        return true
    end
end

function ArmaturePool.retain(objName, alphaName)
    ArmaturePool.init()

    -- unremove obj?
    if alphaName and alphaName ~= "" then
        armaturesAlphaPool[objName] = alphaName
    end

    if ArmaturePool.updateUnremove(objName) then
        return
    end

    if not objPool[objName] then
        objPool[objName] = 1
        return objPool[objName]
    end
    objPool[objName] = objPool[objName] + 1
    return objPool[objName]
end

function ArmaturePool.release(objName)
    if not objPool[objName] then return end
    objPool[objName] = objPool[objName] -1
    if objPool[objName] <= 0 then
        objPool[objName] = nil

        -- remove obj data..
        ArmaturePool.addNeedRemove(objName)
    end
    return objPool[objName]
end

function ArmaturePool.getCount(objName)
    return objPool[objName]
end

function ArmaturePool.getObjPool()
    return objPool
end

--[[--

]]
function ArmaturePool.addUnremove(objName)
    --print("addUnremove:", objName)
    if not unremovePool[objName] then
        unremovePool[objName] = 1

        ResourceManager.addUnremoveTexture(armaturesAlphaPool[objName])
        local texturename = objName .. "/texture.png"
        --print(texturename)
        ResourceManager.addUnremoveTexture(texturename)
        local textureAlphaName = objName .. "/texture_alpha.png"
        ResourceManager.addUnremoveTexture(textureAlphaName)
        
        return unremovePool[objName]
    end
end

function ArmaturePool.getUnremove(objName)
    return unremovePool[objName]
end

function ArmaturePool.delUnremove(objName)
    ResourceManager.delUnremoveTexture(armaturesAlphaPool[objName])
    local texturename = objName .. "/texture.png"
    ResourceManager.delUnremoveTexture(texturename)
    local textureAlphaName = objName .. "/texture_alpha.png"
    ResourceManager.delUnremoveTexture(textureAlphaName)    

    ArmaturePool.addNeedRemove(objName)
    unremovePool[objName] = nil
end

function ArmaturePool.removeObj(objName)
    if ArmaturePool.getUnremove(objName) then
        return
    end

    -- 战斗过程中保留并放在推出的时候释放
    if GlobalCache.PlayerCache.curScene == GAME_SCENE_TYPE.BATTLE_SCENE or 
        GlobalCache.PlayerCache.curScene == GAME_SCENE_TYPE.CUSTOM_SCENE then
        ArmaturePool.addNeedRemove(objName)
        return
    end

    print("ArmaturePool removeObj:", objName)
    dbFactory:removeTextureAtlas(objName, true)
    dbFactory:removeDragonBonesData(objName, true)

    ResourceManager.addUnremoveTexture(armaturesAlphaPool[objName])
end

-- 延时移除
function ArmaturePool.addNeedRemove(objName)
    if not needRemove then needRemove = {} end
    if not needRemove[objName] then
        needRemove[objName] = 1
    end
end

function ArmaturePool.delNeedRemove(objName)
    if needRemove[objName] then
        needRemove[objName] = nil
    end
end

function ArmaturePool.dumpNeedRemoves()
    dump(needRemove)
end

-- 关卡做资源优化处理
function ArmaturePool.addChapterRes(chapterID, objName)
    if not chapterPool then chapterPool = {} end
    if not chapterPool[chapterID] then chapterPool[chapterID] = {} end
    if chapterPool[chapterID][objName] then return end
    chapterPool[chapterID][objName] = 1

    -- add to unremove
    print("ArmaturePool.addChapterRes", objName)
    ArmaturePool.addUnremove(objName)
end

-- 战斗结束的时候做处理
function ArmaturePool.removeChaptersExceptID(chapterID)
    for k, v in pairs(chapterPool) do
        if k ~= chapterID then
            -- 同时不属于主角
--            local heroInfos = { }
--            for _, cv in pairs(HerosCache.heros) do
--                local attr = HerosCache:getHero(cv.id):getTotalAttri()
--                if attr and attr.animFile then
--                    heroInfos[attr.animFile] = 1
--                end
--            end
--            for cck, ccv in pairs(v) do
----                if not heroInfos[cck] then
--                    ArmaturePool.delUnremove(cck)
----                    Armature.removeRes(cck, false, true)
--                    print(cck)
----                end
--            end

            for cck, ccv in pairs(v) do
                ArmaturePool.delUnremove(cck)
                print(cck)
            end

            chapterPool[k] = nil
        end
    end
end

function ArmaturePool.removeUnusedArmatures()
    print("Unremove Armatures...")
    for k,v in pairs(needRemove) do
        if (not ArmaturePool.getCount(k)) or (ArmaturePool.getCount(k) <= 0) then
            ArmaturePool.removeObj(k)
        end
    end
    needRemove = {}    
end

function ArmaturePool.removeAll()
    ArmaturePool.removeUnusedArmatures()
    for k,v in pairs(objPool) do
        ArmaturePool.removeObj(k)
    end

    objPool = {}
    needRemove = {}
    objPool = {}
    chapterPool = {}
    armaturesAlphaPool = {}
end

return ArmaturePool

-- endregion
