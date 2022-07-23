do

SkynetIADSAbstractElement = {}
SkynetIADSAbstractElement = inheritsFrom(SkynetIADSAbstractDCSObjectWrapper)

function SkynetIADSAbstractElement:create(dcsRepresentation, iads)
	local instance = self:superClass():create(dcsRepresentation)
	setmetatable(instance, self)
	self.__index = self
	instance.connectionNodes = {}
	instance.powerSources = {}
	instance.iads = iads
	instance.natoName = "UNKNOWN"
	world.addEventHandler(instance)
	return instance
end

function SkynetIADSAbstractElement:removeEventHandlers()
	world.removeEventHandler(self)
end

function SkynetIADSAbstractElement:cleanUp()
	self:removeEventHandlers()
end

function SkynetIADSAbstractElement:isDestroyed()
	return self:getDCSRepresentation():isExist() == false
end

function SkynetIADSAbstractElement:addPowerSource(powerSource)
	table.insert(self.powerSources, powerSource)
	self:informChildrenOfStateChange()
	return self
end

function SkynetIADSAbstractElement:getPowerSources()
	return self.powerSources
end

function SkynetIADSAbstractElement:addConnectionNode(connectionNode)
	table.insert(self.connectionNodes, connectionNode)
	self:informChildrenOfStateChange()
	return self
end

function SkynetIADSAbstractElement:getConnectionNodes()
	return self.connectionNodes
end

function SkynetIADSAbstractElement:hasActiveConnectionNode()
	local connectionNode = self:genericCheckOneObjectIsAlive(self.connectionNodes)
	if connectionNode == false and self.iads:getDebugSettings().samNoConnection then
		self.iads:printOutput(self:getDescription().." no connection to Command Center")
	end
	return connectionNode
end

function SkynetIADSAbstractElement:hasWorkingPowerSource()
	local power = self:genericCheckOneObjectIsAlive(self.powerSources)
	if power == false and self.iads:getDebugSettings().hasNoPower then
		self.iads:printOutput(self:getDescription().." has no power")
	end
	return power
end

function SkynetIADSAbstractElement:getDCSName()
	return self.dcsName
end

-- generic function to theck if power plants, command centers, connection nodes are still alive
function SkynetIADSAbstractElement:genericCheckOneObjectIsAlive(objects)
	local isAlive = (#objects == 0)
	for i = 1, #objects do
		local object = objects[i]
		--if we find one object that is not fully destroyed we assume the IADS is still working
		if object:isExist() then
			isAlive = true
			break
		end
	end
	return isAlive
end

function SkynetIADSAbstractElement:getNatoName()
	return self.natoName
end

function SkynetIADSAbstractElement:getDescription()
	return "IADS ELEMENT: "..self:getDCSName().." | Type: "..tostring(self:getNatoName())
end

function SkynetIADSAbstractElement:onEvent(event)
	--if a unit is destroyed we check to see if its a power plant powering the unit or a connection node
	if event.id == world.event.S_EVENT_DEAD then
		if self:hasWorkingPowerSource() == false or self:isDestroyed() then
			self:goDark()
			self:informChildrenOfStateChange()
		end
		if self:hasActiveConnectionNode() == false then
			self:informChildrenOfStateChange()
		end
	end
	if event.id == world.event.S_EVENT_SHOT then
		self:weaponFired(event)
	end
end

--placeholder method, can be implemented by subclasses
function SkynetIADSAbstractElement:weaponFired(event)
	
end

--placeholder method, can be implemented by subclasses
function SkynetIADSAbstractElement:goDark()
	
end

--placeholder method, can be implemented by subclasses
function SkynetIADSAbstractElement:goAutonomous()

end

--placeholder method, can be implemented by subclasses
function SkynetIADSAbstractElement:setToCorrectAutonomousState()

end

--placeholder method, can be implemented by subclasses
function SkynetIADSAbstractElement:informChildrenOfStateChange()
	
end

end
