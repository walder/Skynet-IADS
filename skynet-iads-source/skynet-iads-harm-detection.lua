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
	return harmDetection
end

function SkynetIADSHARMDetection:setContacts(contacts)
	self.contacts = contacts
end

function SkynetIADSHARMDetection:evaluateContacts()

	for i = 1, #self.contacts do
		local contact = self.contacts[i]
		if ( contact:getGroundSpeedInKnots(0) > SkynetIADSHARMDetection.HARM_THRESHOLD_SPEED_KTS and self:shallReactToHARM(self:getDetectionProbability(contact))  ) then
			contact:setIsHARM(true)
		end
		
	--[[
		env.info("Contact Speed: "..contact:getGroundSpeedInKnots(0))
			local altProfile = contact:getSimpleAltitudeProfile()
			local profileStr = ""
			for i = 1, #altProfile do
				profileStr = profileStr.." "..altProfile[i]
			end
			env.info(profileStr)
	--]]
			
		--TODO: mergeContacts in SkynetIADS class needs to add radars that have detected contacts, for correct pobability calculation
		--TODO: code case when new radar detects HARM chance has to be calculated again
		--TODO: Add EW radars
		local samSites = self.iads:getUsableSAMSites()
		for i = 1, #samSites do
			local samSite = samSites[i]
			local radars = samSite:getRadars()
			for j = 1, #radars do
				local radar = radars[j]
				
				local distance =  mist.utils.metersToNM(samSite:getDistanceInMetersToContact(radar, contact:getPosition().p))
				local harmToSAMHeading = mist.utils.toDegree(mist.utils.getHeadingPoints(contact:getPosition().p, radar:getPosition().p))
				local harmToSAMAspect = self:calculateAspectInDegrees(contact:getMagneticHeading(), harmToSAMHeading)
				env.info("HARM TO SAM ASPECT: "..harmToSAMAspect.." DISTANCE:"..distance)
				
				--		local harmHeading = mist.utils.toDegree(mist.getHeading(harm))
				--
				--env.info("HARM Distance to SAM: "..distance)
				--if ( distance < SkynetIADSHARMDetection.RADAR_SHUTDOWN_DISTANCE_NM ) then
			
				--end
			end
		end
	end
end

function SkynetIADSHARMDetection:calculateHARMAspect(contact)
	

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


