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
	sam.actAsEW = false
	return sam
end

function SkynetIADSSamSite:goAutonomous()
	if self.autonomousBehaviour == SkynetIADSSamSite.AUTONOMOUS_STATE_DARK then
		self:goDark()
		--trigger.action.outText(self:getDescription().." is Autonomous: DARK", 1)
	else
		self:goLive()
		--trigger.action.outText(self:getDescription().." is Autonomous: DCS AI", 1)
	end
	return
end

function SkynetIADSSamSite:setActAsEW(EWstate)
	self.actAsEW = EWstate
	if self.actAsEW then
		self:goLive()
	else
		self:goDark()
	end
end

function SkynetIADSSamSite:setAutonomousBehaviour(mode)
	if mode then
		self.autonomousBehaviour = mode
	end
end

function SkynetIADSSamSite:informOfContact(contact)
	-- if the sam has no power, it won't do anything
	if self:hasWorkingPowerSource() == false then
		self:goDark(true)
		return
	end
	if self:isTargetInRange(contact) or self.actAsEW then
		self:goLive()
	else
		self:goDark()
	end
end

end
