do

SkynetIADSLogger = {}
SkynetIADSLogger.__index = SkynetIADSLogger

function SkynetIADSLogger:create(iads)
	local logger = {}
	setmetatable(logger, SkynetIADSLogger)
	logger.debugOutput = {}
	logger.debugOutput.IADSStatus = false
	logger.debugOutput.samWentDark = false
	logger.debugOutput.contacts = false
	logger.debugOutput.radarWentLive = false
	logger.debugOutput.jammerProbability = false
	logger.debugOutput.addedEWRadar = false
	logger.debugOutput.addedSAMSite = false
	logger.debugOutput.warnings = true
	logger.debugOutput.harmDefence = false
	logger.debugOutput.samSiteStatusEnvOutput = false
	logger.debugOutput.earlyWarningRadarStatusEnvOutput = false
	logger.debugOutput.commandCenterStatusEnvOutput = false
	logger.iads = iads
	return logger
end

function SkynetIADSLogger:getDebugSettings()
	return self.debugOutput
end

function SkynetIADSLogger:printOutput(output, typeWarning)
	if typeWarning == true and self:getDebugSettings().warnings or typeWarning == nil then
		if typeWarning == true then
			output = "WARNING: "..output
		end
		trigger.action.outText(output, 4)
	end
end

function SkynetIADSLogger:printOutputToLog(output)
	env.info("SKYNET: "..output, 4)
end

