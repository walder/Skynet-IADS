do

SkynetIADSAbstractRadarElement = {}
SkynetIADSAbstractRadarElement = inheritsFrom(SkynetIADSAbstractElement)

function SkynetIADSAbstractRadarElement:create(dcsElementWithRadar, iads)
	local instance = self:superClass():create(dcsElementWithRadar, iads)
	setmetatable(instance, self)
	self.__index = self
	--instance.targetsInRange = {}
	instance.jammerID = nil
	instance.lastJammerUpdate = 0
	instance.setJammerChance = true
	instance.harmScanID = nil
	instance.objectsIdentifiedasHarms = {}
	instance.shutdownforHarmDefence = false
	instance.launchers = {}
	instance.trackingRadars = {}
	instance.searchRadars = {}
	instance:setupElements()
	return instance
end

function SkynetIADSAbstractRadarElement:setupElements()
	local units = {}
	local natoName = self.natoName
	local allUnitsFound = false
	units[1] = self:getDCSRepresentation()
	if getmetatable(self:getDCSRepresentation()) == Group then
		units = self:getDCSRepresentation():getUnits()
	end
	local unitTypes = {}
	--trigger.action.outText("-----"..self:getDCSName().."--------", 1)
	for i = 1, #units do
		local unitName = units[i]:getTypeName()
		if unitTypes[unitName] then
			unitTypes[unitName]['count'] = unitTypes[unitName]['count'] + 1
		else
			unitTypes[unitName] = {}
			unitTypes[unitName]['count'] = 1
			unitTypes[unitName]['found'] = 0
		end
	end
	for i = 1, #units do
		local unit = units[i]
		local unitTypeName = unit:getTypeName()
		for typeName, dataType in pairs(SkynetIADS.database) do
		
			allUnitsFound = true
			for name, countData in pairs(unitTypes) do
				if countData['count'] ~= countData['found'] then
					allUnitsFound = false
					countData['found'] = 0
				end
			end
			if allUnitsFound then
		--		trigger.action.outText("break", 1)
				break
			end
		
			for entry, unitData in pairs(dataType) do
				if entry == 'searchRadar' then
					for unitName, unitPerformanceData in pairs(unitData) do
						if unitName == unitTypeName then
							local searchRadar = SkynetIADSSAMSearchRadar:create(unit, unitPerformanceData)
							table.insert(self.searchRadars, searchRadar)
							--trigger.action.outText("added search radar", 1)
							unitTypes[unitName]['found'] = unitTypes[unitName]['count']
							natoName = dataType['name']['NATO']
						end
					end
				elseif entry == 'launchers' then
					for unitName, unitPerformanceData in pairs(unitData) do
						if unitName == unitTypeName then
							local launcher = SkynetIADSSAMLauncher:create(unit, unitPerformanceData)
							table.insert(self.launchers, launcher)
							unitTypes[unitName]['found'] = unitTypes[unitName]['count']
							natoName = dataType['name']['NATO']
							--trigger.action.outText(launcher:getRange(), 1)
						end
					end
				elseif entry == 'trackingRadar' then
					for unitName, unitPerformanceData in pairs(unitData) do
						if unitName == unitTypeName then
							local trackingRadar = SkynetIADSSAMTrackingRadar:create(unit, unitPerformanceData)
							table.insert(self.trackingRadars, trackingRadar)
							unitTypes[unitName]['found'] = unitTypes[unitName]['count']
							natoName = dataType['name']['NATO']
							--trigger.action.outText("added tracking radar", 1)
						end
					end
				end
			end
		end
	end
	local countNatoNames = 0
	for name, countData in pairs(unitTypes) do
		if countData['count'] ~= countData['found'] then
		--	trigger.action.outText("MISMATCH: "..name.." "..countData['count'].." "..countData['found'], 1)
		end
	end
	--we shorten the SA-XX names and don't return their code names eg goa, gainful..
	local pos = natoName:find(" ")
	local prefix = natoName:sub(1, 2)
	if string.lower(prefix) == 'sa' and pos ~= nil then
		natoName = natoName:sub(1, (pos-1))
	end
	self.natoName = natoName
--	trigger.action.outText(self:getDCSName().." nato name: "..natoName, 1)
end

function SkynetIADSAbstractRadarElement:getController()
	return self:getDCSRepresentation():getController()
end

function SkynetIADSAbstractRadarElement:goLive()
	if self:hasWorkingPowerSource() == false or self.shutdownforHarmDefence == true then
		return
	end
	if self.aiState == false and self:isControllableUnit() then
		local  cont = self:getController()
		cont:setOnOff(true)
		cont:setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.RED)	
		cont:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_FREE)
		self.aiState = true
		if  self.iads:getDebugSettings().radarWentLive then
			self.iads:printOutput(self:getDescription().." going live")
		end
	end
end

function SkynetIADSAbstractRadarElement:isActive()
	return self.aiState
end

