do
env.info("hello")
local units = Group.getByName('SA-20'):getUnits()
for i = 1, #units do
	local unit = units[i]
	env.info(unit:getTypeName())
end

end