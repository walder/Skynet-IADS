do

TestSkynetIADSAbstractDCSObjectWrapper = {}

function TestSkynetIADSAbstractDCSObjectWrapper:setUp()
	self.abstractObjectWrapper = SkynetIADSAbstractDCSObjectWrapper:create(Unit.getByName('EW-SA-6'))
end

function TestSkynetIADSAbstractDCSObjectWrapper:tearDown()

end

function TestSkynetIADSAbstractDCSObjectWrapper:testGetName()
	lu.assertEquals(self.abstractObjectWrapper:getName(), 'EW-SA-6')
	self.abstractObjectWrapper.dcsRepresentation = nil
	--test to see if name is still returned after object wrapped is nil
	lu.assertEquals(self.abstractObjectWrapper:getName(), 'EW-SA-6')
end

function TestSkynetIADSAbstractDCSObjectWrapper:testGetTypeName()
	lu.assertEquals(self.abstractObjectWrapper:getTypeName(), 'Kub 1S91 str')
	self.abstractObjectWrapper.dcsRepresentation = nil
	lu.assertEquals(self.abstractObjectWrapper:getTypeName(), 'Kub 1S91 str')
end

function TestSkynetIADSAbstractDCSObjectWrapper:testIsExist()
	lu.assertEquals(self.abstractObjectWrapper:isExist(), true)
	self.abstractObjectWrapper.dcsRepresentation = nil
	lu.assertEquals(self.abstractObjectWrapper:isExist(), false)
end

function TestSkynetIADSAbstractDCSObjectWrapper:testGetDCSRepresentation()
	lu.assertEquals(self.abstractObjectWrapper:getDCSRepresentation(), Unit.getByName('EW-SA-6'))
end

function TestSkynetIADSAbstractDCSObjectWrapper:testInsertToTableIfNotAlreadyAdded()
	local tbl = {}
	local mock = {}
	table.insert(tbl, mock)
	local result = self.abstractObjectWrapper:insertToTableIfNotAlreadyAdded(tbl, mock)
	lu.assertEquals(#tbl, 1)
	lu.assertEquals(result, false)
	
	
	local mock2 = {}
	local result2 = self.abstractObjectWrapper:insertToTableIfNotAlreadyAdded(tbl, mock2)
	lu.assertEquals(#tbl, 2)
	lu.assertEquals(result2, true)
end

end
