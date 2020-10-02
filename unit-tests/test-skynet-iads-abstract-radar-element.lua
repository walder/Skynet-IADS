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

function TestSkynetIADSAbstractRadarElement:testAddChildRadar()
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

function TestSkynetIADSAbstractRadarElement:testAddParentRadar()
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
	lu.assertEquals(nonAutonomousSAM:getAutonomousState(), true)
	
	local connectionNodeReAdd = StaticObject.getByName('SA-6 Connection Node-autonomous-readd')
	nonAutonomousSAM:addConnectionNode(connectionNodeReAdd)
	lu.assertEquals(nonAutonomousSAM:getAutonomousState(), false)
	
	local ewRadar = self.testIADS:getEarlyWarningRadarByUnitName('EW-west2')
	ewRadar:addConnectionNode(StaticObject.getByName('ew-west-connection-node-test'))
	
	trigger.action.explosion(StaticObject.getByName('ew-west-connection-node-test'):getPosition().p, 500)
	lu.assertEquals(ewRadar:hasActiveConnectionNode(), false)
	lu.assertEquals(ewRadar:getAutonomousState(), true)
	lu.assertEquals(nonAutonomousSAM:getAutonomousState(), true)
	
	ewRadar:addConnectionNode(Unit.getByName('connection-node-ew'))
	lu.assertEquals(nonAutonomousSAM:getAutonomousState(), false)
	
	ewRadar:addPowerSource(StaticObject.getByName('ew-power-source'))
	trigger.action.explosion(StaticObject.getByName('ew-power-source'):getPosition().p, 500)
	lu.assertEquals(ewRadar:hasWorkingPowerSource(), false)
	lu.assertEquals(nonAutonomousSAM:getAutonomousState(), true)
	
	ewRadar:addPowerSource(StaticObject.getByName('ew-power-source-2'))
	lu.assertEquals(ewRadar:isActive(), true)
	lu.assertEquals(nonAutonomousSAM:getAutonomousState(), false)
	
	--test if a SAM site will stay active if it's in EW mode and it's parent EW radar becomes inoperable as long as SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK is set this will work
	nonAutonomousSAM:setActAsEW(true)
	trigger.action.explosion(StaticObject.getByName('ew-power-source-2'):getPosition().p, 500)
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

function TestSkynetIADSAbstractRadarElement:testCheckSA6GroupNumberOfLaunchersAndRangeValuesAndSearchRadarsAndNatoName()
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

function TestSkynetIADSAbstractRadarElement:testCheckSA10GroupNumberOfLaunchersAndSearchRadarsAndNatoName()
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

function TestSkynetIADSAbstractRadarElement:testCheckSA3GroupNumberOfLaunchersAndRangeValuesAndSearchRadarsAndNatoName()
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

function TestSkynetIADSAbstractRadarElement:testShilkaGroupLaunchersSearchRadarRangesAndHARMDefenceChance()
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

function TestSkynetIADSAbstractRadarElement:testSA15LaunchersSearchRadarRangeAndHARMDefenceChance()
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

