do
-- this file contains the definitions for the HightDigitSAMSs: https://github.com/Auranis/HighDigitSAMs

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
		['S-300PMU1 40B6MD sr'] = {
		},
		['S-300PMU1 64N6E sr'] = {
			['name'] = {
				['NATO'] = 'Big Bird',
			},
		},
	},
	['trackingRadar'] = {
		['S-300PMU1 40B6M tr'] = {
		},
		['S-300PMU1 30N6E tr'] = {
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
	['harm_detection_chance'] = 90
}	

--[[ Units in the SA-23 Group:
2020-12-11 16:40:52.072 INFO    SCRIPTING: S-300VM 9A82ME ln
2020-12-11 16:40:52.072 INFO    SCRIPTING: S-300VM 9A83ME ln
2020-12-11 16:40:52.072 INFO    SCRIPTING: S-300VM 9S15M2 sr
2020-12-11 16:40:52.072 INFO    SCRIPTING: S-300VM 9S19M2 sr
2020-12-11 16:40:52.072 INFO    SCRIPTING: S-300VM 9S32ME tr
2020-12-11 16:40:52.072 INFO    SCRIPTING: S-300VM 9S457ME cp

According to wikipedia:
dem 9A83-Startfahrzeug die Bezeichnung SA-12A Gladiator zu geben; das größere 9A82-Startfahrzeug erhielt die Bezeichnung SA-12B Giant.
9A83ME -> SA-23A Gladiator
9A82ME -> SA-23B Giant
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
		['NATO'] = 'SA-23 Gladiator/Giant'
	},
	['harm_detection_chance'] = 90
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
		},
		['S-300PS 64H6E TRAILER sr'] = {
		},
	},
	['trackingRadar'] = {
		['S-300PS 30N6 TRAILER tr'] = {
		},
		['S-300PS SA-10B 40B6M MAST tr'] = {
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
	['harm_detection_chance'] = 90
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

end



