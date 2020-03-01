do

SkynetIADSSAMSearchRadar = {}
SkynetIADSSAMSearchRadar = inheritsFrom(SkynetIADSAbstractDCSObjectWrapper)

function SkynetIADSSAMSearchRadar:create(unit, performanceData)
	local instance = self:superClass():create(unit)
	setmetatable(instance, self)
	self.__index = self
	instance.performanceData = performanceData
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

function SkynetIADSSAMSearchRadar:isInRange(target)
	local distance = mist.utils.get3DDist(target:getPosition().p, self.dcsObject:getPosition().p)
	local radarHeight = self.dcsObject:getPosition().p.y
	local aircraftHeight = target:getPosition().p.y	
	local altitudeDifference = math.abs(aircraftHeight - radarHeight)
	local maxDetectionAltitude = self:getMaxAltFindingTarget()
	local maxDetectionRange = self:getMaxRangeFindingTarget()
	--trigger.action.outText("Radar Range: "..maxDetectionRange,1)
	--trigger.action.outText("current distance: "..distance,1)
	return altitudeDifference <= maxDetectionAltitude and distance <= maxDetectionRange
end

end
