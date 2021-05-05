do

SkynetIADSHARMDetection = {}
SkynetIADSHARMDetection.__index = SkynetIADSHARMDetection

SkynetIADSHARMDetection.HARM_THRESHOLD_SPEED_KTS = 1000
SkynetIADSHARMDetection.RADAR_SHUTDOWN_DISTANCE_NM = 10000

function SkynetIADSHARMDetection:create(iads)
	local harmDetection = {}
	setmetatable(harmDetection, SkynetIADSHARMDetection)
	harmDetection.contacts = {}
	harmDetection.iads = iads
	harmDetection.contactsIdentifiedAsHARMS = {}
	return harmDetection
end

function SkynetIADSHARMDetection:setContacts(contacts)
	self.contacts = contacts
end

function SkynetIADSHARMDetection:evaluateContacts()

	for i = 1, #self.contacts do
		local contact = self.contacts[i]
		
		--[[
		env.info("Contact Speed: "..contact:getGroundSpeedInKnots(0))
		local altProfile = contact:getSimpleAltitudeProfile()
		local profileStr = ""
		for i = 1, #altProfile do
			profileStr = profileStr.." "..altProfile[i]
		end
		env.info(profileStr)
		--]]
			
		--TODO: add simple flight path history to harm detection code
		if ( contact:getGroundSpeedInKnots(0) > SkynetIADSHARMDetection.HARM_THRESHOLD_SPEED_KTS and contact:isHARMStateUnknown() ) then
			if ( self:shallReactToHARM(self:getDetectionProbability(contact)) ) then
				contact:setHARMState(SkynetIADSContact.HARM)
			else
				contact:setHARMState(SkynetIADSContact.NOT_HARM)
			end
		end
		
		
		if contact:isIdentifiedAsHARM() then
			self:informRadarsOfHARM(contact)
		end
		
		--TODO: mergeContacts in SkynetIADS class needs to add radars that have detected contacts, for correct pobability calculation
		--TODO: code case when new radar detects HARM chance has to be calculated again
		--TODO: Add EW radars
		--TODO: TEST what happens when firing at radar that is detecting HARM
		--TODO: only shut down radars that have no PD see shallIgnoreHARMShutdown of AbstractRadarElement
		--TODO: SAM shall not go live if contact passed is positively identified as HARM and it can not engage HARMS
		--TODO: contacts that no longer exist trigger error when getPosition() is called
	end
end

function SkynetIADSHARMDetection:informRadarsOfHARM(contact)
	local samSites = self.iads:getUsableSAMSites()
	self:updateRadarsOfSites(samSites, contact)
end

function SkynetIADSHARMDetection:updateRadarsOfSites(sites, contact)
	for i = 1, #sites do
		local site = sites[i]
		local radars = site:getRadars()
		for j = 1, #radars do
			local radar = radars[j]
			local distanceNM =  mist.utils.metersToNM(self:getDistanceInMetersToContact(radar, contact:getPosition().p))
			local harmToSAMHeading = mist.utils.toDegree(mist.utils.getHeadingPoints(contact:getPosition().p, radar:getPosition().p))
			local harmToSAMAspect = self:calculateAspectInDegrees(contact:getMagneticHeading(), harmToSAMHeading)
			local speedKT = contact:getGroundSpeedInKnots(0)
			local secondsToImpact = self:getSecondsToImpact(distanceNM, speedKT)
			--TODO: Make variable out of aspect and distance
			if ( harmToSAMAspect < 30 and distanceNM < 10 ) then
				--code method informOfHARM(contact) -> checks below shall be done in AbstractRadarElement
				if ( site:isDefendingHARM() == false or ( site:getHARMShutdownTime() < secondsToImpact ) ) then
					site:goSilentToEvadeHARM(secondsToImpact)
					break
				end
			end
		end
	end
end

function SkynetIADSHARMDetection:getDistanceInMetersToContact(radarUnit, point)
	return mist.utils.round(mist.utils.get3DDist(radarUnit:getPosition().p, point), 0)
end

function SkynetIADSHARMDetection:getSecondsToImpact(distanceNM, speedKT)
	local tti = 0
	if speedKT > 0 then
		tti = mist.utils.round((distanceNM / speedKT) * 3600, 0)
		if tti < 0 then
			tti = 0
		end
	end
	return tti
end

function SkynetIADSHARMDetection:calculateAspectInDegrees(harmHeading, harmToSAMHeading)
		local aspect = harmHeading - harmToSAMHeading
		if ( aspect < 0 ) then
			aspect = -1 * aspect
		end
		if aspect > 180 then
			aspect = 360 - aspect
		end
		return mist.utils.round(aspect)
end

function SkynetIADSHARMDetection:shallReactToHARM(chance)
	return chance >=  math.random(1, 100)
end

function SkynetIADSHARMDetection:getDetectionProbability(contact)
	local radars = contact:getAbstractRadarElementsDetected()
	local detectionChance = 0
	local missChance = 100
	local detection = 0
	for i = 1, #radars do
		detection = radars[i]:getHARMDetectionChance()
		if ( detectionChance == 0 ) then
			detectionChance = detection
		else
			detectionChance = detectionChance + (detection * (missChance / 100))
		end	
		missChance = 100 - detection
	end
	return detectionChance
end

end


