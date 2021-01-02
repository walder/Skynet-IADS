do

TestSyknetIADSHighDigitSAMSites = {}

function TestSyknetIADSHighDigitSAMSites:setUp()
	if self.samSiteName then
		self.skynetIADS = SkynetIADS:create()
		local samSite = Group.getByName(self.samSiteName)
		self.samSite = SkynetIADSSamSite:create(samSite, self.skynetIADS)
		self.samSite:setupElements()
	end
	if self.ewName then
		self.skynetIADS = SkynetIADS:create()
		local ewRadar = Unit.getByName(self.ewName)
		self.ewRadar = SkynetIADSEWRadar:create(ewRadar, self.skynetIADS)
		self.ewRadar:setupElements()
	end
end

function TestSyknetIADSHighDigitSAMSites:tearDown()
	if self.samSite then	
		self.samSite:cleanUp()
	end
	
	if self.ewRadar then
		self.ewRadar:cleanUp()
	end
end

function TestSyknetIADSHighDigitSAMSites:testSA10AGargoyle()
	self.samSiteName = "SAM-SA-20A"
	self:setUp()
	lu.assertEquals(self.samSite:getNatoName(), "SA-20A")
	
	local launchers = self.samSite:getLaunchers()
	lu.assertEquals(#launchers, 2)
	
	local launcher1 = launchers[1]
	lu.assertEquals(launcher1:getTypeName(), "S-300PMU1 5P85CE ln")
	lu.assertEquals(launcher1:getRange(), 150000)
	lu.assertEquals(launcher1:getMaximumFiringAltitude(), 27000)
	lu.assertEquals(launcher1:getInitialNumberOfMissiles(), 4)
	
	local launcher2 = launchers[2]
	lu.assertEquals(launcher2:getTypeName(), "S-300PMU1 5P85DE ln")
	lu.assertEquals(launcher2:getRange(), 150000)
	lu.assertEquals(launcher2:getMaximumFiringAltitude(), 27000)
	lu.assertEquals(launcher1:getInitialNumberOfMissiles(), 4)
	
	local searchRadars = self.samSite:getSearchRadars()
	lu.assertEquals(#searchRadars, 2)
	
	local searchRadars1 = searchRadars[1]
	lu.assertEquals(searchRadars1:getTypeName(), "S-300PMU1 40B6MD sr")
	lu.assertEquals(searchRadars1:getMaxRangeFindingTarget(), 106998.453125)

	local searchRadars2 = searchRadars[2]
	lu.assertEquals(searchRadars2:getTypeName(), "S-300PMU1 64N6E sr")
	lu.assertEquals(searchRadars2:getMaxRangeFindingTarget(), 106998.453125)
	
	local trackingRadars = self.samSite:getTrackingRadars()
	lu.assertEquals(#trackingRadars, 2)
	
	local trackingRadar1 = trackingRadars[1]
	lu.assertEquals(trackingRadar1:getTypeName(), "S-300PMU1 40B6M tr")
	lu.assertEquals(trackingRadar1:getMaxRangeFindingTarget(), 106998.453125)
	
	local trackingRadar2 = trackingRadars[2]
	lu.assertEquals(trackingRadar2:getTypeName(), "S-300PMU1 30N6E tr")
	lu.assertEquals(trackingRadar2:getMaxRangeFindingTarget(), 106998.453125)
	
	lu.assertEquals(self.samSite:getHARMDetectionChance(), 90)
	
	--output sensor data to dcs.log:
	--lu.assertEquals(launcher1:getDCSRepresentation():getSensors(), "00")

end

function TestSyknetIADSHighDigitSAMSites:testSA10BigBird()
	self.ewName = "Big-Bird"
	self:setUp()
	lu.assertEquals(self.ewRadar:getNatoName(), "Big Bird")
end

function TestSyknetIADSHighDigitSAMSites:testSA23GladiatorOrGiant()
	self.samSiteName = "SAM-SA-23"
	self:setUp()
	lu.assertEquals(self.samSite:getNatoName(), "SA-23")
	
	local launchers = self.samSite:getLaunchers()
	lu.assertEquals(#launchers, 2)

	local launcher1 = launchers[1]
	lu.assertEquals(launcher1:getTypeName(), "S-300VM 9A83ME ln")
	lu.assertEquals(launcher1:getRange(), 100000)
	lu.assertEquals(launcher1:getMaximumFiringAltitude(), 30000)
	lu.assertEquals(launcher1:getInitialNumberOfMissiles(), 4)

	local launcher1 = launchers[2]
	lu.assertEquals(launcher1:getTypeName(), "S-300VM 9A82ME ln")
	lu.assertEquals(launcher1:getRange(), 200000)
	lu.assertEquals(launcher1:getMaximumFiringAltitude(), 40000)
	lu.assertEquals(launcher1:getInitialNumberOfMissiles(), 2)	
	
	local searchRadars = self.samSite:getSearchRadars()
	lu.assertEquals(#searchRadars, 2)
	
	local searchRadars1 = searchRadars[1]
	lu.assertEquals(searchRadars1:getTypeName(), "S-300VM 9S15M2 sr")
	lu.assertEquals(searchRadars1:getMaxRangeFindingTarget(), 213996.90625)
	
	local searchRadars1 = searchRadars[2]
	lu.assertEquals(searchRadars1:getTypeName(), "S-300VM 9S19M2 sr")
	lu.assertEquals(searchRadars1:getMaxRangeFindingTarget(), 213996.90625)
	
	local trackingRadars = self.samSite:getTrackingRadars()
	lu.assertEquals(#trackingRadars, 1)
	
	local trackingRadar1 = trackingRadars[1]
	lu.assertEquals(trackingRadar1:getTypeName(), "S-300VM 9S32ME tr")
	lu.assertEquals(trackingRadar1:getMaxRangeFindingTarget(), 213996.90625)

	
end

function TestSyknetIADSHighDigitSAMSites:testSA10BGrumble()
	self.samSiteName = "SAM-SA-10B"
	self:setUp()
	lu.assertEquals(self.samSite:getNatoName(), "SA-10B")
	
	local launchers = self.samSite:getLaunchers()
	lu.assertEquals(#launchers, 2)
	
	local launcher1 = launchers[1]
	lu.assertEquals(launcher1:getTypeName(), "S-300PS 5P85SE_mod ln")
	lu.assertEquals(launcher1:getRange(), 75000)
	lu.assertEquals(launcher1:getMaximumFiringAltitude(), 30000)
	lu.assertEquals(launcher1:getInitialNumberOfMissiles(), 4)
	
	local launcher1 = launchers[2]
	lu.assertEquals(launcher1:getTypeName(), "S-300PS 5P85SU_mod ln")
	lu.assertEquals(launcher1:getRange(), 75000)
	lu.assertEquals(launcher1:getMaximumFiringAltitude(), 30000)
	lu.assertEquals(launcher1:getInitialNumberOfMissiles(), 4)
	
	local searchRadars = self.samSite:getSearchRadars()
	lu.assertEquals(#searchRadars, 2)
	
	local searchRadars1 = searchRadars[1]
	lu.assertEquals(searchRadars1:getTypeName(), "S-300PS SA-10B 40B6MD MAST sr")
	lu.assertEquals(searchRadars1:getMaxRangeFindingTarget(), 80248.84375)
	
	local searchRadars1 = searchRadars[2]
	lu.assertEquals(searchRadars1:getTypeName(), "S-300PS 64H6E TRAILER sr")
	lu.assertEquals(searchRadars1:getMaxRangeFindingTarget(), 80248.84375)
	
	local trackingRadars = self.samSite:getTrackingRadars()
	lu.assertEquals(#trackingRadars, 2)
	
	local trackingRadar1 = trackingRadars[1]
	lu.assertEquals(trackingRadar1:getTypeName(), "S-300PS 30N6 TRAILER tr")
	lu.assertEquals(trackingRadar1:getMaxRangeFindingTarget(), 80248.84375)
	
	local trackingRadar1 = trackingRadars[2]
	lu.assertEquals(trackingRadar1:getTypeName(), "S-300PS SA-10B 40B6M MAST tr")
	lu.assertEquals(trackingRadar1:getMaxRangeFindingTarget(), 80248.84375)
end

function TestSyknetIADSHighDigitSAMSites:testEDDefaultSA10GrubleWith55VRUD()
	self.samSiteName = "SAM-SA-10C-5V55RUD"
	self:setUp()
	lu.assertEquals(self.samSite:getNatoName(), "SA-10")
	
	local launchers = self.samSite:getLaunchers()
	lu.assertEquals(#launchers, 2)
	
	local launcher1 = launchers[1]
	lu.assertEquals(launcher1:getTypeName(), "S-300PS 5P85DE ln")
	lu.assertEquals(launcher1:getRange(), 90000)
	lu.assertEquals(launcher1:getMaximumFiringAltitude(), 25000)
	lu.assertEquals(launcher1:getInitialNumberOfMissiles(), 4)
end

function TestSyknetIADSHighDigitSAMSites:testSA10BGrumbleWith55VRUD()
	self.samSiteName = "SAM-SA-10B-5V55RUD"
	self:setUp()
	lu.assertEquals(self.samSite:getNatoName(), "SA-10B")
	
	local launchers = self.samSite:getLaunchers()
	lu.assertEquals(#launchers, 2)
end

function TestSyknetIADSHighDigitSAMSites:testSA20AGargoyleWith55VRUD()
	self.samSiteName = "SAM-SA-20A-5V55RUD"
	self:setUp()
	lu.assertEquals(self.samSite:getNatoName(), "SA-20A")
	
	local launchers = self.samSite:getLaunchers()
	lu.assertEquals(#launchers, 2)
end

function TestSyknetIADSHighDigitSAMSites:testSA17Grizzly()
	self.samSiteName = "SAM-SA-17"
	self:setUp()
	lu.assertEquals(self.samSite:getNatoName(), "SA-17")
	
	local launchers = self.samSite:getLaunchers()
	lu.assertEquals(#launchers, 1)
	
	local launcher1 = launchers[1]
	lu.assertEquals(launcher1:getTypeName(), "SA-17 Buk M1-2 LN 9A310M1-2")
	lu.assertEquals(launcher1:getRange(), 50000)
	lu.assertEquals(launcher1:getMaximumFiringAltitude(), 50000)
	lu.assertEquals(launcher1:getInitialNumberOfMissiles(), 4)
end

function TestSyknetIADSHighDigitSAMSites:testSA2GuidelineWithV7595V23()
	self.samSiteName = "SAM-SA-2-V-759-5V23"
	self:setUp()
	lu.assertEquals(self.samSite:getNatoName(), "SA-2")

	local launchers = self.samSite:getLaunchers()
	lu.assertEquals(#launchers, 1)
	
	local launcher1 = launchers[1]
	lu.assertEquals(launcher1:getTypeName(), "S_75M_Volhov_V759")
	lu.assertEquals(launcher1:getRange(), 56000)
	lu.assertEquals(launcher1:getMaximumFiringAltitude(), 30000)
	--should read as 1, bugreport filed: https://github.com/Auranis/HighDigitSAMs/issues/11
	lu.assertEquals(launcher1:getInitialNumberOfMissiles(), 4)	
end	

function TestSyknetIADSHighDigitSAMSites:testSA3GoaWithV601P5V27()
	self.samSiteName = "SAM-SA-3-V-601P-5V27"
	self:setUp()
	lu.assertEquals(self.samSite:getNatoName(), "SA-3")
	
	local launchers = self.samSite:getLaunchers()
	lu.assertEquals(#launchers, 1)
	
	local launcher1 = launchers[1]
	lu.assertEquals(launcher1:getTypeName(), "5p73 V-601P ln")
	lu.assertEquals(launcher1:getRange(), 25000)
	lu.assertEquals(launcher1:getMaximumFiringAltitude(), 18000)
	--should read as 1, bugreport filed: https://github.com/Auranis/HighDigitSAMs/issues/11
	lu.assertEquals(launcher1:getInitialNumberOfMissiles(), 4)	
end

function TestSyknetIADSHighDigitSAMSites:testSA2GuidelineWithHQ2()
	self.samSiteName = "SAM-SA-2HQ-2"
	self:setUp()
	lu.assertEquals(self.samSite:getNatoName(), "SA-2")
	
	local launchers = self.samSite:getLaunchers()
	lu.assertEquals(#launchers, 1)
	
	local launcher1 = launchers[1]
	lu.assertEquals(launcher1:getTypeName(), "HQ_2_Guideline_LN")
	lu.assertEquals(launcher1:getRange(), 50000)
	lu.assertEquals(launcher1:getMaximumFiringAltitude(), 30000)
	--should read as 1, bugreport filed: https://github.com/Auranis/HighDigitSAMs/issues/11
	lu.assertEquals(launcher1:getInitialNumberOfMissiles(), 4)	
	
end

end
