do

SkynetIADSSAMSearchRadar = {}
SkynetIADSSAMSearchRadar = inheritsFrom(SkynetIADSAbstractDCSObjectWrapper)

function SkynetIADSSAMSearchRadar:create(unit, performanceData)
	local instance = self:superClass():create(unit)
	setmetatable(instance, self)
	self.__index = self
	instance.performanceData = performanceData
	instance.firingRangePercent = 100
	return instance
end

function SkynetIADSSAMSearchRadar:getMaxRangeFindingTarget()
	return self.performanceData['max_range_finding_target']
end

function SkynetIADSSAMSearchRadar:getMinRangeFindingTarget()
	return self.performanceData['min_range_finding_target']
end

function SkynetIADSSAMSearchRadar:getMaxAltFindingTarget()
	return self.performanceData['max_alt_finding_target']
end

function SkynetIADSSAMSearchRadar:getMinAltFindingTarget()
	return self.performanceData['min_alt_finding_target']
end

function SkynetIADSSAMSearchRadar:setFiringRangePercent(percent)
	self.firingRangePercent = percent
end

function SkynetIADSSAMSearchRadar:isInRange(target)
	if self:isExist() == false then
		return false
	end
	local distance = mist.utils.get2DDist(target:getPosition().p, self.dcsObject:getPosition().p)
	local radarHeight = self.dcsObject:getPosition().p.y
	local aircraftHeight = target:getPosition().p.y	
	local altitudeDifference = math.abs(aircraftHeight - radarHeight)
	local maxDetectionAltitude = self:getMaxAltFindingTarget()
	--local maxDetectionRange = self:getMaxRangeFindingTarget()
	
	local maxDetectionRange = (self:getMaxRangeFindingTarget() / 100 * self.firingRangePercent)
	
	--trigger.action.outText("Radar Range: "..maxDetectionRange,1)
	--trigger.action.outText("current distance: "..distance,1)
	return altitudeDifference <= maxDetectionAltitude and distance <= maxDetectionRange
end

end
