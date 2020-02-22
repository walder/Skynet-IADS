do
SkynetIADSCommandCenter = {}
SkynetIADSCommandCenter = inheritsFrom(SkynetIADSAbstractElement)

function SkynetIADSCommandCenter:create(commandCenter, iads)
	local comCenter = self:superClass():create(iads)
	setmetatable(comCenter, self)
	self.__index = self
	comCenter:setDCSRepresentation(commandCenter)
	return comCenter
end

end
