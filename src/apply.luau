-- Variables
local Types = require("./types")

-- Module
return function(instance: Instance, props: { [any]: any })
	for property, value in props do
		if property == "Parent" or property == "Name" then
			continue
		end
		local PropType = type(property)
		local ValueType = type(value)
		if PropType == "number" then -- If the property is a modifier
			if ValueType == "function" then -- If the value is an action
				(value :: Types.Action)(instance)
			elseif ValueType == "userdata" then -- If the value is an instance
				value.Parent = instance
				value.Name = property
			end
		elseif PropType == "string" then -- If the property is a string
			if ValueType == "table" then -- If the value is a constructor
				(value :: Types.Constructor<any, any>):_Bind(property, instance)
			else -- If the value is anything else, it is the value of a property
				(instance :: any)[property] = value
			end
		end
	end
	-- Set Parent and Name later since they are given defaults
	if props.Parent then
		instance.Parent = props.Parent
	end
	if props.Name then
		instance.Name = props.Name
	end
end
