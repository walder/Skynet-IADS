do

SkynetIADSSamSite = {}
SkynetIADSSamSite = inheritsFrom(SkynetIADSAbstractElement)

SkynetIADSSamSite.AUTONOMOUS_STATE_DCS_AI = 0
SkynetIADSSamSite.AUTONOMOUS_STATE_DARK = 1

function SkynetIADSSamSite:create(samGroup, iads)
	local sam = self:superClass():create()
	setmetatable(sam, self)
	self.__index = self
	sam.aiState = true
	sam.iads = iads
	sam.isAutonomous = false
	sam.targetsInRange = {}
	sam.jammerID = nil
	sam.lastJammerUpdate = 0
	sam.setJammerChance = true
	sam.autonomousMode = SkynetIADSSamSite.AUTONOMOUS_STATE_DCS_AI
	sam:setDCSRepresentation(samGroup)
	sam:goDark(true)
	world.addEventHandler(sam)
	return sam
end

function SkynetIADSSamSite:goDark(enforceGoDark)
	-- if the sam site has contacts in range, it will refuse to go dark, unless we enforce shutdown
	if ( self:getNumTargetsInRange() > 0 ) and ( enforceGoDark ~= true ) then
		return
	end
	if self.aiState == true then
		local controller = self:getController()
		-- we will turn off AI for all SAM Sites added to the IADS, Skynet decides when a site will go online.
		controller:setOnOff(false)
		controller:setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.GREEN)
		controller:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_HOLD)
		self.aiState = false
		mist.removeFunction(self.jammerID)
		if self.iads:getDebugSettings().samWentDark then
			self.iads:printOutput(self:getDescription().." going dark")
		end
	end
end

function SkynetIADSSamSite:goLive()
	if self:hasWorkingPowerSource() == false then
		return
	end
	if self.aiState == false then
		local  cont = self:getController()
		cont:setOnOff(true)
		cont:setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.RED)	
		cont:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_FREE)
		---cont:knowTarget(ewrTarget, true, true) check to see if this will help for a faster shot of the SAM
		self.aiState = true
		if self.iads:getDebugSettings().samWentLive then
			self.iads:printOutput(self:getDescription().." going live")
		end
	end
end

--this function is currently a simple placeholder, should read all the radar units of the SAM system an return them
--use this:
--if samUnit:hasSensors(Unit.SensorType.RADAR, Unit.RadarType.AS) or samUnit:hasAttribute("SAM SR") or samUnit:hasAttribute("EWR") or samUnit:hasAttribute("SAM TR") or samUnit:hasAttribute("Armed ships") then
function SkynetIADSSamSite:getRadarUnits()
	return self:getDCSRepresentation():getUnits()
end

function SkynetIADSSamSite:jam(successRate)
	--trigger.action.outText(self.lastJammerUpdate, 2)
	if self.lastJammerUpdate == 0 then
		--trigger.action.outText("updating jammer probability", 5)
		self.lastJammerUpdate = 10
		self.setJammerChance = true
		local jammerChance = successRate
		mist.removeFunction(self.jammerID)
		self.jammerID = mist.scheduleFunction(SkynetIADSSamSite.setJamState, {self, jammerChance}, 1, 1)
	end
end

function SkynetIADSSamSite.setJamState(self, jammerChance)
	local controller = self:getController()
	if self.setJammerChance then
		self.setJammerChance = false
		local probability = math.random(100)
		if self.iads:getDebugSettings().jammerProbability then
			self.iads:printOutput("JAMMER: "..self:getDescription()..": Probability: "..jammerChance)
		end
		if jammerChance > probability then
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

function SkynetIADSSamSite:getNumTargetsInRange()
	local contacts = 0
	for description, aircraft in pairs(self.targetsInRange) do
		contacts = contacts + 1
	end
	--trigger.action.outText("num Contacts in Range: "..contacts, 1)
	return contacts
end

function SkynetIADSSamSite:isActive()
	return self.aiState
end

function SkynetIADSSamSite:goAutonomous()
	self.isAutonomous = true
	self.targetsInRange = {}
	if self.autonomousMode == SkynetIADSSamSite.AUTONOMOUS_STATE_DARK then
		self:goDark()
		trigger.action.outText(self:getDescription().." is Autonomous: DARK", 1)

	else
		self:goLive()
		trigger.action.outText(self:getDescription().." is Autonomous: DCS AI", 1)
	end
	return
end

function SkynetIADSSamSite:setAutonomousMode(mode)
	if mode ~= nil then
		self.autonomousMode = mode
	end
end

function SkynetIADSSamSite:handOff(contact)
	-- if the sam has no power, it won't do anything
	if self:hasWorkingPowerSource() == false then
		self:goDark(true)
		trigger.action.outText(self:getDescription().." has no Power", 1)
		return
	end
	if self:isTargetInRange(contact) then
		self.targetsInRange[contact:getName()] = contact
		self:goLive()
	else
		self:removeContact(contact)
		self:goDark()
	end
end

function SkynetIADSSamSite:removeContact(contact)
	local updatedContacts = {}
	for id, airborneObject in pairs(self.targetsInRange) do
		-- check to see if airborneObject still exists there are cases where the sam keeps the target in the array of contacts
		if airborneObject ~= contact and airborneObject:isExist() then
			updatedContacts[id] = airborneObject
		end
	end
	self.targetsInRange = updatedContacts
end

