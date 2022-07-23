do
--this file contains the required units per sam type
samTypesDB = {
	['S-200'] = {
        ['type'] = 'complex',
        ['searchRadar'] = {
            ['RLS_19J6'] = {
                ['name'] = {
                    ['NATO'] = 'Tin Shield',
                },
			}, 
			['p-19 s-125 sr'] = {
				['name'] = {
					['NATO'] = 'Flat Face',
				},
			},	
		},
        ['EWR P-37 BAR LOCK'] = {
            ['Name'] = {
              ['NATO'] = "Bar lock",
            },   
        },
        ['trackingRadar'] = {
            ['RPC_5N62V'] = {
            },
        },
        ['launchers'] = {
            ['S-200_Launcher'] = {
            },
        },
        ['name'] = {
            ['NATO'] = 'SA-5 Gammon',
        },
        ['harm_detection_chance'] = 60
    },
	['S-300'] = {
		['type'] = 'complex',
		['searchRadar'] = {
			['S-300PS 40B6MD sr'] = {
				['name'] = {
					['NATO'] = 'Clam Shell',
				},
			},
			['S-300PS 64H6E sr'] = {
				['name'] = {
					['NATO'] = 'Big Bird',
				},
			},
		},
		['trackingRadar'] = {
			['S-300PS 40B6M tr'] = {
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
		['harm_detection_chance'] = 90,
		['can_engage_harm'] = true
	},
	['Buk'] = {
		['type'] = 'complex',
		['searchRadar'] = {
			['SA-11 Buk SR 9S18M1'] = {
				['name'] = {
					['NATO'] = 'Snow Drift',
				},
			},
		},
		['launchers'] = {
			['SA-11 Buk LN 9A310M1'] = {
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
		['harm_detection_chance'] = 70
	},
	['S-125'] = {
		['type'] = 'complex',
		['searchRadar'] = {
			['p-19 s-125 sr'] = {
				['name'] = {
					['NATO'] = 'Flat Face',
				},
			},	
		},
		['trackingRadar'] = {
			['snr s-125 tr'] = {
			},
		},
		['launchers'] = {
			['5p73 s-125 ln'] = {
			},
		},
		['name'] = {
			['NATO'] = 'SA-3 Goa',
		},
		['harm_detection_chance'] = 30
	},
    ['S-75'] = {
		['type'] = 'complex',
		['searchRadar'] = {
			['p-19 s-125 sr'] = {
				['name'] = {
					['NATO'] = 'Flat Face',
				},
			},
		},
		['trackingRadar'] = {
			['SNR_75V'] = {
			},
		},
		['launchers'] = {
			['S_75M_Volhov'] = {
			},
		},
		['name'] = {
			['NATO'] = 'SA-2 Guideline',
		},
		['harm_detection_chance'] = 30
	},
	['Kub'] = {
		['type'] = 'complex',
		['searchRadar'] = {
			['Kub 1S91 str'] = {
				['name'] = {
					['NATO'] = 'Straight Flush',
				},
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
				['name'] = {
					['NATO'] = 'Patriot str',
				},
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
		['harm_detection_chance'] = 90,
		['can_engage_harm'] = true
	},
	['Hawk'] = {
		['type'] = 'complex',
		['searchRadar'] = {
			['Hawk sr'] = {
				['name'] = {
					['NATO'] = 'Hawk str',
				},
			},
		},
		['trackingRadar'] = {
			['Hawk tr'] = {
			},
		},
		['launchers'] = {
			['Hawk ln'] = {
			},
		},

		['name'] = {
			['NATO'] = 'Hawk',
		},
		['harm_detection_chance'] = 40

	},	
	['Roland ADS'] = {
		['type'] = 'single',
		['searchRadar'] = {
			['Roland ADS'] = {
			},
		},
		['launchers'] = {
			['Roland ADS'] = {
			},
		},

		['name'] = {
			['NATO'] = 'Roland ADS',
		},
		['harm_detection_chance'] = 60
	},	
	['NASAMS'] = {
		['type'] = 'complex',
		['searchRadar'] = {
			['NASAMS_Radar_MPQ64F1'] = {
			},
		},
		['launchers'] = {
			['NASAMS_LN_B'] = {		
			},
			['NASAMS_LN_C'] = {		
			},
		},
		
		['name'] = {
			['NATO'] = 'NASAMS',
		},
		['misc'] = {
			['NASAMS_Command_Post'] = {
				['required'] = false,
			},
		},
		['can_engage_harm'] = true,
		['harm_detection_chance'] = 90
	},	
	['2S6 Tunguska'] = {
		['type'] = 'single',
		['searchRadar'] = {
			['2S6 Tunguska'] = {
			},
		},
		['launchers'] = {
			['2S6 Tunguska'] = {
			},
		},
		['name'] = {
			['NATO'] = 'SA-19 Grison',
		},
	},		
	['Osa'] = {
		['type'] = 'single',
		['searchRadar'] = {
			['Osa 9A33 ln'] = {
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
	['Strela-10M3'] = {
		['type'] = 'single',
		['searchRadar'] = {
			['Strela-10M3'] = {
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
	['Strela-1 9P31'] = {
		['type'] = 'single',
		['searchRadar'] = {
			['Strela-1 9P31'] = {
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
		['searchRadar'] = {
			['Tor 9A331'] = {
			},
		},
		['launchers'] = {
			['Tor 9A331'] = {
			},
		},
		['name'] = {
			['NATO'] = 'SA-15 Gauntlet',
		},
		['harm_detection_chance'] = 90,
		['can_engage_harm'] = true
		
	},
	['Gepard'] = {
		['type'] = 'single',
		['searchRadar'] = {
			['Gepard'] = {
			},
		},
		['launchers'] = {
			['Gepard'] = {
			},
		},
		['name'] = {
			['NATO'] = 'Gepard',
		},
		['harm_detection_chance'] = 10
	},		
    ['Rapier'] = {
        ['searchRadar'] = {
            ['rapier_fsa_blindfire_radar'] = {
            },
        },
        ['launchers'] = {
        	['rapier_fsa_launcher'] = {
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
		['harm_detection_chance'] = 10
    },	
	['ZSU-23-4 Shilka'] = {
		['type'] = 'single',
		['searchRadar'] = {
			['ZSU-23-4 Shilka'] = {
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
	['HQ-7'] = {
		['searchRadar'] = {
			['HQ-7_STR_SP'] = {
				['name'] = {
					['NATO'] = 'CSA-4',
				},
			},
		},
		['launchers'] = {
			['HQ-7_LN_SP'] = {
			},
		},
		['name'] = {
			['NATO'] = 'CSA-4',
		},
		['harm_detection_chance'] = 30
	},
--- Start of EW radars:
	['1L13 EWR'] = {
		['type'] = 'ewr',
		['searchRadar'] = {
			['1L13 EWR'] = {
				['name'] = {
					['NATO'] = 'Box Spring',
				},
			},
		},
		['harm_detection_chance'] = 60
	},
	['55G6 EWR'] = {
		['type'] = 'ewr',
		['searchRadar'] = {
			['55G6 EWR'] = {
				['name'] = {
					['NATO'] = 'Tall Rack',
				},
			},
		},
		['harm_detection_chance'] = 60
	},
	['Dog Ear'] = {
		['type'] = 'ewr',
		['searchRadar'] = {
			['Dog Ear radar'] = {
				['name'] = {
					['NATO'] = 'Dog Ear',
				},
			},
		},
		['harm_detection_chance'] = 20
	},
	['Roland Radar'] = {
		['type'] = 'ewr',
		['searchRadar'] = {
			['Roland Radar'] = {
				['name'] = {
					['NATO'] = 'Roland EWR',
				},
			},
		},

		['harm_detection_chance'] = 60
	},	
}
end
