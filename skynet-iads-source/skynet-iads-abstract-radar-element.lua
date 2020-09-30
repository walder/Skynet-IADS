do

SkynetIADSAbstractRadarElement = {}
SkynetIADSAbstractRadarElement = inheritsFrom(SkynetIADSAbstractElement)

SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI = 1
SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK = 2

SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE = 1
SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE = 2

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
	instance.samSitesInCoveredArea = {}
	instance.missilesInFlight = {}
	instance.pointDefences = {}
	instance.ingnoreHARMSWhilePointDefencesHaveAmmo = false
	instance.autonomousBehaviour = SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI
	instance.goLiveRange = SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE
	instance.isAutonomous = false
	instance.harmDetectionChance = 0
	instance.minHarmShutdownTime = 0
	instance.maxHarmShutDownTime = 0
	instance.minHarmPresetShutdownTime = 30
	instance.maxHarmPresetShutdownTime = 180
	instance.firingRangePercent = 100
	instance.actAsEW = false
	instance.cachedTargets = {}
	instance.cachedTargetsMaxAge = 1
	instance.cachedTargetsCurrentAge = 0
	instance.goLiveTime = 0
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

function SkynetIADSAbstractRadarElement:addPointDefence(pointDefence)
	table.insert(self.pointDefences, pointDefence)
	return self
end

function SkynetIADSAbstractRadarElement:getPointDefences()
	return self.pointDefences
end


function SkynetIADSAbstractRadarElement:updateSAMSitesInCoveredArea()
	local samSites = self.iads:getUsableSAMSites()
	self.samSitesInCoveredArea = {}
	for i = 1, #samSites do
		local samSite = samSites[i]
		if samSite:isInRadarDetectionRangeOf(self) and samSite ~= self then
			table.insert(self.samSitesInCoveredArea, samSite)
		end
	end
	return self.samSitesInCoveredArea
end

function SkynetIADSAbstractRadarElement:getSAMSitesInCoveredArea()
	return self.samSitesInCoveredArea
end

function SkynetIADSAbstractRadarElement:pointDefencesHaveRemainingAmmo(minNumberOfMissiles)
	local remainingMissiles = 0
	for i = 1, #self.pointDefences do
		local pointDefence = self.pointDefences[i]
		remainingMissiles = remainingMissiles + pointDefence:getRemainingNumberOfMissiles()
	end
	local returnValue = false
	if ( remainingMissiles > 0 and remainingMissiles >= minNumberOfMissiles ) then
		returnValue = true
	end
	return returnValue
end

function SkynetIADSAbstractElement:pointDefencesHaveEnoughLaunchers(minNumberOfLaunchers)
	local numOfLaunchers = 0
	for i = 1, #self.pointDefences do
		local pointDefence = self.pointDefences[i]
		numOfLaunchers = numOfLaunchers + #pointDefence:getLaunchers()	
	end
	local returnValue = false
	if ( numOfLaunchers > 0 and numOfLaunchers >= minNumberOfLaunchers ) then
		returnValue = true
	end
	return returnValue
end

