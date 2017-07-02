--[[
example:
	Object = class("Object")
	
	function Object:__init(id)
		self.id = id
		self.data = "data"
	end

	function Object:get_id()
		return self.id
	end
	
	function Object:print()
		print("hello")
	end
	
	Car = Object:extends("Car")
	
	function Car:__init(id)
		Car.super.__init(self, id)
		this.data = "new data"
	end
	
	function Car:print()
		Car.super.print(self)
	end
	
	BigCar = Car:extends("BigCar")
	
	function BigCar:__init(id)
		BigCar.super.__init(self, id)
		this.data2 = "new data2"
	end
	
	function BigCar:print()
		BigCar.super.print(self)
	end
]]

local classes = {}

local __mt = {
    __call = function(this, ...)
		local obj = {}
		this.__init(obj, ...)
		return setmetatable(obj, this)
    end
}

local function is(self, kind)
	local mt = getmetatable(self)
	while mt do
		if mt == kind then
			return true
		end
		mt = mt.super
	end
	return false
end

local function extends(super, name)
	local this = classes[name]
	if this then
		return this
	end
	this = {}
	this.__name = name
	this.__index =
			function(t, k)
				return rawget(this, k) or super.__index(t, k)
			end
	this.is = is
	this.extends = extends
	this.super = super
	classes[name] = this
	return setmetatable(this, __mt)
end

local function attach(mt, obj)
    assert(not getmetatable(obj))
    setmetatable(obj, mt)
end

local function detach(mt, obj)
    assert(mt == getmetatable(obj))
    setmetatable(obj, nil)
end

local function class(name)
	local this = classes[name]
	if this then
		return this
	end
	this = {}
	this.__name = name
	this.__index =
			function(t, k)
				return rawget(this, k)
			end
	this.is = is
	this.extends = extends
    this.attach = attach
    this.detach = detach
	classes[name] = this
	return setmetatable(this, __mt)
end

return class