do

SkynetIADSSAMTrackingRadar = {}
SkynetIADSSAMTrackingRadar = inheritsFrom(SkynetIADSSAMSearchRadar)

function SkynetIADSSAMTrackingRadar:create(unit)
	local instance = self:superClass():create(unit)
	setmetatable(instance, self)
	self.__index = self
	return instance
end

end
