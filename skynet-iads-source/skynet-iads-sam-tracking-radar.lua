do

SkynetIADSSAMTrackingRadar = {}
SkynetIADSSAMTrackingRadar = inheritsFrom(SkynetIADSSAMSearchRadar)

function SkynetIADSSAMTrackingRadar:create(unit, performanceData)
	local instance = self:superClass():create(unit, performanceData)
	setmetatable(instance, self)
	self.__index = self
	return instance
end

end
