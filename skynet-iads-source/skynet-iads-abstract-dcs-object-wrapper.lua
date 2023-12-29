do

SkynetIADSAbstractDCSObjectWrapper = {}

function SkynetIADSAbstractDCSObjectWrapper:create(dcsRepresentation)
	local instance = {}
	setmetatable(instance, self)
	self.__index = self
	instance.dcsName = ""
	instance.typeName = ""
	instance:setDCSRepresentation(dcsRepresentation)
	if getmetatable(dcsRepresentation) ~= Group then
		instance.typeName = dcsRepresentation:getTypeName()
	end
	return instance
end

function SkynetIADSAbstractDCSObjectWrapper:setDCSRepresentation(representation)
	self.dcsRepresentation = representation
	if self.dcsRepresentation then
		self.dcsName = self:getDCSRepresentation():getName()
	end
end

function SkynetIADSAbstractDCSObjectWrapper:getDCSRepresentation()
	return self.dcsRepresentation
end

function SkynetIADSAbstractDCSObjectWrapper:getName()
	return self.dcsName
end

function SkynetIADSAbstractDCSObjectWrapper:getTypeName()
	return self.typeName
end

function SkynetIADSAbstractDCSObjectWrapper:getPosition()
	return self.dcsRepresentation:getPosition()
end

function SkynetIADSAbstractDCSObjectWrapper:isExist()
	if self.dcsRepresentation then
		return self.dcsRepresentation:isExist()
	else
		return false
	end
end

function SkynetIADSAbstractDCSObjectWrapper:insertToTableIfNotAlreadyAdded(tbl, object)
	local isAdded = false
	for i = 1, #tbl do
		local child = tbl[i]
		if child == object then
			isAdded = true
		end
	end
	if isAdded == false then
		table.insert(tbl, object)
	end
	return not isAdded
end

-- helper code for class inheritance
function inheritsFrom( baseClass )

    local new_class = {}
    local class_mt = { __index = new_class }

    function new_class:create()
        local newinst = {}
        setmetatable( newinst, class_mt )
        return newinst
    end

    if nil ~= baseClass then
        setmetatable( new_class, { __index = baseClass } )
    end

    -- Implementation of additional OO properties starts here --

    -- Return the class object of the instance
    function new_class:class()
        return new_class
    end

    -- Return the super class object of the instance
    function new_class:superClass()
        return baseClass
    end

    -- Return true if the caller is an instance of theClass
    function new_class:isa( theClass )
        local b_isa = false

        local cur_class = new_class

        while ( nil ~= cur_class ) and ( false == b_isa ) do
            if cur_class == theClass then
                b_isa = true
            else
                cur_class = cur_class:superClass()
            end
        end

        return b_isa
    end

    return new_class
end


end

