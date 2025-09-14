do
-- this file contains the definitions for the CurrentHill Russian Military Asset Pack: https://www.currenthill.com/russia

samTypesDB['PGL-625'] = {
	['type'] = 'single',
	['searchRadar'] = {
		['PGL_625'] = {
		},
	},
	['launchers'] = {
		['PGL_625'] = {
		},
	},
	['name'] = {
		['NATO'] = 'PGL=625 SPAAGM',
	},
	['harm_detection_chance'] = 24,
	['can_engage_harm'] = true
	
}

samTypesDB['HQ-17A'] = {
	['type'] = 'single',
	['searchRadar'] = {
		['HQ17A'] = {
		},
	},
	['launchers'] = {
		['HQ17A'] = {
		},
	},
	['name'] = {
		['NATO'] = 'SA-22 Greyhound',
	},
	['harm_detection_chance'] = 56,
	['can_engage_harm'] = true
	
}

samTypesDB['PGZ-09'] = {
	['type'] = 'single',
	['searchRadar'] = {
		['CH_PGZ09'] = {
		},
	},
	['launchers'] = {
		['CH_PGZ09'] = {
		},
	},
	['name'] = {
		['NATO'] = 'PGZ-09',
	},
	['harm_detection_chance'] = 14,
	['can_engage_harm'] = true
	
}


samTypesDB['PGZ-95'] = {
	['type'] = 'single',
	['searchRadar'] = {
		['CH_PGZ95'] = {
		},
	},
	['launchers'] = {
		['CH_PGZ95'] = {
		},
	},
	['name'] = {
		['NATO'] = 'PGZ-95',
	},
	['harm_detection_chance'] = 16,
	['can_engage_harm'] = true
	
}

samTypesDB['LD-3000'] = {
	['type'] = 'single',
	['searchRadar'] = {
		['CH_LD3000'] = {
		},
	},
	['launchers'] = {
		['CH_LD3000'] = {
		},
	},
	['name'] = {
		['NATO'] = 'LD-3000',
	},
	['harm_detection_chance'] = 22,
	['can_engage_harm'] = true
	
}

samTypesDB['LD-3000_stationery'] = {
	['type'] = 'single',
	['searchRadar'] = {
		['CH_LD3000_stationary'] = {
		},
	},
	['launchers'] = {
		['CH_LD3000_stationary'] = {
		},
	},
	['name'] = {
		['NATO'] = 'LD-3000',
	},
	['harm_detection_chance'] = 22,
	['can_engage_harm'] = true
	
}

samTypesDB['HQ-22'] = {
	['type'] = 'complex',
	['searchRadar'] = {
		['CH_HQ22_STR'] = {
		},
		['CH_HQ22_SR'] = {
		},
	},
	['launchers'] = {
		['CH_HQ22_LN'] = {
		},
	},
	['name']  = {
		['NATO'] = 'HQ-22 (FK-3)'
	},
	['harm_detection_chance'] = 92,
	['can_engage_harm'] = true
}	

samTypesDB['THAAD'] = {
	['type'] = 'complex',
	['searchRadar'] = {
		['CH_THAAD_ANTPY2'] = {
		},
	},
	['misc'] = {
		['CH_THAAD_TFCC'] = {
			['required'] = true,
		},
	},
	['launchers'] = {
		['CH_THAAD_M1120'] = {
		},
	},
	['name']  = {
		['NATO'] = 'THAAD'
	},
	['harm_detection_chance'] = 98,
	['can_engage_harm'] = true
}	

--[[

--]]

end



