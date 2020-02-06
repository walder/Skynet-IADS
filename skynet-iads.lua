do


-- TODO: code HARM defencce, check if SAM Site or EW sees HARM, only then start defence
-- TODO: IADS Power Source optional for each EW Radar or SAM Site, if destroyed element goes offline
-- TODO: add Command Center, if destroyed IADS is balkanised, SAM Sites will operate idependently
-- TODO: IADS Connection Node, between SAM Site and Command center, if destroyed SAM Site will have to work idependently
-- TODO: Jamming, Electronic Warfare: add multiple planes via script around the Jamming Group, get SAM to target those


SkynetIADS = {}
SkynetIADS.__index = SkynetIADS

function SkynetIADS:create()
	local iads = {}
	setmetatable(iads, SkynetIADS)
	self.earlyWarningRadars = {}
	self.samSites = {}
	self.ewRadarScanMistTaskID = nil
	return iads
end

function SkynetIADS:addEarlyWarningRadar(earlyWarningRadar)
	table.insert(self.earlyWarningRadars, earlyWarningRadar)
end

function SkynetIADS:getDBSamName(samGroup)
	local samDBName = ""
	local firstElement = samGroup:getUnits()[1]
	local typeName = firstElement:getTypeName()
	local index = typeName:find(" ") - 1
	local samNameSearch = typeName:sub(1, index)
	for samName, samData in pairs(samTypesDB) do
		local prefix = samName:sub(1, index)
		if samNameSearch == prefix then
			samDBName = samName
			break
		end
	end
	--trigger.action.outText(samDBName, 10)
	return samDBName
end

function SkynetIADS:onEvent(event)
	if event.id == world.event.S_EVENT_SHOT then
		local weapon = event.weapon
		targetOfMissile = weapon:getTarget()
		if targetOfMissile ~= nil and SkynetIADS.isWeaponHarm(weapon) then
			self:startHarmDefence(weapon)
		end	
	end

end

function SkynetIADS.isWeaponHarm(weapon)
	local desc = weapon:getDesc()
	return (desc.missileCategory == 6 and desc.guidance == 5)	
end

function SkynetIADS:addSamSite(samSite)
	-- we will turn off AI for all SAM Sites added to the IADS, Skynet decides when a site will go online.
	cont = samSite:getController()
	cont:setOnOff(false)
	local samDBName = self:getDBSamName(samSite)
	local samEntry = {}
	---trigger.action.outText("DB Name: "..samDBName, 10)
	samEntry.name = samDBName
	samEntry.samSite = samSite
	samEntry.ai = false
	table.insert(self.samSites, samEntry)
end

--TODO: distinguish between friendly and enemy aircraft, eg only activate SAM site if enemy aircraft is aproaching
function SkynetIADS.evaluateContacts(self) 
	--trigger.action.outText("Active EW Radars: "..#self.earlyWarningRadars, 1)
	for i = 1, #self.earlyWarningRadars do
		local ewRadar = self.earlyWarningRadars[i]
		local ewRadarController = ewRadar:getController()
		local ewContacts = ewRadarController:getDetectedTargets()
		--TODO: it would be more efficient to store all contacts in a table first and then correlate with the sams, it could be that a target is beeing tracked by two overlapping ew radars, in this case both would trigger a correlation check
		if #ewContacts > 0 then
			for j = 1, #ewContacts do
				local detectedObject = ewContacts[j].object
				--local objectCategory = detectedObject:getCategory()
			--	trigger.action.outText("target category: "..objectCategory, 1)
				--if objectCategory == 1 then
					trigger.action.outText("EWR has detected: "..detectedObject:getTypeName(), 1)
					--TODO: shall we hand of any type of flying object to SAM, eg harms, bombs, and aircraft or only aircraft?
					self:correlateWithSamSites(detectedObject)
				--end
			end
		end		
	end
end

function SkynetIADS:startHarmDefence(inBoundHarm)
	--TODO: store ID of task so it can be stopped when sam or harm is destroyed
	mist.scheduleFunction(SkynetIADS.harmDefence, {self, inBoundHarm}, 1, 1)	
end

function SkynetIADS.harmDefence(self, inBoundHarm) 
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

-- checks to see if SAM Site can attack the tracked aircraft
-- TODO: extrapolate flight path to get SAM to active so that it can fire as aircraft aproaches max range
function SkynetIADS:correlateWithSamSites(detectedAircraft)
	for i = 1, #self.samSites do
		local samSiteEntry = self.samSites[i]
		local samType = samSiteEntry.name
		local samSite = samSiteEntry.samSite
		local aiState = samSiteEntry.ai
		local samSiteUnits = samSite:getUnits()
		local samRadarInRange = false
		local samLauncherinRange = false
		local  cont = samSite:getController()
		--go through sam site units to check launcher and radar distance, they could be positined quite far apart, only activate if both are in reach
		for j = 1, #samSiteUnits do
			local  samElement = samSiteUnits[j]
			local typeName = samElement:getTypeName()	
		--	trigger.action.outText(typeName, 1)
		--trigger.action.outText(samType, 1)
			-- TODO: check search radar and tracking radar, some sam sites have both!
			local radarData = samTypesDB[samType]['searchRadar'][typeName]
			local launcherData = samTypesDB[samType]['launchers'][typeName]
			--if we find a radar in a SAM site, we calculate to see if it is within tracking parameters
			if radarData ~= nil then
				if self:isSamRadarWithinTrackingParameters(detectedAircraft, samElement, radarData) then
					samRadarInRange = true
				end
			end
			--if we find a launcher in a SAM site, we calculate to see if it is within firing parameters
			if launcherData ~= nil then
				if self:isSamLauncherWithinFiringParameters(detectedAircraft, samElement, launcherData) then
					samLauncherinRange = true
				end
			end			
		end
		-- we only need to find one radar and one launcher within range in a Group, the AI of DCS will then decide which launcher will fire
		if samRadarInRange and samLauncherinRange then
			if samSiteEntry.ai == false then
				trigger.action.outText(samSite:getName().." activated", 1)
				cont:setOnOff(true)
				cont:setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.RED)	
				cont:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_FREE)
				---cont:knowTarget(ewrTarget, true, true) check to see if this will help for a faster shot of the SAM
				samSiteEntry.ai = true
			end
		else
			if samSiteEntry.ai then
				trigger.action.outText(samSite:getName().." deactivated", 1)
				cont:setOnOff(false)
				samSiteEntry.ai = false
			end
		end
	end
