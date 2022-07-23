do

SkynetIADSAbstractRadarElement = {}
SkynetIADSAbstractRadarElement = inheritsFrom(SkynetIADSAbstractElement)

SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI = 1
SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK = 2

SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE = 1
SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE = 2

SkynetIADSAbstractRadarElement.HARM_TO_SAM_ASPECT = 15
SkynetIADSAbstractRadarElement.HARM_LOOKAHEAD_NM = 20

function SkynetIADSAbstractRadarElement:create(dcsElementWithRadar, iads)
	local instance = self:superClass():create(dcsElementWithRadar, iads)
	setmetatable(instance, self)
	self.__index = self
	instance.aiState = false
	instance.harmScanID = nil
	instance.harmSilenceID = nil
	instance.lastJammerUpdate = 0
	instance.objectsIdentifiedAsHarms = {}
	instance.objectsIdentifiedAsHarmsMaxTargetAge = 60
	instance.launchers = {}
	instance.trackingRadars = {}
	instance.searchRadars = {}
	instance.parentRadars = {}
	instance.childRadars = {}
	instance.missilesInFlight = {}
	instance.pointDefences = {}
	instance.harmDecoys = {}
	instance.autonomousBehaviour = SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI
	instance.goLiveRange = SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE
	instance.isAutonomous = true
	instance.harmDetectionChance = 0
	instance.minHarmShutdownTime = 0
	instance.maxHarmShutDownTime = 0
	instance.minHarmPresetShutdownTime = 30
	instance.maxHarmPresetShutdownTime = 180
	instance.harmShutdownTime = 0
	instance.firingRangePercent = 100
	instance.actAsEW = false
	instance.cachedTargets = {}
	instance.cachedTargetsMaxAge = 1
	instance.cachedTargetsCurrentAge = 0
	instance.goLiveTime = 0
	instance.engageAirWeapons = false
	instance.isAPointDefence = false
	instance.canEngageHARM = false
	instance.dataBaseSupportedTypesCanEngageHARM = false
	-- 5 seconds seems to be a good value for the sam site to find the target with its organic radar
	instance.noCacheActiveForSecondsAfterGoLive = 5
	return instance
end

--TODO: this method could be updated to only return Radar weapons fired, this way a SAM firing an IR weapon could go dark faster in the goDark() method
function SkynetIADSAbstractRadarElement:weaponFired(event)
	if event.id == world.event.S_EVENT_SHOT then
		local weapon = event.weapon
		local launcherFired = event.initiator
		for i = 1, #self.launchers do
			local launcher = self.launchers[i]
			if launcher:getDCSRepresentation() == launcherFired then
				table.insert(self.missilesInFlight, weapon)
			end
		end
	end
end

function SkynetIADSAbstractRadarElement:setCachedTargetsMaxAge(maxAge)
	self.cachedTargetsMaxAge = maxAge
end

function SkynetIADSAbstractRadarElement:cleanUp()
	for i = 1, #self.pointDefences do
		local pointDefence = self.pointDefences[i]
		pointDefence:cleanUp()
	end
	mist.removeFunction(self.harmScanID)
	mist.removeFunction(self.harmSilenceID)
	--call method from super class
	self:removeEventHandlers()
end

function SkynetIADSAbstractRadarElement:setIsAPointDefence(state)
	if (state == true or state == false) then
		self.isAPointDefence = state
	end
end

function SkynetIADSAbstractRadarElement:getIsAPointDefence()
	return self.isAPointDefence
end

function SkynetIADSAbstractRadarElement:addPointDefence(pointDefence)
	table.insert(self.pointDefences, pointDefence)
	pointDefence:setIsAPointDefence(true)
	return self
end

function SkynetIADSAbstractRadarElement:getPointDefences()
	return self.pointDefences
end

function SkynetIADSAbstractRadarElement:addHARMDecoy(harmDecoy)
	table.insert(self.harmDecoys, harmDecoy)
end

function SkynetIADSAbstractRadarElement:addParentRadar(parentRadar)
	self:insertToTableIfNotAlreadyAdded(self.parentRadars, parentRadar)
	self:informChildrenOfStateChange()
end

function SkynetIADSAbstractRadarElement:getParentRadars()
	return self.parentRadars
end

function SkynetIADSAbstractRadarElement:clearParentRadars()
	self.parentRadars = {}
end

