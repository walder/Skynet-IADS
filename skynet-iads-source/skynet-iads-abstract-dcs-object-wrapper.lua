do

SkynetIADSAbstractDCSObjectWrapper = {}

function SkynetIADSAbstractDCSObjectWrapper:create(dcsObject)
	local instance = {}
	setmetatable(instance, self)
	self.__index = self
	instance.dcsObject = dcsObject
	if dcsObject and dcsObject:isExist() and getmetatable(dcsObject) == Unit then
		--we store inital life here, because getLife0() returs a value that is lower that getLife() when no damage has happened...
		instance.initialLife = dcsObject:getLife()
	end
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
	if self.dcsObject then
		return self.dcsObject:isExist()
	else
		return false
	end
end

function SkynetIADSAbstractDCSObjectWrapper:getLifePercentage()
	if self.dcsObject and self.dcsObject:isExist() then
		return self.dcsObject:getLife() / self.initialLife * 100
	else
		return 0
	end
	
end

function SkynetIADSAbstractDCSObjectWrapper:getDCSRepresentation()
	return self.dcsObject
end

end