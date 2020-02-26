do

SkynetIADSAbstractElement = {}

function SkynetIADSAbstractElement:create(dcsRepresentation, iads)
	local instance = {}
	setmetatable(instance, self)
	self.__index = self
	instance.aiState = true
	instance.connectionNodes = {}
	instance.powerSources = {}
	instance.objectsIdentifiedasHarms = {}
	instance.iads = iads
	instance.shutdownforHarmDefence = false
	instance.launchers = {}
	instance.trackingRadars = {}
	instance.searchRadars = {}
	instance.natoName = "UNKNOWN"
	instance:setDCSRepresentation(dcsRepresentation)
	instance:setupElements()
	world.addEventHandler(instance)
	return instance
end


function SkynetIADSAbstractElement:getLife()
	return self:getDCSRepresentation():getLife()
end

function SkynetIADSAbstractElement:addPowerSource(powerSource)
	table.insert(self.powerSources, powerSource)
end

function SkynetIADSAbstractElement:addConnectionNode(connectionNode)
	table.insert(self.connectionNodes, connectionNode)
end

function SkynetIADSAbstractElement:hasActiveConnectionNode()
	return self:genericCheckOneObjectIsAlive(self.connectionNodes)
end

function SkynetIADSAbstractElement:hasWorkingPowerSource()
	local power = self:genericCheckOneObjectIsAlive(self.powerSources)
	if power == false and self.iads:getDebugSettings().hasNoPower then
		self.iads:printOutput(self:getDescription().." has no power")
	end
	return power
end

function SkynetIADSAbstractElement:getDCSName()
	return self:getDCSRepresentation():getName()
end

