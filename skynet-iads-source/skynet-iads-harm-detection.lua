do

SkynetIADSHARMDetection = {}
SkynetIADSHARMDetection.__index = SkynetIADSHARMDetection

SkynetIADSHARMDetection.HARM_THRESHOLD_SPEED_KTS = 1000
SkynetIADSHARMDetection.RADAR_SHUTDOWN_DISTANCE_NM = 10000

function SkynetIADSHARMDetection:create(iads)
	local harmDetection = {}
	setmetatable(harmDetection, self)
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
		--TODO: TEST what happens when firing at radar that is detecting HARM
		--TODO: contacts that no longer exist trigger error when getPosition() is called
		--TODO: add simple altitude profile history to harm detection code -> shall prevent fast flying aircraft to be identified as HARMs -> max 2 altitude changes
		--TODO: Finish Unit Tests of informOfHARM in AbstractRadarElement
		--TODO: add Unit Test for evaluateContacts() in this class
		--TODO: add HARM DEFENCE for Autonomus SAMS
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


