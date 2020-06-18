do
--- create an iads so the mission can be played, the ones in the unit tests, are cleaned once the tests are finished

iranIADS = SkynetIADS:create("Iran")
local iadsDebug = iranIADS:getDebugSettings()
iadsDebug.IADSStatus = true
iadsDebug.samWentDark = true
iadsDebug.contacts = true
iadsDebug.radarWentLive = true
iadsDebug.noWorkingCommmandCenter = false
iadsDebug.ewRadarNoConnection = false
iadsDebug.samNoConnection = false
iadsDebug.jammerProbability = true
iadsDebug.addedEWRadar = true
iadsDebug.hasNoPower = false
iadsDebug.harmDefence = true
--iadsDebug.samSiteStatusEnvOutput = true
--iadsDebug.earlyWarningRadarStatusEnvOutput = true

iranIADS:addEarlyWarningRadarsByPrefix('EW')
iranIADS:addSAMSitesByPrefix('SAM')

ewConnectionNode = Unit.getByName('connection-node-ew')
iranIADS:getEarlyWarningRadarByUnitName('EW-west2'):setHARMDetectionChance(100):addConnectionNode(ewConnectionNode)
local sa15 = iranIADS:getSAMSiteByGroupName('SAM-SA-15-1')
iranIADS:getSAMSiteByGroupName('SAM-SA-10'):setActAsEW(true):setHARMDetectionChance(100):addPointDefence(sa15):setIgnoreHARMSWhilePointDefencesHaveAmmo(true)
iranIADS:getSAMSiteByGroupName('SAM-HQ-7'):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
local connectioNode = StaticObject.getByName('Unused Connection Node')
local sam = iranIADS:getSAMSiteByGroupName('SAM-SA-6-2'):addConnectionNode(connectioNode):setGoLiveRangeInPercent(120):setHARMDetectionChance(100)

local conNode = SkynetIADSAbstractDCSObjectWrapper:create(nil)
iranIADS:getEarlyWarningRadarByUnitName('EW-SR-P19'):addPointDefence(iranIADS:getSAMSiteByGroupName('SAM-SA-15-P19')):setIgnoreHARMSWhilePointDefencesHaveAmmo(true):addConnectionNode(conNode)



iranIADS:addRadioMenu()
iranIADS:activate()

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
iadsDebug.samWentDark = true
iadsDebug.contacts = true
iadsDebug.radarWentLive = true
--]]


local jammer = SkynetIADSJammer:create(Unit.getByName('jammer-source'), iranIADS)
--jammer:masterArmOn()
jammer:addRadioMenu()

--local blueIadsDebug = blueIADS:getDebugSettings()
--blueIadsDebug.IADSStatus = true
--blueIadsDebug.harmDefence = true
--blueIadsDebug.contacts = true

local launchers = sam:getLaunchers()
for i=1, #launchers do
	local launcher = launchers[i]:getDCSRepresentation()
--	trigger.action.explosion(launcher:getPosition().p, 9000)
end
--test to check in game ammo changes, to build unit tests on

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

--trigger.action.effectSmokeBig(Unit.getByName('EW-west2'):getPosition().p, 8, 10)

function checkSams(iranIADS)

	--[[
	local sam = iranIADS:getSAMSiteByGroupName('SAM-SA-6-2')
	env.info("current num of missile: "..sam:getRemainingNumberOfMissiles())
	env.info("Initial num missiles: "..sam:getInitialNumberOfMissiles())
	env.info("Has Missiles in Flight: "..tostring(sam:hasMissilesInFlight()))
	env.info("Number of Missiles in Fligth: "..#sam.missilesInFlight)
	env.info("Has remaining Ammo: "..tostring(sam:hasRemainingAmmo()))
	--]]
	--[[
	local sam = iranIADS:getSAMSiteByGroupName('SAM-Shilka')
	env.info("current num of missile: "..sam:getRemainingNumberOfShells())
	env.info("Initial num missiles: "..sam:getInitialNumberOfShells())
	--env.info("Has Missiles in Flight: "..tostring(sam:hasMissilesInFlight()))
	--env.info("Number of Missiles in Fligth: "..#sam.missilesInFlight)
	env.info("Has remaining Ammo: "..tostring(sam:hasRemainingAmmo()))
	--]]
end
--[[
local group = Group.getByName('SAM-SA-6-2')	
local cont = group:getController()	
cont:setOnOff(true)
cont:setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.RED)	
cont:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_FREE)
--]]	
--mist.scheduleFunction(checkSams, {iranIADS}, 1, 1)
end