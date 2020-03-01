do

SkynetIADSContact = {}
SkynetIADSContact = inheritsFrom(SkynetIADSAbstractDCSObjectWrapper)

function SkynetIADSContact:create(dcsRadarTarget)
	local instance = self:superClass():create(dcsRadarTarget.object)
	setmetatable(instance, self)
	self.__index = self
	instance.firstContactTime = timer.getAbsTime()
	instance.lastTimeSeen = 0
	instance.dcsRadarTarget = dcsRadarTarget
	instance.name = instance.dcsObject:getName()
	instance.typeName = instance.dcsObject:getTypeName()
	instance.position = instance.dcsObject:getPosition()
	return instance
end

function SkynetIADSContact:getName()
	return self.name
end

function SkynetIADSContact:getTypeName()
	return self.typeName
end

function SkynetIADSContact:isTypeKnown()
	return self.dcsRadarTarget.type
end

function SkynetIADSContact:isDistanceKnown()
	return self.dcsRadarTarget.distance
end

function SkynetIADSContact:getPosition()
	return self.position
end

function SkynetIADSContact:refresh()
	if self.dcsObject and self.dcsObject:isExist() then
		self.position = self.dcsObject:getPosition()
	end
	self.lastTimeSeen = timer.getAbsTime()
end

function SkynetIADSContact:getAge()
	return timer.getAbsTime() - self.lastTimeSeen
end

end

