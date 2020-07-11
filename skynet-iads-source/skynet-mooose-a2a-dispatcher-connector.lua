do

SkynetMooseA2ADispatcherConnector = {}

function SkynetMooseA2ADispatcherConnector:create(iads)
	local instance = {}
	setmetatable(instance, self)
	self.__index = self
	instance.iadsCollection = {}
	instance.mooseGroups = {}
	instance.ewRadarGroupNames = {}
	instance.samSiteGroupNames = {}
	table.insert(instance.iadsCollection, iads)
	return instance
end

function SkynetMooseA2ADispatcherConnector:addIADS(iads)
	table.insert(self.iadsCollection, iads)
end

function SkynetMooseA2ADispatcherConnector:addMooseSetGroup(mooseSetGroup)
	table.insert(self.mooseGroups, mooseSetGroup)
	self:update()
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
			table.insert(self.samSiteGroupNames, samSite:getDCSName())
		end
	end
	return self.samSiteGroupNames
end

function SkynetMooseA2ADispatcherConnector:update()
	
	--mooseGroup elements are type of:
	--https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Core.Set.html##(SET_GROUP)
	
	--remove previously set group names:
	for i = 1, #self.mooseGroups do
		local mooseGroup = self.mooseGroups[i]
		mooseGroup:RemoveGroupsByName(self.ewRadarGroupNames)
		mooseGroup:RemoveGroupsByName(self.samSiteGroupNames)
	end
	
	--add group names of IADS radars that are currently usable by the IADS:
	for i = 1, #self.mooseGroups do
		local mooseGroup = self.mooseGroups[i]
		mooseGroup:AddGroupsByName(self:getEarlyWarningRadarGroupNames())
		mooseGroup:AddGroupsByName(self:getSAMSiteGroupNames())
	end
end

end
