do


--Setup Syknet IADS:
redIADS = SkynetIADS:create('Enemy IADS')


local iadsDebug = redIADS:getDebugSettings()  
iadsDebug.IADSStatus = true
iadsDebug.contacts = true

--[[
iadsDebug.samWentDark = true

iadsDebug.radarWentLive = true
iadsDebug.ewRadarNoConnection = true
iadsDebug.samNoConnection = true
iadsDebug.jammerProbability = true
iadsDebug.addedEWRadar = true
iadsDebug.hasNoPower = true
iadsDebug.addedSAMSite = true
iadsDebug.warnings = true
iadsDebug.harmDefence = true
iadsDebug.samSiteStatusEnvOutput = true
iadsDebug.earlyWarningRadarStatusEnvOutput = true
--]]

redIADS:addSAMSitesByPrefix('SAM')
redIADS:addEarlyWarningRadarsByPrefix('EW')

redIADS:activate()


-- Define a SET_GROUP object that builds a collection of groups that define the EWR network.
-- Here we build the network with all the groups that have a name starting with DF CCCP AWACS and DF CCCP EWR.
DetectionSetGroup = SET_GROUP:New()

-- add the detection group to the Skynet IADS:
redIADS:addMooseDispatcher(DetectionSetGroup)

--DetectionSetGroup:AddGroupsByName('EW-1')
--DetectionSetGroup:FilterStart()

-- Setup the detection and group targets to a 30km range!
Detection = DETECTION_AREAS:New( DetectionSetGroup, 30000 )

-- Setup the A2A dispatcher, and initialize it.
A2ADispatcher = AI_A2A_DISPATCHER:New( Detection )

-- Set 100km as the radius to engage any target by airborne friendlies.
A2ADispatcher:SetEngageRadius() -- 100000 is the default value.

-- Set 200km as the radius to ground control intercept.
A2ADispatcher:SetGciRadius() -- 200000 is the default value.

CCCPBorderZone = ZONE_POLYGON:New( "RED-BORDER", GROUP:FindByName( "RED-BORDER" ) )
A2ADispatcher:SetBorderZone( CCCPBorderZone )

A2ADispatcher:SetSquadron( "Kutaisi", AIRBASE.Caucasus.Kutaisi, { "Squadron red SU-27" }, 2 )
A2ADispatcher:SetSquadronGrouping( "Kutaisi", 2 )
A2ADispatcher:SetSquadronGci( "Kutaisi", 900, 1200 )
A2ADispatcher:SetTacticalDisplay(true)
A2ADispatcher:Start()
end
