do
--this class is currently used for AWACS and Ships, at a latter date a separate class for ships could be created, currently not needed
SkynetIADSAWACSRadar = {}
SkynetIADSAWACSRadar = inheritsFrom(SkynetIADSAbstractRadarElement)

function SkynetIADSAWACSRadar:create(radarUnit, iads)
	local instance = self:superClass():create(radarUnit, iads)
	setmetatable(instance, self)
	self.__index = self
	instance.lastUpdatePosition = nil
	return instance
end

function SkynetIADSAWACSRadar:setupElements()
	local unit = self:getDCSRepresentation()
	local radar = SkynetIADSSAMSearchRadar:create(unit)
	radar:setupRangeData()
	table.insert(self.searchRadars, radar)
end

function SkynetIADSAWACSRadar:getNatoName()
	return self:getDCSRepresentation():getTypeName()
end

-- AWACs will not scan for HARMS
function SkynetIADSAWACSRadar:scanForHarms()
	
end

function SkynetIADSAWACSRadar:getMaxAllowedMovementForAutonomousUpdateInNM()
	local radarRange = mist.utils.metersToNM(self.searchRadars[1]:getMaxRangeFindingTarget())
	return mist.utils.round(radarRange / 10)
end

function SkynetIADSAWACSRadar:isUpdateOfAutonomousStateOfSAMSitesRequired()
	return self:getDistanceTraveledSinceLastUpdate() > self:getMaxAllowedMovementForAutonomousUpdateInNM()
end

function SkynetIADSAWACSRadar:getDistanceTraveledSinceLastUpdate()
	local currentPosition = nil
	if self.lastUpdatePosition == nil and self:getDCSRepresentation():isExist() then
		self.lastUpdatePosition = self:getDCSRepresentation():getPosition().p
	end
	if self:getDCSRepresentation():isExist() then
		currentPosition = self:getDCSRepresentation():getPosition().p
	end
	return mist.utils.round(mist.utils.metersToNM(self:getDistanceToUnit(self.lastUpdatePosition, currentPosition)))
end

end

