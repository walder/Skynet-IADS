do

SkynetIADSSamSite = {}
SkynetIADSSamSite = inheritsFrom(SkynetIADSAbstractRadarElement)

function SkynetIADSSamSite:create(samGroup, iads)
	local sam = self:superClass():create(samGroup, iads)
	setmetatable(sam, self)
	self.__index = self
	sam.actAsEW = false
	sam.targetsInRange = false
	return sam
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
