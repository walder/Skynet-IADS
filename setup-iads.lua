do

nevadaIADS = SkynetIADS:create()

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


end