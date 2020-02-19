do
SkynetIADSCommandCenter = {}
SkynetIADSCommandCenter = inheritsFrom(SkynetIADSAbstractElement)

function SkynetIADSCommandCenter:create(commandCenter)
	local comCenter = self:superClass():create()
	setmetatable(comCenter, self)
	self.__index = self
	comCenter.commandCenter = commandCenter
	return comCenter
end

function SkynetIADSCommandCenter:getLife()
	return self.commandCenter:getLife()
end

end