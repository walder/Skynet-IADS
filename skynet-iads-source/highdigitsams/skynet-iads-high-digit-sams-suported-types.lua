do
-- this file contains the definitions for the HightDigitSAMSs: https://github.com/Auranis/HighDigitSAMs

--EW radars used in multiple SAM systems:

s300PMU164N6Esr = {
	['name'] = {
		['NATO'] = 'Big Bird',
	},
}

s300PMU140B6MDsr = {
	['name'] = {
		['NATO'] = 'Clam Shell',
	},
}

--[[ units in SA-10 group Gargoyle:
2020-12-10 18:27:27.050 INFO    SCRIPTING: S-300PMU1 54K6 cp
2020-12-10 18:27:27.050 INFO    SCRIPTING: S-300PMU1 5P85CE ln
2020-12-10 18:27:27.050 INFO    SCRIPTING: S-300PMU1 5P85DE ln
2020-12-10 18:27:27.050 INFO    SCRIPTING: S-300PMU1 40B6MD sr
2020-12-10 18:27:27.050 INFO    SCRIPTING: S-300PMU1 64N6E sr
2020-12-10 18:27:27.050 INFO    SCRIPTING: S-300PMU1 40B6M tr
2020-12-10 18:27:27.050 INFO    SCRIPTING: S-300PMU1 30N6E tr
--]]
samTypesDB['S-300PMU1'] = {
	['type'] = 'complex',
	['searchRadar'] = {
		['S-300PMU1 40B6MD sr'] = s300PMU140B6MDsr,
		['S-300PMU1 64N6E sr'] = s300PMU164N6Esr,
		
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
		['S-300PMU1 40B6M tr'] = {
			['name'] = {
				['NATO'] = 'Grave Stone',
			},
		},
		['S-300PMU1 30N6E tr'] = {
			['name'] = {
				['NATO'] = 'Flap Lid',
			},

		},
		['S-300PS 40B6M tr'] = {
			['name'] = {
				['NATO'] = '',
			},
		},
	},
	['misc'] = {
		['S-300PMU1 54K6 cp'] = {
			['required'] = true,
		},
	},
	['launchers'] = {
		['S-300PMU1 5P85CE ln'] = {
		},
		['S-300PMU1 5P85DE ln'] = {
		},
	},
	['name']  = {
		['NATO'] = 'SA-20A Gargoyle'
	},
	['harm_detection_chance'] = 90,
	['can_engage_harm'] = true
}	

--[[ Units in the SA-23 Group:
2020-12-11 16:40:52.072 INFO    SCRIPTING: S-300VM 9A82ME ln
2020-12-11 16:40:52.072 INFO    SCRIPTING: S-300VM 9A83ME ln
2020-12-11 16:40:52.072 INFO    SCRIPTING: S-300VM 9S15M2 sr
2020-12-11 16:40:52.072 INFO    SCRIPTING: S-300VM 9S19M2 sr
2020-12-11 16:40:52.072 INFO    SCRIPTING: S-300VM 9S32ME tr
2020-12-11 16:40:52.072 INFO    SCRIPTING: S-300VM 9S457ME cp

]]--
samTypesDB['S-300VM'] = {
	['type'] = 'complex',
	['searchRadar'] = {
		['S-300VM 9S15M2 sr'] = {
			['name'] = {
				['NATO'] = 'Bill Board-C',
			},
		},
		['S-300VM 9S19M2 sr'] = {
			['name'] = {
				['NATO'] = 'High Screen-B',
			},
		},
	},
	['trackingRadar'] = {
		['S-300VM 9S32ME tr'] = {
		},
	},
	['misc'] = {
		['S-300VM 9S457ME cp'] = {
			['required'] = true,
		},
	},
	['launchers'] = {
		['S-300VM 9A82ME ln'] = {
		},
		['S-300VM 9A83ME ln'] = {
		},
	},
	['name']  = {
		['NATO'] = 'SA-23 Antey-2500'
	},
	['harm_detection_chance'] = 90,
	['can_engage_harm'] = true
}	

