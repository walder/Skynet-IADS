do
--- create an iads so the mission can be played, the ones in the unit tests, are cleaned once the tests are finished

redIADS = SkynetIADS:create("Red IADS")
local iadsDebug = redIADS:getDebugSettings()

iadsDebug.IADSStatus = true
iadsDebug.contacts = true
--[[
iadsDebug.radarWentDark = true

iadsDebug.radarWentLive = true
iadsDebug.jammerProbability = true
iadsDebug.addedEWRadar = true
iadsDebug.addedSAMSite = true
iadsDebug.harmDefence = true
iadsDebug.commandCenterStatusEnvOutput = true
iadsDebug.samSiteStatusEnvOutput = true
iadsDebug.earlyWarningRadarStatusEnvOutput = true
--]]

local comCenter = Unit.getByName('connection-node-ew')
local power = StaticObject.getByName('Command Center Power')
local connection = Unit.getByName('connection-node-ew')
redIADS:addCommandCenter(comCenter):addPowerSource(power):addConnectionNode(connection)

local comCenter2 = StaticObject.getByName('Command Center')
redIADS:addCommandCenter(comCenter2)

redIADS:addEarlyWarningRadarsByPrefix('EW')
redIADS:addSAMSitesByPrefix('SAM'):setHARMDetectionChance(100)

ewConnectionNode = Unit.getByName('connection-node-ew')
redIADS:getEarlyWarningRadarByUnitName('EW-west2'):setHARMDetectionChance(100):addConnectionNode(ewConnectionNode)
local sa15 = redIADS:getSAMSiteByGroupName('SAM-SA-15-1')
redIADS:getSAMSiteByGroupName('SAM-SA-10'):setActAsEW(true):setHARMDetectionChance(100):addPointDefence(sa15):setIgnoreHARMSWhilePointDefencesHaveAmmo(true)
redIADS:getSAMSiteByGroupName('SAM-HQ-7'):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
local connectioNode = StaticObject.getByName('Unused Connection Node')
redIADS:getSAMSiteByGroupName('SAM-SA-6-2'):addConnectionNode(connectioNode):setGoLiveRangeInPercent(120):setHARMDetectionChance(100)

redIADS:getEarlyWarningRadarByUnitName('EW-SR-P19'):addPointDefence(redIADS:getSAMSiteByGroupName('SAM-SA-15-P19')):setIgnoreHARMSWhilePointDefencesHaveAmmo(true)



redIADS:addRadioMenu()
redIADS:activate()

blueIADS = SkynetIADS:create("UAE")
blueIADS:addSAMSitesByPrefix('BLUE-SAM')
blueIADS:addEarlyWarningRadarsByPrefix('BLUE-EW')
blueIADS:getSAMSitesByNatoName('Rapier'):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
blueIADS:getSAMSitesByNatoName('Roland ADS'):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
blueIADS:addRadioMenu()
blueIADS:activate()

--[[
local iadsDebug = blueIADS:getDebugSettings()
iadsDebug.IADSStatus = true
iadsDebug.radarWentDark = true
iadsDebug.contacts = true
iadsDebug.radarWentLive = true
--]]


local jammer = SkynetIADSJammer:create(Unit.getByName('jammer-source'), redIADS)
jammer:addRadioMenu()

posCounter = 0
initialPosition = nil
secondPoisition = nil
calculatedPosition = nil

function Vec3CalculationSpike()

	if posCounter == 1 then
		initialPosition = Unit.getByName('Hornet SA-6 Attack'):getPosition().p
		env.info("Initial Position X:"..initialPosition.x.." Y:"..initialPosition.y.." Z:"..initialPosition.z)
	end
	
	if posCounter == 2 then
		secondPoisition = Unit.getByName('Hornet SA-6 Attack'):getPosition().p
		env.info("Second Position X:"..secondPoisition.x.." Y:"..secondPoisition.y.." Z:"..secondPoisition.z)
	end
	
	if posCounter >= 2 then
		
		local deltaX = (secondPoisition.x - initialPosition.x)
		--y represents altitude in implementation don't increment this value it may skyrocket or go below 0
		local deltaY = (secondPoisition.y - initialPosition.y)
		local deltaZ = (secondPoisition.z - initialPosition.z)
		
		env.info("deltas X:"..deltaX.." Y:"..deltaY.." Z:"..deltaZ)
		env.info("------------------------------------------------")
		
		if calculatedPosition == nil then
			calculatedPosition  = {}
			calculatedPosition.x = initialPosition.x
			calculatedPosition.y = initialPosition.y
			calculatedPosition.z = initialPosition.z
		end
		
		calculatedPosition.x = calculatedPosition.x + deltaX
		calculatedPosition.y = calculatedPosition.y + deltaY
		calculatedPosition.z = calculatedPosition.z + deltaZ
		
		local currentPosition = Unit.getByName('Hornet SA-6 Attack'):getPosition().p
		
		env.info("Calculated Position X:"..calculatedPosition.x.." Y:"..calculatedPosition.y.." Z:"..calculatedPosition.z)
		env.info("Current Position X:"..currentPosition.x.." Y:"..currentPosition.y.." Z:"..currentPosition.z)
		local difX = currentPosition.x - calculatedPosition.x
		local difY = currentPosition.y - calculatedPosition.y
		local difZ  = currentPosition.z - calculatedPosition.z
		
		env.info("Difference X:"..difX.." Y:"..difY.." Z:"..difZ)
		env.info("------------------------------------------------")
		
	end
	
	posCounter = posCounter + 1
end

--mist.scheduleFunction(Vec3CalculationSpike, {}, 1, 1)

end