end

function SkynetIADS:isSamLauncherWithinFiringParameters(aircraft, samLauncherUnit, launcherData)
	local isInRange = false
	local distance = mist.utils.get2DDist(aircraft:getPosition().p, samLauncherUnit:getPosition().p)
	local maxFiringRange = launcherData['range']
	if distance <= maxFiringRange then
		isInRange = true
		trigger.action.outText(aircraft:getTypeName().." in range of:"..samLauncherUnit:getTypeName(),1)
	end
	return isInRange
end

function SkynetIADS:isSamRadarWithinTrackingParameters(aircraft, samRadarUnit, radarData)
	local isInRange = false
	local distance = mist.utils.get2DDist(aircraft:getPosition().p, samRadarUnit:getPosition().p)
	local radarHeight = samRadarUnit:getPosition().p.y
	local aircraftHeight = aircraft:getPosition().p.y	
	local altitudeDifference = math.abs(aircraftHeight - radarHeight)
	local maxDetectionAltitude = radarData['max_alt_finding_target']
	local maxDetectionRange = radarData['max_range_finding_target']		
	if altitudeDifference <= maxDetectionAltitude and distance <= maxDetectionRange then
		trigger.action.outText(aircraft:getTypeName().." in range of:"..samRadarUnit:getTypeName(),1)
		isInRange = true
	end
	return isInRange
end

-- will start going through the Early Warning Radars to check what targets they have detected
function SkynetIADS:activate()
	if self.ewRadarScanMistTaskID ~= nil then
		mist.removeFunction(self.ewRadarScanMistTaskID)
	end
	self.ewRadarScanMistTaskID = mist.scheduleFunction(SkynetIADS.evaluateContacts, {self}, 1, 1)
	world.addEventHandler(self)
end