function SkynetIADSAbstractRadarElement:addChildRadar(childRadar)
	self:insertToTableIfNotAlreadyAdded(self.childRadars, childRadar)
end

function SkynetIADSAbstractRadarElement:getChildRadars()
	return self.childRadars
end

function SkynetIADSAbstractRadarElement:clearChildRadars()
	self.childRadars = {}
end

--TODO: unit test this method
function SkynetIADSAbstractRadarElement:getUsableChildRadars()
	local usableRadars = {}
	for i = 1, #self.childRadars do
		local childRadar = self.childRadars[i]
		if childRadar:hasWorkingPowerSource() and childRadar:hasActiveConnectionNode() then
			table.insert(usableRadars, childRadar)
		end
	end	
	return usableRadars
end

function SkynetIADSAbstractRadarElement:informChildrenOfStateChange()
	self:setToCorrectAutonomousState()
	local children = self:getChildRadars()
	for i = 1, #children do
		local childRadar = children[i]
		childRadar:setToCorrectAutonomousState()
	end
	self.iads:getMooseConnector():update()
end

function SkynetIADSAbstractRadarElement:setToCorrectAutonomousState()
	local parents = self:getParentRadars()
	for i = 1, #parents do
		local parent = parents[i]
		--of one parent exists that still is connected to the IADS, the SAM site does not have to go autonomous
		--instead of isDestroyed() write method, hasWorkingSearchRadars()
		if self:hasActiveConnectionNode() and self.iads:isCommandCenterUsable() and parent:hasWorkingPowerSource() and parent:hasActiveConnectionNode() and parent:getActAsEW() == true and parent:isDestroyed() == false then
			self:resetAutonomousState()
			return
		end
	end
	self:goAutonomous()
end


function SkynetIADSAbstractRadarElement:setAutonomousBehaviour(mode)
	if mode ~= nil then
		self.autonomousBehaviour = mode
	end
	return self
end

function SkynetIADSAbstractRadarElement:getAutonomousBehaviour()
	return self.autonomousBehaviour
end

function SkynetIADSAbstractRadarElement:resetAutonomousState()
	self.isAutonomous = false
	self:goDark()
end

function SkynetIADSAbstractRadarElement:goAutonomous()
	self.isAutonomous = true
	if self.autonomousBehaviour == SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK then
		self:goDark()
	else
		self:goLive()
	end
end

function SkynetIADSAbstractRadarElement:getAutonomousState()
	return self.isAutonomous
end

function SkynetIADSAbstractRadarElement:pointDefencesHaveRemainingAmmo(minNumberOfMissiles)
	local remainingMissiles = 0
	for i = 1, #self.pointDefences do
		local pointDefence = self.pointDefences[i]
		remainingMissiles = remainingMissiles + pointDefence:getRemainingNumberOfMissiles()
	end
	return self:hasRequiredNumberOfMissiles(minNumberOfMissiles, remainingMissiles)
end

function SkynetIADSAbstractRadarElement:hasRequiredNumberOfMissiles(minNumberOfMissiles, remainingMissiles)
	local returnValue = false
	if ( remainingMissiles > 0 and remainingMissiles >= minNumberOfMissiles ) then
		returnValue = true
	end
	return returnValue
end

function SkynetIADSAbstractRadarElement:hasRemainingAmmoToEngageMissiles(minNumberOfMissiles)
	local remainingMissiles = self:getRemainingNumberOfMissiles()
	return self:hasRequiredNumberOfMissiles(minNumberOfMissiles, remainingMissiles)
end

-- this method needs to be refactored so that it works for ew radars that don't have launchers, or that it is only called by sam sites
function SkynetIADSAbstractRadarElement:hasEnoughLaunchersToEngageMissiles(minNumberOfLaunchers)
	local launchers = self:getLaunchers()
	if(launchers ~= nil) then
	 launchers = #self:getLaunchers()
	else 
		launchers = 0
	end
	return self:hasRequiredNumberOfMissiles(minNumberOfLaunchers, launchers)
end

function SkynetIADSAbstractRadarElement:pointDefencesHaveEnoughLaunchers(minNumberOfLaunchers)
	local numOfLaunchers = 0
	for i = 1, #self.pointDefences do
		local pointDefence = self.pointDefences[i]
		numOfLaunchers = numOfLaunchers + #pointDefence:getLaunchers()	
	end
	return self:hasRequiredNumberOfMissiles(minNumberOfLaunchers, numOfLaunchers)
