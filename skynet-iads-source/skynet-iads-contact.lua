do

SkynetIADSContact = {}

function SkynetIADSContact:create(dcsRadarTarget)
	local instance = {}
	setmetatable(instance, self)
	self.__index = self
	instance.dcsRadarTarget = dcsRadarTarget
	instance.dcsContact = dcsRadarTarget.object
	return instance
end

function SkynetIADSContact:getName()
	return self.dcsContact:getName()
end

function SkynetIADSContact:getTypeName()
	return self.dcsContact:getTypeName()
end

function SkynetIADSContact:getPosition()
	return self.dcsContact:getPosition()
end

function SkynetIADSContact:isExist()
	return self.dcsContact:isExist()
end

function SkynetIADSContact:isTypeKnown()
	return self.dcsRadarTarget.type
end

function SkynetIADSContact:getPosition()
	return self.dcsContact:getPosition()
end

function SkynetIADSContact:isDistanceKnown()
	return self.dcsRadarTarget.distance
end

end

