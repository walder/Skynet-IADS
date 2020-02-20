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
---end remove debug ---


iranIADS:addEarlyWarningRadarsByPrefix('EW')
iranIADS:addSamSitesByPrefix('SAM')
iranIADS:addCommandCenter(StaticObject.getByName("Command Center"), StaticObject.getByName("Command Center Power"))
iranIADS:activate()	



local jammerSource = Unit.getByName("Player Hornet")
jammer = SkynetIADSJammer:create(jammerSource)
jammer:addIADS(iranIADS)
jammer:masterArmOn()
--jammer:disableFor('SA-2')

--[[
iranIADS:addEarlyWarningRadar('EW-west')
iranIADS:addEarlyWarningRadar('EW-west2')
iranIADS:addEarlyWarningRadar('EW-east')
iranIADS:addEarlyWarningRadar('EW-east2')
iranIADS:addEarlyWarningRadar('EW-center')
iranIADS:addEarlyWarningRadar('EW-center2')
iranIADS:addEarlyWarningRadar('EW-center3')
--]]

--[[

iranIADS:addSamSite('SAM-SA-3')
iranIADS:addSamSite('SAM-SA-2')
iranIADS:addSamSite('SAM-SA-6')
iranIADS:addSamSite('SAM-SA-8')
iranIADS:addSamSite('SAM-SA-10')
iranIADS:addSamSite('SAM-SA-11')
iranIADS:addSamSite('SAM-SA-13')
iranIADS:addSamSite('SAM-SA-15')
iranIADS:addSamSite('SAM-SA-19')
iranIADS:addSamSite('SAM-Shilka')
--]]



--local commandCenter = StaticObject.getByName("Command Center")
--nevadaIADS:addCommandCenter(commandCenter)

--commandCenter = StaticObject.getByName("Command Center2")
--local cc2PowerSource = StaticObject.getByName("Command Center2 Power Source")
--nevadaIADS:addCommandCenter(commandCenter, cc2PowerSource)
end