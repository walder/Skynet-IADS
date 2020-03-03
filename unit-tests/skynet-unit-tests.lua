do


--[[
---debug settings remove from here on if you do not wan't any output on what the IADS is doing

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
--]]

--iranIADS:setOptionsForSamSite('SAM-SA-10', nil, nil, true)
--ewWest2ConnectionNode = StaticObject.getByName('EW-west Connection Node')
--iranIADS:activate()	

--jammerSource = Unit.getByName("Growler")
--jammer = SkynetIADSJammer:create(jammerSource)
--jammer:addIADS(iranIADS)
--jammer:masterArmOn()
--jammer:disableFor('SA-2')

---IADS Unit Tests
TestIADS = {}

function TestIADS:setUp()
	self.iranIADS = SkynetIADS:create()
	self.iranIADS:addEarlyWarningRadarsByPrefix('EW')
	self.iranIADS:addSamSitesByPrefix('SAM')
	local iadsDebug = self.iranIADS:getDebugSettings()
	iadsDebug.IADSStatus = true
end

function TestIADS:testNumberOfSamSitesAndEWRadars()
	self.iranIADS = SkynetIADS:create()
	lu.assertEquals(#self.iranIADS:getSamSites(), 0)
	lu.assertEquals(#self.iranIADS:getEarlyWarningRadars(), 0)
	self.iranIADS:addEarlyWarningRadarsByPrefix('EW')
	self.iranIADS:addSamSitesByPrefix('SAM')
	lu.assertEquals(#self.iranIADS:getSamSites(), 11)
	lu.assertEquals(#self.iranIADS:getEarlyWarningRadars(), 9)
	local ewRadar = self.iranIADS:getEarlyWarningRadarByUnitName('EW-west')
	lu.assertEquals(ewRadar:hasWorkingPowerSource(), true)
end

function TestIADS:testEarlyWarningRadarHasWorkingPowerSourceByDefault()
	local ewRadar = self.iranIADS:getEarlyWarningRadarByUnitName('EW-west')
	lu.assertEquals(ewRadar:hasWorkingPowerSource(), true)
end

function TestIADS:testEarlyWarningRadarLoosesPower()
	ewWest2PowerSource = StaticObject.getByName('EW-west Power Source')
	self.iranIADS:setOptionsForEarlyWarningRadar('EW-west', ewWest2PowerSource)
	local ewRadar = self.iranIADS:getEarlyWarningRadarByUnitName('EW-west')
	lu.assertEquals(ewRadar:hasWorkingPowerSource(), true)
	trigger.action.explosion(ewWest2PowerSource:getPosition().p, 100)
	lu.assertEquals(ewRadar:hasWorkingPowerSource(), false)
	--simulate update cycle of IADS
	self.iranIADS.evaluateContacts(self.iranIADS)
	lu.assertEquals(ewRadar:hasWorkingPowerSource(), false)
end

function TestIADS:testSAMSiteSA6LostConnectionNodeAutonomusStateDCSAI()
	local sa6PowerStation = StaticObject.getByName('SA-6 Power')
	local sa6ConnectionNode = StaticObject.getByName('SA-6 Connection Node')
	self.iranIADS:setOptionsForSamSite('SAM-SA-6', sa6PowerStation, sa6ConnectionNode, false, nil)

	lu.assertEquals(#self.iranIADS:getSamSites(), 11)
	lu.assertEquals(#self.iranIADS:getUsableSamSites(), 11)
	trigger.action.explosion(sa6ConnectionNode:getPosition().p, 100)
	lu.assertEquals(#self.iranIADS:getUsableSamSites(), 10)
	--simulate update cycle of IADS
	self.iranIADS.evaluateContacts(self.iranIADS)
	lu.assertEquals(#self.iranIADS:getUsableSamSites(), 10)
	lu.assertEquals(#self.iranIADS:getSamSites(), 11)
	local samSite = self.iranIADS:getSamSiteByGroupName('SAM-SA-6')
	lu.assertEquals(samSite:isActive(), true)
	--simulate update cycle of IADS
	self.iranIADS.evaluateContacts(self.iranIADS)
	lu.assertEquals(samSite:isActive(), true)
end

function TestIADS:testSAMSiteSA62ConnectionNodeLostAutonomusStateDark()
	local sa6ConnectionNode2 = StaticObject.getByName('SA-6-2 Connection Node')
	local samSite = self.iranIADS:getSamSiteByGroupName('SAM-SA-6-2')
	lu.assertEquals(samSite:isActive(), false)
	self.iranIADS:setOptionsForSamSite('SAM-SA-6-2', nil, sa6ConnectionNode2, false, SkynetIADSSamSite.AUTONOMOUS_STATE_DARK)
	lu.assertEquals(samSite:hasActiveConnectionNode(), true)
	trigger.action.explosion(sa6ConnectionNode2:getPosition().p, 100)
	lu.assertEquals(samSite:hasActiveConnectionNode(), false)
	lu.assertEquals(samSite:isActive(), false)
	--simulate update cycle of IADS
	self.iranIADS.evaluateContacts(self.iranIADS)
	lu.assertEquals(samSite:isActive(), false)
end

function TestIADS:testOneCommandCenterIsDestroyed()
	local powerStation1 = StaticObject.getByName("Command Center Power")
	local commandCenter1 = StaticObject.getByName("Command Center")	
	lu.assertEquals(#self.iranIADS:getCommandCenters(), 0)
	self.iranIADS:addCommandCenter(commandCenter1, powerStation1)
	lu.assertEquals(#self.iranIADS:getCommandCenters(), 1)
	lu.assertEquals(self.iranIADS:isCommandCenterUsable(), true)
	trigger.action.explosion(commandCenter1:getPosition().p, 10000)
	lu.assertEquals(#self.iranIADS:getCommandCenters(), 1)
	lu.assertEquals(self.iranIADS:isCommandCenterUsable(), false)
end

function TestIADS:testSetSamSitesToAutonomous()
	local samSiteDark = self.iranIADS:getSamSiteByGroupName('SAM-SA-6')
	local samSiteActive = self.iranIADS:getSamSiteByGroupName('SAM-SA-6-2')
	lu.assertEquals(samSiteDark:isActive(), false)
	lu.assertEquals(samSiteActive:isActive(), false)
	self.iranIADS:setOptionsForSamSite('SAM-SA-6', nil, nil, false, SkynetIADSSamSite.AUTONOMOUS_STATE_DARK)
	self.iranIADS:setOptionsForSamSite('SAM-SA-6-2', nil, nil, false, SkynetIADSSamSite.AUTONOMOUS_STATE_DCS_AI)
	self.iranIADS:setSamSitesToAutonomousMode()
	lu.assertEquals(samSiteDark:isActive(), false)
	lu.assertEquals(samSiteActive:isActive(), true)
	--simulate update cycle of IADS
	self.iranIADS.evaluateContacts(self.iranIADS)
	lu.assertEquals(samSiteDark:isActive(), false)
	lu.assertEquals(samSiteActive:isActive(), true)
end

function TestIADS:testOneCommandCenterLoosesPower()
	local commandCenter2Power = StaticObject.getByName("Command Center2 Power")
	local commandCenter2 = StaticObject.getByName("Command Center2")
	lu.assertEquals(#self.iranIADS:getCommandCenters(), 0)
	lu.assertEquals(self.iranIADS:isCommandCenterUsable(), true)
	self.iranIADS:addCommandCenter(commandCenter2, commandCenter2Power)
	lu.assertEquals(#self.iranIADS:getCommandCenters(), 1)
	lu.assertEquals(self.iranIADS:isCommandCenterUsable(), true)
	trigger.action.explosion(commandCenter2Power:getPosition().p, 10000)
	lu.assertEquals(#self.iranIADS:getCommandCenters(), 1)
	lu.assertEquals(self.iranIADS:isCommandCenterUsable(), false)
end

function TestIADS:testMergeContacts()
	local radarContact = {}
	radarContact.object = Unit.getByName("Player Hornet")
	local contact = SkynetIADSContact:create(radarContact)
	lu.assertEquals(#self.iranIADS:getContacts(), 0)
	self.iranIADS:mergeContact(contact)
	lu.assertEquals(#self.iranIADS:getContacts(), 1)
	
	local radarContact2 = {}
	radarContact2.object = Unit.getByName("Player Hornet")
	local contact2 = SkynetIADSContact:create(radarContact2)
	self.iranIADS:mergeContact(contact2)
	lu.assertEquals(#self.iranIADS:getContacts(), 1)
	
	local radarContact3 = {}
	radarContact3.object = Unit.getByName("Harrier Pilot")
	local contact3 = SkynetIADSContact:create(radarContact3)
	self.iranIADS:mergeContact(contact3)
	lu.assertEquals(#self.iranIADS:getContacts(), 2)
	
end

TestSamSites = {}

lu.LuaUnit.run()

iranIADS = SkynetIADS:create()
iranIADS:addEarlyWarningRadarsByPrefix('EW')
iranIADS:addSamSitesByPrefix('SAM')
local iadsDebug = iranIADS:getDebugSettings()
iadsDebug.IADSStatus = true
iranIADS:activate()

end