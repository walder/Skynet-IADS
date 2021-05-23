do

TestSkynetIADSHARMDetection = {}

function TestSkynetIADSHARMDetection:setUp()
	local iads = SkynetIADS:create()
	self.harmDetection = SkynetIADSHARMDetection:create(iads)
end

function TestSkynetIADSHARMDetection:testEvaluateContactsContactIsHARMInClimb()
	
	--test with a contact that shall be identified as a HARM
	local mockContactHARM = {}
	
	function mockContactHARM:getGroundSpeedInKnots(round)
		return 1500
	end
	
	function mockContactHARM:isHARMStateUnknown()
		return true
	end
	
	function mockContactHARM:getSimpleAltitudeProfile()
		return {SkynetIADSContact.CLIMB}
	end
	
	local harmStateCalled = false
	function mockContactHARM:setHARMState(state)
		harmStateCalled = true
		lu.assertEquals(state, SkynetIADSContact.HARM)
	end

	function mockContactHARM:isIdentifiedAsHARM()
		return true
	end
	
	local mockRadar = {}
	function mockRadar:getHARMDetectionChance()
		return 50
	end
	
	function mockContactHARM:getAbstractRadarElementsDetected()
		return {mockRadar}
	end
	
	local probCalled = false
	function self.harmDetection:shallReactToHARM(prob)
		lu.assertEquals(prob, 50)
		probCalled = true
		return true
	end

	
	local contactInform = false
	function self.harmDetection:informRadarsOfHARM(contact)
		lu.assertEquals(mockContactHARM, contact)
		contactInform = true
	end

	
	self.harmDetection:setContacts({mockContactHARM})
	self.harmDetection:evaluateContacts()
	
	lu.assertEquals(harmStateCalled, true)
	lu.assertEquals(probCalled, true)
	lu.assertEquals(contactInform, true)
end

function TestSkynetIADSHARMDetection:testGetDetectionProbability()
	
	local mockContact = {}
	
	local mockSAM1 = {}
	function mockSAM1:getHARMDetectionChance()
		return 60
	end
	
	local mockSam2 = {}
	function mockSam2:getHARMDetectionChance()
		return 30
	end
	
	function mockContact:getAbstractRadarElementsDetected()
		return {mockSAM1, mockSam2}
	end
	
	lu.assertEquals(self.harmDetection:getDetectionProbability(mockContact), 72)
	
	function mockSAM1:getHARMDetectionChance()
		return 20
	end
	
	function mockSam2:getHARMDetectionChance()
		return 90
	end
	
	lu.assertEquals(self.harmDetection:getDetectionProbability(mockContact), 92)
	
end

end