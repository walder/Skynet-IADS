do


local units = Group.getByName('SAM-SA-20B'):getUnits()
for i = 1, #units do
	local unit = units[i]
	env.info(unit:getTypeName())
end


lu.LuaUnit.run()

--activate IADS 

redIADS = SkynetIADS:create("Red IADS")
local iadsDebug = redIADS:getDebugSettings()
iadsDebug.IADSStatus = true
iadsDebug.radarWentDark = true
iadsDebug.contacts = true
iadsDebug.radarWentLive = true
iadsDebug.jammerProbability = true
iadsDebug.addedEWRadar = true
iadsDebug.addedSAMSite = true
iadsDebug.harmDefence = true
iadsDebug.commandCenterStatusEnvOutput = true
iadsDebug.samSiteStatusEnvOutput = true

redIADS:addSAMSitesByPrefix('SAM')
redIADS:activate()
end