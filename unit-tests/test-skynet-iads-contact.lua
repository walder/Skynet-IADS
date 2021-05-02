do

TestSyknetIADSContact = {}

function TestSyknetIADSContact:setUp()
	local radarTarget = {}
	radarTarget.object = Unit.getByName('test-outer-search-range')
	self.contact = SkynetIADSContact:create(radarTarget)
end

function TestSyknetIADSContact:testGetNumberOfTimesHitByRadar()
	lu.assertEquals(self.contact:getNumberOfTimesHitByRadar(), 0)
	self.contact:refresh()
	lu.assertEquals(self.contact:getNumberOfTimesHitByRadar(), 1)
end

function TestSyknetIADSContact:testRefresh()
	self.contact:refresh()
	self.contact.dcsObject = Unit.getByName('test-not-in-firing-range-of-sa-2')
	--we set time in the past, to simulate distance traveled
	self.contact.lastTimeSeen = timer.getAbsTime() - 1000
	lu.assertEquals(self.contact:getAge(), 1000)
	self.contact:refresh()
	lu.assertEquals(self.contact:getGroundSpeedInKnots(0), 989)
end

function TestSyknetIADSContact:testGetHeightInFeetMSL()
	lu.assertEquals(self.contact:getHeightInFeetMSL(), 4992)
end

function TestSyknetIADSContact:testUpdateSimpleAltitudeProfile()
	local mockDCSObject = {}
	
	function mockDCSObject:getPosition()
		return {y=100}
	end
	self.contact.position.y = 200
	self.contact.dcsObject = mockDCSObject
	
	self.contact:updateSimpleAltitudeProfile()
	local altProfile = self.contact:getSimpleAltitudeProfile()
	lu.assertEquals(altProfile[1], SkynetIADSContact.DESCEND)
	lu.assertEquals(#altProfile, 1)
	
	function mockDCSObject:getPosition()
		return {y=200}
	end
	self.contact.position.y = 100
	
	self.contact:updateSimpleAltitudeProfile()
	local altProfile = self.contact:getSimpleAltitudeProfile()
	lu.assertEquals(altProfile[2], SkynetIADSContact.CLIMB)
	lu.assertEquals(#altProfile, 2)
	
end

end
