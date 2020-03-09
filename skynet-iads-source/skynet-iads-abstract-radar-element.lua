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
	instance.jammerID = nil
	instance.lastJammerUpdate = 0
	instance.setJammerChance = true
	instance.harmScanID = nil
	instance.harmSilenceID = nil
	instance.objectsIdentifiedAsHarms = {}
	instance.launchers = {}
	instance.trackingRadars = {}
	instance.searchRadars = {}
	instance.autonomousBehaviour = SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI
	instance.goLiveRange = SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE
	instance.isAutonomous = false
	instance.harmDetectionChance = 0
	instance.minHarmShutdownTime = 0
	instance.maxHarmShutDownTime = 0
	instance.minHarmPresetShutdownTime = 30
	instance.maxHarmPresetShutdownTime = 180
	instance.firingRangePercent = 100
	instance:setupElements()
	instance:goLive()
	return instance
end


function SkynetIADSAbstractRadarElement:getUnitsToAnalyse()
	local units = {}
	units[1] = self:getDCSRepresentation()
	if getmetatable(self:getDCSRepresentation()) == Group then
		units = self:getDCSRepresentation():getUnits()
	end
	return units
end

function SkynetIADSAbstractRadarElement:getHarmDetectionChance()
	return self.harmDetectionChance
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
		if (hasLauncher and hasSearchRadar and hasTrackingRadar and #self.launchers > 0 and #self.searchRadars > 0  and #self.trackingRadars > 0 ) or ( hasSearchRadar and hasLauncher and #self.searchRadars > 0 and #self.launchers > 0) then
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
				samElement = class:create(unit, unitPerformanceData)
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
	if ( self.aiState == false and self:hasWorkingPowerSource() and self.harmSilenceID == nil ) and ( (self.isAutonomous == false) or (self.isAutonomous == true and self.autonomousBehaviour == SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI ) ) then
		if self:isDestroyed() == false then
			local  cont = self:getController()
			cont:setOnOff(true)
			cont:setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.RED)	
			cont:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_FREE)
		end
		self.aiState = true
		if  self.iads:getDebugSettings().radarWentLive then
			self.iads:printOutput(self:getDescription().." going live")
		end
		self:scanForHarms()
	end
end

