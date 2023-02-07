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
	iads.harmDetection = SkynetIADSHARMDetection:create(iads)
	iads.logger = SkynetIADSLogger:create(iads)
	if iads.name == nil then
		iads.name = ""
	end
	iads.contactUpdateInterval = 5
	return iads
end

function SkynetIADS:setUpdateInterval(interval)
	self.contactUpdateInterval = interval
end

function SkynetIADS:setCoalition(item)
	if item then
		local coalitionID = item:getCoalition()
		if self.coalitionID == nil then
			self.coalitionID = coalitionID
		end
		if self.coalitionID ~= coalitionID then
			self:printOutputToLog("element: "..item:getName().." has a different coalition than the IADS", true)
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
		self:printOutputToLog("you have added an EW Radar that does not exist, check name of Unit in Setup and Mission editor: "..earlyWarningRadarUnitName, true)
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
	ewRadar:setCachedTargetsMaxAge(self:getCachedTargetsMaxAge())	
	-- for performance improvement, if iads is not scanning no update coverage update needs to be done, will be executed once when iads activates
	if self.ewRadarScanMistTaskID ~= nil then
		self:buildRadarCoverageForEarlyWarningRadar(ewRadar)
	end
	ewRadar:setActAsEW(true)
	ewRadar:setToCorrectAutonomousState()
	ewRadar:goLive()
	table.insert(self.earlyWarningRadars, ewRadar)
	if self:getDebugSettings().addedEWRadar then
			self:printOutputToLog("ADDED: "..ewRadar:getDescription())
	end
	return ewRadar
end

function SkynetIADS:getCachedTargetsMaxAge()
	return self.contactUpdateInterval
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
		local groupName = samSite:getDCSName()
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
		self:printOutputToLog("you have added an SAM Site that does not exist, check name of Group in Setup and Mission editor: "..tostring(samSiteName), true)
		return
	end
	self:setCoalition(samSiteDCS)
	local samSite = SkynetIADSSamSite:create(samSiteDCS, self)
	samSite:setupElements()
	samSite:setCanEngageAirWeapons(true)
	samSite:goLive()
	samSite:setCachedTargetsMaxAge(self:getCachedTargetsMaxAge())
	if samSite:getNatoName() == "UNKNOWN" then
		self:printOutputToLog("you have added an SAM site that Skynet IADS can not handle: "..samSite:getDCSName(), true)
		samSite:cleanUp()
	else
		samSite:goDark()
		table.insert(self.samSites, samSite)
		if self:getDebugSettings().addedSAMSite then
			self:printOutputToLog("ADDED: "..samSite:getDescription())
		end
		-- for performance improvement, if iads is not scanning no update coverage update needs to be done, will be executed once when iads activates
		if self.ewRadarScanMistTaskID ~= nil then
			self:buildRadarCoverageForSAMSite(samSite)
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
	-- when IADS is active the radars will be added to the new command center. If it not active this will happen when radar coverage is built
	if self.ewRadarScanMistTaskID ~= nil then
		self:addRadarsToCommandCenters()
	end
	return comCenter
end

