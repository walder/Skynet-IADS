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
	local called = 0
	function self.contact:updateSimpleAltitudeProfile()
		called = 1
	end
	self.contact:refresh()
	lu.assertEquals(called, 1)
	self.contact.dcsObject = Unit.getByName('test-not-in-firing-range-of-sa-2')
	--we set time in the past, to simulate distance traveled
	self.contact.lastTimeSeen = timer.getAbsTime() - 1000
	lu.assertEquals(self.contact:getAge(), 1000)
	self.contact:refresh()
	lu.assertEquals(self.contact:getGroundSpeedInKnots(0), 989)
end

function TestSyknetIADSContact:testGetHeightInFeetMSL()
	lu.assertEquals(self.contact:getHeightInFeetMSL(), 4974)
end

function TestSyknetIADSContact:testUpdateSimpleAltitudeProfile()
	local mockDCSObject = {}

	
	function mockDCSObject:getPosition()
		local p = {}
		p.y = 100
		local ret = {}
		ret.p = p
		return ret
	end
	self.contact.position.p.y = 200
	self.contact.dcsObject = mockDCSObject
	
	self.contact:updateSimpleAltitudeProfile()
	local altProfile = self.contact:getSimpleAltitudeProfile()
	lu.assertEquals(altProfile[1], SkynetIADSContact.DESCEND)
	lu.assertEquals(#altProfile, 1)


	function mockDCSObject:getPosition()
		local p = {}
		p.y = 200
		local ret = {}
		ret.p = p
		return ret
	end
	self.contact.position.p.y = 200
	self.contact.dcsObject = mockDCSObject
	
	self.contact:updateSimpleAltitudeProfile()
	local altProfile = self.contact:getSimpleAltitudeProfile()
	lu.assertEquals(altProfile[1], SkynetIADSContact.DESCEND)
	lu.assertEquals(#altProfile, 1)



	function mockDCSObject:getPosition()
		local p = {}
		p.y = 200
		local ret = {}
		ret.p = p
		return ret
	end
	self.contact.position.p.y = 100
	
	self.contact:updateSimpleAltitudeProfile()
	local altProfile = self.contact:getSimpleAltitudeProfile()
	lu.assertEquals(altProfile[2], SkynetIADSContact.CLIMB)
	lu.assertEquals(#altProfile, 2)
	
	
	function mockDCSObject:getPosition()
		local p = {}
		p.y = 200
		local ret = {}
		ret.p = p
		return ret
	end
	self.contact.position.p.y = 100
	
	self.contact:updateSimpleAltitudeProfile()
	local altProfile = self.contact:getSimpleAltitudeProfile()
	lu.assertEquals(altProfile[2], SkynetIADSContact.CLIMB)
	lu.assertEquals(#altProfile, 2)
end

function TestSyknetIADSContact:testSetIsHARM()
	lu.assertEquals(self.contact.isHARM, false)
	self.contact:setIsHARM(true)
	lu.assertEquals(self.contact.isHARM, true)
end

function TestSyknetIADSContact:testGetMagneticHeading()
	lu.assertEquals(self.contact:getMagneticHeading(), 351)
	
	function self.contact:isExist()
		return false
	end
	
	lu.assertEquals(self.contact:getMagneticHeading(), -1)
end

end