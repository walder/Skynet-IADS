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

end