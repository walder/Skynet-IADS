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


iranIADS:setOptionsForSamSite('SAM-SA-10', nil, nil, true)


ewWest2ConnectionNode = StaticObject.getByName('EW-west Connection Node')

iranIADS:activate()	

jammerSource = Unit.getByName("Growler")
jammer = SkynetIADSJammer:create(jammerSource)
jammer:addIADS(iranIADS)
--jammer:masterArmOn()
--jammer:disableFor('SA-2')

---IADS Unit Tests
TestIADS = {}

function TestIADS:setUp()
	iranIADS.commandCenters = {}
end

function TestIADS:test1NumberOfSamSitesAndEWRadars()
	lu.assertEquals(#iranIADS:getSamSites(), 0)
	lu.assertEquals(#iranIADS:getEarlyWarningRadars(), 0)
	iranIADS:addEarlyWarningRadarsByPrefix('EW')
	iranIADS:addSamSitesByPrefix('SAM')
	lu.assertEquals(#iranIADS:getSamSites(), 11)
	lu.assertEquals(#iranIADS:getEarlyWarningRadars(), 9)
end

function TestIADS:test2EarlyWarningRadarLoosesPower()

	ewWest2PowerSource = StaticObject.getByName('EW-west Power Source')
	iranIADS:setOptionsForEarlyWarningRadar('EW-west', ewWest2PowerSource)
	
	local ewRadar = iranIADS:getEarlyWarningRadarByUnitName('EW-west')
	lu.assertEquals(ewRadar:hasWorkingPowerSource(), true)
	trigger.action.explosion(ewWest2PowerSource:getPosition().p, 100)
	lu.assertEquals(ewRadar:hasWorkingPowerSource(), false)
	--simulate update cycle of IADS
	iranIADS.evaluateContacts(iranIADS)
	lu.assertEquals(ewRadar:hasWorkingPowerSource(), false)
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
	lu.assertEquals(#iranIADS:getUsableSamSites(), 10)
	local samSite = iranIADS:getSamSiteByGroupName('SAM-SA-6')
	lu.assertEquals(samSite:isActive(), true)
	--simulate update cycle of IADS
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
	lu.assertEquals(samSite:isActive(), false)
end

function TestIADS:test6OneCommandCenterIsDestroyed()
	local powerStation1 = StaticObject.getByName("Command Center Power")
	local commandCenter1 = StaticObject.getByName("Command Center")
	
	lu.assertEquals(#iranIADS:getCommandCenters(), 0)
	iranIADS:addCommandCenter(commandCenter1, powerStation1)
	lu.assertEquals(#iranIADS:getCommandCenters(), 1)
	lu.assertEquals(iranIADS:isCommandCenterUsable(), true)
	trigger.action.explosion(commandCenter1:getPosition().p, 10000)
	lu.assertEquals(#iranIADS:getCommandCenters(), 1)
	lu.assertEquals(iranIADS:isCommandCenterUsable(), false)
end

function TestIADS:test7OneCommandCenterLoosesPower()
	local commandCenter2Power = StaticObject.getByName("Command Center2 Power")
	local commandCenter2 = StaticObject.getByName("Command Center2")
	lu.assertEquals(#iranIADS:getCommandCenters(), 0)
	iranIADS:addCommandCenter(commandCenter2, commandCenter2Power)
	lu.assertEquals(#iranIADS:getCommandCenters(), 1)
	trigger.action.explosion(commandCenter2Power:getPosition().p, 10000)
	lu.assertEquals(#iranIADS:getCommandCenters(), 1)
	lu.assertEquals(iranIADS:isCommandCenterUsable(), false)
end

TestSamSites = {}

lu.LuaUnit.run()

end