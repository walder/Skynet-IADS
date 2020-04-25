do

--[[
SAM Sites that engage HARMs:
SA-15
SA-10 (bug when engaging at 25k, no harms are intercepted)

SAM Sites that ignore HARMS:
SA-11
SA-6
SA-2
SA-3
Patriot
]]--

--[[ Compile Scripts:

echo -- BUILD Timestamp: %DATE% %TIME% > skynet-iads-compiled.lua && type skynet-iads-supported-types.lua skynet-iads.lua  skynet-iads-table-delegator.lua skynet-iads-abstract-dcs-object-wrapper.lua skynet-iads-abstract-element.lua skynet-iads-abstract-radar-element.lua skynet-iads-awacs-radar.lua skynet-iads-command-center.lua skynet-iads-contact.lua skynet-iads-early-warning-radar.lua skynet-iads-jammer.lua skynet-iads-sam-search-radar.lua skynet-iads-sam-site.lua skynet-iads-sam-tracking-radar.lua syknet-iads-sam-launcher.lua >> skynet-iads-compiled.lua;

--]]

--[[
Update Time in MS stress test, before optimisiation:
39 ms
36 ms
38 ms
39 ms
35 ms


update after improvement step 1:
26 ms
16 ms
18 ms
27 ms
25 ms
25 ms
27 ms
24 ms
17 ms
18 ms
--]]

---IADS Unit Tests
SKYNET_UNIT_TESTS_NUM_EW_SITES_RED = 17
SKYNET_UNIT_TESTS_NUM_SAM_SITES_RED = 15

function IADSContactFactory(unitName)
	local contact = Unit.getByName(unitName)
	local radarContact = {}
	radarContact.object = contact
	local iadsContact = SkynetIADSContact:create(radarContact)
	iadsContact:refresh()
	return  iadsContact
end


TestIADS = {}

function TestIADS:setUp()
	self.numSAMSites = SKYNET_UNIT_TESTS_NUM_SAM_SITES_RED 
	self.numEWSites = SKYNET_UNIT_TESTS_NUM_EW_SITES_RED
	self.iranIADS = SkynetIADS:create()
	self.iranIADS:addEarlyWarningRadarsByPrefix('EW')
	self.iranIADS:addSAMSitesByPrefix('SAM')
end

function TestIADS:tearDown()
	if	self.iranIADS then
		self.iranIADS:deactivate()
	end
	self.iranIADS = nil
end

-- this function checks constants in DCS that the IADS relies on. A change to them might indicate that functionallity is broken.
-- In the code constants are refereed to with their constant name calue, not the values the represent.
function TestIADS:testDCSContstantsHaveNotChanged()
	lu.assertEquals(Weapon.Category.MISSILE, 1)
	lu.assertEquals(Weapon.Category.SHELL, 0)
	lu.assertEquals(world.event.S_EVENT_SHOT, 1)
	lu.assertEquals(world.event.S_EVENT_DEAD, 8)
	lu.assertEquals(Unit.Category.AIRPLANE, 0)
end

