do

SkynetIADSHARMDetection = {}
SkynetIADSHARMDetection.__index = SkynetIADSHARMDetection

SkynetIADSHARMDetection.HARM_THRESHOLD_SPEED_KTS = 1000

function SkynetIADSHARMDetection:create(iads)
	local harmDetection = {}
	setmetatable(harmDetection, self)
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
		
		--[[
		env.info("Contact Speed: "..contact:getGroundSpeedInKnots(0))
		local altProfile = contact:getSimpleAltitudeProfile()
		local profileStr = ""
		for i = 1, #altProfile do
			profileStr = profileStr.." "..altProfile[i]
		end
		env.info(profileStr)
		--]]
			
		if ( contact:getGroundSpeedInKnots(0) > SkynetIADSHARMDetection.HARM_THRESHOLD_SPEED_KTS and contact:isHARMStateUnknown() and #contact:getSimpleAltitudeProfile() <= 2 ) then
			local detectionProbability = self:getDetectionProbability(contact)
			if ( self:shallReactToHARM(detectionProbability) ) then
				if (self.iads:getDebugSettings().harmDefence ) then
					self.iads:printOutputToLog("HARM IDENTIFIED: "..contact:getTypeName().." | DETECTION PROBABILITY WAS: "..detectionProbability.."%")
				end
				contact:setHARMState(SkynetIADSContact.HARM)
			else
				contact:setHARMState(SkynetIADSContact.NOT_HARM)
			end
		end
		
		
		if contact:isIdentifiedAsHARM() then
			self:informRadarsOfHARM(contact)
		end
	end
end

function SkynetIADSHARMDetection:informRadarsOfHARM(contact)
	local samSites = self.iads:getUsableSAMSites()
	self:updateRadarsOfSites(samSites, contact)
	
	local ewRadars = self.iads:getUsableEarlyWarningRadars()
	self:updateRadarsOfSites(ewRadars, contact)
end

function SkynetIADSHARMDetection:updateRadarsOfSites(sites, contact)
	for i = 1, #sites do
		local site = sites[i]
		site:informOfHARM(contact)
	end
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


