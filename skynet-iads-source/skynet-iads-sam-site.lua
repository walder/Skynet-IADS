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
	sam.targetsInRange = false
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

function SkynetIADSSamSite:setActAsEW(ewState)
	if ewState == true or ewState == false then
		self.actAsEW = ewState
	end
	if self.actAsEW == true then
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

function SkynetIADSSamSite:targetCycleUpdateStart()
	self.targetsInRange = false
end

function SkynetIADSSamSite:targetCycleUpdateEnd()
	if self.targetsInRange == false and self.actAsEW == false then
		self:goDark()
	end
end

function SkynetIADSSamSite:informOfContact(contact)
	if self:isTargetInRange(contact) or self.actAsEW then
		self:goLive()
		self.targetsInRange = true
	end
end

end
