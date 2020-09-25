do

SkynetIADSEWRadar = {}
SkynetIADSEWRadar = inheritsFrom(SkynetIADSAbstractRadarElement)

function SkynetIADSEWRadar:create(radarUnit, iads)
	local instance = self:superClass():create(radarUnit, iads)
	setmetatable(instance, self)
	self.__index = self
	instance.autonomousBehaviour = SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK
	return instance
end

--an Early Warning Radar has simplified check to detrmine if its autonomous or not
function SkynetIADSEWRadar:setToCorrectAutonomousState()
	if self:hasActiveConnectionNode() then
		self:resetAutonomousState()
		return
	end
	self:goAutonomous()
end

end
