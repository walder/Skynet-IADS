do
-- this file contains the definitions for the SAMPack_S_300/SAM Sites Asset Pack (2SAP): https://drive.google.com/file/d/15STKuCIaQcbbjSO_xlDKvREtbYJ67an5/view?usp=sharing


--[[ units in S-300 PS:
vehicle_file("/Database/Vehicle/S-300PS_5P85DE_LN.lua")
vehicle_file("/Database/Vehicle/S-300PS_5P85SE_LN.lua")
vehicle_file("/Database/Vehicle/S-300PS_5P85SU_LN.lua")
vehicle_file("/Database/Vehicle/S-300PS_54K6_CP.lua")
vehicle_file("/Database/Vehicle/radar/S-300PS_30N6_TR_Mast.lua")
vehicle_file("/Database/Vehicle/radar/S-300PS_30N6_TR_Truck.lua")
vehicle_file("/Database/Vehicle/radar/S-300PS_64N6E_SR_Truck.lua")
vehicle_file("/Database/Vehicle/radar/S-300PS_76N6_SR.lua")
--]]
samTypesDB['S-300PS'] = {
	['type'] = 'complex',
	['searchRadar'] = {
		['S-300PS 64H6E MOD sr'] = {
			['name'] = {
				['NATO'] = 'Big Bird',
			},
		},
		['S-300PS SA-10B 76N6E sr'] = {
			['name'] = {
				['NATO'] = 'Clam Shell',
			},
		},
	},
	['trackingRadar'] = {
		['S-300PS 30N6 TRAILER tr'] = {
			['name'] = {
				['NATO'] = 'Flap Lid',
			},
		},
		['S-300PS SA-10B 30N6 MAST tr'] = {
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
		['S-300PS SA-10B 54K6 cp'] = {
			['required'] = true,
		},
	},
	['launchers'] = {
		['S-300PS 5P85SE_mod ln'] = {
		},
		['S-300PS 5P85SU_mod ln'] = {
		},
		['S-300PS 5P85DE ln'] = {
		},
	},
	['name']  = {
		['NATO'] = 'SA-10B Grumble'
	},
	['harm_detection_chance'] = 90,
	['can_engage_harm'] = true
}	

--[[ Units in the S-300V4:
vehicle_file("/Database/Vehicle/radar/S-300V4_9S32M-1E_TR.lua")
vehicle_file("/Database/Vehicle/radar/S-300V4_9S19M-1E_SR.lua")
vehicle_file("/Database/Vehicle/radar/S-300V4_9S15MDE_SR.lua")
vehicle_file("/Database/Vehicle/S-300V4_9A82M-2E_LN.lua")
vehicle_file("/Database/Vehicle/S-300V4_9A83M-2E_LN.lua")
vehicle_file("/Database/Vehicle/S-300V4_9A84M-2E_LN.lua")
vehicle_file("/Database/Vehicle/S-300V4_9S457-2E_CP.lua")

]]--
samTypesDB['S-300V4'] = {
	['type'] = 'complex',
	['searchRadar'] = {
		['S-300V4 9S15MDE sr'] = {
			['name'] = {
				['NATO'] = 'Bill Board-C',
			},
		},
		['S-300V4 9S19M-1E sr'] = {
			['name'] = {
				['NATO'] = 'High Screen-B',
			},
		},
	},
	['trackingRadar'] = {
		['S-300V4 9S32M-1E tr'] = {
		},
	},
	['misc'] = {
		['S-300V4 9S457-2E cp'] = {
			['required'] = true,
		},
	},
	['launchers'] = {
		['S-300V4 9A83M-2E ln'] = {
		},
		['S-300V4 9A82M-2E ln'] = {
		},
		['S-300V4 9A84M-2E ln'] = {
		},
	},
	['name']  = {
		['NATO'] = 'SA-23 Antey-4000'
	},
	['harm_detection_chance'] = 90,
	['can_engage_harm'] = true
}	

--[[ Units in the S-400:
vehicle_file("/Database/Vehicle/S-400_51P6A_LN.lua")
vehicle_file("/Database/Vehicle/S-400_51P6A_V2_LN.lua")
vehicle_file("/Database/Vehicle/S-400_55K6_CP.lua")
vehicle_file("/Database/Vehicle/radar/S-400_96L6E_SR.lua")
vehicle_file("/Database/Vehicle/radar/S-400_96L6E_Mast_SR.lua")
vehicle_file("/Database/Vehicle/radar/S-400_92H6E_TR.lua")
vehicle_file("/Database/Vehicle/radar/S-400_91N6E_SR.lua")
vehicle_file("/Database/Vehicle/radar/S-400_92H6E_Mast_TR.lua")
--]]
samTypesDB['S-400'] = {
	['type'] = 'complex',
	['searchRadar'] = {
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
		['S-400 91N6E sr'] = {
			['name'] = {
				['NATO'] = 'Big Bird',
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
	['name']  = {
		['NATO'] = 'SA-21 Growler'
	},
	['harm_detection_chance'] = 90,
	['can_engage_harm'] = true
}

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
	['harm_detection_chance'] = 90,
	['can_engage_harm'] = true
	
}

--[[

--]]
end



