do

SkynetIADS = {}
SkynetIADS.__index = SkynetIADS

SkynetIADS.database = samTypesDB

function SkynetIADS:create(name)
	local iads = {}
	setmetatable(iads, SkynetIADS)
	iads.radioMenu = nil
	iads.earlyWarningRadars = {}
	iads.samSites = {}
	iads.commandCenters = {}
	iads.ewRadarScanMistTaskID = nil
	iads.coalition = nil
	iads.contacts = {}
	iads.maxTargetAge = 32
	iads.name = name
	if iads.name == nil then
		iads.name = ""
	end
	iads.contactUpdateInterval = 5
	iads.debugOutput = {}
	iads.debugOutput.IADSStatus = false
	iads.debugOutput.samWentDark = false
	iads.debugOutput.contacts = false
	iads.debugOutput.radarWentLive = false
	iads.debugOutput.ewRadarNoConnection = false
	iads.debugOutput.samNoConnection = false
	iads.debugOutput.jammerProbability = false
	iads.debugOutput.addedEWRadar = false
	iads.debugOutput.hasNoPower = false
	iads.debugOutput.addedSAMSite = false
	iads.debugOutput.warnings = true
	iads.debugOutput.harmDefence = false
	iads.debugOutput.samSiteStatusEnvOutput = false
	iads.earlyWarningRadarStatusEnvOutput = false
	return iads
end

function SkynetIADS:setCoalition(item)
	if item then
		local coalitionID = item:getCoalition()
		if self.coalitionID == nil then
			self.coalitionID = coalitionID
		end
		if self.coalitionID ~= coalitionID then
			self:printOutput("element: "..item:getName().." has a different coalition than the IADS", true)
		end
	end
end

function SkynetIADS:addJammer(jammer)
	table.insert(self.jammers, jammer)
end

function SkynetIADS:getCoalition()
	return self.coalitionID
end

function SkynetIADS:getDestroyedEarlyWarningRadars()
	local destroyedSites = {}
	for i = 1, #self.earlyWarningRadars do
		local ewSite = self.earlyWarningRadars[i]
		if ewSite:isDestroyed() then
			table.insert(destroyedSites, ewSite)
		end
	end
	return destroyedSites
end

function SkynetIADS:getUsableAbstractRadarElemtentsOfTable(abstractRadarTable)
	local usable = {}
	for i = 1, #abstractRadarTable do
		local abstractRadarElement = abstractRadarTable[i]
		if abstractRadarElement:hasActiveConnectionNode() and abstractRadarElement:hasWorkingPowerSource() and abstractRadarElement:isDestroyed() == false then
			table.insert(usable, abstractRadarElement)
		end
	end
	return usable
end

function SkynetIADS:getUsableEarlyWarningRadars()
	return self:getUsableAbstractRadarElemtentsOfTable(self.earlyWarningRadars)
end

function SkynetIADS:createTableDelegator(units) 
	local sites = SkynetIADSTableDelegator:create()
	for i = 1, #units do
		local site = units[i]
		table.insert(sites, site)
	end
	return sites
end

function SkynetIADS:addEarlyWarningRadarsByPrefix(prefix)
	self:deactivateEarlyWarningRadars()
	self.earlyWarningRadars = {}
	for unitName, unit in pairs(mist.DBs.unitsByName) do
		local pos = self:findSubString(unitName, prefix)
		--somehow the MIST unit db contains StaticObject, we check to see we only add Units
		local unit = Unit.getByName(unitName)
		if pos and pos == 1 and unit then
			self:addEarlyWarningRadar(unitName)
		end
	end
	return self:createTableDelegator(self.earlyWarningRadars)
end

function SkynetIADS:addEarlyWarningRadar(earlyWarningRadarUnitName)
	local earlyWarningRadarUnit = Unit.getByName(earlyWarningRadarUnitName)
	if earlyWarningRadarUnit == nil then
		self:printOutput("you have added an EW Radar that does not exist, check name of Unit in Setup and Mission editor: "..earlyWarningRadarUnitName, true)
		return
	end
	self:setCoalition(earlyWarningRadarUnit)
	local ewRadar = nil
	local category = earlyWarningRadarUnit:getDesc().category
	if category == Unit.Category.AIRPLANE or category == Unit.Category.SHIP then
		ewRadar = SkynetIADSAWACSRadar:create(earlyWarningRadarUnit, self)
	else
		ewRadar = SkynetIADSEWRadar:create(earlyWarningRadarUnit, self)
	end
	ewRadar:setupElements()
	ewRadar:goLive()
	table.insert(self.earlyWarningRadars, ewRadar)
	if self:getDebugSettings().addedEWRadar then
			self:printOutput(ewRadar:getDescription().." added to IADS")
	end
	return ewRadar
