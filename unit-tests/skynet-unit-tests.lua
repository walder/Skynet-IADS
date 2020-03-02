do

iranIADS = SkynetIADS:create()

---debug settings remove from here on if you do not wan't any output on what the IADS is doing
local iadsDebug = iranIADS:getDebugSettings()
iadsDebug.IADSStatus = true
iadsDebug.samWentDark = true
iadsDebug.contacts = false
iadsDebug.radarWentLive = true
iadsDebug.noWorkingCommmandCenter = false
iadsDebug.ewRadarNoConnection = false
iadsDebug.samNoConnection = false
iadsDebug.jammerProbability = true
iadsDebug.addedEWRadar = false
iadsDebug.ewRadarNoPower = false
iadsDebug.addedSAMSite = false
---end remove debug ---
iranIADS:addEarlyWarningRadarsByPrefix('EW')
iranIADS:addSamSitesByPrefix('SAM')

powerStation1 = StaticObject.getByName("Command Center Power")
powerStation2 = StaticObject.getByName("Command Center Power2")
commandCenter1 = StaticObject.getByName("Command Center")
commandCenter2 = StaticObject.getByName("Command Center2")
iranIADS:addCommandCenter(commandCenter1, powerStation1)
iranIADS:addCommandCenter(commandCenter2, powerStation2)

sa6PowerStation = StaticObject.getByName('SA-6 Power')
sa6ConnectionNode = StaticObject.getByName('SA-6 Connection Node')
iranIADS:setOptionsForSamSite('SAM-SA-6', sa6PowerStation, sa6ConnectionNode, false, nil, 150)

sa6ConnectionNode2 = StaticObject.getByName('SA-6-2 Connection Node')
iranIADS:setOptionsForSamSite('SAM-SA-6-2', nil, sa6ConnectionNode2, false, SkynetIADSSamSite.AUTONOMOUS_STATE_DARK)


iranIADS:setOptionsForSamSite('SAM-SA-10', nil, nil, true)

ewWest2PowerSource = StaticObject.getByName('EW-west Power Source')
ewWest2ConnectionNode = StaticObject.getByName('EW-west Connection Node')
iranIADS:setOptionsForEarlyWarningRadar('EW-west', ewWest2PowerSource, ewWest2ConnectionNode)

iranIADS:activate()	

jammerSource = Unit.getByName("Growler")
jammer = SkynetIADSJammer:create(jammerSource)
jammer:addIADS(iranIADS)
--jammer:masterArmOn()
--jammer:disableFor('SA-2')


-- IADS Test code from here onwards:
--[[
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
--]]

---IADS Unit Tests
TestIADS = {}

function TestIADS:test1NumberOfSamSites()
	lu.assertEquals(#iranIADS:getSamSites(), 11)
end

function TestIADS:test3NumberOfEWRadars()
	lu.assertEquals(#iranIADS:getEarlyWarningRadars(), 9)
end

function TestIADS:test4SAMSiteSA6LostConnectionNodeAutonomusStateDCSAI()
	lu.assertEquals(#iranIADS:getUsableSamSites(), 11)
	trigger.action.explosion(sa6ConnectionNode:getPosition().p, 100)
	lu.assertEquals(#iranIADS:getUsableSamSites(), 10)
	--simulate update cycle of IADS
	iranIADS.evaluateContacts(iranIADS)
	iranIADS.evaluateContacts(iranIADS)
	lu.assertEquals(#iranIADS:getUsableSamSites(), 10)
	local samSite = iranIADS:getSamSiteByGroupName('SAM-SA-6')
	--simulate update cycle of IADS
	iranIADS.evaluateContacts(iranIADS)
	iranIADS.evaluateContacts(iranIADS)
	lu.assertEquals(samSite:isActive(), true)
end

function TestIADS:test5SAMSiteSA62ConnectionNodeLostAutonomusStateDark()
	local samSite = iranIADS:getSamSiteByGroupName('SAM-SA-6-2')
	lu.assertEquals(samSite:hasActiveConnectionNode(), true)
	trigger.action.explosion(sa6ConnectionNode2:getPosition().p, 100)
	lu.assertEquals(samSite:hasActiveConnectionNode(), false)
	lu.assertEquals(samSite:isActive(), false)
	--simulate update cycle of IADS
	iranIADS.evaluateContacts(iranIADS)
	iranIADS.evaluateContacts(iranIADS)
	lu.assertEquals(samSite:isActive(), false)
end

function TestIADS:test6CommandCenterAliveAndThenDead()
	lu.assertEquals(#iranIADS:getCommandCenters(), 2)
	lu.assertEquals(iranIADS:isCommandCenterAlive(), true)
	trigger.action.explosion(commandCenter1:getPosition().p, 10000)
	trigger.action.explosion(commandCenter2:getPosition().p, 10000)
	lu.assertEquals(#iranIADS:getCommandCenters(), 2)
	lu.assertEquals(iranIADS:isCommandCenterAlive(), false)
end

lu.LuaUnit.run()

end