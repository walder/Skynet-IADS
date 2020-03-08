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