function TestIADS:testCaclulateNumberOfSamSitesAndEWRadars()
	self:tearDown()
	self.iranIADS = SkynetIADS:create()
	lu.assertEquals(#self.iranIADS:getSAMSites(), 0)
	lu.assertEquals(#self.iranIADS:getEarlyWarningRadars(), 0)
	self.iranIADS:addEarlyWarningRadarsByPrefix('EW')
	self.iranIADS:addSAMSitesByPrefix('SAM')
	lu.assertEquals(#self.iranIADS:getSAMSites(), self.numSAMSites)
	lu.assertEquals(#self.iranIADS:getEarlyWarningRadars(), self.numEWSites)
end

function TestIADS:testCaclulateNumberOfSamSitesAndEWRadarsWhenAddMethodsCalledTwice()
	self:tearDown()
	self.iranIADS = SkynetIADS:create()
	lu.assertEquals(#self.iranIADS:getSAMSites(), 0)
	lu.assertEquals(#self.iranIADS:getEarlyWarningRadars(), 0)
	self.iranIADS:addEarlyWarningRadarsByPrefix('EW')
	self.iranIADS:addEarlyWarningRadarsByPrefix('EW')
	self.iranIADS:addSAMSitesByPrefix('SAM')
	self.iranIADS:addSAMSitesByPrefix('SAM')
	lu.assertEquals(#self.iranIADS:getSAMSites(), self.numSAMSites)
	lu.assertEquals(#self.iranIADS:getEarlyWarningRadars(), self.numEWSites)
end

function TestIADS:testDoubleActivateCall()
	self.iranIADS:activate()
	self.iranIADS:activate()
	local ews = self.iranIADS:getEarlyWarningRadars()
	for i = 1, #ews do
		local ew = ews[i]
		local category = ew:getDCSRepresentation():getDesc().category
		if category ~= Unit.Category.AIRPLANE and category ~= Unit.Category.SHIP then
			--env.info(tostring(ew:isScanningForHARMs()))
			lu.assertEquals(ew:isScanningForHARMs(), true)
		end
	end
end

function TestIADS:testWrongCaseStringWillNotLoadSAMGroup()
	self:tearDown()
	self.iranIADS = SkynetIADS:create()
	self.iranIADS:addSAMSitesByPrefix('sam')
	lu.assertEquals(#self.iranIADS:getSAMSites(), 0)
end	

function TestIADS:testWrongCaseStringWillNotLoadEWRadars()
	self:tearDown()
	self.iranIADS = SkynetIADS:create()
	self.iranIADS:addEarlyWarningRadarsByPrefix('ew')
	lu.assertEquals(#self.iranIADS:getEarlyWarningRadars(), 0)
end	

function TestIADS:testEvaluateContacts1EWAnd1SAMSiteWithContactInRange()
	local iads = SkynetIADS:create()
	local ewRadar = iads:addEarlyWarningRadar('EW-west23')
	
	function ewRadar:getDetectedTargets()
		return {IADSContactFactory('test-in-firing-range-of-sa-2')}
	end
	
	local samSite = iads:addSAMSite('SAM-SA-2')
	
	
	function samSite:getDetectedTargets()
		return {}
	end
	
	samSite:goDark()
	lu.assertEquals(samSite:isInRadarDetectionRangeOf(ewRadar), true)
	iads:activate()
	iads:evaluateContacts()
	lu.assertEquals(#iads:getContacts(), 1)
	lu.assertEquals(samSite:isActive(), true)
	
	-- we remove the target to test if the sam site will no go dark, was added for the performance optimised code
	function ewRadar:getDetectedTargets()
		return {}
	end
	iads:evaluateContacts()
	lu.assertEquals(samSite:isActive(), false)
	
end

function TestIADS:testEarlyWarningRadarHasWorkingPowerSourceByDefault()
	local ewRadar = self.iranIADS:getEarlyWarningRadarByUnitName('EW-west')
	lu.assertEquals(ewRadar:hasWorkingPowerSource(), true)
end

function TestIADS:testPowerSourceConnectedToMultipleAbstractRadarElementSitesIsDestroyedAutonomousStateIsOnlyRebuiltOnce()

	local iads = SkynetIADS:create()

	ewWest2PowerSource = StaticObject.getByName('west Power Source')
	local ewRadar = iads:addEarlyWarningRadar('EW-west'):addPowerSource(ewWest2PowerSource)
	
	local samSite = iads:addSAMSite('test-samsite-with-unit-as-power-source')
	
	lu.assertEquals(samSite:getAutonomousState(), false)
	
	local samSite2 = iads:addSAMSite('SAM-SA-15')
	samSite2:addPowerSource(ewWest2PowerSource)
	samSite2:goLive()
	
	local updateCalls = 0

	function iads:enforceRebuildAutonomousStateOfSAMSites()
		SkynetIADS.enforceRebuildAutonomousStateOfSAMSites(self)
		updateCalls = updateCalls + 1
	end
	
	lu.assertEquals(ewRadar:hasWorkingPowerSource(), true)
	trigger.action.explosion(ewWest2PowerSource:getPosition().p, 100)
	lu.assertEquals(ewRadar:hasWorkingPowerSource(), false)
	lu.assertEquals(ewRadar:isActive(), false)
	
	lu.assertEquals(samSite:getAutonomousState(), true)
	lu.assertEquals(samSite2:isActive(), false)
	
	-- we ensure the autonomous state is only rebuilt once when a power source connected to mulitple EW or SAM sites is destroyed
	lu.assertEquals(updateCalls, 1)
	
	
end

function TestIADS:testEarlyWarningRadarAndSAMSiteLooseConnectionNodeAndAutonomousStateIsOnlyRebuiltOnce()

	local iads = SkynetIADS:create()

	ewWestConnectionNode = StaticObject.getByName('west Connection Node Destroy')
	local ewRadar = iads:addEarlyWarningRadar('EW-west'):addConnectionNode(ewWestConnectionNode)
	
	local samSite = iads:addSAMSite('test-samsite-with-unit-as-power-source')
	samSite:addConnectionNode(ewWestConnectionNode)
	lu.assertEquals(samSite:getAutonomousState(), false)
	
	local updateCalls = 0

	function iads:enforceRebuildAutonomousStateOfSAMSites()
		SkynetIADS.enforceRebuildAutonomousStateOfSAMSites(self)
		updateCalls = updateCalls + 1
	end
	
	trigger.action.explosion(ewWestConnectionNode:getPosition().p, 100)
	
	lu.assertEquals(ewRadar:hasActiveConnectionNode(), false)
	lu.assertEquals(samSite:hasActiveConnectionNode(), false)
	lu.assertEquals(ewRadar:isActive(), false)
	
	lu.assertEquals(samSite:getAutonomousState(), true)
	
	-- we ensure the autonomous state is only rebuilt once when a connection node used by mulitple EW or SAM sites is destroyed
	lu.assertEquals(updateCalls, 1)
	
end

function TestIADS:testAWACSHasMovedAndThereforeRebuiltAutonomousStatesOfSAMSites()

	local iads= SkynetIADS:create()
	iads:addEarlyWarningRadar('EW-AWACS-A-50')

	local updateCalls = 0
	function iads:enforceRebuildAutonomousStateOfSAMSites()
		SkynetIADS.enforceRebuildAutonomousStateOfSAMSites(self)
		updateCalls = updateCalls + 1
	end
	
	iads:evaluateContacts()
	
end


function TestIADS:testSAMSiteLoosesPower()
	local powerSource = StaticObject.getByName('SA-6 Power')
	local samSite = self.iranIADS:getSAMSiteByGroupName('SAM-SA-6'):addPowerSource(powerSource)
	lu.assertEquals(#self.iranIADS:getUsableSAMSites(), self.numSAMSites)
	lu.assertEquals(samSite:isActive(), false)
	samSite:goLive()
	lu.assertEquals(samSite:isActive(), true)
	trigger.action.explosion(powerSource:getPosition().p, 100)
	lu.assertEquals(#self.iranIADS:getUsableSAMSites(), self.numSAMSites-1)
	lu.assertEquals(samSite:isActive(), false)
end

function TestIADS:testSAMSiteSA6LostConnectionNodeAutonomusStateDCSAI()
	local sa6ConnectionNode = StaticObject.getByName('SA-6 Connection Node')
	self.iranIADS:getSAMSiteByGroupName('SAM-SA-6'):addConnectionNode(sa6ConnectionNode)
	lu.assertEquals(#self.iranIADS:getSAMSites(), self.numSAMSites)
	lu.assertEquals(#self.iranIADS:getUsableSAMSites(), self.numSAMSites)
	trigger.action.explosion(sa6ConnectionNode:getPosition().p, 100)
	lu.assertEquals(#self.iranIADS:getUsableSAMSites(), self.numSAMSites-1)

	lu.assertEquals(#self.iranIADS:getUsableSAMSites(), self.numSAMSites-1)
	lu.assertEquals(#self.iranIADS:getSAMSites(), self.numSAMSites)
	local samSite = self.iranIADS:getSAMSiteByGroupName('SAM-SA-6')
	lu.assertEquals(samSite:isActive(), true)

	lu.assertEquals(samSite:getAutonomousState(), true)
	lu.assertEquals(samSite:isActive(), true)
end

function TestIADS:testSAMSiteSA62ConnectionNodeLostAutonomusStateDark()
	local sa6ConnectionNode2 = StaticObject.getByName('SA-6-2 Connection Node')
	local samSite = self.iranIADS:getSAMSiteByGroupName('SAM-SA-6-2')
	lu.assertEquals(samSite:isActive(), false)
	self.iranIADS:getSAMSiteByGroupName('SAM-SA-6-2'):addConnectionNode(sa6ConnectionNode2):setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK)
	lu.assertEquals(samSite:hasActiveConnectionNode(), true)
	trigger.action.explosion(sa6ConnectionNode2:getPosition().p, 100)
	lu.assertEquals(samSite:hasActiveConnectionNode(), false)
	lu.assertEquals(#samSite:getRadars(), 1)
	lu.assertEquals(samSite:isActive(), false)
end

function TestIADS:testOneCommandCenterIsDestroyed()
	local powerStation1 = StaticObject.getByName("Command Center Power")
	local commandCenter1 = StaticObject.getByName("Command Center")	
	lu.assertEquals(#self.iranIADS:getCommandCenters(), 0)
	self.iranIADS:addCommandCenter(commandCenter1):addPowerSource(powerStation1)
	lu.assertEquals(#self.iranIADS:getCommandCenters(), 1)
	lu.assertEquals(self.iranIADS:isCommandCenterUsable(), true)
	trigger.action.explosion(commandCenter1:getPosition().p, 10000)
	lu.assertEquals(#self.iranIADS:getCommandCenters(), 1)
	lu.assertEquals(self.iranIADS:isCommandCenterUsable(), false)
end

function TestIADS:testSetSamSitesToAutonomous()
	local samSiteDark = self.iranIADS:getSAMSiteByGroupName('SAM-SA-6')
	local samSiteActive = self.iranIADS:getSAMSiteByGroupName('SAM-SA-6-2')
	lu.assertEquals(samSiteDark:isActive(), false)
	lu.assertEquals(samSiteActive:isActive(), false)
	self.iranIADS:getSAMSiteByGroupName('SAM-SA-6'):setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK)
	self.iranIADS:getSAMSiteByGroupName('SAM-SA-6-2'):setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI)
	self.iranIADS:setSAMSitesToAutonomousMode()
	lu.assertEquals(samSiteDark:isActive(), false)
	lu.assertEquals(samSiteActive:isActive(), true)
	samSiteActive:goDark()
	--dont call an update of the IADS in this test, its just to test setSamSitesToAutonomousMode()
end

function TestIADS:testSetOptionsForSAMSiteType()
	local powerSource = StaticObject.getByName('SA-11-power-source')
	local connectionNode = StaticObject.getByName('SA-11-connection-node')
	lu.assertEquals(#self.iranIADS:getSAMSitesByNatoName('SA-6'), 2)
	--lu.assertIs(getmetatable(self.iranIADS:getSAMSitesByNatoName('SA-6')), SkynetIADSTableForwarder)
	local samSites = self.iranIADS:getSAMSitesByNatoName('SA-6'):setActAsEW(true):addPowerSource(powerSource):addConnectionNode(connectionNode):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE):setGoLiveRangeInPercent(90):setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK)
	lu.assertEquals(#samSites, 2)
	for i = 1, #samSites do
		local samSite = samSites[i]
		lu.assertEquals(samSite:getActAsEW(), true)
		lu.assertEquals(samSite:getEngagementZone(), SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
		lu.assertEquals(samSite:getGoLiveRangeInPercent(), 90)
		lu.assertEquals(samSite:getAutonomousBehaviour(), SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK)
		lu.assertIs(samSite:getConnectionNodes()[1], connectionNode)
		lu.assertIs(samSite:getPowerSources()[1], powerSource)
	end
end

function TestIADS:testSetOptionsForAllAddedSamSitesByPrefix()
	self:tearDown()
	self.iranIADS = SkynetIADS:create()
	local samSites = self.iranIADS:addSAMSitesByPrefix('SAM'):setActAsEW(true):addPowerSource(powerSource):addConnectionNode(connectionNode):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE):setGoLiveRangeInPercent(90):setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK)
	lu.assertEquals(#samSites, self.numSAMSites)
	for i = 1, #samSites do
		local samSite = samSites[i]
		lu.assertEquals(samSite:getActAsEW(), true)
		lu.assertEquals(samSite:getEngagementZone(), SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
		lu.assertEquals(samSite:getGoLiveRangeInPercent(), 90)
		lu.assertEquals(samSite:getAutonomousBehaviour(), SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK)
		lu.assertIs(samSite:getConnectionNodes()[1], connectionNode)
		lu.assertIs(samSite:getPowerSources()[1], powerSource)
	end
end

function TestIADS:testSetOptionsForAllAddedSAMSites()
	local samSites = self.iranIADS:getSAMSites():setActAsEW(true):addPowerSource(powerSource):addConnectionNode(connectionNode):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE):setGoLiveRangeInPercent(90):setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK)
	lu.assertEquals(#samSites, self.numSAMSites)
	for i = 1, #samSites do
		local samSite = samSites[i]
		lu.assertEquals(samSite:getActAsEW(), true)
		lu.assertEquals(samSite:getEngagementZone(), SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
		lu.assertEquals(samSite:getGoLiveRangeInPercent(), 90)
		lu.assertEquals(samSite:getAutonomousBehaviour(), SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK)
		lu.assertIs(samSite:getConnectionNodes()[1], connectionNode)
		lu.assertIs(samSite:getPowerSources()[1], powerSource)
	end
end

function TestIADS:testSetOptionsForAllAddedEWSitesByPrefix()
	self:tearDown()
	self.iranIADS = SkynetIADS:create()
	local ewSites = self.iranIADS:addEarlyWarningRadarsByPrefix('EW'):addPowerSource(powerSource):addConnectionNode(connectionNode)
	lu.assertEquals(#ewSites, self.numEWSites)
	for i = 1, #ewSites do
		local ewSite = ewSites[i]
		lu.assertIs(ewSite:getConnectionNodes()[1], connectionNode)
		lu.assertIs(ewSite:getPowerSources()[1], powerSource)
	end
	
end

function TestIADS:testSetOptionsForAllAddedEWSites()
	local ewSites = self.iranIADS:getEarlyWarningRadars()
	lu.assertEquals(#ewSites, self.numEWSites)
	for i = 1, #ewSites do
		local ewSite = ewSites[i]
		lu.assertIs(ewSite:getConnectionNodes()[1], connectionNode)
		lu.assertIs(ewSite:getPowerSources()[1], powerSource)
	end
end


function TestIADS:testOneCommandCenterLoosesPower()
	local commandCenter2Power = StaticObject.getByName("Command Center2 Power")
	local commandCenter2 = StaticObject.getByName("Command Center2")
	lu.assertEquals(#self.iranIADS:getCommandCenters(), 0)
	lu.assertEquals(self.iranIADS:isCommandCenterUsable(), true)
	local comCenter = self.iranIADS:addCommandCenter(commandCenter2):addPowerSource(commandCenter2Power)
	lu.assertEquals(#comCenter:getPowerSources(), 1)
	lu.assertEquals(#self.iranIADS:getCommandCenters(), 1)
	lu.assertEquals(self.iranIADS:isCommandCenterUsable(), true)
	trigger.action.explosion(commandCenter2Power:getPosition().p, 10000)
	lu.assertEquals(#self.iranIADS:getCommandCenters(), 1)
	lu.assertEquals(self.iranIADS:isCommandCenterUsable(), false)
end

function TestIADS:testMergeContacts()
	lu.assertEquals(#self.iranIADS:getContacts(), 0)
	self.iranIADS:mergeContact(IADSContactFactory('Harrier Pilot'))
	lu.assertEquals(#self.iranIADS:getContacts(), 1)
	
	self.iranIADS:mergeContact(IADSContactFactory('Harrier Pilot'))
	lu.assertEquals(#self.iranIADS:getContacts(), 1)
	
	self.iranIADS:mergeContact(IADSContactFactory('test-in-firing-range-of-sa-2'))
	lu.assertEquals(#self.iranIADS:getContacts(), 2)
	
end

function TestIADS:testCleanAgedTargets()
	local iads = SkynetIADS:create()
	
	target1 = IADSContactFactory('test-in-firing-range-of-sa-2')
	function target1:getAge()
		return iads.maxTargetAge + 1
	end
	
	target2 = IADSContactFactory('test-distance-calculation')
	function target2:getAge()
		return 1
	end
	
	iads.contacts[1] = target1
	iads.contacts[2] = target2
	lu.assertEquals(#iads:getContacts(), 2)
	iads:cleanAgedTargets()
	lu.assertEquals(#iads:getContacts(), 1)
end

function TestIADS:testOnlyLoadGroupsWithPrefixForSAMSiteNotOtherUnitsOrStaticObjectsWithSamePrefix()
	self:tearDown()
	self.iranIADS = SkynetIADS:create()
	local calledPrint = false
	function self.iranIADS:printOutput(str, isWarning)
		calledPrint = true
	end
	self.iranIADS:addSAMSitesByPrefix('prefixtest')
	lu.assertEquals(#self.iranIADS:getSAMSites(), 1)
	lu.assertEquals(calledPrint, false)
end

function TestIADS:testOnlyLoadGroupsWithPrefixForSAMSiteNotOtherUnitsOrStaticObjectsWithSamePrefix2()
	self:tearDown()
	self.iranIADS = SkynetIADS:create()
	local calledPrint = false
	function self.iranIADS:printOutput(str, isWarning)
		calledPrint = true
	end
	--happened when the string.find method was not set to plain special characters messed up the regex pattern
	self.iranIADS:addSAMSitesByPrefix('IADS-EW')
	lu.assertEquals(#self.iranIADS:getSAMSites(), 1)
	lu.assertEquals(calledPrint, false)
end

function TestIADS:testOnlyLoadUnitsWithPrefixForEWSiteNotStaticObjectssWithSamePrefix()
	self:tearDown()
	self.iranIADS = SkynetIADS:create()
	local calledPrint = false
	function self.iranIADS:printOutput(str, isWarning)
		calledPrint = true
	end
	self.iranIADS:addEarlyWarningRadarsByPrefix('prefixewtest')
	lu.assertEquals(#self.iranIADS:getEarlyWarningRadars(), 1)
	lu.assertEquals(calledPrint, false)
end

function TestIADS:testDontPassShipsGroundUnitsAndStructuresToSAMSites()
	
	-- make sure we don't get any targets in the test mission
	local ewRadars = self.iranIADS:getEarlyWarningRadars()
	for i = 1, #ewRadars do
		local ewRadar = ewRadars[i]
		function ewRadar:getDetectedTargets()
			return {}
		end
	end
	
	
	local samSites = self.iranIADS:getSAMSites()
	for i = 1, #samSites do
		local samSite = samSites[i]
		function samSite:getDetectedTargets()
			return {}
		end
	end
	

	self.iranIADS:evaluateContacts()
	-- verifies we have a clean test setup
	lu.assertEquals(#self.iranIADS.contacts, 0)
	

	
	-- ground units should not be passed to the SAM	
	local mockContactGroundUnit = {}
	function mockContactGroundUnit:getDesc()
		return {category = Unit.Category.GROUND_UNIT}
	end
	function mockContactGroundUnit:getAge()
		return 0
	end
	
	
	table.insert(self.iranIADS.contacts, mockContactGroundUnit)
	
	local correlatedCalled = false
	function self.iranIADS:correlateWithSAMSites(contact)
		correlatedCalled = true
	end
	
	self.iranIADS:evaluateContacts()
	lu.assertEquals(correlatedCalled, false)
	lu.assertEquals(#self.iranIADS.contacts, 1)
	
	
	
	self.iranIADS.contacts = {}
	
	-- ships should not be passed to the SAM	
	local mockContactShip = {}
	function mockContactShip:getDesc()
		return {category = Unit.Category.SHIP}
	end
	function mockContactShip:getAge()
		return 0
	end
	
	table.insert(self.iranIADS.contacts, mockContactShip)
	
	correlatedCalled = false
	function self.iranIADS:correlateWithSAMSites(contact)
		correlatedCalled = true
	end
	self.iranIADS:evaluateContacts()
	lu.assertEquals(correlatedCalled, false)
	lu.assertEquals(#self.iranIADS.contacts, 1)
	
	self.iranIADS.contacts = {}
	
	-- aircraft should be passed to the SAM	
	local mockContactAirplane = {}
	function mockContactAirplane:getDesc()
		return {category = Unit.Category.AIRPLANE}
	end
	function mockContactAirplane:getAge()
		return 0
	end
	
	table.insert(self.iranIADS.contacts, mockContactAirplane)
	
	correlatedCalled = false
	function self.iranIADS:correlateWithSAMSites(contact)
	--	correlatedCalled = true
	end
	self.iranIADS:evaluateContacts()
	--TODO: FIX TEST
	--lu.assertEquals(correlatedCalled, true)
	lu.assertEquals(#self.iranIADS.contacts, 1)
	self.iranIADS.contacts = {}

end

function TestIADS:testWillSAMSitesWithNoCoverageGoAutonomous()
	self:tearDown()

	self.iranIADS = SkynetIADS:create()
	
	local autonomousSAM = self.iranIADS:addSAMSite('test-SAM-SA-2-test')
	local nonAutonomousSAM = self.iranIADS:addSAMSite('SAM-SA-6')
	local ewSAM = self.iranIADS:addSAMSite('SAM-SA-10'):setActAsEW(true)
	local sa15 = self.iranIADS:addSAMSite('SAM-SA-15-1')
	
	self.iranIADS:addEarlyWarningRadarsByPrefix('EW')
	
	lu.assertEquals(ewSAM:getAutonomousState(), false)
	lu.assertEquals(sa15:getAutonomousState(), false)
	lu.assertEquals(autonomousSAM:getAutonomousState(), false)
	lu.assertEquals(nonAutonomousSAM:getAutonomousState(), false)
	
	self.iranIADS:updateAutonomousStatesOfSAMSites()
	
	lu.assertEquals(autonomousSAM:getAutonomousState(), true)
	lu.assertEquals(nonAutonomousSAM:getAutonomousState(), false)
	lu.assertEquals(sa15:getAutonomousState(), false)
	lu.assertEquals(ewSAM:getAutonomousState(), false)
end

function TestIADS:testSAMSiteLoosesConnectionThenAddANewOneAgain()
	self:tearDown()
	self.iranIADS = SkynetIADS:create()
	local connectionNode = StaticObject.getByName('SA-6 Connection Node-autonomous-test')
	local nonAutonomousSAM = self.iranIADS:addSAMSite('SAM-SA-6'):addConnectionNode(connectionNode)
	self.iranIADS:addEarlyWarningRadarsByPrefix('EW')
	self.iranIADS:updateAutonomousStatesOfSAMSites()
	
	lu.assertEquals(nonAutonomousSAM:getAutonomousState(), false)
	trigger.action.explosion(connectionNode:getPosition().p, 500)
	lu.assertEquals(nonAutonomousSAM:getAutonomousState(), true)
	
	local connectionNodeReAdd = StaticObject.getByName('SA-6 Connection Node-autonomous-test-readd')
	nonAutonomousSAM:addConnectionNode(connectionNodeReAdd)
	lu.assertEquals(nonAutonomousSAM:getAutonomousState(), false)
	
end

function TestIADS:testBuildSAMSitesInCoveredArea()
	local iads = SkynetIADS:create()
	
	local mockSAM = {}
	local samCalled = false
	function mockSAM:updateSAMSitesInCoveredArea()
		samCalled = true
	end
	
	function iads:getSAMSites()
		return {mockSAM}
	end
	
	local mockEW = {}
	local ewCalled = false
	function mockEW:updateSAMSitesInCoveredArea()
		ewCalled = true
	end
	
	function iads:getEarlyWarningRadars()
		return {mockEW}
	end
	
	iads:buildSAMSitesInCoveredArea()
	
	lu.assertEquals(samCalled, true)
	lu.assertEquals(ewCalled, true)
	
end

function TestIADS:testGetSAMSitesByPrefix()
	self:setUp();
	local samSites = self.iranIADS:getSAMSitesByPrefix('SAM-SA-15')
	lu.assertEquals(#samSites, 3)
end

TestMooseA2ADispatcherConnector = {}

function TestMooseA2ADispatcherConnector:setUp()
	self.iads = SkynetIADS:create()
	self.connector = SkynetMooseA2ADispatcherConnector:create()
end

function TestMooseA2ADispatcherConnector:tearDown()
	self.iads:deactivate()
end

--finish this test:
function TestMooseA2ADispatcherConnector:testAddEWRadars()
	local ewRadar = self.iads:addEarlyWarningRadar('EW-west')
	local connectionNode = StaticObject.getByName('west Connection Node')
	ewRadar:addConnectionNode(connectionNode)
	
	local samSite = self.iads:addSAMSite('SAM-SA-6-2')
	
	self.connector:addIADS(self.iads)
	
	local ewRadarNames = self.connector:getEarlyWarningRadarGroupNames()
	lu.assertEquals(#ewRadarNames, 1)
	lu.assertEquals(ewRadarNames[1], 'EW-west-group-name')
	
	local samSiteNames = self.connector:getSAMSiteGroupNames()
	lu.assertEquals(#samSiteNames, 1)
	
	function samSite:hasWorkingPowerSource()
		return false
	end
	
	local samSiteNames = self.connector:getSAMSiteGroupNames()
	lu.assertEquals(#samSiteNames, 0)
	
function TestMooseA2ADispatcherConnector:testUpdateEWRadars()
	
end
--[[
	
	local mockSetGroup = {}
	
	function mockSetGroup:AddGroupsByName(name)
		lu.assertEquals(name, 'EW-west')
	end
	
	self.connector:setMooseGroup(mockSetGroup)
	self.connector:addIADS(self.iads)
	self.connector:update()
--]]
end

TestSamSites = {}

function TestSamSites:setUp()
	if self.samSiteName then
		self.skynetIADS = SkynetIADS:create()
		local samSite = Group.getByName(self.samSiteName)
		self.samSite = SkynetIADSSamSite:create(samSite, self.skynetIADS)
		
		-- we overrite this method since it returns radar contacts in the DCS world which mess up the tests.
		function self.samSite:getDetectedTargets()
			return {}
		end
		
		self.samSite:setupElements()
		self.samSite:goLive()
	end
end

function TestSamSites:tearDown()
	if self.samSite then	
		self.samSite:goDark()
		self.samSite:cleanUp()
	end
	if self.skynetIADS then
		self.skynetIADS:deactivate()
	end
	self.samSite = nil
	self.samSiteName = nil
end


function TestSamSites:testCheckOneGenericObjectAliveForUnitWorks()
	self.samSiteName = "SAM-SA-6-2"
	self:setUp()
	local unit = Unit.getByName('SAM-SA-6-2-connection-node-unit')
	self.samSite:addConnectionNode(unit)
	lu.assertEquals(self.samSite:genericCheckOneObjectIsAlive(self.samSite.connectionNodes), true)
	lu.assertEquals(self.samSite:hasActiveConnectionNode(), true)
	trigger.action.explosion(unit:getPosition().p, 1000)
	lu.assertEquals(self.samSite:genericCheckOneObjectIsAlive(self.samSite.connectionNodes), false)
	lu.assertEquals(self.samSite:hasActiveConnectionNode(), false)
end

function TestSamSites:testCheckOneGenericObjectAliveForStaticObjectsWorks()
	self.samSiteName = "SAM-SA-6-2"
	self:setUp()
	local static = StaticObject.getByName('SAM-SA-6-2-coonection-node-static')
	self.samSite:addConnectionNode(static)
	lu.assertEquals(self.samSite:genericCheckOneObjectIsAlive(self.samSite.connectionNodes), true)
	lu.assertEquals(self.samSite:hasActiveConnectionNode(), true)
	trigger.action.explosion(static:getPosition().p, 1000)
	lu.assertEquals(self.samSite:genericCheckOneObjectIsAlive(self.samSite.connectionNodes), false)
	lu.assertEquals(self.samSite:hasActiveConnectionNode(), false)
end


-- TODO: write test for updateMissilesInFlight in AbstractRadarElement
function TestSamSites:testUpdateMissilesInFlight()
	self.samSiteName = "SAM-SA-6-2"
	self:setUp()
	
	local mockMissile1 = {}
	function mockMissile1:isExist()
		return false
	end
	
	local mockMissile2 = {}
	function mockMissile2:isExist()
		return true
	end
	
	self.samSite.missilesInFlight = {mockMissile1, mockMissile2}
	lu.assertEquals(#self.samSite.missilesInFlight, 2)
	lu.assertEquals(self.samSite:hasMissilesInFlight(), true)
	
	self.samSite:updateMissilesInFlight()
	lu.assertEquals(#self.samSite.missilesInFlight, 1)
	lu.assertEquals(self.samSite:hasMissilesInFlight(), true)

	self.samSite.missilesInFlight = {mockMissile1}
	lu.assertEquals(#self.samSite.missilesInFlight, 1)
	lu.assertEquals(self.samSite:hasMissilesInFlight(), true)
	
	self.samSite:updateMissilesInFlight()
	lu.assertEquals(#self.samSite.missilesInFlight, 0)
	lu.assertEquals(self.samSite:hasMissilesInFlight(), false)
end

function TestSamSites:testCheckSA6GroupNumberOfLaunchersAndRangeValuesAndSearchRadarsAndNatoName()
--[[
	DCS properties SA-6 (Kub / Gainful) 
	
	Radar:
	{
		{
			{
				detectionDistanceAir={
					lowerHemisphere={headOn=46811.82421875, tailOn=46811.82421875},
					upperHemisphere={headOn=46811.82421875, tailOn=46811.82421875}
					upperHemisphere={headOn=46811.82421875, tailOn=46811.82421875}
				},
				type=1,
				typeName="Kub 1S91 str"
			}
		}
	}

	Launcher:
    {
        count=3,
        desc={
            Nmax=16,
            RCS=0.1059999987483,
            _origin="",
            altMax=8000,
            altMin=30,
            box={
                max={x=2.9061908721924, y=0.43574807047844, z=0.4395649433136},
                min={x=-2.9048342704773, y=-0.43574807047844, z=-0.4395649433136}
            },
            category=1,
            displayName="3M9M Kub (SA-6 Gainful)",
            fuseDist=12,
            guidance=4,
            life=2,
            missileCategory=2,
            rangeMaxAltMax=25000,
            rangeMaxAltMin=25000,
            rangeMin=4000,
            typeName="SA3M9M",
            warhead={caliber=330, explosiveMass=59, mass=59, type=1}
        }
    }
}
--]]
	self.samSiteName = "SAM-SA-6-2"
	self:setUp()
	lu.assertEquals(#self.samSite:getLaunchers(), 1)
	lu.assertEquals(#self.samSite:getSearchRadars(), 1)
	
	local searchRadar = self.samSite:getSearchRadars()[1]
	lu.assertEquals(searchRadar:getMaxRangeFindingTarget(), 46811.82421875)
	
	lu.assertEquals(self.samSite:getNatoName(), "SA-6")
	
	local launcher = self.samSite:getLaunchers()[1]
	lu.assertEquals(launcher:getRange(), 25000)
	
	lu.assertEquals(self.samSite:getRemainingNumberOfMissiles(), 3)
end

function TestSamSites:testCheckSA10GroupNumberOfLaunchersAndSearchRadarsAndNatoName()
--[[
	DCS properties SA-10 (S-300 / SA-10 Grumble)
	
	Radar:	
	{
		{
			{
				detectionDistanceAir={
					lowerHemisphere={headOn=106998.453125, tailOn=106998.453125},
					upperHemisphere={headOn=106998.453125, tailOn=106998.453125}
				},
				type=1,
				typeName="S-300PS 40B6M tr"
			}
		}
	}
	
	Launcher:
	{
		{
			count=4,
			desc={
				Nmax=25,
				RCS=0.17800000309944,
				_origin="",
				altMax=30000,
				altMin=25,
				box={
					max={x=3.6516976356506, y=0.81190091371536, z=0.81109911203384},
					min={x=-3.6131811141968, y=-0.80982387065887, z=-0.81062549352646}
				},
				category=1,
				displayName="5V55 S-300PS (SA-10B Grumble)",
				fuseDist=20,
				guidance=4,
				life=2,
				missileCategory=2,
				rangeMaxAltMax=75000,
				rangeMaxAltMin=40000,
				rangeMin=5000,
				typeName="SA5B55",
				warhead={caliber=508, explosiveMass=133, mass=133, type=1}
			}
		}
	}

--]]
	self.samSiteName = "SAM-SA-10"
	self:setUp()
	lu.assertEquals(#self.samSite:getLaunchers(), 2)
	lu.assertEquals(#self.samSite:getSearchRadars(), 2)
	lu.assertEquals(#self.samSite:getTrackingRadars(), 1)
	lu.assertEquals(#self.samSite:getRadars(), 3)
	lu.assertEquals(self.samSite:getNatoName(), "SA-10")
	
	local launchers = self.samSite:getLaunchers()
	local numLoops = 0
	-- seems like currently both launcher types of the SA-10 have the same range values
	for i = 1, #launchers do
		local launcher = launchers[i]
		lu.assertEquals(launcher:getInitialNumberOfMissiles(), 4)
		lu.assertEquals(launcher:getRange(), 75000)
		lu.assertEquals(launcher:getMaximumFiringAltitude(), 30000)
		numLoops = numLoops + 1
	end
	lu.assertEquals(numLoops, 2)
	
	local radars = self.samSite:getRadars()
	
	numLoops = 0
	-- seems like currently both radar types of the SA-10 have the same range values
	for  i = 1, #radars do
		local radar = radars[i]
		lu.assertEquals(radar:getMaxRangeFindingTarget(), 106998.453125)
		numLoops = numLoops + 1
	end
	lu.assertEquals(numLoops, 3)
end

function TestSamSites:testCheckSA3GroupNumberOfLaunchersAndRangeValuesAndSearchRadarsAndNatoName()
--[[
	DCS properties SA-3 (s-125 / SA-3 Goa)
	
	Radar:
	{
        {
            detectionDistanceAir={
                lowerHemisphere={headOn=106998.453125, tailOn=106998.453125},
                upperHemisphere={headOn=106998.453125, tailOn=106998.453125}
            },
            type=1,
            typeName="p-19 s-125 sr"
        }
    }
	
	Launcher:
	{
		{
			count=4,
			desc={
				Nmax=16,
				RCS=0.1676000058651,
				_origin="",
				altMax=18000,
				altMin=20,
				box={
					max={x=3.7270171642303, y=0.94484841823578, z=0.95312494039536},
					min={x=-2.6432721614838, y=-0.94484841823578, z=-0.95312494039536}
				},
				category=1,
				displayName="5V27 S-125 Neva (SA-3 Goa)",
				fuseDist=14,
				guidance=4,
				life=2,
				missileCategory=2,
				rangeMaxAltMax=25000,
				rangeMaxAltMin=11000,
				rangeMin=3500,
				typeName="SA5B27",
				warhead={caliber=400, explosiveMass=60, mass=60, type=1}
			}
		}
	}
	
--]]
	self.samSiteName = "test-SA-3"
	self:setUp()
	
	local array = {}
	local unitData = {
		['p-19 s-125 sr'] = {
		},
	}
	self.samSite:analyseAndAddUnit(SkynetIADSSAMSearchRadar, array, unitData)
	local searchRadar = array[1]
	lu.assertEquals(#array, 1)
	lu.assertEquals(searchRadar:getMaxRangeFindingTarget(), 106998.453125)
	
	array = {}
	unitData = {
		['5p73 s-125 ln'] = {
		},
	}
	self.samSite:analyseAndAddUnit(SkynetIADSSAMLauncher, array, unitData)
	local launcher = array[1]
	lu.assertEquals(launcher:getRange(), 25000)
	lu.assertEquals(launcher:getMaximumFiringAltitude(), 18000)
	array = {}
	unitData = {
		['snr s-125 tr'] = {
		},
	}	
	self.samSite:analyseAndAddUnit(SkynetIADSSAMTrackingRadar, array, unitData)
	local searchRadar = array[1]
	lu.assertEquals(searchRadar:getMaxRangeFindingTarget(),  106998.453125)
	
	lu.assertEquals(#self.samSite:getLaunchers(), 1)	
	lu.assertEquals(#self.samSite:getSearchRadars(), 1)
	lu.assertEquals(#self.samSite:getTrackingRadars(), 1)
	lu.assertEquals(#self.samSite:getRadars(), 2)
	lu.assertEquals(self.samSite:getHARMDetectionChance(), 40)
	lu.assertEquals(self.samSite:setHARMDetectionChance(100), self.samSite)
	
	lu.assertEquals(self.samSite:getNatoName(), "SA-3")
end

function TestSamSites:testShilkaGroupLaunchersSearchRadarRangesAndHARMDefenceChance()
	--[[
	
	DCS Properties Shilka / Zues:
	
	Radar:	
	{
        {
            detectionDistanceAir={
                lowerHemisphere={headOn=5015.552734375, tailOn=5015.552734375},
                upperHemisphere={headOn=5015.552734375, tailOn=5015.552734375}
            },
            type=1,
            typeName="ZSU-23-4 Shilka"
        }
    }
		
		
	Launcher:
	{
		{
			count=503,
			desc={
				_origin="",
				box={
					max={x=2.2344591617584, y=0.12504191696644, z=0.12113922089338},
					min={x=-6.61008644104, y=-0.12504199147224, z=-0.12113920599222}
				},
				category=0,
				displayName="23mm AP",
				life=2,
				typeName="weapons.shells.2A7_23_AP",
				warhead={caliber=23, explosiveMass=0, mass=0.189, type=0}
			}
		},
		{
			count=1501,
			desc={
				_origin="",
				box={
					max={x=2.2344591617584, y=0.12504191696644, z=0.12113922089338},
					min={x=-6.61008644104, y=-0.12504199147224, z=-0.12113920599222}
				},
				category=0,
				displayName="23mm HE",
				life=2,
				typeName="weapons.shells.2A7_23_HE",
				warhead={caliber=23, explosiveMass=0.189, mass=0.189, type=1}
			}
		}
	}
	--]]
	self.samSiteName = "SAM-Shilka"
	self:setUp()
	lu.assertEquals(self.samSite:getHARMDetectionChance(), 10)
	lu.assertEquals(#self.samSite:getRadars(),1)
	lu.assertEquals(#self.samSite:getLaunchers(), 1)
	lu.assertEquals(#self.samSite:getTrackingRadars(), 0)
	local searchRadar = self.samSite:getSearchRadars()[1]
	
	lu.assertEquals(searchRadar:getMaxRangeFindingTarget(), 5015.552734375)
	
	local target = IADSContactFactory("Harrier Pilot")
	
	local launcher = self.samSite:getLaunchers()[1]
	
	--shilka has no missiles
	lu.assertEquals(launcher:getInitialNumberOfMissiles(), 0)
	lu.assertEquals(launcher:getRemainingNumberOfMissiles(), 0)
	
	lu.assertEquals(#launcher:getDCSRepresentation():getAmmo(), 2)
	
	lu.assertEquals(launcher:getInitialNumberOfShells(), 2004)
	lu.assertEquals(launcher:getRemainingNumberOfShells(), 2004)
	
	lu.assertEquals(launcher:getRange(), 5015.552734375)
	--dcs has no maximum height data for AAA
	lu.assertEquals(launcher:getMaximumFiringAltitude(), 0)
	lu.assertEquals(launcher:isWithinFiringHeight(target), true)
	lu.assertEquals(mist.utils.round(launcher:getHeight(target)), 1910)

	--this target is at 25k feet
	local target = IADSContactFactory("test-not-in-firing-range-of-sa-2")
	lu.assertEquals(launcher:isWithinFiringHeight(target), false)
end

function TestSamSites:testShutDownShilkaWhenOutOfAmmo()
	local launcherData =
	{
		{
			count=503,
			desc={
				_origin="",
				box={
					max={x=2.2344591617584, y=0.12504191696644, z=0.12113922089338},
					min={x=-6.61008644104, y=-0.12504199147224, z=-0.12113920599222}
				},
				category=0,
				displayName="23mm AP",
				life=2,
				typeName="weapons.shells.2A7_23_AP",
				warhead={caliber=23, explosiveMass=0, mass=0.189, type=0}
			}
		},
		{
			count=1501,
			desc={
				_origin="",
				box={
					max={x=2.2344591617584, y=0.12504191696644, z=0.12113922089338},
					min={x=-6.61008644104, y=-0.12504199147224, z=-0.12113920599222}
				},
				category=0,
				displayName="23mm HE",
				life=2,
				typeName="weapons.shells.2A7_23_HE",
				warhead={caliber=23, explosiveMass=0.189, mass=0.189, type=1}
			}
		}
	}

	self.samSiteName = "SAM-Shilka"
	self:setUp()

	local launcher = self.samSite:getLaunchers()[1]

	local mockDCSObjcect = {}
	function mockDCSObjcect:getAmmo()
		launcherData[1].count = 300
		launcherData[2].count = 200
		return launcherData
	end
	---simulate firing of 1 missile
	function launcher:getDCSRepresentation()
		return mockDCSObjcect
	end

	
	lu.assertEquals(launcher:getInitialNumberOfShells(), 2004)
	lu.assertEquals(launcher:getRemainingNumberOfShells(), 500)
	lu.assertEquals(self.samSite:getInitialNumberOfShells(), 2004)
	lu.assertEquals(self.samSite:getRemainingNumberOfShells(), 500)
	lu.assertEquals(self.samSite:hasRemainingAmmo(), true)
	
	lu.assertEquals(self.samSite:isActive(), true)
	self.samSite:goDarkIfOutOfAmmo()
	lu.assertEquals(self.samSite:isActive(), true)
	
	local mockDCSObjcect = {}
	function mockDCSObjcect:getAmmo()
		launcherData[1].count = 0
		launcherData[2].count = 0
		return launcherData
	end
	---simulate firing of 1 missile
	function launcher:getDCSRepresentation()
		return mockDCSObjcect
	end
	
	lu.assertEquals(launcher:getInitialNumberOfShells(), 2004)
	lu.assertEquals(launcher:getRemainingNumberOfShells(), 0)
	lu.assertEquals(self.samSite:getInitialNumberOfShells(), 2004)
	lu.assertEquals(self.samSite:getRemainingNumberOfShells(), 0)
	lu.assertEquals(self.samSite:hasRemainingAmmo(), false)
	
	lu.assertEquals(self.samSite:isActive(), true)
	self.samSite:goDarkIfOutOfAmmo()
	lu.assertEquals(self.samSite:isActive(), false)
	
end

function TestSamSites:testSA15LaunchersSearchRadarRangeAndHARMDefenceChance()
	--[[ 
	DCS SA-15: properties:
	Launcher
    {
        count=8,
        desc={
            Nmax=30,
            RCS=0.03070000000298,
            _origin="",
            altMax=6000,
            altMin=10,
            box={
                max={x=1.8263295888901, y=0.26701140403748, z=0.26600670814514},
                min={x=-1.678077340126, y=-0.26701140403748, z=-0.26600670814514}
            },
            category=1,
            displayName="9M330 Tor (SA-15 Gauntlet)",
            fuseDist=7,
            guidance=4,
            life=2,
            missileCategory=2,
            rangeMaxAltMax=12000,
            rangeMaxAltMin=12000,
            rangeMin=1500,
            typeName="SA9M330",
            warhead={caliber=220, explosiveMass=14.5, mass=14.5, type=1}
        }
    }
	
	Radar:
{
    0={{opticType=0, type=0, typeName="generic SAM search visir"}},
    {
        {
            detectionDistanceAir={
                lowerHemisphere={headOn=16718.5078125, tailOn=16718.5078125},
                upperHemisphere={headOn=16718.5078125, tailOn=16718.5078125}
            },
            type=1,
            typeName="Tor 9A331"
        }
    }
}	--]]

	self.samSiteName = "SAM-SA-15"
	self:setUp()

	lu.assertEquals(self.samSite:getHARMDetectionChance(), 0)
	lu.assertEquals(#self.samSite:getRadars(),1)	
	
	local target = IADSContactFactory("Harrier Pilot")
	
	local searchRadar = self.samSite:getSearchRadars()[1]
	lu.assertEquals(searchRadar:getMaxRangeFindingTarget(), 16718.5078125)
	lu.assertEquals(searchRadar:isInRange(target), false)
	
	lu.assertEquals(#self.samSite:getSearchRadars(), 1)
	lu.assertEquals(#self.samSite:getTrackingRadars(), 0)
	lu.assertEquals(#self.samSite:getLaunchers(), 1)
	
	local launcher = self.samSite:getLaunchers()[1]
	lu.assertEquals(launcher:getRange(), 12000)
	lu.assertEquals(launcher:getMaximumFiringAltitude(), 6000)
	
	lu.assertEquals(launcher:isInRange(target), false)

	lu.assertEquals(mist.utils.round(launcher:getHeight(target)), 1930)
	lu.assertEquals(launcher:getMaximumFiringAltitude(), 6000)
	lu.assertEquals(launcher:isWithinFiringHeight(target), true)
	lu.assertEquals(launcher:getRemainingNumberOfMissiles(), 8)
	
	launcher.maximumFiringAltitude = 400
	lu.assertEquals(launcher:isWithinFiringHeight(target), false)
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

function TestSamSites:testSA13LaunchersSearchRadarRangeAndHARMDefence()
--[[
DCS SA-13 Properties (Strela-10M3 / Gopher):
{
    {
        count=8,
        desc={
            Nmax=16,
            RCS=0.050000000745058,
            _origin="",
            altMax=3500,
            altMin=25,
            box={
                max={x=1.1227556467056, y=0.13098473846912, z=0.13213211297989},
                min={x=-1.1213990449905, y=-0.13098473846912, z=-0.13213211297989}
            },
            category=1,
            displayName="9M333 Strela-10 (SA-13 Gopher)",
            fuseDist=3,
            guidance=2,
            life=2,
            missileCategory=2,
            rangeMaxAltMax=5000,
            rangeMaxAltMin=5000,
            rangeMin=800,
            typeName="SA9M333",
            warhead={caliber=120, explosiveMass=3.5, mass=3.5, type=1}
        }
    },
    {
	count=1009,
        desc={
            _origin="",
            box={
                max={x=2.2344591617584, y=0.12504191696644, z=0.12113922089338},
                min={x=-6.61008644104, y=-0.12504199147224, z=-0.12113920599222}
            },
            category=0,
            displayName="7.62mm",
            life=2,
            typeName="weapons.shells.7_62x54",
            warhead={caliber=7.62, explosiveMass=0, mass=0.0119, type=0}
        }
    }
	Does not have any Radar Properties in DCS
--]]

	self.samSiteName = "SAM-SA-13"
	self:setUp()
	lu.assertEquals(#self.samSite:getRadars(), 1)
	lu.assertEquals(#self.samSite:getSearchRadars(), 1)
	lu.assertEquals(#self.samSite:getTrackingRadars(), 0)
	lu.assertEquals(#self.samSite:getLaunchers(), 1)
	
	local searchRadar = self.samSite:getSearchRadars()[1]
	
	--this asset has no radar sensor information, we load the launcher data instead, to keep interface consistent:
	lu.assertEquals(searchRadar:getDCSRepresentation():getSensors(), nil)
	lu.assertEquals(searchRadar:getMaxRangeFindingTarget(), 5000)
	
	local launcher = self.samSite:getLaunchers()[1]
	lu.assertEquals(launcher:getRange(), 5000)
	lu.assertEquals(launcher:getMaximumFiringAltitude(), 3500)
	lu.assertEquals(launcher:getRemainingNumberOfMissiles(), 8)
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

function TestSamSites:testCompleteDestructionOfSamSiteAndLoadDestroyedSAMSiteInToIADS()
	local iads = SkynetIADS:create()
	local samSite = iads:addSAMSite("Destruction-test-sam"):setActAsEW(true)
	local samSite2 = iads:addSAMSite('prefixtest-sam')
	lu.assertEquals(samSite2:getAutonomousState(), false)
	lu.assertEquals(samSite:isDestroyed(), false)
	lu.assertEquals(samSite:hasWorkingRadar(), true)
	lu.assertEquals(#iads:getUsableSAMSites(), 2)
	local radars = samSite:getRadars()
	for i = 1, #radars do
		local radar = radars[i]
		trigger.action.explosion(radar:getDCSRepresentation():getPosition().p, 500)
	end	
	local launchers = samSite:getLaunchers()
	for i = 1, #launchers do
		local launcher = launchers[i]
		trigger.action.explosion(launcher:getDCSRepresentation():getPosition().p, 900)
	end	
	lu.assertEquals(samSite:isActive(), false)
	lu.assertEquals(samSite:isDestroyed(), true)
	lu.assertEquals(samSite:hasWorkingRadar(), false)
	lu.assertEquals(#iads:getDestroyedSAMSites(), 1)
	lu.assertEquals(#iads:getUsableSAMSites(), 1)
	lu.assertEquals(samSite:getRemainingNumberOfMissiles(), 0)
	lu.assertEquals(samSite:getInitialNumberOfMissiles(), 6)
	lu.assertEquals(samSite:hasRemainingAmmo(), false)
	
	--after destruction of samSite acting as EW samSite2 must be autonomous:
	lu.assertEquals(samSite2:getAutonomousState(), true)
	
	--test build SAM with destroyed elements
	self.samSiteName = "Destruction-test-sam"
	self:setUp()
	lu.assertEquals(self.samSite:getNatoName(), "SA-6")
	lu.assertEquals(#self.samSite:getRadars(), 3)
	lu.assertEquals(#self.samSite:getLaunchers(), 2)
	iads:deactivate()
end	

function TestSamSites:testHARMDefenceStates()
	self.samSiteName = "SAM-SA-6"
	self:setUp()
	lu.assertEquals(self.samSite:isActive(), true)
	lu.assertEquals(self.samSite:isScanningForHARMs(), true)
	self.samSite:goSilentToEvadeHARM()
	lu.assertEquals(self.samSite:isScanningForHARMs(), false)
	lu.assertEquals(self.samSite:isActive(), false)
end

function TestSamSites:testGoLiveFailsWhenInHARMDefenceMode()
	self.samSiteName = "SAM-SA-6"
	self:setUp()
	lu.assertEquals(self.samSite:isActive(), true)
	lu.assertEquals(self.samSite:isScanningForHARMs(), true)
	self.samSite:goSilentToEvadeHARM()
	lu.assertEquals(self.samSite:isActive(), false)
	self.samSite:goLive()
	lu.assertEquals(self.samSite:isActive(), false)
end


function TestSamSites:testHARMTimeToImpactCalculation()
	self.samSiteName = "SAM-SA-6"
	self:setUp()
	lu.assertEquals(self.samSite:getSecondsToImpact(100, 10), 36000)
	lu.assertEquals(self.samSite:getSecondsToImpact(10, 400), 90)
	lu.assertEquals(self.samSite:getSecondsToImpact(0, 400), 0)
	lu.assertEquals(self.samSite:getSecondsToImpact(400, 0), 0)
end

function TestSamSites:testEvaluateIfTargetsContainHARMsShallReactTrue()
	self.samSiteName = "SAM-SA-6-2"
	self:setUp()
	
	local iadsContact = IADSContactFactory("test-distance-calculation")
	
	local calledShutdown = false
	
	function self.samSite:getDetectedTargets()
		return {iadsContact}
	end
	function self.samSite:getDistanceInMetersToContact(a, b)
		return 50
	end
	function self.samSite:calculateImpactPoint(a, b)
		return self:getRadars()[1]:getPosition().p
	end
	
	function self.samSite:shallReactToHARM()
		return true
	end
	
	function self.samSite:goSilentToEvadeHARM()
		calledShutdown = true
	end
	
	lu.assertEquals(#self.samSite:getRadars(), 1)
	self.samSite:evaluateIfTargetsContainHARMs()
	lu.assertEquals(calledShutdown, false)
	lu.assertEquals(self.samSite.objectsIdentifiedAsHarms[iadsContact:getName()]['target'], iadsContact)
	lu.assertEquals(self.samSite.objectsIdentifiedAsHarms[iadsContact:getName()]['count'], 1)
	self.samSite:evaluateIfTargetsContainHARMs()
	lu.assertEquals(self.samSite.objectsIdentifiedAsHarms[iadsContact:getName()]['count'], 2)
	lu.assertEquals(calledShutdown, true)
end


function TestSamSites:testNoErrorTriggeredWhenRadarUnitDestroyedAndHARMDefenceIsRunning()
	
	self.samSiteName = "SAM-SA-6-2"
	self:setUp()
	
	local iadsContact = IADSContactFactory("test-distance-calculation")
	
	local calledPosition = false
	
	function self.samSite:getDetectedTargets()
		return {iadsContact}
	end
	
	local radar = self.samSite:getRadars()[1]
	
	--simulate a destroyed radar:
	function radar:isExist()
		return false
	end
	
	--a destroyed radar returns nil for its position:
	function radar:getPosition()
		calledPosition = true
		self:getDCSRepresentation():getPosition()
	end
	
	lu.assertEquals(#self.samSite:getRadars(), 1)
	self.samSite:evaluateIfTargetsContainHARMs()
	lu.assertEquals(calledPosition, false)
end

function TestSamSites:testEvaluateIfTargetsContainHARMsShallReactFalse()
	self.samSiteName = "SAM-SA-6-2"
	self:setUp()
	
	local iadsContact = IADSContactFactory("test-distance-calculation")
	
	local calledShutdown = false
	
	function self.samSite:getDetectedTargets()
		return {iadsContact}
	end
	function self.samSite:getDistanceInMetersToContact(a, b)
		return 50
	end
	function self.samSite:calculateImpactPoint(a, b)
		return self:getRadars()[1]:getPosition().p
	end
	
	function self.samSite:shallReactToHARM()
		return false
	end
	
	function self.samSite:goSilentToEvadeHARM()
		calledShutdown = true
	end
	
	lu.assertEquals(#self.samSite:getRadars(), 1)
	self.samSite:evaluateIfTargetsContainHARMs()
	lu.assertEquals(calledShutdown, false)
	lu.assertEquals(self.samSite.objectsIdentifiedAsHarms[iadsContact:getName()]['target'], iadsContact)
	lu.assertEquals(self.samSite.objectsIdentifiedAsHarms[iadsContact:getName()]['count'], 1)
	self.samSite:evaluateIfTargetsContainHARMs()
	lu.assertEquals(self.samSite.objectsIdentifiedAsHarms[iadsContact:getName()]['count'], 2)
	lu.assertEquals(calledShutdown, false)
end

function TestSamSites:testSlantRangeCalculationForHARMDefence()
	self.samSiteName = "SAM-SA-6-2"
	self:setUp()
	local iadsContact = IADSContactFactory("test-distance-calculation")
	local radarUnit = self.samSite:getRadars()[1]
	local distanceSlantRange = self.samSite:getDistanceInMetersToContact(iadsContact, radarUnit:getPosition().p)
	local straightLine = mist.utils.round(mist.utils.get2DDist(radarUnit:getPosition().p, iadsContact:getPosition().p), 0)
	lu.assertEquals(distanceSlantRange > straightLine, true)
end

function TestSamSites:testFinishHARMDefence()
	self.samSiteName = "SAM-SA-6-2"
	self:setUp()
	self.samSite:goSilentToEvadeHARM()
	lu.assertEquals(self.samSite:isActive(), false)
	self.samSite:finishHarmDefence()
	self.samSite:goLive()
	lu.assertEquals(self.samSite:isActive(), true)
end

function TestSamSites:testShutDownWhenOutOfMissiles()
	self.samSiteName = "SAM-SA-6-2"
	self:setUp()
	
	local launcher = self.samSite:getLaunchers()[1]
	lu.assertEquals(launcher:getInitialNumberOfMissiles(), 3)
	lu.assertEquals(launcher:getRemainingNumberOfMissiles(), 3)
	lu.assertEquals(self.samSite:getInitialNumberOfMissiles(), 3)
	lu.assertEquals(self.samSite:getRemainingNumberOfMissiles(), 3)
	
	local launcherData =
		{
			{
				count=3,
				desc={
					Nmax=16,
					RCS=0.1059999987483,
					_origin="",
					altMax=8000,
					altMin=30,
					box={
						max={x=2.9061908721924, y=0.43574807047844, z=0.4395649433136},
						min={x=-2.9048342704773, y=-0.43574807047844, z=-0.4395649433136},
					},
					category=1,
					displayName="3M9M Kub (SA-6 Gainful)",
					fuseDist=12,
					guidance=4,
					life=2,
					missileCategory=2,
					rangeMaxAltMax=25000,
					rangeMaxAltMin=25000,
					rangeMin=4000,
					typeName="SA3M9M",
					warhead={caliber=330, explosiveMass=59, mass=59, type=1},
				}
			}
		}

	local mockDCSObjcect = {}
	function mockDCSObjcect:getAmmo()
		launcherData[1].count = 2
		return launcherData
	end
	---simulate firing of 1 missile
	function launcher:getDCSRepresentation()
		return mockDCSObjcect
	end

	lu.assertEquals(launcher:getInitialNumberOfMissiles(), 3)
	lu.assertEquals(launcher:getRemainingNumberOfMissiles(), 2)
	lu.assertEquals(self.samSite:getInitialNumberOfMissiles(), 3)
	lu.assertEquals(self.samSite:getRemainingNumberOfMissiles(), 2)
	lu.assertEquals(self.samSite:hasRemainingAmmo(), true)
	
	self.samSite:goDarkIfOutOfAmmo()
	lu.assertEquals(self.samSite:isActive(), true )
	
	function mockDCSObjcect:getAmmo()
		launcherData[1].count = 1
		return launcherData
	end
	
	lu.assertEquals(launcher:getInitialNumberOfMissiles(), 3)
	lu.assertEquals(launcher:getRemainingNumberOfMissiles(), 1)
	lu.assertEquals(self.samSite:getInitialNumberOfMissiles(), 3)
	lu.assertEquals(self.samSite:getRemainingNumberOfMissiles(), 1)
	lu.assertEquals(self.samSite:hasRemainingAmmo(), true)
	
	self.samSite:goDarkIfOutOfAmmo()
	lu.assertEquals(self.samSite:isActive(), true )
	
	--DCS missile info is nil when no ammo is remaining
	function mockDCSObjcect:getAmmo()
		return nil
	end
	lu.assertEquals(launcher:getInitialNumberOfMissiles(), 3)
	lu.assertEquals(launcher:getRemainingNumberOfMissiles(), 0)
	lu.assertEquals(self.samSite:getInitialNumberOfMissiles(), 3)
	lu.assertEquals(self.samSite:getRemainingNumberOfMissiles(), 0)
	lu.assertEquals(self.samSite:hasRemainingAmmo(), false)
	
	self.samSite:goDarkIfOutOfAmmo()
	lu.assertEquals(self.samSite:isActive(), false )
	self.samSite:goLive()
	lu.assertEquals(self.samSite:isActive(), false )
end

function TestSamSites:testActAsEarlyWarningRadar()
	self.samSiteName = "SAM-SA-6"
	self:setUp()
	self.samSite:goDark()
	lu.assertEquals(self.samSite:isActive(), false)
	self.samSite:setActAsEW(true)
	lu.assertEquals(self.samSite:isActive(), true)
	self.samSite:targetCycleUpdateEnd()
	
	-- SAM Site should not shut down when out of ammo and in EW Mode
	function self.samSite:getRemainingNumberOfMissiles()
		return 0
	end
	
	self.samSite:goDarkIfOutOfAmmo()
	lu.assertEquals(self.samSite:isActive(), true)
	
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

function TestSamSites:testInformOfContactMultipleTimesOnlyOneIsTargetInRangeCall()
	self.samSiteName = "SAM-SA-6"
	self:setUp()
	
	local mockContact = {}
	
	local numTimesCalledTargetInRange = 0
	
	function self.samSite:isTargetInRange(target)
		numTimesCalledTargetInRange = numTimesCalledTargetInRange + 1
		lu.assertIs(target, mockContact)
		return true
	end
	self.samSite:targetCycleUpdateStart()
	self.samSite:informOfContact(mockContact)
	self.samSite:informOfContact(mockContact)
	lu.assertEquals(numTimesCalledTargetInRange, 1)
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

function TestSamSites:testSA2InformOfContactTargetInRangeMethod()
	self.samSiteName = "SAM-SA-2"
	self:setUp()
	--DCS AI radar instantly detects contact in test, so Site will not go dark, therefore we overwrite the method in this test
	function self.samSite:getDetectedTargets()
		return {}
	end
	self.samSite:goDark()
	lu.assertEquals(self.samSite:isActive(), false)
	local target = IADSContactFactory('test-in-firing-range-of-sa-2')
	
	self.samSite:informOfContact(target)
	local searchRadar = self.samSite:getSearchRadars()[1]
	lu.assertEquals(searchRadar:getTypeName(), 'p-19 s-125 sr')
	local sensors = Unit.getByName('Unit #005'):getSensors()
	lu.assertEquals(searchRadar:getMaxRangeFindingTarget(), 106998.453125)

	local launcher = self.samSite:getLaunchers()[1]
	lu.assertEquals(launcher:getRange(), 40000)
	
	local trackingRadar = self.samSite:getTrackingRadars()[1]
	--in its current implementation the SA-2 tracking radar returns the values of the search radar, I presume its only a placeholder in DCS
	lu.assertEquals(trackingRadar:getMaxRangeFindingTarget(), 106998.453125)	
		
	lu.assertEquals(self.samSite:isActive(), true)
	lu.assertEquals(self.samSite:isTargetInRange(target), true)
end

function TestSamSites:testSA2WillNotGoDarkIfTargetIsInRange()
	self.samSiteName = "SAM-SA-2"
	self:setUp()

	local target = IADSContactFactory('test-in-firing-range-of-sa-2')
	--we return a detected target, to pervent SAM site going dark
	function self.samSite:getDetectedTargets()
		local targets = {}
		table.insert(targets, target)
		return targets
	end

	self.samSite:informOfContact(target)
	self.samSite:goDark()
	lu.assertEquals(self.samSite:isActive(), true)
end

function TestSamSites:testSA2WillNotGoDarkIfOutOfMisslesAndMissilesAreStillInFlight()
	self.samSiteName = "SAM-SA-2"
	self:setUp()
	lu.assertEquals(self.samSite:hasMissilesInFlight(), false)
	
	local mockMissileInFlight = {}
	function mockMissileInFlight:isExist()
		return true
	end
	local missiles = {}
	table.insert(missiles, mockMissileInFlight)
	self.samSite.missilesInFlight = missiles
	lu.assertEquals(self.samSite:hasMissilesInFlight(), true)
	lu.assertEquals(#self.samSite:getDetectedTargets(), 0)
	lu.assertEquals(self.samSite:isActive(), true)
	self.samSite:goDark()
	lu.assertEquals(self.samSite:isActive(), true)
end

function TestSamSites:testSA2WillGoDarkWithTargetsInRangeAndHARMDetected()
	self.samSiteName = "SAM-SA-2"
	self:setUp()
	
	local target = IADSContactFactory('test-in-firing-range-of-sa-2')
	function self.samSite:getDetectedTargets()
		local targets = {}
		table.insert(targets, target)
		return targets
	end
	
	self.samSite:informOfContact(target)
	self.samSite:goSilentToEvadeHARM(5)
	self.samSite:goDark()
	lu.assertEquals(self.samSite:isActive(), false)
end

function TestSamSites:testSA2WillgoDarkIfOutOfAmmoNoMissilesAreInFlightAndTargetStillInRange()
	self.samSiteName = "SAM-SA-2"
	self:setUp()
	
	local target = IADSContactFactory('test-in-firing-range-of-sa-2')
	function self.samSite:getDetectedTargets()
		local targets = {}
		table.insert(targets, target)
		return targets
	end
	
	function self.samSite:getRemainingNumberOfMissiles()
		return 0
	end
	
	local mockMissileInFlight = {}
	function mockMissileInFlight:isExist()
		return false
	end
	local missiles = {}
	lu.assertEquals(self.samSite:hasMissilesInFlight(), false)
	lu.assertEquals(self.samSite:getRemainingNumberOfMissiles(), 0)
	lu.assertEquals(self.samSite:isActive(), true)
	self.samSite:goDark()
	lu.assertEquals(self.samSite:isActive(), false)
end

--TODO: write test case: SAM is out of missiles, is currently dark, is informed of a target in range has not detected it with its own radar is not in harm defence mode
function TestSamSites:testSA2OutOfMissilesNoMissilesInFlightIsInformedOfTargetByIADSHasNotDetectedTargetWithOwnRadar()
	self.samSiteName = "SAM-SA-2"
	self:setUp()
	
	function self.samSite:getDetectedTargets()
		return {}
	end
	
	function self.samSite:getRemainingNumberOfMissiles()
		return 0
	end
	
	
	self.samSite:goDark()
	lu.assertEquals(self.samSite:hasMissilesInFlight(), false)
	lu.assertEquals(self.samSite:isActive(), false)
	
	local target = IADSContactFactory('test-in-firing-range-of-sa-2')
	self.samSite:informOfContact(target)
	lu.assertEquals(self.samSite:isActive(), false)
	
end

function TestSamSites:testSA2InformOfContactTargetNotInRange()
	self.samSiteName = "test-SAM-SA-2-test"
	self:setUp()
	self.samSite:goDark()
	local target = IADSContactFactory('test-not-in-firing-range-of-sa-2')
	self.samSite:informOfContact(target)
	lu.assertEquals(self.samSite:isTargetInRange(target), false)
	lu.assertEquals(self.samSite:isActive(), false)
end

function TestSamSites:testSA2InforOfContactInSearchRangeSAMSiteGoLiveWhenSetToSearchRange()
	self.samSiteName = "test-SAM-SA-2-test"
	self:setUp()
	self.samSite:goDark()
	lu.assertEquals(self.samSite:isActive(), false)
	--lu.assertIs(self.samSite:getEngagementZone(), SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
	--self.samSite.goLiveRange = nil
	self.samSite:setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
	lu.assertIs(self.samSite:getEngagementZone(), SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
	local target = IADSContactFactory('test-not-in-firing-range-of-sa-2')
	self.samSite:informOfContact(target)
	lu.assertEquals(self.samSite:isActive(), true)
	lu.assertEquals(self.samSite:isTargetInRange(target), true)
end

function TestSamSites:testSA2GoLiveRangeInPercentInKillZone()
	self.samSiteName = "SAM-SA-2"
	self:setUp()
	lu.assertIs(self.samSite:getEngagementZone(), SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
	self.samSite:setGoLiveRangeInPercent(60)
	
	local target = IADSContactFactory('test-in-firing-range-of-sa-2')
	
	local launcher = self.samSite:getLaunchers()[1]
	lu.assertEquals(launcher:isInRange(target), false)
	lu.assertEquals(self.samSite:isTargetInRange(target), false)
end

function TestSamSites:testSA2GoLiveRangeInPercentSearchRange()
	self.samSiteName = "test-SAM-SA-2-test-2"
	self:setUp()
	self.samSite:setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
	self.samSite:setGoLiveRangeInPercent(80)
	
	local target = IADSContactFactory('test-outer-search-range')

	local radars = self.samSite:getSearchRadars()
	for i = 1, #radars do
		local radar = radars[i]
		lu.assertEquals(radar:isInRange(target), false)
	end
	lu.assertEquals(self.samSite:isTargetInRange(target), false)
end


function TestSamSites:testSA8GoLiveRangeInPercent()	
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

function TestSamSites:testDaisychainSAMOptions()
	self.samSiteName = "SAM-SA-11"
	self:setUp()
	local powerSource = StaticObject.getByName('SA-11-power-source')
	local connectionNode = StaticObject.getByName('SA-11-connection-node')
	local returnValue = self.samSite:setActAsEW(true):addPowerSource(powerSource):addConnectionNode(connectionNode):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE):setGoLiveRangeInPercent(90):setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK)
	lu.assertIs(self.samSite, returnValue)
	lu.assertEquals(self.samSite:getActAsEW(), true)
	lu.assertEquals(self.samSite:getEngagementZone(), SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
	lu.assertEquals(self.samSite:getGoLiveRangeInPercent(), 90)
	lu.assertEquals(self.samSite:getAutonomousBehaviour(), SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK)
	lu.assertIs(self.samSite:getConnectionNodes()[1], connectionNode)
	lu.assertIs(self.samSite:getPowerSources()[1], powerSource)
end

function TestSamSites:testPointDefenceWhenOnlyOneEWRadarIsActive()
	self.samSiteName = "SAM-SA-10"
	self:setUp()
	self.samSite:setActAsEW(true)
	
	local sa15 = Group.getByName("SAM-SA-15-1")
	local pointDefence = SkynetIADSSamSite:create(sa15, self.skynetIADS)
	pointDefence:setupElements()
	pointDefence:goLive()
	pointDefence:goDark()
	lu.assertEquals(self.samSite:addPointDefence(pointDefence), self.samSite)
	lu.assertEquals(#self.samSite:getPointDefences(), 1)
	
	self.samSite:goSilentToEvadeHARM()
	lu.assertEquals(self.samSite:isActive(), false)
	lu.assertEquals(pointDefence:isActive(), true)
	
	self.samSite:finishHarmDefence()
	self.samSite:goLive()
	lu.assertEquals(pointDefence:getActAsEW(), false)
	
	-- TODO: test with two HARM defences
end

function TestSamSites:testCleanUpOldObjectsIdentifiedAsHARMS()
	self.samSiteName = "SAM-SA-10"
	self:setUp()
	
	local sa15 = Group.getByName("SAM-SA-15-1")
	local pointDefence = SkynetIADSSamSite:create(sa15, self.skynetIADS)
	pointDefence:setupElements()
	pointDefence:goLive()
	pointDefence:goDark()
	lu.assertEquals(self.samSite:addPointDefence(pointDefence), self.samSite)
	lu.assertEquals(#self.samSite:getPointDefences(), 1)
	
	-- set point defence to ew mode: that's the state it is in, when defending a HARM
	pointDefence:setActAsEW(true)
	
	local iadsContact = IADSContactFactory("test-distance-calculation")
	local iadsContact2 = IADSContactFactory("test-not-in-firing-range-of-sa-2")	
	local iadsContact3 = IADSContactFactory("test-outer-search-range")
	
	function self.samSite:getDetectedTargets()
		return {iadsContact, iadsContact2, iadsContact3}
	end
	
	function self.samSite:getDistanceInMetersToContact(a, b)
		return 50
	end
	function self.samSite:calculateImpactPoint(a, b)
		return self:getRadars()[1]:getPosition().p
	end
	
	function self.samSite:shallReactToHARM()
		return true
	end
	
	function self.samSite:goSilentToEvadeHARM()
	
	end
	
	self.samSite:evaluateIfTargetsContainHARMs(self.samSite)
	lu.assertEquals(#self.samSite:getDetectedTargets(), 3)
	lu.assertEquals(self.samSite:getNumberOfObjectsItentifiedAsHARMS(), 3)
	
	self.samSite.objectsIdentifiedAsHarms = {}
	
	self.samSite:evaluateIfTargetsContainHARMs(self.samSite)
	
	--age a target
	local testSAMSite = self.samSite	
	function iadsContact3:getAge()
		return testSAMSite.objectsIdentifiedAsHarmsMaxTargetAge + 1
	end
	
	self.samSite:cleanUpOldObjectsIdentifiedAsHARMS()
	lu.assertEquals(self.samSite:getNumberOfObjectsItentifiedAsHARMS(), 2)
	
	---set to 0 harms detected, check if point defence is no longer in EW mode:
	function iadsContact:getAge()
		return testSAMSite.objectsIdentifiedAsHarmsMaxTargetAge + 1
	end

	function iadsContact2:getAge()
		return testSAMSite.objectsIdentifiedAsHarmsMaxTargetAge + 1
	end
	
	self.samSite:cleanUpOldObjectsIdentifiedAsHARMS()
	lu.assertEquals(self.samSite:getNumberOfObjectsItentifiedAsHARMS(), 0)
	
	lu.assertEquals(pointDefence:getActAsEW(), false)
	
end

function TestSamSites:testPointDefenceWhenOnlyOneEWRadarIsActiveAndAmmoIsStillAvailable()
	self.samSiteName = "SAM-SA-10"
	self:setUp()
	self.samSite:setActAsEW(true)
	
	local sa15 = Group.getByName("SAM-SA-15-1")
	local pointDefence = SkynetIADSSamSite:create(sa15, self.skynetIADS)
	pointDefence:setupElements()
	pointDefence:goLive()
	pointDefence:goDark()
	lu.assertEquals(self.samSite:addPointDefence(pointDefence), self.samSite)
	lu.assertEquals(#self.samSite:getPointDefences(), 1)
	
	local iadsContact = IADSContactFactory("test-distance-calculation")
	local iadsContact2 = IADSContactFactory("test-not-in-firing-range-of-sa-2")	
	local iadsContact3 = IADSContactFactory("test-outer-search-range")
	
	local calledShutdown = false
	
	function self.samSite:getDetectedTargets()
		return {iadsContact}
	end
	function self.samSite:getDistanceInMetersToContact(a, b)
		return 50
	end
	function self.samSite:calculateImpactPoint(a, b)
		return self:getRadars()[1]:getPosition().p
	end
	
	function self.samSite:shallReactToHARM()
		return true
	end
	
	function self.samSite:goSilentToEvadeHARM()
		calledShutdown = true
	end
	
	
	--this test is for when setIgnoreHARMSWhilePointDefencesHaveAmmo is  not set expicitly (state false)
	self.samSite:evaluateIfTargetsContainHARMs(self.samSite)
	self.samSite:evaluateIfTargetsContainHARMs(self.samSite)
	lu.assertEquals(calledShutdown, true)
	
	self.samSite.objectsIdentifiedAsHarms = {}
	calledShutdown = false
	
	
	--this test should not provoke a HARM inbound response due to the point defence still having ammo
	
	-- set the state for HARM Ignore to true and check if the method returns a sam site for daisy chaining
	lu.assertEquals(self.samSite:setIgnoreHARMSWhilePointDefencesHaveAmmo(true), self.samSite)
	
	lu.assertEquals(self.samSite:pointDefencesHaveRemainingAmmo(self.samSite:getNumberOfObjectsItentifiedAsHARMS()), true)
	lu.assertEquals(self.samSite:shallIgnoreHARMShutdown(), true)
	
	self.samSite:evaluateIfTargetsContainHARMs(self.samSite)
	self.samSite:evaluateIfTargetsContainHARMs(self.samSite)
	lu.assertEquals(calledShutdown, false)
	lu.assertEquals(self.samSite:isActive(), true)
	lu.assertEquals(pointDefence:isActive(), true)
	
	self.samSite.objectsIdentifiedAsHarms = {}
	calledShutdown = false
	
	
	--this test if for when there are less point defence launchers than HARMs inbound, radar emitter will shut down:
	function self.samSite:getDetectedTargets()
		return {iadsContact, iadsContact2, iadsContact3}
	end
	
	self.samSite:setIgnoreHARMSWhilePointDefencesHaveAmmo(true)
	self.samSite:evaluateIfTargetsContainHARMs(self.samSite)
	lu.assertEquals(self.samSite:pointDefencesHaveEnoughLaunchers(self.samSite:getNumberOfObjectsItentifiedAsHARMS()), false)
	lu.assertEquals(self.samSite:getNumberOfObjectsItentifiedAsHARMS(), 3)	
	self.samSite:evaluateIfTargetsContainHARMs(self.samSite)
	lu.assertEquals(calledShutdown, true)
	
	self.samSite.objectsIdentifiedAsHarms = {}
	calledShutdown = false
	pointDefence:setActAsEW(false)
	pointDefence:goDark()
	
	--this test if for when there are equal number of point defence launchers and HARMs inbound, radar emitter will not shut down
	function self.samSite:getDetectedTargets()
		return {iadsContact, iadsContact2}
	end

	self.samSite:setIgnoreHARMSWhilePointDefencesHaveAmmo(true)
	self.samSite:evaluateIfTargetsContainHARMs(self.samSite)
	lu.assertEquals(self.samSite:getNumberOfObjectsItentifiedAsHARMS(), 2)	
	lu.assertEquals(self.samSite:pointDefencesHaveEnoughLaunchers(self.samSite:getNumberOfObjectsItentifiedAsHARMS()), true)
	self.samSite:evaluateIfTargetsContainHARMs(self.samSite)
	lu.assertEquals(calledShutdown, false)
	lu.assertEquals(self.samSite:isActive(), true)
	lu.assertEquals(pointDefence:isActive(), true)
	
	self.samSite.objectsIdentifiedAsHarms = {}
	calledShutdown = false
	pointDefence:setActAsEW(false)
	pointDefence:goDark()
	
	
	--this test if there are a greater number of point defence launchers than HARMs inbound, radar emitter will not shut down:
	function self.samSite:getDetectedTargets()
		return {iadsContact}
	end
	
	self.samSite:setIgnoreHARMSWhilePointDefencesHaveAmmo(true)
	self.samSite:evaluateIfTargetsContainHARMs(self.samSite)
	lu.assertEquals(self.samSite:getNumberOfObjectsItentifiedAsHARMS(), 1)	
	lu.assertEquals(self.samSite:pointDefencesHaveEnoughLaunchers(self.samSite:getNumberOfObjectsItentifiedAsHARMS()), true)
	self.samSite:evaluateIfTargetsContainHARMs(self.samSite)
	lu.assertEquals(calledShutdown, false)
	lu.assertEquals(self.samSite:isActive(), true)
	lu.assertEquals(pointDefence:isActive(), true)
	
	self.samSite.objectsIdentifiedAsHarms = {}
	calledShutdown = false
	pointDefence:setActAsEW(false)
	pointDefence:goDark()
	
	--this test is for when the point defence is out of ammo and setIgnoreHARMSWhilePointDefencesHaveAmmo is set to true
	function pointDefence:getRemainingNumberOfMissiles()
		return 0
	end
	self.samSite:setIgnoreHARMSWhilePointDefencesHaveAmmo(true)
	self.samSite:evaluateIfTargetsContainHARMs(self.samSite)
	self.samSite:evaluateIfTargetsContainHARMs(self.samSite)
	
	lu.assertEquals(self.samSite:pointDefencesHaveRemainingAmmo(self.samSite:getNumberOfObjectsItentifiedAsHARMS()), false)
	lu.assertEquals(calledShutdown, true)
	
end

function TestSamSites:testPatriotLauncherAndRadar()

--[[
Patriot:

Radar:
{
    {
        count=4,
        desc={
            Nmax=25,
            RCS=0.10660000145435,
            _origin="",
            altMax=24240,
            altMin=45,
            box={
                max={x=2.5578553676605, y=0.33423712849617, z=0.32681864500046},
                min={x=-2.5578553676605, y=-0.33423712849617, z=-0.32681867480278}
            },
            category=1,
            displayName="MIM-104 Patriot",
            fuseDist=13,
            guidance=4,
            life=2,
            missileCategory=2,
            rangeMaxAltMax=120000,
            rangeMaxAltMin=30000,
            rangeMin=3000,
            typeName="MIM_104",
            warhead={caliber=410, explosiveMass=73, mass=73, type=1}
        }
    }
}

Search Radar:
{
    {
        {
            detectionDistanceAir={
                lowerHemisphere={headOn=173872.484375, tailOn=173872.484375},
                upperHemisphere={headOn=173872.484375, tailOn=173872.484375}
            },
            type=1,
            typeName="Patriot str"
        }
    }
}
--]]
	self.samSiteName = "BLUE-SAM-PATRIOT"
	self:setUp()
	lu.assertEquals(self.samSite:getNatoName(), "Patriot")
	lu.assertEquals(self.samSite:getHARMDetectionChance(), 90)
	
	local radar = self.samSite:getSearchRadars()[1]
	lu.assertEquals(radar:getMaxRangeFindingTarget(), 173872.484375)
	
	local launcher = self.samSite:getLaunchers()[1]
	lu.assertEquals(launcher:getInitialNumberOfMissiles(), 4)
	lu.assertEquals(launcher:getRange(), 120000)
end

function TestSamSites:testRapierLauncherAndRadar()
--[[
Rapier:

Radar: (for some reason the typeName  is Tor?)
{
    {
        {
            detectionDistanceAir={
                lowerHemisphere={headOn=16718.5078125, tailOn=16718.5078125},
                upperHemisphere={headOn=16718.5078125, tailOn=16718.5078125}
            },
            type=1,
            typeName="Tor 9A331"
        }
    }
}

Launcher:
{
    {
        count=4,
        desc={
            Nmax=14,
            RCS=0.079999998211861,
            _origin="",
            altMax=3000,
            altMin=50,
            box={
                max={x=1.4030002355576, y=0.13611803948879, z=0.13611821830273},
                min={x=-0.84999942779541, y=-0.13611836731434, z=-0.1361181885004}
            },
            category=1,
            displayName="Rapier",
            fuseDist=0,
            guidance=8,
            life=2,
            missileCategory=2,
            rangeMaxAltMax=6800,
            rangeMaxAltMin=6800,
            rangeMin=400,
            typeName="Rapier",
            warhead={caliber=133, explosiveMass=1.3999999761581, mass=1.3999999761581, type=1}
        }
    }
}

--]]
	self.samSiteName = "BLUE-SAM-RAPIER"
	self:setUp()
	lu.assertEquals(self.samSite:getNatoName(), "Rapier")
	lu.assertEquals(self.samSite:getRadars()[1]:getMaxRangeFindingTarget(), 16718.5078125)
	lu.assertEquals(self.samSite:getLaunchers()[1]:getRange(), 6800)
	lu.assertEquals(self.samSite:getLaunchers()[1]:getInitialNumberOfMissiles(), 4)
	
	local units = Group.getByName(self.samSiteName):getUnits()
	for i = 1, #units do
		local unit = units[i]
		if unit:getTypeName() == 'rapier_fsa_optical_tracker_unit' then
	--		lu.assertEquals(unit:getSensors(), true)
		end
	end
end

function TestSamSites:testRolandLauncherAndRadar()
--[[
Roland:

Radar:
{
    0={
        {opticType=0, type=0, typeName="generic SAM search visir"},
        {opticType=2, type=0, typeName="generic SAM IR search visir"}
    },
    {
        {
            detectionDistanceAir={
                lowerHemisphere={headOn=8024.8837890625, tailOn=8024.8837890625},
                upperHemisphere={headOn=8024.8837890625, tailOn=8024.8837890625}
            },
            type=1,
            typeName="Roland ADS"
        }
    }
}

Launcher:
{
    {
        count=10,
        desc={
            Nmax=14,
            RCS=0.019600000232458,
            _origin="",
            altMax=6000,
            altMin=10,
            box={
                max={x=1.2142661809921, y=0.17386008799076, z=0.1697566062212},
                min={x=-1.212909579277, y=-0.1738600730896, z=-0.1697566062212}
            },
            category=1,
            displayName="XMIM-115 Roland",
            fuseDist=5,
            guidance=4,
            life=2,
            missileCategory=2,
            rangeMaxAltMax=8000,
            rangeMaxAltMin=8000,
            rangeMin=500,
            typeName="ROLAND_R",
            warhead={caliber=150, explosiveMass=6.5, mass=6.5, type=1}
        }
    }
}

--]]
	self.samSiteName = "BLUE-SAM-ROLAND"
	self:setUp()
	lu.assertEquals(self.samSite:getNatoName(), "Roland ADS")
	lu.assertEquals(self.samSite:getRadars()[1]:getMaxRangeFindingTarget(), 8024.8837890625)
	lu.assertEquals(self.samSite:getLaunchers()[1]:getRange(), 8000)
	lu.assertEquals(self.samSite:getLaunchers()[1]:getInitialNumberOfMissiles(), 10)
end

function TestSamSites:testHQ7LauncherAndRadar()
--[[
HQ-7:

Radar:
{
    0={
        {opticType=0, type=0, typeName="TKN-3B day"},
        {opticType=2, type=0, typeName="TKN-3B night"},
        {opticType=0, type=0, typeName="Tunguska optic sight"}
    },
    {
        {
            detectionDistanceAir={
                lowerHemisphere={headOn=10090.756835938, tailOn=6727.1713867188},
                upperHemisphere={headOn=8408.9638671875, tailOn=6727.1713867188}
            },
            type=1,
            typeName="HQ-7 TR"
        }
    }
}

Launcher:
{
    {
        count=4,
        desc={
            Nmax=18,
            RCS=0.0099999997764826,
            _origin="",
            altMax=5500,
            altMin=14.5,
            box={
                max={x=1.245908498764, y=0.20055842399597, z=0.20074887573719},
                min={x=-1.754227399826, y=-0.20056092739105, z=-0.20036999881268}
            },
            category=1,
            displayName="HQ-7",
            fuseDist=7,
            guidance=4,
            life=2,
            missileCategory=2,
            rangeMaxAltMax=12000,
            rangeMaxAltMin=12000,
            rangeMin=500,
            typeName="HQ-7",
            warhead={caliber=156, explosiveMass=15, mass=15, type=1}
        }
    }
}
--]]
	self.samSiteName = "SAM-HQ-7"
	self:setUp()
	
	local group = Group.getByName(self.samSiteName)
--[[
	local units = group:getUnits()
	for i = 1, #units do
		local unit = units[i]
		if unit:getAmmo() then
		--	lu.assertEquals(unit:getAmmo(), false)
		end
	end
--]]
	lu.assertEquals(self.samSite:getNatoName(), "CSA-4")
	lu.assertEquals(self.samSite:getLaunchers()[1]:getRange(), 12000)
	lu.assertEquals(mist.utils.round(self.samSite:getRadars()[1]:getMaxRangeFindingTarget()), mist.utils.round(10090.756835938))
end

--[[
function TestSamSites:testCleanupMistScheduleFunctions()
	self.samSiteName = "SAM-SA-6"
	self:setUp()
	self.samSite:goLive()
	self.ewRadarName = "EW-west22"
	--clean any existing mist scheduleFunctions 
--	local i = 0
	--while i < 1000000 do
	--	mist.removeFunction(i)
	--	i = i + 1
	--end
	self:setUp()
	self.samSite:goLive()
	local i = 0
	while i < 1000000 do
		local hasFunction = mist.removeFunction(i)
		lu.assertEquals(hasFunction, nil)
		i = i + 1
	end-
end
--]]

--[[
function TestSamSites:testCallMethodOnTableElements()
	local test = {}
	function test:theMethod(value)
		env.info("call there: "..value)
		return {}
	end

	function test:theOtherMethod(value)
		env.info("call here: "..value)
		return {}
	end
	
	test.__index = test
	setmetatable(test, test)

	local testContainer = {}
	local handler = {}
	
	handler.__index = function(tbl, name)
		tbl[name] = function(self, ...)
				for i = 1, #self do
					self[i][name](self[i], ...)
				end
				return self
			end
		return tbl[name]
	end
	
	setmetatable(testContainer, handler)
	
	local tast = {}
	setmetatable(tast, test)
	tast.__index = test
	
	table.insert(testContainer, test)
	table.insert(testContainer, tast)
	
	tast['theOtherMethod'](tast, '101')
	
	lu.assertIs(testContainer:theMethod("99"), testContainer)
	lu.assertIs(testContainer:theOtherMethod("100"), testContainer)
end
--]]

function TestSamSites:testAutonomousIfNoEWRadarInRange()
	self.samSiteName = "SAM-SA-6-2"
	self:setUp()
	self.skynetIADS:addEarlyWarningRadarsByPrefix('EW')
	local ewRadar = self.skynetIADS:getEarlyWarningRadarByUnitName('EW-west2')
	lu.assertEquals(self.samSite:isInRadarDetectionRangeOf(ewRadar), true)
	
	
	local ewRadar = self.skynetIADS:getEarlyWarningRadarByUnitName('EW-west23')
	lu.assertEquals(self.samSite:isInRadarDetectionRangeOf(ewRadar), false)
	
end

function TestSamSites:testAutonomousIfNowEWSAMIsInRange()
	self.samSiteName = "SAM-SA-6-2"
	self:setUp()
	self.skynetIADS:addSAMSitesByPrefix('SAM')

	local ewSAM2 = self.skynetIADS:getSAMSiteByGroupName('SAM-SA-6')
	lu.assertEquals(self.samSite:isInRadarDetectionRangeOf(ewSAM2), true)
	
--[[	local radars = ewSAM2:getRadars()
	local samRadars = self.samSite:getRadars()
	for i = 1, #samRadars do
		local samRadar = samRadars[i]
		for j = 1, #radars do
			local radar = radars[j]
			env.info(radar:getMaxRangeFindingTarget())
			env.info(self.samSite:getDistanceToUnit(samRadar:getDCSRepresentation(), radar:getDCSRepresentation()))
		end
	end
--]]
	local ewSAM = self.skynetIADS:getSAMSiteByGroupName('SAM-SA-10')
	lu.assertEquals(self.samSite:isInRadarDetectionRangeOf(ewSAM), false)
	

end

function TestSamSites:testUpdateSAMSitesInCoveredArea()
	self.skynetIADS:addSAMSitesByPrefix('SAM')
	self.samSite = self.skynetIADS:getSAMSiteByGroupName('SAM-SA-10')
	lu.assertEquals(#self.samSite:updateSAMSitesInCoveredArea(), 1)
	local samSites = self.samSite:getSAMSitesInCoveredArea()
	lu.assertEquals(samSites[1]:getDCSRepresentation():getName(), "SAM-SA-15-1")
end

TestJammer = {}

function TestJammer:setUp()
	self.emitter = Unit.getByName('jammer-source')	
	self.mockIADS = {}
	function self.mockIADS:getDebugSettings()
		return {}
	end
	self.jammer = SkynetIADSJammer:create(self.emitter, self.mockIADS)
end

function TestJammer:tearDown()
	self.jammer:masterArmSafe()
end

function TestJammer:testSetJammerDistance()
	self.jammer:setMaximumEffectiveDistance(20)
	lu.assertEquals(self.jammer.maximumEffectiveDistanceNM, 20)
end

function TestJammer:testSetupJammerAndRunCycle()
	lu.assertEquals(self.jammer.jammerTaskID, nil)
	self.jammer:masterArmOn()
	lu.assertNotIs(self.jammer.jammerTaskID, nil)
	
	local mockRadar = {}
	local mockSAM = {}
	local calledJam = false
	
	function mockSAM:getRadars()
		return {mockRadar}
	end
	
	function mockSAM:getNatoName()
		return "SA-2"
	end
	
	function mockSAM:jam(prob)
		calledJam = true
	end
	
	function self.mockIADS:getActiveSAMSites()
		return {mockSAM}
	end
	
	function self.jammer:getDistanceNMToRadarUnit(radarUnit)
		return 50
	end
	
	function self.jammer:hasLineOfSightToRadar(radar)
		return true
	end
	
	self.jammer.runCycle(self.jammer)
	lu.assertEquals(calledJam, true)
end

function TestJammer:testIsActiveForUnknownType()
	lu.assertEquals(self.jammer:isKnownRadarEmitter('ABC-Test'), false)
end

function TestJammer:testIsActiveForKnownType()
	lu.assertEquals(self.jammer:isKnownRadarEmitter('SA-2'), true)
end

function TestJammer:testCleanUpJammer()
	self.jammer:masterArmOn()

	local alive = false
	local i = 0
	while i < 10000 do
		local id =  mist.removeFunction(i)
		i = i + 1
		if id then
			alive = true
		end
	end
	lu.assertEquals(alive, true)

	self.jammer:masterArmSafe()
	
	i = 0
	alive = false
	while i < 10000 do
		local id =  mist.removeFunction(i)
		i = i + 1
		if id then
			alive = true
		end
	end
	lu.assertEquals(alive, false)
end

function TestJammer:testAddJammerFunction()

	local function f(distanceNM)
		return 2 * distanceNM
	end
	self.jammer:addFunction('SA-99', f)
	lu.assertEquals(self.jammer:getSuccessProbability(20, 'SA-99'), 40)
	lu.assertEquals(self.jammer:isKnownRadarEmitter('SA-99'), true)
	self.jammer:disableFor('SA-99')
	lu.assertEquals(self.jammer:isKnownRadarEmitter('SA-99'), false)
end

function TestJammer:testDestroyEmitter()
	self:tearDown()
	self.emitter = Unit.getByName("jammer-source-unit-test")
	local iads = SkynetIADS:create()
	self.jammer = SkynetIADSJammer:create(self.emitter, iads)
	self.jammer:masterArmOn()
	
	trigger.action.explosion(Unit.getByName("jammer-source-unit-test"):getPosition().p, 500)
	self.jammer.runCycle(self.jammer)
	
	local i = 0
	local alive = false
	while i < 10000 do
		local id =  mist.removeFunction(i)
		i = i + 1
		if id then
			alive = true
		end
	end
	lu.assertEquals(alive, false)
end

TestEarlyWarningRadars = {}

function TestEarlyWarningRadars:setUp()
	self.numEWSites = SKYNET_UNIT_TESTS_NUM_EW_SITES_RED
	if self.blue == nil then
		self.blue = ""
	end
	if self.ewRadarName then
		self.iads = SkynetIADS:create()
		self.iads:addEarlyWarningRadarsByPrefix(self.blue..'EW')
		self.ewRadar = self.iads:getEarlyWarningRadarByUnitName(self.ewRadarName)
	end
end

function TestEarlyWarningRadars:tearDown()
	if self.ewRadar then
		self.ewRadar:cleanUp()
	end
	if self.iads then
		self.iads:deactivate()
	end
	self.iads = nil
	self.ewRadar = nil
	self.ewRadarName = nil
	self.blue = ""
end

function TestEarlyWarningRadars:testCompleteDestructionOfEarlyWarningRadar()
		self:tearDown()
		
		local iads = SkynetIADS:create()
		local ewRadar = iads:addEarlyWarningRadar('EW-west22-destroy')
		local sa61 = iads:addSAMSite('SAM-SA-6')
		local sa62 = iads:addSAMSite('SAM-SA-6-2')
		
		lu.assertEquals(ewRadar:hasRemainingAmmo(), true)
		lu.assertEquals(ewRadar:isActive(), true)
		lu.assertEquals(ewRadar:getDCSRepresentation():isExist(), true)
		lu.assertEquals(#iads:getUsableEarlyWarningRadars(), 1)
		lu.assertEquals(sa61:getAutonomousState(), false)
		lu.assertEquals(sa62:getAutonomousState(), false)
		trigger.action.explosion(ewRadar:getDCSRepresentation():getPosition().p, 500)
		lu.assertEquals(ewRadar:getDCSRepresentation():isExist(), false)
	
		lu.assertEquals(ewRadar:isActive(), false)
		lu.assertEquals(#iads:getUsableEarlyWarningRadars(), 0)

		lu.assertEquals(sa61:getAutonomousState(), true)
		lu.assertEquals(sa62:getAutonomousState(), true)
end

function TestEarlyWarningRadars:testGetNatoName()
	self.ewRadarName = "EW-west22-destroy"
	self:setUp()
	lu.assertEquals(self.ewRadar:getNatoName(), "1L13 EWR")
end

function TestEarlyWarningRadars:testEvaluateIfTargetsContainHARMsShallReactTrue()
	self.ewRadarName = "EW-west2"
	self:setUp()
	
	lu.assertNotIs(self.ewRadar.harmScanID, nil)
	local iadsContact = IADSContactFactory("test-distance-calculation")
	
	local calledShutdown = false
	
	function self.ewRadar:getDetectedTargets()
		return {iadsContact}
	end
	function self.ewRadar:getDistanceInMetersToContact(a, b)
		return 50
	end
	function self.ewRadar:calculateImpactPoint(a, b)
		return self:getRadars()[1]:getPosition().p
	end
	
	function self.ewRadar:shallReactToHARM()
		return true
	end
	
	function self.ewRadar:goSilentToEvadeHARM()
		calledShutdown = true
	end
	
	lu.assertEquals(#self.ewRadar:getRadars(), 1)
	self.ewRadar:evaluateIfTargetsContainHARMs()
	lu.assertEquals(calledShutdown, false)
	lu.assertEquals(self.ewRadar.objectsIdentifiedAsHarms[iadsContact:getName()]['target'], iadsContact)
	lu.assertEquals(self.ewRadar.objectsIdentifiedAsHarms[iadsContact:getName()]['count'], 1)
	self.ewRadar:evaluateIfTargetsContainHARMs()
	lu.assertEquals(self.ewRadar.objectsIdentifiedAsHarms[iadsContact:getName()]['count'], 2)
	lu.assertEquals(calledShutdown, true)
end


function TestEarlyWarningRadars:testFinishHARMDefence()
--[[
	Radar:
	{
		{
			{
				detectionDistanceAir={
					lowerHemisphere={headOn=80248.84375, tailOn=80248.84375},
					upperHemisphere={headOn=80248.84375, tailOn=80248.84375}
				},
				type=1,
				typeName="1L13 EWR"
			}
		}
	}


--]]
	self.ewRadarName = "EW-west2"
	self:setUp()
	lu.assertEquals(self.ewRadar:isActive(), true)
	lu.assertEquals(self.ewRadar:hasRemainingAmmo(), true)
	self.ewRadar:goSilentToEvadeHARM()
	lu.assertEquals(self.ewRadar:isActive(), false)
	self.ewRadar.finishHarmDefence(self.ewRadar)
	lu.assertEquals(self.ewRadar.harmSilenceID, nil)
	self.iads.evaluateContacts(self.iads)
	lu.assertEquals(self.ewRadar:isActive(), true)
end

function TestEarlyWarningRadars:testGoDarkWhenAutonomousByDefault()
	self.ewRadarName = "EW-west2"
	self:setUp()
	lu.assertEquals(self.ewRadar:isActive(), true)
	function self.ewRadar:hasActiveConnectionNode()
		return false
	end
	self.ewRadar:goAutonomous()
	lu.assertEquals(self.ewRadar:isActive(), false)
end

function TestEarlyWarningRadars:testEWP19()
	self.ewRadarName = "EW-SR-P19"
	self:setUp()
	lu.assertEquals(self.ewRadar:getNatoName(), "Flat Face")
	lu.assertEquals(self.ewRadar:hasWorkingRadar(), true)
end

function TestEarlyWarningRadars:testPatriotSTRStandalone()
	self.ewRadarName = "BLUE-EW"
	self.blue = "BLUE-"
	self:setUp()
	lu.assertEquals(self.ewRadar:getNatoName(), "Patriot str")
	lu.assertEquals(self.ewRadar:hasWorkingRadar(), true)
end

function TestEarlyWarningRadars:testSA10Standalone()
	self.ewRadarName = "EW-SA-10"
	self:setUp()
	lu.assertEquals(self.ewRadar:getNatoName(), "Big Bird")
	lu.assertEquals(self.ewRadar:hasWorkingRadar(), true)
end

function TestEarlyWarningRadars:testSA10Standalone()
	self.ewRadarName = "EW-SA-10-2"
	self:setUp()
	lu.assertEquals(self.ewRadar:getNatoName(), "Big Bird")
	lu.assertEquals(self.ewRadar:hasWorkingRadar(), true)
end

function TestEarlyWarningRadars:testSA11Standalone()
	self.ewRadarName = "EW-SA-11"
	self:setUp()
	lu.assertEquals(self.ewRadar:getNatoName(), "Snow Drift")
	lu.assertEquals(self.ewRadar:hasWorkingRadar(), true)
end

function TestEarlyWarningRadars:testSA6Standalone()
	self.ewRadarName = "EW-SA-6"
	self:setUp()
	lu.assertEquals(self.ewRadar:getNatoName(), "Straight Flush")
	lu.assertEquals(self.ewRadar:hasWorkingRadar(), true)
end

function TestEarlyWarningRadars:testHawkStandalone()
	self.ewRadarName = "EW-Hawk"
	self:setUp()
	lu.assertEquals(self.ewRadar:getNatoName(), "Hawk str")
	lu.assertEquals(self.ewRadar:hasWorkingRadar(), true)
end

function TestEarlyWarningRadars:testA50AWACSAsEWRadar()
--[[
	DCS A-50 properties:
	
	Radar:
	    {
        {
            detectionDistanceAir={
                lowerHemisphere={headOn=204461.796875, tailOn=204461.796875},
                upperHemisphere={headOn=204461.796875, tailOn=204461.796875}
            },
            detectionDistanceRBM=2500,
            type=1,
            typeName="Shmel"
        }
    },
    3={{type=3, typeName="Abstract RWR"}}
}

--]]
	self.ewRadarName = "EW-AWACS-A-50"
	self:setUp()
	local unit = Unit.getByName(self.ewRadarName)
	lu.assertEquals(unit:getDesc().category, Unit.Category.AIRPLANE)
	lu.assertEquals(self.ewRadar:getNatoName(), 'A-50')
	local searchRadar = self.ewRadar:getSearchRadars()[1]
	lu.assertEquals(searchRadar:getMaxRangeFindingTarget(), 204461.796875)
end

function TestEarlyWarningRadars:testKJ2000AWACSAsEWRadar()
--[[
	DCS KJ-2000 properties:
	
	Radar:
	{
		{
			{
				detectionDistanceAir={
					lowerHemisphere={headOn=268356.125, tailOn=268356.125},
					upperHemisphere={headOn=268356.125, tailOn=268356.125}
				},
				detectionDistanceRBM=3500,
				type=1,
				typeName="AESA_KJ2000"
			}
		},
		3={{type=3, typeName="Abstract RWR"}}
	}

--]]
	self.ewRadarName = "EW-AWACS-KJ-2000"
	self:setUp()
	local unit = Unit.getByName('EW-AWACS-KJ-2000')
	local searchRadar = self.ewRadar:getSearchRadars()[1]
	lu.assertEquals(self.ewRadar:getNatoName(), 'KJ-2000')
	lu.assertEquals(searchRadar:getMaxRangeFindingTarget(), 268356.125)
end

--TODO: this test can only be finished once the perry class has radar data:
function TestEarlyWarningRadars:testOliverHazzardPerryClassShip()
--[[
Oliver Hazzard:

Launchers:
 {
    {
        count=2016,
        desc={
            _origin="",
            box={
                max={x=2.2344591617584, y=0.12504191696644, z=0.12113922089338},
                min={x=-6.61008644104, y=-0.12504199147224, z=-0.12113920599222}
            },
            category=0,
            displayName="12.7mm",
            life=2,
            typeName="weapons.shells.M2_12_7_T",
            warhead={caliber=12.7, explosiveMass=0, mass=0.046, type=0}
        }
    },
    {
        count=460,
        desc={
            _origin="",
            box={
                max={x=2.2344591617584, y=0.12504191696644, z=0.12113922089338},
                min={x=-6.61008644104, y=-0.12504199147224, z=-0.12113920599222}
            },
            category=0,
            displayName="25mm HE",
            life=2,
            typeName="weapons.shells.M242_25_HE_M792",
            warhead={caliber=25, explosiveMass=0.185, mass=0.185, type=1}
        }
    },
    {
        count=142,
        desc={
            _origin="",
            box={
                max={x=2.2344591617584, y=0.12504191696644, z=0.12113922089338},
                min={x=-6.61008644104, y=-0.12504199147224, z=-0.12113920599222}
            },
            category=0,
            displayName="25mm AP",
            life=2,
            typeName="weapons.shells.M242_25_AP_M791",
            warhead={caliber=25, explosiveMass=0, mass=0.155, type=0}
        }
    },
    {
        count=775,
        desc={
            _origin="",
            box={
                max={x=2.2344591617584, y=0.12504191696644, z=0.12113922089338},
                min={x=-6.61008644104, y=-0.12504199147224, z=-0.12113920599222}
            },
            category=0,
            displayName="20mm AP",
            life=2,
            typeName="weapons.shells.M61_20_AP",
            warhead={caliber=20, explosiveMass=0, mass=0.1, type=0}
        }
    },
    {
        count=775,
        desc={
            _origin="",
            box={
                max={x=2.2344591617584, y=0.12504191696644, z=0.12113922089338},
                min={x=-6.61008644104, y=-0.12504199147224, z=-0.12113920599222}
            },
            category=0,
            displayName="20mm HE",
            life=2,
            typeName="weapons.shells.M61_20_HE",
            warhead={caliber=20, explosiveMass=0.1, mass=0.1, type=1}
        }
    },
    {
        count=24,
        desc={
            Nmax=25,
            RCS=0.1765999943018,
            _origin="",
            altMax=24400,
            altMin=10,
            box={
                max={x=2.9796471595764, y=0.39923620223999, z=0.39878171682358},
                min={x=-1.5204827785492, y=-0.38143759965897, z=-0.39878168702126}
            },
            category=1,
            displayName="SM-2",
            fuseDist=15,
            guidance=4,
            life=2,
            missileCategory=2,
            rangeMaxAltMax=100000,
            rangeMaxAltMin=40000,
            rangeMin=4000,
            typeName="SM_2",
            warhead={caliber=340, explosiveMass=98, mass=98, type=1}
        }
    },
    {
        count=16,
        desc={
            Nmax=18,
            RCS=0.10580000281334,
            _origin="",
            altMax=10000,
            altMin=-1,
            box={
                max={x=2.2758972644806, y=0.13610155880451, z=0.28847914934158},
                min={x=-1.6704962253571, y=-0.4600305557251, z=-0.28847911953926}
            },
            category=1,
            displayName="AGM-84S Harpoon",
            fuseDist=0,
            guidance=1,
            life=2,
            missileCategory=4,
            rangeMaxAltMax=241401,
            rangeMaxAltMin=95000,
            rangeMin=3000,
            typeName="AGM_84S",
            warhead={caliber=343, explosiveMass=90, mass=90, type=1}
        }
    },
    {
        count=180,
        desc={
            _origin="",
            box={
--]]
	self.ewRadarName = "BLUE-EW-Oliver-Hazzard"
	self.blue = "BLUE-"
	self:setUp()	
	lu.assertEquals(self.ewRadar:getNatoName(), "PERRY")
	--as long as we don't use the PERRY as a SAM site the distance returned is irrelevant, because it's radar wil be on all the time
	lu.assertEquals(self.ewRadar:getRadars()[1]:getMaxRangeFindingTarget(), 241401)
	
	--PERRY does not have radar data
	local unit = Unit.getByName(self.ewRadarName)
	lu.assertEquals(unit:getSensors(), nil)
end

function TestEarlyWarningRadars:testTiconderoga()
	self.ewRadarName = "ticonderoga-class"
	lu.assertEquals(Unit.getByName(self.ewRadarName):getDesc().category, Unit.Category.SHIP)
end

function TestEarlyWarningRadars:testUpdateSAMSitesInCoveredArea()
	self.ewRadarName = "EW-west23"
	self:setUp()
	self.iads:addSAMSitesByPrefix('SAM')
	lu.assertEquals(#self.ewRadar:updateSAMSitesInCoveredArea(), 3)
	local samSites = self.ewRadar:getSAMSitesInCoveredArea()
	lu.assertEquals(samSites[1]:getDCSRepresentation():getName(), "SAM-SA-2")
	lu.assertEquals(samSites[2]:getDCSRepresentation():getName(), "SAM-SA-19")
	lu.assertEquals(samSites[3]:getDCSRepresentation():getName(), "SAM-SA-15")
end

function TestEarlyWarningRadars:testCacheDetectedTargets()
	self.ewRadarName = "EW-west23"
	self:setUp()
	local targets = self.ewRadar:getDetectedTargets()
	local targets2 = self.ewRadar:getDetectedTargets()
	lu.assertIs(targets, targets2)
	
	local targets = self.ewRadar:getDetectedTargets()
	self.ewRadar.cachedTargetsMaxAge = -1
	local targets2 = self.ewRadar:getDetectedTargets()
	lu.assertNotIs(targets, targets2)
	
end

lu.LuaUnit.run()


--clean miste left over scheduled tasks form unit tests

-- we run this test to check there are no left over tasks in the IADS

local i = 0
while i < 10000 do
	local id =  mist.removeFunction(i)
	i = i + 1
	if id then
		env.info("WARNING: IADS left over Tasks")
	end
end


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