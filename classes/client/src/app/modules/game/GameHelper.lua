--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local GameDefine = require("app.modules.game.GameDefine")

local GameHelper = {}

function GameHelper.decorateCardImgWithSpecialMark(imgCard, cardVal, dir, markValues)
    markValues = markValues or GameCache
    local path = ""
    if dir == GameDefine.DIR_LEFT then 
        path = "GameScene/left/"
    elseif dir == GameDefine.DIR_TOP then 
        path = "GameScene/vertical/"
    elseif dir == GameDefine.DIR_RIGHT then 
        path = "GameScene/right/"
    elseif dir == GameDefine.DIR_BOTTOM then 
        path = "GameScene/vertical/"
    end 
    local spMark
    if cardVal == markValues.laiZiCardVal then 
        spMark = cc.Sprite:create(path .. "bg-handmah_lai.png")
    -- elseif cardVal == markValues.laiZiPiCardVal then 
    --     spMark = cc.Sprite:create(path .. "bg-handmah_pi.png")
    -- elseif cardVal == markValues.hongZhongCardVal then 
    --     spMark = cc.Sprite:create(path .. "bg-handmah_gang.png")
    else 
        return
    end 
    imgCard:addChild(spMark)
    imgCard:setAnchorPoint(cc.p(0.5, 0.5))
    local sz = imgCard:getContentSize()
    spMark:setPosition(cc.p(sz.width * 0.5, sz.height * 0.5))
end 

function GameHelper.decorateCardImgWithHuMark(imgCard, cardVal, dir)
    local path = ""
    if dir == GameDefine.DIR_LEFT then 
        path = "GameScene/left/"
    elseif dir == GameDefine.DIR_TOP then 
        path = "GameScene/vertical/"
    elseif dir == GameDefine.DIR_RIGHT then 
        path = "GameScene/right/"
    elseif dir == GameDefine.DIR_BOTTOM then 
        path = "GameScene/vertical/"
    end 
    local spMark = cc.Sprite:create(path .. "bg-handmah_hu.png")

    imgCard:addChild(spMark)
    imgCard:setAnchorPoint(cc.p(0.5, 0.5))
    local sz = imgCard:getContentSize()
    spMark:setPosition(cc.p(sz.width * 0.5, sz.height * 0.5))
end 

function GameHelper.decorateCardImgWithSpecialMarkFlat(imgCard, cardVal, dir, markValues)
    markValues = markValues or GameCache
    local path = ""
    if dir == GameDefine.DIR_LEFT then 
        path = "GameScene/left/"
    elseif dir == GameDefine.DIR_TOP then 
        path = "GameScene/vertical/"
    elseif dir == GameDefine.DIR_RIGHT then 
        path = "GameScene/right/"
    elseif dir == GameDefine.DIR_BOTTOM then 
        path = "GameScene/vertical/"
    end 
    local spMark
    if cardVal == markValues.laiZiCardVal then 
        if dir == GameDefine.DIR_TOP then 
            spMark = cc.Sprite:create(path .. "bg-handmah_lai.png")
        else
            spMark = cc.Sprite:create(path .. "bg-mingmah_lai.png")
        end
    elseif cardVal == markValues.laiZiPiCardVal then 
        -- if dir == GameDefine.DIR_TOP then 
        --     spMark = cc.Sprite:create(path .. "bg-handmah_pi.png")
        -- else
        --     spMark = cc.Sprite:create(path .. "bg-mingmah_pi.png")
        -- end
    -- elseif cardVal == markValues.hongZhongCardVal then 
    --     if dir == GameDefine.DIR_TOP then 
    --         spMark = cc.Sprite:create(path .. "bg-handmah_gang.png")
    --     else
    --         spMark = cc.Sprite:create(path .. "bg-mingmah_gang.png")
    --     end
    else 
        return
    end 
    imgCard:addChild(spMark)
    imgCard:setAnchorPoint(cc.p(0.5, 0.5))
    local sz = imgCard:getContentSize()
    spMark:setPosition(cc.p(sz.width * 0.5, sz.height * 0.5))
end 

function GameHelper.decorateCardImgWithHuMarkFlat(imgCard, cardVal, dir)
    local path = ""
    if dir == GameDefine.DIR_LEFT then 
        path = "GameScene/left/"
    elseif dir == GameDefine.DIR_TOP then 
        path = "GameScene/vertical/"
    elseif dir == GameDefine.DIR_RIGHT then 
        path = "GameScene/right/"
    elseif dir == GameDefine.DIR_BOTTOM then 
        path = "GameScene/vertical/"
    end 
    local spMark = cc.Sprite:create(path .. "bg-mingmah_hu.png")

    imgCard:addChild(spMark)
    imgCard:setAnchorPoint(cc.p(0.5, 0.5))
    local sz = imgCard:getContentSize()
    spMark:setPosition(cc.p(sz.width * 0.5, sz.height * 0.5))
end 

return GameHelper
--endregion
