do

SkynetIADSSAMLauncher = {}
SkynetIADSSAMLauncher = inheritsFrom(SkynetIADSSAMSearchRadar)

function SkynetIADSSAMLauncher:create(unit)
	local instance = self:superClass():create(unit)
	setmetatable(instance, self)
	self.__index = self
	instance.maximumFiringAltitude = 0
	return instance
end

function SkynetIADSSAMLauncher:setupRangeData()
	self.remainingNumberOfMissiles = 0
	self.remainingNumberOfShells = 0
	if self:isExist() then
		local data = self:getDCSRepresentation():getAmmo()
		local initialNumberOfMissiles = 0
		local initialNumberOfShells = 0
		--data becomes nil, when all missiles are fired
		if data then
			for i = 1, #data do
				local ammo = data[i]		
				--we ignore checks on radar guidance types, since we are not interested in how exactly the missile is guided by the SAM site.
				if ammo.desc.category == Weapon.Category.MISSILE then
					--TODO: see what the difference is between Max and Min values, SA-3 has higher Min value than Max?, most likely it has to do with the box parameters supplied by launcher
					--to simplyfy we just use the larger value, sam sites need a few seconds of tracking time to fire, by that time contact has most likely closed in on the SAM site.
					local altMin = ammo.desc.rangeMaxAltMin
					local altMax = ammo.desc.rangeMaxAltMax
					self.maximumRange = altMin
					if altMin < altMax then
						self.maximumRange = altMax
					end
					self.maximumFiringAltitude = ammo.desc.altMax
					self.remainingNumberOfMissiles = self.remainingNumberOfMissiles + ammo.count
					initialNumberOfMissiles = self.remainingNumberOfMissiles
				end
				if ammo.desc.category == Weapon.Category.SHELL then
					self.remainingNumberOfShells = self.remainingNumberOfShells + ammo.count
					initialNumberOfShells = self.remainingNumberOfShells
				end
				--if no distance was detected we run the code for the search radar. This happens when all in one units are passed like the shilka
				if self.maximumRange == 0 then
					--this is to prevent infinite calls between launcher and search radar
					if self.triedSensors <= 2 then
						SkynetIADSSAMSearchRadar.setupRangeData(self)
					end
				end
			end
			-- conditions here are because setupRangeData() is called multiple times in the code to update ammo status, we set initial values only the first time the method is called
			if self.initialNumberOfMissiles == 0 then
				self.initialNumberOfMissiles = initialNumberOfMissiles
			end
			if self.initialNumberOfShells == 0 then
				self.initialNumberOfShells = initialNumberOfShells
			end
		end
	end
end

function SkynetIADSSAMLauncher:getInitialNumberOfShells()
	return self.initialNumberOfShells
end

function SkynetIADSSAMLauncher:getRemainingNumberOfShells()
	self:setupRangeData()
	return self.remainingNumberOfShells
end

function SkynetIADSSAMLauncher:getInitialNumberOfMissiles()
	return self.initialNumberOfMissiles
end

function SkynetIADSSAMLauncher:getRemainingNumberOfMissiles()
	self:setupRangeData()
	return self.remainingNumberOfMissiles
end

function SkynetIADSSAMLauncher:getRange()
	return self.maximumRange
end

function SkynetIADSSAMLauncher:getMaximumFiringAltitude()
	return self.maximumFiringAltitude
end

function SkynetIADSSAMLauncher:isWithinFiringHeight(target)
	-- if no max firing height is set (radar quided AAA) then we use the vertical range, bit of a hack but probably ok for AAA
	if self:getMaximumFiringAltitude() > 0 then
		return self:getMaximumFiringAltitude() >= self:getHeight(target) 
	else
		return self:getRange() >= self:getHeight(target)
	end
end

function SkynetIADSSAMLauncher:isInRange(target)
	if self:isExist() == false then
		return false
	end
	return self:isWithinFiringHeight(target) and self:isInHorizontalRange(target)
end

end

--[[
SA-2 Launcher:
    {
        count=1,
        desc={
            Nmax=17,
            RCS=0.39669999480247,
            _origin="",
            altMax=25000,
            altMin=100,
            box={
                max={x=4.7303376197815, y=0.84564626216888, z=0.84564626216888},
                min={x=-5.8387970924377, y=-0.84564626216888, z=-0.84564626216888}
            },
            category=1,
            displayName="SA2V755",
            fuseDist=20,
            guidance=4,
            life=2,
            missileCategory=2,
            rangeMaxAltMax=30000,
            rangeMaxAltMin=40000,
            rangeMin=7000,
            typeName="SA2V755",
            warhead={caliber=500, explosiveMass=196, mass=196, type=1}
        }
    }
}
--]]
