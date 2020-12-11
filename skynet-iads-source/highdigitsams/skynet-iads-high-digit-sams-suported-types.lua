do
-- this file contains the definitions for the HightDigitSAMSs: https://github.com/Auranis/HighDigitSAMs

--[[ units in SA-10 group:
2020-12-10 18:27:27.050 INFO    SCRIPTING: S-300PMU1 54K6 cp
2020-12-10 18:27:27.050 INFO    SCRIPTING: S-300PMU1 5P85CE ln
2020-12-10 18:27:27.050 INFO    SCRIPTING: S-300PMU1 5P85DE ln
2020-12-10 18:27:27.050 INFO    SCRIPTING: S-300PMU1 40B6MD sr
2020-12-10 18:27:27.050 INFO    SCRIPTING: S-300PMU1 64N6E sr
2020-12-10 18:27:27.050 INFO    SCRIPTING: S-300PMU1 40B6M tr
2020-12-10 18:27:27.050 INFO    SCRIPTING: S-300PMU1 30N6E tr
--]]
s3000pmu1 = {
	['type'] = 'complex',
	['searchRadar'] = {
		['S-300PMU1 40B6MD sr'] = {
		},
		['S-300PMU1 64N6E sr'] = {
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
samTypesDB['S-300PMU1'] = s3000pmu1
end

