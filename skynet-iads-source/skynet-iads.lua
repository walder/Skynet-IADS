do

--V 1.0:
-- TODO: Jamming dependening on SAM Radar Type and Distance
-- TODO: Sanity checks when adding elements, print errors regardless of debug state
-- TODO: remove contact in sam site if its out of range, it could be a IADS stops working while a SAM site is tracking a target --> or does this not matter due to DCS AI?
-- TODO: Update power handling autonomous sam may go live withouth power same for ew radar. Same for Connection Node dammage
-- TODO: after one connection node or powerplant goes down and there are others, add a delay until the sam site comes online again (configurable)
-- TODO: check if SAM has LOS to target, if not, it should not activate
-- TODO: SA-10 Launch distance seems off
-- TODO: create abstracts IADSItem class and place base function there, other elements shall inherit
-- TODO: add error message when unknown SAM group is added
-- TODO: add coalition checks for power sources, and connection nodes
-- TODO: Update github documentation, add graphic overview of IADS elements, screenthots of mission editor setup, code examples
-- TODO: if jammer source dies, jammer should stop 

-- To test: shall sam turn ai off or set state to green, when going dark? Does one method have an advantage?
-- To test: different kinds of Sam types, damage to power source, command center, connection nodes
-- To test: which SAM Types can engage air weapons, especially HARMs?

-- V 1.1:
-- TODO: code HARM defence, check if SAM Site or EW sees HARM, only then start defence
-- TODO: SAM could have decoy emitters to trick HARM in to homing in to the wrong radar
-- TODO: extrapolate flight path to get SAM to active so that it can fire as aircraft aproaches max range	
-- TODO: add sneaky sam tactics, like stay dark until bandit has passed the sam then go live
-- TODO: if SAM site has run out of missiles shut it down
-- TODO: merge SAM contacts with the ones it gets from the IADS, it could be that the SAM sees something the IADS does not know about, later on add this data back to the IADS
-- TODO: ad random failures in IFF so enemy planes trigger IADS SAM activation by mistake
-- TODO: check contact type coalition of detected IADS target only if its an enemy trigger sam, currently only enemy aircraft are returned by a DCS radar
-- TODO: Electronic Warfare: add multiple planes via script around the Jamming Group, get SAM to target those

SkynetIADS = {}
SkynetIADS.__index = SkynetIADS

SkynetIADS.database = samTypesDB

function SkynetIADS:create()
	local iads = {}
	setmetatable(iads, SkynetIADS)
	iads.earlyWarningRadars = {}
	iads.samSites = {}
	iads.commandCenters = {}
	iads.ewRadarScanMistTaskID = nil
	iads.coalition = nil
	self.debugOutput = {}
	self.debugOutput.IADSStatus = false
	self.debugOutput.samWentDark = false
	self.debugOutput.contacts = false
	self.debugOutput.samWentLive = false
	self.debugOutput.ewRadarNoConnection = false
	self.debugOutput.samNoConnection = false
	return iads
end

function SkynetIADS.getDBName(samGroup, natoName)
	local units = samGroup:getUnits()
	local samDBName = "UNKNOWN"
	local unitData = nil
	local typeName = nil
	for i = 1, #units do
		typeName = units[i]:getTypeName()
		for samName, samData in pairs(SkynetIADS.database) do
			--all Sites have a unique launcher, if we find one, we got the internal designator of the SAM unit
			unitData = SkynetIADS.database[samName]
			if unitData['launchers'] and unitData['launchers'][typeName] then
			--	trigger.action.outText("Element is a: "..samName, 1)
				if natoName then
					return SkynetIADS.database[samName]['name']['NATO']
				else
					return samName
				end	
			else
				--trigger.action.outText("no launcher data: "..typeName, 1)
			end
		end
	end
	return samDBName
end

function SkynetIADS:addSamSitesByPrefix(prefix)
	for groupName, groupData in pairs(mist.DBs.groupsByName) do
		local pos = string.find(string.lower(groupName), string.lower(prefix))
		if string.find(string.lower(groupName), string.lower(prefix)) == 1 then
			self:addSamSite(groupName)
		end
	end
end

function SkynetIADS:addEarlyWarningRadarsByPrefix(prefix)
	for unitName, groupData in pairs(mist.DBs.unitsByName) do
		local pos = string.find(string.lower(unitName), string.lower(prefix))
		if string.find(string.lower(unitName), string.lower(prefix)) == 1 then
			self:addEarlyWarningRadar(unitName)
		end
	end
