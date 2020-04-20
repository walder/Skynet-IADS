do

SkynetMooseA2ADispatcherConnector = {}

function SkynetMooseA2ADispatcherConnector:create(dcsObject)
	local instance = {}
	setmetatable(instance, self)
	self.__index = self
	instance.dcsObject = dcsObject
	instance.iadsCollection = {}
	instance.mooseGroups = {}
	instance.ewRadarGroupNames = {}
	instance.samSiteGroupNames = {}
	return instance
end

function SkynetMooseA2ADispatcherConnector:addIADS(iads)
	table.insert(self.iadsCollection, iads)
end

function SkynetMooseA2ADispatcherConnector:addMooseGroup(mooseGroup)
	table.insert(self.mooseGroups, moooseGroup)
end

function SkynetMooseA2ADispatcherConnector:getEarlyWarningRadarGroupNames()
	self.ewRadarGroupNames = {}
	for i = 1, #self.iadsCollection do
		local ewRadars = self.iadsCollection[i]:getUsableEarlyWarningRadars()
		for j = 1, #ewRadars do
			local ewRadar = ewRadars[j]
			table.insert(self.ewRadarGroupNames, ewRadar:getDCSRepresentation():getGroup():getName())
		end
	end
	return self.ewRadarGroupNames
end

function SkynetMooseA2ADispatcherConnector:getSAMSiteGroupNames()
	self.samSiteGroupNames = {}
	for i = 1, #self.iadsCollection do
		local samSites = self.iadsCollection[i]:getUsableSAMSites()
		for j = 1, #samSites do
			local samSite = samSites[j]
			table.insert(self.samSiteGroupNames, samSite:getDCSRepresentation():getName())
		end
	end
	return self.samSiteGroupNames
end

function SkynetMooseA2ADispatcherConnector:update()
	
	--remove previously set group names:
	for i = 1, #self.mooseGroups do
		mooseGroup = self.mooseGroups[i]
		mooseGroup:RemoveGroupsByName(self.ewRadarGroupNames)
		mooseGroup:RemoveGroupsByName(self.samSiteGroupNames)
	end
	
	--add current group names:
	for j = 1, #self.mooseGroups do
		mooseGroup = self.mooseGroups[i]
	
	end
end

end
