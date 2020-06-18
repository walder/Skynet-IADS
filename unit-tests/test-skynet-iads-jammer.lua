do
TestSkynetIADSJammer = {}

function TestSkynetIADSJammer:setUp()
	self.emitter = Unit.getByName('jammer-source')	
	self.mockIADS = {}
	function self.mockIADS:getDebugSettings()
		return {}
	end
	self.jammer = SkynetIADSJammer:create(self.emitter, self.mockIADS)
end

function TestSkynetIADSJammer:tearDown()
	self.jammer:masterArmSafe()
end

function TestSkynetIADSJammer:testSetJammerDistance()
	self.jammer:setMaximumEffectiveDistance(20)
	lu.assertEquals(self.jammer.maximumEffectiveDistanceNM, 20)
end

function TestSkynetIADSJammer:testSetupJammerAndRunCycle()
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

function TestSkynetIADSJammer:testIsActiveForUnknownType()
	lu.assertEquals(self.jammer:isKnownRadarEmitter('ABC-Test'), false)
end

function TestSkynetIADSJammer:testIsActiveForKnownType()
	lu.assertEquals(self.jammer:isKnownRadarEmitter('SA-2'), true)
end

function TestSkynetIADSJammer:testCleanUpJammer()
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

function TestSkynetIADSJammer:testAddJammerFunction()

	local function f(distanceNM)
		return 2 * distanceNM
	end
	self.jammer:addFunction('SA-99', f)
	lu.assertEquals(self.jammer:getSuccessProbability(20, 'SA-99'), 40)
	lu.assertEquals(self.jammer:isKnownRadarEmitter('SA-99'), true)
	self.jammer:disableFor('SA-99')
	lu.assertEquals(self.jammer:isKnownRadarEmitter('SA-99'), false)
end

function TestSkynetIADSJammer:testDestroyEmitter()
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
end