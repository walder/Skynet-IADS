do
TestSkynetIADSEWRadar = {}

function TestSkynetIADSEWRadar:setUp()
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

function TestSkynetIADSEWRadar:tearDown()
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

function TestSkynetIADSEWRadar:testCompleteDestructionOfEarlyWarningRadar()
		
		local ewRadar = SkynetIADSAWACSRadar:create(Unit.getByName('EW-west22-destroy'), SkynetIADS:create('test'))
		ewRadar:setupElements()
		ewRadar:setActAsEW(true)
		ewRadar:goLive()
		
		local sa61 = SkynetIADSSamSite:create(Group.getByName('SAM-SA-6'), SkynetIADS:create('test'))
		local sa62 = SkynetIADSSamSite:create(Group.getByName('SAM-SA-6-2'), SkynetIADS:create('test'))
	
		--build radar association
		ewRadar:addChildRadar(sa61)
		sa61:addParentRadar(ewRadar)
		ewRadar:addChildRadar(sa62)
		sa62:addParentRadar(ewRadar)
		
		sa61:setToCorrectAutonomousState()
		sa62:setToCorrectAutonomousState()
		
		lu.assertEquals(ewRadar:hasRemainingAmmo(), true)
		lu.assertEquals(ewRadar:isActive(), true)
		lu.assertEquals(ewRadar:getDCSRepresentation():isExist(), true)
		lu.assertEquals(sa61:getAutonomousState(), false)
		lu.assertEquals(sa62:getAutonomousState(), false)
		trigger.action.explosion(ewRadar:getDCSRepresentation():getPosition().p, 500)
		--we simulate a call to the event, since in game will be triggered to late to for later checks in this unit test
		ewRadar:onEvent(createDeadEvent())
		lu.assertEquals(ewRadar:getDCSRepresentation():isExist(), false)
	
		lu.assertEquals(ewRadar:isActive(), false)

		lu.assertEquals(sa61:getAutonomousState(), true)
		lu.assertEquals(sa62:getAutonomousState(), true)
		
		sa61:cleanUp()
		sa62:cleanUp()
		ewRadar:cleanUp()
end

function TestSkynetIADSEWRadar:testFinishHARMDefence()
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

function TestSkynetIADSEWRadar:testGoDarkWhenAutonomousByDefault()
	self.ewRadarName = "EW-west2"
	self:setUp()
	lu.assertEquals(self.ewRadar:isActive(), true)
	function self.ewRadar:hasActiveConnectionNode()
		return false
	end
	self.ewRadar:goAutonomous()
	lu.assertEquals(self.ewRadar:isActive(), false)
end

end