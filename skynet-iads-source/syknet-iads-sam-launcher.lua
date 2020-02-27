do

SkynetIADSSAMLauncher = {}
SkynetIADSSAMLauncher = inheritsFrom(SkynetIADSAbstractDCSObjectWrapper)

function SkynetIADSSAMLauncher:create(unit, performanceData)
	local instance = self:superClass():create(unit)
	setmetatable(instance, self)
	self.__index = self
	instance.performanceData = performanceData
	return instance
end

function SkynetIADSSAMLauncher:getRange()
	return self.performanceData['range']
end

function SkynetIADSSAMLauncher:isInRange(target)
	local distance = mist.utils.get2DDist(target:getPosition().p, self.dcsObject:getPosition().p)
	local maxFiringRange = self:getRange()
	--trigger.action.outText("Launcher Range: "..maxFiringRange,1)
	--trigger.action.outText("current distance: "..distance,1)
	return distance <= maxFiringRange
end

end
