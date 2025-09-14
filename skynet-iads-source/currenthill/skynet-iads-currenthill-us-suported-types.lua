do
-- this file contains the definitions for the CurrentHill Russian Military Asset Pack: https://www.currenthill.com/russia

samTypesDB['Centurion_C_RAM'] = {
	['type'] = 'single',
	['searchRadar'] = {
		['CH_Centurion_C_RAM'] = {
		},
	},
	['launchers'] = {
		['CH_Centurion_C_RAM'] = {
		},
	},
	['name'] = {
		['NATO'] = 'Centurion',
	},
	['harm_detection_chance'] = 38,
	['can_engage_harm'] = true
	
}

samTypesDB['LAV_AD'] = {
	['type'] = 'single',
	['launchers'] = {
		['CH_LAVAD'] = {
		},
	},
	['name'] = {
		['NATO'] = 'LAV-AD',
	},
	['harm_detection_chance'] = 5,
	['can_engage_harm'] = true
	
}

samTypesDB['MIM-104_US'] = {
	['type'] = 'complex',
	['searchRadar'] = {
		['MIM104_ANMPQ65'] = {
			['name'] = {
				['NATO'] = 'Fire Finder',
			},
		},
		['MIM104_ANMPQ65_HEMTT'] = {
			['name'] = {
				['NATO'] = 'Fire Finder',
			},
		},
		['MIM104_ANMPQ65A'] = {
			['name'] = {
				['NATO'] = 'Fire Finder',
			},
		},
		['MIM104_ANMPQ65A_HEMTT'] = {
			['name'] = {
				['NATO'] = 'Fire Finder',
			},
		},
		['MIM104_LTAMDS'] = {
			['name'] = {
				['NATO'] = 'Fire Finder',
			},
		},
		['MIM104_LTAMDS_HEMTT'] = {
			['name'] = {
				['NATO'] = 'Fire Finder',
			},
		},
	},
	['misc'] = {
		['MIM104_ECS'] = {
			['required'] = true,
		},
		['MIM104_EPP'] = {
			['required'] = true,
		},
	},
	['launchers'] = {
		['MIM104_M903_PAC2'] = {
		},
		['MIM104_M903_PAC2_HEMTT'] = {
		},
		['MIM104_M903_PAC3'] = {
		},
		['MIM104_M903_PAC3_HEMTT'] = {
		},
		
	},
	['name']  = {
		['NATO'] = 'SAM-10 Guardian'
	},
	['harm_detection_chance'] = 95,
	['can_engage_harm'] = true
}	

samTypesDB['NASAMS_CH'] = {
	['type'] = 'complex',
	['searchRadar'] = {
		['CH_NASAMS3_SR'] = {
		},
	},
	['misc'] = {
		['CH_NASAMS3_CP'] = {
			['required'] = false,
		},
	},
	['launchers'] = {
		['CH_NASAMS3_LN_AMRAAM_ER'] = {
		},
		['CH_NASAMS3_LN_AIM9X2'] = {
		},
	},
	['name']  = {
		['NATO'] = 'NASAMS'
	},
	['harm_detection_chance'] = 86,
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