--[[ Units in the SA-10B Group:
2021-01-01 20:39:14.413 INFO    SCRIPTING: S-300PS SA-10B 40B6MD MAST sr
2021-01-01 20:39:14.413 INFO    SCRIPTING: S-300PS SA-10B 54K6 cp
2021-01-01 20:39:14.413 INFO    SCRIPTING: S-300PS 5P85SE_mod ln
2021-01-01 20:39:14.413 INFO    SCRIPTING: S-300PS 5P85SU_mod ln
2021-01-01 20:39:14.413 INFO    SCRIPTING: S-300PS 64H6E TRAILER sr
2021-01-01 20:39:14.413 INFO    SCRIPTING: S-300PS 30N6 TRAILER tr
2021-01-01 20:39:14.413 INFO    SCRIPTING: S-300PS SA-10B 40B6M MAST tr
--]]
samTypesDB['S-300PS'] = {
	['type'] = 'complex',
	['searchRadar'] = {
		['S-300PS SA-10B 40B6MD MAST sr'] = {
			['name'] = {
				['NATO'] = 'Clam Shell',
			},
		},
		['S-300PS SA-10B 76N6E sr'] = {
			['name'] = {
				['NATO'] = 'Clam Shell',
			},
		},
		['S-300PS 64H6E TRAILER sr'] = {
		},
		['S-300PS 64H6E MOD sr'] = {
			['name'] = {
				['NATO'] = 'Big Bird',
			},
		},
	},
	['trackingRadar'] = {
		['S-300PS 30N6 TRAILER tr'] = {
		},
		['S-300PS SA-10B 40B6M MAST tr'] = {
		},
		['S-300PS SA-10B 30N6 MAST tr'] = {
		},
		['S-300PS 40B6M tr'] = {
		},
		['S-300PMU1 40B6M tr'] = {
		},	
		['S-300PMU1 30N6E tr'] = {
		},		
	},
	['misc'] = {
		['S-300PS SA-10B 54K6 cp'] = {
			['required'] = true,
		},
	},
	['launchers'] = {
		['S-300PS 5P85SE_mod ln'] = {
		},
		['S-300PS 5P85SU_mod ln'] = {
		},
	},
	['name']  = {
		['NATO'] = 'SA-10B Grumble'
	},
	['harm_detection_chance'] = 90,
	['can_engage_harm'] = true
}

--[[ Extra launchers for the in game SA-10C and HighDigitSAMs SA-10B, SA-20B
2021-01-01 21:04:19.908 INFO    SCRIPTING: S-300PS 5P85DE ln
2021-01-01 21:04:19.908 INFO    SCRIPTING: S-300PS 5P85CE ln
--]]

local s300launchers = samTypesDB['S-300']['launchers']
s300launchers['S-300PS 5P85DE ln'] = {}
s300launchers['S-300PS 5P85CE ln'] = {}

local s300launchers = samTypesDB['S-300PS']['launchers']
s300launchers['S-300PS 5P85DE ln'] = {}
s300launchers['S-300PS 5P85CE ln'] = {}

local s300launchers = samTypesDB['S-300PMU1']['launchers']
s300launchers['S-300PS 5P85DE ln'] = {}
s300launchers['S-300PS 5P85CE ln'] = {}

--[[
New launcher for the SA-11 complex, will identify as SA-17
SA-17 Buk M1-2 LN 9A310M1-2
 --]]
samTypesDB['Buk-M2'] = {
	['type'] = 'complex',
	['searchRadar'] = {
		['SA-11 Buk SR 9S18M1'] = {
			['name'] = {
				['NATO'] = 'Snow Drift',
			},
		},
	},
	['launchers'] = {
		['SA-17 Buk M1-2 LN 9A310M1-2'] = {
		},
	},
	['misc'] = {
		['SA-11 Buk CC 9S470M1'] = {
			['required'] = true,
		},
	},
	['name'] = {
		['NATO'] = 'SA-17 Grizzly',
	},
	['harm_detection_chance'] = 90
}