end

function SkynetIADS:setCoalition(coalitionID)
	if self.coalitionID == nil then
		self.coalitionID = coalitionID
	elseif self.coalitionID ~= coalitionID then
		trigger.action.outText("WARNING: you have added different coalitions to the same IADS", 20)
	end
end

function SkynetIADS:getCoalition()
	return self.coalitionID
end

function SkynetIADS:getSamSites()
	return self.samSites
end

function SkynetIADS:addEarlyWarningRadar(earlyWarningRadarUnitName, powerSource, connectionNode)
	local earlyWarningRadarUnit = Unit.getByName(earlyWarningRadarUnitName)
	if earlyWarningRadarUnit == nil then
		trigger.action.outText("WARNING: You have added an EW Radar that does not exist, check name of Unit in Setup and Mission editor", 10)
		return
	end
	self:setCoalition(earlyWarningRadarUnit:getCoalition())
	local ewRadar = SkynetIADSEWRadar:create(earlyWarningRadarUnit)
	ewRadar:addPowerSource(powerSource)
	ewRadar:addConnectionNode(connectionNode)
	table.insert(self.earlyWarningRadars, ewRadar)
end

function SkynetIADS.isWeaponHarm(weapon)
	local desc = weapon:getDesc()
	return (desc.missileCategory == 6 and desc.guidance == 5)	
end

function SkynetIADS:addSamSite(samSiteName, powerSource, connectionNode, autonomousMode)
	local samSite = Group.getByName(samSiteName)
	if samSite == nil then
		trigger.action.outText("You have added an SAM Site that does not exist, check name of Group in Setup and Mission editor", 10)
		return
	end
	self:setCoalition(samSite:getCoalition())
	local samSite = SkynetIADSSamSite:create(samSite, self)
	samSite:addPowerSource(powerSource)
	samSite:addConnectionNode(connectionNode)
	samSite:setAutonomousMode(autonomousMode)
	table.insert(self.samSites, samSite)
end

function SkynetIADS:addCommandCenter(commandCenter, powerSource)
	self:setCoalition(commandCenter:getCoalition())
	if powerSource then
		self:setCoalition(powerSource:getCoalition())
	end
	local comCenter = SkynetIADSCommandCenter:create(commandCenter)
	comCenter:addPowerSource(powerSource)
	table.insert(self.commandCenters, comCenter)
end

