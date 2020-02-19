do

SkynetIADSEWRadar = {}
SkynetIADSEWRadar = inheritsFrom(SkynetIADSAbstractElement)
--SkynetIADSEWRadar.__index = SkynetIADSEWRadar

function SkynetIADSEWRadar:create(radarUnit)
	local radar = self:superClass():create()
	setmetatable(radar, self)
	self.__index = self
	radar.radarUnit = radarUnit
	--trigger.action.outText("call radar", 5)
	return radar
end

function SkynetIADSEWRadar:getDescription()
	return "EW Radar: "..self.radarUnit:getName().." Type: "..self.radarUnit:getTypeName()
end

function SkynetIADSEWRadar:getDetectedTargets()
	if self:hasWorkingPowerSource() == false then
		trigger.action.outText(self:getDescription().." has no Power", 1)
		return
	end
	local returnTargets = {}
	--trigger.action.outText("EW getTargets", 1)
	--trigger.action.outText(self.radarUnit:getName(), 1)
	local ewRadarController = self.radarUnit:getController()
	local targets = ewRadarController:getDetectedTargets()
	--trigger.action.outText("num Targets: "..#targets, 1)
	for i = 1, #targets do
		local target = targets[i].object
		--trigger.action.outText(target:getName(), 1)
		table.insert(returnTargets, target)
	end
	return returnTargets
end

end