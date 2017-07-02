--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local Event = { __events = {}}

--[Comment]
--注册事件处理方法
function Event.register(eventName, caller, funcOrFuncName)
    assert(eventName, "eventName cannot be nil")
    local funcType = type(funcOrFuncName)
    if funcType == "string" then 
        if not caller then 
            printError("[Event: %s]registered function name %s must has a caller", eventName, funcOrFuncName)
            return
        end 
    elseif funcType == "function" then 
        
    else 
        printError("[Event: %s]unsupported dispatch function type: %s", eventName, funcType)
        return
    end 
    Event.__events[eventName] = Event.__events[eventName] or {name = eventName, handlers = {}}
    table.insert(Event.__events[eventName].handlers, {caller = caller, funcOrFuncName = funcOrFuncName})
end 

--[Comment]
--删除事件处理方法
function Event.unregister(eventName, caller, funcOrFuncName)
    local event = Event.__events[eventName]
    if not event then 
        return 
    end 
    for _, call in ipairs(event.handlers) do 
        if call.caller == caller and call.funcOrFuncName == funcOrFuncName then 
            table.remove(event.handlers, _)
        end 
    end 
end

--[Comment]
--广播事件
--params: 广播传递的数据(参数个数最多为4个，超过4个请使用table)
function Event.dispatch(eventName, ...)
    assert(eventName, "nil evenet name dispatch can not be allowed")
    local event = Event.__events[eventName]
    if not event then 
        return
    end 
    for _, call in ipairs(event.handlers) do 
        local funcOrFuncName = call.funcOrFuncName
        local funcType = type(funcOrFuncName)
        local func = nil
        if funcType == "string" then 
            if call.caller and call.caller[funcOrFuncName] then 
                func = call.caller[funcOrFuncName]
            end 
        elseif funcType == "function" then 
            func = funcOrFuncName
        else 
            printError("[Event: %s]unsupported dispatch function type: %s", eventName, funcType)
        end 
        if not func then
            printError("[Event: %s]nil dispatch function found", eventName)
        else 
            if call.caller then
                func(call.caller, ...)
            else 
                func(...)
            end
        end
    end 
end 

return Event
--endregion