end

function SkynetIADS:getEarlyWarningRadars()
	return self:createTableDelegator(self.earlyWarningRadars)
end

function SkynetIADS:getEarlyWarningRadarByUnitName(unitName)
	for i = 1, #self.earlyWarningRadars do
		local ewRadar = self.earlyWarningRadars[i]
		if ewRadar:getDCSName() == unitName then
			return ewRadar
		end
	end
end

function SkynetIADS:findSubString(haystack, needle)
	return string.find(haystack, needle, 1, true)
end

function SkynetIADS:addSAMSitesByPrefix(prefix)
	self:deativateSAMSites()
	self.samSites = {}
	for groupName, groupData in pairs(mist.DBs.groupsByName) do
		local pos = self:findSubString(groupName, prefix)
		if pos and pos == 1 then
			--mist returns groups, units and, StaticObjects
			local dcsObject = Group.getByName(groupName)
			if dcsObject then
				self:addSAMSite(groupName)
			end
		end
	end
	return self:createTableDelegator(self.samSites)
end

function SkynetIADS:getSAMSitesByPrefix(prefix)
	local returnSams = {}
	for i = 1, #self.samSites do
		local samSite = self.samSites[i]
		local groupName = samSite:getDCSRepresentation():getName()
		local pos = self:findSubString(groupName, prefix)
		if pos and pos == 1 then
			table.insert(returnSams, samSite)
		end
	end
	return self:createTableDelegator(returnSams)
end

function SkynetIADS:addSAMSite(samSiteName)
	local samSiteDCS = Group.getByName(samSiteName)
	if samSiteDCS == nil then
		self:printOutput("you have added an SAM Site that does not exist, check name of Group in Setup and Mission editor: "..tostring(samSiteName), true)
		return
	end
	self:setCoalition(samSiteDCS)
	local samSite = SkynetIADSSamSite:create(samSiteDCS, self)
	samSite:setupElements()
	samSite:goLive()
	if samSite:getNatoName() == "UNKNOWN" then
		self:printOutput("you have added an SAM Site that Skynet IADS can not handle: "..samSite:getDCSName(), true)
		samSite:cleanUp()
	else
		samSite:goDark()
		table.insert(self.samSites, samSite)
		if self:getDebugSettings().addedSAMSite then
			self:printOutput(samSite:getDescription().." added to IADS")
		end
		return samSite
	end 
end

function SkynetIADS:getUsableSAMSites()
	return self:getUsableAbstractRadarElemtentsOfTable(self.samSites)
end

function SkynetIADS:getDestroyedSAMSites()
	local destroyedSites = {}
	for i = 1, #self.samSites do
		local samSite = self.samSites[i]
		if samSite:isDestroyed() then
			table.insert(destroyedSites, samSite)
		end
	end
	return destroyedSites
end

function SkynetIADS:getSAMSites()
	return self:createTableDelegator(self.samSites)
end

function SkynetIADS:getActiveSAMSites()
	local activeSAMSites = {}
	for i = 1, #self.samSites do
		if self.samSites[i]:isActive() then
			table.insert(activeSAMSites, self.samSites[i])
		end
	end
	return activeSAMSites
end

function SkynetIADS:getSAMSiteByGroupName(groupName)
	for i = 1, #self.samSites do
		local samSite = self.samSites[i]
		if samSite:getDCSName() == groupName then
			return samSite
		end
	end
end

function SkynetIADS:getSAMSitesByNatoName(natoName)
	local selectedSAMSites = SkynetIADSTableDelegator:create()
	for i = 1, #self.samSites do
		local samSite = self.samSites[i]
		if samSite:getNatoName() == natoName then
			table.insert(selectedSAMSites, samSite)
		end
	end
	return selectedSAMSites
end

function SkynetIADS:addCommandCenter(commandCenter)
	self:setCoalition(commandCenter)
	local comCenter = SkynetIADSCommandCenter:create(commandCenter, self)
	table.insert(self.commandCenters, comCenter)
	return comCenter