end

function SkynetIADSAbstractRadarElement:setIgnoreHARMSWhilePointDefencesHaveAmmo(state)
	self.iads:printOutputToLog("DEPRECATED: setIgnoreHARMSWhilePointDefencesHaveAmmo SAM Site will stay live automaticall as long as itself or it's point defences can defend against a HARM")
	return self
end

function SkynetIADSAbstractRadarElement:hasMissilesInFlight()
	return #self.missilesInFlight > 0
end

function SkynetIADSAbstractRadarElement:getNumberOfMissilesInFlight()
	return #self.missilesInFlight
end

-- DCS does not send an event, when a missile is destroyed, so this method needs to be polled so that the missiles in flight are current, polling is done in the HARM Search call: evaluateIfTargetsContainHARMs
function SkynetIADSAbstractRadarElement:updateMissilesInFlight()
	local missilesInFlight = {}
	for i = 1, #self.missilesInFlight do
		local missile = self.missilesInFlight[i]
		if missile:isExist() then
			table.insert(missilesInFlight, missile)
		end
	end
	self.missilesInFlight = missilesInFlight
	self:goDarkIfOutOfAmmo()
end

function SkynetIADSAbstractRadarElement:goDarkIfOutOfAmmo()
	if self:hasRemainingAmmo() == false and self:getActAsEW() == false then
		self:goDark()
	end
end

function SkynetIADSAbstractRadarElement:getActAsEW()
	return self.actAsEW
end	

function SkynetIADSAbstractRadarElement:setActAsEW(ewState)
	if ewState == true or ewState == false then
		local stateChange = false
		if ewState ~= self.actAsEW then
			stateChange = true
		end
		self.actAsEW = ewState
		if stateChange then
			self:informChildrenOfStateChange()
		end
	end
	if self.actAsEW == true then
		self:goLive()
	else
		self:goDark()
	end
	return self
end

function SkynetIADSAbstractRadarElement:getUnitsToAnalyse()
	local units = {}
	table.insert(units, self:getDCSRepresentation())
	if getmetatable(self:getDCSRepresentation()) == Group then
		units = self:getDCSRepresentation():getUnits()
	end
	return units
end

function SkynetIADSAbstractRadarElement:getRemainingNumberOfMissiles()
	local remainingNumberOfMissiles = 0
	for i = 1, #self.launchers do
		local launcher = self.launchers[i]
		remainingNumberOfMissiles = remainingNumberOfMissiles + launcher:getRemainingNumberOfMissiles()
	end
	return remainingNumberOfMissiles
end

function SkynetIADSAbstractRadarElement:getInitialNumberOfMissiles()
	local initalNumberOfMissiles = 0
	for i = 1, #self.launchers do
		local launcher = self.launchers[i]
		initalNumberOfMissiles = launcher:getInitialNumberOfMissiles() + initalNumberOfMissiles
	end
	return initalNumberOfMissiles
end

function SkynetIADSAbstractRadarElement:getRemainingNumberOfShells()
	local remainingNumberOfShells = 0
	for i = 1, #self.launchers do
		local launcher = self.launchers[i]
		remainingNumberOfShells = remainingNumberOfShells + launcher:getRemainingNumberOfShells()
	end
	return remainingNumberOfShells
end

function SkynetIADSAbstractRadarElement:getInitialNumberOfShells()
	local initialNumberOfShells = 0
	for i = 1, #self.launchers do
		local launcher = self.launchers[i]
		initialNumberOfShells = initialNumberOfShells + launcher:getInitialNumberOfShells()
	end
	return initialNumberOfShells
end

