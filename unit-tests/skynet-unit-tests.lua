
do
---IADS Unit Tests
TestIADS = {}

function TestIADS:setUp()
	self.iranIADS = SkynetIADS:create()
	self.iranIADS:addEarlyWarningRadarsByPrefix('EW')
	self.iranIADS:addSamSitesByPrefix('SAM')
end

function TestIADS:testCaclulateNumberOfSamSitesAndEWRadars()
	self.iranIADS = SkynetIADS:create()
	lu.assertEquals(#self.iranIADS:getSamSites(), 0)
	lu.assertEquals(#self.iranIADS:getEarlyWarningRadars(), 0)
	self.iranIADS:addEarlyWarningRadarsByPrefix('EW')
	self.iranIADS:addSamSitesByPrefix('SAM')
	lu.assertEquals(#self.iranIADS:getSamSites(), 11)
	lu.assertEquals(#self.iranIADS:getEarlyWarningRadars(), 9)
	local ewRadar = self.iranIADS:getEarlyWarningRadarByUnitName('EW-west')
	lu.assertEquals(ewRadar:hasWorkingPowerSource(), true)
end

function TestIADS:testEarlyWarningRadarHasWorkingPowerSourceByDefault()
	local ewRadar = self.iranIADS:getEarlyWarningRadarByUnitName('EW-west')
	lu.assertEquals(ewRadar:hasWorkingPowerSource(), true)
end

function TestIADS:testEarlyWarningRadarLoosesPower()
	ewWest2PowerSource = StaticObject.getByName('EW-west Power Source')
	self.iranIADS:setOptionsForEarlyWarningRadar('EW-west', ewWest2PowerSource)
	local ewRadar = self.iranIADS:getEarlyWarningRadarByUnitName('EW-west')
	lu.assertEquals(ewRadar:hasWorkingPowerSource(), true)
	trigger.action.explosion(ewWest2PowerSource:getPosition().p, 100)
	lu.assertEquals(ewRadar:hasWorkingPowerSource(), false)
	--simulate update cycle of IADS
	self.iranIADS.evaluateContacts(self.iranIADS)
	lu.assertEquals(ewRadar:hasWorkingPowerSource(), false)
	lu.assertEquals(ewRadar:isActive(), false)
end

function TestIADS:testSamSiteLoosesPower()
	local powerSource = StaticObject.getByName('SA-6 Power')
	self.iranIADS:setOptionsForSamSite('SAM-SA-6', powerSource)
	local samSite = self.iranIADS:getSamSiteByGroupName('SAM-SA-6')
	lu.assertEquals(#self.iranIADS:getUsableSamSites(), 11)
	lu.assertEquals(samSite:isActive(), false)
	samSite:goLive()
	lu.assertEquals(samSite:isActive(), true)
	trigger.action.explosion(powerSource:getPosition().p, 100)
	lu.assertEquals(#self.iranIADS:getUsableSamSites(), 10)
	lu.assertEquals(samSite:isActive(), false)
end

function TestIADS:testSAMSiteSA6LostConnectionNodeAutonomusStateDCSAI()
	local sa6ConnectionNode = StaticObject.getByName('SA-6 Connection Node')
	self.iranIADS:setOptionsForSamSite('SAM-SA-6', nil, sa6ConnectionNode, false, nil)
	lu.assertEquals(#self.iranIADS:getSamSites(), 11)
	lu.assertEquals(#self.iranIADS:getUsableSamSites(), 11)
	trigger.action.explosion(sa6ConnectionNode:getPosition().p, 100)
	lu.assertEquals(#self.iranIADS:getUsableSamSites(), 10)
	--simulate update cycle of IADS
	self.iranIADS.evaluateContacts(self.iranIADS)
	lu.assertEquals(#self.iranIADS:getUsableSamSites(), 10)
	lu.assertEquals(#self.iranIADS:getSamSites(), 11)
	local samSite = self.iranIADS:getSamSiteByGroupName('SAM-SA-6')
	lu.assertEquals(samSite:isActive(), true)
	--simulate update cycle of IADS
	self.iranIADS.evaluateContacts(self.iranIADS)
	lu.assertEquals(samSite:isActive(), true)
end

function TestIADS:testSAMSiteSA62ConnectionNodeLostAutonomusStateDark()
	local sa6ConnectionNode2 = StaticObject.getByName('SA-6-2 Connection Node')
	local samSite = self.iranIADS:getSamSiteByGroupName('SAM-SA-6-2')
	lu.assertEquals(samSite:isActive(), false)
	self.iranIADS:setOptionsForSamSite('SAM-SA-6-2', nil, sa6ConnectionNode2, false, SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK)
	lu.assertEquals(samSite:hasActiveConnectionNode(), true)
	trigger.action.explosion(sa6ConnectionNode2:getPosition().p, 100)
	lu.assertEquals(samSite:hasActiveConnectionNode(), false)
	lu.assertEquals(samSite:isActive(), false)
	--simulate update cycle of IADS
	self.iranIADS.evaluateContacts(self.iranIADS)
	lu.assertEquals(samSite:isActive(), false)
end

function TestIADS:testOneCommandCenterIsDestroyed()
	local powerStation1 = StaticObject.getByName("Command Center Power")
	local commandCenter1 = StaticObject.getByName("Command Center")	
	lu.assertEquals(#self.iranIADS:getCommandCenters(), 0)
	self.iranIADS:addCommandCenter(commandCenter1, powerStation1)
	lu.assertEquals(#self.iranIADS:getCommandCenters(), 1)
	lu.assertEquals(self.iranIADS:isCommandCenterUsable(), true)
	trigger.action.explosion(commandCenter1:getPosition().p, 10000)
	lu.assertEquals(#self.iranIADS:getCommandCenters(), 1)
	lu.assertEquals(self.iranIADS:isCommandCenterUsable(), false)
end

function TestIADS:testSetSamSitesToAutonomous()
	local samSiteDark = self.iranIADS:getSamSiteByGroupName('SAM-SA-6')
	local samSiteActive = self.iranIADS:getSamSiteByGroupName('SAM-SA-6-2')
	lu.assertEquals(samSiteDark:isActive(), false)
	lu.assertEquals(samSiteActive:isActive(), false)
	self.iranIADS:setOptionsForSamSite('SAM-SA-6', nil, nil, false, SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK)
	self.iranIADS:setOptionsForSamSite('SAM-SA-6-2', nil, nil, false, SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI)
	self.iranIADS:setSamSitesToAutonomousMode()
	lu.assertEquals(samSiteDark:isActive(), false)
	lu.assertEquals(samSiteActive:isActive(), true)
	--dont call an update of the IADS in this test, its just to test setSamSitesToAutonomousMode()
end

function TestIADS:testOneCommandCenterLoosesPower()
	local commandCenter2Power = StaticObject.getByName("Command Center2 Power")
	local commandCenter2 = StaticObject.getByName("Command Center2")
	lu.assertEquals(#self.iranIADS:getCommandCenters(), 0)
	lu.assertEquals(self.iranIADS:isCommandCenterUsable(), true)
	self.iranIADS:addCommandCenter(commandCenter2, commandCenter2Power)
	lu.assertEquals(#self.iranIADS:getCommandCenters(), 1)
	lu.assertEquals(self.iranIADS:isCommandCenterUsable(), true)
	trigger.action.explosion(commandCenter2Power:getPosition().p, 10000)
	lu.assertEquals(#self.iranIADS:getCommandCenters(), 1)
	lu.assertEquals(self.iranIADS:isCommandCenterUsable(), false)
end

function TestIADS:testMergeContacts()
	lu.assertEquals(#self.iranIADS:getContacts(), 0)
	self.iranIADS:mergeContact(IADSContactFactory('Player Hornet'))
	lu.assertEquals(#self.iranIADS:getContacts(), 1)
	
	self.iranIADS:mergeContact(IADSContactFactory('Player Hornet'))
	lu.assertEquals(#self.iranIADS:getContacts(), 1)
	
	self.iranIADS:mergeContact(IADSContactFactory('Harrier Pilot'))
	lu.assertEquals(#self.iranIADS:getContacts(), 2)
	
end

function TestIADS:testCompleteDestructionOfSamSite()
	local samSiteDCS = Group.getByName("Destruction-test-sam")
	local iads = SkynetIADS:create()
	local samSite = iads:addSamSite("Destruction-test-sam")
	lu.assertEquals(samSite:isDestroyed(), false)
	samSite:goLive()
	lu.assertEquals(samSite:isActive(), true)
	local radars = samSite:getRadars()
	for i = 1, #radars do
		local radar = radars[i]
		trigger.action.explosion(radar:getDCSRepresentation():getPosition().p, 500)
	end	
	local launchers = samSite:getLaunchers()
	for i = 1, #launchers do
		local launcher = launchers[i]
		trigger.action.explosion(launcher:getDCSRepresentation():getPosition().p, 500)
	end	
	lu.assertEquals(samSite:isActive(), false)
	lu.assertEquals(samSite:isDestroyed(), true)
	lu.assertEquals(#iads:getDestroyedSamSites(), 1)
end	

function TestIADS:testOnlyLoadGroupsWithPrefixForSAMSiteNotOtherUnitsOrStaticObjectsWithSamePrefix()
	local iads = SkynetIADS:create()
	local calledPrint = false
	function iads:printOutput(str, isWarning)
		calledPrint = true
	end
	iads:addSamSitesByPrefix('prefixtest')
	lu.assertEquals(#iads:getSamSites(), 1)
	lu.assertEquals(calledPrint, false)
end

function TestIADS:testOnlyLoadUnitsWithPrefixForEWSiteNotStaticObjectssWithSamePrefix()
	local iads = SkynetIADS:create()
	local calledPrint = false
	function iads:printOutput(str, isWarning)
		calledPrint = true
	end
	iads:addEarlyWarningRadarsByPrefix('prefixewtest')
	lu.assertEquals(#iads:getEarlyWarningRadars(), 1)
	lu.assertEquals(calledPrint, false)
end

TestSamSites = {}

function TestSamSites:setUp()
	if self.samSiteName then
		self.skynetIADS = SkynetIADS:create()
		local samSite = Group.getByName(self.samSiteName)
		self.samSite = SkynetIADSSamSite:create(samSite, self.skynetIADS)
	end
end

function TestSamSites:testCheckSA6GroupNumberOfLaunchersAndSearchRadarsAndNatoName()
	self.samSiteName = "SAM-SA-6"
	self:setUp()
	lu.assertEquals(#self.samSite:getLaunchers(), 2)
	lu.assertEquals(#self.samSite:getSearchRadars(), 3)
	lu.assertEquals(self.samSite:getNatoName(), "SA-6")
end

function TestSamSites:testCheckSA10GroupNumberOfLaunchersAndSearchRadarsAndNatoName()
	self.samSiteName = "SAM-SA-10"
	self:setUp()
	lu.assertEquals(#self.samSite:getLaunchers(), 2)
	lu.assertEquals(#self.samSite:getSearchRadars(), 2)
	lu.assertEquals(#self.samSite:getTrackingRadars(), 1)
	lu.assertEquals(#self.samSite:getRadars(), 3)
	lu.assertEquals(self.samSite:getNatoName(), "SA-10")
end

function TestSamSites:testCheckSA3GroupNumberOfLaunchersAndSearchRadarsAndNatoName()
	self.samSiteName = "test-SA-3"
	self:setUp()
	
	local array = {}
	local unitData = {
		['p-19 s-125 sr'] = {
			['max_range_finding_target'] = 80000,
			['min_range_finding_target'] = 1500,
			['max_alt_finding_target'] = 20000,
			['min_alt_finding_target'] = 25,
			['height'] = 5.841,
			['radar_rotation_period'] = 6.0,
		},
	}
	self.samSite:analyseAndAddUnit(SkynetIADSSAMSearchRadar, array, unitData)
	local searchRadar = array[1]
	lu.assertEquals(searchRadar:getMaxRangeFindingTarget(), 80000)
	
	array = {}
	unitData = {
		['5p73 s-125 ln'] = {
				['range'] = 18000,
				['missiles'] = 4,
		},
	}
	self.samSite:analyseAndAddUnit(SkynetIADSSAMLauncher, array, unitData)
	local launcher = array[1]
	lu.assertEquals(launcher:getRange(), 18000)
	
	array = {}
	unitData = {
		['snr s-125 tr'] = {
			['max_range_finding_target'] = 100000,
			['min_range_finding_target'] = 1500,
			['max_alt_finding_target'] = 20000,
			['min_alt_finding_target'] = 25,
			['height'] = 3,
		},
	}
	self.samSite:analyseAndAddUnit(SkynetIADSSAMTrackingRadar, array, unitData)
	local launcher = array[1]
	lu.assertEquals(launcher:getMaxRangeFindingTarget(), 100000)
	
	lu.assertEquals(#self.samSite:getLaunchers(), 1)	
	lu.assertEquals(#self.samSite:getSearchRadars(), 1)
	lu.assertEquals(#self.samSite:getTrackingRadars(), 1)
	lu.assertEquals(#self.samSite:getRadars(), 2)
	lu.assertEquals(self.samSite:getHarmDetectionChance(), 40)
	
	lu.assertEquals(self.samSite:getNatoName(), "SA-3")
end

function TestSamSites:testCreateSamSiteFromInvalidGroup()
	self.samSiteName = "Invalid-for-sam"
	self:setUp()
	lu.assertStrMatches(self.samSite:getNatoName(), "UNKNOWN")
	lu.assertEquals(#self.samSite:getRadars(), 0)
	lu.assertEquals(#self.samSite:getLaunchers(), 0)
	lu.assertEquals(#self.samSite:getSearchRadars(), 0)
	lu.assertEquals(#self.samSite:getTrackingRadars(), 0)
end

function TestSamSites:testSamSiteGroupContainingOfOneUnitOnlySA8()
	self.samSiteName = "SAM-SA-8"
	self:setUp()
	lu.assertEquals(#self.samSite:getRadars(), 1)
	lu.assertEquals(#self.samSite:getLaunchers(), 1)
	lu.assertEquals(#self.samSite:getSearchRadars(), 1)
	lu.assertEquals(#self.samSite:getTrackingRadars(), 0)
	lu.assertEquals(self.samSite:getNatoName(), "SA-8")
end

function TestSamSites:testHARMDefenceStates()
	self.samSiteName = "SAM-SA-6"
	self:setUp()
	lu.assertEquals(self.samSite:isActive(), true)
	lu.assertEquals(self.samSite:isScanningForHarms(), true)
	self.samSite:goSilentToEvadeHarm()
	lu.assertEquals(self.samSite:isScanningForHarms(), false)
	lu.assertEquals(self.samSite:isActive(), false)
end

function TestSamSites:testTimeToImpactCalculation()
	self.samSiteName = "SAM-SA-6"
	self:setUp()
	lu.assertEquals(self.samSite:getSecondsToImpact(100, 10), 36000)
	lu.assertEquals(self.samSite:getSecondsToImpact(10, 400), 90)
	lu.assertEquals(self.samSite:getSecondsToImpact(0, 400), 0)
	lu.assertEquals(self.samSite:getSecondsToImpact(400, 0), 0)
end

function TestSamSites:testActAsEarlyWarningRadar()
	self.samSiteName = "SAM-SA-6"
	self:setUp()
	self.samSite:goDark()
	lu.assertEquals(self.samSite:isActive(), false)
	self.samSite:setActAsEW(true)
	lu.assertEquals(self.samSite:isActive(), true)
	self.samSite:targetCycleUpdateEnd()
	lu.assertEquals(self.samSite:isActive(), true)
	self.samSite:setActAsEW(false)
	lu.assertEquals(self.samSite:isActive(), false)
end

function TestSamSites:testInformOfContactInRangeWhenEarlyWaringRadar()
	self.samSiteName = "SAM-SA-6"
	self:setUp()
	self.samSite:setActAsEW(true)
	local mockContact = {}
	function self.samSite:isTargetInRange(target)
		lu.assertIs(target, mockContact)
		return false
	end
	self.samSite:targetCycleUpdateStart()
	lu.assertEquals(self.samSite:isActive(), true)
	self.samSite:informOfContact(mockContact)
	lu.assertEquals(self.samSite:isActive(), true)
	self.samSite:targetCycleUpdateEnd()
	lu.assertEquals(self.samSite:isActive(), true)
end

function TestSamSites:testInformOfContactInRange()
	self.samSiteName = "SAM-SA-6"
	self:setUp()
	local mockContact = {}
	function self.samSite:isTargetInRange(target)
		lu.assertIs(target, mockContact)
		return true
	end
	self.samSite:goDark()
	self.samSite:targetCycleUpdateStart()
	lu.assertEquals(self.samSite:isActive(), false)
	self.samSite:informOfContact(mockContact)
	lu.assertEquals(self.samSite:isActive(), true)
	self.samSite:targetCycleUpdateEnd()
	lu.assertEquals(self.samSite:isActive(), true)
end

function TestSamSites:testInformOfContactNotInRange()
	self.samSiteName = "SAM-SA-6"
	self:setUp()
	local mockContact = {}
	function self.samSite:isTargetInRange(target)
		lu.assertIs(target, mockContact)
		return false
	end
	self.samSite:goDark()
	self.samSite:targetCycleUpdateStart()
	lu.assertEquals(self.samSite:isActive(), false)
	self.samSite:informOfContact(mockContact)
	lu.assertEquals(self.samSite:isActive(), false)
	self.samSite:targetCycleUpdateEnd()
	lu.assertEquals(self.samSite:isActive(), false)
end

function TestSamSites:testInformOfContactTargetInRangeMethod()
	self.samSiteName = "SAM-SA-2"
	self:setUp()
	self.samSite:goDark()
	self.samSite:informOfContact(IADSContactFactory('test-in-firing-range-of-sa-2'))
	lu.assertEquals(self.samSite:isActive(), true)
	
	self.samSite:goDark()
	self.samSite:informOfContact(IADSContactFactory('test-not-in-firing-range-of-sa-2'))
	lu.assertEquals(self.samSite:isActive(), false)
end

function TestSamSites:testInforOfContactInSearchRangeSAMSiteGoLiveWhenSetToSearchRange()
	self.samSiteName = "SAM-SA-2"
	self:setUp()
	self.samSite:goDark()
	lu.assertIs(self.samSite:getEngagementZone(), SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
	self.samSite.goLiveRange = nil
	self.samSite:setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
	lu.assertIs(self.samSite:getEngagementZone(), SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
	local target = IADSContactFactory('test-not-in-firing-range-of-sa-2')
	self.samSite:informOfContact(target)
	lu.assertEquals(self.samSite:isActive(), true)
end

function TestSamSites:testGoLiveRangeInPercentSA2()
	self.samSiteName = "SAM-SA-2"
	self:setUp()
	self.samSite:goDark()
	lu.assertIs(self.samSite:getEngagementZone(), SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
	self.samSite:setGoLiveRangeInPercent(60)
	
	local target = IADSContactFactory('test-in-firing-range-of-sa-2')
	self.samSite:informOfContact(target)
	
	local launcher = self.samSite:getLaunchers()[1]
	lu.assertEquals(launcher:isInRange(target), false)
	lu.assertEquals(self.samSite:isActive(), false)
	
end

function TestSamSites:testGoLiveRangeInPercentSA8()	
	self.samSiteName = 'SAM-SA-8'
	self:setUp()
	self.samSite:goDark()
	local target = IADSContactFactory('test-sa-8-will-go-active')
	self.samSite:informOfContact(target)
	lu.assertEquals(self.samSite:isActive(), true)
	
	local launcher = self.samSite:getLaunchers()[1]
	self.samSite:setGoLiveRangeInPercent(20)
	self.samSite:goDark()
	self.samSite:informOfContact(target)
	lu.assertEquals(launcher:isInRange(target), false)
	lu.assertEquals(self.samSite:isActive(), false)
end

function TestSamSites:testGetDistanceNMToContact()
	self.samSiteName = "SAM-SA-6"
	self:setUp()
	local contact = Unit.getByName('test-distance-calculation')
	lu.assertEquals(self.samSite:getDistanceNMToContact(self.samSite:getRadars()[1], contact), 20.33)
end

function TestSamSites:testPowerSourceStaticObjectGroundVehiclesAndDestrutionSuccessful()
	self.samSiteName = "test-samsite-with-unit-as-power-source"
	self:setUp()
	local powerSource = StaticObject.getByName("test-ground-vehicle-power-source")
	local connectionNode = StaticObject.getByName("test-ground-vehicle-connection-node")
	self.samSite:addPowerSource(powerSource)
	self.samSite:addConnectionNode(connectionNode)
	lu.assertEquals(self.samSite:hasWorkingPowerSource(), true)
	lu.assertEquals(self.samSite:hasActiveConnectionNode(), true)
	trigger.action.explosion(powerSource:getPosition().p, 3000)
	trigger.action.explosion(connectionNode:getPosition().p, 500)
	lu.assertEquals(self.samSite:hasWorkingPowerSource(), false)
	lu.assertEquals(self.samSite:hasActiveConnectionNode(), false)
	local event = {}
	event.id = world.event.S_EVENT_DEAD
	self.samSite:onEvent(event)
	self.skynetIADS.evaluateContacts(self.skynetIADS)
end

function TestSamSites:testPowerSourceUnitAndDescrutionSuccessful()
	self.samSiteName = "test-samsite-with-unit-as-power-source"
	self:setUp()
	local powerSource = Unit.getByName("test-unit-as-sam-power-source")
	local connectionNode = Unit.getByName("test-unit-as-sam-connection-node")
	self.samSite:addPowerSource(powerSource)
	self.samSite:addConnectionNode(connectionNode)
	lu.assertEquals(self.samSite:hasWorkingPowerSource(), true)
	trigger.action.explosion(powerSource:getPosition().p, 500)
	trigger.action.explosion(connectionNode:getPosition().p, 3000)
	lu.assertEquals(self.samSite:hasActiveConnectionNode(), false)
	lu.assertEquals(self.samSite:hasWorkingPowerSource(), false)
	self.skynetIADS.evaluateContacts(self.skynetIADS)
end

function TestSamSites:testShutDownTimes()
	self.samSiteName = "SAM-SA-6"
	self:setUp()
	lu.assertEquals(self.samSite:calculateMinimalShutdownTimeInSeconds(30), 60)
	local saveRandom = mist.random
	function mist.random(low, high)
		return 10
	end
	lu.assertEquals(self.samSite:calculateMaximalShutdownTimeInSeconds(20), 30)
	mist.random = saveRandom
end

TestEarlyWarningRadars = {}

function TestEarlyWarningRadars:setUp()
	if self.ewRadarName then
		local ewRadar = Unit.getByName(self.ewRadarName)
		self.iads = SkynetIADS:create()
		self.iads:addEarlyWarningRadarsByPrefix('EW')
		self.ewRadar = self.iads:getEarlyWarningRadarByUnitName('EW-west22')
	end
end

function TestEarlyWarningRadars:testCompleteDestructionOfEarlyWarningRadar()
		self.ewRadarName = "EW-west22"
		self:setUp()
		lu.assertEquals(self.ewRadar:isActive(), true)
		lu.assertEquals(self.ewRadar:getDCSRepresentation():isExist(), true)
		lu.assertEquals(#self.iads:getUsableEarlyWarningRadars(), 9)
		trigger.action.explosion(self.ewRadar:getDCSRepresentation():getPosition().p, 500)
		lu.assertEquals(self.ewRadar:getDCSRepresentation():isExist(), false)
		self.ewRadar:goDark()
		lu.assertEquals(self.ewRadar:isActive(), false)
		lu.assertEquals(#self.iads:getUsableEarlyWarningRadars(), 8)	
end

function IADSContactFactory(unitName)
	local contact = Unit.getByName(unitName)
	local radarContact = {}
	radarContact.object = contact
	local iadsContact = SkynetIADSContact:create(radarContact)
	return  iadsContact
end

lu.LuaUnit.run()

--- create an iads so the mission can be played, the ones in the unit tests, are cleaned once the tests are finished
iranIADS = SkynetIADS:create()
iranIADS:addEarlyWarningRadarsByPrefix('EW')
iranIADS:addSamSitesByPrefix('SAM')
local iadsDebug = iranIADS:getDebugSettings()
iadsDebug.IADSStatus = true
iranIADS:activate()

end