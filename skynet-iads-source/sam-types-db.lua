do
samTypesDB = { -- this is a static DB based off of scripts/database files for each sam type.
	-- '-' character needs special search term %
	['S%-300'] = {
		['type'] = 'complex',
		['searchRadar'] = {
			['S-300PS 40B6MD sr'] = {
				['height'] = 42.158,
			},
			['S-300PS 64H6E sr'] = {
				['height'] = 8.68,
			},
		},
		['trackingRadar'] = {
			['S-300PS 40B6M tr'] = {
				['height'] = 27.63,
			},
		},
		['launchers'] = {
			['S-300PS 5P85D ln'] = {
			},
			['S-300PS 5P85C ln'] = {
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
		['harm_detection_chance'] = 90
	},
	['Buk'] = {
		['type'] = 'complex',
		['searchRadar'] = {
			['SA-11 Buk SR 9S18M1'] = {
				['height'] = 7.534,
			},
		},
		['launchers'] = {
			['SA-11 Buk LN 9A310M1'] = {
				['height'] = 6.931,
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
		['harm_detection_chance'] = 70
	},
	['s%-125'] = {
		['type'] = 'complex',
		['searchRadar'] = {
			['p-19 s-125 sr'] = {
				['height'] = 5.841,
			},
		},
		['trackingRadar'] = {
			['snr s-125 tr'] = {
				['height'] = 3,
			},
		},
		['launchers'] = {
			['5p73 s-125 ln'] = {
			},
		},
		['name'] = {
			['NATO'] = 'SA-3 Goa',
		},
		['harm_detection_chance'] = 40
	},
    ['s%-75'] = {
		['type'] = 'complex',
		['searchRadar'] = {
			['p-19 s-125 sr'] = {
				['height'] = 5.841,
			},
		},
		['trackingRadar'] = {
			['SNR_75V'] = {
				['height'] = 5.5,
			},
		},
		['launchers'] = {
			['S_75M_Volhov'] = {
				['rearmTime'] = 2700,
			},
		},
		['name'] = {
			['NATO'] = 'SA-2 Guideline',
		},
		['harm_detection_chance'] = 30
	},
	['Kub'] = {
		['type'] = 'complex',
		['mobile'] = true,
		['searchRadar'] = {
			['Kub 1S91 str'] = {
				['height'] = 5.872,
			},
		},
		['launchers'] = {
			['Kub 2P25 ln'] = {
			},
		},
		['name'] = {
			['NATO'] = 'SA-6 Gainful',
		},
		['harm_detection_chance'] = 40
	},
	['Patriot'] = {
		['type'] = 'complex',
		['searchRadar'] = {
			['Patriot str'] = {
				['height'] = 5.895,
			},
		},

		['launchers'] = {
			['Patriot ln'] = {
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
				['height'] = 5.841,
			},
		},
		['trackingRadar'] = {
			['Hawk tr'] = {
				['height'] = 3,
			},
		},
		['launchers'] = {
			['Hawk ln'] = {
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
				['height'] = 3.922,
			},
		},
		['launchers'] = {
			['Roland ADS'] = {
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
				['height'] = 3.675,
			},
		},
		['launchers'] = {
			['2S6 Tunguska'] = {
			},
		},
		['name'] = {
			['NATO'] = 'SA-19 Grison',
		},
		['harm_detection_chance'] = 10
	},		
	['Osa'] = {
		['type'] = 'single',
		['mobile'] = true,
		['searchRadar'] = {
			['Osa 9A33 ln'] = {
				['height'] = 5.438,
			},
		},
		['launchers'] = {
			['Osa 9A33 ln'] = {
			
			},
		},
		['name'] = {
			['NATO'] = 'SA-8 Gecko',
		},
		['harm_detection_chance'] = 20
	},	
	['Strela%-10M3'] = {
		['type'] = 'single',
		['mobile'] = true,
		['searchRadar'] = {
			['Strela-10M3'] = {
				['height'] = 3.548,
				['trackingRadar'] = true,
			},
		},
		['launchers'] = {
			['Strela-10M3'] = {
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
				['height'] = 3.277,
			},
		},
		['launchers'] = {
			['Strela-1 9P31'] = {
			},
		},
		['name'] = {
			['NATO'] = 'SA-9 Gaskin',
		},
		['harm_detection_chance'] = 20
	},
	['Tor'] = {
		['type'] = 'single',
		['mobile'] = true,
		['searchRadar'] = {
			['Tor 9A331'] = {
				['height'] = 5.118,	
			},
		},
		['launchers'] = {
			['Tor 9A331'] = {
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
				['height'] = 3.854,
			},
		},
		['launchers'] = {
			['Gepard'] = {
			},
		},
		['name'] = {
			['NATO'] = 'Gepard',
		},
	},		
	['M6 Linebacker'] = {
		['type'] = 'single',
		['mobile'] = true,
		['searchRadar'] = {
			['M6 Linebacker'] = {
				['height'] = 2.58,			
			},
		},
		['launchers'] = {
			['M6 Linebacker'] = {
			},
		},
		['name'] = {
			['NATO'] = 'M6 Linebacker',
		},
	},
    ['Rapier'] = {
        ['searchRadar'] = {
            ['rapier_fsa_blindfire_radar'] = {
            },
        },
        ['launchers'] = {
        	['rapier_fsa_launcher'] = {
				['height'] = 2.5,
				['trackingRadar'] = true,
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
				['height'] = 2.52,	
			},
		},
		['launchers'] = {
			['M48 Chaparral'] = {	
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
				['height'] = 3.872,
			},
		},
		['launchers'] = {
			['Vulcan'] = {
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
				['height'] = 3.076,	
			},
		},
		['launchers'] = {
			['M1097 Avenger'] = {
				['ir'] = true,
				['guns'] = true,
			},
		},
		['name'] = {
			['NATO'] = 'M1097 Avenger',
		},
	},
	['ZSU%-23%-4 Shilka'] = {
		['type'] = 'single',
		['mobile'] = true,
		['searchRadar'] = {
			['ZSU-23-4 Shilka'] = {
				['height'] = 3.458,	
			},
		},
		['launchers'] = {
			['ZSU-23-4 Shilka'] = {
			},
		},
		['name'] = {
			['NATO'] = 'Zues',
		},
		['harm_detection_chance'] = 10
	},
	['1L13 EWR'] = {
		['type'] = 'ewr',
		['searchRadar'] = {
			['1L13 EWR'] = {
				['height'] = 39,
			},
		},
		['name'] = {
			['NATO'] = '1L13 EWR',
		},
		['harm_detection_chance'] = 60
	},
	['55G6 EWR'] = {
		['type'] = 'ewr',
		['searchRadar'] = {
			['55G6 EWR'] = {
				['height'] = 39,
			},
		},
		['name'] = {
			['NATO'] = '55G6 EWR',
		},
		['harm_detection_chance'] = 60
	},
	['Dog Ear'] = {
		['type'] = 'ewr',
		['mobile'] = true,
		['searchRadar'] = {
			['Dog Ear radar'] = {
				['height'] = 3.8,
			},
		},
		['name'] = {
			['NATO'] = 'Dog Ear',
		},
		['harm_detection_chance'] = 2
	},
	['Roland Radar'] = {
		['type'] = 'ewr',
		['mobile'] = true,
		['searchRadar'] = {
			['Roland Radar'] = {
				['height'] = 6.87,
			},
		},
		['name'] = {
			['NATO'] = 'Roland EWR',
		},
	},
	['A-50'] = {
		['searchRadar'] = {
			['A-50'] = {
			
			},
		},
		['name'] = {
			['NATO'] = 'Mainstay',
		},
	}
}
end