function SkynetIADSLogger:printEarlyWarningRadarStatus()
	local ewRadars = self.iads:getEarlyWarningRadars()
	self:printOutputToLog("------------------------------------------ EW RADAR STATUS: "..self.iads:getCoalitionString().." -------------------------------")
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
		local samSitesInCoveredArea = ewRadar:getChildRadars()
		
		local unitName = "DESTROYED"
		
		if ewRadar:getDCSRepresentation():isExist() then
			unitName = ewRadar:getDCSName()
		end
		
		self:printOutputToLog("UNIT: "..unitName.." | TYPE: "..ewRadar:getNatoName())
		self:printOutputToLog("ACTIVE: "..tostring(isActive).."| DETECTED TARGETS: "..#detectedTargets.." | DEFENDING HARM: "..tostring(ewRadar:isDefendingHARM()))
		if numConnectionNodes > 0 then
			self:printOutputToLog("CONNECTION NODES: "..numConnectionNodes.." | DAMAGED: "..numDamagedConnectionNodes.." | INTACT: "..intactConnectionNodes)
		else
			self:printOutputToLog("NO CONNECTION NODES SET")
		end
		if numPowerSources > 0 then
			self:printOutputToLog("POWER SOURCES : "..numPowerSources.." | DAMAGED:"..numDamagedPowerSources.." | INTACT: "..intactPowerSources)
		else
			self:printOutputToLog("NO POWER SOURCES SET")
		end
		
		self:printOutputToLog("SAM SITES IN COVERED AREA: "..#samSitesInCoveredArea)
		for j = 1, #samSitesInCoveredArea do
			local samSiteCovered = samSitesInCoveredArea[j]
			self:printOutputToLog(samSiteCovered:getDCSName())
		end
		
		for j = 1, #detectedTargets do
			local contact = detectedTargets[j]
			if firstRadar ~= nil and firstRadar:isExist() then
				local distance = mist.utils.round(mist.utils.metersToNM(ewRadar:getDistanceInMetersToContact(firstRadar:getDCSRepresentation(), contact:getPosition().p)), 2)
				self:printOutputToLog("CONTACT: "..contact:getName().." | TYPE: "..contact:getTypeName().." | DISTANCE NM: "..distance)
			end
		end
		
		self:printOutputToLog("---------------------------------------------------")
		
	end

end

function SkynetIADSLogger:getMetaInfo(abstractElementSupport)
	local info = {}
	info.numSources = #abstractElementSupport
	info.numDamagedSources = 0
	info.numIntactSources = 0
	for j = 1, #abstractElementSupport do
		local source = abstractElementSupport[j]
		if source:isExist() == false then
			info.numDamagedSources = info.numDamagedSources + 1
		end
	end
	info.numIntactSources = info.numSources - info.numDamagedSources
	return info
end

function SkynetIADSLogger:printSAMSiteStatus()
	local samSites = self.iads:getSAMSites()
	
	self:printOutputToLog("------------------------------------------ SAM STATUS: "..self.iads:getCoalitionString().." -------------------------------")
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
		
		local samSitesInCoveredArea = samSite:getChildRadars()
		
		local engageAirWeapons = samSite:getCanEngageAirWeapons()
		
		local engageHARMS = samSite:getCanEngageHARM()
		
		local hasAmmo = samSite:hasRemainingAmmo()
		
		self:printOutputToLog("GROUP: "..samSite:getDCSName().." | TYPE: "..samSite:getNatoName())
		self:printOutputToLog("ACTIVE: "..tostring(isActive).." | AUTONOMOUS: "..tostring(isAutonomous).." | IS ACTING AS EW: "..tostring(samSite:getActAsEW()).." | CAN ENGAGE AIR WEAPONS : "..tostring(engageAirWeapons).." | CAN ENGAGE HARMS : "..tostring(engageHARMS).." | HAS AMMO: "..tostring(hasAmmo).." | DETECTED TARGETS: "..#detectedTargets.." | DEFENDING HARM: "..tostring(samSite:isDefendingHARM()).." | MISSILES IN FLIGHT: "..tostring(samSite:getNumberOfMissilesInFlight()))
		
		if numConnectionNodes > 0 then
			self:printOutputToLog("CONNECTION NODES: "..numConnectionNodes.." | DAMAGED: "..numDamagedConnectionNodes.." | INTACT: "..intactConnectionNodes)
		else
			self:printOutputToLog("NO CONNECTION NODES SET")
		end
		if numPowerSources > 0 then
			self:printOutputToLog("POWER SOURCES : "..numPowerSources.." | DAMAGED:"..numDamagedPowerSources.." | INTACT: "..intactPowerSources)
		else
			self:printOutputToLog("NO POWER SOURCES SET")
		end
		
		self:printOutputToLog("SAM SITES IN COVERED AREA: "..#samSitesInCoveredArea)
		for j = 1, #samSitesInCoveredArea do
			local samSiteCovered = samSitesInCoveredArea[j]
			self:printOutputToLog(samSiteCovered:getDCSName())
		end
		
		for j = 1, #detectedTargets do
			local contact = detectedTargets[j]
			if firstRadar ~= nil and firstRadar:isExist() then
				local distance = mist.utils.round(mist.utils.metersToNM(samSite:getDistanceInMetersToContact(firstRadar:getDCSRepresentation(), contact:getPosition().p)), 2)
				self:printOutputToLog("CONTACT: "..contact:getName().." | TYPE: "..contact:getTypeName().." | DISTANCE NM: "..distance)
			end
		end
		
		self:printOutputToLog("---------------------------------------------------")
	end
end

function SkynetIADSLogger:printCommandCenterStatus()
	local commandCenters = self.iads:getCommandCenters()
	self:printOutputToLog("------------------------------------------ COMMAND CENTER STATUS: "..self.iads:getCoalitionString().." -------------------------------")
	
	for i = 1, #commandCenters do
		local commandCenter = commandCenters[i]
		local numConnectionNodes = #commandCenter:getConnectionNodes()
		local powerSourceInfo = self:getMetaInfo(commandCenter:getPowerSources())
		local connectionNodeInfo = self:getMetaInfo(commandCenter:getConnectionNodes())
		self:printOutputToLog("GROUP: "..commandCenter:getDCSName().." | TYPE: "..commandCenter:getNatoName())
		if connectionNodeInfo.numSources > 0 then
			self:printOutputToLog("CONNECTION NODES: "..connectionNodeInfo.numSources.." | DAMAGED: "..connectionNodeInfo.numDamagedSources.." | INTACT: "..connectionNodeInfo.numIntactSources)
		else
			self:printOutputToLog("NO CONNECTION NODES SET")
		end
		if powerSourceInfo.numSources > 0 then
			self:printOutputToLog("POWER SOURCES : "..powerSourceInfo.numSources.." | DAMAGED: "..powerSourceInfo.numDamagedSources.." | INTACT: "..powerSourceInfo.numIntactSources)
		else
			self:printOutputToLog("NO POWER SOURCES SET")
		end
		self:printOutputToLog("---------------------------------------------------")
	end
end

function SkynetIADSLogger:printSystemStatus()	

	if self:getDebugSettings().IADSStatus or self:getDebugSettings().contacts then
		local coalitionStr = self.iads:getCoalitionString()
		self:printOutput("---- IADS: "..coalitionStr.." ------")
	end
	
	if self:getDebugSettings().IADSStatus then

		local commandCenters = self.iads:getCommandCenters()
		local numComCenters = #commandCenters
		local numDestroyedComCenters = 0
		local numComCentersNoPower = 0
		local numComCentersNoConnectionNode = 0
		local numIntactComCenters = 0
		for i = 1, #commandCenters do
			local commandCenter = commandCenters[i]
			if commandCenter:hasWorkingPowerSource() == false then
				numComCentersNoPower = numComCentersNoPower + 1
			end
			if commandCenter:hasActiveConnectionNode() == false then
				numComCentersNoConnectionNode = numComCentersNoConnectionNode + 1
			end
			if commandCenter:isDestroyed() == false then
				numIntactComCenters = numIntactComCenters + 1
			end
		end
		
		numDestroyedComCenters = numComCenters - numIntactComCenters
		
		
		self:printOutput("COMMAND CENTERS: "..numComCenters.." | Destroyed: "..numDestroyedComCenters.." | NoPowr: "..numComCentersNoPower.." | NoCon: "..numComCentersNoConnectionNode)
	
		local ewNoPower = 0
		local earlyWarningRadars = self.iads:getEarlyWarningRadars()
		local ewTotal = #earlyWarningRadars
		local ewNoConnectionNode = 0
		local ewActive = 0
		local ewRadarsInactive = 0

		for i = 1, #earlyWarningRadars do
			local ewRadar = earlyWarningRadars[i]
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
		local numEWRadarsDestroyed = #self.iads:getDestroyedEarlyWarningRadars()
		self:printOutput("EW: "..ewTotal.." | On: "..ewActive.." | Off: "..ewRadarsInactive.." | Destroyed: "..numEWRadarsDestroyed.." | NoPowr: "..ewNoPower.." | NoCon: "..ewNoConnectionNode)
		
		local samSitesInactive = 0
		local samSitesActive = 0
		local samSites = self.iads:getSAMSites()
		local samSitesTotal = #samSites
		local samSitesNoPower = 0
		local samSitesNoConnectionNode = 0
		local samSitesOutOfAmmo = 0
		local samSiteAutonomous = 0
		local samSiteRadarDestroyed = 0
		for i = 1, #samSites do
			local samSite = samSites[i]
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
		self:printOutput("SAM: "..samSitesTotal.." | On: "..samSitesActive.." | Off: "..samSitesInactive.." | Autonm: "..samSiteAutonomous.." | Raddest: "..samSiteRadarDestroyed.." | NoPowr: "..samSitesNoPower.." | NoCon: "..samSitesNoConnectionNode.." | NoAmmo: "..samSitesOutOfAmmo)
	end
	
	if self:getDebugSettings().contacts then
		local contacts = self.iads:getContacts()
		if contacts then
			for i = 1, #contacts do
				local contact = contacts[i]
					self:printOutput("CONTACT: "..contact:getName().." | TYPE: "..contact:getTypeName().." | GS: "..tostring(contact:getGroundSpeedInKnots()).." | LAST SEEN: "..contact:getAge())
			end
		end
	end
	
	if self:getDebugSettings().commandCenterStatusEnvOutput then
		self:printCommandCenterStatus()
	end

	if self:getDebugSettings().earlyWarningRadarStatusEnvOutput then
		self:printEarlyWarningRadarStatus()
	end
	
	if self:getDebugSettings().samSiteStatusEnvOutput then
		self:printSAMSiteStatus()
	end

end

end