function SkynetIADS:isCommandCenterUsable()
	if #self:getCommandCenters() == 0 then
		return true
	end
	local usableComCenters = self:getUsableAbstractRadarElemtentsOfTable(self:getCommandCenters())
	return (#usableComCenters > 0)
end

function SkynetIADS:getCommandCenters()
	return self.commandCenters
end


function SkynetIADS.evaluateContacts(self)

	local ewRadars = self:getUsableEarlyWarningRadars()
	local samSites = self:getUsableSAMSites()
	
	--will add SAM Sites acting as EW Rardars to the ewRadars array:
	for i = 1, #samSites do
		local samSite = samSites[i]
		--We inform SAM sites that a target update is about to happen. If they have no targets in range after the cycle they go dark
		samSite:targetCycleUpdateStart()
		if samSite:getActAsEW() then
			table.insert(ewRadars, samSite)
		end
		--if the sam site is not in ew mode and active we grab the detected targets right here
		if samSite:isActive() and samSite:getActAsEW() == false then
			local contacts = samSite:getDetectedTargets()
			for j = 1, #contacts do
				local contact = contacts[j]
				self:mergeContact(contact)
			end
		end
	end

	local samSitesToTrigger = {}
	
	for i = 1, #ewRadars do
		local ewRadar = ewRadars[i]
		--call go live in case ewRadar had to shut down (HARM attack)
		ewRadar:goLive()
		-- if an awacs has traveled more than a predeterminded distance we update the autonomous state of the SAMs
		if getmetatable(ewRadar) == SkynetIADSAWACSRadar and ewRadar:isUpdateOfAutonomousStateOfSAMSitesRequired() then
			self:buildRadarCoverageForEarlyWarningRadar(ewRadar)
		end
		local ewContacts = ewRadar:getDetectedTargets()
		if #ewContacts > 0 then
			local samSitesUnderCoverage = ewRadar:getUsableChildRadars()
			for j = 1, #samSitesUnderCoverage do
				local samSiteUnterCoverage = samSitesUnderCoverage[j]
				-- only if a SAM site is not active we add it to the hash of SAM sites to be iterated later on
				if samSiteUnterCoverage:isActive() == false then
					--we add them to a hash to make sure each SAM site is in the collection only once, reducing the number of loops we conduct later on
					samSitesToTrigger[samSiteUnterCoverage:getDCSName()] = samSiteUnterCoverage
				end
			end
			for j = 1, #ewContacts do
				local contact = ewContacts[j]
				self:mergeContact(contact)
			end
		end
	end

	self:cleanAgedTargets()
	
	for samName, samToTrigger in pairs(samSitesToTrigger) do
		for j = 1, #self.contacts do
			local contact = self.contacts[j]
			-- the DCS Radar only returns enemy aircraft, if that should change a coalition check will be required
			-- currently every type of object in the air is handed of to the SAM site, including missiles
			local description = contact:getDesc()
			local category = description.category
			if category and category ~= Unit.Category.GROUND_UNIT and category ~= Unit.Category.SHIP and category ~= Unit.Category.STRUCTURE then
				samToTrigger:informOfContact(contact)
			end
		end
	end
	
	for i = 1, #samSites do
		local samSite = samSites[i]
		samSite:targetCycleUpdateEnd()
	end
	
	self.harmDetection:setContacts(self:getContacts())
	self.harmDetection:evaluateContacts()
	
	self.logger:printSystemStatus()
end

function SkynetIADS:cleanAgedTargets()
	local contactsToKeep = {}
	for i = 1, #self.contacts do
		local contact = self.contacts[i]
		if contact:getAge() < self.maxTargetAge then
			table.insert(contactsToKeep, contact)
		end
	end
	self.contacts = contactsToKeep
end

--TODO unit test this method:
function SkynetIADS:getAbstracRadarElements()
	local abstractRadarElements = {}
	local ewRadars = self:getEarlyWarningRadars()
	local samSites = self:getSAMSites()
	
	for i = 1, #ewRadars do
		local ewRadar = ewRadars[i]
		table.insert(abstractRadarElements, ewRadar)
	end
	
	for i = 1, #samSites do
		local samSite = samSites[i]
		table.insert(abstractRadarElements, samSite)
	end
	return abstractRadarElements
end


function SkynetIADS:addRadarsToCommandCenters()

	--we clear any existing radars that may have been added earlier
	local comCenters = self:getCommandCenters()
	for i = 1, #comCenters do
		local comCenter = comCenters[i]
		comCenter:clearChildRadars()
	end	
	
	-- then we add child radars to the command centers
	local abstractRadarElements = self:getAbstracRadarElements()
		for i = 1, #abstractRadarElements do
			local abstractRadar = abstractRadarElements[i]
			self:addSingleRadarToCommandCenters(abstractRadar)
		end
end

function SkynetIADS:addSingleRadarToCommandCenters(abstractRadarElement)
	local comCenters = self:getCommandCenters()
	for i = 1, #comCenters do
		local comCenter = comCenters[i]
		comCenter:addChildRadar(abstractRadarElement)
	end	
end

-- this method rebuilds the radar coverage of the IADS, a complete rebuild is only required the first time the IADS is activated
-- during runtime it is sufficient to call buildRadarCoverageForSAMSite or buildRadarCoverageForEarlyWarningRadar method that just updates the IADS for one unit, this saves script execution time
function SkynetIADS:buildRadarCoverage()	
	
	--to build the basic radar coverage we use all SAM sites. Checks if SAM site has power or a connection node is done when using the SAM site later on
	local samSites = self:getSAMSites()
	
	--first we clear all child and parent radars that may have been added previously
	for i = 1, #samSites do
		local samSite = samSites[i]
		samSite:clearChildRadars()
		samSite:clearParentRadars()
	end
	
	local ewRadars = self:getEarlyWarningRadars()
	
	for i = 1, #ewRadars do
		local ewRadar = ewRadars[i]
		ewRadar:clearChildRadars()
	end	
	
	--then we rebuild the radar coverage
	local abstractRadarElements = self:getAbstracRadarElements()
	for i = 1, #abstractRadarElements do
		local abstract = abstractRadarElements[i]
		self:buildRadarCoverageForAbstractRadarElement(abstract)
	end
	
	self:addRadarsToCommandCenters()
	
	--we call this once on all sam sites, to make sure autonomous sites go live when IADS activates
	for i = 1, #samSites do
		local samSite = samSites[i]
		samSite:informChildrenOfStateChange()
	end

end

function SkynetIADS:buildRadarCoverageForAbstractRadarElement(abstractRadarElement)
	local abstractRadarElements = self:getAbstracRadarElements()
	for i = 1, #abstractRadarElements do
		local aElementToCompare = abstractRadarElements[i]
		if aElementToCompare ~= abstractRadarElement then
			if abstractRadarElement:isInRadarDetectionRangeOf(aElementToCompare) then
				self:buildRadarAssociation(aElementToCompare, abstractRadarElement)
			end
			if aElementToCompare:isInRadarDetectionRangeOf(abstractRadarElement) then
				self:buildRadarAssociation(abstractRadarElement, aElementToCompare)
			end
		end
	end
end

function SkynetIADS:buildRadarAssociation(parent, child)
	--chilren should only be SAM sites not EW radars
	if ( getmetatable(child) == SkynetIADSSamSite ) then
		parent:addChildRadar(child)
	end
	--Only SAM Sites should have parent Radars, not EW Radars
	if ( getmetatable(child) == SkynetIADSSamSite ) then
		child:addParentRadar(parent)
	end
end

function SkynetIADS:buildRadarCoverageForSAMSite(samSite)
	self:buildRadarCoverageForAbstractRadarElement(samSite)
	self:addSingleRadarToCommandCenters(samSite)
end

function SkynetIADS:buildRadarCoverageForEarlyWarningRadar(ewRadar)
	self:buildRadarCoverageForAbstractRadarElement(ewRadar)
	self:addSingleRadarToCommandCenters(ewRadar)
end

function SkynetIADS:mergeContact(contact)
	local existingContact = false
	for i = 1, #self.contacts do
		local iadsContact = self.contacts[i]
		if iadsContact:getName() == contact:getName() then
			iadsContact:refresh()
			--these contacts are used in the logger we set a kown harm state of a contact coming from a SAM site. So the logger will show them als HARMs
			contact:setHARMState(iadsContact:getHARMState())
			local radars = contact:getAbstractRadarElementsDetected()
			for j = 1, #radars do
				local radar = radars[j]
				iadsContact:addAbstractRadarElementDetected(radar)
			end
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

function SkynetIADS:getDebugSettings()
	return self.logger.debugOutput
end

function SkynetIADS:printOutput(output, typeWarning)
	self.logger:printOutput(output, typeWarning)
end

function SkynetIADS:printOutputToLog(output)
	self.logger:printOutputToLog(output)
end

-- will start going through the Early Warning Radars and SAM sites to check what targets they have detected
function SkynetIADS.activate(self)
	mist.removeFunction(self.ewRadarScanMistTaskID)
	self.ewRadarScanMistTaskID = mist.scheduleFunction(SkynetIADS.evaluateContacts, {self}, 1, self.contactUpdateInterval)
	self:buildRadarCoverage()
end

function SkynetIADS:setupSAMSitesAndThenActivate(setupTime)
	self:activate()
	self.logger:printOutputToLog("DEPRECATED: setupSAMSitesAndThenActivate, no longer needed since using enableEmission instead of AI on / off allows for the Ground units to setup with their radars turned off")
end

function SkynetIADS:deactivate()
	mist.removeFunction(self.ewRadarScanMistTaskID)
	mist.removeFunction(self.samSetupMistTaskID)
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
		coalitionStr = "COALITION: "..coalitionStr.." | NAME: "..self.name
	end
	
	return coalitionStr
end

function SkynetIADS:getMooseConnector()
	if self.mooseConnector == nil then
		self.mooseConnector = SkynetMooseA2ADispatcherConnector:create(self)
	end
	return self.mooseConnector
end

function SkynetIADS:addMooseSetGroup(mooseSetGroup)
	self:getMooseConnector():addMooseSetGroup(mooseSetGroup)
end

end
