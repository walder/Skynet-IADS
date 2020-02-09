do

-- To test: different kinds of Sam types, damage to power source, command center, connection nodes
-- TODO: Command centers should be able to have a power source, if it is dammaged IADS will no longer work
-- TODO: remove contact in sam site if its out of range, it could be a IADS stops working while a SAM site is tracking a target --> or does this not matter due to DCS AI?
-- TODO: merge SAM contacts with the ones it gets from the IADS, it could be that the SAM Sees something the IADS does not know about, later on add this data to back to the IADS
-- TODO: code HARM defencce, check if SAM Site or EW sees HARM, only then start defence
-- TODO: Jamming, Electronic Warfare: add multiple planes via script around the Jamming Group, get SAM to target those


SkynetIADS = {}
SkynetIADS.__index = SkynetIADS

SkynetIADS.database = samTypesDB

function SkynetIADS:create()
	local iads = {}
	setmetatable(iads, SkynetIADS)
	iads.earlyWarningRadars = {}
	iads.samSites = {}
	iads.commandCenters = {}
	iads.ewRadarScanMistTaskID = nil
	return iads
end

function SkynetIADS.getDBName(samGroup, natoName)
	local units = samGroup:getUnits()
	local samDBName = "UNKNOWN"
	local unitData = nil
	local typeName = nil
	for i = 1, #units do
		typeName = units[i]:getTypeName()
		for samName, samData in pairs(SkynetIADS.database) do
			--all Sites have a unique launcher, if we find one, we got the internal designator of the SAM unit
			unitData = SkynetIADS.database[samName]
			if unitData['launchers'] and unitData['launchers'][typeName] then
			--	trigger.action.outText("Element is a: "..samName, 1)
				if natoName then
					return SkynetIADS.database[samName]['name']['NATO']
				else
					return samName
				end	
			else
				--trigger.action.outText("no launcher data: "..typeName, 1)
			end
		end
	end
	return samDBName
end

function SkynetIADS:printSystemStatus()
	local ewNoPower = 0
	local ewTotal = #self.earlyWarningRadars
	local ewNoConnectionNode = 0
	
	local numCommandCenters = #self.commandCenters
	local activeCommandCenters = 0
	
	for i = 1, #self.commandCenters do
		local commandCenter = self.commandCenters[i]
		if commandCenter:getLife() > 0 then
			activeCommandCenters = activeCommandCenters + 1
		end
	end
	trigger.action.outText("COMMAND CENTERS: "..numCommandCenters.." | Active: "..activeCommandCenters, 1)
	
	for i = 1, #self.earlyWarningRadars do
		local ewRadar = self.earlyWarningRadars[i]
		if ewRadar:hasWorkingPowerSource() == false then
			ewNoPower = ewNoPower + 1
		end
		if ewRadar:hasActiveConnectionNode() == false then
			ewNoConnectionNode = ewNoConnectionNode + 1
		end
	end
	trigger.action.outText("EW SITES: "..ewTotal.." | Active: "..ewTotal.." | Inactive: 0| No Power: "..ewNoPower.." | No Connection: "..ewNoConnectionNode, 1)
	
	local samSitesInactive = 0
	local samSitesActive = 0
	local samSitesTotal = #self.samSites
	local samSitesNoPower = 0
	local samSitesNoConnectionNode = 0
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
	end
	samSitesInactive = samSitesTotal - samSitesActive
	trigger.action.outText("SAM SITES: "..samSitesTotal.." | Active: "..samSitesActive.." | Inactive: "..samSitesInactive.." | No Power: "..samSitesNoPower.." | No Connection: "..samSitesNoConnectionNode, 1)
end

function SkynetIADS:addEarlyWarningRadar(earlyWarningRadarUnit, powerSource, connectionNode)
	local ewRadar = SkynetIADSEWRadar:create(earlyWarningRadarUnit)
	ewRadar:addPowerSource(powerSource)
	ewRadar:addConnectionNode(connectionNode)
	table.insert(self.earlyWarningRadars, ewRadar)
