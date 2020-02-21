do
iranIADS = SkynetIADS:create()

---debug settings remove from here on if you do not wan't any output on what the IADS is doing
local iadsDebug = iranIADS:getDebugSettings()
iadsDebug.IADSStatus = true
iadsDebug.samWentDark = true
iadsDebug.contacts = true
iadsDebug.samWentLive = true
iadsDebug.noWorkingCommmandCenter = true
iadsDebug.ewRadarNoConnection = true
iadsDebug.samNoConnection = true
iadsDebug.jammerProbability = true
iadsDebug.addedEWRadar = true
---end remove debug ---

iranIADS:addEarlyWarningRadarsByPrefix('EW')
iranIADS:addSamSitesByPrefix('SAM')
iranIADS:addCommandCenter(StaticObject.getByName("Command Center"), StaticObject.getByName("Command Center Power"))

iranIADS:setOptionsForSamSite('SAM-SA-2', StaticObject.getByName('Ammo'), StaticObject.getByName('Ammo #002'))
iranIADS:setOptionsForEarlyWarningRadar('EW-west', StaticObject.getByName('Ammo'), StaticObject.getByName('Ammo #002'))
iranIADS:activate()	

local jammerSource = Unit.getByName("Player Hornet")
jammer = SkynetIADSJammer:create(jammerSource)
jammer:addIADS(iranIADS)
jammer:masterArmOn()
--jammer:disableFor('SA-2')
end