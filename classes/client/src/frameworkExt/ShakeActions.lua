--region ShakeActions.lua
--Author : admin
--Date   : 2015/3/10
--此文件由[BabeLua]插件自动生成

local ShakeActions = {}

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local ShakeAction = require("app.module.public.ShakeAction")

--[[--
    晃动基本函数
]]
--记录晃动对象初始位置
--local obj_pos = {}
--local function commonShake(obj, info, action)
--    --保存初始位置
--    local ACTION_TAG = 2028
--    if obj[1]:getNumberOfRunningActions() == 0 then
--        local x,y = obj[1]:getPosition()
--        --print(x..","..y)
--        local startPostion = cc.p(x, y)
--        obj_pos[1] = {1, startPostion}
--        if #obj == 2 then
--            if obj[2]:getNumberOfRunningActions() == 0 then
--                x,y = obj[2]:getPosition()
--                startPostion = cc.p(x, y)
--                obj_pos[2] = {2, startPostion}
--            end
--        end
--    end
--    --震动
--    local repeataction = cc.Repeat:create(
--            cc.Sequence:create(action,cc.DelayTime:create(info.delaytime)),info.times
--            )
--    repeataction:setTag(ACTION_TAG)

--    --背景层 先暂停 再执行动作(避免移位)
--    if obj[1]:getNumberOfRunningActions() ~= 0 then
--        obj[1]:stopActionByTag(ACTION_TAG)
--        obj[1]:setPosition(obj_pos[1][2])
--        --local m,n = obj[1]:getPosition()
--        --print(m..","..n)
--    end
--    obj[1]:runAction(repeataction)

--    --背景层和人物层震动
--    if #obj == 2 then
--        --人物层 先暂停
--        if obj[2]:getNumberOfRunningActions() ~= 0 then
--            obj[2]:stopActionByTag(ACTION_TAG)
--            obj[2]:setPosition(obj_pos[2][2])
--            --local m,n = obj[2]:getPosition()
--            --print(m..",,"..n)
--        end
--        local action_clone = repeataction:clone()
--        action_clone:setTag(ACTION_TAG)
--        obj[2]:runAction(action_clone)
--    end
--end

--[[--
--水平晃动
parama obj : 要晃动的对象
parama info : 晃动参数,包括 
                info.shaketime 晃动时间
                info.times 晃动次数
                info.delaytime 两次晃动间隔
                info.strenth_x 水平方向晃动振幅        
]]
function ShakeActions.shakeHorizontal(obj, info, flag)
    --assert(type(obj)=="table", "info should be a table")
    assert(type(info)=="table", "info should be a table")
    obj.shakeAction:startAction(ShakeAction.NONE, info.shaketime, {x=info.strenth_x,y=0})
    if flag == 2 then
        obj.shakeEntity:startAction(ShakeAction.NONE, info.shaketime, {x=info.strenth_x,y=0})
    end
    --local action = cc.Shake:createWithStrength(info.shaketime, info.strenth_x, 0)
    --commonShake(obj, info, action, flag)
end

--垂直晃动
--[[--
parama obj : 要晃动的对象
parama info : 晃动参数,包括 -
                info.shaketime 晃动时间
                info.times 晃动次数
                info.delaytime 两次晃动间隔
                info.strenth_y 垂直方向晃动振幅  
]]
function ShakeActions.shakeVertical (obj, info, flag)
    assert(type(obj)=="table", "info should be a table")
    assert(type(info)=="table", "info should be a table")
    obj.shakeAction:startAction(ShakeAction.NONE, info.shaketime, {x=0,y=info.strenth_y})
    if flag == 2 then
        obj.shakeEntity:startAction(ShakeAction.NONE, info.shaketime, {x=0,y=info.strenth_y})
    end    
end

--随机晃动
--[[--
parama obj : 要晃动的对象
parama info : 晃动参数,包括 
                info.shaketime 晃动时间
                info.times 晃动次数
                info.delaytime 两次晃动间隔
                info.strenth_x 随机振幅下限
                info.strenth_y 随机振幅上限
]]
function ShakeActions.shakeRandom (obj, info, flag)
    assert(type(obj)=="table", "info should be a table")
    assert(type(info)=="table", "info should be a table")
    local sx = info.strenth_x + math.random(info.strenth_y - info.strenth_x)
    local sy = info.strenth_x + math.random(info.strenth_y - info.strenth_x)
    obj.shakeAction:startAction(ShakeAction.NONE, info.shaketime, {x=sx,y=sy})
    if flag == 2 then
        obj.shakeEntity:startAction(ShakeAction.NONE, info.shaketime, {x=sx,y=sy})
    end
