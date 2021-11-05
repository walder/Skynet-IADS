do

---IADS Unit Tests
SKYNET_UNIT_TESTS_NUM_EW_SITES_RED = 18
SKYNET_UNIT_TESTS_NUM_SAM_SITES_RED = 17

--factory method used in multiple unit tests
function IADSContactFactory(unitName)
	local contact = Unit.getByName(unitName)
	local radarContact = {}
	radarContact.object = contact
	local iadsContact = SkynetIADSContact:create(radarContact)
	iadsContact:refresh()
	return  iadsContact
end

lu.LuaUnit.run()

--clean mist left over scheduled tasks form unit tests, check there are no left over tasks in the IADS
local i = 0
while i < 10000 do
	local id =  mist.removeFunction(i)
	i = i + 1
	if id then
		env.info("WARNING: IADS left over Tasks")
	end
end

end