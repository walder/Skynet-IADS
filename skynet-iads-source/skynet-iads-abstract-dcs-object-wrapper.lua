do

SkynetIADSAbstractDCSObjectWrapper = {}

function SkynetIADSAbstractDCSObjectWrapper:create(dcsObject)
	local instance = {}
	setmetatable(instance, self)
	self.__index = self
	instance.dcsObject = dcsObject
	return instance
end

function SkynetIADSAbstractDCSObjectWrapper:getName()
	return self.dcsObject:getName()
end

function SkynetIADSAbstractDCSObjectWrapper:getTypeName()
	return self.dcsObject:getTypeName()
end

function SkynetIADSAbstractDCSObjectWrapper:getPosition()
	return self.dcsObject:getPosition()
end

function SkynetIADSAbstractDCSObjectWrapper:isExist()
	return self.dcsObject:isExist()
end

function SkynetIADSAbstractDCSObjectWrapper:getDCSRepresentation()
	return self.dcsObject
end

end

