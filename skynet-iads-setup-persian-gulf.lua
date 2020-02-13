do

iranIADS = SkynetIADS:create()

---debug settings remove here on if you do not wan't any output on what the IADS is doing
local iadsDebug = iranIADS:getDebugSettings()
iadsDebug.IADSStatus = true
iadsDebug.samWentDark = true
iadsDebug.contacts = true
iadsDebug.samWentLive = true
iadsDebug.noWorkingCommmandCenter = true
iadsDebug.ewRadarNoConnection = true
iadsDebug.samNoConnection = true
---end remove

iranIADS:addEarlyWarningRadar(Unit.getByName('EW west'))
iranIADS:addEarlyWarningRadar(Unit.getByName('EW east'))
iranIADS:addEarlyWarningRadar(Unit.getByName('EW center'))
iranIADS:addEarlyWarningRadar(Unit.getByName('EW center2'))
iranIADS:addEarlyWarningRadar(Unit.getByName('EW center3'))

iranIADS:addSamSite(Group.getByName('SA-2'))
iranIADS:addSamSite(Group.getByName('SA-3'))
iranIADS:addSamSite(Group.getByName('SA-6'))
iranIADS:addSamSite(Group.getByName('SA-8'))



--local sa10 = Group.getByName('SA-10')
--nevadaIADS:addSamSite(sa10)

--local sa11 = Group.getByName('SA-11')
--nevadaIADS:addSamSite(sa11)

--local commandCenter = StaticObject.getByName("Command Center")
--nevadaIADS:addCommandCenter(commandCenter)

--commandCenter = StaticObject.getByName("Command Center2")
--local cc2PowerSource = StaticObject.getByName("Command Center2 Power Source")
--nevadaIADS:addCommandCenter(commandCenter, cc2PowerSource)

iranIADS:activate()	

--[[
local jammerSource = Unit.getByName("Player Hornet")
jammer = SkynetIADSJammer:create(jammerSource)
jammer:addIADS(nevadaIADS)
jammer:musicOn()
--]]


end