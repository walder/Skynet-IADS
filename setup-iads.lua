do

---- Instanciate IADS

nevadaIADS = SkynetIADS:create()

local earlyWarningRadar = Unit.getByName('EWR')
nevadaIADS:addEarlyWarningRadar(earlyWarningRadar)

local sa6Site2 = Group.getByName('SA6 Group2')
nevadaIADS:addSamSite(sa6Site2)

local sa6Site = Group.getByName('SA6 Group')
nevadaIADS:addSamSite(sa6Site)

local sa10 = Group.getByName('SA-10')
nevadaIADS:addSamSite(sa10)

nevadaIADS:activate()	

createFalseTarget()

end