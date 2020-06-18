do

SkynetIADSJammer = {}
SkynetIADSJammer.__index = SkynetIADSJammer

function SkynetIADSJammer:create(emitter, iads)
	local jammer = {}
	setmetatable(jammer, SkynetIADSJammer)
	jammer.radioMenu = nil
	jammer.emitter = emitter
	jammer.jammerTaskID = nil
	jammer.iads = {iads}
	jammer.maximumEffectiveDistanceNM = 200
	--jammer probability settings are stored here, visualisation, see: https://docs.google.com/spreadsheets/d/16rnaU49ZpOczPEsdGJ6nfD0SLPxYLEYKmmo4i2Vfoe0/edit#gid=0
	jammer.jammerTable = {
		['SA-2'] = {
			['function'] = function(distanceNauticalMiles) return ( 1.4 ^ distanceNauticalMiles ) + 90 end,
			['canjam'] = true,
		},
		['SA-3'] = {
			['function'] = function(distanceNauticalMiles) return ( 1.4 ^ distanceNauticalMiles ) + 80 end,
			['canjam'] = true,
		},
		['SA-6'] = {
			['function'] = function(distanceNauticalMiles) return ( 1.4 ^ distanceNauticalMiles ) + 23 end,
			['canjam'] = true,
		},
		['SA-8'] = {
			['function'] = function(distanceNauticalMiles) return ( 1.35 ^ distanceNauticalMiles ) + 30 end,
			['canjam'] = true,
		},
		['SA-10'] = {
			['function'] = function(distanceNauticalMiles) return ( 1.07 ^ (distanceNauticalMiles / 1.13) ) + 5 end,
			['canjam'] = true,
		},
		['SA-11'] = {
			['function'] = function(distanceNauticalMiles) return ( 1.25 ^ distanceNauticalMiles ) + 15 end,
			['canjam'] = true,
		},
		['SA-15'] = {
			['function'] = function(distanceNauticalMiles) return ( 1.15 ^ distanceNauticalMiles ) + 5 end,
			['canjam'] = true,
		},
	}
	return jammer
end

function SkynetIADSJammer:masterArmOn()
	self:masterArmSafe()
	self.jammerTaskID = mist.scheduleFunction(SkynetIADSJammer.runCycle, {self}, 1, 10)
end

function SkynetIADSJammer:addFunction(natoName, jammerFunction)
	self.jammerTable[natoName] = {
		['function'] = jammerFunction,
		['canjam'] = true
	}
end

function SkynetIADSJammer:setMaximumEffectiveDistance(distance)
	self.maximumEffectiveDistanceNM = distance
end

function SkynetIADSJammer:disableFor(natoName)
	self.jammerTable[natoName]['canjam'] = false
end

function SkynetIADSJammer:isKnownRadarEmitter(natoName)
	local isActive = false
	for unitName, unit in pairs(self.jammerTable) do
		if unitName == natoName and unit['canjam'] == true then
			isActive = true
		end
	end
	return isActive
end

function SkynetIADSJammer:addIADS(iads)
	table.insert(self.iads, iads)
end

function SkynetIADSJammer:getSuccessProbability(distanceNauticalMiles, natoName)
	local probability = 0
	local jammerSettings = self.jammerTable[natoName]
	if jammerSettings ~= nil then
		probability = jammerSettings['function'](distanceNauticalMiles)
	end
	return probability
end

function SkynetIADSJammer:getDistanceNMToRadarUnit(radarUnit)
	return mist.utils.metersToNM(mist.utils.get3DDist(self.emitter:getPosition().p, radarUnit:getPosition().p))
end

function SkynetIADSJammer.runCycle(self)

	if self.emitter:isExist() == false then
		self:masterArmSafe()
		return
	end

	for i = 1, #self.iads do
		local iads = self.iads[i]
		local samSites = iads:getActiveSAMSites()	
		for j = 1, #samSites do
			local samSite = samSites[j]
			local radars = samSite:getRadars()
			local hasLOS = false
			local distance = 0
			local natoName = samSite:getNatoName()
			for l = 1, #radars do
				local radar = radars[l]
				distance = self:getDistanceNMToRadarUnit(radar)
				-- I try to emulate the system as it would work in real life, so a jammer can only jam a SAM site if has line of sight to at least one radar in the group
				if self:isKnownRadarEmitter(natoName) and self:hasLineOfSightToRadar(radar) and distance <= self.maximumEffectiveDistanceNM then
					if iads:getDebugSettings().jammerProbability then
						iads:printOutput("JAMMER: Distance: "..distance)
					end
					samSite:jam(self:getSuccessProbability(distance, natoName))
				end
			end
		end
	end
end

function SkynetIADSJammer:hasLineOfSightToRadar(radar)
	local radarPos = radar:getPosition().p
	--lift the radar 30 meters off the ground, some 3d models are dug in to the ground, creating issues in calculating LOS
	radarPos.y = radarPos.y + 30
	return land.isVisible(radarPos, self.emitter:getPosition().p) 
end

function SkynetIADSJammer:masterArmSafe()
	mist.removeFunction(self.jammerTaskID)
end

--TODO: Remove Menu when emitter dies:
function SkynetIADSJammer:addRadioMenu()
	self.radioMenu = missionCommands.addSubMenu('Jammer: '..self.emitter:getName())
	missionCommands.addCommand('Master Arm On', self.radioMenu, SkynetIADSJammer.updateMasterArm, {self = self, option = 'masterArmOn'})
	missionCommands.addCommand('Master Arm Safe', self.radioMenu, SkynetIADSJammer.updateMasterArm, {self = self, option = 'masterArmSafe'})
end

function SkynetIADSJammer.updateMasterArm(params)
	local option = params.option
	local self = params.self
	if option == 'masterArmOn' then
		self:masterArmOn()
	elseif option == 'masterArmSafe' then
		self:masterArmSafe()
	end
end

function SkynetIADSJammer:removeRadioMenu()
	missionCommands.removeItem(self.radioMenu)
end

end