function SkynetIADSAbstractElement:setIgnoreHARMSWhilePointDefencesHaveAmmo(state)
	if state == true or state == false then
		self.ingnoreHARMSWhilePointDefencesHaveAmmo = state
	end
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
		self.actAsEW = ewState
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
	self.harmDetectionChance = chance
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
		
		local numElementsCreated = #self.searchRadars + #self.trackingRadars + #self.launchers
		--this check ensures a unit or group has all required elements for the specific sam or ew type:
		if (hasLauncher and hasSearchRadar and hasTrackingRadar and #self.launchers > 0 and #self.searchRadars > 0  and #self.trackingRadars > 0 ) 
			or (hasSearchRadar and hasLauncher and #self.searchRadars > 0 and #self.launchers > 0) 
				or (hasSearchRadar and hasLauncher == false and hasTrackingRadar == false and #self.searchRadars > 0 and numUnits == 1) then
			local harmDetection = dataType['harm_detection_chance']
			if harmDetection then
				self.harmDetectionChance = harmDetection
			end
			local natoName = dataType['name']['NATO']
			--we shorten the SA-XX names and don't return their code names eg goa, gainful..
			local pos = natoName:find(" ")
			local prefix = natoName:sub(1, 2)
			if string.lower(prefix) == 'sa' and pos ~= nil then
				self.natoName = natoName:sub(1, (pos-1))
			else
				self.natoName = natoName
			end
			break
		end	
	end
end

function SkynetIADSAbstractRadarElement:analyseAndAddUnit(class, tableToAdd, unitData)
	local units = self:getUnitsToAnalyse()
	for i = 1, #units do
		local unit = units[i]
		local unitTypeName = unit:getTypeName()
		for unitName, unitPerformanceData in pairs(unitData) do
			if unitName == unitTypeName then
				samElement = class:create(unit)
				samElement:setupRangeData()
				table.insert(tableToAdd, samElement)
			end
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
	and ( (self.isAutonomous == false) or (self.isAutonomous == true and self.autonomousBehaviour == SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI ) )
	and (self:hasRemainingAmmo() == true  )
	then
		if self:isDestroyed() == false then
			local  cont = self:getController()
			cont:setOnOff(true)
			cont:setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.RED)	
			cont:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_FREE)
			self.goLiveTime = timer.getTime()
		end
		self.aiState = true
		self:pointDefencesStopActingAsEW()
		if  self.iads:getDebugSettings().radarWentLive then
			self.iads:printOutput(self:getDescription().." going live")
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


function SkynetIADSAbstractRadarElement:noDamageToRadars()
	local radars = self:getRadars()
	for i = 1, #radars do
		local radar = radars[i]
		if radar:getLifePercentage() < 100 then
			return false
		end
	end	
	return true
end

function SkynetIADSAbstractRadarElement:goDark()
	if ( self.aiState == true ) 
	and (self.harmSilenceID ~= nil or ( self.harmSilenceID == nil and #self:getDetectedTargets() == 0 and self:hasMissilesInFlight() == false) or ( self.harmSilenceID == nil and #self:getDetectedTargets() > 0 and self:hasMissilesInFlight() == false and self:hasRemainingAmmo() == false ) )	
	and ( self.isAutonomous == false or ( self.isAutonomous == true and self.autonomousBehaviour == SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK )  )
	then
		if self:isDestroyed() == false then
			local controller = self:getController()
			-- if the SAM site still has ammo we turn off the controller, this prevents rearming, however this way the SAM site is frozen in a red state, on the next actication it will be up and running much faster, therefore it will instantaneously engage targets
			-- also  this is a better way to get the HARM to miss the target, if not set to false the HARM often sticks to the target
			if self:hasRemainingAmmo() then
				controller:setOnOff(false)
			--if the SAM is out of ammo we set the state to green, and ROE to weapon hold, this way it will shut down its radar and it can be rearmed
			else
				controller:setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.GREEN)
				controller:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_HOLD)
			end
		end
		-- point defence will only go live if the Radar Emitting site it is protecting goes dark and this is due to a it defending against a HARM
		if (self.harmSilenceID ~= nil) then
			self:pointDefencesGoLive()
		end
		self.aiState = false
		self:stopScanningForHARMs()
		if self.iads:getDebugSettings().samWentDark then
			self.iads:printOutput(self:getDescription().." going dark")
		end
	end
end

function SkynetIADSAbstractRadarElement:pointDefencesGoLive()
	for i = 1, #self.pointDefences do
		local pointDefence = self.pointDefences[i]
		pointDefence:setActAsEW(true)
	end
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
	if self.isAutonomous == true then
		self.isAutonomous = false
		self:goDark()
	end
end

function SkynetIADSAbstractRadarElement:goAutonomous()
	if self.isAutonomous == false then
		self.isAutonomous = true
		self:goDark()
		self:goLive()
	end
end

function SkynetIADSAbstractRadarElement:getAutonomousState()
	return self.isAutonomous
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
				self.iads:printOutput("JAMMER: "..self:getDescription()..": Probability: "..successProbability)
			end
			if successProbability > probability then
				controller:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_HOLD)
				if self.iads:getDebugSettings().jammerProbability then
					self.iads:printOutput("JAMMER: "..self:getDescription()..": jammed, setting to weapon hold")
				end
			else
				controller:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_FREE)
				if self.iads:getDebugSettings().jammerProbability then
					self.iads:printOutput("Jammer: "..self:getDescription()..": jammed, setting to weapon free")
				end
			end
			self.lastJammerUpdate = timer:getTime()
		end
end

function SkynetIADSAbstractRadarElement:scanForHarms()
	self:stopScanningForHARMs()
	self.harmScanID = mist.scheduleFunction(SkynetIADSAbstractRadarElement.evaluateIfTargetsContainHARMs, {self}, 1, 2)
end

function SkynetIADSAbstractElement:isScanningForHARMs()
	return self.harmScanID ~= nil
end

function SkynetIADSAbstractElement:isDefendingHARM()
	return self.harmSilenceID ~= nil
end

function SkynetIADSAbstractRadarElement:stopScanningForHARMs()
	mist.removeFunction(self.harmScanID)
	self.harmScanID = nil
end

