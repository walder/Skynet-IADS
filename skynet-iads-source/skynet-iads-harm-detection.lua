do

SkynetIADSHARMDetection = {}
SkynetIADSHARMDetection.__index = SkynetIADSHARMDetection

SkynetIADSHARMDetection.HARM_THRESHOLD_SPEED_KTS = 1000

function SkynetIADSHARMDetection:create()
	local harmDetection = {}
	setmetatable(harmDetection, SkynetIADSHARMDetection)
	harmDetection.contacts = {}
	return harmDetection
end

function SkynetIADSHARMDetection:setContacts(contacts)
	self.contacts = contacts
end

function SkynetIADSHARMDetection:evaluateContacts()

	for i = 1, #self.contacts do
		local contact = self.contacts[i]
		if ( contact:getGroundSpeedInKnots(0) > SkynetIADSHARMDetection.HARM_THRESHOLD_SPEED_KTS ) then
			env.info("Contact Speed: "..contact:getGroundSpeedInKnots(0))
			local altProfile = contact:getSimpleAltitudeProfile()
			local profileStr = ""
			for i = 1, #altProfile do
				profileStr = profileStr.." "..altProfile[i]
			end
			env.info(profileStr)
			
			--TODO: mergeContacts in SkynetIADS class needs to add radars that have detected contacts, for correct pobability calculation
			--TODO: code case when new radar detects HARM chance has to be calculated again
			local detectionProbability = self:getDetectionProbability(contact)
			if self:shallReactToHARM(detectionProbability)
				--start shutting down SAMS here:
			end
			
		end
	end
end

function SkynetIADSAbstractRadarElement:shallReactToHARM(chance)
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


