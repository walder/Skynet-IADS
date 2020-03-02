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

---IADS Unit Tests
TestIADS = {}

function TestIADS:test1NumberOfSamSites()
	lu.assertEquals(#iranIADS:getSamSites(), 11)
end

function TestIADS:test3NumberOfEWRadars()
	lu.assertEquals(#iranIADS:getEarlyWarningRadars(), 9)
end

function TestIADS:test4SAMSiteSA6LostConnectionNodeAutonomusStateDCSAI()

	local sa6PowerStation = StaticObject.getByName('SA-6 Power')
	local sa6ConnectionNode = StaticObject.getByName('SA-6 Connection Node')
	iranIADS:setOptionsForSamSite('SAM-SA-6', sa6PowerStation, sa6ConnectionNode, false, nil, 150)

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

	local sa6ConnectionNode2 = StaticObject.getByName('SA-6-2 Connection Node')
	iranIADS:setOptionsForSamSite('SAM-SA-6-2', nil, sa6ConnectionNode2, false, SkynetIADSSamSite.AUTONOMOUS_STATE_DARK)

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

	local powerStation1 = StaticObject.getByName("Command Center Power")
	local powerStation2 = StaticObject.getByName("Command Center Power2")
	local commandCenter1 = StaticObject.getByName("Command Center")
	local commandCenter2 = StaticObject.getByName("Command Center2")
	iranIADS:addCommandCenter(commandCenter1, powerStation1)
	iranIADS:addCommandCenter(commandCenter2, powerStation2)

	lu.assertEquals(#iranIADS:getCommandCenters(), 2)
	lu.assertEquals(iranIADS:isCommandCenterAlive(), true)
	trigger.action.explosion(commandCenter1:getPosition().p, 10000)
	trigger.action.explosion(commandCenter2:getPosition().p, 10000)
	lu.assertEquals(#iranIADS:getCommandCenters(), 2)
	lu.assertEquals(iranIADS:isCommandCenterAlive(), false)
end

lu.LuaUnit.run()

end