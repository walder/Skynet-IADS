do


SkynetIADSTableDelegator = {}

function SkynetIADSTableDelegator:create()
	local instance = {}
	local forwarder = {}
	forwarder.__index = function(tbl, name)
		tbl[name] = function(self, ...)
				for i = 1, #self do
					self[i][name](self[i], ...)
				end
				return self
			end
		return tbl[name]
	end
	setmetatable(instance, forwarder)
	instance.__index = forwarder
	return instance
end

end
