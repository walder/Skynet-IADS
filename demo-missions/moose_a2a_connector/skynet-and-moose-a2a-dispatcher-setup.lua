do


--Setup Syknet IADS:
redIADS = SkynetIADS:create('Enemy IADS')


local iadsDebug = redIADS:getDebugSettings()  
iadsDebug.IADSStatus = true
iadsDebug.contacts = true

--[[
iadsDebug.samWentDark = true

iadsDebug.radarWentLive = true
iadsDebug.jammerProbability = true
iadsDebug.addedEWRadar = true
iadsDebug.addedSAMSite = true
iadsDebug.warnings = true
iadsDebug.harmDefence = true
iadsDebug.samSiteStatusEnvOutput = true
iadsDebug.earlyWarningRadarStatusEnvOutput = true
--]]

redIADS:addSAMSitesByPrefix('SAM')

local power = StaticObject.getByName('power-source')
redIADS:addEarlyWarningRadarsByPrefix('EW')
redIADS:getEarlyWarningRadarByUnitName('EW-1'):addConnectionNode(power)

redIADS:activate()


-- Define a SET_GROUP object that builds a collection of groups that define the EWR network.
DetectionSetGroup = SET_GROUP:New()

-- add the MOOSE SET_GROUP to the Skynet IADS, from now on Skynet will update active radars that the MOOSE SET_GROUP can use for EW detection.
redIADS:addMooseSetGroup(DetectionSetGroup)

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

--test to see which groups are added and removed to the SET_GROUP at runtime by Skynet:
function outputNames()
	env.info("IADS Radar Groups added by Skynet:")
	env.info(DetectionSetGroup:GetObjectNames())
end

mist.scheduleFunction(outputNames, self, 1, 2)
--end test
end
