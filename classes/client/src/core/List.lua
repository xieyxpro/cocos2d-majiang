--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--[[
    List数据结构是一个综合结构，可以实现顺序访问，也可以随机访问（当index可用时）可以做如下结构使用：
    队列：使用pushBack和popFront进行操作
    链表：已经支持双向链接，使用insert和pop进行操作
    堆栈：pushBack和popBack
--]]

local class = require("core.class")

local List = class("List")

local ListNode = class("ListNode")

function ListNode:__init(data)
    self._prev = nil 
    self._next = nil 
    self._data = data 
    self._index = nil
end 


function List:__init(params)
    --------------------------
    self._head = nil 
    self._tail = nil 
    self._cnt = 0
    self._indexes = {}
end 

function List:isEmpty()
    return self._cnt == 0
end 

function List:getCnt()
    return self._cnt 
end 

function List:size()
    return self._cnt
end 

function List:getPairs()
    local ptr = self._head
    local ndx = 0
    local function pairs()
        ndx = ndx + 1
        if ptr then 
            local data = ptr._data
            local index = ptr._index or ndx
            ptr = ptr._next
            return index, data
        else
            return nil, nil
        end
    end 
    return pairs
end 

function List:getPairsRevert()
    local ptr = self._tail
    local ndx = 0
    local function pairs()
        ndx = ndx + 1
        if ptr then 
            local data = ptr._data
            local index = ptr._index or ndx
            ptr = ptr._prev
            return index, data
        else
            return nil, nil
        end
    end 
    return pairs
end 

function List:getIpairs()
    local ptr = self._head
    local ndx = 0
    local function pairs()
        ndx = ndx + 1
        if ptr then 
            local data = ptr._data
            ptr = ptr._next
            return ndx, data
        else
            return nil, nil
        end
    end 
    return pairs
end 

function List:getIpairsRevert()
    local ptr = self._tail
    local ndx = 0
    local function pairs()
        ndx = ndx + 1
        if ptr then 
            local data = ptr._data
            ptr = ptr._prev
            return ndx, data
        else
            return nil, nil
        end
    end 
    return pairs
end 

function List:toArray()
    local ary = {}
    local ptr = self._head
    while ptr do 
        table.insert(ary, ptr._data)
        ptr = ptr._next
    end 
    return ary
end

function List:toArrayRevert()
    local ary = {}
    local ptr = self._tail
    while ptr do 
        table.insert(ary, ptr._data)
        ptr = ptr._prev
    end 
    return ary
end

function List:pushBack(data, index)
    local node = ListNode(data)
    if not self._head then 
        self._head = node 
        self._tail = node 
        self._cnt = 1
    else 
        self._tail._next = node 
        node._prev = self._tail 
        self._tail = self._tail._next 
        self._cnt = self._cnt + 1
    end 
    if index then 
        assert(self._indexes[index] == nil)
        node._index = index
        self._indexes[index] = node
    end 
end 

function List:pushFront(data, index)
    local node = ListNode(data)
    if not self._head then 
        self._head = node 
        self._tail = node 
        self._cnt = 1
    else 
        self._head._prev = node 
        node._next = self._head 
        self._head = self._head._prev 
        self._cnt = self._cnt + 1
    end 
    if index then 
        assert(self._indexes[index] == nil)
        node._index = index
        self._indexes[index] = node
    end 
end 

function List:popFront()
    if not self._head then 
        return 
    end 
    local node = self._head
    local data = self._head._data 
    self._head = self._head._next 
    self._cnt = self._cnt - 1
    if not self._head then 
        self._head = nil 
        self._tail = nil 
    else
        self._head._prev = nil 
    end 
    if node._index then 
        self._indexes[node._index] = nil
    end 
    return data 
end 

function List:popBack()
    if not self._tail then 
        return 
    end 
    local node = self._tail
    local data = self._tail._data 
    self._tail = self._tail._prev 
    self._cnt = self._cnt - 1
    if not self._tail then 
        self._head = nil 
        self._tail = nil 
    else
        self._tail._next = nil 
    end 
    if node._index then 
        self._indexes[node._index] = nil
    end 
    return data 
end 

function List:popByIndex(index)
    local node = self._indexes[index]
    if not node then 
        return 
    end
    if not node._prev then 
        self:popFront()
    elseif not node._next then 
        self:popBack()
    else
        node._prev._next = node._next
        node._next._prev = node._prev
        self._cnt = self._cnt - 1
        self._indexes[node._index] = nil
    end 
    return node._data
