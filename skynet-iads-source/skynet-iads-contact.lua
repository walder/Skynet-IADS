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
	instance.numOfTimesRefreshed = 0
	instance.speed = 0
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

function SkynetIADSContact:getGroundSpeedInKnots(decimals)
	if decimals == nil then
		decimals = 2
	end
	return mist.utils.round(self.speed, decimals)
end

function SkynetIADSContact:getNumberOfTimesHitByRadar()
	return self.numOfTimesRefreshed
end

function SkynetIADSContact:refresh()
	self.numOfTimesRefreshed = self.numOfTimesRefreshed + 1
	if self.dcsObject and self.dcsObject:isExist() then
		local distance = mist.utils.metersToNM(mist.utils.get2DDist(self.position.p, self.dcsObject:getPosition().p))
		local timeDelta = (timer.getAbsTime() - self.lastTimeSeen)
		if timeDelta > 0 then
			local hours = timeDelta / 3600
			self.speed = (distance / hours)
		end 
		self.position = self.dcsObject:getPosition()
	end
	self.lastTimeSeen = timer.getAbsTime()
end

function SkynetIADSContact:getAge()
	return timer.getAbsTime() - self.lastTimeSeen
end

end