function SkynetIADSSamSite:isTargetInRange(target)
	local samSiteUnits = self:getDCSRepresentation():getUnits()
	local samRadarInRange = false
	local samLauncherinRange = false
	--go through sam site units to check launcher and radar distance, they could be positioned quite far apart, only activate if both are in reach
	for j = 1, #samSiteUnits do
		local  samElement = samSiteUnits[j]
		local typeName = samElement:getTypeName()
		local samDBData = SkynetIADS.database[self:getDBName()]
		--trigger.action.outText("type name: "..typeName, 1)
		local radarData = samDBData['searchRadar'][typeName]
		local launcherData = samDBData['launchers'][typeName]
		local trackingData = nil
		if radarData == nil then
			--to decide if we should activate the sam we use the tracking radar range if it exists
			trackingData = SkynetIADS.database[self:getDBName()]['trackingRadar']
		end
		--if we find a radar in a SAM site, we calculate to see if it is within tracking parameters
		if radarData ~= nil then
			if self:isRadarWithinTrackingParameters(target, samElement, radarData) then
				samRadarInRange = true
			end
		end
		--if we find a launcher in a SAM site, we calculate to see if it is within firing parameters
		if launcherData ~= nil then
			--if it's a AAA we override the check for launcher distance, otherwise the target will pass over the AAA without it firing because the AAA will become active too late
			if launcherData['aaa'] then
				samLauncherinRange = true
			end
			-- if it's not AAA we calculate the firing distance
			if self:isLauncherWithinFiringParameters(target, samElement, launcherData) and ( samLauncherinRange == false  ) then
				samLauncherinRange = true
			end
		end		
	end	
	-- we only need to find one radar and one launcher within range in a Group, the AI of DCS will then decide which launcher will fire
	return ( samRadarInRange and samLauncherinRange )
end

-- TODO: could be more acurrate if it would calculate slant range
function SkynetIADSSamSite:isLauncherWithinFiringParameters(aircraft, samLauncherUnit, launcherData)
	local isInRange = false
	local distance = mist.utils.get2DDist(aircraft:getPosition().p, samLauncherUnit:getPosition().p)
	local maxFiringRange = launcherData['range']
	-- trigger.action.outText("Launcher Range: "..maxFiringRange,1)
	-- trigger.action.outText("current distance: "..distance,1)
	if distance <= maxFiringRange then
		isInRange = true
		--trigger.action.outText(aircraft:getTypeName().." in range of:"..samLauncherUnit:getTypeName(),1)
	end
	return isInRange
end

function SkynetIADSSamSite:isRadarWithinTrackingParameters(aircraft, samRadarUnit, radarData)
	local isInRange = false
	local distance = mist.utils.get2DDist(aircraft:getPosition().p, samRadarUnit:getPosition().p)
	local radarHeight = samRadarUnit:getPosition().p.y
	local aircraftHeight = aircraft:getPosition().p.y	
	local altitudeDifference = math.abs(aircraftHeight - radarHeight)
	local maxDetectionAltitude = radarData['max_alt_finding_target']
	local maxDetectionRange = radarData['max_range_finding_target']	
	-- trigger.action.outText("Radar Range: "..maxDetectionRange,1)
	-- trigger.action.outText("current distance: "..distance,1)
	if altitudeDifference <= maxDetectionAltitude and distance <= maxDetectionRange then
		--trigger.action.outText(aircraft:getTypeName().." in range of:"..samRadarUnit:getTypeName(),1)
		isInRange = true
	end
	return isInRange
end

function SkynetIADSSamSite:isWeaponHarm(weapon)
	local desc = weapon:getDesc()
	return (desc.missileCategory == 6 and desc.guidance == 5)	
end

function SkynetIADSSamSite:onEvent(event)
--[[
	if event.id == world.event.S_EVENT_SHOT then
		local weapon = event.weapon
		targetOfMissile = weapon:getTarget()
		if targetOfMissile ~= nil and self:isWeaponHarm(weapon) then
			self:startHarmDefence(weapon)
		end	
	end
--]]
end

function SkynetIADSSamSite.harmDefence(self, inBoundHarm) 
	local target = inBoundHarm:getTarget()
	local harmDetected = false	
	if target ~= nil then
		local targetController = target:getController()
		trigger.action.outText("HARM TARGET IS: "..target:getName(), 1)	
		local radarContacts = targetController:getDetectedTargets()
		--check to see if targeted Radar Site can see the HARM with its sensors, only then start defensive action
		for i = 1, #radarContacts do
			local detectedObject = radarContacts[i].object
			if SkynetIADS.isWeaponHarm(detectedObject) then
				trigger.action.outText(target:getName().." has detected: "..detectedObject:getTypeName(), 1)
				harmDetected = true
			end
		end
		
		local distance = mist.utils.get2DDist(inBoundHarm:getPosition().p, target:getPosition().p)
		distance = mist.utils.round(mist.utils.metersToNM(distance),2)
		trigger.action.outText("HARM Distance: "..distance, 1)
		
		--TODO: some SAM Sites have HARM defence, so they do not need help from the script
		if distance < 5 and harmDetected then
			local point = inBoundHarm:getPosition().p
			point.y = point.y + 1
			point.x = point.x - 1
			point.z = point.z + 1
		--	trigger.action.explosion(point, 10) 
		end
	else
		trigger.action.outText("target is nil", 1)
	end
end

end
