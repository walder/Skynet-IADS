do
SkynetIADSCommandCenter = {}
SkynetIADSCommandCenter = inheritsFrom(SkynetIADSAbstractElement)

function SkynetIADSCommandCenter:create(commandCenter)
	local comCenter = self:superClass():create()
	setmetatable(comCenter, self)
	self.__index = self
	comCenter:setDCSRepresentation(commandCenter)
	return comCenter
end

end