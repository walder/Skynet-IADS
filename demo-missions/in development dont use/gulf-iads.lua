do

iranIADS = SkynetIADS:create()

---debug settings remove from here on if you do not wan't any output on what the IADS is doing
local iadsDebug = iranIADS:getDebugSettings()
iadsDebug.IADSStatus = true
iadsDebug.samWentDark = false
iadsDebug.contacts = true
iadsDebug.radarWentLive = false
iadsDebug.noWorkingCommmandCenter = true
iadsDebug.ewRadarNoConnection = true
iadsDebug.samNoConnection = false
iadsDebug.jammerProbability = true
iadsDebug.addedEWRadar = false
iadsDebug.ewRadarNoPower = true
---end remove debug ---

---load red assets:
--[[
for groupName, groupData in pairs(mist.DBs.groupsByName) do
		local group = Group.getByName(groupName) 
		if group and group:getCoalition() == coalition.side.RED and group:getName() ~= 'EW-RADAR' then
			iranIADS:addSamSite(groupName, nil, nil)
		end
end
--]]
iranIADS:addSamSite('Bandar Abbas Hawk Site')
iranIADS:addEarlyWarningRadar('EW-Radar')

iranIADS:activate()

end