end

function SkynetIADS.isWeaponHarm(weapon)
	local desc = weapon:getDesc()
	return (desc.missileCategory == 6 and desc.guidance == 5)	
end

function SkynetIADS:addSamSite(samSite, powerSource, connectionNode, autonomousMode)
	local samSite = SkynetIADSSamSite:create(samSite)
	samSite:addPowerSource(powerSource)
	samSite:addConnectionNode(connectionNode)
	samSite:setAutonomousMode(autonomousMode)
	table.insert(self.samSites, samSite)
end

function SkynetIADS:addCommandCenter(commandCenter)
	table.insert(self.commandCenters, commandCenter)
end

-- generic function to theck if powerplants, command centers, connection nodes are still alive
function SkynetIADS.genericCheckOneObjectIsAlive(objects)
	local isAlive = (#objects == 0)
	for i = 1, #objects do
		local object = objects[i]
	--	trigger.action.outText("life: "..object:getLife(), 1)
		--if we find one object that is not fully destroyed we assume the IADS is still working
		if object:getLife() > 0 then
			isAlive = true
			break
		end
	end
	return isAlive
end

function SkynetIADS:isCommandCenterAlive() 
	return SkynetIADS.genericCheckOneObjectIsAlive(self.commandCenters)
end

function SkynetIADS:setSamSitesToAutonomousMode()
	for i= 1, #self.samSites do
		samSite = self.samSites[i]
		samSite:goAutonomous()
	end
end

--TODO: distinguish between friendly and enemy aircraft, eg only activate SAM site if enemy aircraft is aproaching
function SkynetIADS.evaluateContacts(self) 
	local iadsContacts = {}
	if self:isCommandCenterAlive() == false then
		trigger.action.outText("There is no working Command Center for the IADS", 1)
		self:setSamSitesToAutonomousMode()
		return
	end
	for i = 1, #self.earlyWarningRadars do
		local ewRadar = self.earlyWarningRadars[i]
		if ewRadar:hasActiveConnectionNode() == true then
			local ewContacts = ewRadar:getDetectedTargets()
			for j = 1, #ewContacts do
				--trigger.action.outText(ewContacts[j]:getName(), 1)
				iadsContacts[ewContacts[j]:getName()] = ewContacts[j]
				--trigger.action.outText(ewRadar:getDescription().." has detected: "..ewContacts[j]:getName(), 1)	
			end
		else
			trigger.action.outText(ewRadar:getDescription().." no connection to command center", 1)
		end
	end
	for unitName, unit in pairs(iadsContacts) do
		trigger.action.outText("IADS Contact: "..unitName, 1)
		---Todo: currently every type of object in the air is handed of to the sam site, including bombs and missiles, shall these be removed?
		self:correlateWithSamSites(unit)
	end
	self:printSystemStatus()
end

function SkynetIADS:startHarmDefence(inBoundHarm)
	--TODO: store ID of task so it can be stopped when sam or harm is destroyed
	mist.scheduleFunction(SkynetIADS.harmDefence, {self, inBoundHarm}, 1, 1)	
end

function SkynetIADS:correlateWithSamSites(detectedAircraft)
	for i= 1, #self.samSites do
		local samSite = self.samSites[i]
		if samSite:hasActiveConnectionNode() == true then
			samSite:handOff(detectedAircraft)
		else
			samSite:goAutonomous()
			trigger.action.outText(samSite:getDescription().." no connection Command center", 1)
		end
	end
end

-- will start going through the Early Warning Radars to check what targets they have detected
function SkynetIADS:activate()
	if self.ewRadarScanMistTaskID ~= nil then
		mist.removeFunction(self.ewRadarScanMistTaskID)
	end
	self.ewRadarScanMistTaskID = mist.scheduleFunction(SkynetIADS.evaluateContacts, {self}, 1, 5)
end

-- checks to see if SAM Site can attack the tracked aircraft
-- TODO: extrapolate flight path to get SAM to active so that it can fire as aircraft aproaches max range

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