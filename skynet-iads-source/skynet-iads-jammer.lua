do

SkynetIADSJammer = {}
SkynetIADSJammer.__index = SkynetIADSJammer

function SkynetIADSJammer:create(emitter)
	local jammer = {}
	setmetatable(jammer, SkynetIADSJammer)
	jammer.emitter = emitter
	jammer.jammerTaskID = nill
	jammer.iads = {}
	return jammer
end

function SkynetIADSJammer:masterArmOn()
	self:masterArmSafe()
	self.jammerTaskID = mist.scheduleFunction(SkynetIADSJammer.runCycle, {self}, 1, 1)
end

function SkynetIADSJammer:addIADS(iads)
	table.insert(self.iads, iads)
end

function SkynetIADSJammer:getSuccessProbability(distanceNauticalMiles, natoName)
	local probability = 0
	
	if natoName == 'SA-2' then
		probability = ( 1.4 ^ distanceNauticalMiles ) + 90
	elseif natoName == 'SA-3' then
		probability = ( 1.4 ^ distanceNauticalMiles ) + 80
	elseif natoName == 'SA-6' then
		probability = ( 1.4 ^ distanceNauticalMiles ) + 23
	elseif natoName == 'SA-10' then
		probability =  ( 1.07 ^ (distanceNauticalMiles / 1.13) ) + 5
	elseif natoName == 'SA-11' then
		probability = ( 1.25 ^ distanceNauticalMiles ) + 15
	elseif natoName == 'SA-15' then
		probability = ( 1.15 ^ distanceNauticalMiles ) + 5
	end
	return probability
end

--TODO: add types of radars the jammer can jam
function SkynetIADSJammer.runCycle(self)
	for i = 1, #self.iads do
		local iads = self.iads[i]
		local samSites = iads:getSamSites()	
		for j = 1, #samSites do
			local samSite = samSites[j]
			local radars = samSite:getRadarUnits()
			local hasLOS = false
			local distance = 0
			for l = 1, #radars do
				local radar = radars[l]
				distance = mist.utils.metersToNM(mist.utils.get2DDist(self.emitter:getPosition().p, radar:getPosition().p))
				-- I try to emulate the system as it would work in real life, so a jammer can only jam a SAM site if has line of sight to at least one radar in the group
				if self:hasLineOfSightToRadar(radar) then
					hasLOS = true
				end
			end
			if samSite:isActive() then	
				trigger.action.outText("Distance: "..distance, 2)
				trigger.action.outText("Jammer Probability: "..self:getSuccessProbability(distance, samSite:getNatoName()), 2)
				samSite:jam(self:getSuccessProbability(distance, samSite:getNatoName()))
			end
		end
	end
--	trigger.action.outText("jam cycle",1)
end

function SkynetIADSJammer:hasLineOfSightToRadar(radar)
	local radarPos = radar:getPosition().p
	--lift the radar 3 meters off the ground, some 3d models are dug in to the ground, creating issues in calculating LOS
	radarPos.y = radarPos.y + 3
	return land.isVisible(radarPos, self.emitter:getPosition().p) 
end

function SkynetIADSJammer:masterArmSafe()
	mist.removeFunction(self.jammerTaskID)
end

end
