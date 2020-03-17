do

SkynetIADSAWACSRadar = {}
SkynetIADSAWACSRadar = inheritsFrom(SkynetIADSAbstractRadarElement)

function SkynetIADSAWACSRadar:create(radarUnit, iads)
	local instance = self:superClass():create(radarUnit, iads)
	setmetatable(instance, self)
	self.__index = self
	return instance
end

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