function SkynetIADSAbstractRadarElement:goDark()
	if ( self.aiState == true ) and ( ( #self:getDetectedTargets() == 0 or self.harmSilenceID ~= nil) or ( self.isAutonomous == true and self.autonomousBehaviour == SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK ) ) then
		if self:isDestroyed() == false then
			local controller = self:getController()
			-- fastest way to get a radar unit to stop emitting
			controller:setOnOff(false)
			--controller:setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.GREEN)
			--controller:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_HOLD)
		end
		self.aiState = false
		mist.removeFunction(self.jammerID)
		self:stopScanningForHarms()
		if self.iads:getDebugSettings().samWentDark then
			self.iads:printOutput(self:getDescription().." going dark")
		end
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
		end
	end
	
	if self.goLiveRange == SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE then
		
		isLauncherInRange = ( #self.launchers == 0 )
		for i = 1, #self.launchers do
			local launcher = self.launchers[i]
			if launcher:isInRange(target) or launcher:isAAA() then
				isLauncherInRange = true
			end
		end
		
		isTrackingRadarInRange = ( #self.trackingRadars == 0 )
		for i = 1, #self.trackingRadars do
			local trackingRadar = self.trackingRadars[i]
			if trackingRadar:isInRange(target) then
				isTrackingRadarInRange = true
			end
		end
	else
		isLauncherInRange = true
		isTrackingRadarInRange = true
	end
	return  (isSearchRadarInRange and isTrackingRadarInRange and isLauncherInRange )
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

function SkynetIADSAbstractRadarElement:goAutonomous()
	self.isAutonomous = true
	self:goDark()
	self:goLive()
end

function SkynetIADSAbstractRadarElement:jam(successProbability)
	--trigger.action.outText(self.lastJammerUpdate, 2)
	if self.lastJammerUpdate == 0 then
		--trigger.action.outText("updating jammer probability", 5)
		self.lastJammerUpdate = 10
		self.setJammerChance = true
		mist.removeFunction(self.jammerID)
		self.jammerID = mist.scheduleFunction(SkynetIADSAbstractRadarElement.setJamState, {self, successProbability}, 1, 1)
	end
end

function SkynetIADSAbstractRadarElement.setJamState(self, successProbability)
	if self.setJammerChance then
		if self:isDestroyed() == false then
			local controller = self:getController()
			self.setJammerChance = false
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
		end
	end
	self.lastJammerUpdate = self.lastJammerUpdate - 1
end

function SkynetIADSAbstractRadarElement:scanForHarms()
	self:stopScanningForHarms()
	self.harmScanID = mist.scheduleFunction(SkynetIADSAbstractRadarElement.evaluateIfTargetsContainHarms, {self}, 1, 2)
end

function SkynetIADSAbstractElement:isScanningForHarms()
	return self.harmScanID ~= nil
end

function SkynetIADSAbstractRadarElement:stopScanningForHarms()
	mist.removeFunction(self.harmScanID)
	self.harmScanID = nil
end

function SkynetIADSAbstractRadarElement:goSilentToEvadeHarm()
	self:finishHarmDefence(self)
	self.objectsIdentifiedAsHarms = {}
	local harmTime = self:getHarmShutDownTime()
	self.harmSilenceID = mist.scheduleFunction(SkynetIADSAbstractRadarElement.finishHarmDefence, {self}, timer.getTime() + harmTime, 1)
	self:goDark()
	--trigger.action.outText(tostring(self.harmSilenceID), 1)
	--trigger.action.outText(tostring(harmTime), 1)
end

function SkynetIADSAbstractRadarElement:getHarmShutDownTime()
	local shutDownTime = math.random(self.minHarmShutdownTime, self.maxHarmShutDownTime)
	--trigger.action.outText("shutdowntime: "..shutDownTime, 1)
	return shutDownTime
end

function SkynetIADSAbstractRadarElement.finishHarmDefence(self)
	--trigger.action.outText("finish harm defence", 1)
	mist.removeFunction(self.harmSilenceID)
	self.harmSilenceID = nil
end

function SkynetIADSAbstractRadarElement:getDetectedTargets()
	local returnTargets = {}
	if self:hasWorkingPowerSource() and self:isDestroyed() == false then
		local targets = self:getController():getDetectedTargets(Controller.Detection.RADAR)
		for i = 1, #targets do
			local target = targets[i]
			-- there are cases when a destroyed object is still visible as a target to the radar, don't add it, will cause errors in the sam firing code
			if target.object then
				local iadsTarget = SkynetIADSContact:create(target)
				iadsTarget:refresh()
				if self:isTargetInRange(iadsTarget) then
					table.insert(returnTargets, iadsTarget)
				end
			end
		end
	end
	return returnTargets
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

function SkynetIADSAbstractRadarElement:getDistanceNMToContact(radarUnit, contact)
	local distanceMeters = mist.utils.metersToNM(mist.utils.get2DDist(contact:getPosition().p, radarUnit:getPosition().p))
	return mist.utils.round(distanceMeters, 2)
end

function SkynetIADSAbstractRadarElement:calculateMinimalShutdownTimeInSeconds(timeToImpact)
	return timeToImpact + self.minHarmPresetShutdownTime
end

function SkynetIADSAbstractRadarElement:calculateMaximalShutdownTimeInSeconds(minShutdownTime)	
	return minShutdownTime + mist.random(1, self.maxHarmPresetShutdownTime)
end


function SkynetIADSAbstractRadarElement.evaluateIfTargetsContainHarms(self, detectionType)
	local targets = self:getDetectedTargets() 
	for i = 1, #targets do
		local target = targets[i]
		--if target:getTypeName() == 'weapons.missiles.AGM_88' then
		--	trigger.action.outText("Detection Type: "..detectionType, 1)
		--	trigger.action.outText(target:getTypeName(), 1)
		--	trigger.action.outText("Is Type Known: "..tostring(target:isTypeKnown()), 1)
		--	trigger.action.outText("Distance is Known: "..tostring(target:isDistanceKnown()), 1)
			local radars = self:getRadars()
			for j = 1, #radars do
				local radar = radars[j]
				local distance = self:getDistanceNMToContact(target, radar)
			--	trigger.action.outText("Missile to SAM distance: "..distance, 1)
				-- distance needs to be incremented by a certain value for ip calculation to work, check why, distance needs to be m here!
				local impactPoint = land.getIP(target:getPosition().p, target:getPosition().x, distance + 100)
				if impactPoint then
					local diststanceToSam = mist.utils.get2DDist(radar:getPosition().p, impactPoint)
					--trigger.action.outText("Impact Point distance to SAM site: "..diststanceToSam, 1)
					---trigger.action.outText("detected Object Name: "..target:getName(), 1)
					--trigger.action.outText("Impact Point X: "..impactPoint.x.."Y: "..impactPoint.y.."Z: "..impactPoint.z, 1)
					if diststanceToSam <= 100 then
						local numDetections = 0
						if self.objectsIdentifiedAsHarms[target:getName()] then
							numDetections = self.objectsIdentifiedAsHarms[target:getName()]['num_detections']
							numDetections = numDetections + 1
							self.objectsIdentifiedAsHarms[target:getName()]['num_detections'] = numDetections
						else
							self.objectsIdentifiedAsHarms[target:getName()]= {}
							self.objectsIdentifiedAsHarms[target:getName()]['target'] = target
							self.objectsIdentifiedAsHarms[target:getName()]['num_detections'] = 0
							numDetections = self.objectsIdentifiedAsHarms[target:getName()]['num_detections']
						end
						local randomReaction = math.random(1, 100)
						local targetHarm = self.objectsIdentifiedAsHarms[target:getName()]['target']
						targetHarm:refresh()
						local speed = targetHarm:getGroundSpeedInKnots()
						local timeToImpact = self:getSecondsToImpact(distance, speed )
						trigger.action.outText("detection Cycle: "..numDetections.." Random: "..randomReaction.." GS: "..targetHarm:getGroundSpeedInKnots().."TTI: "..timeToImpact, 1)
						---use distance and speed of harm to determine min shutdown time
						if numDetections == 3 and self.harmDetectionChance > randomReaction then
							self.minHarmShutdownTime = self:calculateShutdownTimeInSeconds(timeToImpact)
							self.maxHarmShutDownTime = self:calculateMaximalShutdownTimeInSeconds(self.minHarmShutdownTime)
							trigger.action.outText("SAM EVADING HARM", 1)
							self:goSilentToEvadeHarm()
						end
					end
				end
			end
	--	end
	end
end

end