function SkynetIADSAbstractRadarElement:isTargetInRange(target)
	
	local isSearchRadarInRange = ( #self.searchRadars == 0 )
	for i = 1, #self.searchRadars do
		local searchRadar = self.searchRadars[i]
		if searchRadar:isInRange(target) then
			isSearchRadarInRange = true
		end
	end
	
	local isLauncherInRange = ( #self.launchers == 0 )
	for i = 1, #self.launchers do
		local launcher = self.launchers[i]
		if launcher:isInRange(target) then
			isLauncherInRange = true
		end
	end
	
	local isTrackingRadarInRange = ( #self.trackingRadars == 0 )
	for i = 1, #self.trackingRadars do
		local trackingRadar = self.trackingRadars[i]
		if trackingRadar:isInRange(target) then
			isTrackingRadarInRange = true
		end
	end
	--trigger.action.outText(self:getNatoName()..": in Range of Search Radar: "..tostring(isSearchRadarInRange).." Launcher: "..tostring(isLauncherInRange).." Tracking Radar: "..tostring(isTrackingRadarInRange), 1)
	--TODO: handle special case for AAA to go live when in Search Range not firing Range
	return  (isSearchRadarInRange and isTrackingRadarInRange and isLauncherInRange )
end

function SkynetIADSAbstractRadarElement:goDark(enforceGoDark)
	-- if the sam site has contacts in range, it will refuse to go dark, unless we enforce shutdown (power failure)
	if	#self:getDetectedTargets(true) > 0 and enforceGoDark ~= true then
		return
	end
	if self.aiState == true then
		local controller = self:getController()
		-- fastest way to get a radar unit to stop emitting
		controller:setOnOff(false)
		--controller:setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.GREEN)
		--controller:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_HOLD)
		self.aiState = false
		mist.removeFunction(self.jammerID)
		mist.removeFunction(self.harmScanID)
		if self.iads:getDebugSettings().samWentDark then
			self.iads:printOutput(self:getDescription().." going dark")
		end
	end
end

--this function is currently a simple placeholder, should only read all the radar units of the SAM system an return them
--use this: if samUnit:hasSensors(Unit.SensorType.RADAR, Unit.RadarType.AS) or samUnit:hasAttribute("SAM SR") or samUnit:hasAttribute("EWR") or samUnit:hasAttribute("SAM TR") or samUnit:hasAttribute("Armed ships") then
function SkynetIADSAbstractRadarElement:getRadarUnits()
	return self:getDCSRepresentation():getUnits()
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
	self.lastJammerUpdate = self.lastJammerUpdate - 1
end

function SkynetIADSAbstractRadarElement:getNumTargetsInRange()
	local contacts = 0
	for description, aircraft in pairs(self.targetsInRange) do
		contacts = contacts + 1
	end
	--trigger.action.outText("num Contacts in Range: "..contacts, 1)
	return contacts
end

function SkynetIADSAbstractRadarElement:scanForHarms()
	mist.removeFunction(self.harmScanID)
	self.harmScanID = mist.scheduleFunction(SkynetIADSAbstractRadarElement.evaluateIfTargetsContainHarms, {self}, 1, 5)
end

function SkynetIADSAbstractRadarElement:getDetectedTargets(inKillZone)
	local returnTargets = {}
	if self:hasWorkingPowerSource() then
		--trigger.action.outText("EW getTargets", 1)
		--trigger.action.outText(self.radarUnit:getName(), 1)
		local targets = self:getController():getDetectedTargets(Controller.Detection.RADAR)
		--trigger.action.outText("num Targets: "..#targets, 1)
		for i = 1, #targets do
			local target = targets[i]
			local iadsTarget = SkynetIADSContact:create(target)
			iadsTarget:refresh()
			if inKillZone then
				if self:isTargetInRange(iadsTarget) then
					table.insert(returnTargets, iadsTarget)
				end
			else
				table.insert(returnTargets, iadsTarget)
			end
		end
	end
	return returnTargets
end

--Todo: detection of HARM ist to perfect, add randomisation, add reactivation time or the IADS could give SAM green lights, when no Strikers are in the area of the sam anymore.
function SkynetIADSAbstractRadarElement.evaluateIfTargetsContainHarms(self, detectionType)
	local targets = self:getDetectedTargets() 
	for i = 1, #targets do
		local target = targets[i]
		--if target:getTypeName() == 'weapons.missiles.AGM_88' then
		--	trigger.action.outText("Detection Type: "..detectionType, 1)
		--	trigger.action.outText(target:getTypeName(), 1)
		--	trigger.action.outText("Is Type Known: "..tostring(target:isTypeKnown()), 1)
		--	trigger.action.outText("Distance is Known: "..tostring(target:isDistanceKnown()), 1)
			local radars = self:getRadarUnits()
			for j = 1, #radars do
				local radar = radars[j]
				local distance = mist.utils.get3DDist(target:getPosition().p, radar:getPosition().p)
			--	trigger.action.outText("Missile to SAM distance: "..distance, 1)
				-- distance needs to be incremented by a certain value for ip calculation to work, check why
				local impactPoint = land.getIP(target:getPosition().p, target:getPosition().x, distance+100)
				if impactPoint then
					local diststanceToSam = mist.utils.get2DDist(radar:getPosition().p, impactPoint)
				--	trigger.action.outText("Impact Point distance to SAM site: "..diststanceToSam, 1)
				--	trigger.action.outText("detected Object Name: "..target:getName(), 1)
					--trigger.action.outText("Impact Point X: "..impactPoint.x.."Y: "..impactPoint.y.."Z: "..impactPoint.z, 1)
					if diststanceToSam <= 100 then
						local numDetections = 0
						if self.objectsIdentifiedasHarms[target:getName()] then
							numDetections = self.objectsIdentifiedasHarms[target:getName()]
							numDetections = numDetections + 1
							self.objectsIdentifiedasHarms[target:getName()] = numDetections
						else
							self.objectsIdentifiedasHarms[target:getName()] = 1
							numDetections = self.objectsIdentifiedasHarms[target:getName()]
						end
					--	trigger.action.outText("detection Cycle: "..numDetections, 1)
						-- this may still be too perfect, add some kind of randomisation, but where?
						if numDetections >= 3 then
							self:goDark(true)
							self.shutdownforHarmDefence = true
						end
					end
				end
			end
	--	end
	end
end

end
