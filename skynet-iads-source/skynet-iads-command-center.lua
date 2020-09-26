do
SkynetIADSCommandCenter = {}
SkynetIADSCommandCenter = inheritsFrom(SkynetIADSAbstractRadarElement)

function SkynetIADSCommandCenter:create(commandCenter, iads)
	local instance = self:superClass():create(commandCenter, iads)
	setmetatable(instance, self)
	self.__index = self
	instance.natoName = "Command Center"
	return instance
end

function SkynetIADSCommandCenter:goDark()

end

function SkynetIADSCommandCenter:goLive()

end

end
