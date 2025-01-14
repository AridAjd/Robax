-- Variables
local Root = script.Parent
local Types = require(Root.types)
local Debugger = require(Root.Parent.roblox_packages.debugger)

local Class = {}
Class.__index = Class

-- Functions

local function Listener(self: Types.Computed)
	return function()
		self._Value = self._Processor() -- Set the value of the computed to the processed value

		if self._Instances ~= nil then
			for prop, instance in self._Instances do
				(instance :: any)[prop] = self._Value
			end
		end
	end
end

--[=[
	Gets the current value of the compute object.

	[Open Documentation](https://lumin-org.github.io/ui/api/computed/#get)
]=]
function Class.Get(self: Types.Computed): any
	return self._Value
end

function Class._Bind(self: Types.Computed, prop: string, instance: Instance)
	(self._Instances :: {})[prop] = instance;
	(instance :: any)[prop] = self._Value
end

--[=[
	Destroys the compute object, but not the state dependencies.

	[Open Documentation](https://lumin-org.github.io/ui/api/computed/#destroy)
]=]
function Class.Destroy(self: Types.Computed)
	table.clear(self :: any)
	setmetatable(self :: any, nil)
end

-- Module

--[=[
	Creates a new computed value, which changes the final value when a dependency is changed.

	[Open Documentation](https://lumin-org.github.io/ui/api/#computed)
]=]
return function(processor: () -> (), dependencies: { Types.State | Types.Spring }?): Types.ComputedExport
	local self = setmetatable({}, Class)

	self._Processor = processor
	self._Value = processor()
	self._Instances = {}
	self._Dependencies = nil

	if dependencies then
		local Type = type(dependencies)
		Debugger.assert(Type == "table", "InvalidType", "table", Type)
		self._Dependencies = {} :: any
		for _, dependency in dependencies do
			if type(dependency) == "table" then
				(self._Dependencies :: any)[dependency] = (dependency :: any):Listen(Listener(self :: any))
            else
                Debugger.fatal("InvalidType", "state", type(dependency))
			end
		end
	end

	return self :: any
end