function TestSkynetIADSAbstractRadarElement:testCreateSamSiteFromInvalidGroup()
	self.samSiteName = "Invalid-for-sam"
	self:setUp()
	lu.assertStrMatches(self.samSite:getNatoName(), "UNKNOWN")
	lu.assertEquals(#self.samSite:getRadars(), 0)
	lu.assertEquals(#self.samSite:getLaunchers(), 0)
	lu.assertEquals(#self.samSite:getSearchRadars(), 0)
	lu.assertEquals(#self.samSite:getTrackingRadars(), 0)
end

function TestSkynetIADSAbstractRadarElement:testSA13LaunchersSearchRadarRangeAndHARMDefence()
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

function TestSkynetIADSAbstractRadarElement:testEvaluateIfTargetsContainHARMsShallReactTrue()
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


function TestSkynetIADSAbstractRadarElement:testNoErrorTriggeredWhenRadarUnitDestroyedAndHARMDefenceIsRunning()
	
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

function TestSkynetIADSAbstractRadarElement:testEvaluateIfTargetsContainHARMsShallReactFalse()
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
	self.samSite:goSilentToEvadeHARM()
	lu.assertEquals(self.samSite:isActive(), false)
	self.samSite:finishHarmDefence()
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

function TestSkynetIADSAbstractRadarElement:testInformOfContactMultipleTimesOnlyOneIsTargetInRangeCall()
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

function TestSkynetIADSAbstractRadarElement:testInformOfContactInRange()
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
	lu.assertEquals(searchRadar:getMaxRangeFindingTarget(), 106998.453125)

	local launcher = self.samSite:getLaunchers()[1]
	lu.assertEquals(launcher:getRange(), 40000)
	
	local trackingRadar = self.samSite:getTrackingRadars()[1]
	--in its current implementation the SA-2 tracking radar returns the values of the search radar, I presume its only a placeholder in DCS
	lu.assertEquals(trackingRadar:getMaxRangeFindingTarget(), 106998.453125)	
		
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
	lu.assertEquals(self.samSite:hasWorkingPowerSource(), false)
	lu.assertEquals(self.samSite:isActive(), false)
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

function TestSkynetIADSAbstractRadarElement:testPointDefenceWhenOnlyOneEWRadarIsActiveAndAmmoIsStillAvailable()
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
	
	-- we start with one contact the sam detects
	function self.samSite:getDetectedTargets()
		return {iadsContact}
	end
	
	-- in this test we simulate an impact point that is close enough for the contact to be identified as a HARM
	function self.samSite:getDistanceInMetersToContact(a, b)
		return 50
	end
	
	--we simulate the impact point to be a radar of the SAM site
	function self.samSite:calculateImpactPoint(a, b)
		return self:getRadars()[1]:getPosition().p
	end
	
	--we ensure it will react to HARM (no probability in this test)
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
	
	
	-- set the state for HARM Ignore to true and check if the method returns a sam site for daisy chaining
	lu.assertEquals(self.samSite:setIgnoreHARMSWhilePointDefencesHaveAmmo(true), self.samSite)
	
	--this test should not provoke a HARM inbound response due to the point defence still having ammo and the number of HARMS is not greater than the point defences
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
	lu.assertEquals(self.samSite:shallIgnoreHARMShutdown(), false)
	lu.assertEquals(self.samSite:pointDefencesHaveEnoughLaunchers(self.samSite:getNumberOfObjectsItentifiedAsHARMS()), false)
	lu.assertEquals(self.samSite:getNumberOfObjectsItentifiedAsHARMS(), 3)	
	self.samSite:evaluateIfTargetsContainHARMs(self.samSite)
	lu.assertEquals(calledShutdown, true)
	
	self.samSite.objectsIdentifiedAsHarms = {}
	calledShutdown = false
	pointDefence:setActAsEW(false)
	pointDefence:goDark()
	
	--this test is for when there are equal number of point defence launchers and HARMs inbound, radar emitter will not shut down
	function self.samSite:getDetectedTargets()
		return {iadsContact, iadsContact2}
	end

	self.samSite:setIgnoreHARMSWhilePointDefencesHaveAmmo(true)
	self.samSite:evaluateIfTargetsContainHARMs(self.samSite)
	lu.assertEquals(self.samSite:getNumberOfObjectsItentifiedAsHARMS(), 2)	
	lu.assertEquals(self.samSite:shallIgnoreHARMShutdown(), true)
	lu.assertEquals(self.samSite:pointDefencesHaveEnoughLaunchers(self.samSite:getNumberOfObjectsItentifiedAsHARMS()), true)
	self.samSite:evaluateIfTargetsContainHARMs(self.samSite)
	lu.assertEquals(calledShutdown, false)
	lu.assertEquals(self.samSite:isActive(), true)
	lu.assertEquals(pointDefence:isActive(), true)
	
	self.samSite.objectsIdentifiedAsHarms = {}
	calledShutdown = false
	pointDefence:setActAsEW(false)
	pointDefence:goDark()
	
	
	--this tests if there are lower number of point defence launchers than HARMs inbound, radar emitter will not shut down:
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

function TestSkynetIADSAbstractRadarElement:testHQ7LauncherAndRadar()
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
the IADS turns controllers of a SAM or EW site on and of. This has the advantage that a SAM site will react faster  after beeing waken up by the IADS
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

end
