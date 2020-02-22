do
samTypesDB = { -- this is a static DB based off of scripts/database files for each sam type.
	-- '-' character needs special search term %
	['S%-300'] = {
		['type'] = 'complex',
		['searchRadar'] = {
			['S-300PS 40B6MD sr'] = {
				['max_range_finding_target'] = 60000,
				['min_range_finding_target'] = 2000,
				['max_alt_finding_target'] = 3000,
				['min_alt_finding_target'] = 5,
				['height'] = 42.158,
				['radar_rotation_period'] = 3.0,
			},
			['S-300PS 64H6E sr'] = {
				['max_range_finding_target'] = 160000,
				['min_range_finding_target'] = 2000,
				['max_alt_finding_target'] = 27000,
				['min_alt_finding_target'] = 100,
				['height'] = 8.68,
				['radar_rotation_period'] = 12.0/2, -- radar has 2 sides
			},
		},
		['trackingRadar'] = {
			['S-300PS 40B6M tr'] = {
				['max_range_finding_target'] = 160000,
				['min_range_finding_target'] = 2000,
				['max_alt_finding_target'] = 27000,
				['min_alt_finding_target'] = 25,
				['height'] = 27.63,
			},
		},
		['launchers'] = {
			['S-300PS 5P85D ln'] = {
				['missiles'] = 4,
				['range'] = 120000,
				['rearmTime'] = 3600,
			},
			['S-300PS 5P85C ln'] = {
				['missiles'] = 4,
				['range'] = 120000,
				['rearmTime'] = 3600,
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
	},
	['Buk'] = {
		['type'] = 'complex',
		['searchRadar'] = {
			['SA-11 Buk SR 9S18M1'] = {
				['max_range_finding_target'] = 100000,
				['min_range_finding_target'] = 2000,
				['max_alt_finding_target'] = 25000,
				['min_alt_finding_target'] = 25,
				['height'] = 7.534,
				['radar_rotation_period'] = 12.0,
				['radar_on'] = 60,
			},
		},
		['launchers'] = {
			['SA-11 Buk LN 9A310M1'] = {
				['missiles'] = 4,
				['range'] = 50000,
				['max_range_finding_target'] = 50000,
				['min_range_finding_target'] = 3000,
				['max_alt_finding_target'] = 22000,
				['min_alt_finding_target'] = 20,
				['height'] = 6.931,
				['trackingRadar'] = true,
				['atkVisual'] = true,
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
		['mobile'] = true,
	},
	['s%-125'] = {
		['type'] = 'complex',
		['searchRadar'] = {
			['p-19 s-125 sr'] = {
				['max_range_finding_target'] = 80000,
				['min_range_finding_target'] = 1500,
				['max_alt_finding_target'] = 20000,
				['min_alt_finding_target'] = 25,
				['height'] = 5.841,
				['radar_rotation_period'] = 6.0,
			},
		},
		['trackingRadar'] = {
			['snr s-125 tr'] = {
				['max_range_finding_target'] = 100000,
				['min_range_finding_target'] = 1500,
				['max_alt_finding_target'] = 20000,
				['min_alt_finding_target'] = 25,
				['height'] = 3,
			},
		},
		['launchers'] = {
			['5p73 s-125 ln'] = {
				['range'] = 18000,
				['missiles'] = 4,
			},
		},
		['name'] = {
			['NATO'] = 'SA-3 Goa',
		},
	},
    ['s%-75'] = {
		['type'] = 'complex',
		['searchRadar'] = {
			['p-19 s-125 sr'] = {
				['max_range_finding_target'] = 80000,
				['min_range_finding_target'] = 1500,
				['max_alt_finding_target'] = 20000,
				['min_alt_finding_target'] = 25,
				['height'] = 5.841,
				['radar_rotation_period'] = 6.0,
			},
		},
		['trackingRadar'] = {
			['SNR_75V'] = {
				['max_range_finding_target'] = 100000,
				['min_range_finding_target'] = 1500,
				['max_alt_finding_target'] = 25000,
				['min_alt_finding_target'] = 25,
				['height'] = 5.5,
			},
		},
		['launchers'] = {
			['S_75M_Volhov'] = {
				['range'] = 40000,
				['missiles'] = 1,
				['rearmTime'] = 2700,
			},
		},
		['name'] = {
			['NATO'] = 'SA-2 Guideline',
		},
	},
	['Kub'] = {
		['type'] = 'complex',
		['mobile'] = true,
		['searchRadar'] = {
			['Kub 1S91 str'] = {
				['max_range_finding_target'] = 70000,
				['min_range_finding_target'] = 1000,
				['max_alt_finding_target'] = 14000,
				['min_alt_finding_target'] = 20,
				['height'] = 5.872,
				['radar_rotation_period'] = 4.0,
				['trackingRadar'] = true,
				['radar_on'] = 6,
			},
		},
		['launchers'] = {
			['Kub 2P25 ln'] = {
				['range'] = 25000,
				['missiles'] = 3,
			
			},
		},
		['name'] = {
			['NATO'] = 'SA-6 Gainful',
		},
	},
	['Patriot'] = {
		['type'] = 'complex',
		['searchRadar'] = {
			['Patriot str'] = {
				['max_range_finding_target'] = 16000,
				['min_range_finding_target'] = 3000,
				['max_alt_finding_target'] = 30000,
				['min_alt_finding_target'] = 60,
				['height'] = 5.895,
				['trackingRadar'] = true,
			},
		},

		['launchers'] = {
			['Patriot ln'] = {
				['range'] = 100000,
				['missiles'] = 4,
				['rearmTime'] = 3600,
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
	},
	['Hawk'] = {
		['type'] = 'complex',
		['searchRadar'] = {
			['Hawk sr'] = {
				['max_range_finding_target'] = 90000,
				['min_range_finding_target'] = 1500,
				['max_alt_finding_target'] = 20000,
				['min_alt_finding_target'] = 25,
				['height'] = 5.841,
				['radar_rotation_period'] = 6.0,
			},
		},
		['trackingRadar'] = {
			['Hawk tr'] = {
				['max_range_finding_target'] = 90000,
				['min_range_finding_target'] = 1500,
				['max_alt_finding_target'] = 20000,
				['min_alt_finding_target'] = 25,
				['height'] = 3,
			},
		},
		['launchers'] = {
			['Hawk ln'] = {
				['range'] = 50000,
				['missiles'] = 3,
			},
		},

		['name'] = {
			['NATO'] = 'Hawk',
		},

	},	
	['Roland ADS'] = {
		['type'] = 'single',
		['mobile'] = true,
		['searchRadar'] = {
			['Roland ADS'] = {
				['max_range_finding_target'] = 12000,
				['min_range_finding_target'] = 1500,
				['max_alt_finding_target'] = 6000,
				['min_alt_finding_target'] = 20,
				['height'] = 3.922,
				['radar_rotation_period'] = 1.0,
				['trackingRadar'] = true,
			},
		},
		['launchers'] = {
			['Roland ADS'] = {
				['laser'] = true,
				['range'] = 8000,
				['missiles'] = 8,
				['rearmTime'] = 3600,
			},
		},

		['name'] = {
			['NATO'] = 'Roland ADS',
		},
	},		
	['2S6 Tunguska'] = {
		['type'] = 'single',
		['mobile'] = true,
		['searchRadar'] = {
			['2S6 Tunguska'] = {
				['max_range_finding_target'] = 18000,
				['min_range_finding_target'] = 200,
				['max_alt_finding_target'] = 3500,
				['min_alt_finding_target'] = 0,
				['height'] = 3.675,
				['radar_rotation_period'] = 1.0,
				['trackingRadar'] = true,
			},
		},
		['launchers'] = {
			['2S6 Tunguska'] = {

				['range'] = 8000,
				['missiles'] = 8,
				['guns'] = true,
			},
		},
		['name'] = {
			['NATO'] = 'SA-19 Grison',
		},
	},		
	['Osa'] = {
		['type'] = 'single',
		['mobile'] = true,
		['searchRadar'] = {
			['Osa 9A33 ln'] = {
				['max_range_finding_target'] = 30000,
				['min_range_finding_target'] = 1500,
				['max_alt_finding_target'] = 5000,
				['min_alt_finding_target'] = 10,
				['height'] = 5.438,
				['radar_rotation_period'] = 60/33,
				['trackingRadar'] = true,
			},
		},
		['launchers'] = {
			['Osa 9A33 ln'] = {

				['range'] = 8000,
				['missiles'] = 6,
				['radar_on'] = 5,
			},
		},
		['name'] = {
			['NATO'] = 'SA-8 Gecko',
		},
	},	
	['Strela%-10M3'] = {
		['type'] = 'single',
		['mobile'] = true,
		['searchRadar'] = {
			['Strela-10M3'] = {
				['max_range_finding_target'] = 8000,
				['min_range_finding_target'] = 0,
				['max_alt_finding_target'] = 3500,
				['min_alt_finding_target'] = 10,
				['height'] = 3.548,
				['trackingRadar'] = true,
				['ir'] = true,
			},
		},
		['launchers'] = {
			['Strela-10M3'] = {

				['range'] = 5000,
				['missiles'] = 4,
				['ir'] = true,
			},
		},
		['name'] = {
			['NATO'] = 'SA-13 Gopher',
		},
	},	
	['Strela%-1 9P31'] = {
		['type'] = 'single',
		['mobile'] = true,
		['searchRadar'] = {
			['Strela-1 9P31'] = {
				['max_range_finding_target'] = 5000,
				['min_range_finding_target'] = 0,
				['max_alt_finding_target'] = 3500,
				['min_alt_finding_target'] = 10,
				['height'] = 3.277,
				['trackingRadar'] = true,
				['ir'] = true,
			},
		},
		['launchers'] = {
			['Strela-1 9P31'] = {

				['range'] = 4000,
				['missiles'] = 4,
				['ir'] = true,
			},
		},
		['name'] = {
			['NATO'] = 'SA-9 Gaskin',
		},
	},
	['Tor'] = {
		['type'] = 'single',
		['mobile'] = true,
		['searchRadar'] = {
			['Tor 9A331'] = {
				['max_range_finding_target'] = 25000,
				['min_range_finding_target'] = 500,
				['max_alt_finding_target'] = 8000,
				['min_alt_finding_target'] = 20,
				['radar_rotation_period'] = 1.0,
				['height'] = 5.118,	
				['trackingRadar'] = true,
			},
		},
		['launchers'] = {
			['Tor 9A331'] = {

				['range'] = 12000,
				['missiles'] = 8,
				['radar_on'] = 10,
			},
		},
		['name'] = {
			['NATO'] = 'SA-15 Gauntlet',
		},
	},
	['Gepard'] = {
		['type'] = 'single',
		['mobile'] = true,
		['searchRadar'] = {
			['Gepard'] = {
				['max_range_finding_target'] = 15000,
				['min_range_finding_target'] = 0,
				['max_alt_finding_target'] = 3000,
				['min_alt_finding_target'] = 0,
				['height'] = 3.854,
				['trackingRadar'] = true,
			},
		},
		['launchers'] = {
			['Gepard'] = {
				['range'] = 3000,
				['aaa'] = true,
			},
		},
		['name'] = {
			['NATO'] = 'Gepard',
		},
	},		
	['Igla'] = {
		['type'] = 'single',
		['searchRadar'] = {
			['SA-18 Igla manpad'] = {
				['max_range_finding_target'] = 5000,
				['min_range_finding_target'] = 0,
				['max_alt_finding_target'] = 3000,
				['min_alt_finding_target'] = 0,
				['height'] = 1.8,
				['ir'] = true,
				['trackingRadar'] = true,
			},
		},
		['launchers'] = {
			['SA-18 Igla manpad'] = {

				['range'] = 5000,
				['missiles'] = 3,
				['ir'] = true,
			},
			['SA-18 Igla-S comm'] = {

				['height'] = 1.8,
				['range'] = 5000,
			},			
		},
		['name'] = {
			['NATO'] = 'SA-18 Grouse',
		},
	},	
	['M6 Linebacker'] = {
		['type'] = 'single',
		['mobile'] = true,
		['searchRadar'] = {
			['M6 Linebacker'] = {
				['max_range_finding_target'] = 8000,
				['min_range_finding_target'] = 0,
				['max_alt_finding_target'] = 3000,
				['min_alt_finding_target'] = 0,
				['height'] = 2.58,
				['ir'] = true,
				['trackingRadar'] = true,				
			},
		},
		['launchers'] = {
			['M6 Linebacker'] = {
				['range'] = 4500,
				['missiles'] = 4,
				['ir'] = true,
				['guns'] = true,
			},
		},
		['name'] = {
			['NATO'] = 'M6 Linebacker',
		},
	},
    ['Rapier'] = {
        ['searchRadar'] = {
            ['rapier_fsa_blindfire_radar'] = {
				['max_range_finding_target'] = 30000,
				['min_range_finding_target'] = 500,
				['max_alt_finding_target'] = 4000,
				['min_alt_finding_target'] = 50,
                ['radar_rotation_period'] = 1.0,
            },
        },
        ['launchers'] = {
        	['rapier_fsa_launcher'] = {
				['missiles'] = 4,
				['range'] = 8800,
				['max_range_finding_target'] = 30000,
				['min_range_finding_target'] = 500,
				['max_alt_finding_target'] = 4000,
				['min_alt_finding_target'] = 50,
				['height'] = 2.5,
				['trackingRadar'] = true,
				['rearmTime'] = 210,
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
    },	
	['M48 Chaparral'] = {
		['type'] = 'single',
		['mobile'] = true,
		['searchRadar'] = {
			['M48 Chaparral'] = {
				['max_range_finding_target'] = 10000,
				['min_range_finding_target'] = 0,
				['max_alt_finding_target'] = 2500,
				['min_alt_finding_target'] = 0,
				['height'] = 2.52,
				['ir'] = true,
				['trackingRadar'] = true,		
			},
		},
		['launchers'] = {
			['M48 Chaparral'] = {

				['range'] = 8500,
				['missiles'] = 4,		
				['ir'] = true,		
			},
		},
		['name'] = {
			['NATO'] = 'M48 Chaparral',
		},
	},
	['Vulcan'] = {
		['type'] = 'single',
		['mobile'] = true,
		
		['searchRadar'] = {
			['Vulcan'] = {
				['max_range_finding_target'] = 5000,
				['min_range_finding_target'] = 0,
				['max_alt_finding_target'] = 2500,
				['min_alt_finding_target'] = 0,
				['height'] = 3.872,
				['trackingRadar'] = true,
			},
		},
		['launchers'] = {
			['Vulcan'] = {

				['range'] = 1500,
				['aaa'] = true,
			},
		},
	
		['name'] = {
			['NATO'] = 'M163 Vulcan',
		},


	},
	['M1097 Avenger'] = {
		['type'] = 'single',
		['mobile'] = true,
		['searchRadar'] = {
			['M1097 Avenger'] = {
				['max_range_finding_target'] = 5200,
				['min_range_finding_target'] = 0,
				['max_alt_finding_target'] = 2500,
				['min_alt_finding_target'] = 0,
				['height'] = 3.076,
				['ir'] = true,
				['trackingRadar'] = true,		
			},
		},
		['launchers'] = {
			['M1097 Avenger'] = {
				
				['range'] = 1500,
				['missiles'] = 8,
				['ir'] = true,
				['guns'] = true,
			},
		},
		['name'] = {
			['NATO'] = 'M1097 Avenger',
		},
	},
	['Stinger'] = {
		['type'] = 'single',
		['searchRadar'] = {
			['Stinger manpad'] = {
				['max_range_finding_target'] = 5000,
				['min_range_finding_target'] = 0,
				['max_alt_finding_target'] = 3000,
				['min_alt_finding_target'] = 0,
				['height'] = 1.8,
				['ir'] = true,
				['trackingRadar'] = true,		
			},
		},
		['launchers'] = {
			['Stinger manpad'] = {

				['range'] = 5000,
				['missiles'] = 3,
				['ir'] = true,
			},
			['Stinger comm'] = {
				['height'] = 1.8,
				['range'] = 5000,
			},			
		},
		['name'] = {
			['NATO'] = 'Stinger manpad',
		},
	},
	['ZSU%-23%-4 Shilka'] = {
		['type'] = 'single',
		['mobile'] = true,
		['searchRadar'] = {
			['ZSU-23-4 Shilka'] = {
				['max_range_finding_target'] = 5000,
				['min_range_finding_target'] = 0,
				['max_alt_finding_target'] = 2500,
				['min_alt_finding_target'] = 0,
				['height'] = 3.458,
				['trackingRadar'] = true,		
			},
		},
		['launchers'] = {
			['ZSU-23-4 Shilka'] = {
				['range'] = 2500,
				['aaa'] = true,
			},
		},
		['name'] = {
			['NATO'] = 'Zues',
		},
	},
	['ZU%-23'] = { -- zu-23
		['type'] = 'single',
		['searchRadar'] = {
			['ZU%-23'] = {
				['max_range_finding_target'] = 5000,
				['min_range_finding_target'] = 0,
				['max_alt_finding_target'] = 2500,
				['min_alt_finding_target'] = 0,
				['range'] = 2500,
				['height'] = 1.736,
				['sensor'] = false,
			},
		},
		['launchers'] = {
			['ZU-23 Emplacement'] = {
				['aaa'] = true,
			},
			['ZU-23 Insurgent'] = {
				['aaa'] = true,
			},
			['ZU-23 Closed Insurgent'] = {
				['aaa'] = true,
			},
			['ZU-23 Emplacement Closed'] = {
				['aaa'] = true,
			},			
			['Ural-375 ZU-23'] = {
				['aaa'] = true,
				['mobile'] = true,
			},
			['Ural-375 ZU-23 Insurgent'] = {
				['aaa'] = true,
				['mobile'] = true,
			},			
		},
		
		['name'] = {
			['NATO'] = 'ZU-23 Emplacement',
		},
	},
	['1L13 EWR'] = {
		['type'] = 'ewr',
		['searchRadar'] = {
			['1L13 EWR'] = {
				['max_range_finding_target'] = 120000,
				['min_range_finding_target'] = 0,
				['max_alt_finding_target'] = 30000,
				['min_alt_finding_target'] = 50,
				['height'] = 39,
				['ewr'] = true,
				['cantTurnOffBug'] = true,
				['radar_rotation_period'] = 18.0/2,
			},
		},
		['name'] = {
			['NATO'] = '1L13 EWR',
		},
	},
	['55G6 EWR'] = {
		['type'] = 'ewr',
		['searchRadar'] = {
			['55G6 EWR'] = {
				['max_range_finding_target'] = 120000,
				['min_range_finding_target'] = 0,
				['max_alt_finding_target'] = 30000,
				['min_alt_finding_target'] = 50,
				['height'] = 39,
				['ewr'] = true,
				['cantTurnOffBug'] = true,
				['radar_rotation_period'] = 10.0/2,
			},
		},
		['name'] = {
			['NATO'] = '55G6 EWR',
		},
	},
	['Dog Ear'] = {
		['type'] = 'ewr',
		['mobile'] = true,
		['searchRadar'] = {
			['Dog Ear radar'] = {
				['max_range_finding_target'] = 35000,
				['min_range_finding_target'] = 100,
				['max_alt_finding_target'] = 10000,
				['min_alt_finding_target'] = 15,
				['height'] = 3.8,
				['ewr'] = true,
				['radar_rotation_period'] = 3.0,
			},
		},
		['name'] = {
			['NATO'] = 'Dog Ear',
		},
	},
	['Roland Radar'] = {
		['type'] = 'ewr',
		['mobile'] = true,
		['searchRadar'] = {
			['Roland Radar'] = {
				['max_range_finding_target'] = 35000,
				['min_range_finding_target'] = 1500,
				['max_alt_finding_target'] = 6000,
				['min_alt_finding_target'] = 15,
				['height'] = 6.87,
				['ewr'] = true,
				['radar_rotation_period'] = 3.0,
			},
		},
		['name'] = {
			['NATO'] = 'Roland EWR',
		},
	},
}
end
do

SkynetIADSAbstractElement = {}

function SkynetIADSAbstractElement:create()
	local instance = {}
	setmetatable(instance, self)
	self.__index = self
	instance.connectionNodes = {}
	instance.powerSources = {}
	return instance
end


function SkynetIADSAbstractElement:getLife()
	return self:getDCSRepresentation():getLife()
end

function SkynetIADSAbstractElement:addPowerSource(powerSource)
	table.insert(self.powerSources, powerSource)
end

function SkynetIADSAbstractElement:addConnectionNode(connectionNode)
	table.insert(self.connectionNodes, connectionNode)
end

function SkynetIADSAbstractElement:hasActiveConnectionNode()
	return self:genericCheckOneObjectIsAlive(self.connectionNodes)
end

function SkynetIADSAbstractElement:hasWorkingPowerSource()
	return self:genericCheckOneObjectIsAlive(self.powerSources)
end

function SkynetIADSAbstractElement:getDCSName()
	return self:getDCSRepresentation():getName()
end

-- generic function to theck if power plants, command centers, connection nodes are still alive
function SkynetIADSAbstractElement:genericCheckOneObjectIsAlive(objects)
	local isAlive = (#objects == 0)
	for i = 1, #objects do
		local object = objects[i]
		--trigger.action.outText("life: "..object:getLife(), 1)
		--if we find one object that is not fully destroyed we assume the IADS is still working
		if object:getLife() > 0 then
			isAlive = true
			break
		end
	end
	return isAlive
end

function SkynetIADSAbstractElement:setDCSRepresentation(representation)
	self.dcsRepresentation = representation
end

function SkynetIADSAbstractElement:getDCSRepresentation()
	return self.dcsRepresentation
end

function SkynetIADSAbstractElement:getController()
	return self:getDCSRepresentation():getController()
end

function SkynetIADSAbstractElement:getDBValues()
	local units = {}
	units[1] = self:getDCSRepresentation()
	if getmetatable(self:getDCSRepresentation()) == Group then
		units = self:getDCSRepresentation():getUnits()
	end
	local samDB = {}
	local unitData = nil
	local typeName = nil
	local natoName = ""
	for i = 1, #units do
		typeName = units[i]:getTypeName()
		for samName, samData in pairs(SkynetIADS.database) do
			--all Sites have a unique launcher, if we find one, we got the internal designator of the SAM unit
			unitData = SkynetIADS.database[samName]
			if unitData['launchers'] and unitData['launchers'][typeName] or unitData['searchRadar'] and unitData['searchRadar'][typeName] then
				samDB = self:extractDBName(samName)
				break
			end
		end
	end
	return samDB
end

function SkynetIADSAbstractElement:extractDBName(samName)
	local samDB = {}
	samDB['key'] =  samName
--	trigger.action.outText("Element is a: "..samName, 1)
	natoName = SkynetIADS.database[samName]['name']['NATO']
	local pos = natoName:find(" ")
	local prefix = natoName:sub(1, 2)
	--we shorten the SA-XX names and don't return their code names eg goa, gainful
	if string.lower(prefix) == 'sa' and pos ~= nil then
		natoName = natoName:sub(1, (pos-1))
	end
	samDB['nato'] = natoName
	return samDB
end

function SkynetIADSAbstractElement:getDBName()
	local dbName =  self:getDBValues()['key']
	if dbName == nil then
		dbName = "UNKNOWN"
	end
	return dbName
end

function SkynetIADSAbstractElement:getNatoName()
	local natoName = self:getDBValues()['nato']
	if natoName == nil then
		natoName = "UNKNOWN"
	end
	return natoName
end

function SkynetIADSAbstractElement:getDescription()
	return "IADS ELEMENT: "..self:getDCSRepresentation():getName().." | Type : "..tostring(self:getNatoName())
end

-- helper code for class inheritance
function inheritsFrom( baseClass )

    local new_class = {}
    local class_mt = { __index = new_class }

    function new_class:create()
        local newinst = {}
        setmetatable( newinst, class_mt )
        return newinst
    end

    if nil ~= baseClass then
        setmetatable( new_class, { __index = baseClass } )
    end

    -- Implementation of additional OO properties starts here --

    -- Return the class object of the instance
    function new_class:class()
        return new_class
    end

    -- Return the super class object of the instance
    function new_class:superClass()
        return baseClass
    end

    -- Return true if the caller is an instance of theClass
    function new_class:isa( theClass )
        local b_isa = false

        local cur_class = new_class

        while ( nil ~= cur_class ) and ( false == b_isa ) do
            if cur_class == theClass then
                b_isa = true
            else
                cur_class = cur_class:superClass()
            end
        end

        return b_isa
    end

    return new_class
end

end
do
SkynetIADSCommandCenter = {}
SkynetIADSCommandCenter = inheritsFrom(SkynetIADSAbstractElement)

function SkynetIADSCommandCenter:create(commandCenter)
	local comCenter = self:superClass():create()
	setmetatable(comCenter, self)
	self.__index = self
	comCenter:setDCSRepresentation(commandCenter)
	return comCenter
end

end
do

SkynetIADSEWRadar = {}
SkynetIADSEWRadar = inheritsFrom(SkynetIADSAbstractElement)

function SkynetIADSEWRadar:create(radarUnit, iads)
	local radar = self:superClass():create()
	setmetatable(radar, self)
	self.__index = self
	radar:setDCSRepresentation(radarUnit)
	radar.iads = iads
	if radar.iads:getDebugSettings().addedEWRadar then
			radar.iads:printOutput(radar:getDescription().." added to IADS")
	end
	return radar
end

function SkynetIADSEWRadar:getDetectedTargets()
	if self:hasWorkingPowerSource() == false then
		trigger.action.outText(self:getDescription().." has no Power", 1)
		return
	end
	local returnTargets = {}
	--trigger.action.outText("EW getTargets", 1)
	--trigger.action.outText(self.radarUnit:getName(), 1)
	local ewRadarController = self:getController()
	local targets = ewRadarController:getDetectedTargets()
	--trigger.action.outText("num Targets: "..#targets, 1)
	for i = 1, #targets do
		local target = targets[i].object
		--trigger.action.outText(target:getName(), 1)
		table.insert(returnTargets, target)
	end
	return returnTargets
end

end
do

SkynetIADSJammer = {}
SkynetIADSJammer.__index = SkynetIADSJammer

function SkynetIADSJammer:create(emitter)
	local jammer = {}
	setmetatable(jammer, SkynetIADSJammer)
	jammer.emitter = emitter
	jammer.jammerTaskID = nill
	jammer.iads = {}
	--jammer probability settings are stored here, visualisation, see: https://docs.google.com/spreadsheets/d/16rnaU49ZpOczPEsdGJ6nfD0SLPxYLEYKmmo4i2Vfoe0/edit#gid=0
	jammer.jammerTable = {
		['SA-2'] = {
			['function'] = function(distanceNauticalMiles) return ( 1.4 ^ distanceNauticalMiles ) + 90 end,
			['canjam'] = true,
		},
		['SA-3'] = {
			['function'] = function(distanceNauticalMiles) return ( 1.4 ^ distanceNauticalMiles ) + 80 end,
			['canjam'] = true,
		},
		['SA-6'] = {
			['function'] = function(distanceNauticalMiles) return ( 1.4 ^ distanceNauticalMiles ) + 23 end,
			['canjam'] = true,
		},
		['SA-10'] = {
			['function'] = function(distanceNauticalMiles) return ( 1.07 ^ (distanceNauticalMiles / 1.13) ) + 5 end,
			['canjam'] = true,
		},
		['SA-11'] = {
			['function'] = function(distanceNauticalMiles) return ( 1.25 ^ distanceNauticalMiles ) + 15 end,
			['canjam'] = true,
		},
		['SA-15'] = {
			['function'] = function(distanceNauticalMiles) return ( 1.15 ^ distanceNauticalMiles ) + 5 end,
			['canjam'] = true,
		},
	}
	return jammer
end

function SkynetIADSJammer:masterArmOn()
	self:masterArmSafe()
	self.jammerTaskID = mist.scheduleFunction(SkynetIADSJammer.runCycle, {self}, 1, 1)
end

function SkynetIADSJammer:disableFor(natoName)
	self.jammerTable[natoName]['canjam'] = false
end

function SkynetIADSJammer:isActiveForEmitterType(natoName)
	return self.jammerTable[natoName]['canjam']
end

function SkynetIADSJammer:addIADS(iads)
	table.insert(self.iads, iads)
end

function SkynetIADSJammer:getSuccessProbability(distanceNauticalMiles, natoName)
	local probability = 0
	local jammerSettings = self.jammerTable[natoName]
	if jammerSettings ~= nil then
		probability = jammerSettings['function'](distanceNauticalMiles)
	end
	return probability
end

function SkynetIADSJammer.runCycle(self)

	if self.emitter:getLife() == 1 then
		self:masterArmSafe()
	--	trigger.action.outText("emitter is dead", 1)
		return
	end

	for i = 1, #self.iads do
		local iads = self.iads[i]
		local samSites = iads:getSamSites()	
		for j = 1, #samSites do
			local samSite = samSites[j]
			local radars = samSite:getRadarUnits()
			local hasLOS = false
			local distance = 0
			local natoName = samSite:getNatoName()
			for l = 1, #radars do
				local radar = radars[l]
				distance = mist.utils.metersToNM(mist.utils.get2DDist(self.emitter:getPosition().p, radar:getPosition().p))
				-- I try to emulate the system as it would work in real life, so a jammer can only jam a SAM site if has line of sight to at least one radar in the group
				if self:hasLineOfSightToRadar(radar) then
					hasLOS = true
				end
			end
			if samSite:isActive() and self:isActiveForEmitterType(natoName) then
			--	trigger.action.outText("Distance: "..distance, 2)
			--	trigger.action.outText("Jammer Probability: "..self:getSuccessProbability(distance, natoName), 2)
				samSite:jam(self:getSuccessProbability(distance, natoName))
			end
		end
	end
	--trigger.action.outText("jammer cycle",1)
end

function SkynetIADSJammer:hasLineOfSightToRadar(radar)
	local radarPos = radar:getPosition().p
	--lift the radar 3 meters off the ground, some 3d models are dug in to the ground, creating issues in calculating LOS
	radarPos.y = radarPos.y + 3
	return land.isVisible(radarPos, self.emitter:getPosition().p) 
end

function SkynetIADSJammer:masterArmSafe()
	mist.removeFunction(self.jammerTaskID)
end

end
do

SkynetIADSSamSite = {}
SkynetIADSSamSite = inheritsFrom(SkynetIADSAbstractElement)

SkynetIADSSamSite.AUTONOMOUS_STATE_DCS_AI = 0
SkynetIADSSamSite.AUTONOMOUS_STATE_DARK = 1

function SkynetIADSSamSite:create(samGroup, iads)
	local sam = self:superClass():create()
	setmetatable(sam, self)
	self.__index = self
	sam.aiState = true
	sam.iads = iads
	sam.isAutonomous = false
	sam.targetsInRange = {}
	sam.jammerID = nil
	sam.lastJammerUpdate = 0
	sam.setJammerChance = true
	sam.autonomousMode = SkynetIADSSamSite.AUTONOMOUS_STATE_DCS_AI
	sam:setDCSRepresentation(samGroup)
	sam:goDark(true)
	world.addEventHandler(sam)
	return sam
end

function SkynetIADSSamSite:goDark(enforceGoDark)
	-- if the sam site has contacts in range, it will refuse to go dark, unless we enforce shutdown
	if ( self:getNumTargetsInRange() > 0 ) and ( enforceGoDark ~= true ) then
		return
	end
	if self.aiState == true then
		local controller = self:getController()
		-- we will turn off AI for all SAM Sites added to the IADS, Skynet decides when a site will go online.
		controller:setOnOff(false)
		controller:setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.GREEN)
		controller:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_HOLD)
		self.aiState = false
		mist.removeFunction(self.jammerID)
		if self.iads:getDebugSettings().samWentDark then
			self.iads:printOutput(self:getDescription().." going dark")
		end
	end
end

function SkynetIADSSamSite:goLive()
	if self:hasWorkingPowerSource() == false then
		return
	end
	if self.aiState == false then
		local  cont = self:getController()
		cont:setOnOff(true)
		cont:setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.RED)	
		cont:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_FREE)
		---cont:knowTarget(ewrTarget, true, true) check to see if this will help for a faster shot of the SAM
		self.aiState = true
		if self.iads:getDebugSettings().samWentLive then
			self.iads:printOutput(self:getDescription().." going live")
		end
	end
end

--this function is currently a simple placeholder, should read all the radar units of the SAM system an return them
--use this:
--if samUnit:hasSensors(Unit.SensorType.RADAR, Unit.RadarType.AS) or samUnit:hasAttribute("SAM SR") or samUnit:hasAttribute("EWR") or samUnit:hasAttribute("SAM TR") or samUnit:hasAttribute("Armed ships") then
function SkynetIADSSamSite:getRadarUnits()
	return self:getDCSRepresentation():getUnits()
end

function SkynetIADSSamSite:jam(successRate)
	--trigger.action.outText(self.lastJammerUpdate, 2)
	if self.lastJammerUpdate == 0 then
		--trigger.action.outText("updating jammer probability", 5)
		self.lastJammerUpdate = 10
		self.setJammerChance = true
		local jammerChance = successRate
		mist.removeFunction(self.jammerID)
		self.jammerID = mist.scheduleFunction(SkynetIADSSamSite.setJamState, {self, jammerChance}, 1, 1)
	end
end

function SkynetIADSSamSite.setJamState(self, jammerChance)
	local controller = self:getController()
	if self.setJammerChance then
		self.setJammerChance = false
		local probability = math.random(100)
		if self.iads:getDebugSettings().jammerProbability then
			self.iads:printOutput("JAMMER: "..self:getDescription()..": Probability: "..jammerChance)
		end
		if jammerChance > probability then
			controller:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_HOLD)
			if self.iads:getDebugSettings().jammerProbability then
				self.iads:printOutput("JAMMER: "..self:getDescription()..": jammed, setting to weapon hold")
			end
		else
			controller:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_FREE)
			if self.iads:getDebugSettings().jammerProbability then
				self.iads:printOutput("Jammer: "..self:getDescription()..": jammed, setting to weapon free")
			end
		end
	end
	self.lastJammerUpdate = self.lastJammerUpdate - 1
end

function SkynetIADSSamSite:getNumTargetsInRange()
	local contacts = 0
	for description, aircraft in pairs(self.targetsInRange) do
		contacts = contacts + 1
	end
	--trigger.action.outText("num Contacts in Range: "..contacts, 1)
	return contacts
end

function SkynetIADSSamSite:isActive()
	return self.aiState
end

function SkynetIADSSamSite:goAutonomous()
	self.isAutonomous = true
	self.targetsInRange = {}
	if self.autonomousMode == SkynetIADSSamSite.AUTONOMOUS_STATE_DARK then
		self:goDark()
		trigger.action.outText(self:getDescription().." is Autonomous: DARK", 1)

	else
		self:goLive()
		trigger.action.outText(self:getDescription().." is Autonomous: DCS AI", 1)
	end
	return
end

function SkynetIADSSamSite:setAutonomousMode(mode)
	if mode ~= nil then
		self.autonomousMode = mode
	end
end

function SkynetIADSSamSite:handOff(contact)
	-- if the sam has no power, it won't do anything
	if self:hasWorkingPowerSource() == false then
		self:goDark(true)
		trigger.action.outText(self:getDescription().." has no Power", 1)
		return
	end
	if self:isTargetInRange(contact) then
		self.targetsInRange[contact:getName()] = contact
		self:goLive()
	else
		self:removeContact(contact)
		self:goDark()
	end
end

function SkynetIADSSamSite:removeContact(contact)
	local updatedContacts = {}
	for id, airborneObject in pairs(self.targetsInRange) do
		-- check to see if airborneObject still exists there are cases where the sam keeps the target in the array of contacts
		if airborneObject ~= contact and airborneObject:isExist() then
			updatedContacts[id] = airborneObject
		end
	end
	self.targetsInRange = updatedContacts
end

function SkynetIADSSamSite:isTargetInRange(target)
	local samSiteUnits = self:getDCSRepresentation():getUnits()
	local samRadarInRange = false
	local samLauncherinRange = false
	--go through sam site units to check launcher and radar distance, they could be positioned quite far apart, only activate if both are in reach
	for j = 1, #samSiteUnits do
		local  samElement = samSiteUnits[j]
		local typeName = samElement:getTypeName()
		local samDBData = SkynetIADS.database[self:getDBName()]
		--trigger.action.outText("type name: "..typeName, 1)
		local radarData = samDBData['searchRadar'][typeName]
		local launcherData = samDBData['launchers'][typeName]
		local trackingData = nil
		if radarData == nil then
			--to decide if we should activate the sam we use the tracking radar range if it exists
			trackingData = SkynetIADS.database[self:getDBName()]['trackingRadar']
		end
		--if we find a radar in a SAM site, we calculate to see if it is within tracking parameters
		if radarData ~= nil then
			if self:isRadarWithinTrackingParameters(target, samElement, radarData) then
				samRadarInRange = true
			end
		end
		--if we find a launcher in a SAM site, we calculate to see if it is within firing parameters
		if launcherData ~= nil then
			--if it's a AAA we override the check for launcher distance, otherwise the target will pass over the AAA without it firing because the AAA will become active too late
			if launcherData['aaa'] then
				samLauncherinRange = true
			end
			-- if it's not AAA we calculate the firing distance
			if self:isLauncherWithinFiringParameters(target, samElement, launcherData) and ( samLauncherinRange == false  ) then
				samLauncherinRange = true
			end
		end		
	end	
	-- we only need to find one radar and one launcher within range in a Group, the AI of DCS will then decide which launcher will fire
	return ( samRadarInRange and samLauncherinRange )
end

-- TODO: could be more acurrate if it would calculate slant range
function SkynetIADSSamSite:isLauncherWithinFiringParameters(aircraft, samLauncherUnit, launcherData)
	local isInRange = false
	local distance = mist.utils.get2DDist(aircraft:getPosition().p, samLauncherUnit:getPosition().p)
	local maxFiringRange = launcherData['range']
	-- trigger.action.outText("Launcher Range: "..maxFiringRange,1)
	-- trigger.action.outText("current distance: "..distance,1)
	if distance <= maxFiringRange then
		isInRange = true
		--trigger.action.outText(aircraft:getTypeName().." in range of:"..samLauncherUnit:getTypeName(),1)
	end
	return isInRange
end

function SkynetIADSSamSite:isRadarWithinTrackingParameters(aircraft, samRadarUnit, radarData)
	local isInRange = false
	local distance = mist.utils.get2DDist(aircraft:getPosition().p, samRadarUnit:getPosition().p)
	local radarHeight = samRadarUnit:getPosition().p.y
	local aircraftHeight = aircraft:getPosition().p.y	
	local altitudeDifference = math.abs(aircraftHeight - radarHeight)
	local maxDetectionAltitude = radarData['max_alt_finding_target']
	local maxDetectionRange = radarData['max_range_finding_target']	
	-- trigger.action.outText("Radar Range: "..maxDetectionRange,1)
	-- trigger.action.outText("current distance: "..distance,1)
	if altitudeDifference <= maxDetectionAltitude and distance <= maxDetectionRange then
		--trigger.action.outText(aircraft:getTypeName().." in range of:"..samRadarUnit:getTypeName(),1)
		isInRange = true
	end
	return isInRange
end

function SkynetIADSSamSite:isWeaponHarm(weapon)
	local desc = weapon:getDesc()
	return (desc.missileCategory == 6 and desc.guidance == 5)	
end

function SkynetIADSSamSite:onEvent(event)
--[[
	if event.id == world.event.S_EVENT_SHOT then
		local weapon = event.weapon
		targetOfMissile = weapon:getTarget()
		if targetOfMissile ~= nil and self:isWeaponHarm(weapon) then
			self:startHarmDefence(weapon)
		end	
	end
--]]
end

function SkynetIADSSamSite.harmDefence(self, inBoundHarm) 
	local target = inBoundHarm:getTarget()
	local harmDetected = false	
	if target ~= nil then
		local targetController = target:getController()
		trigger.action.outText("HARM TARGET IS: "..target:getName(), 1)	
		local radarContacts = targetController:getDetectedTargets()
		--check to see if targeted Radar Site can see the HARM with its sensors, only then start defensive action
		for i = 1, #radarContacts do
			local detectedObject = radarContacts[i].object
			if SkynetIADS.isWeaponHarm(detectedObject) then
				trigger.action.outText(target:getName().." has detected: "..detectedObject:getTypeName(), 1)
				harmDetected = true
			end
		end
		
		local distance = mist.utils.get2DDist(inBoundHarm:getPosition().p, target:getPosition().p)
		distance = mist.utils.round(mist.utils.metersToNM(distance),2)
		trigger.action.outText("HARM Distance: "..distance, 1)
		
		--TODO: some SAM Sites have HARM defence, so they do not need help from the script
		if distance < 5 and harmDetected then
			local point = inBoundHarm:getPosition().p
			point.y = point.y + 1
			point.x = point.x - 1
			point.z = point.z + 1
		--	trigger.action.explosion(point, 10) 
		end
	else
		trigger.action.outText("target is nil", 1)
	end
end

end
do

--V 1.0:
-- TODO: when SAM or EW Radar is active and looses its power source it should go dark
-- TODO: Update github documentation, add graphic overview of IADS elements
-- To test: shall sam turn ai off or set state to green, when going dark? Does one method have an advantage?
-- To test: different kinds of Sam types, damage to power source, command center, connection nodes

-- V 1.1:
-- TODO: check if SAM has LOS to target, if not, it should not activate
-- TODO: code HARM defence, check if SAM Site or EW sees HARM, only then start defence
-- TODO: SAM could have decoy emitters to trick HARM in to homing in to the wrong radar
-- TODO: extrapolate flight path to get SAM to active so that it can fire as aircraft aproaches max range	
-- TODO: add sneaky sam tactics, like stay dark until bandit has passed the sam then go live
-- TODO: if SAM site has run out of missiles shut it down
-- TODO: merge SAM contacts with the ones it gets from the IADS, it could be that the SAM sees something the IADS does not know about, later on add this data back to the IADS
-- TODO: add random failures in IFF so enemy planes trigger IADS SAM activation by mistake
-- TODO: electronic Warfare: add multiple planes via script around the Jamming Group, get SAM to target those
-- TODO: decide if more SAM Sites need to be jammable, eg blue side.
-- TODO: after one connection node or powerplant goes down and there are others, add a delay until the sam site comes online again (configurable)
-- TODO: remove contact in sam site if its out of range, it could be an IADS stops working while a SAM site is tracking a target --> or does this not matter due to DCS AI?
-- TODO: SA-10 Launch distance seems off
-- TODO: EW Radars should also be jammable, what should the effects be on IADS target detection? eg activate sam sites in the bearing ot the jammer source, since distance calculation would be difficult, when tracked by 2 EWs, distance calculation should improve due to triangulation?
-- To test: which SAM Types can engage air weapons, especially HARMs?
--[[
SAM Sites that engage HARMs:
SA-15

SAM Sites that ignore HARMS:
SA-11
SA-10
SA-6
]]--

-- Compile Scripts: type sam-types-db.lua  skynet-iads-abstract-element.lua skynet-iads-command-center.lua skynet-iads-early-warning-radar.lua skynet-iads-jammer.lua skynet-iads-sam-site.lua skynet-iads.lua > skynet-iads-compiled.lua

SkynetIADS = {}
SkynetIADS.__index = SkynetIADS

SkynetIADS.database = samTypesDB

function SkynetIADS:create()
	local iads = {}
	setmetatable(iads, SkynetIADS)
	iads.earlyWarningRadars = {}
	iads.samSites = {}
	iads.commandCenters = {}
	iads.ewRadarScanMistTaskID = nil
	iads.coalition = nil
	self.debugOutput = {}
	self.debugOutput.IADSStatus = false
	self.debugOutput.samWentDark = false
	self.debugOutput.contacts = false
	self.debugOutput.samWentLive = false
	self.debugOutput.ewRadarNoConnection = false
	self.debugOutput.samNoConnection = false
	self.debugOutput.jammerProbability = false
	self.debugOutput.addedEWRadar = false
	return iads
end

function SkynetIADS:setCoalition(item)
	if item then
		local coalitionID = item:getCoalition()
		if self.coalitionID == nil then
			self.coalitionID = coalitionID
		end
		if self.coalitionID ~= coalitionID then
			trigger.action.outText("WARNING: Element: "..item:getName().." has a different coalition than the IADS", 10)
		end
	end
end

function SkynetIADS:getCoalition()
	return self.coalitionID
end

function SkynetIADS:addEarlyWarningRadarsByPrefix(prefix)
	for unitName, groupData in pairs(mist.DBs.unitsByName) do
		local pos = string.find(string.lower(unitName), string.lower(prefix))
		if pos ~= nil and pos == 1 then
			self:addEarlyWarningRadar(unitName)
		end
	end
end

function SkynetIADS:addEarlyWarningRadar(earlyWarningRadarUnitName, powerSource, connectionNode)
	local earlyWarningRadarUnit = Unit.getByName(earlyWarningRadarUnitName)
	if earlyWarningRadarUnit == nil then
		trigger.action.outText("WARNING: You have added an EW Radar that does not exist, check name of Unit in Setup and Mission editor", 10)
		return
	end
	self:setCoalition(earlyWarningRadarUnit)
	local ewRadar = SkynetIADSEWRadar:create(earlyWarningRadarUnit, self)
	self:addPowerAndConnectionNodeTo(ewRadar, powerSource, connectionNode)
	table.insert(self.earlyWarningRadars, ewRadar)
end

function SkynetIADS:setOptionsForEarlyWarningRadar(unitName, powerSource, connectionNode)
		for i = 1, #self.earlyWarningRadars do
		local ewRadar = self.earlyWarningRadars[i]
		if string.lower(ewRadar:getDCSName()) == string.lower(unitName) then
			self:addPowerAndConnectionNodeTo(ewRadar, powerSource, connectionNode)
		end
	end
end

function SkynetIADS:addSamSitesByPrefix(prefix, autonomousMode)
	for groupName, groupData in pairs(mist.DBs.groupsByName) do
		local pos = string.find(string.lower(groupName), string.lower(prefix))
		if pos ~= nil and pos == 1 then
			self:addSamSite(groupName, nil, nil, autonomousMode)
		end
	end
end

function SkynetIADS:addSamSite(samSiteName, powerSource, connectionNode, autonomousMode)
	local samSiteDCS = Group.getByName(samSiteName)
	if samSiteDCS == nil then
		trigger.action.outText("You have added an SAM Site that does not exist, check name of Group in Setup and Mission editor", 10)
		return
	end
	self:setCoalition(samSiteDCS)
	local samSite = SkynetIADSSamSite:create(samSiteDCS, self)
	self:addPowerAndConnectionNodeTo(samSite, powerSource, connectionNode)
	samSite:setAutonomousMode(autonomousMode)
	if samSite:getDBName() == "UNKNOWN" then
		trigger.action.outText("You have added an SAM Site that Skynet IADS can not handle: "..samSite:getDCSName(), 10)
	else
		table.insert(self.samSites, samSite)
	end
end

function SkynetIADS:setOptionsForSamSite(groupName, powerSource, connectionNode, autonomousMode)
	for i = 1, #self.samSites do
		local samSite = self.samSites[i]
		if string.lower(samSite:getDCSName()) == string.lower(groupName) then
			self:addPowerAndConnectionNodeTo(samSite, powerSource, connectionNode)
			samSite:setAutonomousMode(autonomousMode)
		end
	end
end

function SkynetIADS:getSamSites()
	return self.samSites
end

function SkynetIADS:addPowerAndConnectionNodeTo(iadsElement, powerSource, connectionNode)
	if powerSource then
		self:setCoalition(powerSource)
		iadsElement:addPowerSource(powerSource)
	end
	if connectionNode then
		self:setCoalition(connectionNode)
		iadsElement:addConnectionNode(connectionNode)
	end
end

function SkynetIADS:addCommandCenter(commandCenter, powerSource)
	self:setCoalition(commandCenter)
	if powerSource then
		self:setCoalition(powerSource)
	end
	local comCenter = SkynetIADSCommandCenter:create(commandCenter)
	comCenter:addPowerSource(powerSource)
	table.insert(self.commandCenters, comCenter)
end

function SkynetIADS:isCommandCenterAlive()
	local hasWorkingCommandCenter = (#self.commandCenters == 0)
	for i = 1, #self.commandCenters do
		local comCenter = self.commandCenters[i]
		if comCenter:getLife() > 0 and comCenter:hasWorkingPowerSource() then
			hasWorkingCommandCenter = true
			break
		else
			hasWorkingCommandCenter = false
		end
	end
	return hasWorkingCommandCenter
end

function SkynetIADS:setSamSitesToAutonomousMode()
	for i= 1, #self.samSites do
		samSite = self.samSites[i]
		samSite:goAutonomous()
	end
end

function SkynetIADS.evaluateContacts(self)
	if self:getDebugSettings().IADSStatus then
		self:printSystemStatus()
	end	
	local iadsContacts = {}
	if self:isCommandCenterAlive() == false then
		if self:getDebugSettings().noWorkingCommmandCenter then
			self:printOutput("No Working Command Center")
		end
		self:setSamSitesToAutonomousMode()
		return
	end
	for i = 1, #self.earlyWarningRadars do
		local ewRadar = self.earlyWarningRadars[i]
		if ewRadar:hasActiveConnectionNode() then
			local ewContacts = ewRadar:getDetectedTargets()
			for j = 1, #ewContacts do
				--trigger.action.outText(ewContacts[j]:getName(), 1)
				iadsContacts[ewContacts[j]:getName()] = ewContacts[j]
				--trigger.action.outText(ewRadar:getDescription().." has detected: "..ewContacts[j]:getName(), 1)	
			end
		else
			if self:getDebugSettings().ewRadarNoConnection then
				self:printOutput(ewRadar:getDescription().." no connection to command center")
			end
		end
	end
	for unitName, unit in pairs(iadsContacts) do
		if self:getDebugSettings().contacts then
			self:printOutput("IADS CONTACT: "..unitName.." | TYPE: "..unit:getTypeName())
		end
		--currently the DCS Radar only returns enemy aircraft, if that should change an coalition check will be required
		---Todo: currently every type of object in the air is handed of to the sam site, including bombs and missiles, shall these be removed?
		self:correlateWithSamSites(unit)
	end
end

function SkynetIADS:printOutput(output)
	trigger.action.outText(output, 4)
end

function SkynetIADS:getDebugSettings()
	return self.debugOutput
end

function SkynetIADS:startHarmDefence(inBoundHarm)
	--TODO: store ID of task so it can be stopped when sam or harm is destroyed
	mist.scheduleFunction(SkynetIADS.harmDefence, {self, inBoundHarm}, 1, 1)	
end

function SkynetIADS:correlateWithSamSites(detectedAircraft)
	for i= 1, #self.samSites do
		local samSite = self.samSites[i]
		if samSite:hasActiveConnectionNode() then
			samSite:handOff(detectedAircraft)
		else
			if self:getDebugSettings().samNoConnection then
				self:printOutput(samSite:getDescription().." no connection Command center")
				samSite:goAutonomous()
			end
		end
	end
end

-- will start going through the Early Warning Radars to check what targets they have detected
function SkynetIADS:activate()
	if self.ewRadarScanMistTaskID ~= nil then
		mist.removeFunction(self.ewRadarScanMistTaskID)
	end
	self.ewRadarScanMistTaskID = mist.scheduleFunction(SkynetIADS.evaluateContacts, {self}, 1, 5)
end

function SkynetIADS:printSystemStatus()	
	local numComCenters = #self.commandCenters
	local numIntactComCenters = 0
	local numDestroyedComCenters = 0
	local numComCentersNoPower = 0
	local numComCentersServingIADS = 0
	for i = 1, #self.commandCenters do
		local commandCenter = self.commandCenters[i]
		if commandCenter:hasWorkingPowerSource() == false then
			numComCentersNoPower = numComCentersNoPower + 1
		end
		if commandCenter:getLife() > 0 then
			numIntactComCenters = numIntactComCenters + 1
		end
		if commandCenter:getLife() > 0 and commandCenter:hasWorkingPowerSource() then
			numComCentersServingIADS = numComCentersServingIADS + 1
		end
	end
	
	numDestroyedComCenters = numComCenters - numIntactComCenters
	
	self:printOutput("COMMAND CENTERS: Serving IADS: "..numComCentersServingIADS.." | Total: "..numComCenters.." | Intact: "..numIntactComCenters.." | Destroyed: "..numDestroyedComCenters.." | No Power: "..numComCentersNoPower)
	
	local ewNoPower = 0
	local ewTotal = #self.earlyWarningRadars
	local ewNoConnectionNode = 0
	
	for i = 1, #self.earlyWarningRadars do
		local ewRadar = self.earlyWarningRadars[i]
		if ewRadar:hasWorkingPowerSource() == false then
			ewNoPower = ewNoPower + 1
		end
		if ewRadar:hasActiveConnectionNode() == false then
			ewNoConnectionNode = ewNoConnectionNode + 1
		end
	end
	self:printOutput("EW SITES: "..ewTotal.." | Active: "..ewTotal.." | Inactive: 0 | No Power: "..ewNoPower.." | No Connection: "..ewNoConnectionNode)
	
	local samSitesInactive = 0
	local samSitesActive = 0
	local samSitesTotal = #self.samSites
	local samSitesNoPower = 0
	local samSitesNoConnectionNode = 0
	for i = 1, #self.samSites do
		local samSite = self.samSites[i]
		if samSite:hasWorkingPowerSource() == false then
			samSitesNoPower = samSitesNoPower + 1
		end
		if samSite:hasActiveConnectionNode() == false then
			samSitesNoConnectionNode = samSitesNoConnectionNode + 1
		end
		if samSite:isActive() then
			samSitesActive = samSitesActive + 1
		end
	end
	samSitesInactive = samSitesTotal - samSitesActive
	self:printOutput("SAM SITES: "..samSitesTotal.." | Active: "..samSitesActive.." | Inactive: "..samSitesInactive.." | No Power: "..samSitesNoPower.." | No Connection: "..samSitesNoConnectionNode)
end

end