--[[
New launcher for the SA-2 complex: S_75M_Volhov_V759
--]]
local s75launchers = samTypesDB['S-75']['launchers']
s75launchers['S_75M_Volhov_V759'] = {}

--[[
New launcher for the SA-3 complex:
--]]
local s125launchers = samTypesDB['S-125']['launchers']
s125launchers['5p73 V-601P ln'] = {}

--[[
New launcher for the SA-2 complex: HQ_2_Guideline_LN
--]]
local s125launchers = samTypesDB['S-75']['launchers']
s125launchers['HQ_2_Guideline_LN'] = {}

--[[
SA-12 Gladiator / Giant:
2021-03-19 21:24:22.620 INFO    SCRIPTING: S-300V 9S15 sr
2021-03-19 21:24:22.620 INFO    SCRIPTING: S-300V 9S19 sr
2021-03-19 21:24:22.620 INFO    SCRIPTING: S-300V 9S32 tr
2021-03-19 21:24:22.620 INFO    SCRIPTING: S-300V 9S457 cp
2021-03-19 21:24:22.620 INFO    SCRIPTING: S-300V 9A83 ln
2021-03-19 21:24:22.620 INFO    SCRIPTING: S-300V 9A82 ln
--]]
samTypesDB['S-300V'] = {
	['type'] = 'complex',
	['searchRadar'] = {
		['S-300V 9S15 sr'] = {
			['name'] = {
				['NATO'] = 'Bill Board',
			},
		},
		['S-300V 9S19 sr'] = {
			['name'] = {
				['NATO'] = 'High Screen',
			},
		},
	},
	['trackingRadar'] = {
		['S-300V 9S32 tr'] = {
			['name'] = {
				['NATO'] = 'Grill Pan',
			},
		},
	},
	['misc'] = {
		['S-300V 9S457 cp'] = {
			['required'] = true,
		},
	},
	['launchers'] = {
		['S-300V 9A83 ln'] = {
		},
		['S-300V 9A82 ln'] = {
		},
	},
	['name']  = {
		['NATO'] = 'SA-12 Gladiator/Giant'
	},
	['harm_detection_chance'] = 90,
	['can_engage_harm'] = true
}

--[[
SA-20B Gargoyle B:

2021-03-25 19:15:02.135 INFO    SCRIPTING: S-300PMU2 64H6E2 sr
2021-03-25 19:15:02.135 INFO    SCRIPTING: S-300PMU2 92H6E tr
2021-03-25 19:15:02.135 INFO    SCRIPTING: S-300PMU2 5P85SE2 ln
2021-03-25 19:15:02.135 INFO    SCRIPTING: S-300PMU2 54K6E2 cp
--]]

samTypesDB['S-300PMU2'] = {
	['type'] = 'complex',
	['searchRadar'] = {
		['S-300PMU2 64H6E2 sr'] = {
			['name'] = {
				['NATO'] = 'Big Bird',
			},
		},
		['S-300PMU1 40B6MD sr'] = s300PMU140B6MDsr,
		['S-300PMU1 64N6E sr'] = s300PMU164N6Esr,
	},
	['trackingRadar'] = {
		['S-300PMU2 92H6E tr'] = {
		},
		['S-300PMU2 30N6E2 tr'] = {
		},
		['S-300PMU2 30N6E2 mast tr'] = {
		},
		['S-300PS 40B6M tr'] = {
		},
		['S-300PMU1 40B6M tr'] = {
		},
		['S-300PMU1 30N6E tr'] = {
		},
	},
	['misc'] = {
		['S-300PMU2 54K6E2 cp'] = {
			['required'] = true,
		},
	},
	['launchers'] = {
		['S-300PMU2 5P85SE2 ln'] = {
		},
	},
	['name']  = {
		['NATO'] = 'SA-20B Gargoyle B'
	},
	['harm_detection_chance'] = 90,
	['can_engage_harm'] = true
}

