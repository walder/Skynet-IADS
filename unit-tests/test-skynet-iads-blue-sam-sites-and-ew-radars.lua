do
TestSkynetIADSBLUESAMSitesAndEWRadars = {}

function TestSkynetIADSBLUESAMSitesAndEWRadars:setUp()
	if self.samSiteName then
		self.skynetIADS = SkynetIADS:create()
		local samSite = Group.getByName(self.samSiteName)
		self.samSite = SkynetIADSSamSite:create(samSite, self.skynetIADS)
		
		-- we overrite this method since it returns radar contacts in the DCS world which mess up the tests.
		function self.samSite:getDetectedTargets()
			return {}
		end
		
		self.samSite:setupElements()
		self.samSite:goLive()
	end
	
	if self.ewRadarName then
		self.iads = SkynetIADS:create()
		self.iads:addEarlyWarningRadarsByPrefix('BLUE-EW')
		self.ewRadar = self.iads:getEarlyWarningRadarByUnitName(self.ewRadarName)
	end
	
end

function TestSkynetIADSBLUESAMSitesAndEWRadars:tearDown()
	if self.samSite then	
		self.samSite:goDark()
		self.samSite:cleanUp()
	end
	
	if self.ewRadar then
		self.ewRadar:cleanUp()
	end
	if self.iads then
		self.iads:deactivate()
	end
	self.iads = nil
	self.ewRadar = nil
	self.ewRadarName = nil
	
	self.samSite = nil
	self.samSiteName = nil
end

function TestSkynetIADSBLUESAMSitesAndEWRadars:testHawkSTR()
	self.ewRadarName = "BLUE-EW-Hawk"
	self:setUp()
	lu.assertEquals(self.ewRadar:getNatoName(), "Hawk str")
	lu.assertEquals(self.ewRadar:hasWorkingRadar(), true)
end

function TestSkynetIADSBLUESAMSitesAndEWRadars:testPatriotSTR()
	self.ewRadarName = "BLUE-EW"
	self:setUp()
	lu.assertEquals(self.ewRadar:getNatoName(), "Patriot str")
	lu.assertEquals(self.ewRadar:hasWorkingRadar(), true)
end

function TestSkynetIADSBLUESAMSitesAndEWRadars:testRolandEWR()
	self.ewRadarName = "BLUE-EW-Roland"
	self:setUp()
	lu.assertEquals(self.ewRadar:getNatoName(), "Roland EWR")
	lu.assertEquals(self.ewRadar:hasWorkingRadar(), true)
end