end 

function List:popByPosition(pos)
    if self:isEmpty() then 
        return 
    else
        if pos < 1 then 
            return 
        end 
        local ptr = self._head
        for i = 2, pos do 
            ptr = ptr._next
            if not ptr then 
                break 
            end 
        end 
        if not ptr then 
            return 
        end 
        local node = ptr
        if not node._prev then 
            self:popFront()
        elseif not node._next then 
            self:popBack()
        else
            node._prev._next = node._next
            node._next._prev = node._prev
            self._cnt = self._cnt - 1
            self._indexes[node._index] = nil
        end 
        return node._data
    end 
end

function List:insert(data, pos, index)
    local node = ListNode(data)
    if self:isEmpty() then 
        self._head = node 
        self._tail = node 
        self._cnt = 1
        if index then 
            node._index = index
            self._indexes[index] = node
        end 
    else
        if pos >= 0 then 
            local ptr = self._head 
            for i = 1, pos - 1 do 
                ptr = ptr and ptr._next
                if not ptr then 
                    break 
                end 
            end 
            if not ptr then 
                self:pushBack(data, index)
            else
                local cur = ptr 
                if cur._prev then
                    node._next = cur
                    node._prev = cur._prev
                    cur._prev._next = node
                    cur._prev = node
                    self._cnt = self._cnt + 1
                    if index then 
                        assert(self._indexes[index] == nil)
                        node._index = index
                        self._indexes[index] = node
                    end 
                else
                    self:pushFront(data, index)
                end
            end 
        else
            local ptr = self._tail 
            for i = 1, -pos - 1 do 
                ptr = ptr and ptr._prev
                if not ptr then 
                    break 
                end 
            end 
            if not ptr then 
                self:pushFront(data, index)
            else
                local cur = ptr 
                if cur._next then
                    node._next = cur._next
                    node._prev = cur
                    cur._next._prev = node
                    cur._next = node
                    self._cnt = self._cnt + 1
                    if index then 
                        assert(self._indexes[index] == nil)
                        node._index = index
                        self._indexes[index] = node
                    end 
                else
                    self:pushBack(data, index)
                end
            end 
        end 
    end 
    
end 

--根据排序插入
--cmprFunc: 比较方法，声明如下：
--function cmprFunc(oldData, newData) end
function List:sortInsert(data,cmprFunc, index)
    local node = ListNode(data)
    if self:isEmpty() then 
        self._head = node 
        self._tail = node 
        self._cnt = 1
        if index then 
            assert(self._indexes[index] == nil)
            node._index = index
            self._indexes[index] = node
        end 
    else
        local ptr = self._head
        while ptr do 
            if cmprFunc(ptr._data, data) then 
                local cur = ptr 
                if cur._prev then
                    node._next = cur
                    node._prev = cur._prev
                    cur._prev._next = node
                    cur._prev = node
                    self._cnt = self._cnt + 1
                    if index then 
                        node._index = index
                        self._indexes[index] = node
                    end 
                else
                    self:pushFront(data, index)
                end
                return
            else
                ptr = ptr._next
            end
        end 
        if not ptr then
            self:pushBack(data, index)
        end 
    end 
end 

function List:getFront()
    return self._head and self._head._data or nil
end 

function List:getBack()
    return self._tail and self._tail._data or nil
end 

function List:getByPos(pos)
    if self:isEmpty() == 0 then 
        return nil
    end 
    if pos > 0 then 
        local ndx = 0
        local ptr = self._head 
        for i = 1, pos - 1 do 
            ptr = ptr and ptr._next
            ndx = ndx + 1
            if not ptr then 
                break 
            end 
        end 
        if ptr and pos - 1 == ndx then 
            return ptr._data
        else 
            return nil
        end 
    elseif pos < 0 then 
        local ndx = 0
        local ptr = self._tail 
        for i = 1, -pos - 1 do 
            ptr = ptr and ptr._prev
            ndx = ndx - 1
            if not ptr then 
                break 
            end 
        end 
        if ptr and pos + 1 == ndx then 
            return ptr._data
        else 
            return nil
        end 
    else
        return nil
    end 
end 

function List:getByIndex(index)
    local node = self._indexes[index]
    return node and node._data or nil
end 

return List
--endregion
