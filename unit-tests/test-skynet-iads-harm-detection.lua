do

TestSkynetIADSHARMDetection = {}

function TestSkynetIADSHARMDetection:setUp()
	self.harmDetection = SkynetIADSHARMDetection:create()
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

function TestSkynetIADSHARMDetection:testCalculateAspectInDegrees()
	lu.assertEquals(self.harmDetection:calculateAspectInDegrees(0, 90), 90)
	lu.assertEquals(self.harmDetection:calculateAspectInDegrees(300, 90), 150)
	lu.assertEquals(self.harmDetection:calculateAspectInDegrees(010, 280), 90)
	lu.assertEquals(self.harmDetection:calculateAspectInDegrees(190, 350), 160)
	lu.assertEquals(self.harmDetection:calculateAspectInDegrees(090, 270), 180)
	lu.assertEquals(self.harmDetection:calculateAspectInDegrees(010, 170), 160)
end

end