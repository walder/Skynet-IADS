do

TestSkynetIADSHARMDetection = {}

function TestSkynetIADSHARMDetection:setUp()
	local iads = SkynetIADS:create()
	self.harmDetection = SkynetIADSHARMDetection:create(iads)
end

function TestSkynetIADSHARMDetection:testContact0GroundSpeed()
	
	local mockContact = {}
	function mockContact:getGroundSpeedInKnots(round)
		return 0
	end
	
	local calledProfileInfo = false
	function mockContact:getSimpleAltitudeProfile()
		calledProfileInfo = true
	end
	self.harmDetection:setContacts({mockContact})
	self.harmDetection:evaluateContacts()
	lu.assertEquals(calledProfileInfo, false)
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

	local calls = 0
	function mockContactHARM:isIdentifiedAsHARM()
		calls = calls + 1
		if ( calls == 2 ) then
			return true
		else
			return false
		end
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
	
	local calledCleanedAgedTargets = false
	function self.harmDetection:cleanAgedContacts()
		calledCleanedAgedTargets = true
	end
	self.harmDetection:evaluateContacts()
	
	lu.assertEquals(calledCleanedAgedTargets, true)
	
	lu.assertEquals(harmStateCalled, true)
	lu.assertEquals(probCalled, true)
	lu.assertEquals(contactInform, true)
end

function TestSkynetIADSHARMDetection:testEvaluateContactsContactDetectedAsHARMHas3rdAltitudeChangeRecorded()
	--a contact previously identified as a HARM has a 3rd altitude change recorded, this means it's an aircraft previously falsely detected as HARM
	local mockContactHARM = {}
	
	function mockContactHARM:getGroundSpeedInKnots(round)
		return 1000
	end
	
	function mockContactHARM:isHARMStateUnknown()
		return false
	end
	
	function mockContactHARM:getSimpleAltitudeProfile()
		return {SkynetIADSContact.DESCEND, SkynetIADSContact.CLIMB, SkynetIADSContact.DESCEND }
	end
	
	local harmStateCalled = false
	function mockContactHARM:setHARMState(state)
		harmStateCalled = true
		lu.assertEquals(state, SkynetIADSContact.HARM_UNKNOWN)
	end
	
	local calls = 0
	function mockContactHARM:isIdentifiedAsHARM()
		calls = calls + 1
		if ( calls == 2 ) then
			return true
		else
			return false
		end
	end
	
	local contactInform = false
	function self.harmDetection:informRadarsOfHARM(contact)
		contactInform = true
	end
	
	function self.harmDetection:getNewRadarsThatHaveDetectedContact(contact)
		return {"MockRadar"}
	end
	
	self.harmDetection:setContacts({mockContactHARM})
	self.harmDetection:evaluateContacts()
	
	lu.assertEquals(harmStateCalled, true)
	lu.assertEquals(contactInform, false)
	
end

function TestSkynetIADSHARMDetection:testGetDetectionProbability()
	
	local mockSAM1 = {}
	function mockSAM1:getHARMDetectionChance()
		return 60
	end
	
	local mockSam2 = {}
	function mockSam2:getHARMDetectionChance()
		return 30
	end
	
	local mockNewRadarsDetected = {mockSAM1, mockSam2}

	lu.assertEquals(self.harmDetection:getDetectionProbability(mockNewRadarsDetected), 72)
	
	function mockSAM1:getHARMDetectionChance()
		return 20
	end
	
	function mockSam2:getHARMDetectionChance()
		return 90
	end
	
	lu.assertEquals(self.harmDetection:getDetectionProbability(mockNewRadarsDetected), 92)
	
end

function TestSkynetIADSHARMDetection:testGetNewRadarsThatHaveDetectedContact()
	local mockContact = {}
	local mockRadar1 = {"MockRadar1"}
	local mockRadar2 = {"MockRadar2"}
	function mockContact:getAbstractRadarElementsDetected()
		return {mockRadar1, mockRadar2}
	end
	local result = self.harmDetection:getNewRadarsThatHaveDetectedContact(mockContact)
	lu.assertEquals(result, {mockRadar1, mockRadar2})

	local result2 = self.harmDetection:getNewRadarsThatHaveDetectedContact(mockContact)
	lu.assertEquals(result2, {})
	
	local mockRadar3 = {"MockRadar3"}
	function mockContact:getAbstractRadarElementsDetected()
		return {mockRadar1, mockRadar2, mockRadar3}
	end
	local result3 = self.harmDetection:getNewRadarsThatHaveDetectedContact(mockContact)
	lu.assertEquals(result3, {mockRadar3})	
	
	local mockRadar4 = {"MockRadar4"}
	function mockContact:getAbstractRadarElementsDetected()
		return {mockRadar4, mockRadar1, mockRadar2, mockRadar3}
	end
	local result4 = self.harmDetection:getNewRadarsThatHaveDetectedContact(mockContact)
	lu.assertEquals(result4, {mockRadar4})	
end

function TestSkynetIADSHARMDetection:testCleanAgedContacts()
	local mockContact1 = {}
	function mockContact1:getAge()
		return 1
	end
	
	local mockContact2 = {}
	function mockContact2:getAge()
		return 33
	end
	
	local contactRadars = {}
	contactRadars[mockContact1] = "keep"
	contactRadars[mockContact2] = "delete"
	self.harmDetection.contactRadarsEvaluated = contactRadars
	self.harmDetection:cleanAgedContacts()
	
	local count = 0
	for key, value in pairs(self.harmDetection.contactRadarsEvaluated) do
		count = count + 1
	end
	lu.assertEquals(count, 1)
	lu.assertEquals(self.harmDetection.contactRadarsEvaluated[mockContact1], "keep")
end

end