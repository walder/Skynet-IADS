do
SkynetIADSCommandCenter = {}
SkynetIADSCommandCenter = inheritsFrom(SkynetIADSAbstractRadarElement)

function SkynetIADSCommandCenter:create(commandCenter, iads)
	local instance = self:superClass():create(commandCenter, iads)
	setmetatable(instance, self)
	self.__index = self
	instance.natoName = "COMMAND CENTER"
	return instance
end

function SkynetIADSCommandCenter:goDark()

end

function SkynetIADSCommandCenter:goLive()

end

end
