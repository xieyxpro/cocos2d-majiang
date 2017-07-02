local beholder = {}

local groups = {} --{[group_id] = nodes, ...}
local cur_group_id = 0

function beholder.stop_observ_group(group_id)
    if not groups[group_id] then 
        return 
    end 
    groups[group_id] = nil 
end

function beholder.stop_observe(event)
    if not groups[cur_group_id] then 
        return 
    end 
    if not groups[cur_group_id][event] then 
        return 
    end 
    groups[cur_group_id][event] = nil 
end 

function beholder.set_cur_group(group_id)
    self.cur_group_id = group_id
end 

function beholder.observe(event, caller, callback)
    if not event or not callback then 
        error("event or callback must be specified when call observe")
    end 
    groups[cur_group_id] = groups[cur_group_id] or {group_id = cur_group_id, nodes = {}}
    local nodes = groups[cur_group_id].nodes
    nodes[event] = nodes[event] or {}
    table.insert(nodes[event], {caller = caller, callback = callback})
end

local local_safe_call = safecall
function beholder.trigger(event, ...)
    if not groups[cur_group_id] then 
        return 
    end 
    if not groups[cur_group_id].nodes[event] then 
        return 
    end 
    local callbacks = groups[cur_group_id].nodes[event]
    for _, callback_info in ipairs(callbacks) do 
        local caller = callback_info.caller 
        local callback = callback_info.callback 
        if caller then 
            local_safe_call(callback,caller, ...)
        else
            local_safe_call(callback, ...)
        end 
    end 
end

function beholder.trigger_all(...)
    if not groups[cur_group_id] then 
        return 
    end 
    for _, callbacks in pairs(groups[cur_group_id].nodes) do 
        for _, callback_info in ipairs(callbacks) do 
            local caller = callback_info.caller 
            local callback = callback_info.callback 
            if caller then 
                local_safe_call(callback,caller, ...)
            else
                local_safe_call(callback, ...)
            end 
        end 
    end 
end

function beholder.reset()
  groups = {}
  cur_group_id = 0
end

return beholder