-- SAMPack_S-300_Series: S-300V4 (SA-23B)
samTypesDB['S-300V4'] = {
	['type'] = 'complex',
	['searchRadar'] = {
		['S-300V4 9S15MDE sr'] = {
			['name'] = {
				['NATO'] = 'Bill Board-M',
			},
		},
		['S-300V4 9S19M-1E sr'] = {
			['name'] = {
				['NATO'] = 'High Screen-M',
			},
		},
	},
	['trackingRadar'] = {
		['S-300V4 9S32M-1E tr'] = {
			['name'] = {
				['NATO'] = 'Grill Pan-M',
			},
		},
	},
	['misc'] = {
		['S-300V4 9S457-2E cp'] = {
			['required'] = true,
		},
	},
	['launchers'] = {
		['S-300V4 9A82M-2E ln'] = {
		},
		['S-300V4 9A83M-2E ln'] = {
		},
		['S-300V4 9A84M-2E ln'] = {
		},
	},
	['name'] = {
		['NATO'] = 'SA-23B Antey-4000',
	},
	['harm_detection_chance'] = 95,
	['can_engage_harm'] = true
}

-- SAMPack_S-300_Series: S-400 (SA-21 Growler)
samTypesDB['S-400'] = {
	['type'] = 'complex',
	['searchRadar'] = {
		['S-400 91N6E sr'] = {
			['name'] = {
				['NATO'] = 'Big Bird-D',
			},
		},
		['S-400 96L6E sr'] = {
			['name'] = {
				['NATO'] = 'Cheese Board',
			},
		},
		['S-400 96L6E mast sr'] = {
			['name'] = {
				['NATO'] = 'Cheese Board',
			},
		},
	},
	['trackingRadar'] = {
		['S-400 92N6E tr'] = {
			['name'] = {
				['NATO'] = 'Grave Stone',
			},
		},
		['S-400 92N6E mast tr'] = {
			['name'] = {
				['NATO'] = 'Grave Stone',
			},
		},
	},
	['misc'] = {
		['S-400 55K6 cp'] = {
			['required'] = true,
		},
	},
	['launchers'] = {
		['S-400 51P6A ln'] = {
		},
		['S-400 51P6A (9M96E2) ln'] = {
		},
	},
	['name'] = {
		['NATO'] = 'SA-21 Growler',
	},
	['harm_detection_chance'] = 95,
	['can_engage_harm'] = true
}

-- SAMPack_S-300_Series: Pantsir-SM
samTypesDB['Pantsir-SM'] = {
	['type'] = 'single',
	['searchRadar'] = {
		['Pantsir_SM'] = {
		},
	},
	['launchers'] = {
		['Pantsir_SM'] = {
		},
	},
	['name'] = {
		['NATO'] = 'SA-22 Greyhound',
	},
	['harm_detection_chance'] = 95,
	['can_engage_harm'] = true
}

-- SAMSitesAssetPack EWRs & Radars:
samTypesDB['S-75']['trackingRadar']['ERO_SA2_SNR75'] = {}

samTypesDB['EWR 1L119 Nebo-SVU'] = {
	['type'] = 'ewr',
	['searchRadar'] = {
		['EWR 1L119 Nebo-SVU'] = {
			['name'] = {
				['NATO'] = 'Nebo-SVU',
			},
		},
	},
	['harm_detection_chance'] = 85
}

samTypesDB['EWR 55G6U NEBO-U'] = {
	['type'] = 'ewr',
	['searchRadar'] = {
		['EWR 55G6U NEBO-U'] = {
			['name'] = {
				['NATO'] = 'Tall Rack',
			},
		},
	},
	['harm_detection_chance'] = 85
}