function TestSkynetIADSBLUESAMSitesAndEWRadars:testRolandLauncherAndRadar()
--[[
Roland:

Radar:
{
    0={
        {opticType=0, type=0, typeName="generic SAM search visir"},
        {opticType=2, type=0, typeName="generic SAM IR search visir"}
    },
    {
        {
            detectionDistanceAir={
                lowerHemisphere={headOn=8024.8837890625, tailOn=8024.8837890625},
                upperHemisphere={headOn=8024.8837890625, tailOn=8024.8837890625}
            },
            type=1,
            typeName="Roland ADS"
        }
    }
}

Launcher:
{
    {
        count=10,
        desc={
            Nmax=14,
            RCS=0.019600000232458,
            _origin="",
            altMax=6000,
            altMin=10,
            box={
                max={x=1.2142661809921, y=0.17386008799076, z=0.1697566062212},
                min={x=-1.212909579277, y=-0.1738600730896, z=-0.1697566062212}
            },
            category=1,
            displayName="XMIM-115 Roland",
            fuseDist=5,
            guidance=4,
            life=2,
            missileCategory=2,
            rangeMaxAltMax=8000,
            rangeMaxAltMin=8000,
            rangeMin=500,
            typeName="ROLAND_R",
            warhead={caliber=150, explosiveMass=6.5, mass=6.5, type=1}
        }
    }
}

--]]
	self.samSiteName = "BLUE-SAM-ROLAND"
	self:setUp()
	lu.assertEquals(self.samSite:getNatoName(), "Roland ADS")	
	lu.assertEquals(#self.samSite:getLaunchers(), 1)
	lu.assertEquals(#self.samSite:getSearchRadars(), 1)	
	
	lu.assertEquals(self.samSite:getSearchRadars()[1]:getMaxRangeFindingTarget(), 23405.912109375)
	lu.assertEquals(self.samSite:getLaunchers()[1]:getRange(), 8000)
	lu.assertEquals(self.samSite:getLaunchers()[1]:getInitialNumberOfMissiles(), 10)
end

function TestSkynetIADSBLUESAMSitesAndEWRadars:testNASAMS()

	self.samSiteName = "BLUE-SAM-NASAMS"
	self:setUp()
	lu.assertEquals(self.samSite:getNatoName(), "NASAMS")
	lu.assertEquals(self.samSite:getHARMDetectionChance(),90)
	lu.assertEquals(self.samSite:getCanEngageHARM(), true)
	lu.assertEquals(self.samSite:getRadars()[1]:getMaxRangeFindingTarget(), 26749.61328125)
	lu.assertEquals(self.samSite:getLaunchers()[1]:getRange(), 57000)
	lu.assertEquals(self.samSite:getLaunchers()[1]:getInitialNumberOfMissiles(), 6)
	
	lu.assertEquals(self.samSite:getLaunchers()[2]:getRange(), 61000)
	lu.assertEquals(self.samSite:getLaunchers()[2]:getInitialNumberOfMissiles(), 6)
	
end

function TestSkynetIADSBLUESAMSitesAndEWRadars:testRapierLauncherAndRadar()
--[[
Rapier:

Radar: (for some reason the typeName  is Tor?)
{
    {
        {
            detectionDistanceAir={
                lowerHemisphere={headOn=16718.5078125, tailOn=16718.5078125},
                upperHemisphere={headOn=16718.5078125, tailOn=16718.5078125}
            },
            type=1,
            typeName="Tor 9A331"
        }
    }
}

Launcher:
{
    {
        count=4,
        desc={
            Nmax=14,
            RCS=0.079999998211861,
            _origin="",
            altMax=3000,
            altMin=50,
            box={
                max={x=1.4030002355576, y=0.13611803948879, z=0.13611821830273},
                min={x=-0.84999942779541, y=-0.13611836731434, z=-0.1361181885004}
            },
            category=1,
            displayName="Rapier",
            fuseDist=0,
            guidance=8,
            life=2,
            missileCategory=2,
            rangeMaxAltMax=6800,
            rangeMaxAltMin=6800,
            rangeMin=400,
            typeName="Rapier",
            warhead={caliber=133, explosiveMass=1.3999999761581, mass=1.3999999761581, type=1}
        }
    }
}

--]]
	self.samSiteName = "BLUE-SAM-RAPIER"
	self:setUp()
	lu.assertEquals(self.samSite:getNatoName(), "Rapier")
	lu.assertEquals(self.samSite:getRadars()[1]:getMaxRangeFindingTarget(), 16718.5078125)
	lu.assertEquals(self.samSite:getLaunchers()[1]:getRange(), 6800)
	lu.assertEquals(self.samSite:getLaunchers()[1]:getInitialNumberOfMissiles(), 4)
	
	local units = Group.getByName(self.samSiteName):getUnits()
	for i = 1, #units do
		local unit = units[i]
		if unit:getTypeName() == 'rapier_fsa_optical_tracker_unit' then
	--		lu.assertEquals(unit:getSensors(), true)
		end
	end
end

function TestSkynetIADSBLUESAMSitesAndEWRadars:testPatriotLauncherAndRadar()

--[[
Patriot:

Radar:
{
    {
        count=4,
        desc={
            Nmax=25,
            RCS=0.10660000145435,
            _origin="",
            altMax=24240,
            altMin=45,
            box={
                max={x=2.5578553676605, y=0.33423712849617, z=0.32681864500046},
                min={x=-2.5578553676605, y=-0.33423712849617, z=-0.32681867480278}
            },
            category=1,
            displayName="MIM-104 Patriot",
            fuseDist=13,
            guidance=4,
            life=2,
            missileCategory=2,
            rangeMaxAltMax=120000,
            rangeMaxAltMin=30000,
            rangeMin=3000,
            typeName="MIM_104",
            warhead={caliber=410, explosiveMass=73, mass=73, type=1}
        }
    }
}

Search Radar:
{
    {
        {
            detectionDistanceAir={
                lowerHemisphere={headOn=173872.484375, tailOn=173872.484375},
                upperHemisphere={headOn=173872.484375, tailOn=173872.484375}
            },
            type=1,
            typeName="Patriot str"
        }
    }
}
--]]
	self.samSiteName = "BLUE-SAM-PATRIOT"
	self:setUp()
	lu.assertEquals(self.samSite:getNatoName(), "Patriot")
	lu.assertEquals(self.samSite:getHARMDetectionChance(), 90)
	lu.assertEquals(self.samSite:getCanEngageHARM(), true)
	
	local radar = self.samSite:getSearchRadars()[1]
	lu.assertEquals(radar:getMaxRangeFindingTarget(), 173872.484375)
	
	local launcher = self.samSite:getLaunchers()[1]
	lu.assertEquals(launcher:getInitialNumberOfMissiles(), 4)
	lu.assertEquals(launcher:getRange(), 120000)
end

function TestSkynetIADSBLUESAMSitesAndEWRadars:testLPWSCRAM()
	--"HEMTT_C-RAM_Phalanx"
	
--[[	
	{
        {
            detectionDistanceAir={
                lowerHemisphere={headOn=13374.806640625, tailOn=13374.806640625},
                upperHemisphere={headOn=13374.806640625, tailOn=13374.806640625}
            },
            type=1,
            typeName="C_RAM_Phalanx"
        }
    }
	
	    {
        count=1550,
        desc={
            _origin="",
            box={
                max={x=2.2344591617584, y=0.12504191696644, z=0.12113922089338},
                min={x=-6.61008644104, y=-0.12504199147224, z=-0.12113920599222}
            },
            category=0,
            displayName="M246_20_HE",
            life=2,
            typeName="weapons.shells.M246_20_HE_gr",
            warhead={caliber=20, explosiveMass=0.1, mass=0.1, type=1}
        }
    }
}

--]]
	self.samSiteName = "BLUE-SAM-LPWS-C-RAM"
	self:setUp()
	lu.assertEquals(#self.samSite:getRadars(),1)
	lu.assertEquals(#self.samSite:getLaunchers(), 1)
	lu.assertEquals(#self.samSite:getTrackingRadars(), 0)
	
	local searchRadar = self.samSite:getSearchRadars()[1]
	local launcher = self.samSite:getLaunchers()[1]
	
	lu.assertEquals(searchRadar:getMaxRangeFindingTarget(), 13374.806640625)
	lu.assertEquals(launcher:getRange(), 13374.806640625)
end


function TestSkynetIADSBLUESAMSitesAndEWRadars:testEWRANFPS117Domed()
	--[[
	    {
        {
            detectionDistanceAir={
                lowerHemisphere={headOn=309626.78125, tailOn=309626.78125},
                upperHemisphere={headOn=309626.78125, tailOn=309626.78125}
            },
            type=1,
            typeName="FPS-117"
        }
    }
}
--]]
	self.ewRadarName = "BLUE-EW-FPS-117-DOMED"
	self:setUp()
	--lu.assertEquals(Unit.getByName(self.ewRadarName):getTypeName(), nil)
	lu.assertEquals(self.ewRadar:getNatoName(), "FPS-117 Dome")
	lu.assertEquals(self.ewRadar:getHARMDetectionChance(), 80)
	local radar = self.ewRadar:getSearchRadars()[1]
	lu.assertEquals(radar:getMaxRangeFindingTarget(), 309626.78125)
end

function TestSkynetIADSBLUESAMSitesAndEWRadars:testEWRANFPS117()
	--[[
	    {
        {
            detectionDistanceAir={
                lowerHemisphere={headOn=309626.78125, tailOn=309626.78125},
                upperHemisphere={headOn=309626.78125, tailOn=309626.78125}
            },
            type=1,
            typeName="FPS-117"
        }
    }
}
--]]
	self.ewRadarName = "BLUE-EW-FPS-117"
	self:setUp()
	--lu.assertEquals(Unit.getByName(self.ewRadarName):getTypeName(), nil)
	lu.assertEquals(self.ewRadar:getNatoName(), "FPS-117")
	lu.assertEquals(self.ewRadar:getHARMDetectionChance(), 80)
	local radar = self.ewRadar:getSearchRadars()[1]
	lu.assertEquals(radar:getMaxRangeFindingTarget(), 309626.78125)
end

--TODO: this test can only be finished once the perry class has radar data:
function TestSkynetIADSBLUESAMSitesAndEWRadars:testOliverHazzardPerryClassShip()
--[[
Oliver Hazzard:

Launchers:
 {
    {
        count=2016,
        desc={
            _origin="",
            box={
                max={x=2.2344591617584, y=0.12504191696644, z=0.12113922089338},
                min={x=-6.61008644104, y=-0.12504199147224, z=-0.12113920599222}
            },
            category=0,
            displayName="12.7mm",
            life=2,
            typeName="weapons.shells.M2_12_7_T",
            warhead={caliber=12.7, explosiveMass=0, mass=0.046, type=0}
        }
    },
    {
        count=460,
        desc={
            _origin="",
            box={
                max={x=2.2344591617584, y=0.12504191696644, z=0.12113922089338},
                min={x=-6.61008644104, y=-0.12504199147224, z=-0.12113920599222}
            },
            category=0,
            displayName="25mm HE",
            life=2,
            typeName="weapons.shells.M242_25_HE_M792",
            warhead={caliber=25, explosiveMass=0.185, mass=0.185, type=1}
        }
    },
    {
        count=142,
        desc={
            _origin="",
            box={
                max={x=2.2344591617584, y=0.12504191696644, z=0.12113922089338},
                min={x=-6.61008644104, y=-0.12504199147224, z=-0.12113920599222}
            },
            category=0,
            displayName="25mm AP",
            life=2,
            typeName="weapons.shells.M242_25_AP_M791",
            warhead={caliber=25, explosiveMass=0, mass=0.155, type=0}
        }
    },
    {
        count=775,
        desc={
            _origin="",
            box={
                max={x=2.2344591617584, y=0.12504191696644, z=0.12113922089338},
                min={x=-6.61008644104, y=-0.12504199147224, z=-0.12113920599222}
            },
            category=0,
            displayName="20mm AP",
            life=2,
            typeName="weapons.shells.M61_20_AP",
            warhead={caliber=20, explosiveMass=0, mass=0.1, type=0}
        }
    },
    {
        count=775,
        desc={
            _origin="",
            box={
                max={x=2.2344591617584, y=0.12504191696644, z=0.12113922089338},
                min={x=-6.61008644104, y=-0.12504199147224, z=-0.12113920599222}
            },
            category=0,
            displayName="20mm HE",
            life=2,
            typeName="weapons.shells.M61_20_HE",
            warhead={caliber=20, explosiveMass=0.1, mass=0.1, type=1}
        }
    },
    {
        count=24,
        desc={
            Nmax=25,
            RCS=0.1765999943018,
            _origin="",
            altMax=24400,
            altMin=10,
            box={
                max={x=2.9796471595764, y=0.39923620223999, z=0.39878171682358},
                min={x=-1.5204827785492, y=-0.38143759965897, z=-0.39878168702126}
            },
            category=1,
            displayName="SM-2",
            fuseDist=15,
            guidance=4,
            life=2,
            missileCategory=2,
            rangeMaxAltMax=100000,
            rangeMaxAltMin=40000,
            rangeMin=4000,
            typeName="SM_2",
            warhead={caliber=340, explosiveMass=98, mass=98, type=1}
        }
    },
    {
        count=16,
        desc={
            Nmax=18,
            RCS=0.10580000281334,
            _origin="",
            altMax=10000,
            altMin=-1,
            box={
                max={x=2.2758972644806, y=0.13610155880451, z=0.28847914934158},
                min={x=-1.6704962253571, y=-0.4600305557251, z=-0.28847911953926}
            },
            category=1,
            displayName="AGM-84S Harpoon",
            fuseDist=0,
            guidance=1,
            life=2,
            missileCategory=4,
            rangeMaxAltMax=241401,
            rangeMaxAltMin=95000,
            rangeMin=3000,
            typeName="AGM_84S",
            warhead={caliber=343, explosiveMass=90, mass=90, type=1}
        }
    },
    {
        count=180,
        desc={
            _origin="",
            box={
			

	SENSOR:
	{
	0={{opticType=0, type=0, typeName="long-range naval optics"}},
	{
		{
			detectionDistanceAir={
				lowerHemisphere={headOn=173872.484375, tailOn=173872.484375},
				upperHemisphere={headOn=173872.484375, tailOn=173872.484375}
			},
			type=1,
			typeName="Patriot str"
		},
		{detectionDistanceRBM=336.19998168945, type=1, typeName="perry search radar"}
	}
	}	
--]]

	self.ewRadarName = "BLUE-EW-Oliver-Hazzard"
	self:setUp()
	lu.assertEquals(self.ewRadar:getNatoName(), "PERRY")
	--as long as we don't use the PERRY as a SAM site the distance returned is irrelevant, because it's radar wil be on all the time
	lu.assertEquals(self.ewRadar:getRadars()[1]:getMaxRangeFindingTarget(), 173872.484375)
end

end