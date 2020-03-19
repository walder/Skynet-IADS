do
---IADS Unit Tests

SKYNET_UNIT_TESTS_NUM_EW_SITES_RED = 11
SKYNET_UNIT_TESTS_NUM_SAM_SITES_RED = 12

function IADSContactFactory(unitName)
	local contact = Unit.getByName(unitName)
	local radarContact = {}
	radarContact.object = contact
	local iadsContact = SkynetIADSContact:create(radarContact)
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

function TestIADS:testEarlyWarningRadarHasWorkingPowerSourceByDefault()
	local ewRadar = self.iranIADS:getEarlyWarningRadarByUnitName('EW-west')
	lu.assertEquals(ewRadar:hasWorkingPowerSource(), true)
end

function TestIADS:testEarlyWarningRadarLoosesPower()
	ewWest2PowerSource = StaticObject.getByName('EW-west Power Source')
	self.iranIADS:getEarlyWarningRadarByUnitName('EW-west'):addPowerSource(ewWest2PowerSource)
	local ewRadar = self.iranIADS:getEarlyWarningRadarByUnitName('EW-west')
	lu.assertEquals(ewRadar:hasWorkingPowerSource(), true)
	trigger.action.explosion(ewWest2PowerSource:getPosition().p, 100)
	lu.assertEquals(ewRadar:hasWorkingPowerSource(), false)
	--simulate update cycle of IADS
	self.iranIADS:evaluateContacts(self.iranIADS)
	lu.assertEquals(ewRadar:hasWorkingPowerSource(), false)
	lu.assertEquals(ewRadar:isActive(), false)
end

