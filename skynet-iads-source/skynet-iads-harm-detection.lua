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
		end
	end

end

end