function createFalseTarget()
--[[
	local an30m = { 
                                ["units"] = 
                                {
                                    [1] = 
                                    {
                                        ["alt"] = 4800,
                                        ["hardpoint_racks"] = true,
                                        ["alt_type"] = "BARO",
                                        ["livery_id"] = "VFA-37",
                                        ["skill"] = "Excellent",
                                        ["speed"] = 179.86111111111,
                                        ["AddPropAircraft"] = 
                                        {
                                            ["OuterBoard"] = 0,
                                            ["InnerBoard"] = 0,
                                        }, -- end of ["AddPropAircraft"]
                                        ["type"] = "FA-18C_hornet",
                                        ["Radio"] = 
                                        {
                                            [1] = 
                                            {
                                                ["modulations"] = 
                                                {
                                                    [1] = 0,
                                                    [2] = 0,
                                                    [4] = 0,
                                                    [8] = 0,
                                                    [16] = 0,
                                                    [17] = 0,
                                                    [9] = 0,
                                                    [18] = 0,
                                                    [5] = 0,
                                                    [10] = 0,
                                                    [20] = 0,
                                                    [11] = 0,
                                                    [3] = 0,
                                                    [6] = 0,
                                                    [12] = 0,
                                                    [13] = 0,
                                                    [7] = 0,
                                                    [14] = 0,
                                                    [19] = 0,
                                                    [15] = 0,
                                                }, -- end of ["modulations"]
                                                ["channels"] = 
                                                {
                                                    [1] = 305,
                                                    [2] = 264,
                                                    [4] = 256,
                                                    [8] = 257,
                                                    [16] = 261,
                                                    [17] = 267,
                                                    [9] = 255,
                                                    [18] = 251,
                                                    [5] = 254,
                                                    [10] = 262,
                                                    [20] = 266,
                                                    [11] = 259,
                                                    [3] = 265,
                                                    [6] = 250,
                                                    [12] = 268,
                                                    [13] = 269,
                                                    [7] = 270,
                                                    [14] = 260,
                                                    [19] = 253,
                                                    [15] = 263,
                                                }, -- end of ["channels"]
                                            }, -- end of [1]
                                            [2] = 
                                            {
                                                ["modulations"] = 
                                                {
                                                    [1] = 0,
                                                    [2] = 0,
                                                    [4] = 0,
                                                    [8] = 0,
                                                    [16] = 0,
                                                    [17] = 0,
                                                    [9] = 0,
                                                    [18] = 0,
                                                    [5] = 0,
                                                    [10] = 0,
                                                    [20] = 0,
                                                    [11] = 0,
                                                    [3] = 0,
                                                    [6] = 0,
                                                    [12] = 0,
                                                    [13] = 0,
                                                    [7] = 0,
                                                    [14] = 0,
                                                    [19] = 0,
                                                    [15] = 0,
                                                }, -- end of ["modulations"]
                                                ["channels"] = 
                                                {
                                                    [1] = 305,
                                                    [2] = 264,
                                                    [4] = 256,
                                                    [8] = 257,
                                                    [16] = 261,
                                                    [17] = 267,
                                                    [9] = 255,
                                                    [18] = 251,
                                                    [5] = 254,
                                                    [10] = 262,
                                                    [20] = 266,
                                                    [11] = 259,
                                                    [3] = 265,
                                                    [6] = 250,
                                                    [12] = 268,
                                                    [13] = 269,
                                                    [7] = 270,
                                                    [14] = 260,
                                                    [19] = 253,
                                                    [15] = 263,
                                                }, -- end of ["channels"]
                                            }, -- end of [2]
                                        }, -- end of ["Radio"]
                                        ["unitId"] = 2,
                                        ["psi"] = 0.012914190422554,
                                        ["y"] = -55258.964143426,
                                        ["x"] = -339019.92867398,
                                        ["name"] = "DictKey_UnitName_7-0",
                                        ["payload"] = 
                                        {
                                            ["pylons"] = 
                                            {
                                                [1] = 
                                                {
                                                    ["CLSID"] = "{6CEB49FC-DED8-4DED-B053-E1F033FF72D3}",
                                                }, -- end of [1]
                                                [2] = 
                                                {
                                                    ["CLSID"] = "<CLEAN>",
                                                }, -- end of [2]
                                                [3] = 
                                                {
                                                    ["CLSID"] = "{B06DD79A-F21E-4EB9-BD9D-AB3844618C93}",
                                                }, -- end of [3]
                                                [5] = 
                                                {
                                                    ["CLSID"] = "{FPU_8A_FUEL_TANK}",
                                                }, -- end of [5]
                                                [7] = 
                                                {
                                                    ["CLSID"] = "{B06DD79A-F21E-4EB9-BD9D-AB3844618C93}",
                                                }, -- end of [7]
                                                [8] = 
                                                {
                                                    ["CLSID"] = "<CLEAN>",
                                                }, -- end of [8]
                                                [9] = 
                                                {
                                                    ["CLSID"] = "{6CEB49FC-DED8-4DED-B053-E1F033FF72D3}",
                                                }, -- end of [9]
                                            }, -- end of ["pylons"]
                                            ["fuel"] = 4900,
                                            ["flare"] = 30,
                                            ["ammo_type"] = 1,
                                            ["chaff"] = 60,
                                            ["gun"] = 100,
                                        }, -- end of ["payload"]
                                        ["heading"] = -0.012914190422554,
                                        ["callsign"] = 
                                        {
                                            [1] = 1,
                                            [2] = 1,
                                            [3] = 1,
                                            ["name"] = "Enfield11",
                                        }, -- end of ["callsign"]
                                        ["onboard_num"] = "010",
                                    }, -- end of [1]
                                }, -- end of ["units"]
                                ["y"] = -55258.964143426,
                                ["x"] = -339019.92867398,
                                ["name"] = "DictKey_GroupName_6",
                                ["communication"] = true,
                                ["start_time"] = 0,
                                ["frequency"] = 305,
								 ["tasks"] = 
                                {
                                }, -- end of ["tasks"]

	} 	
	coalition.addGroup(country.id.USA,1, an30m) 
--]]	
end

end