end

function SkynetIADS:isCommandCenterUsable()
	local hasWorkingCommandCenter = (#self.commandCenters == 0)
	for i = 1, #self.commandCenters do
		local comCenter = self.commandCenters[i]
		if comCenter:isDestroyed() == false and comCenter:hasWorkingPowerSource() then
			hasWorkingCommandCenter = true
			break
		else
			hasWorkingCommandCenter = false
		end
	end
	return hasWorkingCommandCenter
end

function SkynetIADS:getCommandCenters()
	return self.commandCenters
end

function SkynetIADS:setSAMSitesToAutonomousMode()
	for i= 1, #self.samSites do
		samSite = self.samSites[i]
		samSite:goAutonomous()
	end
end

function SkynetIADS.evaluateContacts(self)
	if self:isCommandCenterUsable() == false then
		if self:getDebugSettings().noWorkingCommmandCenter then
			self:printOutput("No Working Command Center")
		end
		self:setSAMSitesToAutonomousMode()
		return
	end
	
	self:updateSAMSitesIfNoEWRadarCoverage()
	
	local ewRadars = self:getUsableEarlyWarningRadars()
	for i = 1, #ewRadars do
		local ewRadar = ewRadars[i]
		--call go Live in case ewRadar had to shut down (HARM attack)
		ewRadar:goLive()
		local ewContacts = ewRadar:getDetectedTargets()
		for j = 1, #ewContacts do
			local contact = ewContacts[j]
			self:mergeContact(contact)
		end
	end
	
	local usableSamSites = self:getUsableSAMSites()
	for i = 1, #usableSamSites do
		local samSite = usableSamSites[i]
		--see if this can be written with better code. We inform SAM sites that a target update is about to happen. if they have no targets in range after the cycle they go dark
		samSite:targetCycleUpdateStart()
		local samContacts = samSite:getDetectedTargets()
		for j = 1, #samContacts do
			local contact = samContacts[j]
			self:mergeContact(contact)
		end
	end

--[[	
	local contactsToKeep = {}
	for i = 1, #self.contacts do
		local contact = self.contacts[i]
		if contact:getAge() < self.maxTargetAge then
			table.insert(contactsToKeep, contact)
		end
	end
	self.contacts = contactsToKeep
--]]	
	
	for i = 1, #self.contacts do
		local contact = self.contacts[i]
		-- the DCS Radar only returns enemy aircraft, if that should change an coalition check will be required
		-- currently every type of object in the air is handed of to the sam site, including missiles
		local description = contact:getDesc()
		local category = description.category
		if category and category ~= Unit.Category.GROUND_UNIT and category ~= Unit.Category.SHIP and category ~= Unit.Category.STRUCTURE then
			self:correlateWithSAMSites(contact)
		end
	end
	
	for i = 1, #usableSamSites do
		local samSite = usableSamSites[i]
		samSite:targetCycleUpdateEnd()
	end
	
	self:printSystemStatus()
end

function SkynetIADS:updateSAMSitesIfNoEWRadarCoverage()
	local ewRadars = self:getUsableEarlyWarningRadars()
	local samSites = self:getUsableSAMSites()
		
	for i = 1, #samSites do
		local samSite = samSites[i]
		if samSite:getActAsEW() then
			table.insert(ewRadars, samSite)
		end
	end

	for i = 1, #samSites do
		local samSite = samSites[i]
		local inRange = false
		for j = 1, #ewRadars do
			if samSite:isInRadarDetectionRangeOf(ewRadars[j]) then
				inRange = true
			end
		end
		if inRange == false then
			samSite:goAutonomous()
		else
			samSite:resetAutonomousState()
		end
	end
end

function SkynetIADS:mergeContact(contact)
	local existingContact = false
	for i = 1, #self.contacts do
		local iadsContact = self.contacts[i]
		if iadsContact:getName() == contact:getName() then
			iadsContact:refresh()
			existingContact = true
		end
	end
	if existingContact == false then
		table.insert(self.contacts, contact)
	end
end

function SkynetIADS:getContacts()
	return self.contacts
end

function SkynetIADS:printOutput(output, typeWarning)
	if typeWarning == true and self.debugOutput.warnings or typeWarning == nil then
		if typeWarning == true then
			output = "WARNING: "..output
		end
		trigger.action.outText(output, 4)
	end
end

function SkynetIADS:getDebugSettings()
	return self.debugOutput
end

function SkynetIADS:correlateWithSAMSites(detectedAircraft)	
	local usableSamSites = self:getUsableSAMSites()
	for i = 1, #usableSamSites do
		local samSite = usableSamSites[i]		
		samSite:informOfContact(detectedAircraft)
	end
end

-- will start going through the Early Warning Radars and SAM sites to check what targets they have detected
function SkynetIADS:activate()
	mist.removeFunction(self.ewRadarScanMistTaskID)
	self.ewRadarScanMistTaskID = mist.scheduleFunction(SkynetIADS.evaluateContacts, {self}, 1, self.contactUpdateInterval)
end

function SkynetIADS:deactivate()
	mist.removeFunction(self.ewRadarScanMistTaskID)
	self:deativateSAMSites()
	self:deactivateEarlyWarningRadars()
	self:deactivateCommandCenters()
end

function SkynetIADS:deactivateCommandCenters()
	for i = 1, #self.commandCenters do
		local comCenter = self.commandCenters[i]
		comCenter:cleanUp()
	end
end

function SkynetIADS:deativateSAMSites()
	for i = 1, #self.samSites do
		local samSite = self.samSites[i]
		samSite:cleanUp()
	end
end

function SkynetIADS:deactivateEarlyWarningRadars()
	for i = 1, #self.earlyWarningRadars do
		local ewRadar = self.earlyWarningRadars[i]
		ewRadar:cleanUp()
	end
end	

function SkynetIADS:addRadioMenu()
	self.radioMenu = missionCommands.addSubMenu('SKYNET IADS '..self:getCoalitionString())
	local displayIADSStatus = missionCommands.addCommand('show IADS Status', self.radioMenu, SkynetIADS.updateDisplay, {self = self, value = true, option = 'IADSStatus'})
	local displayIADSStatus = missionCommands.addCommand('hide IADS Status', self.radioMenu, SkynetIADS.updateDisplay, {self = self, value = false, option = 'IADSStatus'})
	local displayIADSStatus = missionCommands.addCommand('show contacts', self.radioMenu, SkynetIADS.updateDisplay, {self = self, value = true, option = 'contacts'})
	local displayIADSStatus = missionCommands.addCommand('hide contacts', self.radioMenu, SkynetIADS.updateDisplay, {self = self, value = false, option = 'contacts'})
end

function SkynetIADS:removeRadioMenu()
	missionCommands.removeItem(self.radioMenu)
end

function SkynetIADS.updateDisplay(params)
	local option = params.option
	local self = params.self
	local value = params.value
	if option == 'IADSStatus' then
		self:getDebugSettings()[option] = value
	elseif option == 'contacts' then
		self:getDebugSettings()[option] = value
	end
end

function SkynetIADS:getCoalitionString()
	local coalitionStr = "RED"
	if self.coalitionID == coalition.side.BLUE then
		coalitionStr = "BLUE"
	elseif self.coalitionID == coalition.side.NEUTRAL then
		coalitionStr = "NEUTRAL"
	end
		
	if self.name then
		coalitionStr = coalitionStr.." "..self.name
	end
	
	return coalitionStr
end

function SkynetIADS:printDetailedEarlyWarningRadarStatus()
	local ewRadars = self:getEarlyWarningRadars()
	env.info("------------------------------------------ EW RADAR STATUS: "..self:getCoalitionString().." -------------------------------")
	for i = 1, #ewRadars do
		local ewRadar = ewRadars[i]
		local numConnectionNodes = #ewRadar:getConnectionNodes()
		local numPowerSources = #ewRadar:getPowerSources()
		local isActive = ewRadar:isActive()
		local connectionNodes = ewRadar:getConnectionNodes()
		local firstRadar = nil
		local radars = ewRadar:getRadars()
		
		--get the first existing radar to prevent issues in calculating the distance later on:
		for i = 1, #radars do
			if radars[i]:isExist() then
				firstRadar = radars[i]
				break
			end
		
		end
		local numDamagedConnectionNodes = 0
		
		
		for j = 1, #connectionNodes do
			local connectionNode = connectionNodes[j]
			if connectionNode:isExist() == false then
				numDamagedConnectionNodes = numDamagedConnectionNodes + 1
			end
		end
		local intactConnectionNodes = numConnectionNodes - numDamagedConnectionNodes
		
		local powerSources = ewRadar:getPowerSources()
		local numDamagedPowerSources = 0
		for j = 1, #powerSources do
			local powerSource = powerSources[j]
			if powerSource:isExist() == false then
				numDamagedPowerSources = numDamagedPowerSources + 1
			end
		end
		local intactPowerSources = numPowerSources - numDamagedPowerSources 
		
		local detectedTargets = ewRadar:getDetectedTargets()
		
		local unitName = "DESTROYED"
		
		if ewRadar:getDCSRepresentation():isExist() then
			unitName = ewRadar:getDCSRepresentation():getName()
		end
		
		env.info("UNIT: "..unitName.." | TYPE: "..ewRadar:getNatoName())
		env.info("ACTIVE: "..tostring(isActive).."| DETECTED TARGETS: "..#detectedTargets.." | DEFENDING HARM: "..tostring(ewRadar:isDefendingHARM()))
		if numConnectionNodes > 0 then
			env.info("CONNECTION NODES: "..numConnectionNodes.." | DAMAGED: "..numDamagedConnectionNodes.." | INTACT: "..intactConnectionNodes)
		else
			env.info("NO CONNECTION NODES SET")
		end
		if numPowerSources > 0 then
			env.info("POWER SOURCES : "..numPowerSources.." | DAMAGED:"..numDamagedPowerSources.." | INTACT: "..intactPowerSources)
		else
			env.info("NO POWER SOURCES SET")
		end
		
		for j = 1, #detectedTargets do
			local contact = detectedTargets[j]
			local distance = mist.utils.round(mist.utils.metersToNM(ewRadar:getDistanceInMetersToContact(firstRadar:getDCSRepresentation(), contact:getPosition().p)), 2)
			env.info("CONTACT: "..contact:getName().." | TYPE: "..contact:getTypeName().." | DISTANCE NM: "..distance)
		end
		
		env.info("---------------------------------------------------")
		
	end

end

function SkynetIADS:printDetailedSAMSiteStatus()
	local samSites = self:getSAMSites()
	
	env.info("------------------------------------------ SAM STATUS: "..self:getCoalitionString().." -------------------------------")
	for i = 1, #samSites do
		local samSite = samSites[i]
		local numConnectionNodes = #samSite:getConnectionNodes()
		local numPowerSources = #samSite:getPowerSources()
		local isAutonomous = samSite:getAutonomousState()
		local isActive = samSite:isActive()
		
		local connectionNodes = samSite:getConnectionNodes()
		local firstRadar = samSite:getRadars()[1]
		local numDamagedConnectionNodes = 0
		for j = 1, #connectionNodes do
			local connectionNode = connectionNodes[j]
			if connectionNode:isExist() == false then
				numDamagedConnectionNodes = numDamagedConnectionNodes + 1
			end
		end
		local intactConnectionNodes = numConnectionNodes - numDamagedConnectionNodes
		
		local powerSources = samSite:getPowerSources()
		local numDamagedPowerSources = 0
		for j = 1, #powerSources do
			local powerSource = powerSources[j]
			if powerSource:isExist() == false then
				numDamagedPowerSources = numDamagedPowerSources + 1
			end
		end
		local intactPowerSources = numPowerSources - numDamagedPowerSources 
		
		local detectedTargets = samSite:getDetectedTargets()
		
		env.info("GROUP: "..samSite:getDCSRepresentation():getName().." | TYPE: "..samSite:getNatoName())
		env.info("ACTIVE: "..tostring(isActive).." | AUTONOMOUS: "..tostring(isAutonomous).." | IS ACTING AS EW: "..tostring(samSite:getActAsEW()).." | DETECTED TARGETS: "..#detectedTargets.." | DEFENDING HARM: "..tostring(samSite:isDefendingHARM()))
		if numConnectionNodes > 0 then
			env.info("CONNECTION NODES: "..numConnectionNodes.." | DAMAGED: "..numDamagedConnectionNodes.." | INTACT: "..intactConnectionNodes)
		else
			env.info("NO CONNECTION NODES SET")
		end
		if numPowerSources > 0 then
			env.info("POWER SOURCES : "..numPowerSources.." | DAMAGED:"..numDamagedPowerSources.." | INTACT: "..intactPowerSources)
		else
			env.info("NO POWER SOURCES SET")
		end
		
	
		
		for j = 1, #detectedTargets do
			local contact = detectedTargets[j]
			local distance = mist.utils.round(mist.utils.metersToNM(samSite:getDistanceInMetersToContact(firstRadar:getDCSRepresentation(), contact:getPosition().p)), 2)
			env.info("CONTACT: "..contact:getName().." | TYPE: "..contact:getTypeName().." | DISTANCE NM: "..distance)
		end
		
		env.info("---------------------------------------------------")
	end
end

function SkynetIADS:printSystemStatus()	

	if self:getDebugSettings().IADSStatus or self:getDebugSettings().contacts then
		local coalitionStr = self:getCoalitionString()
		self:printOutput("---- IADS: "..coalitionStr.." ------")
	end
	
	if self:getDebugSettings().IADSStatus then

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
			if commandCenter:isDestroyed() == false then
				numIntactComCenters = numIntactComCenters + 1
			end
			if commandCenter:isDestroyed() == false and commandCenter:hasWorkingPowerSource() then
				numComCentersServingIADS = numComCentersServingIADS + 1
			end
		end
		
		numDestroyedComCenters = numComCenters - numIntactComCenters
		
		
		self:printOutput("COMMAND CENTERS: Serving IADS: "..numComCentersServingIADS.." | Total: "..numComCenters.." | Intact: "..numIntactComCenters.." | Destroyed: "..numDestroyedComCenters.." | NoPower: "..numComCentersNoPower)
		
		local ewNoPower = 0
		local ewTotal = #self:getEarlyWarningRadars()
		local ewNoConnectionNode = 0
		local ewActive = 0
		local ewRadarsInactive = 0

		for i = 1, #self.earlyWarningRadars do
			local ewRadar = self.earlyWarningRadars[i]
			if ewRadar:hasWorkingPowerSource() == false then
				ewNoPower = ewNoPower + 1
			end
			if ewRadar:hasActiveConnectionNode() == false then
				ewNoConnectionNode = ewNoConnectionNode + 1
			end
			if ewRadar:isActive() then
				ewActive = ewActive + 1
			end
		end
		
		ewRadarsInactive = ewTotal - ewActive	
		local numEWRadarsDestroyed = #self:getDestroyedEarlyWarningRadars()
		self:printOutput("EW: "..ewTotal.." | Act: "..ewActive.." | Inact: "..ewRadarsInactive.." | Destroyed: "..numEWRadarsDestroyed.." | NoPowr: "..ewNoPower.." | NoCon: "..ewNoConnectionNode)
		
		local samSitesInactive = 0
		local samSitesActive = 0
		local samSitesTotal = #self:getSAMSites()
		local samSitesNoPower = 0
		local samSitesNoConnectionNode = 0
		local samSitesOutOfAmmo = 0
		local samSiteAutonomous = 0
		local samSiteRadarDestroyed = 0
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
			if samSite:hasRemainingAmmo() == false then
				samSitesOutOfAmmo = samSitesOutOfAmmo + 1
			end
			if samSite:getAutonomousState() == true then
				samSiteAutonomous = samSiteAutonomous + 1
			end
			if samSite:hasWorkingRadar() == false then
				samSiteRadarDestroyed = samSiteRadarDestroyed + 1
			end
		end
		
		samSitesInactive = samSitesTotal - samSitesActive
		self:printOutput("SAM: "..samSitesTotal.." | Act: "..samSitesActive.." | Inact: "..samSitesInactive.." | Autonm: "..samSiteAutonomous.." | Raddest: "..samSiteRadarDestroyed.." | NoPowr: "..samSitesNoPower.." | NoCon: "..samSitesNoConnectionNode.." | NoAmmo: "..samSitesOutOfAmmo)
	end
	if self:getDebugSettings().contacts then
		for i = 1, #self.contacts do
			local contact = self.contacts[i]
				self:printOutput("CONTACT: "..contact:getName().." | TYPE: "..contact:getTypeName().." | GS: "..tostring(contact:getGroundSpeedInKnots()).." | LAST SEEN: "..contact:getAge())
		end
	end
	
	if self:getDebugSettings().earlyWarningRadarStatusEnvOutput then
		self:printDetailedEarlyWarningRadarStatus()
	end
	
	if self:getDebugSettings().samSiteStatusEnvOutput then
		self:printDetailedSAMSiteStatus()
	end
end

end
