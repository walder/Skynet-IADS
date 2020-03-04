-- BUILD Timestamp: 04.03.2020 23:12:30.82  
do
samTypesDB = { -- this is a static DB based off of scripts/database files for each sam type.
	-- '-' character needs special search term %
	['S%-300'] = {
		['type'] = 'complex',
		['searchRadar'] = {
			['S-300PS 40B6MD sr'] = {
				['max_range_finding_target'] = 60000,
				['min_range_finding_target'] = 2000,
				['max_alt_finding_target'] = 3000,
				['min_alt_finding_target'] = 5,
				['height'] = 42.158,
				['radar_rotation_period'] = 3.0,
			},
			['S-300PS 64H6E sr'] = {
				['max_range_finding_target'] = 160000,
				['min_range_finding_target'] = 2000,
				['max_alt_finding_target'] = 27000,
				['min_alt_finding_target'] = 100,
				['height'] = 8.68,
				['radar_rotation_period'] = 12.0/2, -- radar has 2 sides
			},
		},
		['trackingRadar'] = {
			['S-300PS 40B6M tr'] = {
				['max_range_finding_target'] = 160000,
				['min_range_finding_target'] = 2000,
				['max_alt_finding_target'] = 27000,
				['min_alt_finding_target'] = 25,
				['height'] = 27.63,
			},
		},
		['launchers'] = {
			['S-300PS 5P85D ln'] = {
				['missiles'] = 4,
				['range'] = 120000,
				['rearmTime'] = 3600,
			},
			['S-300PS 5P85C ln'] = {
				['missiles'] = 4,
				['range'] = 120000,
				['rearmTime'] = 3600,
			},
		},
		['misc'] = {
			['S-300PS 54K6 cp'] = {
				['required'] = true,
			},
		},
		['name'] = {
			['NATO'] = 'SA-10 Grumble',
		},
	},
	['Buk'] = {
		['type'] = 'complex',
		['searchRadar'] = {
			['SA-11 Buk SR 9S18M1'] = {
				['max_range_finding_target'] = 100000,
				['min_range_finding_target'] = 2000,
				['max_alt_finding_target'] = 25000,
				['min_alt_finding_target'] = 25,
				['height'] = 7.534,
				['radar_rotation_period'] = 12.0,
				['radar_on'] = 60,
			},
		},
		['launchers'] = {
			['SA-11 Buk LN 9A310M1'] = {
				['missiles'] = 4,
				['range'] = 50000,
				['max_range_finding_target'] = 50000,
				['min_range_finding_target'] = 3000,
				['max_alt_finding_target'] = 22000,
				['min_alt_finding_target'] = 20,
				['height'] = 6.931,
				['trackingRadar'] = true,
				['atkVisual'] = true,
			},
		},
		['misc'] = {
			['SA-11 Buk CC 9S470M1'] = {
				['required'] = true,
			},
		},
		['name'] = {
			['NATO'] = 'SA-11 Gadfly',
		},
		['mobile'] = true,
	},
	['s%-125'] = {
		['type'] = 'complex',
		['searchRadar'] = {
			['p-19 s-125 sr'] = {
				['max_range_finding_target'] = 80000,
				['min_range_finding_target'] = 1500,
				['max_alt_finding_target'] = 20000,
				['min_alt_finding_target'] = 25,
				['height'] = 5.841,
				['radar_rotation_period'] = 6.0,
			},
		},
		['trackingRadar'] = {
			['snr s-125 tr'] = {
				['max_range_finding_target'] = 100000,
				['min_range_finding_target'] = 1500,
				['max_alt_finding_target'] = 20000,
				['min_alt_finding_target'] = 25,
				['height'] = 3,
			},
		},
		['launchers'] = {
			['5p73 s-125 ln'] = {
				['range'] = 18000,
				['missiles'] = 4,
			},
		},
		['name'] = {
			['NATO'] = 'SA-3 Goa',
		},
	},
    ['s%-75'] = {
		['type'] = 'complex',
		['searchRadar'] = {
			['p-19 s-125 sr'] = {
				['max_range_finding_target'] = 80000,
				['min_range_finding_target'] = 1500,
				['max_alt_finding_target'] = 20000,
				['min_alt_finding_target'] = 25,
				['height'] = 5.841,
				['radar_rotation_period'] = 6.0,
			},
		},
		['trackingRadar'] = {
			['SNR_75V'] = {
				['max_range_finding_target'] = 100000,
				['min_range_finding_target'] = 1500,
				['max_alt_finding_target'] = 25000,
				['min_alt_finding_target'] = 25,
				['height'] = 5.5,
			},
		},
		['launchers'] = {
			['S_75M_Volhov'] = {
				['range'] = 40000,
				['missiles'] = 1,
				['rearmTime'] = 2700,
			},
		},
		['name'] = {
			['NATO'] = 'SA-2 Guideline',
		},
	},
	['Kub'] = {
		['type'] = 'complex',
		['mobile'] = true,
		['searchRadar'] = {
			['Kub 1S91 str'] = {
				['max_range_finding_target'] = 70000,
				['min_range_finding_target'] = 1000,
				['max_alt_finding_target'] = 14000,
				['min_alt_finding_target'] = 20,
				['height'] = 5.872,
				['radar_rotation_period'] = 4.0,
				['trackingRadar'] = true,
				['radar_on'] = 6,
			},
		},
		['launchers'] = {
			['Kub 2P25 ln'] = {
				['range'] = 25000,
				['missiles'] = 3,
			
			},
		},
		['name'] = {
			['NATO'] = 'SA-6 Gainful',
		},
	},
	['Patriot'] = {
		['type'] = 'complex',
		['searchRadar'] = {
			['Patriot str'] = {
				['max_range_finding_target'] = 16000,
				['min_range_finding_target'] = 3000,
				['max_alt_finding_target'] = 30000,
				['min_alt_finding_target'] = 60,
				['height'] = 5.895,
				['trackingRadar'] = true,
			},
		},

		['launchers'] = {
			['Patriot ln'] = {
				['range'] = 100000,
				['missiles'] = 4,
				['rearmTime'] = 3600,
			},
		},
		['misc'] = {
			['Patriot cp'] = {
				['required'] = false,
			},
			['Patriot EPP']  = {
				['required'] = false,
			},
			['Patriot ECS']  = {
				['required'] = true,
			},
			['Patriot AMG']  = {
				['required'] = false,
			},
		},
			

		['name'] = {
			['NATO'] = 'Patriot',
		},
	},
	['Hawk'] = {
		['type'] = 'complex',
		['searchRadar'] = {
			['Hawk sr'] = {
				['max_range_finding_target'] = 90000,
				['min_range_finding_target'] = 1500,
				['max_alt_finding_target'] = 20000,
				['min_alt_finding_target'] = 25,
				['height'] = 5.841,
				['radar_rotation_period'] = 6.0,
			},
		},
		['trackingRadar'] = {
			['Hawk tr'] = {
				['max_range_finding_target'] = 90000,
				['min_range_finding_target'] = 1500,
				['max_alt_finding_target'] = 20000,
				['min_alt_finding_target'] = 25,
				['height'] = 3,
			},
		},
		['launchers'] = {
			['Hawk ln'] = {
				['range'] = 50000,
				['missiles'] = 3,
			},
		},

		['name'] = {
			['NATO'] = 'Hawk',
		},

	},	
	['Roland ADS'] = {
		['type'] = 'single',
		['mobile'] = true,
		['searchRadar'] = {
			['Roland ADS'] = {
				['max_range_finding_target'] = 12000,
				['min_range_finding_target'] = 1500,
				['max_alt_finding_target'] = 6000,
				['min_alt_finding_target'] = 20,
				['height'] = 3.922,
				['radar_rotation_period'] = 1.0,
				['trackingRadar'] = true,
			},
		},
		['launchers'] = {
			['Roland ADS'] = {
				['laser'] = true,
				['range'] = 8000,
				['missiles'] = 8,
				['rearmTime'] = 3600,
			},
		},

		['name'] = {
			['NATO'] = 'Roland ADS',
		},
	},		
	['2S6 Tunguska'] = {
		['type'] = 'single',
		['mobile'] = true,
		['searchRadar'] = {
			['2S6 Tunguska'] = {
				['max_range_finding_target'] = 18000,
				['min_range_finding_target'] = 200,
				['max_alt_finding_target'] = 3500,
				['min_alt_finding_target'] = 0,
				['height'] = 3.675,
				['radar_rotation_period'] = 1.0,
				['trackingRadar'] = true,
			},
		},
		['launchers'] = {
			['2S6 Tunguska'] = {

				['range'] = 8000,
				['missiles'] = 8,
				['guns'] = true,
			},
		},
		['name'] = {
			['NATO'] = 'SA-19 Grison',
		},
	},		
	['Osa'] = {
		['type'] = 'single',
		['mobile'] = true,
		['searchRadar'] = {
			['Osa 9A33 ln'] = {
				['max_range_finding_target'] = 30000,
				['min_range_finding_target'] = 1500,
				['max_alt_finding_target'] = 5000,
				['min_alt_finding_target'] = 10,
				['height'] = 5.438,
				['radar_rotation_period'] = 60/33,
				['trackingRadar'] = true,
			},
		},
		['launchers'] = {
			['Osa 9A33 ln'] = {

				['range'] = 8000,
				['missiles'] = 6,
				['radar_on'] = 5,
			},
		},
		['name'] = {
			['NATO'] = 'SA-8 Gecko',
		},
	},	
	['Strela%-10M3'] = {
		['type'] = 'single',
		['mobile'] = true,
		['searchRadar'] = {
			['Strela-10M3'] = {
				['max_range_finding_target'] = 8000,
				['min_range_finding_target'] = 0,
				['max_alt_finding_target'] = 3500,
				['min_alt_finding_target'] = 10,
				['height'] = 3.548,
				['trackingRadar'] = true,
				['ir'] = true,
			},
		},
		['launchers'] = {
			['Strela-10M3'] = {

				['range'] = 5000,
				['missiles'] = 4,
				['ir'] = true,
			},
		},
		['name'] = {
			['NATO'] = 'SA-13 Gopher',
		},
	},	
	['Strela%-1 9P31'] = {
		['type'] = 'single',
		['mobile'] = true,
		['searchRadar'] = {
			['Strela-1 9P31'] = {
				['max_range_finding_target'] = 5000,
				['min_range_finding_target'] = 0,
				['max_alt_finding_target'] = 3500,
				['min_alt_finding_target'] = 10,
				['height'] = 3.277,
				['trackingRadar'] = true,
				['ir'] = true,
			},
		},
		['launchers'] = {
			['Strela-1 9P31'] = {

				['range'] = 4000,
				['missiles'] = 4,
				['ir'] = true,
			},
		},
		['name'] = {
			['NATO'] = 'SA-9 Gaskin',
		},
	},
	['Tor'] = {
		['type'] = 'single',
		['mobile'] = true,
		['searchRadar'] = {
			['Tor 9A331'] = {
				['max_range_finding_target'] = 25000,
				['min_range_finding_target'] = 500,
				['max_alt_finding_target'] = 8000,
				['min_alt_finding_target'] = 20,
				['radar_rotation_period'] = 1.0,
				['height'] = 5.118,	
				['trackingRadar'] = true,
			},
		},
		['launchers'] = {
			['Tor 9A331'] = {

				['range'] = 12000,
				['missiles'] = 8,
				['radar_on'] = 10,
			},
		},
		['name'] = {
			['NATO'] = 'SA-15 Gauntlet',
		},
	},
	['Gepard'] = {
		['type'] = 'single',
		['mobile'] = true,
		['searchRadar'] = {
			['Gepard'] = {
				['max_range_finding_target'] = 15000,
				['min_range_finding_target'] = 0,
				['max_alt_finding_target'] = 3000,
				['min_alt_finding_target'] = 0,
				['height'] = 3.854,
				['trackingRadar'] = true,
			},
		},
		['launchers'] = {
			['Gepard'] = {
				['range'] = 3000,
				['aaa'] = true,
			},
		},
		['name'] = {
			['NATO'] = 'Gepard',
		},
	},		
	['Igla'] = {
		['type'] = 'single',
		['searchRadar'] = {
			['SA-18 Igla manpad'] = {
				['max_range_finding_target'] = 5000,
				['min_range_finding_target'] = 0,
				['max_alt_finding_target'] = 3000,
				['min_alt_finding_target'] = 0,
				['height'] = 1.8,
				['ir'] = true,
				['trackingRadar'] = true,
			},
		},
		['launchers'] = {
			['SA-18 Igla manpad'] = {

				['range'] = 5000,
				['missiles'] = 3,
				['ir'] = true,
			},
			['SA-18 Igla-S comm'] = {

				['height'] = 1.8,
				['range'] = 5000,
			},			
		},
		['name'] = {
			['NATO'] = 'SA-18 Grouse',
		},
	},	
	['M6 Linebacker'] = {
		['type'] = 'single',
		['mobile'] = true,
		['searchRadar'] = {
			['M6 Linebacker'] = {
				['max_range_finding_target'] = 8000,
				['min_range_finding_target'] = 0,
				['max_alt_finding_target'] = 3000,
				['min_alt_finding_target'] = 0,
				['height'] = 2.58,
				['ir'] = true,
				['trackingRadar'] = true,				
			},
		},
		['launchers'] = {
			['M6 Linebacker'] = {
				['range'] = 4500,
				['missiles'] = 4,
				['ir'] = true,
				['guns'] = true,
			},
		},
		['name'] = {
			['NATO'] = 'M6 Linebacker',
		},
	},
    ['Rapier'] = {
        ['searchRadar'] = {
            ['rapier_fsa_blindfire_radar'] = {
				['max_range_finding_target'] = 30000,
				['min_range_finding_target'] = 500,
				['max_alt_finding_target'] = 4000,
				['min_alt_finding_target'] = 50,
                ['radar_rotation_period'] = 1.0,
            },
        },
        ['launchers'] = {
        	['rapier_fsa_launcher'] = {
				['missiles'] = 4,
				['range'] = 8800,
				['max_range_finding_target'] = 30000,
				['min_range_finding_target'] = 500,
				['max_alt_finding_target'] = 4000,
				['min_alt_finding_target'] = 50,
				['height'] = 2.5,
				['trackingRadar'] = true,
				['rearmTime'] = 210,
			},
        },
        ['misc'] = {
            ['rapier_fsa_optical_tracker_unit'] = {
                ['required'] = true,
            },
        },
        ['name'] = {
			['NATO'] = 'Rapier',
		},
    },	
	['M48 Chaparral'] = {
		['type'] = 'single',
		['mobile'] = true,
		['searchRadar'] = {
			['M48 Chaparral'] = {
				['max_range_finding_target'] = 10000,
				['min_range_finding_target'] = 0,
				['max_alt_finding_target'] = 2500,
				['min_alt_finding_target'] = 0,
				['height'] = 2.52,
				['ir'] = true,
				['trackingRadar'] = true,		
			},
		},
		['launchers'] = {
			['M48 Chaparral'] = {

				['range'] = 8500,
				['missiles'] = 4,		
				['ir'] = true,		
			},
		},
		['name'] = {
			['NATO'] = 'M48 Chaparral',
		},
	},
	['Vulcan'] = {
		['type'] = 'single',
		['mobile'] = true,
		
		['searchRadar'] = {
			['Vulcan'] = {
				['max_range_finding_target'] = 5000,
				['min_range_finding_target'] = 0,
				['max_alt_finding_target'] = 2500,
				['min_alt_finding_target'] = 0,
				['height'] = 3.872,
				['trackingRadar'] = true,
			},
		},
		['launchers'] = {
			['Vulcan'] = {

				['range'] = 1500,
				['aaa'] = true,
			},
		},
	
		['name'] = {
			['NATO'] = 'M163 Vulcan',
		},


	},
	['M1097 Avenger'] = {
		['type'] = 'single',
		['mobile'] = true,
		['searchRadar'] = {
			['M1097 Avenger'] = {
				['max_range_finding_target'] = 5200,
				['min_range_finding_target'] = 0,
				['max_alt_finding_target'] = 2500,
				['min_alt_finding_target'] = 0,
				['height'] = 3.076,
				['ir'] = true,
				['trackingRadar'] = true,		
			},
		},
		['launchers'] = {
			['M1097 Avenger'] = {
				
				['range'] = 1500,
				['missiles'] = 8,
				['ir'] = true,
				['guns'] = true,
			},
		},
		['name'] = {
			['NATO'] = 'M1097 Avenger',
		},
	},
	['Stinger'] = {
		['type'] = 'single',
		['searchRadar'] = {
			['Stinger manpad'] = {
				['max_range_finding_target'] = 5000,
				['min_range_finding_target'] = 0,
				['max_alt_finding_target'] = 3000,
				['min_alt_finding_target'] = 0,
				['height'] = 1.8,
				['ir'] = true,
				['trackingRadar'] = true,		
			},
		},
		['launchers'] = {
			['Stinger manpad'] = {

				['range'] = 5000,
				['missiles'] = 3,
				['ir'] = true,
			},
			['Stinger comm'] = {
				['height'] = 1.8,
				['range'] = 5000,
			},			
		},
		['name'] = {
			['NATO'] = 'Stinger manpad',
		},
	},
	['ZSU%-23%-4 Shilka'] = {
		['type'] = 'single',
		['mobile'] = true,
		['searchRadar'] = {
			['ZSU-23-4 Shilka'] = {
				['max_range_finding_target'] = 5000,
				['min_range_finding_target'] = 0,
				['max_alt_finding_target'] = 2500,
				['min_alt_finding_target'] = 0,
				['height'] = 3.458,
				['trackingRadar'] = true,		
			},
		},
		['launchers'] = {
			['ZSU-23-4 Shilka'] = {
				['range'] = 2500,
				['aaa'] = true,
			},
		},
		['name'] = {
			['NATO'] = 'Zues',
		},
	},
	['ZU%-23'] = { -- zu-23
		['type'] = 'single',
		['searchRadar'] = {
			['ZU%-23'] = {
				['max_range_finding_target'] = 5000,
				['min_range_finding_target'] = 0,
				['max_alt_finding_target'] = 2500,
				['min_alt_finding_target'] = 0,
				['range'] = 2500,
				['height'] = 1.736,
				['sensor'] = false,
			},
		},
		['launchers'] = {
			['ZU-23 Emplacement'] = {
				['aaa'] = true,
			},
			['ZU-23 Insurgent'] = {
				['aaa'] = true,
			},
			['ZU-23 Closed Insurgent'] = {
				['aaa'] = true,
			},
			['ZU-23 Emplacement Closed'] = {
				['aaa'] = true,
			},			
			['Ural-375 ZU-23'] = {
				['aaa'] = true,
				['mobile'] = true,
			},
			['Ural-375 ZU-23 Insurgent'] = {
				['aaa'] = true,
				['mobile'] = true,
			},			
		},
		
		['name'] = {
			['NATO'] = 'ZU-23 Emplacement',
		},
	},
	['1L13 EWR'] = {
		['type'] = 'ewr',
		['searchRadar'] = {
			['1L13 EWR'] = {
				['max_range_finding_target'] = 120000,
				['min_range_finding_target'] = 0,
				['max_alt_finding_target'] = 30000,
				['min_alt_finding_target'] = 50,
				['height'] = 39,
				['ewr'] = true,
				['cantTurnOffBug'] = true,
				['radar_rotation_period'] = 18.0/2,
			},
		},
		['name'] = {
			['NATO'] = '1L13 EWR',
		},
	},
	['55G6 EWR'] = {
		['type'] = 'ewr',
		['searchRadar'] = {
			['55G6 EWR'] = {
				['max_range_finding_target'] = 120000,
				['min_range_finding_target'] = 0,
				['max_alt_finding_target'] = 30000,
				['min_alt_finding_target'] = 50,
				['height'] = 39,
				['ewr'] = true,
				['cantTurnOffBug'] = true,
				['radar_rotation_period'] = 10.0/2,
			},
		},
		['name'] = {
			['NATO'] = '55G6 EWR',
		},
	},
	['Dog Ear'] = {
		['type'] = 'ewr',
		['mobile'] = true,
		['searchRadar'] = {
			['Dog Ear radar'] = {
				['max_range_finding_target'] = 35000,
				['min_range_finding_target'] = 100,
				['max_alt_finding_target'] = 10000,
				['min_alt_finding_target'] = 15,
				['height'] = 3.8,
				['ewr'] = true,
				['radar_rotation_period'] = 3.0,
			},
		},
		['name'] = {
			['NATO'] = 'Dog Ear',
		},
	},
	['Roland Radar'] = {
		['type'] = 'ewr',
		['mobile'] = true,
		['searchRadar'] = {
			['Roland Radar'] = {
				['max_range_finding_target'] = 35000,
				['min_range_finding_target'] = 1500,
				['max_alt_finding_target'] = 6000,
				['min_alt_finding_target'] = 15,
				['height'] = 6.87,
				['ewr'] = true,
				['radar_rotation_period'] = 3.0,
			},
		},
		['name'] = {
			['NATO'] = 'Roland EWR',
		},
	},
}
end
do
--[[
SAM Sites that engage HARMs:
SA-15


SAM Sites that ignore HARMS:
SA-11 (test again)
SA-10 (didn't react)
SA-6
]]--

--[[ Compile Scripts:

echo -- BUILD Timestamp: %DATE% %TIME% > skynet-iads-compiled.lua && type sam-types-db.lua skynet-iads.lua skynet-iads-abstract-dcs-object-wrapper.lua skynet-iads-abstract-element.lua skynet-iads-abstract-radar-element.lua skynet-iads-command-center.lua skynet-iads-contact.lua skynet-iads-early-warning-radar.lua skynet-iads-jammer.lua skynet-iads-sam-search-radar.lua skynet-iads-sam-site.lua skynet-iads-sam-tracking-radar.lua skynet-iads-sam-types-db-extension.lua syknet-iads-sam-launcher.lua >> skynet-iads-compiled.lua;

--]]

SkynetIADS = {}
SkynetIADS.__index = SkynetIADS

SkynetIADS.database = samTypesDB

function SkynetIADS:create()
	local iads = {}
	setmetatable(iads, SkynetIADS)
	iads.earlyWarningRadars = {}
	iads.samSites = {}
	iads.commandCenters = {}
	iads.ewRadarScanMistTaskID = nil
	iads.coalition = nil
	iads.contacts = {}
	iads.maxTargetAge = 32
	iads.contactUpdateInterval = 5
	iads.debugOutput = {}
	iads.debugOutput.IADSStatus = false
	iads.debugOutput.samWentDark = false
	iads.debugOutput.contacts = false
	iads.debugOutput.radarWentLive = false
	iads.debugOutput.ewRadarNoConnection = false
	iads.debugOutput.samNoConnection = false
	iads.debugOutput.jammerProbability = false
	iads.debugOutput.addedEWRadar = false
	iads.debugOutput.hasNoPower = false
	iads.debugOutput.addedSAMSite = false
	iads.debugOutput.warnings = true
	return iads
end

function SkynetIADS:setCoalition(item)
	if item then
		local coalitionID = item:getCoalition()
		if self.coalitionID == nil then
			self.coalitionID = coalitionID
		end
		if self.coalitionID ~= coalitionID then
			self:printOutput("element: "..item:getName().." has a different coalition than the IADS", true)
		end
	end
end

function SkynetIADS:getCoalition()
	return self.coalitionID
end

function SkynetIADS:addEarlyWarningRadarsByPrefix(prefix)
	for unitName, unit in pairs(mist.DBs.unitsByName) do
		local pos = string.find(string.lower(unitName), string.lower(prefix))
		--somehow the MIST unit db contains StaticObject, we check to see we only add Units
		local unit = Unit.getByName(unitName)
		if pos and pos == 1 and unit then
			self:addEarlyWarningRadar(unitName)
		end
	end
end

function SkynetIADS:addEarlyWarningRadar(earlyWarningRadarUnitName, powerSource, connectionNode)
	local earlyWarningRadarUnit = Unit.getByName(earlyWarningRadarUnitName)
	if earlyWarningRadarUnit == nil then
		self:printOutput("you have added an EW Radar that does not exist, check name of Unit in Setup and Mission editor: "..earlyWarningRadarUnitName, true)
		return
	end
	self:setCoalition(earlyWarningRadarUnit)
	local ewRadar = SkynetIADSEWRadar:create(earlyWarningRadarUnit, self)
	self:addPowerAndConnectionNodeTo(earlyWarningRadarUnitName, powerSource, connectionNode)
	table.insert(self.earlyWarningRadars, ewRadar)
	if self:getDebugSettings().addedEWRadar then
			self:printOutput(ewRadar:getDescription().." added to IADS")
	end
end

function SkynetIADS:setOptionsForEarlyWarningRadar(unitName, powerSource, connectionNode)
		local update = false
		for i = 1, #self.earlyWarningRadars do
			local ewRadar = self.earlyWarningRadars[i]
			if string.lower(ewRadar:getDCSName()) == string.lower(unitName) then
				self:addPowerAndConnectionNodeTo(ewRadar, powerSource, connectionNode)
				update = true
			end
		end
		if update == false then
			self:printOutput("you tried to set options for an EW radar that does not exist: "..unitName, true)
		end
end

function SkynetIADS:getEarlyWarningRadars()
	return self.earlyWarningRadars
end

function SkynetIADS:getEarlyWarningRadarByUnitName(unitName)
	for i = 1, #self.earlyWarningRadars do
		local ewRadar = self.earlyWarningRadars[i]
		if ewRadar:getDCSName() == unitName then
			return ewRadar
		end
	end
end

function SkynetIADS:addSamSitesByPrefix(prefix, autonomousMode)
	for groupName, groupData in pairs(mist.DBs.groupsByName) do
		local pos = string.find(string.lower(groupName), string.lower(prefix))
		if pos and pos == 1 then
			self:addSamSite(groupName, nil, nil, autonomousMode)
		end
	end
end

function SkynetIADS:addSamSite(samSiteName, powerSource, connectionNode, actAsEW, autonomousMode, firingRangePercent)
	local samSiteDCS = Group.getByName(samSiteName)
	if samSiteDCS == nil then
		self:printOutput("you have added an SAM Site that does not exist, check name of Group in Setup and Mission editor", true)
		return
	end
	self:setCoalition(samSiteDCS)
	local samSite = SkynetIADSSamSite:create(samSiteDCS, self)
	if samSite:getNatoName() == "UNKNOWN" then
		self:printOutput("you have added an SAM Site that Skynet IADS can not handle: "..samSite:getDCSName(), true)
	else
		samSite:goDark()
		table.insert(self.samSites, samSite)
		if self:getDebugSettings().addedSAMSite then
			self:printOutput(samSite:getDescription().." added to IADS")
		end
	end
	self:setOptionsForSamSite(samSiteName, powerSource, connectionNode, actAsEW, autonomousMode, firingRangePercent)
end

function SkynetIADS:setOptionsForSamSite(groupName, powerSource, connectionNode, actAsEW, autonomousMode, firingRangePercent)
	local update = false
	for i = 1, #self.samSites do
		local samSite = self.samSites[i]
		if string.lower(samSite:getDCSName()) == string.lower(groupName) then
			self:addPowerAndConnectionNodeTo(samSite, powerSource, connectionNode)
			samSite:setAutonomousBehaviour(autonomousMode)
			samSite:setActAsEW(actAsEW)
			samSite:setFiringRangePercent(firingRangePercent)
			update = true
		end
	end
	if update == false then
		self:printOutput("you tried to set options for a SAM site that does not exist: "..groupName, true)
	end
end

function SkynetIADS:getUsableSamSites()
	local usableSamSites = {}
	for i = 1, #self.samSites do
		local samSite = self.samSites[i]
		if samSite:hasActiveConnectionNode() and samSite:hasWorkingPowerSource() then
			table.insert(usableSamSites, samSite)
		end
	end
	return usableSamSites
end

function SkynetIADS:getUsableEarlyWarningRadars()
	local usable = {}
	for i = 1, #self.earlyWarningRadars do
		local ewRadar = self.earlyWarningRadars[i]
		if ewRadar:hasActiveConnectionNode() and ewRadar:hasWorkingPowerSource() and ewRadar:isDestroyed() == false then
			table.insert(usable, ewRadar)
		end
	end
	return usable
end

function SkynetIADS:getSamSites()
	return self.samSites
end

function SkynetIADS:getSamSiteByGroupName(groupName)
	for i = 1, #self.samSites do
		local samSite = self.samSites[i]
		if samSite:getDCSName() == groupName then
			return samSite
		end
	end
end

function SkynetIADS:addPowerAndConnectionNodeTo(iadsElement, powerSource, connectionNode)
	if powerSource then
		self:setCoalition(powerSource)
		iadsElement:addPowerSource(powerSource)
	end
	if connectionNode then
		self:setCoalition(connectionNode)
		iadsElement:addConnectionNode(connectionNode)
	end
end

function SkynetIADS:addCommandCenter(commandCenter, powerSource)
	self:setCoalition(commandCenter)
	if powerSource then
		self:setCoalition(powerSource)
	end
	local comCenter = SkynetIADSCommandCenter:create(commandCenter, self)
	comCenter:addPowerSource(powerSource)
	table.insert(self.commandCenters, comCenter)
end

function SkynetIADS:isCommandCenterUsable()
	local hasWorkingCommandCenter = (#self.commandCenters == 0)
	for i = 1, #self.commandCenters do
		local comCenter = self.commandCenters[i]
		if comCenter:getLife() > 0 and comCenter:hasWorkingPowerSource() then
			hasWorkingCommandCenter = true
			break
		else
			hasWorkingCommandCenter = false
		end
	end
	return hasWorkingCommandCenter
end

function SkynetIADS:getCommandCenters()
	return self.commandCenters
end

function SkynetIADS:setSamSitesToAutonomousMode()
	for i= 1, #self.samSites do
		samSite = self.samSites[i]
		samSite:goAutonomous()
	end
end

function SkynetIADS.evaluateContacts(self)
	if self:getDebugSettings().IADSStatus then
		self:printSystemStatus()
	end	
	local iadsContacts = {}
	if self:isCommandCenterUsable() == false then
		if self:getDebugSettings().noWorkingCommmandCenter then
			self:printOutput("No Working Command Center")
		end
		self:setSamSitesToAutonomousMode()
		return
	end
	for i = 1, #self.earlyWarningRadars do
		local ewRadar = self.earlyWarningRadars[i]
		if ewRadar:hasActiveConnectionNode() then
			local ewContacts = ewRadar:getDetectedTargets()
			for j = 1, #ewContacts do
				local contact = ewContacts[j]
				self:mergeContact(contact)
			end
		else
			if self:getDebugSettings().ewRadarNoConnection then
				self:printOutput(ewRadar:getDescription().." no connection to Command Center")
			end
		end
	end
	
	local usableSamSites = self:getUsableSamSites()
	
	for i = 1, #usableSamSites do
		local samSite = usableSamSites[i]
		--see if this can be written with better code. We inform SAM sites that a target update is about to happen. if they have no targets in range after the cycle they go dark
		samSite:targetCycleUpdateStart()
		local samContacts = samSite:getDetectedTargets()
		for j = 1, #samContacts do
			local contact = samContacts[j]
			self:mergeContact(contact)
		end
	end
	
	local contactsToKeep = {}
	for i = 1, #self.contacts do
		local contact = self.contacts[i]
		if contact:getAge() < self.maxTargetAge then
			table.insert(contactsToKeep, contact)
		end
	end
	self.contacts = contactsToKeep
	
	
	for i = 1, #self.contacts do
		local contact = self.contacts[i]
		if self:getDebugSettings().contacts then
			self:printOutput("CONTACT: "..contact:getName().." | TYPE: "..contact:getTypeName().."| GS: "..tostring(contact:getGroundSpeedInKnots()).." | LAST SEEN: "..contact:getAge())
		end
		--currently the DCS Radar only returns enemy aircraft, if that should change an coalition check will be required
		---Todo: currently every type of object in the air is handed of to the sam site, including bombs and missiles, shall these be removed?
		self:correlateWithSamSites(contact)
	end
	
	for i = 1, #usableSamSites do
		local samSite = usableSamSites[i]
		samSite:targetCycleUpdateEnd()
	end
end

function SkynetIADS:mergeContact(contact)
	local existingContact = false
	for i = 1, #self.contacts do
		local iadsContact = self.contacts[i]
		if iadsContact:getName() == contact:getName() then
			iadsContact:refresh()
			existingContact = true
		end
	end
	if existingContact == false then
		table.insert(self.contacts, contact)
	end
end

function SkynetIADS:getContacts()
	return self.contacts
end

function SkynetIADS:printOutput(output, typeWarning)
	if typeWarning == true and self.debugOutput.warnings or typeWarning == nil then
		if typeWarning == true then
			output = "WARNING: "..output
		end
		trigger.action.outText(output, 4)
	end
end

function SkynetIADS:getDebugSettings()
	return self.debugOutput
end

function SkynetIADS:correlateWithSamSites(detectedAircraft)	
	local usableSamSites = self:getUsableSamSites()
	for i = 1, #usableSamSites do
		local samSite = usableSamSites[i]		
		samSite:informOfContact(detectedAircraft)
	end
end

-- will start going through the Early Warning Radars and SAM sites to check what targets they have detected
function SkynetIADS:activate()
	if self.ewRadarScanMistTaskID ~= nil then
		mist.removeFunction(self.ewRadarScanMistTaskID)
	end
	self.ewRadarScanMistTaskID = mist.scheduleFunction(SkynetIADS.evaluateContacts, {self}, 1, self.contactUpdateInterval)
end

function SkynetIADS:printSystemStatus()	
	local numComCenters = #self.commandCenters
	local numIntactComCenters = 0
	local numDestroyedComCenters = 0
	local numComCentersNoPower = 0
	local numComCentersServingIADS = 0
	for i = 1, #self.commandCenters do
		local commandCenter = self.commandCenters[i]
		if commandCenter:hasWorkingPowerSource() == false then
			numComCentersNoPower = numComCentersNoPower + 1
		end
		if commandCenter:getLife() > 0 then
			numIntactComCenters = numIntactComCenters + 1
		end
		if commandCenter:getLife() > 0 and commandCenter:hasWorkingPowerSource() then
			numComCentersServingIADS = numComCentersServingIADS + 1
		end
	end
	
	numDestroyedComCenters = numComCenters - numIntactComCenters
	
	self:printOutput("COMMAND CENTERS: Serving IADS: "..numComCentersServingIADS.." | Total: "..numComCenters.." | Intact: "..numIntactComCenters.." | Destroyed: "..numDestroyedComCenters.." | No Power: "..numComCentersNoPower)
	
	local ewNoPower = 0
	local ewTotal = #self.earlyWarningRadars
	local ewNoConnectionNode = 0
	local ewActive = 0
	local ewRadarsInactive = 0

	for i = 1, #self.earlyWarningRadars do
		local ewRadar = self.earlyWarningRadars[i]
		if ewRadar:hasWorkingPowerSource() == false then
			ewNoPower = ewNoPower + 1
		end
		if ewRadar:hasActiveConnectionNode() == false then
			ewNoConnectionNode = ewNoConnectionNode + 1
		end
		if ewRadar:isActive() then
			ewActive = ewActive + 1
		end
	end
	
	ewRadarsInactive = ewTotal - ewActive
	
	self:printOutput("EW SITES: "..ewTotal.." | Active: "..ewActive.." | Inactive: "..ewRadarsInactive.." | No Power: "..ewNoPower.." | No Connection: "..ewNoConnectionNode)
	
	local samSitesInactive = 0
	local samSitesActive = 0
	local samSitesTotal = #self.samSites
	local samSitesNoPower = 0
	local samSitesNoConnectionNode = 0
	for i = 1, #self.samSites do
		local samSite = self.samSites[i]
		if samSite:hasWorkingPowerSource() == false then
			samSitesNoPower = samSitesNoPower + 1
		end
		if samSite:hasActiveConnectionNode() == false then
			samSitesNoConnectionNode = samSitesNoConnectionNode + 1
		end
		if samSite:isActive() then
			samSitesActive = samSitesActive + 1
		end
	end
	samSitesInactive = samSitesTotal - samSitesActive
	self:printOutput("SAM SITES: "..samSitesTotal.." | Active: "..samSitesActive.." | Inactive: "..samSitesInactive.." | No Power: "..samSitesNoPower.." | No Connection: "..samSitesNoConnectionNode)
end

end
do

SkynetIADSAbstractDCSObjectWrapper = {}

function SkynetIADSAbstractDCSObjectWrapper:create(dcsObject)
	local instance = {}
	setmetatable(instance, self)
	self.__index = self
	instance.dcsObject = dcsObject
	return instance
end

function SkynetIADSAbstractDCSObjectWrapper:getName()
	return self.dcsObject:getName()
end

function SkynetIADSAbstractDCSObjectWrapper:getTypeName()
	return self.dcsObject:getTypeName()
end

function SkynetIADSAbstractDCSObjectWrapper:getPosition()
	return self.dcsObject:getPosition()
end

function SkynetIADSAbstractDCSObjectWrapper:isExist()
	return self.dcsObject:isExist()
end

end
do

SkynetIADSAbstractElement = {}

function SkynetIADSAbstractElement:create(dcsRepresentation, iads)
	local instance = {}
	setmetatable(instance, self)
	self.__index = self
	instance.connectionNodes = {}
	instance.powerSources = {}
	instance.iads = iads
	instance.natoName = "UNKNOWN"
	instance:setDCSRepresentation(dcsRepresentation)
	world.addEventHandler(instance)
	return instance
end

function SkynetIADSAbstractElement:getLife()
	return self:getDCSRepresentation():getLife()
end

--- implemented in subclasses
function SkynetIADSAbstractElement:isDestroyed()

end

function SkynetIADSAbstractElement:addPowerSource(powerSource)
	table.insert(self.powerSources, powerSource)
end

function SkynetIADSAbstractElement:addConnectionNode(connectionNode)
	table.insert(self.connectionNodes, connectionNode)
end

function SkynetIADSAbstractElement:hasActiveConnectionNode()
	local connectionNode = self:genericCheckOneObjectIsAlive(self.connectionNodes)
	if connectionNode == false and self.iads:getDebugSettings().samNoConnection then
		self.iads:printOutput(self:getDescription().." no connection Command Center")
	end
	return connectionNode
end

function SkynetIADSAbstractElement:hasWorkingPowerSource()
	local power = self:genericCheckOneObjectIsAlive(self.powerSources)
	if power == false and self.iads:getDebugSettings().hasNoPower then
		self.iads:printOutput(self:getDescription().." has no power")
	end
	return power
end

function SkynetIADSAbstractElement:getDCSName()
	return self:getDCSRepresentation():getName()
end

-- generic function to theck if power plants, command centers, connection nodes are still alive
function SkynetIADSAbstractElement:genericCheckOneObjectIsAlive(objects)
	local isAlive = (#objects == 0)
	for i = 1, #objects do
		local object = objects[i]
		--if we find one object that is not fully destroyed we assume the IADS is still working
		if object:getLife() > 0 then
			isAlive = true
			break
		end
	end
	return isAlive
end

function SkynetIADSAbstractElement:setDCSRepresentation(representation)
	self.dcsRepresentation = representation
end

function SkynetIADSAbstractElement:getDCSRepresentation()
	return self.dcsRepresentation
end

function SkynetIADSAbstractElement:getNatoName()
	return self.natoName
end

function SkynetIADSAbstractElement:getDescription()
	return "IADS ELEMENT: "..self:getDCSRepresentation():getName().." | Type : "..tostring(self:getNatoName())
end

function SkynetIADSAbstractElement:onEvent(event)
	--if a unit is destroyed we check to see if its a power plant powering the unit or a connection node
	if event.id == world.event.S_EVENT_DEAD then
		if self:hasWorkingPowerSource() == false then
			self:goDark()
		end
		if self:hasActiveConnectionNode() == false then
			self:goAutonomous()
		end
	end
end

--placeholder method, can be implemented by subclasses
function SkynetIADSAbstractElement:goDark()
	
end

--placeholder method, can be implemented by subclasses
function SkynetIADSAbstractElement:goAutonomous()

end

-- helper code for class inheritance
function inheritsFrom( baseClass )

    local new_class = {}
    local class_mt = { __index = new_class }

    function new_class:create()
        local newinst = {}
        setmetatable( newinst, class_mt )
        return newinst
    end

    if nil ~= baseClass then
        setmetatable( new_class, { __index = baseClass } )
    end

    -- Implementation of additional OO properties starts here --

    -- Return the class object of the instance
    function new_class:class()
        return new_class
    end

    -- Return the super class object of the instance
    function new_class:superClass()
        return baseClass
    end

    -- Return true if the caller is an instance of theClass
    function new_class:isa( theClass )
        local b_isa = false

        local cur_class = new_class

        while ( nil ~= cur_class ) and ( false == b_isa ) do
            if cur_class == theClass then
                b_isa = true
            else
                cur_class = cur_class:superClass()
            end
        end

        return b_isa
    end

    return new_class
end

end
do

SkynetIADSAbstractRadarElement = {}
SkynetIADSAbstractRadarElement = inheritsFrom(SkynetIADSAbstractElement)

SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI = 0
SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK = 1

function SkynetIADSAbstractRadarElement:create(dcsElementWithRadar, iads)
	local instance = self:superClass():create(dcsElementWithRadar, iads)
	setmetatable(instance, self)
	self.__index = self
	instance.aiState = true
	instance.jammerID = nil
	instance.lastJammerUpdate = 0
	instance.setJammerChance = true
	instance.harmScanID = nil
	instance.harmSilenceID = nil
	instance.objectsIdentifiedAsHarms = {}
	instance.launchers = {}
	instance.trackingRadars = {}
	instance.searchRadars = {}
	instance.autonomousBehaviour = SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI
	instance.isAutonomous = false
	instance.harmDetectionChance = 0
	instance.minHarmShutdownTime = 0
	instance.maxHarmShutDownTime = 0
	instance.maxHarmPresetShuttdownTime = 180
	instance.firingRangePercent = 100
	instance:setupElements()
	return instance
end

function SkynetIADSAbstractRadarElement:setupElements()
	local units = {}
	local natoName = self.natoName
	local allUnitsFound = false
	units[1] = self:getDCSRepresentation()
	if getmetatable(self:getDCSRepresentation()) == Group then
		units = self:getDCSRepresentation():getUnits()
	end
	local unitTypes = {}
	--trigger.action.outText("-----"..self:getDCSName().."--------", 1)
	for i = 1, #units do
		local unitName = units[i]:getTypeName()
		if unitTypes[unitName] then
			unitTypes[unitName]['count'] = unitTypes[unitName]['count'] + 1
		else
			unitTypes[unitName] = {}
			unitTypes[unitName]['count'] = 1
			unitTypes[unitName]['found'] = 0
		end
	end
	for i = 1, #units do
		local unit = units[i]
		local unitTypeName = unit:getTypeName()
		for typeName, dataType in pairs(SkynetIADS.database) do
		
			allUnitsFound = true
			for name, countData in pairs(unitTypes) do
				if countData['count'] ~= countData['found'] then
					allUnitsFound = false
					countData['found'] = 0
				end
			end
			if allUnitsFound then
		--		trigger.action.outText("break", 1)
				break
			end
		
			for entry, unitData in pairs(dataType) do
				if entry == 'searchRadar' then
					for unitName, unitPerformanceData in pairs(unitData) do
						if unitName == unitTypeName then
							local searchRadar = SkynetIADSSAMSearchRadar:create(unit, unitPerformanceData)
							table.insert(self.searchRadars, searchRadar)
							--trigger.action.outText("added search radar", 1)
							unitTypes[unitName]['found'] = unitTypes[unitName]['found'] + 1
							natoName = dataType['name']['NATO']
							if dataType['harm_detection_chance'] ~= nil then
								self.harmDetectionChance = dataType['harm_detection_chance']
							end
						end
					end
				elseif entry == 'launchers' then
					for unitName, unitPerformanceData in pairs(unitData) do
						if unitName == unitTypeName then
							local launcher = SkynetIADSSAMLauncher:create(unit, unitPerformanceData)
							table.insert(self.launchers, launcher)
							unitTypes[unitName]['found'] = unitTypes[unitName]['found'] + 1
							natoName = dataType['name']['NATO']
							if dataType['harm_detection_chance'] ~= nil then
								self.harmDetectionChance = dataType['harm_detection_chance']
							end
							--trigger.action.outText(launcher:getRange(), 1)
						end
					end
				elseif entry == 'trackingRadar' then
					for unitName, unitPerformanceData in pairs(unitData) do
						if unitName == unitTypeName then
							local trackingRadar = SkynetIADSSAMTrackingRadar:create(unit, unitPerformanceData)
							table.insert(self.trackingRadars, trackingRadar)
							unitTypes[unitName]['found'] = unitTypes[unitName]['found'] + 1
							natoName = dataType['name']['NATO']
							if dataType['harm_detection_chance'] ~= nil then
								self.harmDetectionChance = dataType['harm_detection_chance']
							end
							--trigger.action.outText("added tracking radar", 1)
						end
					end
				end
			end
		end
	end
--	local countNatoNames = 0
--	for name, countData in pairs(unitTypes) do
	--	if countData['count'] ~= countData['found'] then
		--	trigger.action.outText("MISMATCH: "..name.." "..countData['count'].." "..countData['found'], 1)
	--	end
--	end
	--we shorten the SA-XX names and don't return their code names eg goa, gainful..
	local pos = natoName:find(" ")
	local prefix = natoName:sub(1, 2)
	if string.lower(prefix) == 'sa' and pos ~= nil then
		natoName = natoName:sub(1, (pos-1))
	end
	self.natoName = natoName
	--trigger.action.outText(self:getDCSName().." nato name: "..natoName.." HARM detection chance: "..tostring(self.harmDetectionChance), 1)
end

function SkynetIADSAbstractRadarElement:getController()
	local dcsRepresentation = self:getDCSRepresentation()
	if dcsRepresentation:isExist() then
		return dcsRepresentation:getController()
	else
		return nil
	end
end

function SkynetIADSAbstractRadarElement:getLaunchers()
	return self.launchers
end

function SkynetIADSAbstractRadarElement:getSearchRadars()
	return self.searchRadars
end

function SkynetIADSAbstractRadarElement:getTrackingRadars()
	return self.trackingRadars
end

function SkynetIADSAbstractRadarElement:getRadars()
	local radarUnits = {}	
	for i = 1, #self.searchRadars do
		table.insert(radarUnits, self.searchRadars[i])
	end	
	for i = 1, #self.trackingRadars do
		table.insert(radarUnits, self.trackingRadars[i])
	end
	return radarUnits
end

function SkynetIADSAbstractRadarElement:setFiringRangePercent(percent)
	if percent ~= nil then
		self.firingRangePercent = percent	
		for i = 1, #self.launchers do
			local launcher = self.launchers[i]
			launcher:setFiringRangePercent(self.firingRangePercent)
		end
	end
end

function SkynetIADSAbstractRadarElement:goLive()
	if ( self.aiState == false and self:hasWorkingPowerSource() and self.harmSilenceID == nil ) and ( (self.isAutonomous == false) or (self.isAutonomous == true and self.autonomousBehaviour == SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI ) ) then
		if self:isDestroyed() == false then
			local  cont = self:getController()
			cont:setOnOff(true)
			cont:setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.RED)	
			cont:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_FREE)
		end
		self.aiState = true
		if  self.iads:getDebugSettings().radarWentLive then
			self.iads:printOutput(self:getDescription().." going live")
		end
		self:scanForHarms()
	end
end

function SkynetIADSAbstractRadarElement:goDark()
	if ( self.aiState == true ) and ( ( #self:getDetectedTargets(true) == 0 or self.harmSilenceID ~= nil) or ( self.isAutonomous == true and self.autonomousBehaviour == SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK ) ) then
		if self:isDestroyed() == false then
			local controller = self:getController()
			-- fastest way to get a radar unit to stop emitting
			controller:setOnOff(false)
			--controller:setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.GREEN)
			--controller:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_HOLD)
		end
		self.aiState = false
		mist.removeFunction(self.jammerID)
		self:stopScanningForHarms()
		if self.iads:getDebugSettings().samWentDark then
			self.iads:printOutput(self:getDescription().." going dark")
		end
	end
end

function SkynetIADSAbstractRadarElement:isActive()
	return self.aiState
end

function SkynetIADSAbstractElement:isDestroyed()
	return self:getController() == nil
end

function SkynetIADSAbstractRadarElement:isTargetInRange(target)
	
	local isSearchRadarInRange = ( #self.searchRadars == 0 )
	for i = 1, #self.searchRadars do
		local searchRadar = self.searchRadars[i]
		if searchRadar:isInRange(target) then
			isSearchRadarInRange = true
		end
	end
	
	local isTrackingRadarInRange = ( #self.trackingRadars == 0 )
	for i = 1, #self.trackingRadars do
		local trackingRadar = self.trackingRadars[i]
		if trackingRadar:isInRange(target) then
			isTrackingRadarInRange = true
		end
	end
	
	local isLauncherInRange = ( #self.launchers == 0 )
	for i = 1, #self.launchers do
		local launcher = self.launchers[i]
		if launcher:isInRange(target) or launcher:isAAA() then
			isLauncherInRange = true
		end
	end
	--if self.natoName == 'SA-11' then
	--	trigger.action.outText(target:getName(), 1)
	--	trigger.action.outText(self:getNatoName()..": in Range of Search Radar: "..tostring(isSearchRadarInRange).." Launcher: "..tostring(isLauncherInRange).." Tracking Radar: "..tostring(isTrackingRadarInRange), 1)
	--end
	return  (isSearchRadarInRange and isTrackingRadarInRange and isLauncherInRange )
end

function SkynetIADSAbstractRadarElement:setAutonomousBehaviour(mode)
	if mode ~= nil then
		self.autonomousBehaviour = mode
	end
end

function SkynetIADSAbstractRadarElement:goAutonomous()
	self.isAutonomous = true
	self:goDark()
	self:goLive()
end

function SkynetIADSAbstractRadarElement:jam(successProbability)
	--trigger.action.outText(self.lastJammerUpdate, 2)
	if self.lastJammerUpdate == 0 then
		--trigger.action.outText("updating jammer probability", 5)
		self.lastJammerUpdate = 10
		self.setJammerChance = true
		mist.removeFunction(self.jammerID)
		self.jammerID = mist.scheduleFunction(SkynetIADSAbstractRadarElement.setJamState, {self, successProbability}, 1, 1)
	end
end

function SkynetIADSAbstractRadarElement.setJamState(self, successProbability)
	if self.setJammerChance then
		if self:isDestroyed() == false then
			local controller = self:getController()
			self.setJammerChance = false
			local probability = math.random(1, 100)
			if self.iads:getDebugSettings().jammerProbability then
				self.iads:printOutput("JAMMER: "..self:getDescription()..": Probability: "..successProbability)
			end
			if successProbability > probability then
				controller:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_HOLD)
				if self.iads:getDebugSettings().jammerProbability then
					self.iads:printOutput("JAMMER: "..self:getDescription()..": jammed, setting to weapon hold")
				end
			else
				controller:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_FREE)
				if self.iads:getDebugSettings().jammerProbability then
					self.iads:printOutput("Jammer: "..self:getDescription()..": jammed, setting to weapon free")
				end
			end
		end
	end
	self.lastJammerUpdate = self.lastJammerUpdate - 1
end

function SkynetIADSAbstractRadarElement:scanForHarms()
	self:stopScanningForHarms()
	self.harmScanID = mist.scheduleFunction(SkynetIADSAbstractRadarElement.evaluateIfTargetsContainHarms, {self}, 1, 2)
end

function SkynetIADSAbstractRadarElement:stopScanningForHarms()
	mist.removeFunction(self.harmScanID)
	self.harmScanID = nil
end

function SkynetIADSAbstractRadarElement:goSilentToEvadeHarm()
	self:finishHarmDefence(self)
	self.objectsIdentifiedAsHarms = {}
	self.harmSilenceID = mist.scheduleFunction(SkynetIADSAbstractRadarElement.finishHarmDefence, {self}, timer.getTime() + harmTime, 1)
	self:goDark()
	local harmTime = self:getHarmShutDownTime()
	--trigger.action.outText(tostring(self.harmSilenceID), 1)
	--trigger.action.outText(tostring(harmTime), 1)
end

function SkynetIADSAbstractRadarElement:getHarmShutDownTime()
	local shutDownTime = math.random(self.minHarmShutdownTime, self.maxHarmShutDownTime)
	trigger.action.outText("shutdowntime: "..shutDownTime, 1)
	return shutDownTime
end

function SkynetIADSAbstractRadarElement.finishHarmDefence(self)
	--trigger.action.outText("finish harm defence", 1)
	mist.removeFunction(self.harmSilenceID)
	self.harmSilenceID = nil
end

function SkynetIADSAbstractRadarElement:getDetectedTargets(inKillZone)
	local returnTargets = {}
	if self:hasWorkingPowerSource() and self:isDestroyed() == false then
		local targets = self:getController():getDetectedTargets(Controller.Detection.RADAR)
		for i = 1, #targets do
			local target = targets[i]
			-- there are cases when a destroyed object is still visible as a target to the radar, don't add it, will cause errors in the sam firing code
			if target.object then
				local iadsTarget = SkynetIADSContact:create(target)
				iadsTarget:refresh()
				if inKillZone then
					if self:isTargetInRange(iadsTarget) then
						table.insert(returnTargets, iadsTarget)
					end
				else
					table.insert(returnTargets, iadsTarget)
				end
			end
		end
	end
	return returnTargets
end

function SkynetIADSAbstractRadarElement.evaluateIfTargetsContainHarms(self, detectionType)
	local targets = self:getDetectedTargets() 
	for i = 1, #targets do
		local target = targets[i]
		--if target:getTypeName() == 'weapons.missiles.AGM_88' then
		--	trigger.action.outText("Detection Type: "..detectionType, 1)
		--	trigger.action.outText(target:getTypeName(), 1)
		--	trigger.action.outText("Is Type Known: "..tostring(target:isTypeKnown()), 1)
		--	trigger.action.outText("Distance is Known: "..tostring(target:isDistanceKnown()), 1)
			local radars = self:getRadars()
			for j = 1, #radars do
				local radar = radars[j]
				local distance = mist.utils.get3DDist(target:getPosition().p, radar:getPosition().p)
			--	trigger.action.outText("Missile to SAM distance: "..distance, 1)
				-- distance needs to be incremented by a certain value for ip calculation to work, check why
				local impactPoint = land.getIP(target:getPosition().p, target:getPosition().x, distance + 100)
				if impactPoint then
					local diststanceToSam = mist.utils.get2DDist(radar:getPosition().p, impactPoint)
					--trigger.action.outText("Impact Point distance to SAM site: "..diststanceToSam, 1)
					---trigger.action.outText("detected Object Name: "..target:getName(), 1)
					--trigger.action.outText("Impact Point X: "..impactPoint.x.."Y: "..impactPoint.y.."Z: "..impactPoint.z, 1)
					if diststanceToSam <= 100 then
						local numDetections = 0
						if self.objectsIdentifiedAsHarms[target:getName()] then
							numDetections = self.objectsIdentifiedAsHarms[target:getName()]['num_detections']
							numDetections = numDetections + 1
							self.objectsIdentifiedAsHarms[target:getName()]['num_detections'] = numDetections
						else
							self.objectsIdentifiedAsHarms[target:getName()]= {}
							self.objectsIdentifiedAsHarms[target:getName()]['target'] = target
							self.objectsIdentifiedAsHarms[target:getName()]['num_detections'] = 0
							numDetections = self.objectsIdentifiedAsHarms[target:getName()]['num_detections']
						end
						local randomReaction = math.random(1, 100)
						local targetHarm = self.objectsIdentifiedAsHarms[target:getName()]['target']
						targetHarm:refresh()
						local speed = targetHarm:getGroundSpeedInKnots()
						local timeToImpact =  mist.utils.round((mist.utils.metersToNM(distance) / speed) * 3600, 0)
						trigger.action.outText("detection Cycle: "..numDetections.." Random: "..randomReaction.." GS: "..targetHarm:getGroundSpeedInKnots().."TTI: "..timeToImpact, 1)
						---use distance and speed of harm to determine min shutdown time
						if numDetections == 3 and self.harmDetectionChance > randomReaction then
							self.minHarmShutdownTime = timeToImpact + 30
							self.maxHarmShutDownTime = self.minHarmShutdownTime + math.random(1, self.maxHarmPresetShuttdownTime)
							trigger.action.outText("SAM EVADING HARM", 1)
							self:goSilentToEvadeHarm()
						end
					end
				end
			end
	--	end
	end
end

end
do
SkynetIADSCommandCenter = {}
SkynetIADSCommandCenter = inheritsFrom(SkynetIADSAbstractElement)

function SkynetIADSCommandCenter:create(commandCenter, iads)
	local instance = self:superClass():create(commandCenter, iads)
	setmetatable(instance, self)
	self.__index = self
	instance.natoName = "Command Center"
	return instance
end

end
do

SkynetIADSContact = {}
SkynetIADSContact = inheritsFrom(SkynetIADSAbstractDCSObjectWrapper)

function SkynetIADSContact:create(dcsRadarTarget)
	local instance = self:superClass():create(dcsRadarTarget.object)
	setmetatable(instance, self)
	self.__index = self
	instance.firstContactTime = timer.getAbsTime()
	instance.lastTimeSeen = 0
	instance.dcsRadarTarget = dcsRadarTarget
	instance.name = instance.dcsObject:getName()
	instance.typeName = instance.dcsObject:getTypeName()
	instance.position = instance.dcsObject:getPosition()
	self.speed = 0
	return instance
end

function SkynetIADSContact:getName()
	return self.name
end

function SkynetIADSContact:getTypeName()
	return self.typeName
end

function SkynetIADSContact:isTypeKnown()
	return self.dcsRadarTarget.type
end

function SkynetIADSContact:isDistanceKnown()
	return self.dcsRadarTarget.distance
end

function SkynetIADSContact:getPosition()
	return self.position
end

function SkynetIADSContact:getGroundSpeedInKnots(decimals)
	if decimals == nil then
		decimals = 2
	end
	return mist.utils.round(self.speed, decimals)
end

function SkynetIADSContact:refresh()
	if self.dcsObject and self.dcsObject:isExist() then
		local distance = mist.utils.metersToNM(mist.utils.get2DDist(self.position.p, self.dcsObject:getPosition().p))
		local timeDelta = (timer.getAbsTime() - self.lastTimeSeen)
		if timeDelta > 0 then
			local hours = timeDelta / 3600
		--	trigger.action.outText("distance: "..distance, 1)
		--	trigger.action.outText("hours: "..hours,1)
			self.speed = (distance / hours)
		end 
		self.position = self.dcsObject:getPosition()
	end
	self.lastTimeSeen = timer.getAbsTime()
end

function SkynetIADSContact:getAge()
	return timer.getAbsTime() - self.lastTimeSeen
end

end

do

SkynetIADSEWRadar = {}
SkynetIADSEWRadar = inheritsFrom(SkynetIADSAbstractRadarElement)

function SkynetIADSEWRadar:create(radarUnit, iads)
	local instance = self:superClass():create(radarUnit, iads)
	setmetatable(instance, self)
	self.__index = self
	return instance
end

end
do

SkynetIADSJammer = {}
SkynetIADSJammer.__index = SkynetIADSJammer

function SkynetIADSJammer:create(emitter)
	local jammer = {}
	setmetatable(jammer, SkynetIADSJammer)
	jammer.emitter = emitter
	jammer.jammerTaskID = nill
	jammer.iads = {}
	--jammer probability settings are stored here, visualisation, see: https://docs.google.com/spreadsheets/d/16rnaU49ZpOczPEsdGJ6nfD0SLPxYLEYKmmo4i2Vfoe0/edit#gid=0
	jammer.jammerTable = {
		['SA-2'] = {
			['function'] = function(distanceNauticalMiles) return ( 1.4 ^ distanceNauticalMiles ) + 90 end,
			['canjam'] = true,
		},
		['SA-3'] = {
			['function'] = function(distanceNauticalMiles) return ( 1.4 ^ distanceNauticalMiles ) + 80 end,
			['canjam'] = true,
		},
		['SA-6'] = {
			['function'] = function(distanceNauticalMiles) return ( 1.4 ^ distanceNauticalMiles ) + 23 end,
			['canjam'] = true,
		},
		['SA-10'] = {
			['function'] = function(distanceNauticalMiles) return ( 1.07 ^ (distanceNauticalMiles / 1.13) ) + 5 end,
			['canjam'] = true,
		},
		['SA-11'] = {
			['function'] = function(distanceNauticalMiles) return ( 1.25 ^ distanceNauticalMiles ) + 15 end,
			['canjam'] = true,
		},
		['SA-15'] = {
			['function'] = function(distanceNauticalMiles) return ( 1.15 ^ distanceNauticalMiles ) + 5 end,
			['canjam'] = true,
		},
	}
	return jammer
end

function SkynetIADSJammer:masterArmOn()
	self:masterArmSafe()
	self.jammerTaskID = mist.scheduleFunction(SkynetIADSJammer.runCycle, {self}, 1, 1)
end

function SkynetIADSJammer:disableFor(natoName)
	self.jammerTable[natoName]['canjam'] = false
end

function SkynetIADSJammer:isActiveForEmitterType(natoName)
	return self.jammerTable[natoName]['canjam']
end

function SkynetIADSJammer:addIADS(iads)
	table.insert(self.iads, iads)
end

function SkynetIADSJammer:getSuccessProbability(distanceNauticalMiles, natoName)
	local probability = 0
	local jammerSettings = self.jammerTable[natoName]
	if jammerSettings ~= nil then
		probability = jammerSettings['function'](distanceNauticalMiles)
	end
	return probability
end

function SkynetIADSJammer.runCycle(self)

	if self.emitter:getLife() == 1 then
		self:masterArmSafe()
	--	trigger.action.outText("emitter is dead", 1)
		return
	end

	for i = 1, #self.iads do
		local iads = self.iads[i]
		local samSites = iads:getSamSites()	
		for j = 1, #samSites do
			local samSite = samSites[j]
			local radars = samSite:getRadars()
			local hasLOS = false
			local distance = 0
			local natoName = samSite:getNatoName()
			for l = 1, #radars do
				local radar = radars[l]
				distance = mist.utils.metersToNM(mist.utils.get2DDist(self.emitter:getPosition().p, radar:getPosition().p))
				-- I try to emulate the system as it would work in real life, so a jammer can only jam a SAM site if has line of sight to at least one radar in the group
				if self:hasLineOfSightToRadar(radar) then
					hasLOS = true
				end
			end
			if samSite:isActive() and self:isActiveForEmitterType(natoName) then
			--	trigger.action.outText("Distance: "..distance, 2)
			--	trigger.action.outText("Jammer Probability: "..self:getSuccessProbability(distance, natoName), 2)
				samSite:jam(self:getSuccessProbability(distance, natoName))
			end
		end
	end
	--trigger.action.outText("jammer cycle",1)
end

function SkynetIADSJammer:hasLineOfSightToRadar(radar)
	local radarPos = radar:getPosition().p
	--lift the radar 3 meters off the ground, some 3d models are dug in to the ground, creating issues in calculating LOS
	radarPos.y = radarPos.y + 3
	return land.isVisible(radarPos, self.emitter:getPosition().p) 
end

function SkynetIADSJammer:masterArmSafe()
	mist.removeFunction(self.jammerTaskID)
end

end
do

SkynetIADSSAMSearchRadar = {}
SkynetIADSSAMSearchRadar = inheritsFrom(SkynetIADSAbstractDCSObjectWrapper)

function SkynetIADSSAMSearchRadar:create(unit, performanceData)
	local instance = self:superClass():create(unit)
	setmetatable(instance, self)
	self.__index = self
	instance.performanceData = performanceData
	return instance
end

function SkynetIADSSAMSearchRadar:getMaxRangeFindingTarget()
	return self.performanceData['max_range_finding_target']
end

function SkynetIADSSAMSearchRadar:getMinRangeFindingTarget()
	return self.performanceData['min_range_finding_target']
end

function SkynetIADSSAMSearchRadar:getMaxAltFindingTarget()
	return self.performanceData['max_alt_finding_target']
end

function SkynetIADSSAMSearchRadar:getMinAltFindingTarget()
	return self.performanceData['min_alt_finding_target']
end

function SkynetIADSSAMSearchRadar:isInRange(target)
	local distance = mist.utils.get3DDist(target:getPosition().p, self.dcsObject:getPosition().p)
	local radarHeight = self.dcsObject:getPosition().p.y
	local aircraftHeight = target:getPosition().p.y	
	local altitudeDifference = math.abs(aircraftHeight - radarHeight)
	local maxDetectionAltitude = self:getMaxAltFindingTarget()
	local maxDetectionRange = self:getMaxRangeFindingTarget()
	--trigger.action.outText("Radar Range: "..maxDetectionRange,1)
	--trigger.action.outText("current distance: "..distance,1)
	return altitudeDifference <= maxDetectionAltitude and distance <= maxDetectionRange
end

end
do

SkynetIADSSamSite = {}
SkynetIADSSamSite = inheritsFrom(SkynetIADSAbstractRadarElement)

function SkynetIADSSamSite:create(samGroup, iads)
	local sam = self:superClass():create(samGroup, iads)
	setmetatable(sam, self)
	self.__index = self
	sam.actAsEW = false
	sam.targetsInRange = false
	return sam
end

function SkynetIADSSamSite:setActAsEW(ewState)
	if ewState == true or ewState == false then
		self.actAsEW = ewState
	end
	if self.actAsEW == true then
		self:goLive()
	else
		self:goDark()
	end
end

function SkynetIADSSamSite:targetCycleUpdateStart()
	self.targetsInRange = false
end

function SkynetIADSSamSite:targetCycleUpdateEnd()
	if self.targetsInRange == false and self.actAsEW == false then
		self:goDark()
	end
end

function SkynetIADSSamSite:informOfContact(contact)
	if self:isTargetInRange(contact) or self.actAsEW then
		self:goLive()
		self.targetsInRange = true
	end
end

end
do

SkynetIADSSAMTrackingRadar = {}
SkynetIADSSAMTrackingRadar = inheritsFrom(SkynetIADSSAMSearchRadar)

function SkynetIADSSAMTrackingRadar:create(unit, performanceData)
	local instance = self:superClass():create(unit, performanceData)
	setmetatable(instance, self)
	self.__index = self
	return instance
end

end
do

-- values beteween 0 and 100, represents the reaction probability

local ew1l13 = samTypesDB['1L13 EWR']
ew1l13['harm_detection_chance'] = 60

local ewr55g6 = samTypesDB['55G6 EWR']
ewr55g6['harm_detection_chance'] = 60

local dogEar = samTypesDB['Dog Ear']
dogEar['harm_detection_chance'] = 20

local sa2 = samTypesDB['s%-75']
sa2['harm_detection_chance'] = 30

local sa3 = samTypesDB['s%-125']
sa3['harm_detection_chance'] = 40

local sa6 = samTypesDB['Kub']
sa6['harm_detection_chance'] = 10

local sa11 = samTypesDB['Buk']
sa11['harm_detection_chance'] = 70

local sa19 = samTypesDB['s%-125']
sa19['harm_detection_chance'] = 10

end
do

SkynetIADSSAMLauncher = {}
SkynetIADSSAMLauncher = inheritsFrom(SkynetIADSAbstractDCSObjectWrapper)

function SkynetIADSSAMLauncher:create(unit, performanceData)
	local instance = self:superClass():create(unit)
	setmetatable(instance, self)
	self.__index = self
	instance.performanceData = performanceData
	instance.firingRangePercent = 100
	return instance
end

function SkynetIADSSAMLauncher:getRange()
	return self.performanceData['range']
end

function SkynetIADSSAMLauncher:isAAA()
	local isAAA = self.performanceData['aaa']
	if isAAA == nil then
		isAAA = false
	end
	return isAAA
end

function SkynetIADSSAMLauncher:setFiringRangePercent(percent)
	self.firingRangePercent = percent
end

function SkynetIADSSAMLauncher:isInRange(target)
	local distance = mist.utils.get2DDist(target:getPosition().p, self.dcsObject:getPosition().p)
	local maxFiringRange = (self:getRange() / 100 * self.firingRangePercent)
	--trigger.action.outText("Launcher Range: "..maxFiringRange,1)
	--trigger.action.outText("current distance: "..distance,1)
	return distance <= maxFiringRange
end

end
