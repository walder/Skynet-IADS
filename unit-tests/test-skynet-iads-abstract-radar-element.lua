do
TestSkynetIADSAbstractRadarElement = {}

function TestSkynetIADSAbstractRadarElement:setUp()
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

function TestSkynetIADSAbstractRadarElement:tearDown()
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

--TODO: test other calls in the GoDark Method
function TestSkynetIADSAbstractRadarElement:testGoDark()
	self.samSiteName = "SAM-SA-6-2"
	self:setUp()
	
	local mockRepresentation = {}
	
	local emissionState = nil
	
	function mockRepresentation:enableEmission(state)
		emissionState = false
	end
	
	function mockRepresentation:isExist()
		return true
	end
	
	function self.samSite:getDCSRepresentation()
		return mockRepresentation
	end
	
	
	local mockController = {}
	
	function mockController:setOption(option)
	
	end
	
	function mockRepresentation:getController()
		return mockController
	end
	
	table.insert(self.samSite.cachedTargets,{"Mock1"})
	self.samSite:goDark()
	lu.assertEquals(self.samSite:isActive(), false)
	lu.assertEquals(emissionState, false)
	lu.assertEquals(#self.samSite.cachedTargets, 0)
	
end

--TODO: test other calls in the GoLive Method
function TestSkynetIADSAbstractRadarElement:testGoLive()
	self.samSiteName = "SAM-SA-6-2"
	self:setUp()
	self.samSite:goDark()
	
	local mockRepresentation = {}
	
	local emissionState = nil
	
	function mockRepresentation:enableEmission(state)
		emissionState = true
	end
	
	function mockRepresentation:isExist()
		return true
	end
	
	function self.samSite:getDCSRepresentation()
		return mockRepresentation
	end
	
	
	local mockController = {}
	
	function mockController:setOption(option)
	
	end
	
	function mockRepresentation:getController()
		return mockController
	end
	
	--test so see if controller is called when setting site live:
	call = 0
	function mockController:setOnOff(state)
		lu.assertEquals(state, true)
		call = 1
	end
	
	self.samSite:goLive()
	lu.assertEquals(call, 1)
	lu.assertEquals(self.samSite:isActive(), true)
	lu.assertEquals(emissionState, true)
end
	
function TestSkynetIADSAbstractRadarElement:testGoDarkDueToHARMTestIfAIisOff()
	self.samSiteName = "SAM-SA-2"
	self:setUp()
	local mockController = {}
	local call = 0
	function mockController:setOnOff(state)
		lu.assertEquals(state, false)
		call = 1
	end
	function self.samSite:getController()
		return mockController
	end
	self.samSite:goSilentToEvadeHARM(10)
	lu.assertEquals(self.samSite:isActive(), false)
	lu.assertEquals(call, 1)
	
	--test so no controller call is made if sam site is destroyed:
	self.samSiteName = "SAM-SA-2"
	self:setUp()
	local mockController = {}
	call = 0
	function mockController:setOnOff(state)
		call = call + 1
	end
	function self.samSite:getController()
		return mockController
	end
	function self.samSite:isDestroyed()
		return true
	end
	self.samSite:goSilentToEvadeHARM(10)
	lu.assertEquals(self.samSite:isActive(), false)
	lu.assertEquals(call, 0)
end

function TestSkynetIADSAbstractRadarElement:testCanEngageAirWeapons()
	self.samSiteName = "SAM-SA-6-2"
	self:setUp()
	
	local called = false
	local mockController = {}
	function mockController:setOption(option, value)
		lu.assertEquals(option, AI.Option.Ground.id.ENGAGE_AIR_WEAPONS)
		lu.assertEquals(value, true)
		called = true
	end
	
	local mockDCSRepresenation = {}
	function mockDCSRepresenation:getController()
		return mockController
	end
	
	function self.samSite:getDCSRepresentation()
		return mockDCSRepresenation
	end

	
	function self.samSite:getController()
		return mockController
	end
	--by default SAM site is not set to engage air weapons in Skynet:
	lu.assertEquals(self.samSite:getCanEngageAirWeapons(), false)
	lu.assertEquals(self.samSite:setCanEngageAirWeapons(true), self.samSite)
	lu.assertEquals(self.samSite:getCanEngageAirWeapons(), true)
	lu.assertEquals(called, true)
	
	--we test that calling setEngageAirWeapons with true on a SAM site that can by default engage harms also sets canEngageHarm to true
	
	function mockController:setOption(option, value)
	end
	
	self.samSite.dataBaseSupportedTypesCanEngageHARM = true
	self.samSite:setCanEngageAirWeapons(false)
	self.samSite:setCanEngageAirWeapons(true)
	lu.assertEquals(self.samSite:getCanEngageHARM(), true)
	self.samSite = nil
end

function TestSkynetIADSAbstractRadarElement:testCanEngageHARM()
	self.samSiteName = "SAM-SA-6-2"
	self:setUp()
	
	local called = false
	function self.samSite:setCanEngageAirWeapons(state)
		lu.assertEquals(state, true)
		called = true
	end
	
	lu.assertEquals(self.samSite:setCanEngageHARM(true), self.samSite)
	lu.assertEquals(self.samSite:getCanEngageHARM(), true)
	lu.assertEquals(called, true)
	
	local called = false
	self.samSite:setCanEngageHARM(false)
	lu.assertEquals(self.samSite:getCanEngageHARM(), false)
	lu.assertEquals(called, false)
	
end

function TestSkynetIADSAbstractRadarElement:testAddParentRadarAndClearParentRadars()
	self.samSiteName = "SAM-SA-6-2"
	self:setUp()
	
	local called = false
	function self.samSite:setToCorrectAutonomousState()
		called = true
	end
	
	lu.assertEquals(#self.samSite:getParentRadars(), 0)
	local parentRad1 = {}
	self.samSite:addParentRadar(parentRad1)
	lu.assertEquals(#self.samSite:getParentRadars(), 1)
	
	--try adding the same radar again, make sure its not added:
	self.samSite:addParentRadar(parentRad1)
	lu.assertEquals(#self.samSite:getParentRadars(), 1)
	
	local parentRad2 = {}
	self.samSite:addParentRadar(parentRad2)
	lu.assertEquals(#self.samSite:getParentRadars(), 2)
	
	lu.assertEquals(self.samSite:getParentRadars()[1], parentRad2)
	lu.assertEquals(self.samSite:getParentRadars()[2], parentRad1)
	
	lu.assertEquals(called, true)
	
	--reset array to prevent teardown issues with mock objects
	self.samSite:clearParentRadars()
	lu.assertEquals(#self.samSite:getParentRadars(), 0)
end

function TestSkynetIADSAbstractRadarElement:testAddChildRadarAndClearChildRadars()
	self.samSiteName = "SAM-SA-6-2"
	self:setUp()
	lu.assertEquals(#self.samSite:getChildRadars(), 0)
	local childRad1 = {}
	self.samSite:addChildRadar(childRad1)
	lu.assertEquals(#self.samSite:getChildRadars(), 1)
	
	--try adding the same radar again, make sure its not added:
	self.samSite:addChildRadar(childRad1)
	lu.assertEquals(#self.samSite:getChildRadars(), 1)
	
	local childRad2 = {}
	self.samSite:addChildRadar(childRad2)
	lu.assertEquals(#self.samSite:getChildRadars(), 2)
	
	lu.assertEquals(self.samSite:getChildRadars()[1], childRad1)
	lu.assertEquals(self.samSite:getChildRadars()[2], childRad2)
	
	--reset array to prevent teardown issues with mock objects
	self.samSite:clearChildRadars()
	lu.assertEquals(#self.samSite:getChildRadars(), 0)
end

function TestSkynetIADSAbstractRadarElement:testGetUsableChildRadars()
	
	self.samSiteName = "SAM-SA-6-2"
	self:setUp()
	
	function self.samSite:setToCorrectAutonomousState()
	
	end
	
	local childRad1 = {}
	function childRad1:hasWorkingPowerSource()
		return false
	end
	
	function childRad1:hasActiveConnectionNode()
		return true
	end
	
	self.samSite:addChildRadar(childRad1)
	
	lu.assertEquals(#self.samSite:getUsableChildRadars(), 0)
	
	
	function childRad1:hasWorkingPowerSource()
		return true
	end
		
	function childRad1:hasActiveConnectionNode()
		return false
	end
	
	lu.assertEquals(#self.samSite:getUsableChildRadars(), 0)
	
	
	function childRad1:hasWorkingPowerSource()
		return true
	end
	
	function childRad1:hasActiveConnectionNode()
		return true
	end
	
	lu.assertEquals(#self.samSite:getUsableChildRadars(), 1)

	--reset array to prevent teardown issues with mock objects
	self.samSite.childRadars = {}
	
end

function TestSkynetIADSAbstractRadarElement:testInformChildrenOfStateChange()
	
	self.samSiteName = "SAM-SA-6-2"
	self:setUp()
	
	--we ensure the moose connector is updated if a state of an IADS radar changes
	local updateCalled = false
	local mockMoose = {}
	function mockMoose:update()
		updateCalled = true
	end
	function self.samSite.iads:getMooseConnector()
		return mockMoose
	end
	
	local calls = 0
	local childRad1 = {}
	function childRad1:setToCorrectAutonomousState()
		calls = calls + 1
	end
	self.samSite:addChildRadar(childRad1)
	
	local childRad2 = {}
	function childRad2:setToCorrectAutonomousState()
		calls = calls + 1
	end
	self.samSite:addChildRadar(childRad2)
	
	self.samSite:informChildrenOfStateChange()

	lu.assertEquals(updateCalled, true)
	lu.assertEquals(calls, 2)
end

--this test is related to testInformChildrenOfStateChange it tests, if SAM site go to their correct state depending on destruction of connection nodes and power sources 
-- TODO: remove SkynetIADS variable to reduce test cupling its not needed for this test, sam and ew site could just be instantiated by ther own.
function TestSkynetIADSAbstractRadarElement:testSAMSiteAndEWRadarLoosesConnectionAndPowerSourceThenAddANewOneAgain()
	self:tearDown()
	self.testIADS = SkynetIADS:create()
	local connectionNode = StaticObject.getByName('SA-6 Connection Node-autonomous-test')
	local nonAutonomousSAM = self.testIADS:addSAMSite('SAM-SA-6'):addConnectionNode(connectionNode)
	self.testIADS:addEarlyWarningRadar('EW-west2')
	
	self.testIADS:buildRadarCoverage()
	
	lu.assertEquals(nonAutonomousSAM:getAutonomousState(), false)
	trigger.action.explosion(connectionNode:getPosition().p, 500)
	--we simulate a call to the event, since in game will be triggered to late to for later checks in this unit test
	nonAutonomousSAM:onEvent(createDeadEvent())
	lu.assertEquals(nonAutonomousSAM:getAutonomousState(), true)
	
	local connectionNodeReAdd = StaticObject.getByName('SA-6 Connection Node-autonomous-readd')
	nonAutonomousSAM:addConnectionNode(connectionNodeReAdd)
	lu.assertEquals(nonAutonomousSAM:getAutonomousState(), false)
	
	local ewRadar = self.testIADS:getEarlyWarningRadarByUnitName('EW-west2')
	ewRadar:addConnectionNode(StaticObject.getByName('ew-west-connection-node-test'))
	
	trigger.action.explosion(StaticObject.getByName('ew-west-connection-node-test'):getPosition().p, 500)
	--we simulate a call to the event, since in game will be triggered to late to for later checks in this unit test
	ewRadar:onEvent(createDeadEvent())
	lu.assertEquals(ewRadar:hasActiveConnectionNode(), false)
	lu.assertEquals(ewRadar:getAutonomousState(), true)
	lu.assertEquals(nonAutonomousSAM:getAutonomousState(), true)
	
	ewRadar:addConnectionNode(Unit.getByName('connection-node-ew'))
	lu.assertEquals(nonAutonomousSAM:getAutonomousState(), false)
	
	ewRadar:addPowerSource(StaticObject.getByName('ew-power-source'))
	trigger.action.explosion(StaticObject.getByName('ew-power-source'):getPosition().p, 500)
	--we simulate a call to the event, since in game will be triggered to late to for later checks in this unit test
	ewRadar:onEvent(createDeadEvent())
	lu.assertEquals(ewRadar:hasWorkingPowerSource(), false)
	lu.assertEquals(nonAutonomousSAM:getAutonomousState(), true)
	
	ewRadar:addPowerSource(StaticObject.getByName('ew-power-source-2'))
	lu.assertEquals(ewRadar:isActive(), true)
	lu.assertEquals(nonAutonomousSAM:getAutonomousState(), false)
	
	--test if a SAM site will stay active if it's in EW mode and it's parent EW radar becomes inoperable as long as SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK is set this will work
	nonAutonomousSAM:setActAsEW(true)
	trigger.action.explosion(StaticObject.getByName('ew-power-source-2'):getPosition().p, 500)
	--we simulate a call to the event, since in game will be triggered to late to for later checks in this unit test
	ewRadar:onEvent(createDeadEvent())
	lu.assertEquals(ewRadar:isActive(), false)
	lu.assertEquals(ewRadar:hasWorkingPowerSource(), false)
	lu.assertEquals(nonAutonomousSAM:isActive(), true)
	lu.assertEquals(nonAutonomousSAM:getAutonomousState(), true)

	--test if command center is destroyed all SAM sites and EW radars should go autonomous:
	ewRadar.powerSources = {}
	nonAutonomousSAM.powerSources = {}
	nonAutonomousSAM:setActAsEW(false)
	ewRadar:setToCorrectAutonomousState()
	ewRadar:informChildrenOfStateChange()
	
	lu.assertEquals(ewRadar:isActive(), true)
	lu.assertEquals(nonAutonomousSAM:isActive(), false)
	lu.assertEquals(nonAutonomousSAM:getAutonomousState(), false)
	
	local commandCenter = StaticObject.getByName('command-center-unit-test')
	local comCenter = self.testIADS:addCommandCenter(commandCenter)
	
	self.testIADS:buildRadarCoverage()
	lu.assertEquals(#comCenter:getChildRadars(), 2)
	trigger.action.explosion(commandCenter:getPosition().p, 5000)
	--we simulate a call to the event, since in game will be triggered to late to for later checks in this unit test
	comCenter:onEvent(createDeadEvent())
	
	lu.assertEquals(self.testIADS:isCommandCenterUsable(), false)
	lu.assertEquals(ewRadar:getAutonomousState(), true)
	lu.assertEquals(nonAutonomousSAM:getAutonomousState(), true)
	
	self.testIADS:deactivate()
end


--TODO: add tests for more check true / false combiations connectionnode power source etc.
function TestSkynetIADSAbstractRadarElement:testSetToCorrectAutonomousState()
	self.samSiteName = "SAM-SA-6-2"
	self:setUp()
	
	self.samSite:goAutonomous()
	lu.assertEquals(self.samSite:getAutonomousState(), true)
	
	function self.samSite:hasActiveConnectionNode()
		return true
	end
	
	local parentRad = {}
	function parentRad:hasWorkingPowerSource()
		return true
	end
	function parentRad:hasActiveConnectionNode()
		return true
	end
	function parentRad:getActAsEW()
		return true
	end
	function parentRad:isDestroyed()
		return false
	end
	
	self.samSite:addParentRadar(parentRad)
	self.samSite:setToCorrectAutonomousState()
	lu.assertEquals(self.samSite:getAutonomousState(), false) 
	
	--check when SAM site does not have active connection node
	self.samSite:goAutonomous()
	lu.assertEquals(self.samSite:getAutonomousState(), true)
	
	function self.samSite:hasActiveConnectionNode()
		return false
	end
	
	local parentRad = {}
	function parentRad:hasWorkingPowerSource()
		return true
	end
	function parentRad:hasActiveConnectionNode()
		return true
	end
	function parentRad:getActAsEW()
		return true
	end
	function parentRad:isDestroyed()
		return false
	end
	
	self.samSite:addParentRadar(parentRad)
	self.samSite:setToCorrectAutonomousState()
	lu.assertEquals(self.samSite:getAutonomousState(), true) 
	
	
end

function TestSkynetIADSAbstractRadarElement:testWillGoLiveWhenAutonomousAndHARMDefenceFinished()
	self.samSiteName = "SAM-SA-6-2"
	self:setUp()
	self.samSite:setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI)
	self.samSite:goSilentToEvadeHARM(1)
	self.samSite:finishHarmDefence()
	lu.assertEquals(self.samSite:isActive(), true)
end

-- TODO: write test for updateMissilesInFlight in AbstractRadarElement
function TestSkynetIADSAbstractRadarElement:testUpdateMissilesInFlight()
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

function TestSkynetIADSAbstractRadarElement:testShutDownShilkaWhenOutOfAmmo()
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

function TestSkynetIADSAbstractRadarElement:testCreateSamSiteFromInvalidGroup()
	self.samSiteName = "Invalid-for-sam"
	self:setUp()
	lu.assertStrMatches(self.samSite:getNatoName(), "UNKNOWN")
	lu.assertEquals(#self.samSite:getRadars(), 0)
	lu.assertEquals(#self.samSite:getLaunchers(), 0)
	lu.assertEquals(#self.samSite:getSearchRadars(), 0)
	lu.assertEquals(#self.samSite:getTrackingRadars(), 0)
end

function TestSkynetIADSAbstractRadarElement:testSamSiteGroupContainingOfOneUnitOnlySA8()
	self.samSiteName = "SAM-SA-8"
	self:setUp()
	lu.assertEquals(#self.samSite:getRadars(), 1)
	lu.assertEquals(#self.samSite:getLaunchers(), 1)
	lu.assertEquals(#self.samSite:getSearchRadars(), 1)
	lu.assertEquals(#self.samSite:getTrackingRadars(), 0)
	lu.assertEquals(self.samSite:getNatoName(), "SA-8")
end

function TestSkynetIADSAbstractRadarElement:testHARMDefenceStates()
	self.samSiteName = "SAM-SA-6"
	self:setUp()
	lu.assertEquals(self.samSite:isActive(), true)
	lu.assertEquals(self.samSite:isScanningForHARMs(), true)
	self.samSite:goSilentToEvadeHARM()
	lu.assertEquals(self.samSite:isScanningForHARMs(), false)
	lu.assertEquals(self.samSite:isActive(), false)
end

function TestSkynetIADSAbstractRadarElement:testGoLiveFailsWhenInHARMDefenceMode()
	self.samSiteName = "SAM-SA-6"
	self:setUp()
	lu.assertEquals(self.samSite:isActive(), true)
	lu.assertEquals(self.samSite:isScanningForHARMs(), true)
	self.samSite:goSilentToEvadeHARM()
	lu.assertEquals(self.samSite:isActive(), false)
	self.samSite:goLive()
	lu.assertEquals(self.samSite:isActive(), false)
end


function TestSkynetIADSAbstractRadarElement:testHARMTimeToImpactCalculation()
	self.samSiteName = "SAM-SA-6"
	self:setUp()
	lu.assertEquals(self.samSite:getSecondsToImpact(100, 10), 36000)
	lu.assertEquals(self.samSite:getSecondsToImpact(10, 400), 90)
	lu.assertEquals(self.samSite:getSecondsToImpact(0, 400), 0)
	lu.assertEquals(self.samSite:getSecondsToImpact(400, 0), 0)
end

function TestSkynetIADSAbstractRadarElement:testSlantRangeCalculationForHARMDefence()
	self.samSiteName = "SAM-SA-6-2"
	self:setUp()
	local iadsContact = IADSContactFactory("test-distance-calculation")
	local radarUnit = self.samSite:getRadars()[1]
	local distanceSlantRange = self.samSite:getDistanceInMetersToContact(iadsContact, radarUnit:getPosition().p)
	local straightLine = mist.utils.round(mist.utils.get2DDist(radarUnit:getPosition().p, iadsContact:getPosition().p), 0)
	lu.assertEquals(distanceSlantRange > straightLine, true)
end

function TestSkynetIADSAbstractRadarElement:testFinishHARMDefence()
	self.samSiteName = "SAM-SA-6-2"
	self:setUp()
	self.samSite:goSilentToEvadeHARM(10)
	lu.assertEquals(self.samSite:isActive(), false)
	self.samSite:finishHarmDefence()
	lu.assertEquals(self.samSite.harmShutdownTime, 0)
	self.samSite:goLive()
	lu.assertEquals(self.samSite:isActive(), true)
end

function TestSkynetIADSAbstractRadarElement:testShutDownWhenOutOfMissiles()
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

function TestSkynetIADSAbstractRadarElement:testActAsEarlyWarningRadar()
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
	
	-- test when stopping EW mode the child SAM site should go dark
	local samSA62 = SkynetIADSSamSite:create(Group.getByName('SAM-SA-6-2'), self.skynetIADS)
	samSA62:setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK)
	samSA62:setupElements()
	samSA62:goLive()
	self.samSite:addChildRadar(samSA62)
	samSA62:addParentRadar(self.samSite)
	self.samSite:informChildrenOfStateChange()
	lu.assertEquals(samSA62:getAutonomousState(), false)
	
	self.samSite:setActAsEW(false)
	lu.assertEquals(self.samSite:isActive(), false)
	lu.assertEquals(samSA62:getAutonomousState(), true)
	lu.assertEquals(samSA62:isActive(), false)
	samSA62:cleanUp()

end

function TestSkynetIADSAbstractRadarElement:testInformOfContactInRangeWhenEarlyWaringRadar()
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

function TestSkynetIADSAbstractRadarElement:testSA2InformOfContactTargetInRangeMethod()
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
	lu.assertEquals(searchRadar:getMaxRangeFindingTarget(), 53499.2265625)

	local launcher = self.samSite:getLaunchers()[1]
	lu.assertEquals(launcher:getRange(), 40000)
	
	local trackingRadar = self.samSite:getTrackingRadars()[1]
	--in its current implementation the SA-2 tracking radar returns the values of the search radar, I presume its only a placeholder in DCS
	lu.assertEquals(trackingRadar:getMaxRangeFindingTarget(), 53499.2265625)	
		
	lu.assertEquals(self.samSite:isActive(), true)
	lu.assertEquals(self.samSite:isTargetInRange(target), true)
end

function TestSkynetIADSAbstractRadarElement:testSA2WillNotGoDarkIfTargetIsInRange()
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

function TestSkynetIADSAbstractRadarElement:testSA2WillNotGoDarkIfOutOfMisslesAndMissilesAreStillInFlight()
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

function TestSkynetIADSAbstractRadarElement:testSA2WillGoDarkWithTargetsInRangeAndHARMDetected()
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

	lu.assertEquals(self.samSite:isActive(), false)
end

function TestSkynetIADSAbstractRadarElement:testSA2WillgoDarkIfOutOfAmmoNoMissilesAreInFlightAndTargetStillInRange()
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
function TestSkynetIADSAbstractRadarElement:testSA2OutOfMissilesNoMissilesInFlightIsInformedOfTargetByIADSHasNotDetectedTargetWithOwnRadar()
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

--[[
This test is no longer required with setEmission available in dcs 2.7
function TestSkynetIADSAbstractRadarElement:testControllerNotDisabledWhenGoingDarkAndOutOfAmmo()
	self.samSiteName = "test-SAM-SA-2-test"
	self:setUp()
	
	local stateCalled = false
	local mockController = {}
	function mockController:setOnOff(state)
		lu.assertEquals(state, false)
		stateCalled = true
	end
	
	local optionCalled = false
	function mockController:setOption(opt, val)
		optionCalled = true
	end
	
	function self.samSite:getController()
		return mockController
	end
	
	function self.samSite:hasRemainingAmmo()
		return false
	end
	
	self.samSite:goDark()
	lu.assertEquals(stateCalled, false)
	lu.assertEquals(optionCalled, true)
	
end
--]]

--[[
This test is no longer required with setEmission available in dcs 2.7
function TestSkynetIADSAbstractRadarElement:testControllerDisabledWhenGoingDarkAndHasRemainingAmmo()
	self.samSiteName = "test-SAM-SA-2-test"
	self:setUp()
	
	local stateCalled = false
	local mockController = {}
	function mockController:setOnOff(state)
		lu.assertEquals(state, false)
		stateCalled = true
	end
	
	local optionCalled = false
	function mockController:setOption(opt, val)
		optionCalled = true
	end
	
	function self.samSite:getController()
		return mockController
	end
	
	function self.samSite:hasRemainingAmmo()
		return true
	end

	self.samSite:goDark()
	lu.assertEquals(stateCalled, true)
	lu.assertEquals(optionCalled, false)
end
--]]
function TestSkynetIADSAbstractRadarElement:testSA2GoLiveRangeInPercentInKillZone()
	self.samSiteName = "SAM-SA-2"
	self:setUp()
	lu.assertIs(self.samSite:getEngagementZone(), SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE)
	self.samSite:setGoLiveRangeInPercent(60)
	
	local target = IADSContactFactory('test-in-firing-range-of-sa-2')
	
	local launcher = self.samSite:getLaunchers()[1]
	lu.assertEquals(launcher:isInRange(target), false)
	lu.assertEquals(self.samSite:isTargetInRange(target), false)
end

function TestSkynetIADSAbstractRadarElement:testSA2GoLiveRangeInPercentSearchRange()
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

function TestSkynetIADSAbstractRadarElement:testSA8GoLiveRangeInPercent()	
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

function TestSkynetIADSAbstractRadarElement:testShutDownTimes()
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

function TestSkynetIADSAbstractRadarElement:testDaisychainSAMOptions()
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

function TestSkynetIADSAbstractRadarElement:testWillSAMShutDownWhenItLoosesPowerAndAMissileIsInFlight()
	self.samSiteName = "SAM-SA-11"
	self:setUp()
	local powerSource = StaticObject.getByName('SA-11-power-source')
	self.samSite:addPowerSource(powerSource)
	self.samSite:goLive()
	
	lu.assertEquals(self.samSite:hasWorkingPowerSource(), true)
	lu.assertEquals(self.samSite:isActive(), true)
	
	-- simulate that the SAM site has a missile in flight
	function self.samSite:hasMissilesInFlight()
		return true
	end

	--trigger the explosion of the power source, this should shut down the SAM site
	trigger.action.explosion(powerSource:getPosition().p, 100)
	--we simulate a call to the event, since in game will be triggered to late to for later checks in this unit test
	self.samSite:onEvent(createDeadEvent())
	lu.assertEquals(self.samSite:hasWorkingPowerSource(), false)
	lu.assertEquals(self.samSite:isActive(), false)
end

function TestSkynetIADSAbstractRadarElement:testSetPointDefence()
	self.samSiteName = "SAM-SA-10"
	self:setUp()
	local pd = self.skynetIADS:addSAMSite("SAM-SA-15-1")
	lu.assertEquals(pd:getIsAPointDefence(), false)
	self.samSite:addPointDefence(pd)
	lu.assertEquals(pd:getIsAPointDefence(), true)
end

function TestSkynetIADSAbstractRadarElement:testPointDefencesGoLive()

	local stateSet = false
	local mockPD1 = {}
	function mockPD1:getActAsEW()
		return false
	end
	function mockPD1:setIsAPointDefence(state)
	
	end
	function mockPD1:setActAsEW(state)
		stateSet = true
	end
	
	function mockPD1:cleanUp()
	
	end
	
	self.samSiteName = "SAM-SA-10"
	self:setUp()
	self.samSite:addPointDefence(mockPD1)
	lu.assertEquals(self.samSite:pointDefencesGoLive(), true)
	lu.assertEquals(stateSet, true)
	
	
	self:tearDown()
	
	local stateSet = false
	local mockPD1 = {}
	function mockPD1:getActAsEW()
		return true
	end
	function mockPD1:setActAsEW(state)
		stateSet = true
	end
	function mockPD1:setIsAPointDefence(state)
	
	end
	
	function mockPD1:cleanUp()
	
	end
	
	self.samSiteName = "SAM-SA-10"
	self:setUp()
	self.samSite:addPointDefence(mockPD1)
	lu.assertEquals(self.samSite:pointDefencesGoLive(), false)
	lu.assertEquals(stateSet, false)
	
	
end

function TestSkynetIADSAbstractRadarElement:testPointDefenceActiveWhenSAMGoesDarkDueToHARMDefence()
	self.samSiteName = "SAM-SA-10"
	self:setUp()
	self.samSite:setActAsEW(true)
	
	--in this group there are two SA-15 units:
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

end

function TestSkynetIADSAbstractRadarElement:testCleanUpOldObjectsIdentifiedAsHARMS()
	self.samSiteName = "SAM-SA-10"
	self:setUp()
	local mockContact = {}
	function mockContact:getAge()
		return 10
	end
	table.insert(self.samSite.objectsIdentifiedAsHarms, mockContact)
	lu.assertEquals(self.samSite:getNumberOfObjectsItentifiedAsHARMS(), 1)
end

--TODO:write Unit test
function TestSkynetIADSAbstractRadarElement:testPointDefenceWhenOnlyOneEWRadarIsActiveAndAmmoIsStillAvailable()

end

function TestSkynetIADSAbstractRadarElement:testPointDefencesAreNotActivatedWhenNoHARMSRemoved()
	self.samSiteName = "SAM-SA-10"
	self:setUp()	
	local sa15 = Group.getByName("SAM-SA-15-1")
	local pointDefence = SkynetIADSSamSite:create(sa15, self.skynetIADS)
	self.samSite:addPointDefence(pointDefence)
	local calledStopPointDefence = false
	function self.samSite:pointDefencesStopActingAsEW()
		calledStopPointDefence = true
	end
	self.samSite:evaluateIfTargetsContainHARMs()
	lu.assertEquals(calledStopPointDefence, false)
end

function TestSkynetIADSAbstractRadarElement:testPointDefenceWillGoDarkWhenSAMItIsProtectingGoesDark()
	self.samSiteName = "SAM-SA-10"
	self:setUp()	
	local sa15 = Group.getByName("SAM-SA-15-1")
	local pointDefence = SkynetIADSSamSite:create(sa15, self.skynetIADS)
	self.samSite:addPointDefence(pointDefence)
	pointDefence:setActAsEW(true)
	self.samSite:goDark()
	lu.assertEquals(pointDefence:isActive(), false)
end


function TestSkynetIADSAbstractRadarElement:testPatriotLauncherAndRadar()

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
	lu.assertEquals(self.samSite:getCanEngageHARM(), true)
	
	local radar = self.samSite:getSearchRadars()[1]
	lu.assertEquals(radar:getMaxRangeFindingTarget(), 173872.484375)
	
	local launcher = self.samSite:getLaunchers()[1]
	lu.assertEquals(launcher:getInitialNumberOfMissiles(), 4)
	lu.assertEquals(launcher:getRange(), 120000)
end

function TestSkynetIADSAbstractRadarElement:testRapierLauncherAndRadar()
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

function TestSkynetIADSAbstractRadarElement:testRolandLauncherAndRadar()
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

function TestSkynetIADSAbstractRadarElement:testNASAMS()

	self.samSiteName = "BLUE-SAM-NASAMS"
	self:setUp()
	lu.assertEquals(self.samSite:getNatoName(), "NASAMS")
	lu.assertEquals(self.samSite:getHARMDetectionChance(),90)
	lu.assertEquals(self.samSite:getCanEngageHARM(), true)
	lu.assertEquals(self.samSite:getRadars()[1]:getMaxRangeFindingTarget(), 26749.61328125)
	lu.assertEquals(self.samSite:getLaunchers()[1]:getRange(), 57000)
	lu.assertEquals(self.samSite:getLaunchers()[1]:getInitialNumberOfMissiles(), 6)
	
	lu.assertEquals(self.samSite:getLaunchers()[2]:getRange(), 61000)
	lu.assertEquals(self.samSite:getLaunchers()[2]:getInitialNumberOfMissiles(), 6)
	
end

--[[
function TestSkynetIADSAbstractRadarElement:testCallMethodOnTableElements()
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

--[[
this test ensures that targets are cached in the sam site, calls to the getDetectedTargets function of the controller are cpu intensive
multiple calls are made within miliseconds on the same SAM or EW site when updating the IADS status, therefore only the first call ist to the acutall controller
after that results are cached for a few seconds (default IADS setting is for one update cycle, e.g. 5 seconds).
--]]

function TestSkynetIADSAbstractRadarElement:testCacheDetectedTargets()
	self.skynetIADS:addSAMSitesByPrefix('SAM')
	self.samSite = self.skynetIADS:getSAMSiteByGroupName('SAM-SA-10')
	self.samSite:goDark()
	self.samSite:goLive()
	-- deactivate no cache after goLive
	self.samSite.noCacheActiveForSecondsAfterGoLive = 0
	lu.assertEquals(self.samSite:getDetectedTargets() == self.samSite:getDetectedTargets(), true)
	self.samSite.cachedTargetsMaxAge = -1
	lu.assertEquals(self.samSite:getDetectedTargets() == self.samSite:getDetectedTargets(), false)
	
end

--[[
the IADS turns controllers of a SAM or EW site on and off. This has the advantage that a SAM site will react faster  after beeing waken up by the IADS
the down side is that the first call to getDetectedTarget() on a controller after a goLive returns no targets, this result is cached causing the SAM site to misbehave in the IADS.
Therefore for the first seconds after goLive the cache of getDetectedTargets is bypassed, ensuring targets are stored and the SAM site behaves correctly. 
--]]
function TestSkynetIADSAbstractRadarElement:testCacheInvalidatedFirstfewSecondsAfterControllerIsActivated()
	self.skynetIADS:addSAMSitesByPrefix('SAM')
	self.samSite = self.skynetIADS:getSAMSiteByGroupName('SAM-SA-10')
	self.samSite:goDark()
	self.samSite:goLive()
	lu.assertEquals(self.samSite:getDetectedTargets() == self.samSite:getDetectedTargets(), false)
end

function TestSkynetIADSAbstractRadarElement:testCalculateAspectInDegrees()
	self.samSite = self.skynetIADS:getSAMSiteByGroupName('SAM-SA-10')
	lu.assertEquals(self.samSite:calculateAspectInDegrees(0, 90), 90)
	lu.assertEquals(self.samSite:calculateAspectInDegrees(300, 90), 150)
	lu.assertEquals(self.samSite:calculateAspectInDegrees(010, 280), 90)
	lu.assertEquals(self.samSite:calculateAspectInDegrees(190, 350), 160)
	lu.assertEquals(self.samSite:calculateAspectInDegrees(090, 270), 180)
	lu.assertEquals(self.samSite:calculateAspectInDegrees(010, 170), 160)
end

function TestSkynetIADSAbstractRadarElement:testShallIgnoreHARMShutdown()
	self.samSiteName = "SAM-SA-10"
	self:setUp()
	
	--older sam site that can not engage HARMs (air weapons)
	function self.samSite:hasEnoughLaunchersToEngageMissiles(value)
		return true
	end
	
	function self.samSite:hasRemainingAmmoToEngageMissiles(value)
		return true
	end
	
	function self.samSite:getCanEngageHARM()
		return false
	end
	
	function self.samSite:pointDefencesHaveRemainingAmmo(value)
		return false
	end
	
	function self.samSite:pointDefencesHaveEnoughLaunchers(value)
		return false
	end

	lu.assertEquals(self.samSite:shallIgnoreHARMShutdown(), false)
	
	

	function self.samSite:hasEnoughLaunchersToEngageMissiles(value)
		return false
	end
	
	function self.samSite:hasRemainingAmmoToEngageMissiles(value)
		return false
	end
	
	function self.samSite:getCanEngageHARM()
		return true
	end
	
	function self.samSite:pointDefencesHaveRemainingAmmo(value)
		return false
	end
	
	function self.samSite:pointDefencesHaveEnoughLaunchers(value)
		return false
	end

	lu.assertEquals(self.samSite:shallIgnoreHARMShutdown(), false)
	
	
	function self.samSite:hasEnoughLaunchersToEngageMissiles(value)
		return false
	end
	
	function self.samSite:hasRemainingAmmoToEngageMissiles(value)
		return true
	end
	
	function self.samSite:getCanEngageHARM()
		return true
	end
	
	function self.samSite:pointDefencesHaveRemainingAmmo(value)
		return false
	end
	
	function self.samSite:pointDefencesHaveEnoughLaunchers(value)
		return true
	end

	lu.assertEquals(self.samSite:shallIgnoreHARMShutdown(), false)
	
	
	function self.samSite:hasEnoughLaunchersToEngageMissiles(value)
		return true
	end
	
	function self.samSite:hasRemainingAmmoToEngageMissiles(value)
		return false
	end
	
	function self.samSite:getCanEngageHARM()
		return true
	end
	
	function self.samSite:pointDefencesHaveRemainingAmmo(value)
		return true
	end
	
	function self.samSite:pointDefencesHaveEnoughLaunchers(value)
		return false
	end

	lu.assertEquals(self.samSite:shallIgnoreHARMShutdown(), false)
	
	
	function self.samSite:hasEnoughLaunchersToEngageMissiles(value)
		return true
	end
	
	function self.samSite:hasRemainingAmmoToEngageMissiles(value)
		return true
	end
	
	function self.samSite:getCanEngageHARM()
		return true
	end
	
	function self.samSite:pointDefencesHaveRemainingAmmo(value)
		return false
	end
	
	function self.samSite:pointDefencesHaveEnoughLaunchers(value)
		return false
	end

	lu.assertEquals(self.samSite:shallIgnoreHARMShutdown(), true)
	

	
	function self.samSite:hasEnoughLaunchersToEngageMissiles(value)
		return true
	end
	
	function self.samSite:hasRemainingAmmoToEngageMissiles(value)
		return true
	end
	
	function self.samSite:getCanEngageHARM()
		return true
	end
	
	function self.samSite:pointDefencesHaveRemainingAmmo(value)
		return true
	end
	
	function self.samSite:pointDefencesHaveEnoughLaunchers(value)
		return true
	end

	lu.assertEquals(self.samSite:shallIgnoreHARMShutdown(), true)
	
	
	
	function self.samSite:hasEnoughLaunchersToEngageMissiles(value)
		return true
	end
	
	function self.samSite:hasRemainingAmmoToEngageMissiles(value)
		return false
	end
	
	function self.samSite:getCanEngageHARM()
		return true
	end
	
	function self.samSite:pointDefencesHaveRemainingAmmo(value)
		return true
	end
	
	function self.samSite:pointDefencesHaveEnoughLaunchers(value)
		return true
	end

	lu.assertEquals(self.samSite:shallIgnoreHARMShutdown(), true)
	
	
	
	function self.samSite:hasEnoughLaunchersToEngageMissiles(value)
		return true
	end
	
	function self.samSite:hasRemainingAmmoToEngageMissiles(value)
		return true
	end
	
	function self.samSite:getCanEngageHARM()
		return true
	end
	
	function self.samSite:pointDefencesHaveRemainingAmmo(value)
		return false
	end
	
	function self.samSite:pointDefencesHaveEnoughLaunchers(value)
		return true
	end

	lu.assertEquals(self.samSite:shallIgnoreHARMShutdown(), true)
	
	
	
	function self.samSite:hasEnoughLaunchersToEngageMissiles(value)
		return true
	end
	
	function self.samSite:hasRemainingAmmoToEngageMissiles(value)
		return true
	end
	
	function self.samSite:getCanEngageHARM()
		return true
	end
	
	function self.samSite:pointDefencesHaveRemainingAmmo(value)
		return true
	end
	
	function self.samSite:pointDefencesHaveEnoughLaunchers(value)
		return false
	end

	lu.assertEquals(self.samSite:shallIgnoreHARMShutdown(), true)
	

end

end