-- generic function to theck if powerplants, command centers, connection nodes are still alive
function SkynetIADS.genericCheckOneObjectIsAlive(objects)
	local isAlive = (#objects == 0)
	for i = 1, #objects do
		local object = objects[i]
	--	trigger.action.outText("life: "..object:getLife(), 1)
		--if we find one object that is not fully destroyed we assume the IADS is still working
		if object:getLife() > 0 then
			isAlive = true
			break
		end
	end
	return isAlive
end

function SkynetIADS:isCommandCenterAlive()
	local hasWorkingCommandCenter = (#self.commandCenters == 0)
	for i = 1, #self.commandCenters do
		local comCenter = self.commandCenters[i]
		if comCenter:getLife() > 0 then
			hasWorkingCommandCenter = true
			break
		else
			hasWorkingCommandCenter = false
		end
	end
	return hasWorkingCommandCenter
end

function SkynetIADS:setSamSitesToAutonomousMode()
	for i= 1, #self.samSites do
		samSite = self.samSites[i]
		samSite:goAutonomous()
	end
end

function SkynetIADS.evaluateContacts(self) 
	local iadsContacts = {}
	if self:isCommandCenterAlive() == false then
		if self:getDebugSettings().noWorkingCommmandCenter then
			self:printOutput("No Working Command Center")
		end
		self:setSamSitesToAutonomousMode()
		return
	end
	for i = 1, #self.earlyWarningRadars do
		local ewRadar = self.earlyWarningRadars[i]
		if ewRadar:hasActiveConnectionNode() then
			local ewContacts = ewRadar:getDetectedTargets()
			for j = 1, #ewContacts do
				--trigger.action.outText(ewContacts[j]:getName(), 1)
				iadsContacts[ewContacts[j]:getName()] = ewContacts[j]
				--trigger.action.outText(ewRadar:getDescription().." has detected: "..ewContacts[j]:getName(), 1)	
			end
		else
			if self:getDebugSettings().ewRadarNoConnection then
				self:printOutput(ewRadar:getDescription().." no connection to command center")
			end
		end
	end
	for unitName, unit in pairs(iadsContacts) do
		if self:getDebugSettings().contacts then
			self:printOutput("IADS Contact: "..unitName)
		end
		--currently the DCS Radar only returns enemy aircraft, if that should change an coalition check will be required
		--if unit:getCoalition() ~= self:getCoalition() then
		---Todo: currently every type of object in the air is handed of to the sam site, including bombs and missiles, shall these be removed?
		self:correlateWithSamSites(unit)
		--end
	end
	
	if self:getDebugSettings().IADSStatus then
		self:printSystemStatus()
	end	
end

function SkynetIADS:printOutput(output)
	trigger.action.outText(output, 4)
end

function SkynetIADS:getDebugSettings()
	return self.debugOutput
end

function SkynetIADS:startHarmDefence(inBoundHarm)
	--TODO: store ID of task so it can be stopped when sam or harm is destroyed
	mist.scheduleFunction(SkynetIADS.harmDefence, {self, inBoundHarm}, 1, 1)	
end

function SkynetIADS:correlateWithSamSites(detectedAircraft)
	for i= 1, #self.samSites do
		local samSite = self.samSites[i]
		if samSite:hasActiveConnectionNode() == true then
			samSite:handOff(detectedAircraft)
		else
			if self:getDebugSettings().samNoConnection then
				self:printOutput(samSite:getDescription().." no connection Command center")
				samSite:goAutonomous()
			end
		end
	end
end

-- will start going through the Early Warning Radars to check what targets they have detected
function SkynetIADS:activate()
	if self.ewRadarScanMistTaskID ~= nil then
		mist.removeFunction(self.ewRadarScanMistTaskID)
	end
	self.ewRadarScanMistTaskID = mist.scheduleFunction(SkynetIADS.evaluateContacts, {self}, 1, 5)
end

function SkynetIADS:printSystemStatus()
	
	local numComCenters = #self.commandCenters
	local numIntactComCenters = 0
	local numDestroyedComCenters = 0
	local numComCentersNoPower = 0
	local numComCentersServingIADS = 0
	for i = 1, #self.commandCenters do
		local commandCenter = self.commandCenters[i]
		if commandCenter:hasWorkingPowerSource() == false then
			numComCentersNoPower = numComCentersNoPower + 1
		end
		if commandCenter:getLife() > 0 then
			numIntactComCenters = numIntactComCenters + 1
		end
		if commandCenter:getLife() > 0 and commandCenter:hasWorkingPowerSource() then
			numComCentersServingIADS = numComCentersServingIADS + 1
		end
	end
	
	numDestroyedComCenters = numComCenters - numIntactComCenters
	
	self:printOutput("COMMAND CENTERS: Serving IADS: "..numComCentersServingIADS.." | Total: "..numComCenters.." | Intact: "..numIntactComCenters.." | Destroyed: "..numDestroyedComCenters.." | No Power: "..numComCentersNoPower)
	
	local ewNoPower = 0
	local ewTotal = #self.earlyWarningRadars
	local ewNoConnectionNode = 0
	
	for i = 1, #self.earlyWarningRadars do
		local ewRadar = self.earlyWarningRadars[i]
		if ewRadar:hasWorkingPowerSource() == false then
			ewNoPower = ewNoPower + 1
		end
		if ewRadar:hasActiveConnectionNode() == false then
			ewNoConnectionNode = ewNoConnectionNode + 1
		end
	end
	self:printOutput("EW SITES: "..ewTotal.." | Active: "..ewTotal.." | Inactive: 0 | No Power: "..ewNoPower.." | No Connection: "..ewNoConnectionNode)
	
	local samSitesInactive = 0
	local samSitesActive = 0
	local samSitesTotal = #self.samSites
	local samSitesNoPower = 0
	local samSitesNoConnectionNode = 0
	for i = 1, #self.samSites do
		local samSite = self.samSites[i]
		if samSite:hasWorkingPowerSource() == false then
			samSitesNoPower = samSitesNoPower + 1
		end
		if samSite:hasActiveConnectionNode() == false then
			samSitesNoConnectionNode = samSitesNoConnectionNode + 1
		end
		if samSite:isActive() then
			samSitesActive = samSitesActive + 1
		end
	end
	samSitesInactive = samSitesTotal - samSitesActive
	self:printOutput("SAM SITES: "..samSitesTotal.." | Active: "..samSitesActive.." | Inactive: "..samSitesInactive.." | No Power: "..samSitesNoPower.." | No Connection: "..samSitesNoConnectionNode)
end

end