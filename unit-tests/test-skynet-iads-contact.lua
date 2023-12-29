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
	function self.contact:getDCSRepresentation()
		return Unit.getByName('test-not-in-firing-range-of-sa-2')
	end
	--we set time in the past, to simulate distance traveled
	self.contact.lastTimeSeen = timer.getAbsTime() - 1000
	lu.assertEquals(self.contact:getAge(), 1000)
	self.contact:refresh()
	lu.assertEquals(self.contact:getGroundSpeedInKnots(0), 989)
end

function TestSyknetIADSContact:testGetHeightInFeetMSL()
	lu.assertEquals(self.contact:getHeightInFeetMSL(), 5015)
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
	function self.contact:getDCSRepresentation()
	 return mockDCSObject
	end
	
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
	function self.contact:getDCSRepresentation()
	 return mockDCSObject
	end
	
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
	lu.assertEquals(self.contact.harmState, SkynetIADSContact.HARM_UNKNOWN)
	self.contact:setHARMState(SkynetIADSContact.HARM)
	lu.assertEquals(self.contact.harmState, SkynetIADSContact.HARM)
end

function TestSyknetIADSContact:testGetMagneticHeading()
	lu.assertEquals(self.contact:getMagneticHeading(), 347)
	
	function self.contact:isExist()
		return false
	end
	
	lu.assertEquals(self.contact:getMagneticHeading(), -1)
end

function TestSyknetIADSContact:testIsIdentifiedAsHARM()
	lu.assertEquals(self.contact:isIdentifiedAsHARM(), false)
	self.contact:setHARMState(SkynetIADSContact.HARM)
	lu.assertEquals(self.contact:isIdentifiedAsHARM(), true)
end

function TestSyknetIADSContact:testIsHARMStateUnknown()
	lu.assertEquals(self.contact:isHARMStateUnknown(), true)
	self.contact:setHARMState(SkynetIADSContact.NOT_HARM)
	lu.assertEquals(self.contact:isHARMStateUnknown(), false)
end

function TestSyknetIADSContact:testAddAbstractRadarElementDetected()
	local radar = {}
	self.contact:addAbstractRadarElementDetected(radar)
	lu.assertEquals(#self.contact:getAbstractRadarElementsDetected(), 1)
	
	--adding the same radar again, shall not result in it being added:
	self.contact:addAbstractRadarElementDetected(radar)
	lu.assertEquals(#self.contact:getAbstractRadarElementsDetected(), 1)
	
	local radar2 = {}
	self.contact:addAbstractRadarElementDetected(radar2)
	lu.assertEquals(#self.contact:getAbstractRadarElementsDetected(), 2)
end	

function TestSyknetIADSContact:testGetTypeNameUNKNOWN()
	function self.contact:getDCSRepresentation()
		return nil
	end
	lu.assertEquals(self.contact:getTypeName(), "UNKNOWN")
end

function TestSyknetIADSContact:testGetTypeNameisHARM()
	self.contact:setHARMState(SkynetIADSContact.HARM)
	lu.assertEquals(self.contact:getTypeName(), SkynetIADSContact.HARM)
end

function TestSyknetIADSContact:testGetTypeNameisUnit()
	lu.assertEquals(self.contact:getTypeName(), "AH-1W")
end

end