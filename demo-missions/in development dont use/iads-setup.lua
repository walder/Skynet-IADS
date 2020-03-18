do

rusIADS = SkynetIADS:create()

local iadsDebug = rusIADS:getDebugSettings()
iadsDebug.IADSStatus = true
iadsDebug.samWentDark = true
iadsDebug.contacts = true
iadsDebug.radarWentLive = true
iadsDebug.noWorkingCommmandCenter = true
iadsDebug.ewRadarNoConnection = true
iadsDebug.samNoConnection = true
iadsDebug.jammerProbability = true
iadsDebug.addedEWRadar = true
iadsDebug.addedSAMSite = true
iadsDebug.hasNoPower = true
iadsDebug.warnings = true
iadsDebug.harmDefence = true

rusIADS:addEarlyWarningRadarsByPrefix('RUS_EWR')
rusIADS:addSAMSitesByPrefix('RUS_SAM')

rusIADS:getSAMSitesByNatoName('SA-10'):setActAsEW(true)
--rusIADS:getSAMSitesByNatoName('SA-3'):setActAsEW(true)

rusIADS:addRadioMenu()

rusIADS:activate()

end