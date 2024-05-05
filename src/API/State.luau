-- // Folders
local Utility = script.Parent.Parent.Utility
local Types = script.Parent.Parent.Types

-- // Dependencies
local InternalTypes = require(Types.InternalTypes)
local PublicTypes = require(Types.PublicTypes)
local Debugger = require(Utility.Debugger)
local Is = require(Utility.Is)

-- // Variables
local Class = {}

-- // Functions
local function TriggerListeners(listeners: { (oldValue: any, newValue: any) -> () }, oldValue: any, value: any): ()
	-- Loop through the listeners table and call every function each of them have.
	for _, fn in listeners do
		fn(oldValue, value)
	end
end

--[[
	@return T
]]
function Class.Get<T>(self: InternalTypes.StateInternal): T
	return self._state
end

--[[
	@param newValue The value to change to
]]
function Class.Set(self: InternalTypes.StateInternal, newValue: any): ()
	local OldValue = self._state

	-- Normal checks
	if self._state == newValue then
		return
	end

	if self._protectType == true and Is.TypeSame(OldValue, newValue) == false then
		Debugger.Warn("TypeMismatch", typeof(OldValue), typeof(newValue))
		return
	end

	-- Setting the actual value and triggering the listeners
	self._state = newValue
	TriggerListeners(self._listeners, OldValue, newValue)
end

--[[
	@param fn The listener function that the paths will listen to.
]]
function Class.Listen(self: InternalTypes.StateInternal, fn: (oldValue: any, newValue: any) -> ()): ()
	table.insert(self._listeners, fn) -- Add a listener
end

function Class._apply(self: InternalTypes.StateInternal, prop: string, instance: Instance)
	(instance :: any)[prop] = self._state

	self:Listen(function(_, newValue)
		(instance :: any)[prop] = newValue
	end)
end

--[[
	@param initialState Create an empty state table
	@param protectType Whether to do type checking when setting value
	@return State
]]
local function state(initialState: any, protectType: boolean?): PublicTypes.State
	local self = setmetatable({} :: InternalTypes.StateInternal, { __index = Class })

	self.AegisClass = "API"
	self.AegisName = "State"

	self._state = initialState
	self._listeners = {}
	self._protectType = protectType or true

	return self
end

-- // Returning
return state
