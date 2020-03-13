-- BUILD Timestamp: 13.03.2020 20:13:56.89  
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
				['max_range_finding_target'] = 160000,
				['min_range_finding_target'] = 1500,
				['max_alt_finding_target'] = 30000,
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
				['max_range_finding_target'] = 160000,
				['min_range_finding_target'] = 1500,
				['max_alt_finding_target'] = 30000,
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
SA-10
SA-6
]]--

--[[ Compile Scripts:

echo -- BUILD Timestamp: %DATE% %TIME% > skynet-iads-compiled.lua && type sam-types-db.lua skynet-iads.lua skynet-iads-table-delegator.lua skynet-iads-abstract-dcs-object-wrapper.lua skynet-iads-abstract-element.lua skynet-iads-abstract-radar-element.lua skynet-iads-command-center.lua skynet-iads-contact.lua skynet-iads-early-warning-radar.lua skynet-iads-jammer.lua skynet-iads-sam-search-radar.lua skynet-iads-sam-site.lua skynet-iads-sam-tracking-radar.lua skynet-iads-sam-types-db-extension.lua syknet-iads-sam-launcher.lua >> skynet-iads-compiled.lua;

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
	iads.debugOutput.harmDefence = false
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

function SkynetIADS:getDestroyedEarlyWarningRadars()
	local destroyedSites = {}
	for i = 1, #self.earlyWarningRadars do
		local ewSite = self.earlyWarningRadars[i]
		if ewSite:isDestroyed() then
			table.insert(destroyedSites, ewSite)
		end
	end
	return destroyedSites
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

function SkynetIADS:createTableDelegator(units) 
	local sites = SkynetIADSTableDelegator:create()
	for i = 1, #units do
		local site = units[i]
		table.insert(sites, site)
	end
	return sites
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
	return self:createTableDelegator(self.earlyWarningRadars)
end

function SkynetIADS:addEarlyWarningRadar(earlyWarningRadarUnitName)
	local earlyWarningRadarUnit = Unit.getByName(earlyWarningRadarUnitName)
	if earlyWarningRadarUnit == nil then
		self:printOutput("you have added an EW Radar that does not exist, check name of Unit in Setup and Mission editor: "..earlyWarningRadarUnitName, true)
		return
	end
	self:setCoalition(earlyWarningRadarUnit)
	local ewRadar = SkynetIADSEWRadar:create(earlyWarningRadarUnit, self)
	table.insert(self.earlyWarningRadars, ewRadar)
	if self:getDebugSettings().addedEWRadar then
			self:printOutput(ewRadar:getDescription().." added to IADS")
	end
	return ewRadar
end

function SkynetIADS:getEarlyWarningRadars()
	return self:createTableDelegator(self.earlyWarningRadars)
end

function SkynetIADS:getEarlyWarningRadarByUnitName(unitName)
	for i = 1, #self.earlyWarningRadars do
		local ewRadar = self.earlyWarningRadars[i]
		if ewRadar:getDCSName() == unitName then
			return ewRadar
		end
	end
end

function SkynetIADS:addSamSitesByPrefix(prefix)
	for groupName, groupData in pairs(mist.DBs.groupsByName) do
		local pos = string.find(string.lower(groupName), string.lower(prefix))
		if pos and pos == 1 then
			--mist returns groups, units and, StaticObjects
			local dcsObject = Group.getByName(groupName)
			if dcsObject then
				self:addSamSite(groupName)
			end
		end
	end
	return self:createTableDelegator(self.samSites)
end

function SkynetIADS:addSamSite(samSiteName)
	local samSiteDCS = Group.getByName(samSiteName)
	if samSiteDCS == nil then
		self:printOutput("you have added an SAM Site that does not exist, check name of Group in Setup and Mission editor: "..tostring(samSiteName), true)
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
		return samSite
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


function SkynetIADS:getDestroyedSamSites()
	local destroyedSites = {}
	for i = 1, #self.samSites do
		local samSite = self.samSites[i]
		if samSite:isDestroyed() then
			table.insert(destroyedSites, samSite)
		end
	end
	return destroyedSites
end

function SkynetIADS:getSamSites()
	return self:createTableDelegator(self.samSites)
end

function SkynetIADS:getSAMSiteByGroupName(groupName)
	for i = 1, #self.samSites do
		local samSite = self.samSites[i]
		if samSite:getDCSName() == groupName then
			return samSite
		end
	end
end

function SkynetIADS:getSAMSitesByNatoName(natoName)
	local selectedSAMSites = SkynetIADSTableDelegator:create()
	for i = 1, #self.samSites do
		local samSite = self.samSites[i]
		if samSite:getNatoName() == natoName then
			table.insert(selectedSAMSites, samSite)
		end
	end
	return selectedSAMSites
end

function SkynetIADS:addCommandCenter(commandCenter)
	self:setCoalition(commandCenter)
	if powerSource then
		self:setCoalition(powerSource)
	end
	local comCenter = SkynetIADSCommandCenter:create(commandCenter, self)
	table.insert(self.commandCenters, comCenter)
	return comCenter
end

function SkynetIADS:isCommandCenterUsable()
	local hasWorkingCommandCenter = (#self.commandCenters == 0)
	for i = 1, #self.commandCenters do
		local comCenter = self.commandCenters[i]
		if comCenter:isDestroyed() == false and comCenter:hasWorkingPowerSource() then
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

function SkynetIADS:addRadioMenu()
	local skynetMenu = missionCommands.addSubMenu('SKYNET IADS')
	local displayIADSStatus = missionCommands.addCommand('show IADS Status', skynetMenu, SkynetIADS.updateDisplay, {self = self, value = true, option = 'IADSStatus'})
	local displayIADSStatus = missionCommands.addCommand('hide IADS Status', skynetMenu, SkynetIADS.updateDisplay, {self = self, value = false, option = 'IADSStatus'})
	local displayIADSStatus = missionCommands.addCommand('show contacts', skynetMenu, SkynetIADS.updateDisplay, {self = self, value = true, option = 'contacts'})
	local displayIADSStatus = missionCommands.addCommand('hide contacts', skynetMenu, SkynetIADS.updateDisplay, {self = self, value = false, option = 'contacts'})
end

function SkynetIADS:removeRadioMenu()
	missionCommands.removeItem('SKYNET IADS')
end

function SkynetIADS.updateDisplay(params)
	local option = params.option
	local self = params.self
	local value = params.value
	if option == 'IADSStatus' then
		self:getDebugSettings()[option] = value
	elseif option == 'contacts' then
		self:getDebugSettings()[option] = value
	end
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
		if commandCenter:isDestroyed() == false then
			numIntactComCenters = numIntactComCenters + 1
		end
		if commandCenter:isDestroyed() == false and commandCenter:hasWorkingPowerSource() then
			numComCentersServingIADS = numComCentersServingIADS + 1
		end
	end
	
	numDestroyedComCenters = numComCenters - numIntactComCenters
	
	self:printOutput("COMMAND CENTERS: Serving IADS: "..numComCentersServingIADS.." | Total: "..numComCenters.." | Inactive: "..numIntactComCenters.." | Destroyed: "..numDestroyedComCenters.." | No Power: "..numComCentersNoPower)
	
	local ewNoPower = 0
	local ewTotal = #self:getEarlyWarningRadars()
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
	local numEWRadarsDestroyed = #self:getDestroyedEarlyWarningRadars()
	self:printOutput("EW SITES: "..ewTotal.." | Active: "..ewActive.." | Inactive: "..ewRadarsInactive.." | Destroyed: "..numEWRadarsDestroyed.." | No Power: "..ewNoPower.." | No Connection: "..ewNoConnectionNode)
	
	local samSitesInactive = 0
	local samSitesActive = 0
	local samSitesTotal = #self:getSamSites()
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
	local numSamSitesDestroyed = #self:getDestroyedSamSites()
	self:printOutput("SAM SITES: "..samSitesTotal.." | Active: "..samSitesActive.." | Inactive: "..samSitesInactive.." | Destroyed: "..numSamSitesDestroyed.." | No Power: "..samSitesNoPower.." | No Connection: "..samSitesNoConnectionNode)
end

end
do


SkynetIADSTableDelegator = {}

function SkynetIADSTableDelegator:create()
	local instance = {}
	local forwarder = {}
	forwarder.__index = function(tbl, name)
		tbl[name] = function(self, ...)
				for i = 1, #self do
					self[i][name](self[i], ...)
				end
				return self
			end
		return tbl[name]
	end
	setmetatable(instance, forwarder)
	instance.__index = forwarder
	return instance
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

function SkynetIADSAbstractDCSObjectWrapper:getDCSRepresentation()
	return self.dcsObject
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

function SkynetIADSAbstractElement:isDestroyed()
	return self:getDCSRepresentation():isExist() == false
end

function SkynetIADSAbstractElement:addPowerSource(powerSource)
	table.insert(self.powerSources, powerSource)
	return self
end

function SkynetIADSAbstractElement:getPowerSources()
	return self.powerSources
end

function SkynetIADSAbstractElement:addConnectionNode(connectionNode)
	table.insert(self.connectionNodes, connectionNode)
	return self
end

function SkynetIADSAbstractElement:getConnectionNodes()
	return self.connectionNodes
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
		if object:isExist() then
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
		if self:hasWorkingPowerSource() == false or self:isDestroyed() then
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

SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI = 1
SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK = 2

SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE = 1
SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE = 2

function SkynetIADSAbstractRadarElement:create(dcsElementWithRadar, iads)
	local instance = self:superClass():create(dcsElementWithRadar, iads)
	setmetatable(instance, self)
	self.__index = self
	instance.aiState = false
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
	instance.goLiveRange = SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE
	instance.isAutonomous = false
	instance.harmDetectionChance = 0
	instance.minHarmShutdownTime = 0
	instance.maxHarmShutDownTime = 0
	instance.minHarmPresetShutdownTime = 30
	instance.maxHarmPresetShutdownTime = 180
	instance.firingRangePercent = 100
	instance:setupElements()
	instance:goLive()
	return instance
end


function SkynetIADSAbstractRadarElement:getUnitsToAnalyse()
	local units = {}
	units[1] = self:getDCSRepresentation()
	if getmetatable(self:getDCSRepresentation()) == Group then
		units = self:getDCSRepresentation():getUnits()
	end
	return units
end

function SkynetIADSAbstractRadarElement:getHARMDetectionChance()
	return self.harmDetectionChance
end

function SkynetIADSAbstractRadarElement:setHARMDetectionChance(chance)
	self.harmDetectionChance = chance
end

function SkynetIADSAbstractRadarElement:setupElements()
	local numUnits = #self:getUnitsToAnalyse()
	for typeName, dataType in pairs(SkynetIADS.database) do
		local hasSearchRadar = false
		local hasTrackingRadar = false
		local hasLauncher = false
		self.searchRadars = {}
		self.trackingRadars = {}
		self.launchers = {}
		for entry, unitData in pairs(dataType) do
			if entry == 'searchRadar' then
				self:analyseAndAddUnit(SkynetIADSSAMSearchRadar, self.searchRadars, unitData)
				hasSearchRadar = true
			end
			if entry == 'launchers' then
				self:analyseAndAddUnit(SkynetIADSSAMLauncher, self.launchers, unitData)
				hasLauncher = true
			end
			if entry == 'trackingRadar' then
				self:analyseAndAddUnit(SkynetIADSSAMTrackingRadar, self.trackingRadars, unitData)
				hasTrackingRadar = true
			end
		end
		
		local numElementsCreated = #self.searchRadars + #self.trackingRadars + #self.launchers
		--this check ensures a unit or group has all required elements for the specific sam or ew type:
		if (hasLauncher and hasSearchRadar and hasTrackingRadar and #self.launchers > 0 and #self.searchRadars > 0  and #self.trackingRadars > 0 ) 
			or ( hasSearchRadar and hasLauncher and #self.searchRadars > 0 and #self.launchers > 0) 
				or (hasSearchRadar and hasLauncher == false and hasTrackingRadar == false and #self.searchRadars > 0) then
			local harmDetection = dataType['harm_detection_chance']
			if harmDetection then
				self.harmDetectionChance = harmDetection
			end
			local natoName = dataType['name']['NATO']
			--we shorten the SA-XX names and don't return their code names eg goa, gainful..
			local pos = natoName:find(" ")
			local prefix = natoName:sub(1, 2)
			if string.lower(prefix) == 'sa' and pos ~= nil then
				self.natoName = natoName:sub(1, (pos-1))
			else
				self.natoName = natoName
			end
			break
		end	
	end
end

function SkynetIADSAbstractRadarElement:analyseAndAddUnit(class, tableToAdd, unitData)
	local units = self:getUnitsToAnalyse()
	for i = 1, #units do
		local unit = units[i]
		local unitTypeName = unit:getTypeName()
		for unitName, unitPerformanceData in pairs(unitData) do
			if unitName == unitTypeName then
				samElement = class:create(unit, unitPerformanceData)
				table.insert(tableToAdd, samElement)
			end
		end
	end
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

function SkynetIADSAbstractRadarElement:setGoLiveRangeInPercent(percent)
	if percent ~= nil then
		self.firingRangePercent = percent	
		for i = 1, #self.launchers do
			local launcher = self.launchers[i]
			launcher:setFiringRangePercent(self.firingRangePercent)
		end
		for i = 1, #self.searchRadars do
			local radar = self.searchRadars[i]
			radar:setFiringRangePercent(self.firingRangePercent)
		end
	end
	return self
end

function SkynetIADSAbstractRadarElement:getGoLiveRangeInPercent()
	return self.firingRangePercent
end

function SkynetIADSAbstractRadarElement:setEngagementZone(engagementZone)
	if engagementZone == SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE then
		self.goLiveRange = engagementZone
	elseif engagementZone == SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE then
		self.goLiveRange = engagementZone
	end
	return self
end

function SkynetIADSAbstractRadarElement:getEngagementZone()
	return self.goLiveRange
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
	if ( self.aiState == true ) and ( ( #self:getDetectedTargets() == 0 or self.harmSilenceID ~= nil) or ( self.isAutonomous == true and self.autonomousBehaviour == SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK ) ) then
		if self:isDestroyed() == false then
			local controller = self:getController()
			-- fastest way to get a radar unit to stop emitting
			controller:setOnOff(false)
			--controller:setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.GREEN)
			--controller:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_HOLD)
		end
		self.aiState = false
		mist.removeFunction(self.jammerID)
		self:stopScanningForHARMs()
		if self.iads:getDebugSettings().samWentDark then
			self.iads:printOutput(self:getDescription().." going dark")
		end
	end
end

function SkynetIADSAbstractRadarElement:isActive()
	return self.aiState
end

function SkynetIADSAbstractRadarElement:isTargetInRange(target)

	local isSearchRadarInRange = false
	local isTrackingRadarInRange = false
	local isLauncherInRange = false
	
	local isSearchRadarInRange = ( #self.searchRadars == 0 )
	for i = 1, #self.searchRadars do
		local searchRadar = self.searchRadars[i]
		if searchRadar:isInRange(target) then
			isSearchRadarInRange = true
		end
	end
	
	if self.goLiveRange == SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE then
		
		isLauncherInRange = ( #self.launchers == 0 )
		for i = 1, #self.launchers do
			local launcher = self.launchers[i]
			if launcher:isInRange(target) or launcher:isAAA() then
				isLauncherInRange = true
			end
		end
		
		isTrackingRadarInRange = ( #self.trackingRadars == 0 )
		for i = 1, #self.trackingRadars do
			local trackingRadar = self.trackingRadars[i]
			if trackingRadar:isInRange(target) then
				isTrackingRadarInRange = true
			end
		end
	else
		isLauncherInRange = true
		isTrackingRadarInRange = true
	end
	return  (isSearchRadarInRange and isTrackingRadarInRange and isLauncherInRange )
end

function SkynetIADSAbstractRadarElement:setAutonomousBehaviour(mode)
	if mode ~= nil then
		self.autonomousBehaviour = mode
	end
	return self
end

function SkynetIADSAbstractRadarElement:getAutonomousBehaviour()
	return self.autonomousBehaviour
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
	self:stopScanningForHARMs()
	self.harmScanID = mist.scheduleFunction(SkynetIADSAbstractRadarElement.evaluateIfTargetsContainHARMs, {self}, 1, 2)
end

function SkynetIADSAbstractElement:isScanningForHARMs()
	return self.harmScanID ~= nil
end

function SkynetIADSAbstractRadarElement:stopScanningForHARMs()
	mist.removeFunction(self.harmScanID)
	self.harmScanID = nil
end

function SkynetIADSAbstractRadarElement:goSilentToEvadeHARM(timeToImpact)
	self:finishHarmDefence(self)
	self.objectsIdentifiedAsHarms = {}
	local harmTime = self:getHarmShutDownTime()
	if self.iads:getDebugSettings().harmDefence then
		self.iads:printOutput("HARM DEFENCE: "..self:getDCSRepresentation():getName().." shutting down | FOR: "..harmTime.." seconds | TTI: "..timeToImpact)
	end
	self.harmSilenceID = mist.scheduleFunction(SkynetIADSAbstractRadarElement.finishHarmDefence, {self}, timer.getTime() + harmTime, 1)
	self:goDark()
end

function SkynetIADSAbstractRadarElement:getHarmShutDownTime()
	local shutDownTime = math.random(self.minHarmShutdownTime, self.maxHarmShutDownTime)
	return shutDownTime
end

function SkynetIADSAbstractRadarElement.finishHarmDefence(self)
	mist.removeFunction(self.harmSilenceID)
	self.harmSilenceID = nil
end

function SkynetIADSAbstractRadarElement:getDetectedTargets()
	local returnTargets = {}
	if self:hasWorkingPowerSource() and self:isDestroyed() == false then
		local targets = self:getController():getDetectedTargets(Controller.Detection.RADAR)
		for i = 1, #targets do
			local target = targets[i]
			-- there are cases when a destroyed object is still visible as a target to the radar, don't add it, will cause errors everywhere the dcs object is accessed
			if target.object then
				local iadsTarget = SkynetIADSContact:create(target)
				iadsTarget:refresh()
				if self:isTargetInRange(iadsTarget) then
					table.insert(returnTargets, iadsTarget)
				end
			end
		end
	end
	return returnTargets
end

function SkynetIADSAbstractRadarElement:getSecondsToImpact(distanceNM, speedKT)
	local tti = 0
	if speedKT > 0 then
		tti = mist.utils.round((distanceNM / speedKT) * 3600, 0)
		if tti < 0 then
			tti = 0
		end
	end
	return tti
end

function SkynetIADSAbstractRadarElement:getDistanceInMetersToContact(radarUnit, point)
	return mist.utils.round(mist.utils.get3DDist(radarUnit:getPosition().p, point), 0)
end

function SkynetIADSAbstractRadarElement:calculateMinimalShutdownTimeInSeconds(timeToImpact)
	return timeToImpact + self.minHarmPresetShutdownTime
end

function SkynetIADSAbstractRadarElement:calculateMaximalShutdownTimeInSeconds(minShutdownTime)	
	return minShutdownTime + mist.random(1, self.maxHarmPresetShutdownTime)
end

function SkynetIADSAbstractRadarElement:calculateImpactPoint(target, distanceInMeters)
	-- distance needs to be incremented by a certain value for ip calculation to work, check why presumably due to rounding errors in the previous distance calculation
	return land.getIP(target:getPosition().p, target:getPosition().x, distanceInMeters + 50)
end

function SkynetIADSAbstractRadarElement:shallReactToHARM()
	return self.harmDetectionChance >=  math.random(1, 100)
end

function SkynetIADSAbstractRadarElement.evaluateIfTargetsContainHARMs(self)
	local targets = self:getDetectedTargets() 
	for i = 1, #targets do
		local target = targets[i]
		local radars = self:getRadars()
		for j = 1, #radars do
			local radar = radars[j]
			local distance = self:getDistanceInMetersToContact(radar, target:getPosition().p)
			local impactPoint = self:calculateImpactPoint(target, distance)
			if impactPoint then
				local harmImpactPointDistanceToSAM = self:getDistanceInMetersToContact(radar, impactPoint)
				if harmImpactPointDistanceToSAM <= 100 then
					if self.objectsIdentifiedAsHarms[target:getName()] then
						self.objectsIdentifiedAsHarms[target:getName()]['count'] = self.objectsIdentifiedAsHarms[target:getName()]['count'] + 1
					else
						self.objectsIdentifiedAsHarms[target:getName()] =  {}
						self.objectsIdentifiedAsHarms[target:getName()]['target'] = target
						self.objectsIdentifiedAsHarms[target:getName()]['count'] = 1
					end
					local savedTarget = self.objectsIdentifiedAsHarms[target:getName()]['target']
					savedTarget:refresh()
					local numDetections = self.objectsIdentifiedAsHarms[target:getName()]['count']
					local speed = savedTarget:getGroundSpeedInKnots()
					local timeToImpact = self:getSecondsToImpact(mist.utils.metersToNM(distance), speed)
					local shallReactToHarm = self:shallReactToHARM()
					-- we use 2 detection cycles so a random object in the air pointing on the SAM site for a spilt second will not trigger a shutdown. The harm reaction time adds some salt otherwise the SAM will always shut down 100% of the time.
					if numDetections == 2 and shallReactToHarm then
						self.minHarmShutdownTime = self:calculateMinimalShutdownTimeInSeconds(timeToImpact)
						self.maxHarmShutDownTime = self:calculateMaximalShutdownTimeInSeconds(self.minHarmShutdownTime)
						self:goSilentToEvadeHARM(timeToImpact)
					end
					if numDetections == 2 and shallReactToHarm == false then
						if self.iads:getDebugSettings().harmDefence then
							self.iads:printOutput("HARM DEFENCE: "..self:getDCSRepresentation():getName().." will not react")
						end
					end
				end
			end
		end
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
	instance.numOfTimesRefreshed = 0
	instance.speed = 0
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

function SkynetIADSContact:getNumberOfTimesHitByRadar()
	return self.numOfTimesRefreshed
end

function SkynetIADSContact:refresh()
	self.numOfTimesRefreshed = self.numOfTimesRefreshed + 1
	if self.dcsObject and self.dcsObject:isExist() then
		local distance = mist.utils.metersToNM(mist.utils.get2DDist(self.position.p, self.dcsObject:getPosition().p))
		local timeDelta = (timer.getAbsTime() - self.lastTimeSeen)
		if timeDelta > 0 then
			local hours = timeDelta / 3600
			self.speed = (distance / hours)
		end 
		self.position = self.dcsObject:getPosition()
	end
	self.lastTimeSeen = timer.getAbsTime()
end

function SkynetIADSContact:getAge()
	return mist.utils.round(timer.getAbsTime() - self.lastTimeSeen)
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
	instance.firingRangePercent = 100
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

function SkynetIADSSAMSearchRadar:setFiringRangePercent(percent)
	self.firingRangePercent = percent
end

function SkynetIADSSAMSearchRadar:isInRange(target)
	if self:isExist() == false then
		return false
	end
	local distance = mist.utils.get2DDist(target:getPosition().p, self.dcsObject:getPosition().p)
	local radarHeight = self.dcsObject:getPosition().p.y
	local aircraftHeight = target:getPosition().p.y	
	local altitudeDifference = math.abs(aircraftHeight - radarHeight)
	local maxDetectionAltitude = self:getMaxAltFindingTarget()
	--local maxDetectionRange = self:getMaxRangeFindingTarget()
	
	local maxDetectionRange = (self:getMaxRangeFindingTarget() / 100 * self.firingRangePercent)
	
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
	return self
end

function SkynetIADSSamSite:getActAsEW()
	return self.actAsEW
end	

function SkynetIADSSamSite:isDestroyed()
	local isDestroyed = true
	for i = 1, #self.launchers do
		local launcher = self.launchers[i]
		if launcher:isExist() == true then
			isDestroyed = false
		end
	end
	local radars = self:getRadars()
	for i = 1, #radars do
		local radar = radars[i]
		if radar:isExist() == true then
			isDestroyed = false
		end
	end	
	return isDestroyed
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
	if self:isTargetInRange(contact) then
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
sa6['harm_detection_chance'] = 40

local sa10 = samTypesDB['S%-300']
sa10['harm_detection_chance'] = 90

local sa11 = samTypesDB['Buk']
sa11['harm_detection_chance'] = 70

local sa19 = samTypesDB['2S6 Tunguska']
sa19['harm_detection_chance'] = 10

end
do

SkynetIADSSAMLauncher = {}
SkynetIADSSAMLauncher = inheritsFrom(SkynetIADSSAMSearchRadar)

function SkynetIADSSAMLauncher:create(unit, performanceData)
	local instance = self:superClass():create(unit)
	setmetatable(instance, self)
	self.__index = self
	instance.performanceData = performanceData
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

function SkynetIADSSAMLauncher:isInRange(target)
	if self:isExist() == false then
		return false
	end
	local distance = mist.utils.get2DDist(target:getPosition().p, self.dcsObject:getPosition().p)
	local maxFiringRange = (self:getRange() / 100 * self.firingRangePercent)
	return distance <= maxFiringRange
end

end
