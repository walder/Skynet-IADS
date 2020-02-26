do
SkynetIADSCommandCenter = {}
SkynetIADSCommandCenter = inheritsFrom(SkynetIADSAbstractElement)

function SkynetIADSCommandCenter:create(commandCenter, iads)
	local comCenter = self:superClass():create(commandCenter, iads)
	setmetatable(comCenter, self)
	self.__index = self
	return comCenter
end

end