end

--大晃动
--[[--
parama obj : 要晃动的对象
parama info : 晃动参数,包括 
                info.shaketime 晃动时间
                info.times 晃动次数
                info.delaytime 两次晃动间隔
                info.strenth_x 水平方向晃动振幅
                info.strenth_y 垂直方向晃动振幅   
]]
function ShakeActions.shakeSharply (obj, info)
    assert(type(obj)=="table", "info should be a table")
    assert(type(info)=="table", "info should be a table")
    obj.shakeAction:startAction(ShakeAction.NONE, info.shaketime, {x=info.strenth_x,y=info.strenth_y})
    if flag == 2 then
        obj.shakeEntity:startAction(ShakeAction.NONE, info.shaketime, {x=info.strenth_x,y=info.strenth_y})
    end
end

--小晃动
--[[--
parama obj : 要晃动的对象
parama info : 晃动参数,包括 
                info.shaketime 晃动时间
                info.times 晃动次数
                info.delaytime 两次晃动间隔
                info.strenth_x 水平方向晃动振幅
                info.strenth_y 垂直方向晃动振幅   
]]
function ShakeActions.shakeSlightly (obj, info)
    assert(type(obj)=="table", "info should be a table")
    assert(type(info)=="table", "info should be a table")
    obj.shakeAction:startAction(ShakeAction.NONE, info.shaketime, {x=info.strenth_x,y=info.strenth_y})
    if flag == 2 then
        obj.shakeEntity:startAction(ShakeAction.NONE, info.shaketime, {x=info.strenth_x,y=info.strenth_y})
    end
end

--穿帮晃动
--[[--
parama obj : 要晃动的对象
parama info : 晃动参数,包括 
                info.shaketime 晃动时间
                info.times 晃动次数
                info.delaytime 两次晃动间隔
                info.strenth_x 水平方向晃动振幅
                info.strenth_y 垂直方向晃动振幅   
]]
function ShakeActions.shakeGoof (obj, info)
    assert(type(obj)=="table", "info should be a table")
    assert(type(info)=="table", "info should be a table")
    obj.shakeAction:startAction(ShakeAction.NONE, info.shaketime, {x=info.strenth_x,y=info.strenth_y})
    if flag == 2 then
        obj.shakeEntity:startAction(ShakeAction.NONE, info.shaketime, {x=info.strenth_x,y=info.strenth_y})
    end
end

--红屏or黑屏
--[[--
parama node : 红/黑屏加到的节点
parama info : 红/黑屏透明度变化参数,透明度=A * |sin（W * t + C)|+D，包括 
               A是透明度最大值，W控制变化速度，C控制初始透明度 ,D调节总透明度
               参数T表示变化总时间  T=100表示1s
parama skillID : 记录触发红屏的技能ID,用于技能打断时停止红屏
]]

--暂停
local pause = false
--打断
local breakSkillID = 0
local breakeffect = false
--shakeColorEffect内部逻辑
local t,deleteID,max_time = 0,0,0    
local handle = nil
local effect_time = {}
local isLayerExist = false
local layercolor
local STOPSIGN = 8888888888
function ShakeActions.shakeColorEffect (node, info, skillID)
    assert(type(info)=="table", "info should be a table")
    assert(skillID,"技能ID无效")
    --强制结束红屏
    local function stopColorEffectSelf()
        if handle then
            scheduler.unscheduleGlobal(handle)
            handle = nil
        end
        effect_time = {}
        isLayerExist = false
        breakeffect = false
        t,deleteID,max_time = 0,0,0    
    end
    --节点不可用
    if tolua.isnull(node) then
        stopColorEffectSelf()
        return
    end

    --当前是否有已执行的红屏
    local LAYER_TAG = 1028
    table.insert(effect_time, {skillID, info.T})
    if not isLayerExist then
        layercolor = cc.LayerColor:create( cc.c4b(info.R,info.G,info.B,info.A) ):addTo(node, 9999, LAYER_TAG)
        max_time = info.T
        isLayerExist = true
    else
        table.sort(effect_time, function(a,b) return a[2]<b[2] end )
        if info.T > max_time then
            max_time = info.T
        end
        return
    end
    --红屏主循环
    local function changeColorAlpha() 
        if tolua.isnull(node) then
            stopColorEffectSelf()
            return
        end       
        --停止红屏        
        if breakeffect then
            --停止全部红屏
            if breakSkillID == STOPSIGN then 
                stopColorEffectSelf()
                node:removeChildByTag(LAYER_TAG)
                return
            end

            --停止指定id红屏
            for k,v in ipairs(effect_time) do
                if v[1] == breakSkillID then
                    deleteID = k                    
                end
            end
            if deleteID == 0 then breakeffect = false return end        
            table.remove(effect_time, deleteID)
            deleteID = 0
