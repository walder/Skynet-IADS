do

TestSyknetIADSHighDigitSAMSites = {}

function TestSyknetIADSHighDigitSAMSites:setUp()
	if self.samSiteName then
		self.skynetIADS = SkynetIADS:create()
		local samSite = Group.getByName(self.samSiteName)
		self.samSite = SkynetIADSSamSite:create(samSite, self.skynetIADS)
		self.samSite:setupElements()
	end
end

function TestSyknetIADSHighDigitSAMSites:tearDown()
	if self.samSite then	
		self.samSite:cleanUp()
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
	
	local launcher2 = launchers[2]
	lu.assertEquals(launcher2:getTypeName(), "S-300PMU1 5P85DE ln")
	lu.assertEquals(launcher2:getRange(), 150000)
	lu.assertEquals(launcher2:getMaximumFiringAltitude(), 27000)
	
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

function TestSyknetIADSHighDigitSAMSites:testSA23()
	self.samSiteName = "SAM-SA-23"
	self:setUp()
	lu.assertEquals(self.samSite:getNatoName(), "SA-23")
	
	local launchers = self.samSite:getLaunchers()
	lu.assertEquals(#launchers, 2)

	local launcher1 = launchers[1]
	lu.assertEquals(launcher1:getTypeName(), "S-300VM 9A83ME ln")
	lu.assertEquals(launcher1:getRange(), 100000)
	lu.assertEquals(launcher1:getMaximumFiringAltitude(), 30000)

	local launcher1 = launchers[1]
	lu.assertEquals(launcher1:getTypeName(), "S-300VM 9A83ME ln")
	lu.assertEquals(launcher1:getRange(), 100000)
	lu.assertEquals(launcher1:getMaximumFiringAltitude(), 30000)	
	
end

end