samTypesDB['EWR P-37 BAR LOCK'] = {
	['type'] = 'ewr',
	['searchRadar'] = {
		['EWR P-37 BAR LOCK'] = {
			['name'] = {
				['NATO'] = 'Bar Lock',
			},
		},
	},
	['harm_detection_chance'] = 60
}

samTypesDB['EWR Generic radar tower'] = {
	['type'] = 'ewr',
	['searchRadar'] = {
		['EWR Generic radar tower'] = {
			['name'] = {
				['NATO'] = 'Generic EWR',
			},
		},
	},
	['harm_detection_chance'] = 70
}

-- Currenthill Military Asset Pack (Russia):
samTypesDB['CH_S350'] = {
	['type'] = 'complex',
	['searchRadar'] = {
		['CH_S350_96L6'] = {
			['name'] = {
				['NATO'] = 'Cheese Board',
			},
		},
		['CH_S350_50N6'] = {
			['name'] = {
				['NATO'] = '50N6A',
			},
		},
	},
	['trackingRadar'] = {
		['CH_S350_50N6'] = {
		},
	},
	['launchers'] = {
		['CH_S350_50P6_9M96D'] = {
		},
		['CH_S350_50P6_9M100'] = {
		},
	},
	['misc'] = {
		['CH_S350_50K6'] = {
			['required'] = true,
		},
	},
	['name'] = {
		['NATO'] = 'SA-28 Vityaz',
	},
	['harm_detection_chance'] = 95,
	['can_engage_harm'] = true
}

samTypesDB['CH_BukM3'] = {
	['type'] = 'complex',
	['searchRadar'] = {
		['CH_BukM3_9S18M13'] = {
			['name'] = {
				['NATO'] = 'Snow Drift',
			},
		},
		['CH_BukM3_9S36M'] = {
			['name'] = {
				['NATO'] = '9S36M',
			},
		},
		['CH_BukM3_9A317M'] = {
		},
	},
	['launchers'] = {
		['CH_BukM3_9A317M'] = {
		},
		['CH_BukM3_9A317MA'] = {
		},
	},
	['misc'] = {
		['CH_BukM3_9S510M'] = {
			['required'] = false,
		},
	},
	['name'] = {
		['NATO'] = 'SA-27 Gollum',
	},
	['harm_detection_chance'] = 90,
	['can_engage_harm'] = true
}

samTypesDB['CH_PantsirS2'] = {
	['type'] = 'single',
	['searchRadar'] = {
		['CH_PantsirS2'] = {
		},
	},
	['launchers'] = {
		['CH_PantsirS2'] = {
		},
	},
	['name'] = {
		['NATO'] = 'SA-22 Greyhound',
	},
	['harm_detection_chance'] = 95,
	['can_engage_harm'] = true
}

samTypesDB['CH_TorM2K'] = {
	['type'] = 'single',
	['searchRadar'] = {
		['CH_TorM2K'] = {
		},
	},
	['launchers'] = {
		['CH_TorM2K'] = {
		},
	},
	['name'] = {
		['NATO'] = 'SA-15 Gauntlet',
	},
	['harm_detection_chance'] = 90,
	['can_engage_harm'] = true
}
samTypesDB['Tor']['searchRadar']['CH_TorM2K'] = {}
samTypesDB['Tor']['launchers']['CH_TorM2K'] = {}

samTypesDB['CH_2S38'] = {
	['type'] = 'single',
	['searchRadar'] = {
		['CH_2S38'] = {
		},
		['CH_2S38_LG'] = {
		},
	},
	['launchers'] = {
		['CH_2S38'] = {
		},
		['CH_2S38_LG'] = {
		},
	},
	['name'] = {
		['NATO'] = '2S38 Derivatsiya',
	},
	['harm_detection_chance'] = 70,
	['can_engage_harm'] = true
}

samTypesDB['Strela-10M3']['searchRadar']['CH_9K35'] = { ['trackingRadar'] = true }
samTypesDB['Strela-10M3']['launchers']['CH_9K35'] = {}
samTypesDB['ZSU-23-4 Shilka']['searchRadar']['CH_ZSU234'] = {}
samTypesDB['ZSU-23-4 Shilka']['launchers']['CH_ZSU234'] = {}

