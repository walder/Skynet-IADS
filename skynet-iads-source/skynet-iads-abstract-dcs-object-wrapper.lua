do

SkynetIADSAbstractDCSObjectWrapper = {}

function SkynetIADSAbstractDCSObjectWrapper:create(dcsObject)
	local instance = {}
	setmetatable(instance, self)
	self.__index = self
	instance.dcsObject = dcsObject
	instance.name = dcsObject:getName()
	instance.typeName = dcsObject:getTypeName()
	return instance
end

function SkynetIADSAbstractDCSObjectWrapper:getName()
	return self.name
end

function SkynetIADSAbstractDCSObjectWrapper:getTypeName()
	return self.typeName
end

function SkynetIADSAbstractDCSObjectWrapper:getPosition()
	return self.dcsObject:getPosition()
end

function SkynetIADSAbstractDCSObjectWrapper:isExist()
	if self.dcsObject then
		return self.dcsObject:isExist()
	else
		return false
	end
end

function SkynetIADSAbstractDCSObjectWrapper:getDCSRepresentation()
	return self.dcsObject
end

end

