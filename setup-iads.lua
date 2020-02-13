do

nevadaIADS = SkynetIADS:create()

---debug settings remove here on if you do not wan't any output on what the IADS is doing
local iadsDebug = nevadaIADS:getDebugSettings()
iadsDebug.IADSStatus = true
iadsDebug.samWentDark = false
iadsDebug.contacts = false
iadsDebug.samWentLive = false
iadsDebug.noWorkingCommmandCenter = false
iadsDebug.ewRadarNoConnection = false
iadsDebug.samNoConnection = false
---end remove


local earlyWarningRadar = Unit.getByName('EWR')
local ewPower = StaticObject.getByName("EW Power Source")
local ewConnectionNode = StaticObject.getByName("EWR Connection Node")
nevadaIADS:addEarlyWarningRadar(earlyWarningRadar, ewPower, ewConnectionNode)


earlyWarningRadar = Unit.getByName('EWR2')
nevadaIADS:addEarlyWarningRadar(earlyWarningRadar)

local powerSource = StaticObject.getByName("SA6-PowerSource")
local sa6Site = Group.getByName('SA-6')
local connectionNode = StaticObject.getByName("SA-6 Connection Node")
nevadaIADS:addSamSite(sa6Site, powerSource, connectionNode, SkynetIADSSamSite.AUTONOMOUS_STATE_DARK)


local sa2Site = Group.getByName('SA-2')
nevadaIADS:addSamSite(sa2Site)

--local sa10 = Group.getByName('SA-10')
--nevadaIADS:addSamSite(sa10)

local sa11 = Group.getByName('SA-11')
nevadaIADS:addSamSite(sa11)

local commandCenter = StaticObject.getByName("Command Center")
nevadaIADS:addCommandCenter(commandCenter)

commandCenter = StaticObject.getByName("Command Center2")
local cc2PowerSource = StaticObject.getByName("Command Center2 Power Source")
nevadaIADS:addCommandCenter(commandCenter, cc2PowerSource)

nevadaIADS:activate()	
local jammerSource = Unit.getByName("Player Hornet")
jammer = SkynetIADSJammer:create(jammerSource)
jammer:addIADS(nevadaIADS)
jammer:musicOn()

end