-- Currenthill Military Asset Pack (USA & Germany):
local patriotSR = samTypesDB['Patriot']['searchRadar']
patriotSR['CH_MIM104_ANMPQ65'] = { ['name'] = { ['NATO'] = 'AN/MPQ-65' } }
patriotSR['CH_MIM104_ANMPQ65A'] = { ['name'] = { ['NATO'] = 'AN/MPQ-65A' } }
patriotSR['CH_MIM104_ANMPQ65_HEMTT'] = { ['name'] = { ['NATO'] = 'AN/MPQ-65' } }
patriotSR['CH_MIM104_ANMPQ65A_HEMTT'] = { ['name'] = { ['NATO'] = 'AN/MPQ-65A' } }
patriotSR['CH_MIM104_LTAMDS'] = { ['name'] = { ['NATO'] = 'LTAMDS' } }
patriotSR['CH_MIM104_LTAMDS_HEMTT'] = { ['name'] = { ['NATO'] = 'LTAMDS' } }
patriotSR['CH_MIM104_ANMPQ53_KAT1'] = { ['name'] = { ['NATO'] = 'AN/MPQ-53' } }

local patriotLN = samTypesDB['Patriot']['launchers']
patriotLN['CH_MIM104_M903_PAC2'] = {}
patriotLN['CH_MIM104_M903_PAC2_HEMTT'] = {}
patriotLN['CH_MIM104_M903_PAC3'] = {}
patriotLN['CH_MIM104_M903_PAC3_HEMTT'] = {}
patriotLN['CH_MIM104_M901_PAC2_KAT1'] = {}

local patriotMisc = samTypesDB['Patriot']['misc']
patriotMisc['CH_MIM104_ECS'] = { ['required'] = false }
patriotMisc['CH_MIM104_EPP'] = { ['required'] = false }
patriotMisc['CH_MIM104_ECS_KAT1'] = { ['required'] = false }
patriotMisc['CH_MIM104_EPP_KAT1'] = { ['required'] = false }

local nasamsSR = samTypesDB['NASAMS']['searchRadar']
nasamsSR['CH_NASAMS3_SR'] = {}
local nasamsLN = samTypesDB['NASAMS']['launchers']
nasamsLN['CH_NASAMS3_LN_AIM9X2'] = {}
nasamsLN['CH_NASAMS3_LN_AMRAAM_ER'] = {}
samTypesDB['NASAMS']['misc']['CH_NASAMS3_CP'] = { ['required'] = false }

samTypesDB['CH_THAAD'] = {
	['type'] = 'complex',
	['searchRadar'] = {
		['CH_THAAD_ANTPY2'] = {
			['name'] = {
				['NATO'] = 'AN/TPY-2',
			},
		},
	},
	['launchers'] = {
		['CH_THAAD_M1120'] = {
		},
	},
	['misc'] = {
		['CH_THAAD_TFCC'] = {
			['required'] = false,
		},
	},
	['name'] = {
		['NATO'] = 'THAAD',
	},
	['harm_detection_chance'] = 95,
	['can_engage_harm'] = true
}

samTypesDB['Phalanx']['searchRadar']['CH_Centurion_C_RAM'] = {}
samTypesDB['Phalanx']['launchers']['CH_Centurion_C_RAM'] = {}

samTypesDB['CH_LAVAD'] = {
	['type'] = 'single',
	['searchRadar'] = {
		['CH_LAVAD'] = {
			['trackingRadar'] = true,
		},
	},
	['launchers'] = {
		['CH_LAVAD'] = {
		},
	},
	['name'] = {
		['NATO'] = 'LAV-AD',
	},
	['harm_detection_chance'] = 20
}

samTypesDB['Roland ADS']['searchRadar']['CH_FlaRakRad'] = { ['name'] = { ['NATO'] = 'FlaRakRad' } }
samTypesDB['Roland ADS']['launchers']['CH_FlaRakRad'] = {}

