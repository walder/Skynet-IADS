do

--[[
SAM Sites that engage HARMs:
SA-15
SA-10 (bug when engaging at 25k, no harms are intercepted)

SAM Sites that ignore HARMS:
SA-11
SA-6
SA-2
SA-3
Patriot
]]--

--[[
Create Table of Contents from markdown with:
https://github.com/ekalinin/github-markdown-toc.go

call:
gh-md-toc.exe ../Readme.md

--]]

---IADS Unit Tests
SKYNET_UNIT_TESTS_NUM_EW_SITES_RED = 17
SKYNET_UNIT_TESTS_NUM_SAM_SITES_RED = 15

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