-- generic function to theck if power plants, command centers, connection nodes are still alive
function SkynetIADSAbstractElement:genericCheckOneObjectIsAlive(objects)
	local isAlive = (#objects == 0)
	for i = 1, #objects do
		local object = objects[i]
		--trigger.action.outText("life: "..object:getLife(), 1)
		--if we find one object that is not fully destroyed we assume the IADS is still working
		if object:getLife() > 0 then
			isAlive = true
			break
		end
	end
	return isAlive
end

function SkynetIADSAbstractElement:setDCSRepresentation(representation)
	self.dcsRepresentation = representation
end

function SkynetIADSAbstractElement:getDCSRepresentation()
	return self.dcsRepresentation
end

function SkynetIADSAbstractElement:getController()
	return self:getDCSRepresentation():getController()
end

function SkynetIADSAbstractElement:getDetectedTargets(detectionType)
	if self:hasWorkingPowerSource() == false then
		return
	end
	local returnTargets = {}
	--trigger.action.outText("EW getTargets", 1)
	--trigger.action.outText(self.radarUnit:getName(), 1)
	local targets = self:getController():getDetectedTargets(detectionType)
	--trigger.action.outText("num Targets: "..#targets, 1)
	for i = 1, #targets do
		local target = targets[i]
		local iadsTarget = SkynetIADSContact:create(target)
		table.insert(returnTargets, iadsTarget)
	end
	return returnTargets
end

function SkynetIADSAbstractElement:setupElements()
	local units = {}
	local natoName = self.natoName
	units[1] = self:getDCSRepresentation()
	if getmetatable(self:getDCSRepresentation()) == Group then
		units = self:getDCSRepresentation():getUnits()
	end
	local unitTypes = {}
	trigger.action.outText("-----"..self:getDCSName().."--------", 1)
	for i = 1, #units do
		local unitName = units[i]:getTypeName()
		if unitTypes[unitName] then
			unitTypes[unitName]['count'] = unitTypes[unitName]['count'] + 1
		else
			unitTypes[unitName] = {}
			unitTypes[unitName]['count'] = 1
			unitTypes[unitName]['found'] = 0
		end
	end
	local allUnitsFound = true
	for i = 1, #units do
		local unit = units[i]
		local unitTypeName = unit:getTypeName()
		for typeName, dataType in pairs(SkynetIADS.database) do
			for unitType, unitData in pairs(dataType) do
				if unitType == 'searchRadar' then
					for unitName, unitPerformanceData in pairs(unitData) do
						if unitName == unitTypeName then
							local searchRadar = SkynetIADSSAMSearchRadar:create(unit, unitPerformanceData)
							table.insert(self.searchRadars, searchRadar)
							--trigger.action.outText("added search radar", 1)
							unitTypes[unitName]['found'] = unitTypes[unitName]['count']
						end
					end
				elseif unitType == 'launchers' then
					for unitName, unitPerformanceData in pairs(unitData) do
						if unitName == unitTypeName then
							local launcher = SkynetIADSSAMLauncher:create(unit, unitPerformanceData)
							table.insert(self.launchers, launcher)
							unitTypes[unitName]['found'] = unitTypes[unitName]['count']
							--trigger.action.outText(launcher:getRange(), 1)
						end
					end
				elseif unitType == 'trackingRadar' then
					for unitName, unitPerformanceData in pairs(unitData) do
						if unitName == unitTypeName then
							local trackingRadar = SkynetIADSSAMTrackingRadar:create(unit, unitPerformanceData)
							table.insert(self.trackingRadars, trackingRadar)
							unitTypes[unitName]['found'] = unitTypes[unitName]['count']
							--trigger.action.outText("added tracking radar", 1)
						end
					end
				end
			end
			allUnitsFound = true
			for name, countData in pairs(unitTypes) do
				if countData['count'] ~= countData['found'] then
					allUnitsFound = false
					countData['found'] = 0
				end
			end
			if allUnitsFound then
		--		trigger.action.outText("break", 1)
				natoName = dataType['name']['NATO']
				break
			end
		end
	end
	local countNatoNames = 0
	for name, countData in pairs(unitTypes) do
		if countData['count'] ~= countData['found'] then
			trigger.action.outText("MISMATCH: "..name.." "..countData['count'].." "..countData['found'], 1)
		end
	end
	--we shorten the SA-XX names and don't return their code names eg goa, gainful..
	local pos = natoName:find(" ")
	local prefix = natoName:sub(1, 2)
	if string.lower(prefix) == 'sa' and pos ~= nil then
		natoName = natoName:sub(1, (pos-1))
	end
	self.natoName = natoName
	trigger.action.outText(self:getDCSName().." nato name: "..natoName, 1)
end

function SkynetIADSAbstractElement:getDBValues()
	local units = {}
	units[1] = self:getDCSRepresentation()
	if getmetatable(self:getDCSRepresentation()) == Group then
		units = self:getDCSRepresentation():getUnits()
	end
	local samDB = {}
	local unitData = nil
	local typeName = nil
	local natoName = ""
	for i = 1, #units do
		typeName = units[i]:getTypeName()
		for samName, samData in pairs(SkynetIADS.database) do
			--all Sites have a unique launcher, if we find one, we got the internal designator of the SAM unit
			unitData = SkynetIADS.database[samName]
			if unitData['launchers'] and unitData['launchers'][typeName] or unitData['searchRadar'] and unitData['searchRadar'][typeName] then
				samDB = self:extractDBName(samName)
				break
			end
		end
	end
	return samDB
end

function SkynetIADSAbstractElement:extractDBName(samName)
	local samDB = {}
	samDB['key'] =  samName
--	trigger.action.outText("Element is a: "..samName, 1)
	natoName = SkynetIADS.database[samName]['name']['NATO']
	local pos = natoName:find(" ")
	local prefix = natoName:sub(1, 2)
	--we shorten the SA-XX names and don't return their code names eg goa, gainful..
	if string.lower(prefix) == 'sa' and pos ~= nil then
		natoName = natoName:sub(1, (pos-1))
	end
	samDB['nato'] = natoName
	return samDB
end

function SkynetIADSAbstractElement:getDBName()
	local dbName = self:getDBValues()['key']
	if dbName == nil then
		dbName = "UNKNOWN"
	end
	return dbName
end

function SkynetIADSAbstractElement:getNatoName()
	return self.natoName
end

function SkynetIADSAbstractElement:getDescription()
	return "IADS ELEMENT: "..self:getDCSRepresentation():getName().." | Type : "..tostring(self:getNatoName())
end

function SkynetIADSAbstractElement:onEvent(event)
	--if a unit is destroyed we check to see if its a power plant powering the unit.
	if event.id == world.event.S_EVENT_DEAD then
		--trigger.action.outText(self:getDCSRepresentation():getName().." "..tostring(self:hasWorkingPowerSource()), 10)
		if self:hasWorkingPowerSource() == false then
			self:goDark(true)
		end
	end
end

function SkynetIADSAbstractElement:goLive()
	if self:hasWorkingPowerSource() == false or self.shutdownforHarmDefence == true then
		return
	end
	if self.aiState == false and self:isControllableUnit() then
		local  cont = self:getController()
		cont:setOnOff(true)
		cont:setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.RED)	
		cont:setOption(AI.Option.Air.id.ROE, AI.Option.Air.val.ROE.WEAPON_FREE)
		self.aiState = true
	--	self:scanForHarms()
		if  self.iads:getDebugSettings().radarWentLive then
			self.iads:printOutput(self:getDescription().." going live")
		end
	end
end

function SkynetIADSAbstractElement:scanForHarms()
	mist.removeFunction(self.harmScanID)
	self.harmScanID = mist.scheduleFunction(SkynetIADSAbstractElement.evaluateIfTargetsContainHarms, {self}, 1, 5)
end


--Todo: detection of HARM ist to perfect, add randomisation, add reactivation time or the IADS could give SAM green lights, when no Strikers are in the area of the sam anymore.
function SkynetIADSAbstractElement.evaluateIfTargetsContainHarms(self, detectionType)
	local targets = self:getDetectedTargets(detectionType) 
	for i = 1, #targets do
		local target = targets[i]
		--if target:getTypeName() == 'weapons.missiles.AGM_88' then
		--	trigger.action.outText("Detection Type: "..detectionType, 1)
		--	trigger.action.outText(target:getTypeName(), 1)
		--	trigger.action.outText("Is Type Known: "..tostring(target:isTypeKnown()), 1)
		--	trigger.action.outText("Distance is Known: "..tostring(target:isDistanceKnown()), 1)
			local radars = self:getRadarUnits()
			for j = 1, #radars do
				local radar = radars[j]
				local distance = mist.utils.get3DDist(target:getPosition().p, radar:getPosition().p)
			--	trigger.action.outText("Missile to SAM distance: "..distance, 1)
				-- distance needs to be incremented by a certain value for ip calculation to work, check why
				local impactPoint = land.getIP(target:getPosition().p, target:getPosition().x, distance+100)
				if impactPoint then
					local diststanceToSam = mist.utils.get2DDist(radar:getPosition().p, impactPoint)
				--	trigger.action.outText("Impact Point distance to SAM site: "..diststanceToSam, 1)
				--	trigger.action.outText("detected Object Name: "..target:getName(), 1)
					--trigger.action.outText("Impact Point X: "..impactPoint.x.."Y: "..impactPoint.y.."Z: "..impactPoint.z, 1)
					if diststanceToSam <= 100 then
						local numDetections = 0
						if self.objectsIdentifiedasHarms[target:getName()] then
							numDetections = self.objectsIdentifiedasHarms[target:getName()]
							numDetections = numDetections + 1
							self.objectsIdentifiedasHarms[target:getName()] = numDetections
						else
							self.objectsIdentifiedasHarms[target:getName()] = 1
							numDetections = self.objectsIdentifiedasHarms[target:getName()]
						end
					--	trigger.action.outText("detection Cycle: "..numDetections, 1)
						-- this may still be too perfect, add some kind of randomisation, but where?
						if numDetections >= 3 then
							self:goDark(true)
							self.shutdownforHarmDefence = true
						end
					end
				end
			end
	--	end
	end
end

function SkynetIADSAbstractElement:isActive()
	return self.aiState
end

function SkynetIADSAbstractElement:isControllableUnit()
	return getmetatable(self:getDCSRepresentation()) ~= StaticObject
end

-- can be overridden in subclasses if needed
function SkynetIADSAbstractElement:goDark(enforceGoDark)
	if self.aiState and self:isControllableUnit() then
	--	trigger.action.outText("setting off:"..self:getDCSRepresentation():getName(), 10)
		self:getController():setOnOff(false)
		self.aiState = false
	end
end

-- helper code for class inheritance
function inheritsFrom( baseClass )

    local new_class = {}
    local class_mt = { __index = new_class }

    function new_class:create()
        local newinst = {}
        setmetatable( newinst, class_mt )
        return newinst
    end

    if nil ~= baseClass then
        setmetatable( new_class, { __index = baseClass } )
    end

    -- Implementation of additional OO properties starts here --

    -- Return the class object of the instance
    function new_class:class()
        return new_class
    end

    -- Return the super class object of the instance
    function new_class:superClass()
        return baseClass
    end

    -- Return true if the caller is an instance of theClass
    function new_class:isa( theClass )
        local b_isa = false

        local cur_class = new_class

        while ( nil ~= cur_class ) and ( false == b_isa ) do
            if cur_class == theClass then
                b_isa = true
            else
                cur_class = cur_class:superClass()
            end
        end

        return b_isa
    end

    return new_class
end

end
