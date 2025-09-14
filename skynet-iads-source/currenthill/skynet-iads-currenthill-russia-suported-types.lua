do
-- this file contains the definitions for the CurrentHill Russian Military Asset Pack: https://www.currenthill.com/russia

samTypesDB['2S38'] = {
	['type'] = 'single',
	['searchRadar'] = {
		['CH_2S38'] = {
		},
	},
	['launchers'] = {
		['CH_2S38'] = {
		},
	},
	['name'] = {
		['NATO'] = '2S38',
	},
	['harm_detection_chance'] = 5,
	['can_engage_harm'] = true
	
}

samTypesDB['2S38_LG'] = {
	['type'] = 'single',
	['searchRadar'] = {
		['CH_2S38_LG'] = {
		},
	},
	['launchers'] = {
		['CH_2S38_LG'] = {
		},
	},
	['name'] = {
		['NATO'] = '2S38',
	},
	['harm_detection_chance'] = 5,
	['can_engage_harm'] = true
	
}

samTypesDB['Pantsir-S1'] = {
	['type'] = 'single',
	['searchRadar'] = {
		['PantsirS1'] = {
		},
	},
	['launchers'] = {
		['PantsirS1'] = {
		},
	},
	['name'] = {
		['NATO'] = 'SA-22 Greyhound',
	},
	['harm_detection_chance'] = 75,
	['can_engage_harm'] = true
	
}

samTypesDB['Pantsir-S2'] = {
	['type'] = 'single',
	['searchRadar'] = {
		['PantsirS2'] = {
		},
	},
	['launchers'] = {
		['PantsirS2'] = {
		},
	},
	['name'] = {
		['NATO'] = 'SA-22 Greyhound',
	},
	['harm_detection_chance'] = 75,
	['can_engage_harm'] = true
	
}

samTypesDB['Tor-M2'] = {
	['type'] = 'single',
	['searchRadar'] = {
		['TorM2'] = {
		},
	},
	['launchers'] = {
		['TorM2'] = {
		},
	},
	['name'] = {
		['NATO'] = 'SA-15C "Gauntlet',
	},
	['harm_detection_chance'] = 80,
	['can_engage_harm'] = true
	
}

samTypesDB['Tor-M2K'] = {
	['type'] = 'single',
	['searchRadar'] = {
		['TorM2K'] = {
		},
	},
	['launchers'] = {
		['TorM2K'] = {
		},
	},
	['name'] = {
		['NATO'] = 'SA-15D "Gauntlet',
	},
	['harm_detection_chance'] = 80,
	['can_engage_harm'] = true
	
}

samTypesDB['Tor-M2M'] = {
	['type'] = 'single',
	['searchRadar'] = {
		['TorM2M'] = {
		},
	},
	['launchers'] = {
		['TorM2M'] = {
		},
	},
	['name'] = {
		['NATO'] = 'SA-15E "Gauntlet',
	},
	['harm_detection_chance'] = 85,
	['can_engage_harm'] = true
	
}

samTypesDB['S-350'] = {
	['type'] = 'complex',
	['searchRadar'] = {
		['CH_S350_96L6'] = {
			['name'] = {
				['NATO'] = '',
			},
		},
		['CH_S350_50N6'] = {
			['name'] = {
				['NATO'] = '',
			},
		},
	},
	['misc'] = {
		['CH_S350_50K6'] = {
			['required'] = true,
		},
	},
	['launchers'] = {
		['CH_S350_50P6_9M96D'] = {
		},
		['CH_S350_50P6_9M100'] = {
		},
	},
	['name']  = {
		['NATO'] = 'SA-27 Sizzler'
	},
	['harm_detection_chance'] = 95,
	['can_engage_harm'] = true
}	

samTypesDB['Buk-M3'] = {
	['type'] = 'complex',
	['searchRadar'] = {
		['CH_BukM3_9S18M13'] = {
			['name'] = {
				['NATO'] = 'Snow Drift',
			},
		},
	},
	['trackingRadar'] = {
		['CH_BukM3_9S36M'] = {
		},
	},
	['misc'] = {
		['CH_BukM3_9S510M'] = {
			['required'] = true,
		},
	},
	['launchers'] = {
		['CH_BukM3_9A317M'] = {
		},
		['CH_BukM3_9A317MA'] = {
		},
	},
	['name']  = {
		['NATO'] = 'SA-27 Gollum'
	},
	['harm_detection_chance'] = 92,
	['can_engage_harm'] = true
}	

--[[

--]]

end



