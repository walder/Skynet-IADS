do
TestMooseA2ADispatcherConnector = {}

function TestMooseA2ADispatcherConnector:setUp()
	self.iads = SkynetIADS:create()
	self.iads:addEarlyWarningRadarsByPrefix("EW")
	self.iads:addSAMSitesByPrefix("SAM")
	self.connector = SkynetMooseA2ADispatcherConnector:create(self.iads)
end

function TestMooseA2ADispatcherConnector:tearDown()
	self.iads:deactivate()
end


function TestMooseA2ADispatcherConnector:testGetEarlyWarningRadarGroupNames()
	local ewRadarNames = self.connector:getEarlyWarningRadarGroupNames()
	
	---we iterate through the EW radars of the IADS, to check the table in the connector contains all the names of the EW radars
	local usableEWRadars = self.iads:getUsableEarlyWarningRadars()
	local numRadars = 0
	for i = 1, #ewRadarNames do
		local ewName = ewRadarNames[i]
		local ewFound = false
		for j = 1, #usableEWRadars do
			local ewNameInIADS = usableEWRadars[j]:getDCSName()
			if ewName == ewNameInIADS then
				ewFound = true
			end
		end
		lu.assertEquals(ewFound, true)
		numRadars = numRadars + 1
	end
	lu.assertEquals(numRadars, SKYNET_UNIT_TESTS_NUM_EW_SITES_RED)
end

function TestMooseA2ADispatcherConnector:testGetSAMSitesGroupNames()
	
	local samSiteGroupNames = self.connector:getSAMSiteGroupNames()
	
	---we iterate through the SAM sites of the IADS, to check the table in the connector contains all the names of the SAM sites
	local usableSAMSites = self.iads:getUsableSAMSites()
	local numSams = 0
	for i = 1, #samSiteGroupNames do
		local samSiteName = samSiteGroupNames[i]
		local samFound = false
		for j = 1, #usableSAMSites do
			local samNameInIADS = usableSAMSites[j]:getDCSName()
			if samSiteName == samNameInIADS then
				samFound = true
			end
		end
		lu.assertEquals(samFound, true)
		numSams = numSams + 1
	end
	lu.assertEquals(numSams, SKYNET_UNIT_TESTS_NUM_SAM_SITES_RED)
end

function TestMooseA2ADispatcherConnector:testUpdate()

	local mockMooseSetGroup = {}
	mockMooseSetGroup.connector = self.connector
	local numRemoveCalls = 0
	
	function mockMooseSetGroup:RemoveGroupsByName(groupNames)
		numRemoveCalls = numRemoveCalls + 1
		if	numRemoveCalls == 1 then
			lu.assertEquals(groupNames, self.connector.ewRadarGroupNames)
		end
		
		if numRemoveCalls == 2 then
			lu.assertEquals(groupNames, self.connector.samSiteGroupNames)
		end
	end
	
	local samGroups = {}
	function self.connector:getSAMSiteGroupNames()
		return samGroups
	end

	local ewGroups = {}
	function self.connector:getEarlyWarningRadarGroupNames()
		return ewGroups
	end
	
	local numAddCalls = 0
	function mockMooseSetGroup:AddGroupsByName(groupNames)
	
		if numAddCalls == 0 then
			lu.assertEquals(groupNames, samGroups)
		end
		
		if numAddCalls == 1 then
			lu.assertEquals(groupNames, ewGroups)
		end
		
		numAddCalls = numAddCalls + 1
	end
	
	local calledFilterStart = 0
	function mockMooseSetGroup:FilterStart()
		calledFilterStart = calledFilterStart + 1
	end
	
	self.connector:addMooseGroup(mockMooseSetGroup)
	self.connector:update()
	
	lu.assertEquals(numRemoveCalls, 2)
	lu.assertEquals(numAddCalls, 2)
	lu.assertEquals(calledFilterStart, 1)
end

end
