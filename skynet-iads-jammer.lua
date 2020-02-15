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

function SkynetIADSJammer:getParameters(radar)
	local testParams = {}
	testParams = {[40]=100, [20] = 90, [10] = 80, }
end

function SkynetIADSJammer:wakeUp()
	self.jammerTaskID = mist.scheduleFunction(SkynetIADSJammer.runCycle, {self}, 1, 1)
end

function SkynetIADSJammer:addIADS(iads)
	table.insert(self.iads, iads)
end

--TODO: add types of radars the jammer can jam
function SkynetIADSJammer.runCycle(self)
	
	for i = 1, #self.iads do
		local iads = self.iads[i]
		local samSites = iads:getSamSites()	
		for j = 1, #samSites do
			local samSite = samSites[j]
			local radar = samSite:getRadarUnits()[1]
			local distance = mist.utils.get2DDist(self.emitter:getPosition().p, radar:getPosition().p)
		--	trigger.action.outText("Distance: "..distance, 1)
			-- I try to emulate the system as it would work in real life, so a jammer can only jam a SAM site it has los to is active
			if	self:hasLineOfSightToRadar(radar) and samSite:isActive() then
				samSite:jam(distance)
			end
		end
	end
--	trigger.action.outText("jam cycle",1)
end

function SkynetIADSJammer:hasLineOfSightToRadar(radar)
	return land.isVisible(self.emitter:getPosition().p, radar:getPosition().p) 
end

function SkynetIADSJammer:turnOff()

end

end
