do
TestMooseA2ADispatcherConnector = {}

function TestMooseA2ADispatcherConnector:setUp()
	self.iads = SkynetIADS:create()
	self.connector = SkynetMooseA2ADispatcherConnector:create()
end

function TestMooseA2ADispatcherConnector:tearDown()
	self.iads:deactivate()
end

--[[	
	local ewRadarNames = self.connector:getEarlyWarningRadarGroupNames()
	lu.assertEquals(#ewRadarNames, 1)
	lu.assertEquals(ewRadarNames[1], 'EW-west-group-name')
	
	local samSiteNames = self.connector:getSAMSiteGroupNames()
	lu.assertEquals(#samSiteNames, 1)
	
	function samSite:hasWorkingPowerSource()
		return false
	end
	
	local samSiteNames = self.connector:getSAMSiteGroupNames()
	lu.assertEquals(#samSiteNames, 0)
--]]

--[[
	
	local mockSetGroup = {}
	
	function mockSetGroup:AddGroupsByName(name)
		lu.assertEquals(name, 'EW-west')
	end
	
	self.connector:setMooseGroup(mockSetGroup)
	self.connector:addIADS(self.iads)
	self.connector:update()
--]]
end