function SkynetIADSAbstractRadarElement:hasRemainingAmmo()
	--the launcher check is due to ew radars they have no launcher and no ammo and therefore are never out of ammo
	return ( #self.launchers == 0 ) or ((self:getRemainingNumberOfMissiles() > 0 ) or ( self:getRemainingNumberOfShells() > 0 ) )
end

function SkynetIADSAbstractRadarElement:getHARMDetectionChance()
	return self.harmDetectionChance
end

function SkynetIADSAbstractRadarElement:setHARMDetectionChance(chance)
	if chance and chance >= 0 and chance <= 100 then
		self.harmDetectionChance = chance
	end
	return self
end

function SkynetIADSAbstractRadarElement:setupElements()
	local numUnits = #self:getUnitsToAnalyse()
	for typeName, dataType in pairs(SkynetIADS.database) do
		local hasSearchRadar = false
		local hasTrackingRadar = false
		local hasLauncher = false
		self.searchRadars = {}
		self.trackingRadars = {}
		self.launchers = {}
		for entry, unitData in pairs(dataType) do
			if entry == 'searchRadar' then
				self:analyseAndAddUnit(SkynetIADSSAMSearchRadar, self.searchRadars, unitData)
				hasSearchRadar = true
			end
			if entry == 'launchers' then
				self:analyseAndAddUnit(SkynetIADSSAMLauncher, self.launchers, unitData)
				hasLauncher = true
			end
			if entry == 'trackingRadar' then
				self:analyseAndAddUnit(SkynetIADSSAMTrackingRadar, self.trackingRadars, unitData)
				hasTrackingRadar = true
			end
		end
		
		--this check ensures a unit or group has all required elements for the specific sam or ew type:
		if (hasLauncher and hasSearchRadar and hasTrackingRadar and #self.launchers > 0 and #self.searchRadars > 0  and #self.trackingRadars > 0 ) 
			or (hasSearchRadar and hasLauncher and #self.searchRadars > 0 and #self.launchers > 0) then
			self:setHARMDetectionChance(dataType['harm_detection_chance'])
			self.dataBaseSupportedTypesCanEngageHARM = dataType['can_engage_harm'] 
			self:setCanEngageHARM(self.dataBaseSupportedTypesCanEngageHARM)
			local natoName = dataType['name']['NATO']
			self:buildNatoName(natoName)
			break
		end	
	end
end

function SkynetIADSAbstractRadarElement:setCanEngageHARM(canEngage)
	if canEngage == true or canEngage == false then
		self.canEngageHARM = canEngage
		if ( canEngage == true and self:getCanEngageAirWeapons() == false ) then
			self:setCanEngageAirWeapons(true)
		end
	end
	return self
end

function SkynetIADSAbstractRadarElement:getCanEngageHARM()
	return self.canEngageHARM
end

function SkynetIADSAbstractRadarElement:setCanEngageAirWeapons(engageAirWeapons)
	if self:isDestroyed() == false then
		local controller = self:getDCSRepresentation():getController()
		if ( engageAirWeapons == true ) then
			controller:setOption(AI.Option.Ground.id.ENGAGE_AIR_WEAPONS, true)
			--its important that we set var to true here, to prevent recursion in setCanEngageHARM
			self.engageAirWeapons = true
			--we set the original value we got when loading info about the SAM site
			self:setCanEngageHARM(self.dataBaseSupportedTypesCanEngageHARM)
		else
			controller:setOption(AI.Option.Ground.id.ENGAGE_AIR_WEAPONS, false)
			self:setCanEngageHARM(false)
			self.engageAirWeapons = false
		end
	end
	return self
end

function SkynetIADSAbstractRadarElement:getCanEngageAirWeapons()
	return self.engageAirWeapons
end

function SkynetIADSAbstractRadarElement:buildNatoName(natoName)
	--we shorten the SA-XX names and don't return their code names eg goa, gainful..
	local pos = natoName:find(" ")
	local prefix = natoName:sub(1, 2)
	if string.lower(prefix) == 'sa' and pos ~= nil then
		self.natoName = natoName:sub(1, (pos-1))
	else
		self.natoName = natoName
	end
end

function SkynetIADSAbstractRadarElement:analyseAndAddUnit(class, tableToAdd, unitData)
	local units = self:getUnitsToAnalyse()
	for i = 1, #units do
		local unit = units[i]
		self:buildSingleUnit(unit, class, tableToAdd, unitData)
	end
end

function SkynetIADSAbstractRadarElement:buildSingleUnit(unit, class, tableToAdd, unitData)
	local unitTypeName = unit:getTypeName()
	for unitName, unitPerformanceData in pairs(unitData) do
		if unitName == unitTypeName then
			samElement = class:create(unit)
			samElement:setupRangeData()
			table.insert(tableToAdd, samElement)
		end
	end
end

function SkynetIADSAbstractRadarElement:getController()
	local dcsRepresentation = self:getDCSRepresentation()
	if dcsRepresentation:isExist() then
		return dcsRepresentation:getController()
	else
		return nil
	end
end

function SkynetIADSAbstractRadarElement:getLaunchers()
	return self.launchers
end

function SkynetIADSAbstractRadarElement:getSearchRadars()
	return self.searchRadars
end

function SkynetIADSAbstractRadarElement:getTrackingRadars()
	return self.trackingRadars
end

function SkynetIADSAbstractRadarElement:getRadars()
	local radarUnits = {}	
	for i = 1, #self.searchRadars do
		table.insert(radarUnits, self.searchRadars[i])
	end	
	for i = 1, #self.trackingRadars do
		table.insert(radarUnits, self.trackingRadars[i])
	end
	return radarUnits
end

function SkynetIADSAbstractRadarElement:setGoLiveRangeInPercent(percent)
	if percent ~= nil then
		self.firingRangePercent = percent	
		for i = 1, #self.launchers do
			local launcher = self.launchers[i]
			launcher:setFiringRangePercent(self.firingRangePercent)
		end
		for i = 1, #self.searchRadars do
			local radar = self.searchRadars[i]
			radar:setFiringRangePercent(self.firingRangePercent)
		end
	end
	return self
end

function SkynetIADSAbstractRadarElement:getGoLiveRangeInPercent()
	return self.firingRangePercent
end

function SkynetIADSAbstractRadarElement:setEngagementZone(engagementZone)
	if engagementZone == SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE then
		self.goLiveRange = engagementZone
	elseif engagementZone == SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE then
		self.goLiveRange = engagementZone
	end
	return self
end

function SkynetIADSAbstractRadarElement:getEngagementZone()
	return self.goLiveRange
end

function SkynetIADSAbstractRadarElement:goLive()
	if ( self.aiState == false and self:hasWorkingPowerSource() and self.harmSilenceID == nil) 
	and (self:hasRemainingAmmo() == true  )
	then
		if self:isDestroyed() == false then
			local  cont = self:getController()
			cont:setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.RED)	
			cont:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_FREE)
			self:getDCSRepresentation():enableEmission(true)
			self.goLiveTime = timer.getTime()
			self.aiState = true
		end
		self:pointDefencesStopActingAsEW()
		if  self.iads:getDebugSettings().radarWentLive then
			self.iads:printOutputToLog("GOING LIVE: "..self:getDescription())
		end
		self:scanForHarms()
	end
end

function SkynetIADSAbstractRadarElement:pointDefencesStopActingAsEW()
	for i = 1, #self.pointDefences do
		local pointDefence = self.pointDefences[i]
		pointDefence:setActAsEW(false)
	end
end


function SkynetIADSAbstractRadarElement:goDark()
	if (self:hasWorkingPowerSource() == false) or ( self.aiState == true ) 
	and (self.harmSilenceID ~= nil or ( self.harmSilenceID == nil and #self:getDetectedTargets() == 0 and self:hasMissilesInFlight() == false) or ( self.harmSilenceID == nil and #self:getDetectedTargets() > 0 and self:hasMissilesInFlight() == false and self:hasRemainingAmmo() == false ) )	
	then
		if self:isDestroyed() == false then
			self:getDCSRepresentation():enableEmission(false)
		end
		-- point defence will only go live if the Radar Emitting site it is protecting goes dark and this is due to a it defending against a HARM
		if (self.harmSilenceID ~= nil) then
			self:pointDefencesGoLive()
		end
		self.aiState = false
		self:stopScanningForHARMs()
		if self.iads:getDebugSettings().radarWentDark then
			self.iads:printOutputToLog("GOING DARK: "..self:getDescription())
		end
	end
end

function SkynetIADSAbstractRadarElement:pointDefencesGoLive()
	local setActive = false
	for i = 1, #self.pointDefences do
		local pointDefence = self.pointDefences[i]
		if ( pointDefence:getActAsEW() == false ) then
			setActive = true
			pointDefence:setActAsEW(true)
		end
	end
	return setActive
end

function SkynetIADSAbstractRadarElement:isActive()
	return self.aiState
end

function SkynetIADSAbstractRadarElement:isTargetInRange(target)

	local isSearchRadarInRange = false
	local isTrackingRadarInRange = false
	local isLauncherInRange = false
	
	local isSearchRadarInRange = ( #self.searchRadars == 0 )
	for i = 1, #self.searchRadars do
		local searchRadar = self.searchRadars[i]
		if searchRadar:isInRange(target) then
			isSearchRadarInRange = true
			break
		end
	end
	
	if self.goLiveRange == SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE then
		
		isLauncherInRange = ( #self.launchers == 0 )
		for i = 1, #self.launchers do
			local launcher = self.launchers[i]
			if launcher:isInRange(target) then
				isLauncherInRange = true
				break
			end
		end
		
		isTrackingRadarInRange = ( #self.trackingRadars == 0 )
		for i = 1, #self.trackingRadars do
			local trackingRadar = self.trackingRadars[i]
			if trackingRadar:isInRange(target) then
				isTrackingRadarInRange = true
				break
			end
		end
	else
		isLauncherInRange = true
		isTrackingRadarInRange = true
	end
	return  (isSearchRadarInRange and isTrackingRadarInRange and isLauncherInRange )
end

function SkynetIADSAbstractRadarElement:isInRadarDetectionRangeOf(abstractRadarElement)
	local radars = self:getRadars()
	local abstractRadarElementRadars = abstractRadarElement:getRadars()
	for i = 1, #radars do
		local radar = radars[i]
		for j = 1, #abstractRadarElementRadars do
			local abstractRadarElementRadar = abstractRadarElementRadars[j]
			if  abstractRadarElementRadar:isExist() and radar:isExist() then
				local distance = self:getDistanceToUnit(radar:getDCSRepresentation():getPosition().p, abstractRadarElementRadar:getDCSRepresentation():getPosition().p)	
				if abstractRadarElementRadar:getMaxRangeFindingTarget() >= distance then
					return true
				end
			end
		end
	end
	return false
end

function SkynetIADSAbstractRadarElement:getDistanceToUnit(unitPosA, unitPosB)
	return mist.utils.round(mist.utils.get2DDist(unitPosA, unitPosB, 0))
end

function SkynetIADSAbstractRadarElement:hasWorkingRadar()
	local radars = self:getRadars()
	for i = 1, #radars do
		local radar = radars[i]
		if radar:isRadarWorking() == true then
			return true
		end
	end
	return false
end

function SkynetIADSAbstractRadarElement:jam(successProbability)
		if self:isDestroyed() == false then
			local controller = self:getController()
			local probability = math.random(1, 100)
			if self.iads:getDebugSettings().jammerProbability then
				self.iads:printOutputToLog("JAMMER: "..self:getDescription()..": Probability: "..successProbability)
			end
			if successProbability > probability then
				controller:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_HOLD)
				if self.iads:getDebugSettings().jammerProbability then
					self.iads:printOutputToLog("JAMMER: "..self:getDescription()..": jammed, setting to weapon hold")
				end
			else
				controller:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_FREE)
				if self.iads:getDebugSettings().jammerProbability then
					self.iads:printOutputToLog("JAMMER: "..self:getDescription()..": jammed, setting to weapon free")
				end
			end
			self.lastJammerUpdate = timer:getTime()
		end
end

function SkynetIADSAbstractRadarElement:scanForHarms()
	self:stopScanningForHARMs()
	self.harmScanID = mist.scheduleFunction(SkynetIADSAbstractRadarElement.evaluateIfTargetsContainHARMs, {self}, 1, 2)
end

function SkynetIADSAbstractRadarElement:isScanningForHARMs()
	return self.harmScanID ~= nil
end

function SkynetIADSAbstractRadarElement:isDefendingHARM()
	return self.harmSilenceID ~= nil
end

function SkynetIADSAbstractRadarElement:stopScanningForHARMs()
	mist.removeFunction(self.harmScanID)
	self.harmScanID = nil
end

function SkynetIADSAbstractRadarElement:goSilentToEvadeHARM(timeToImpact)
	self:finishHarmDefence(self)
	if ( timeToImpact == nil ) then
		timeToImpact = 0
	end
	
	self.minHarmShutdownTime = self:calculateMinimalShutdownTimeInSeconds(timeToImpact)
	self.maxHarmShutDownTime = self:calculateMaximalShutdownTimeInSeconds(self.minHarmShutdownTime)
	
	self.harmShutdownTime = self:calculateHARMShutdownTime()
	if self.iads:getDebugSettings().harmDefence then
		self.iads:printOutputToLog("HARM DEFENCE SHUTTING DOWN: "..self:getDCSName().." | FOR: "..self.harmShutdownTime.." seconds | TTI: "..timeToImpact)
	end
	self.harmSilenceID = mist.scheduleFunction(SkynetIADSAbstractRadarElement.finishHarmDefence, {self}, timer.getTime() + self.harmShutdownTime, 1)
	self:goDark()
end

function SkynetIADSAbstractRadarElement:getHARMShutdownTime()
	return self.harmShutdownTime
end

function SkynetIADSAbstractRadarElement:calculateHARMShutdownTime()
	local shutDownTime = math.random(self.minHarmShutdownTime, self.maxHarmShutDownTime)
	return shutDownTime
end

function SkynetIADSAbstractRadarElement.finishHarmDefence(self)
	mist.removeFunction(self.harmSilenceID)
	self.harmSilenceID = nil
	self.harmShutdownTime = 0
	
	if ( self:getAutonomousState() == true ) then
		self:goAutonomous()
	end	
end

function SkynetIADSAbstractRadarElement:getDetectedTargets()
	if ( timer.getTime() - self.cachedTargetsCurrentAge > self.cachedTargetsMaxAge ) or ( timer.getTime() - self.goLiveTime < self.noCacheActiveForSecondsAfterGoLive ) then
		self.cachedTargets = {}
		self.cachedTargetsCurrentAge = timer.getTime()
		if self:hasWorkingPowerSource() and self:isDestroyed() == false then
			local targets = self:getController():getDetectedTargets(Controller.Detection.RADAR)
			for i = 1, #targets do
				local target = targets[i]
				-- there are cases when a destroyed object is still visible as a target to the radar, don't add it, will cause errors everywhere the dcs object is accessed
				if target.object then
					local iadsTarget = SkynetIADSContact:create(target, self)
					iadsTarget:refresh()
					if self:isTargetInRange(iadsTarget) then
						table.insert(self.cachedTargets, iadsTarget)
					end
				end
			end
		end
	end
	return self.cachedTargets
end

function SkynetIADSAbstractRadarElement:getSecondsToImpact(distanceNM, speedKT)
	local tti = 0
	if speedKT > 0 then
		tti = mist.utils.round((distanceNM / speedKT) * 3600, 0)
		if tti < 0 then
			tti = 0
		end
	end
	return tti
end

function SkynetIADSAbstractRadarElement:getDistanceInMetersToContact(radarUnit, point)
	return mist.utils.round(mist.utils.get3DDist(radarUnit:getPosition().p, point), 0)
end

function SkynetIADSAbstractRadarElement:calculateMinimalShutdownTimeInSeconds(timeToImpact)
	return timeToImpact + self.minHarmPresetShutdownTime
end

function SkynetIADSAbstractRadarElement:calculateMaximalShutdownTimeInSeconds(minShutdownTime)	
	return minShutdownTime + mist.random(1, self.maxHarmPresetShutdownTime)
end

function SkynetIADSAbstractRadarElement:calculateImpactPoint(target, distanceInMeters)
	-- distance needs to be incremented by a certain value for ip calculation to work, check why presumably due to rounding errors in the previous distance calculation
	return land.getIP(target:getPosition().p, target:getPosition().x, distanceInMeters + 50)
end

function SkynetIADSAbstractRadarElement:shallReactToHARM()
	return self.harmDetectionChance >=  math.random(1, 100)
end

-- will only check for missiles, if DCS ads AAA than can engage HARMs then this code must be updated:
function SkynetIADSAbstractRadarElement:shallIgnoreHARMShutdown()
	local numOfHarms = self:getNumberOfObjectsItentifiedAsHARMS()
	--[[
	self.iads:printOutputToLog("Self enough launchers: "..tostring(self:hasEnoughLaunchersToEngageMissiles(numOfHarms)))
	self.iads:printOutputToLog("Self enough missiles: "..tostring(self:hasRemainingAmmoToEngageMissiles(numOfHarms)))
	self.iads:printOutputToLog("PD enough missiles: "..tostring(self:pointDefencesHaveRemainingAmmo(numOfHarms)))
	self.iads:printOutputToLog("PD enough launchers: "..tostring(self:pointDefencesHaveEnoughLaunchers(numOfHarms)))
	--]]
	return ( ((self:hasEnoughLaunchersToEngageMissiles(numOfHarms) and self:hasRemainingAmmoToEngageMissiles(numOfHarms) and self:getCanEngageHARM()) or (self:pointDefencesHaveRemainingAmmo(numOfHarms) and self:pointDefencesHaveEnoughLaunchers(numOfHarms))))
end

function SkynetIADSAbstractRadarElement:informOfHARM(harmContact)
	local radars = self:getRadars()
		for j = 1, #radars do
			local radar = radars[j]
			local distanceNM =  mist.utils.metersToNM(self:getDistanceInMetersToContact(radar, harmContact:getPosition().p))
			local harmToSAMHeading = mist.utils.toDegree(mist.utils.getHeadingPoints(harmContact:getPosition().p, radar:getPosition().p))
			local harmToSAMAspect = self:calculateAspectInDegrees(harmContact:getMagneticHeading(), harmToSAMHeading)
			local speedKT = harmContact:getGroundSpeedInKnots(0)
			local secondsToImpact = self:getSecondsToImpact(distanceNM, speedKT)
			--TODO: use tti instead of distanceNM?
			-- when iterating through the radars, store shortest tti and work with that value??
			if ( harmToSAMAspect < SkynetIADSAbstractRadarElement.HARM_TO_SAM_ASPECT and distanceNM < SkynetIADSAbstractRadarElement.HARM_LOOKAHEAD_NM ) then
				self:addObjectIdentifiedAsHARM(harmContact)
				if ( #self:getPointDefences() > 0 and self:pointDefencesGoLive() == true and self.iads:getDebugSettings().harmDefence ) then
						self.iads:printOutputToLog("POINT DEFENCES GOING LIVE FOR: "..self:getDCSName().." | TTI: "..secondsToImpact)
				end
				--self.iads:printOutputToLog("Ignore HARM shutdown: "..tostring(self:shallIgnoreHARMShutdown()))
				if ( self:getIsAPointDefence() == false and ( self:isDefendingHARM() == false or ( self:getHARMShutdownTime() < secondsToImpact ) ) and self:shallIgnoreHARMShutdown() == false) then
					self:goSilentToEvadeHARM(secondsToImpact)
					break
				end
			end
		end
end

function SkynetIADSAbstractElement:addObjectIdentifiedAsHARM(harmContact)
	self:insertToTableIfNotAlreadyAdded(self.objectsIdentifiedAsHarms, harmContact)
end

function SkynetIADSAbstractRadarElement:calculateAspectInDegrees(harmHeading, harmToSAMHeading)
		local aspect = harmHeading - harmToSAMHeading
		if ( aspect < 0 ) then
			aspect = -1 * aspect
		end
		if aspect > 180 then
			aspect = 360 - aspect
		end
		return mist.utils.round(aspect)
end

function SkynetIADSAbstractRadarElement:getNumberOfObjectsItentifiedAsHARMS()
	return #self.objectsIdentifiedAsHarms
end

function SkynetIADSAbstractRadarElement:cleanUpOldObjectsIdentifiedAsHARMS()
	local newHARMS = {}
	for i = 1, #self.objectsIdentifiedAsHarms do
		local harmContact = self.objectsIdentifiedAsHarms[i]
		if harmContact:getAge() < self.objectsIdentifiedAsHarmsMaxTargetAge then
			table.insert(newHARMS, harmContact)
		end
	end
	--stop point defences acting as ew (always on), will occur if activated via evaluateIfTargetsContainHARMs()
	--if in this iteration all harms where cleared we turn of the point defence. But in any other cases we dont turn of point defences, that interferes with other parts of the iads
	-- when setting up the iads (letting pds go to read state)
	if (#newHARMS == 0 and self:getNumberOfObjectsItentifiedAsHARMS() > 0 ) then
		self:pointDefencesStopActingAsEW()
	end
	self.objectsIdentifiedAsHarms = newHARMS
end


function SkynetIADSAbstractRadarElement.evaluateIfTargetsContainHARMs(self)

	--if an emitter dies the SAM site being jammed will revert back to normal operation:
	if self.lastJammerUpdate > 0 and ( timer:getTime() - self.lastJammerUpdate ) > 10 then
		self:jam(0)
		self.lastJammerUpdate = 0
	end
	
	--we use the regular interval of this method to update to other states: 
	self:updateMissilesInFlight()	
	self:cleanUpOldObjectsIdentifiedAsHARMS()
end

end
