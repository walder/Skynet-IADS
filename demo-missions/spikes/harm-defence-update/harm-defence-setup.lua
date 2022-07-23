do
--create an instance of the IADS
redIADS = SkynetIADS:create('CAUCASUS')

---debug settings remove from here on if you do not wan't any output on what the IADS is doing by default
local iadsDebug = redIADS:getDebugSettings()
iadsDebug.IADSStatus = true
iadsDebug.radarWentDark = true
iadsDebug.contacts = true
iadsDebug.radarWentLive = true
iadsDebug.noWorkingCommmandCenter = false
iadsDebug.ewRadarNoConnection = false
iadsDebug.samNoConnection = false
iadsDebug.jammerProbability = true
iadsDebug.addedEWRadar = false
iadsDebug.hasNoPower = false
iadsDebug.harmDefence = true
iadsDebug.samSiteStatusEnvOutput = true
iadsDebug.earlyWarningRadarStatusEnvOutput = true
iadsDebug.commandCenterStatusEnvOutput = true
---end remove debug ---

--add all units with unit name beginning with 'EW' to the IADS:
redIADS:addEarlyWarningRadarsByPrefix('EW')

--add all groups begining with group name 'SAM' to the IADS:
redIADS:addSAMSitesByPrefix('SAM'):setHARMDetectionChance(100)

redIADS:getSAMSiteByGroupName('SAM-SA-10'):addPointDefence(redIADS:getSAMSiteByGroupName('SAM-SA-15')):setCanEngageAirWeapons(false)

--activate the radio menu to toggle IADS Status output
redIADS:addRadioMenu()

-- activate the IADS
redIADS:activate()	

end