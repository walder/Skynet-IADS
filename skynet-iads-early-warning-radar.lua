do

SkynetIADSEWRadar = {}
SkynetIADSEWRadar.__index = SkynetIADSEWRadar

function SkynetIADSEWRadar:create(radarUnit)
	local radar = {}
	setmetatable(radar, SkynetIADSEWRadar)
	radar.radarUnit = radarUnit
	radar.connectionNodes = {}
	radar.powerSources = {}
	return radar
end

function SkynetIADSEWRadar:getDescription()
	return "EW Radar: "..self.radarUnit:getName().." Type : "..self:getDBName()
end

function SkynetIADSEWRadar:getDBName()
	return "EW"
	--SkynetIADS.getDBName(self.radarUnit)
end

function SkynetIADSEWRadar:getDetectedTargets()
	if self:hasWorkingPowerSource() == false then
		trigger.action.outText(self:getDescription().." has no Power", 1)
		return
	end
	local returnTargets = {}
--	trigger.action.outText("EW getTargets", 1)
--	trigger.action.outText(self.radarUnit:getName(), 1)
	local ewRadarController = self.radarUnit:getController()
	local targets = ewRadarController:getDetectedTargets()
	--trigger.action.outText("num Targets: "..#targets, 1)
	for i = 1, #targets do
		local target = targets[i].object
	--	trigger.action.outText(target:getName(), 1)
		table.insert(returnTargets, target)
	end
	return returnTargets
end


function SkynetIADSEWRadar:addPowerSource(powerSource)
	table.insert(self.powerSources, powerSource)
end

function SkynetIADSEWRadar:addConnectionNode(connectionNode)
	table.insert(self.connectionNodes, connectionNode)
end

function SkynetIADSEWRadar:hasActiveConnectionNode()
	return SkynetIADS.genericCheckOneObjectIsAlive(self.connectionNodes)
end

function SkynetIADSEWRadar:hasWorkingPowerSource()
	return SkynetIADS.genericCheckOneObjectIsAlive(self.powerSources)
end

end