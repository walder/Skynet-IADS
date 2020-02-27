do
iranIADS = SkynetIADS:create()

---debug settings remove from here on if you do not wan't any output on what the IADS is doing
local iadsDebug = iranIADS:getDebugSettings()
iadsDebug.IADSStatus = true
iadsDebug.samWentDark = false
iadsDebug.contacts = false
iadsDebug.radarWentLive = false
iadsDebug.noWorkingCommmandCenter = false
iadsDebug.ewRadarNoConnection = false
iadsDebug.samNoConnection = false
iadsDebug.jammerProbability = false
iadsDebug.addedEWRadar = false
iadsDebug.ewRadarNoPower = false
iadsDebug.addedSAMSite = true
---end remove debug ---

iranIADS:addEarlyWarningRadarsByPrefix('EW')
iranIADS:addSamSitesByPrefix('SAM')

local powerStation1 = StaticObject.getByName("Command Center Power")
local powerStation2 = StaticObject.getByName("Command Center Power2")
local commandCenter1 = StaticObject.getByName("Command Center")
local commandCenter2 = StaticObject.getByName("Command Center2")
iranIADS:addCommandCenter(commandCenter1, powerStation1)
iranIADS:addCommandCenter(commandCenter2, powerStation2)

local sa6PowerStation = StaticObject.getByName('SA-6 Power')
local sa6ConnectionNode = StaticObject.getByName('SA-6 Connection Node')
iranIADS:setOptionsForSamSite('SAM-SA-6', sa6PowerStation, sa6ConnectionNode)

local ewWest2PowerSource = StaticObject.getByName('EW-west Power Source')
local ewWest2ConnectionNode = StaticObject.getByName('EW-west Connection Node')
iranIADS:setOptionsForEarlyWarningRadar('EW-west', ewWest2PowerSource, ewWest2ConnectionNode)
iranIADS:activate()	

local jammerSource = Unit.getByName("Player Hornet")
jammer = SkynetIADSJammer:create(jammerSource)
jammer:addIADS(iranIADS)
--jammer:masterArmOn()
--jammer:disableFor('SA-2')


-- IADS Test code from here onwards:

test = {}
test.powerStation1 = powerStation1
test.powerStation2 = powerStation2
test.commandCenter1 = commandCenter1
test.commandCenter2 = commandCenter2
test.sa6PowerStation = sa6PowerStation
test.sa6ConnectionNode = sa6ConnectionNode
test.ewWest2PowerSource = ewWest2PowerSource
test.ewWest2ConnectionNode = ewWest2ConnectionNode
test.boom = 1

function pickApartIADS(test)
	if test.boom == 1 then
		trigger.action.outText("BLOWING UP EW CONNECTION NODE", 5)
		trigger.action.explosion(test.ewWest2ConnectionNode:getPosition().p, 100)
		--trigger.action.outText(test.sa6ConnectionNode:getLife(), 10)
	end
	if test.boom == 2 then
		trigger.action.outText("BLOWING UP EW POWER STATION", 5)
		trigger.action.explosion(test.ewWest2PowerSource:getPosition().p, 100)
	--	trigger.action.outText(test.sa6Power:getLife(), 10)
	end	
	
	if test.boom == 3 then
		trigger.action.outText("BLOWING UP SA-6 CONNECTION NODE", 5)
		trigger.action.explosion(test.sa6ConnectionNode:getPosition().p, 100)
		--trigger.action.outText(test.sa6ConnectionNode:getLife(), 10)
	end
	if test.boom == 4 then
		trigger.action.outText("BLOWING UP SA-6 POWER STATION", 5)
		trigger.action.explosion(test.sa6PowerStation:getPosition().p, 100)
	--	trigger.action.outText(test.sa6Power:getLife(), 10)
	end
	if test.boom == 5 then
		trigger.action.outText("BLOWING UP COM CENTER POWER STATION 1", 5)
		trigger.action.explosion(test.powerStation1:getPosition().p, 100) 
	end
	if test.boom == 6 then
		trigger.action.outText("BLOWING UP COM CENTER 1", 5)
		trigger.action.explosion(test.commandCenter1:getPosition().p, 10000) 
	end
	if test.boom == 7 then
		trigger.action.outText("BLOWING UP COM CENTER POWER STATION 2", 5)
		trigger.action.explosion(test.powerStation2:getPosition().p, 100)
	--	trigger.action.outText(test.powerStation2:getLife(), 10)
	end
	if test.boom == 8 then
		trigger.action.outText("BLOWING UP COM CENTER 2", 5)
		trigger.action.explosion(test.commandCenter2:getPosition().p, 10000)
		--trigger.action.outText(test.commandCenter2:getLife(), 10)
	end
	test.boom = test.boom + 1
end
--mist.scheduleFunction(pickApartIADS, {test}, 20, 10)
end