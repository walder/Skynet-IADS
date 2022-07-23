do

SkynetIADSHARMDetection = {}
SkynetIADSHARMDetection.__index = SkynetIADSHARMDetection

SkynetIADSHARMDetection.HARM_THRESHOLD_SPEED_KTS = 800

function SkynetIADSHARMDetection:create(iads)
	local harmDetection = {}
	setmetatable(harmDetection, self)
	harmDetection.contacts = {}
	harmDetection.iads = iads
	harmDetection.contactRadarsEvaluated = {}
	return harmDetection
end

function SkynetIADSHARMDetection:setContacts(contacts)
	self.contacts = contacts
end

function SkynetIADSHARMDetection:evaluateContacts()
	self:cleanAgedContacts()
	for i = 1, #self.contacts do
		local contact = self.contacts[i]	
		local groundSpeed  = contact:getGroundSpeedInKnots(0)
		--if a contact has only been hit by a radar once it's speed is 0
		if groundSpeed == 0 then
			return
		end
		local simpleAltitudeProfile = contact:getSimpleAltitudeProfile()
		local newRadarsToEvaluate = self:getNewRadarsThatHaveDetectedContact(contact)
		--self.iads:printOutputToLog(contact:getName().." new Radars to evaluate: "..#newRadarsToEvaluate)
		--self.iads:printOutputToLog(contact:getName().." ground speed: "..groundSpeed)
		if ( #newRadarsToEvaluate > 0 and contact:isIdentifiedAsHARM() == false and ( groundSpeed > SkynetIADSHARMDetection.HARM_THRESHOLD_SPEED_KTS and #simpleAltitudeProfile <= 2 ) ) then
			local detectionProbability = self:getDetectionProbability(newRadarsToEvaluate)
			--self.iads:printOutputToLog("DETECTION PROB: "..detectionProbability)
			if ( self:shallReactToHARM(detectionProbability) ) then
				contact:setHARMState(SkynetIADSContact.HARM)
				if (self.iads:getDebugSettings().harmDefence ) then
					self.iads:printOutputToLog("HARM IDENTIFIED: "..contact:getTypeName().." | DETECTION PROBABILITY WAS: "..detectionProbability.."%")
				end
			else
				contact:setHARMState(SkynetIADSContact.NOT_HARM)
				if (self.iads:getDebugSettings().harmDefence ) then
					self.iads:printOutputToLog("HARM NOT IDENTIFIED: "..contact:getTypeName().." | DETECTION PROBABILITY WAS: "..detectionProbability.."%")
				end
			end
		end
		
		if ( #simpleAltitudeProfile > 2 and contact:isIdentifiedAsHARM() ) then
			contact:setHARMState(SkynetIADSContact.HARM_UNKNOWN)
			if (self.iads:getDebugSettings().harmDefence ) then
				self.iads:printOutputToLog("CORRECTING HARM STATE: CONTACT IS NOT A HARM: "..contact:getName())
			end
		end
		
		if ( contact:isIdentifiedAsHARM() ) then
			self:informRadarsOfHARM(contact)
		end
	end
end

function SkynetIADSHARMDetection:cleanAgedContacts()
	local activeContactRadars = {}
	for contact, radars in pairs (self.contactRadarsEvaluated) do
		if contact:getAge() < 32 then
			activeContactRadars[contact] = radars
		end
	end
	self.contactRadarsEvaluated = activeContactRadars
end

function SkynetIADSHARMDetection:getNewRadarsThatHaveDetectedContact(contact)
	local newRadars = contact:getAbstractRadarElementsDetected()
	local radars = self.contactRadarsEvaluated[contact]
	if radars then
		newRadars = {}
		local contactRadars = contact:getAbstractRadarElementsDetected()
		for i = 1, #contactRadars do
			local contactRadar = contactRadars[i]
			local newRadar = self:isElementInTable(radars, contactRadar)
			if newRadar ~= nil then
				table.insert(newRadars, newRadar)
			end
		end
	end
	self.contactRadarsEvaluated[contact] = contact:getAbstractRadarElementsDetected()
	return newRadars
end

function SkynetIADSHARMDetection:isElementInTable(tbl, element)
	for i = 1, #tbl do
		tblElement = tbl[i]
		if tblElement == element then
			return nil
		end
	end
	return element
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

function SkynetIADSHARMDetection:getDetectionProbability(radars)
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


