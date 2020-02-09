do

SkynetIADSSamSite = {}
SkynetIADSSamSite.__index = SkynetIADSSamSite

SkynetIADSSamSite.AUTONOMOUS_STATE_DCS_AI = 0
SkynetIADSSamSite.AUTONOMOUS_STATE_DARK = 1

function SkynetIADSSamSite:create(samGroup)
	local sam = {}
	setmetatable(sam, SkynetIADSSamSite)
	sam.powerSources = {}
	sam.connectionNodes = {}
	sam.aiState = true
	sam.samSite = samGroup
	sam.isAutonomous = false
	sam.targetsInRange = {}
	sam.autonomousMode = SkynetIADSSamSite.AUTONOMOUS_STATE_DCS_AI
	sam:goDark()
	return sam
end

function SkynetIADSSamSite:goDark()
	if self.aiState == true then
		local sam = self.samSite
		local cont = sam:getController()
		-- we will turn off AI for all SAM Sites added to the IADS, Skynet decides when a site will go online.
		cont:setOnOff(false)
		self.aiState = false
		trigger.action.outText("still in rannge:"..#self.targetsInRange, 1)
		trigger.action.outText(self:getDescription().." going dark", 1)
	end
end

function SkynetIADSSamSite:getDescription()
	return "SAM Group: "..self.samSite:getName().." Type : "..self:getDBName(true)
end

function SkynetIADSSamSite:addPowerSource(powerSource)
	table.insert(self.powerSources, powerSource)
end

function SkynetIADSSamSite:addConnectionNode(connectionNode)
	table.insert(self.connectionNodes, connectionNode)
end

function SkynetIADSSamSite:hasActiveConnectionNode()
	return SkynetIADS.genericCheckOneObjectIsAlive(self.connectionNodes)
end

function SkynetIADSSamSite:hasWorkingPowerSource()
	return SkynetIADS.genericCheckOneObjectIsAlive(self.powerSources)
end

function SkynetIADSSamSite:getDBName(natoName)
	return SkynetIADS.getDBName(self.samSite, natoName)
end

function SkynetIADSSamSite:goAutonomous()
	self.isAutonomous = true
	if self.autonomousMode == SkynetIADSSamSite.AUTONOMOUS_STATE_DARK then
		self:goDark()
		trigger.action.outText(self:getDescription().." is Autonomous: dark", 1)

	else
		self:goLive()
		trigger.action.outText(self:getDescription().." is Autonomous: DCS AI", 1)
	end
	return
end

function SkynetIADSSamSite:setAutonomousMode(mode)
	self.autonomousMode = mode
end

function SkynetIADSSamSite:goLive()
	if self.aiState == false then
		local  cont = self.samSite:getController()
		cont:setOnOff(true)
		cont:setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.RED)	
		cont:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_FREE)
		---cont:knowTarget(ewrTarget, true, true) check to see if this will help for a faster shot of the SAM
		self.aiState = true
		trigger.action.outText(self:getDescription().." going live", 1)
	end
end

function SkynetIADSSamSite:handOff(aircraft)
	-- if the sam has no power, it won't do anything
	if self:hasWorkingPowerSource() == false then
		self:goDark()
		trigger.action.outText(self:getDescription().." has no Power", 1)
		return
	end
	if self:isTargetInRange(aircraft) then
		self.targetsInRange[aircraft:getName()] = aircraft
		if self.aiState == false then
			self:goLive()
		end
	else
	--	table.remove(self.targetsInRange, aircraft)
		self:goDark()
	end
end

function SkynetIADSSamSite:isTargetInRange(target)
	local samSiteUnits = self.samSite:getUnits()
	local samRadarInRange = false
	local samLauncherinRange = false
	--go through sam site units to check launcher and radar distance, they could be positined quite far apart, only activate if both are in reach
	for j = 1, #samSiteUnits do
		local  samElement = samSiteUnits[j]
		local typeName = samElement:getTypeName()	
		--trigger.action.outText("type name: "..typeName, 1)
		local radarData = SkynetIADS.database[self:getDBName()]['searchRadar'][typeName]
		local launcherData = SkynetIADS.database[self:getDBName()]['launchers'][typeName]
		local trackingData = nil
		if radarData == nil then
			--to decide if we should activate the sam we use the tracking radar range if it exists
			trackingData = SkynetIADS.database[self:getDBName()]['trackingRadar']
			if trackingData ~= nil then
				radarData = trackingData[typeName]
			end
		end
		--if we find a radar in a SAM site, we calculate to see if it is within tracking parameters
		if radarData ~= nil then
			if self:isRadarWithinTrackingParameters(target, samElement, radarData) then
				samRadarInRange = true
			end
		end
		--if we find a launcher in a SAM site, we calculate to see if it is within firing parameters
		if launcherData ~= nil then
			if self:isLauncherWithinFiringParameters(target, samElement, launcherData) then
				samLauncherinRange = true
			end
		end		
	end	
	-- we only need to find one radar and one launcher within range in a Group, the AI of DCS will then decide which launcher will fire
	return ( samRadarInRange and samLauncherinRange )
end

function SkynetIADSSamSite:isLauncherWithinFiringParameters(aircraft, samLauncherUnit, launcherData)
	local isInRange = false
	local distance = mist.utils.get2DDist(aircraft:getPosition().p, samLauncherUnit:getPosition().p)
	local maxFiringRange = launcherData['range']
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
	if altitudeDifference <= maxDetectionAltitude and distance <= maxDetectionRange then
		--trigger.action.outText(aircraft:getTypeName().." in range of:"..samRadarUnit:getTypeName(),1)
		isInRange = true
	end
	return isInRange
end

end