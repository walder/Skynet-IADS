do

SkynetIADSContact = {}
SkynetIADSContact = inheritsFrom(SkynetIADSAbstractDCSObjectWrapper)

SkynetIADSContact.CLIMB = "CLIMB"
SkynetIADSContact.DESCEND = "DESCEND"

function SkynetIADSContact:create(dcsRadarTarget)
	local instance = self:superClass():create(dcsRadarTarget.object)
	setmetatable(instance, self)
	self.__index = self
	instance.firstContactTime = timer.getAbsTime()
	instance.lastTimeSeen = 0
	instance.dcsRadarTarget = dcsRadarTarget
	instance.position = instance.dcsObject:getPosition()
	instance.numOfTimesRefreshed = 0
	instance.speed = 0
	instance.simpleAltitudeProfile = {}
	return instance
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

function SkynetIADSContact:getHeightInFeetMSL()
	if self.dcsObject:isExist() then
		return mist.utils.round(mist.utils.metersToFeet(self.dcsObject:getPosition().p.y), 0)
	else
		return 0
	end
end

function SkynetIADSContact:getDesc()
	if self.dcsObject:isExist() then
		return self.dcsObject:getDesc()
	else
		return {}
	end
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
		self:updateSimpleAltitudeProfile()
		self.position = self.dcsObject:getPosition()
	end
	self.lastTimeSeen = timer.getAbsTime()
end

function SkynetIADSContact:updateSimpleAltitudeProfile()
	local currentAltitude = self.dcsObject:getPosition().p.y
	local currentProfile = self.simpleAltitudeProfile
	
	local previousPath = ""
	if #self.simpleAltitudeProfile > 0 then
		previousPath = self.simpleAltitudeProfile[#self.simpleAltitudeProfile]
	end
	
	if self.position.p.y > currentAltitude and previousPath ~= SkynetIADSContact.DESCEND then
		table.insert(self.simpleAltitudeProfile, SkynetIADSContact.DESCEND)
	elseif self.position.p.y < currentAltitude and previousPath ~= SkynetIADSContact.CLIMB then
		table.insert(self.simpleAltitudeProfile, SkynetIADSContact.CLIMB)
	end
end

function SkynetIADSContact:getSimpleAltitudeProfile()
	return self.simpleAltitudeProfile
end

function SkynetIADSContact:getAge()
	return mist.utils.round(timer.getAbsTime() - self.lastTimeSeen)
endk

end

