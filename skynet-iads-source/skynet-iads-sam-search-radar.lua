do

SkynetIADSSAMSearchRadar = {}
SkynetIADSSAMSearchRadar = inheritsFrom(SkynetIADSAbstractDCSObjectWrapper)

function SkynetIADSSAMSearchRadar:create(unit)
	local instance = self:superClass():create(unit)
	setmetatable(instance, self)
	self.__index = self
	instance.firingRangePercent = 100
	instance.maximumRange = 0
	instance.initialNumberOfMissiles = 0
	instance.remainingNumberOfMissiles = 0
	instance.initialNumberOfShells = 0
	instance.remainingNumberOfShells = 0
	instance.triedSensors = 0
	return instance
end

--override in subclasses to match different datastructure of getSensors()
function SkynetIADSSAMSearchRadar:setupRangeData()
	if self:isExist() then
		local data = self:getDCSRepresentation():getSensors()
		if data == nil then
			--this is to prevent infinite calls between launcher and search radar
			self.triedSensors = self.triedSensors + 1
			--the SA-13 does not have any sensor data, but is has launcher data, so we use the stuff from the launcher for the radar range.
			SkynetIADSSAMLauncher.setupRangeData(self)
			return
		end
		for i = 1, #data do
			local subEntries = data[i]
			for j = 1, #subEntries do
				local sensorInformation = subEntries[j]
				-- some sam sites have  IR and passive EWR detection, we are just interested in the radar data
				-- investigate if upperHemisphere and headOn is ok, I guess it will work for most detection cases
				if sensorInformation.type == Unit.SensorType.RADAR and sensorInformation['detectionDistanceAir'] then
					local upperHemisphere = sensorInformation['detectionDistanceAir']['upperHemisphere']['headOn']
					local lowerHemisphere = sensorInformation['detectionDistanceAir']['lowerHemisphere']['headOn']
					self.maximumRange = upperHemisphere
					if lowerHemisphere > upperHemisphere then
						self.maximumRange = lowerHemisphere
					end
				end
			end
		end
	end
end

function SkynetIADSSAMSearchRadar:getMaxRangeFindingTarget()
	return self.maximumRange
end

function SkynetIADSSAMSearchRadar:isRadarWorking()
	-- the ammo check is for the SA-13 which does not return any sensor data:
	return (self:isExist() == true and ( self:getDCSRepresentation():getSensors() ~= nil or self:getDCSRepresentation():getAmmo() ~= nil ) )
end

function SkynetIADSSAMSearchRadar:setFiringRangePercent(percent)
	self.firingRangePercent = percent
end

function SkynetIADSSAMSearchRadar:getDistance(target)
	return mist.utils.get2DDist(target:getPosition().p, self:getDCSRepresentation():getPosition().p)
end

function SkynetIADSSAMSearchRadar:getHeight(target)
	local radarElevation = self:getDCSRepresentation():getPosition().p.y
	local targetElevation = target:getPosition().p.y
	return math.abs(targetElevation - radarElevation)
end

function SkynetIADSSAMSearchRadar:isInHorizontalRange(target)
	return (self:getMaxRangeFindingTarget() / 100 * self.firingRangePercent) >= self:getDistance(target)
end

function SkynetIADSSAMSearchRadar:isInRange(target)
	if self:isExist() == false then
		return false
	end
	return self:isInHorizontalRange(target)
end

end

