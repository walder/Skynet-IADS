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

function SkynetIADSEWRadar:setupElements()
	local unit = self:getDCSRepresentation()
	local unitType = unit:getTypeName()
	for typeName, dataType in pairs(SkynetIADS.database) do
		for entry, unitData in pairs(dataType) do
			if entry == 'searchRadar' then
				self:buildSingleUnit(unit, SkynetIADSSAMSearchRadar, self.searchRadars, unitData)
				if #self.searchRadars > 0 then
					if unitData[unitType]['name'] then
						local natoName = unitData[unitType]['name']['NATO']
						self:buildNatoName(natoName)
					end
					return
				end
			end
		end
	end
end

--an Early Warning Radar has simplified check to determine if its autonomous or not
function SkynetIADSEWRadar:setToCorrectAutonomousState()
	if self:hasActiveConnectionNode() and self:hasWorkingPowerSource() and self.iads:isCommandCenterUsable() then
		self:resetAutonomousState()
		self:goLive()
	end
	if self:hasActiveConnectionNode() == false or self.iads:isCommandCenterUsable() == false then
		self:goAutonomous()
	end
end

end