--            print(#effect_time)
            if #effect_time > 0 then
                max_time = effect_time[#effect_time][2] - 1
                t = t + 0.01
                for k,v in ipairs(effect_time) do
                    v[2] = v[2] - 1
                    if v[2] == 1 then
                        table.remove(effect_time, k)
                    end
                end
            else
                scheduler.unscheduleGlobal(handle)
                handle = nil
                node:removeChildByTag(LAYER_TAG)
                isLayerExist = false
                breakeffect = false
                return
            end
            breakeffect = false
        else
            if pause then return end
            --正常红屏
            local alpha = info.A * math.abs( math.sin( info.W * t + info.C ) ) + info.D
            if node:getChildByTag(LAYER_TAG) then
--                print("alpha".. math.floor(alpha))
                if not alpha then alpha = 0 end
                layercolor:setOpacity(alpha)
            else                                   
                if tolua.isnull(node) then
                    print("node null")
                    ShakeActions.stopAllColorEffect ()
                    return
                end
                layercolor = cc.LayerColor:create( cc.c4b(info.R,info.G,info.B,alpha) ):addTo(node, 9999, LAYER_TAG)
            end
            max_time = max_time - 1 
            t = t + 0.01
--            print(max_time)
            for k,v in ipairs(effect_time) do
                v[2] = v[2] - 1
--                print(k.."---"..v[1].."---"..v[2])
                if v[2] == 1 then
                    table.remove(effect_time, k)
                    --print("remove a kv")
                end
            end
            if  0 == max_time then
--                if handle then
--                    scheduler.unscheduleGlobal(handle)
--                    handle = nil
--                end
--                isLayerExist = false
                if node:getChildByTag(LAYER_TAG) then
                    node:getChildByTag(LAYER_TAG):removeFromParent()
                end
                stopColorEffectSelf()
                --return
            end
        end
    end
    handle = scheduler.scheduleGlobal(changeColorAlpha, 0.01, false)
end

function ShakeActions.stopColorEffectByID (skillID)
    assert(skillID,"技能ID无效")
    breakSkillID = skillID
    breakeffect = true
end

function ShakeActions.stopAllColorEffect ()
    if handle then
        breakSkillID = STOPSIGN
        breakeffect = true
    end
end

--暂停红屏
function ShakeActions.pauseColorEffect ()
    pause = true
end

--恢复红屏
function ShakeActions.resumeColorEffect ()
    pause = false
end

--技能换场景
--[[--
parama node : 场景加到的节点(原场景)
parama info : 地图资源 
              info.map_id 地图ID   info.time 技能持续时间
]]
local TAGBGLAYER = 1029
function ShakeActions.changeBattleScene (node, info)
    assert(type(info)=="table", "info should be a table")
    local parama_fadein = {R=0,G=0,B=0,A=255,W=1,C=0.52,D=0,T=50}
    ShakeActions.shakeColorEffect(node, parama_fadein, 16801)

    assert(type(t_map[info.map_id].res)=="string", "map_id error")
    if not tolua.isnull(node) then
        node:removeChildByTag(TAGBGLAYER)
        local fightBgLayer = display.newSprite(t_map[info.map_id].res):addTo(node, 10, TAGBGLAYER):pos(display.cx, display.cy)
    end

--    local handle_map = nil
--    local function regainBattleScene ()

--        if pause then return end
--        timer = timer + 0.01

--        if (timer - 0.38) >= 0 then
--            if not isAddScene then
--                print(timer.."addbg")
--                assert(type(t_map[info.map_id].res)=="string", "map_id error")
--                local fightBgLayer = display.newSprite(t_map[info.map_id].res):addTo(node, 10, TAGBGLAYER):pos(display.cx, display.cy)
--                isAddScene = true
--            else
--                if (timer - info.time + 0.38) >= 0 then
--                    if not isAddEffect then
--                        ShakeActions.shakeColorEffect(node, parama_fadeout, 16801)
--                        isAddEffect = true
--                    elseif (timer - info.time) >= 0 then
--                        --print(timer.."removebg")
--                        --移除地图
--                        isAddScene = false
--                        isAddEffect = false
--                        if handle_map then
--                            scheduler.unscheduleGlobal(handle_map)
--                            handle_map = nil
--                            return
--                        end
--                    end
--                end
--            end
--        end
--    end
--    handle_map = scheduler.scheduleGlobal(regainBattleScene, 0.01, false)
end

function ShakeActions.stopChangeBattleScene(node)
    if not tolua.isnull(node) then
        local parama_fadeout = {R=0,G=0,B=0,A=155,W=1,C=2.02,D=0,T=100}
        ShakeActions.shakeColorEffect(node, parama_fadeout, 16801)
        node:removeChildByTag(TAGBGLAYER)
        return
    end
end

--[[
特写 镜头拉近
parama node : {bg,entity}
parama info : delaytime 近景停留时长    k_scale 放大倍数    t_scale1 放大过程时间   t_scale2 缩小过程时间

]]
local isZooming,isPauseZoom = false, false
local pos_node1 = {}
local pos_node2 = {}
local handle_zoom = nil
local time_zooming = 0
function ShakeActions.cameraZoomInEffect (node, info, pos_x)
    assert(type(info)=="table", "info should be a table")
    --print(isZooming)
    if tolua.isnull(node[1]) and tolua.isnull(node[2]) then
        return
    end
    if isZooming then
        return
    else
        --记录初始信息
        isZooming = true
        pos_node1[1],pos_node1[2] = node[1]:getPosition()
        pos_node2[1],pos_node2[2] = node[2]:getPosition()
        --Scale
        local function visibleCallback(object)
            node[1]:setPosition(cc.p(display.cx,display.cy))
            node[2]:setPosition(cc.p(display.cx,display.cy))
        end
        --print("x is "..x)
        local offset = (1 - info.k_scale) * (pos_x or info.node_x - pos_node1[1])
        --print("offset is "..offset)
        local action1 = cc.Sequence:create(cc.ScaleTo:create(info.t_scale1, info.k_scale), cc.DelayTime:create(info.delaytime), cc.ScaleTo:create(info.t_scale2, 1))
        local action2 = cc.Sequence:create(cc.MoveBy:create(info.t_scale1, cc.p(offset, 0)),cc.DelayTime:create(info.delaytime), cc.MoveBy:create(info.t_scale2, cc.p(-offset, 0)), cc.CallFunc:create(visibleCallback))

        node[1]:runAction(action1)
        node[2]:runAction(action1:clone())
        node[1]:runAction(action2)
        node[2]:runAction(action2:clone())
        local time_zoomEffect = info.t_scale1 + info.delaytime + info.t_scale2
        local function Zooming()
            if isPauseZoom then            
                return
            else
                time_zooming = time_zooming + 0.01
                if (time_zooming - time_zoomEffect) > 0 then
                    isZooming = false
                    time_zooming = 0
                    pos_node1 = {}
                    pos_node2 = {}
                    if handle_zoom then
                        scheduler.unscheduleGlobal(handle_zoom)
                        handle_zoom = nil
                    end
                end
            end
        end    
        handle_zoom = scheduler.scheduleGlobal(Zooming, 0.01, false)
    end
end
    --ActionCamera
--    local cameranew = cc.ActionCamera:new()
--    cameranew:startWithTarget(node)
--    cameranew:setEye(-100,0,100 )
--    cameranew:setCenter(cc.Vec3(10,10,-10))
--停止镜头缩放
function ShakeActions.stopCameraZoomIn()
    if isZooming then
--        pos_node1[3]:stopAllActions()
--        pos_node1[3]:setPosition(ccp(pos_node1[1],pos_node1[2]))
--        pos_node2[3]:stopAllActions()
--        pos_node2[3]:setPosition(ccp(pos_node2[1],pos_node2[2]))
        
        isZooming = false
        time_zooming = 0
        pos_node1 = {}
        pos_node2 = {}
        if handle_zoom then
            scheduler.unscheduleGlobal(handle_zoom)
            handle_zoom = nil
        end
    end
end

--暂停镜头缩放
function ShakeActions.pauseCameraZoomIn()
    isPauseZoom = true
end

--恢复镜头缩放
function ShakeActions.resumeCameraZoomIn()
    isPauseZoom = false
end

return ShakeActions 

--endregion
