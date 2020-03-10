do

SkynetIADSSAMLauncher = {}
SkynetIADSSAMLauncher = inheritsFrom(SkynetIADSSAMSearchRadar)

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

function SkynetIADSSAMLauncher:isAAA()
	local isAAA = self.performanceData['aaa']
	if isAAA == nil then
		isAAA = false
	end
	return isAAA
end

function SkynetIADSSAMLauncher:isInRange(target)
	if self:isExist() == false then
		return false
	end
	local distance = mist.utils.get2DDist(target:getPosition().p, self.dcsObject:getPosition().p)
	local maxFiringRange = (self:getRange() / 100 * self.firingRangePercent)
	return distance <= maxFiringRange
end

end