function SkynetIADSAbstractRadarElement:goSilentToEvadeHARM(timeToImpact)
	self:finishHarmDefence(self)
	self.objectsIdentifiedAsHarms = {}
	local harmTime = self:getHarmShutDownTime()
	if self.iads:getDebugSettings().harmDefence then
		self.iads:printOutput("HARM DEFENCE: "..self:getDCSName().." shutting down | FOR: "..harmTime.." seconds | TTI: "..timeToImpact)
	end
	self.harmSilenceID = mist.scheduleFunction(SkynetIADSAbstractRadarElement.finishHarmDefence, {self}, timer.getTime() + harmTime, 1)
	self:goDark()
end

function SkynetIADSAbstractRadarElement:getHarmShutDownTime()
	local shutDownTime = math.random(self.minHarmShutdownTime, self.maxHarmShutDownTime)
	return shutDownTime
end

function SkynetIADSAbstractRadarElement.finishHarmDefence(self)
	mist.removeFunction(self.harmSilenceID)
	self.harmSilenceID = nil
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
					local iadsTarget = SkynetIADSContact:create(target)
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
	return ( self:pointDefencesHaveRemainingAmmo(numOfHarms) and self:pointDefencesHaveEnoughLaunchers(numOfHarms) and self.ingnoreHARMSWhilePointDefencesHaveAmmo == true)
end


function SkynetIADSAbstractRadarElement:getNumberOfObjectsItentifiedAsHARMS()
	local numFound = 0
	for unitName, unit in pairs(self.objectsIdentifiedAsHarms) do
		numFound = numFound + 1
	end
	return numFound
end

function SkynetIADSAbstractRadarElement:cleanUpOldObjectsIdentifiedAsHARMS()
	local validObjects = {}
	for unitName, unit in pairs(self.objectsIdentifiedAsHarms) do
		local harm = unit['target']
		if harm:getAge() <= self.objectsIdentifiedAsHarmsMaxTargetAge then
			validObjects[harm:getName()] = {}
			validObjects[harm:getName()]['target'] = harm
			validObjects[harm:getName()]['count'] = unit['count']
		end
	end
	self.objectsIdentifiedAsHarms = validObjects
	
	--stop point defences acting as ew (always on), will occur of activated via shallIgnoreHARMShutdown() in evaluateIfTargetsContainHARMs
	if self:getNumberOfObjectsItentifiedAsHARMS() == 0 then
		self:pointDefencesStopActingAsEW()
	end
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
	
	
	local targets = self:getDetectedTargets() 
	for i = 1, #targets do
		local target = targets[i]
		local radars = self:getRadars()
		for j = 1, #radars do	
			local radar = radars[j]
			if radar:isExist() == true then
				local distance = self:getDistanceInMetersToContact(radar, target:getPosition().p)
				local impactPoint = self:calculateImpactPoint(target, distance)
				if impactPoint then
					local harmImpactPointDistanceToSAM = self:getDistanceInMetersToContact(radar, impactPoint)
					if harmImpactPointDistanceToSAM <= 100 then
						if self.objectsIdentifiedAsHarms[target:getName()] then
							self.objectsIdentifiedAsHarms[target:getName()]['count'] = self.objectsIdentifiedAsHarms[target:getName()]['count'] + 1
						else
							self.objectsIdentifiedAsHarms[target:getName()] =  {}
							self.objectsIdentifiedAsHarms[target:getName()]['target'] = target
							self.objectsIdentifiedAsHarms[target:getName()]['count'] = 1
						end
						local savedTarget = self.objectsIdentifiedAsHarms[target:getName()]['target']
						savedTarget:refresh()
						local numDetections = self.objectsIdentifiedAsHarms[target:getName()]['count']
						local speed = savedTarget:getGroundSpeedInKnots()
						local timeToImpact = self:getSecondsToImpact(mist.utils.metersToNM(distance), speed)
						local shallReactToHarm = self:shallReactToHARM()
						
					--	if self:getNumberOfObjectsItentifiedAsHARMS() > 0 then
					--		env.info("detect as HARM: "..self:getDCSName().." "..self:getNumberOfObjectsItentifiedAsHARMS())
					--	end
						
						-- we use 2 detection cycles so a random object in the air pointing at the SAM site for a spilt second will not trigger a shutdown. shallReactToHarm adds some salt otherwise the SAM will always shut down 100% of the time.
						if numDetections == 2 and shallReactToHarm then
							if self:shallIgnoreHARMShutdown() == false then
								self.minHarmShutdownTime = self:calculateMinimalShutdownTimeInSeconds(timeToImpact)
								self.maxHarmShutDownTime = self:calculateMaximalShutdownTimeInSeconds(self.minHarmShutdownTime)
								self:goSilentToEvadeHARM(timeToImpact)
							else
								self:pointDefencesGoLive()
							end
						end
						if numDetections == 2 and shallReactToHarm == false then
							if self.iads:getDebugSettings().harmDefence then
								self.iads:printOutput("HARM DEFENCE: "..self:getDCSName().." will not react")
							end
						end
					end
				end
			end
		end
	end
end

end
