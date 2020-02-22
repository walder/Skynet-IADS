do

iranIADS = SkynetIADS:create()

---debug settings remove from here on if you do not wan't any output on what the IADS is doing
local iadsDebug = iranIADS:getDebugSettings()
iadsDebug.IADSStatus = true
iadsDebug.samWentDark = true
iadsDebug.contacts = true
iadsDebug.radarWentLive = true
iadsDebug.noWorkingCommmandCenter = true
iadsDebug.ewRadarNoConnection = true
iadsDebug.samNoConnection = false
iadsDebug.jammerProbability = true
iadsDebug.addedEWRadar = false
iadsDebug.ewRadarNoPower = true
---end remove debug ---

iranIADS:addEarlyWarningRadarsByPrefix('EW')
iranIADS:addSamSitesByPrefix('SAM')

local c21 = StaticObject.getByName('C2-1')
iranIADS:addCommandCenter(c21)

local c22 = StaticObject.getByName('C2-2')
iranIADS:addCommandCenter(c22)

local c23 = StaticObject.getByName('C2-3')
iranIADS:addCommandCenter(c23)

iranIADS:activate()

local jammerSource = Unit.getByName("Pilot #001")
jammer = SkynetIADSJammer:create(jammerSource)
jammer:addIADS(iranIADS)
jammer:masterArmOn()
--jammer:disableFor('SA-2')


end