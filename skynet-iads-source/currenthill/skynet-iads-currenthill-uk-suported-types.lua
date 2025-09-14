do
-- this file contains the definitions for the CurrentHill Russian Military Asset Pack: https://www.currenthill.com/russia

samTypesDB['CH_StormerHVM'] = {
	['type'] = 'single',
	['launchers'] = {
		['CH_StormerHVM'] = {
		},
	},
	['name'] = {
		['NATO'] = 'Stormer HVM',
	},
	['harm_detection_chance'] = 5,
	['can_engage_harm'] = true
	
}

samTypesDB['Sky Sabre'] = {
	['type'] = 'complex',
	['searchRadar'] = {
		['CH_SkySabreGiraffe'] = {
		},
	},
	['misc'] = {
		['CH_SkySabreC2'] = {
			['required'] = true,
		},
	},
	['launchers'] = {
		['CH_SkySabre'] = {
		},
	},
	['name']  = {
		['NATO'] = 'Sky Sabre'
	},
	['harm_detection_chance'] = 59,
	['can_engage_harm'] = true
}	

--[[

--]]

end



