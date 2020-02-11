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

function SkynetIADSJammer:musicOn()
	self.jammerTaskID = mist.scheduleFunction(SkynetIADSJammer.runCycle, {self}, 1, 5)
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
			local distance = mist.utils.get2DDist(self.emitter:getPosition().p, samSite:getRadarUnits()[1]:getPosition().p)
			--trigger.action.outText("Distance: "..distance, 1)
			--TODO: add line of sight check
			-- I try to emulate the system as it would work in real life, so a jammer can only jam a SAM site that is active
			if	samSite:isActive() then
				samSite:jam(distance)
			end
		end
	end
--	trigger.action.outText("jam cycle",1)
end

function SkynetIADSJammer:musicOff()

end

end