samTypesDB['CH_Skyshield'] = {
	['type'] = 'complex',
	['searchRadar'] = {
		['CH_Skyshield_FCU'] = {
			['name'] = {
				['NATO'] = 'Skyshield FCU',
			},
		},
	},
	['launchers'] = {
		['CH_Skyshield_Gun'] = {
		},
	},
	['name'] = {
		['NATO'] = 'Skyshield',
	},
	['harm_detection_chance'] = 80,
	['can_engage_harm'] = true
}

samTypesDB['CH_Skynex'] = {
	['type'] = 'single',
	['searchRadar'] = {
		['CH_SkynexHX'] = {
		},
		['CH_BoxerSkyranger'] = {
		},
	},
	['launchers'] = {
		['CH_SkynexHX'] = {
		},
		['CH_BoxerSkyranger'] = {
		},
	},
	['name'] = {
		['NATO'] = 'Skynex',
	},
	['harm_detection_chance'] = 80,
	['can_engage_harm'] = true
}

samTypesDB['CH_Wiesel2Ozelot'] = {
	['type'] = 'single',
	['searchRadar'] = {
		['CH_Wiesel2Ozelot'] = {
		},
	},
	['launchers'] = {
		['CH_Wiesel2Ozelot'] = {
		},
	},
	['name'] = {
		['NATO'] = 'Ozelot',
	},
	['harm_detection_chance'] = 20
}

-- Currenthill Military Asset Pack (China):
samTypesDB['CH_HQ22'] = {
	['type'] = 'complex',
	['searchRadar'] = {
		['CH_HQ22_SR'] = {
			['name'] = {
				['NATO'] = 'JSG-100',
			},
		},
		['CH_HQ22_STR'] = {
			['name'] = {
				['NATO'] = 'H-200',
			},
		},
	},
	['trackingRadar'] = {
		['CH_HQ22_STR'] = {
		},
	},
	['launchers'] = {
		['CH_HQ22_LN'] = {
		},
	},
	['name'] = {
		['NATO'] = 'HQ-22',
	},
	['harm_detection_chance'] = 90,
	['can_engage_harm'] = true
}

samTypesDB['HQ17A'] = {
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
		['NATO'] = 'HQ-17A',
	},
	['harm_detection_chance'] = 90,
	['can_engage_harm'] = true
}

samTypesDB['PGZ-09']['searchRadar']['CH_PGZ09'] = {}
samTypesDB['PGZ-09']['launchers']['CH_PGZ09'] = {}
samTypesDB['PGZ-09']['searchRadar']['CH_PGZ95'] = {}
samTypesDB['PGZ-09']['launchers']['CH_PGZ95'] = {}
samTypesDB['PGZ-09']['searchRadar']['PGL_625'] = {}
samTypesDB['PGZ-09']['launchers']['PGL_625'] = {}

samTypesDB['Phalanx']['searchRadar']['CH_LD3000'] = {}
samTypesDB['Phalanx']['launchers']['CH_LD3000'] = {}
samTypesDB['Phalanx']['searchRadar']['CH_LD3000_stationary'] = {}
samTypesDB['Phalanx']['launchers']['CH_LD3000_stationary'] = {}

-- Turkish EW_Sistemi Mod:
samTypesDB['KORAL'] = {
	['type'] = 'ewr',
	['searchRadar'] = {
		['KORAL100'] = {
			['name'] = {
				['NATO'] = 'KORAL EW',
			},
		},
		['KORAL200'] = {
			['name'] = {
				['NATO'] = 'KORAL EW',
			},
		},
		['Ilgar'] = {
			['name'] = {
				['NATO'] = 'ILGAR EW',
			},
		},
		['Vural'] = {
			['name'] = {
				['NATO'] = 'VURAL EW',
			},
		},
	},
	['harm_detection_chance'] = 90
}

end



