do
SkynetIADSCommandCenter = {}
SkynetIADSCommandCenter.__index = SkynetIADSCommandCenter

function SkynetIADSCommandCenter:create(commandCenter)
	local comCenter = {}
	setmetatable(comCenter, SkynetIADSCommandCenter)
	comCenter.commandCenter = commandCenter
	comCenter.powerSources = {}
	return comCenter
end

function SkynetIADSCommandCenter:addPowerSource(powerSource)
	table.insert(self.powerSources, powerSource)
end

function SkynetIADSCommandCenter:hasWorkingPowerSource()
	return SkynetIADS.genericCheckOneObjectIsAlive(self.powerSources)
end

function SkynetIADSCommandCenter:getLife()
	return self.commandCenter:getLife()
end

end