function TestIADS:testSamSiteLoosesPower()
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
	--simulate update cycle of IADS
	self.iranIADS.evaluateContacts(self.iranIADS)
	lu.assertEquals(#self.iranIADS:getUsableSAMSites(), self.numSAMSites-1)
	lu.assertEquals(#self.iranIADS:getSAMSites(), self.numSAMSites)
	local samSite = self.iranIADS:getSAMSiteByGroupName('SAM-SA-6')
	lu.assertEquals(samSite:isActive(), true)
	--simulate update cycle of IADS
	self.iranIADS.evaluateContacts(self.iranIADS)
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
	--simulate update cycle of IADS
--	self.iranIADS:evaluateContacts()
--	lu.assertEquals(samSite:isActive(), false)
	samSite:goDark()
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
		correlatedCalled = true
	end
	self.iranIADS:evaluateContacts()
	lu.assertEquals(correlatedCalled, true)
	lu.assertEquals(#self.iranIADS.contacts, 1)
	self.iranIADS.contacts = {}

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
	self.samSiteName = "SAM-SA-6"
	self:setUp()
	lu.assertEquals(#self.samSite:getLaunchers(), 2)
	lu.assertEquals(#self.samSite:getSearchRadars(), 3)
	
	local searchRadar = self.samSite:getSearchRadars()[1]
	lu.assertEquals(searchRadar:getMaxRangeFindingTarget(), 46811.82421875)
	
	lu.assertEquals(self.samSite:getNatoName(), "SA-6")
	
	local launcher = self.samSite:getLaunchers()[1]
	lu.assertEquals(launcher:getRange(), 25000)
	
	lu.assertEquals(self.samSite:getRemainingNumberOfMissiles(), 6)
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
	
	Launcher:
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
	lu.assertEquals(mist.utils.round(launcher:getHeight(target)), 1909)

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
	local samSite = iads:addSAMSite("Destruction-test-sam")
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
		trigger.action.explosion(launcher:getDCSRepresentation():getPosition().p, 900)
	end	
	lu.assertEquals(samSite:isActive(), false)
	lu.assertEquals(samSite:isDestroyed(), true)
	lu.assertEquals(#iads:getDestroyedSAMSites(), 1)
	lu.assertEquals(samSite:getRemainingNumberOfMissiles(), 0)
	lu.assertEquals(samSite:getInitialNumberOfMissiles(), 6)
	lu.assertEquals(samSite:hasRemainingAmmo(), false)
	
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
	self.samSite:evaluateIfTargetsContainHARMs(self.samSite)
	self.samSite:evaluateIfTargetsContainHARMs(self.samSite)
	lu.assertEquals(calledShutdown, false)
	lu.assertEquals(self.samSite:isActive(), true)
	
	self.samSite.objectsIdentifiedAsHarms = {}
	calledShutdown = false
		
	--this test is for when the point defence is out of ammo and setIgnoreHARMSWhilePointDefencesHaveAmmo is set to true
	function pointDefence:hasRemainingAmmo()
		return false
	end
	self.samSite:setIgnoreHARMSWhilePointDefencesHaveAmmo(true)
	self.samSite:evaluateIfTargetsContainHARMs(self.samSite)
	self.samSite:evaluateIfTargetsContainHARMs(self.samSite)
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
TestEarlyWarningRadars = {}

function TestEarlyWarningRadars:setUp()
	self.numEWSites = SKYNET_UNIT_TESTS_NUM_EW_SITES_RED
	if self.ewRadarName then
		self.iads = SkynetIADS:create()
		self.iads:addEarlyWarningRadarsByPrefix('EW')
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
end

function TestEarlyWarningRadars:testCompleteDestructionOfEarlyWarningRadar()
		self.ewRadarName = "EW-west22"
		self:setUp()
		lu.assertEquals(self.ewRadar:hasRemainingAmmo(), true)
		lu.assertEquals(self.ewRadar:isActive(), true)
		lu.assertEquals(self.ewRadar:getDCSRepresentation():isExist(), true)
		lu.assertEquals(#self.iads:getUsableEarlyWarningRadars(), self.numEWSites)
		trigger.action.explosion(self.ewRadar:getDCSRepresentation():getPosition().p, 500)
		lu.assertEquals(self.ewRadar:getDCSRepresentation():isExist(), false)
		self.ewRadar:goDark()
		lu.assertEquals(self.ewRadar:isActive(), false)
		lu.assertEquals(#self.iads:getUsableEarlyWarningRadars(), self.numEWSites-1)	
end

function TestEarlyWarningRadars:testGetNatoName()
	self.ewRadarName = "EW-west22"
	self:setUp()
	lu.assertEquals(self.ewRadar:getNatoName(), "1L13 EWR")
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

lu.LuaUnit.run()

--clean miste left over scheduled tasks form unit tests

-- we run this test to check there are no left over tasks in the IADS
local i = 0
while i < 10000000 do
	local id =  mist.removeFunction(i)
	i = i + 1
	if id then
		env.info("WARNING: IADS left over Tasks")
	end
end

--- create an iads so the mission can be played, the ones in the unit tests, are cleaned once the tests are finished

iranIADS = SkynetIADS:create("Iran")
iranIADS:addEarlyWarningRadarsByPrefix('EW')
iranIADS:addSAMSitesByPrefix('SAM')
iranIADS:getSAMSiteByGroupName('SAM-SA-6-2'):setHARMDetectionChance(100)

local sa15 = iranIADS:getSAMSiteByGroupName('SAM-SA-15-1')
iranIADS:getSAMSiteByGroupName('SAM-SA-10'):setActAsEW(true):setHARMDetectionChance(100):addPointDefence(sa15):setIgnoreHARMSWhilePointDefencesHaveAmmo(true)

local connectioNode = StaticObject.getByName('Unused Connection Node')
local sam = iranIADS:getSAMSiteByGroupName('SAM-SA-6-2'):addConnectionNode(connectioNode)

iranIADS:addRadioMenu()
iranIADS:activate()

local iadsDebug = iranIADS:getDebugSettings()
iadsDebug.IADSStatus = true
iadsDebug.harmDefence = true
iadsDebug.contacts = true



blueIADS = SkynetIADS:create("UAE")
blueIADS:addSAMSitesByPrefix('BLUE-SAM')
blueIADS:addEarlyWarningRadarsByPrefix('BLUE-EW')
blueIADS:addRadioMenu()
blueIADS:activate()

local blueIadsDebug = blueIADS:getDebugSettings()
blueIadsDebug.IADSStatus = true
blueIadsDebug.harmDefence = true
blueIadsDebug.contacts = true

local launchers = sam:getLaunchers()
for i=1, #launchers do
	local launcher = launchers[i]:getDCSRepresentation()
--	trigger.action.explosion(launcher:getPosition().p, 9000)
end
--test to check in game ammo changes, to build unit tests on
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
mist.scheduleFunction(checkSams, {iranIADS}, 1, 1)
end