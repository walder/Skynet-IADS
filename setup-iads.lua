do

---- Instanciate IADS
nevadaIADS = SkynetIADS:create()

local earlyWarningRadar = Unit.getByName('EWR')
local ewPower = StaticObject.getByName("EW Power Source")
local ewConnectionNode = StaticObject.getByName("EWR Connection Node")
nevadaIADS:addEarlyWarningRadar(earlyWarningRadar, ewPower, ewConnectionNode)

local powerSource = StaticObject.getByName("SA6-PowerSource")
local sa6Site2 = Group.getByName('SA6 Group2')
local connectionNode = StaticObject.getByName("Connection Node")
--nevadaIADS:addSamSite(sa6Site2, powerSource, connectionNode, SkynetIADSSamSite.AUTONOMOUS_STATE_DARK)

--local sa6Site = Group.getByName('SA6 Group')
--nevadaIADS:addSamSite(sa6Site)

--local sa2Site = Group.getByName('SA-2')
--nevadaIADS:addSamSite(sa2Site)

--local sa10 = Group.getByName('SA-10')
--nevadaIADS:addSamSite(sa10)

local sa11 = Group.getByName('SA-11')
nevadaIADS:addSamSite(sa11)

local commandCenter = StaticObject.getByName("Command Center")
nevadaIADS:addCommandCenter(commandCenter)

commandCenter = StaticObject.getByName("Command Center2")
nevadaIADS:addCommandCenter(commandCenter)

nevadaIADS:activate()	

end