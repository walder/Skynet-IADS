do

SkynetIADSSamSite = {}
SkynetIADSSamSite = inheritsFrom(SkynetIADSAbstractRadarElement)

SkynetIADSSamSite.AUTONOMOUS_STATE_DCS_AI = 0
SkynetIADSSamSite.AUTONOMOUS_STATE_DARK = 1

function SkynetIADSSamSite:create(samGroup, iads)
	local sam = self:superClass():create(samGroup, iads)
	setmetatable(sam, self)
	self.__index = self
	sam.autonomousBehaviour = SkynetIADSSamSite.AUTONOMOUS_STATE_DCS_AI
	sam:goDark(true)
	return sam
end

function SkynetIADSSamSite:goAutonomous()
	self.targetsInRange = {}
	if self.autonomousBehaviour == SkynetIADSSamSite.AUTONOMOUS_STATE_DARK then
		self:goDark()
		--trigger.action.outText(self:getDescription().." is Autonomous: DARK", 1)
	else
		self:goLive()
		--trigger.action.outText(self:getDescription().." is Autonomous: DCS AI", 1)
	end
	return
end

function SkynetIADSSamSite:setAutonomousBehaviour(mode)
	if mode then
		self.autonomousBehaviour = mode
	end
end

function SkynetIADSSamSite:handOff(contact)
	-- if the sam has no power, it won't do anything
	if self:hasWorkingPowerSource() == false then
		self:goDark(true)
		return
	end
	if self:isTargetInRange(contact) then
		self.targetsInRange[contact:getName()] = contact
		self:goLive()
	else
		self:removeContact(contact)
		self:goDark()
	end
end

end
