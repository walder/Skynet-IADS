do

SkynetIADSEWRadar = {}
SkynetIADSEWRadar = inheritsFrom(SkynetIADSAbstractElement)

function SkynetIADSEWRadar:create(radarUnit, iads)
	local radar = self:superClass():create(radarUnit, iads)
	setmetatable(radar, self)
	self.__index = self
	if radar.iads:getDebugSettings().addedEWRadar then
			radar.iads:printOutput(radar:getDescription().." added to IADS")
	end
	return radar
end

end
