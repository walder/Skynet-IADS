do
-- this file contains the definitions for the CurrentHill Russian Military Asset Pack: https://www.currenthill.com/russia

samTypesDB['FlaRakRad'] = {
	['type'] = 'single',
	['searchRadar'] = {
		['CH_FlaRakRad'] = {
		},
	},
	['launchers'] = {
		['CH_FlaRakRad'] = {
		},
	},
	['name'] = {
		['NATO'] = 'FlaRakRad',
	},
	['harm_detection_chance'] = 32,
	['can_engage_harm'] = true
	
}

samTypesDB['Skynex SPAAG'] = {
	['type'] = 'single',
	['searchRadar'] = {
		['CH_SkynexHX'] = {
		},
	},
	['launchers'] = {
		['CH_SkynexHX'] = {
		},
	},
	['name'] = {
		['NATO'] = 'Skynex SPAAGM',
	},
	['harm_detection_chance'] = 22,
	['can_engage_harm'] = true
	
}

samTypesDB['Wiesel Ozelot'] = {
	['type'] = 'single',
	['launchers'] = {
		['CH_Wiesel2Ozelot'] = {
		},
	},
	['name'] = {
		['NATO'] = 'Ozelot',
	},
	['harm_detection_chance'] = 5,
	['can_engage_harm'] = false
	
}

samTypesDB['Boxer SPAAGM'] = {
	['type'] = 'single',
	['launchers'] = {
		['CH_BoxerSkyranger'] = {
		},
	},
	['name'] = {
		['NATO'] = 'Boxer SPAAGM',
	},
	['harm_detection_chance'] = 8,
	['can_engage_harm'] = false
	
}

samTypesDB['Skynex C-RAM'] = {
	['type'] = 'complex',
	['searchRadar'] = {
		['CH_Skyshield_FCU'] = {
		},
	},
	['launchers'] = {
		['CH_Skyshield_Gun'] = {
		},
	},
	['name']  = {
		['NATO'] = 'Skynex C-RAM'
	},
	['harm_detection_chance'] = 28,
	['can_engage_harm'] = true
}	

samTypesDB['IRIS-T SML'] = {
	['type'] = 'complex',
	['searchRadar'] = {
		['CH_TRML4D'] = {
		},
	},
	['misc'] = {
		['CH_IRIST_SLM_C2'] = {
			['required'] = true,
		},
	},
	['launchers'] = {
		['CH_IRIST_SLM'] = {
		},
	},
	['name']  = {
		['NATO'] = 'IRIS-T SLM'
	},
	['harm_detection_chance'] = 79,
	['can_engage_harm'] = true
}	

samTypesDB['MIM-104_GER'] = {
	['type'] = 'complex',
	['searchRadar'] = {
		['CH_MIM104_ANMPQ53_KAT1'] = {
			['name'] = {
				['NATO'] = 'Fire Finder',
			},
		},
	},
	['misc'] = {
		['CH_MIM104_ECS_KAT1'] = {
			['required'] = true,
		},
		['CH_MIM104_EPP_KAT1'] = {
			['required'] = true,
		},
	},
	['launchers'] = {
		['CH_MIM104_M901_PAC2_KAT1'] = {
		},		
	},
	['name']  = {
		['NATO'] = 'SAM-10 Guardian'
	},
	['harm_detection_chance'] = 95,
	['can_engage_harm'] = true
}	

--[[

--]]

end



