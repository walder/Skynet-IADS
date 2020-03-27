do

iranIADS = SkynetIADS:create()

---debug settings remove from here on if you do not wan't any output on what the IADS is doing by default
local iadsDebug = iranIADS:getDebugSettings()
iadsDebug.IADSStatus = false
iadsDebug.samWentDark = false
iadsDebug.contacts = false
iadsDebug.radarWentLive = false
iadsDebug.noWorkingCommmandCenter = false
iadsDebug.ewRadarNoConnection = false
iadsDebug.samNoConnection = false
iadsDebug.jammerProbability = false
iadsDebug.addedEWRadar = false
iadsDebug.hasNoPower = false
iadsDebug.harmDefence = false
---end remove debug ---

--add all units with unit name beginning with 'EW' to the IADS:
iranIADS:addEarlyWarningRadarsByPrefix('EW-')

--add all groups begining with group name 'SAM' to the IADS:
iranIADS:addSAMSitesByPrefix('SAM-')


iranIADS:getSAMSiteByGroupName('SAM-SA-6-bandar-lengeh'):setHARMDetectionChance(100)

iranIADS:getSAMSiteByGroupName('SAM-SA-3-queshim-island'):setHARMDetectionChance(100)

iranIADS:getEarlyWarningRadarByUnitName('EW-Larak'):setHARMDetectionChance(80):addPointDefence(iranIADS:getSAMSiteByGroupName('SAM-SA-15-EW-Protection')):setIgnoreHARMSWhilePointDefencesHaveAmmo(true)

--activate the radio menu to toggle IADS Status output
iranIADS:addRadioMenu()

-- activate the IADS
iranIADS:activate()	

end