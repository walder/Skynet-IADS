do

TestSkynetIADSAbstractDCSObjectWrapper = {}

function TestSkynetIADSAbstractDCSObjectWrapper:setUp()
	self.abstractObjectWrapper = SkynetIADSAbstractDCSObjectWrapper:create(Unit.getByName('EW-SA-6'))
end

function TestSkynetIADSAbstractDCSObjectWrapper:tearDown()

end

function TestSkynetIADSAbstractDCSObjectWrapper:testGetName()
	lu.assertEquals(self.abstractObjectWrapper:getName(), 'EW-SA-6')
	self.abstractObjectWrapper.dcsObject = nil
	--test to see if name is still returned after object wrapped is nil
	lu.assertEquals(self.abstractObjectWrapper:getName(), 'EW-SA-6')
end

function TestSkynetIADSAbstractDCSObjectWrapper:testGetTypeName()
	lu.assertEquals(self.abstractObjectWrapper:getTypeName(), 'Kub 1S91 str')
	self.abstractObjectWrapper.dcsObject = nil
	lu.assertEquals(self.abstractObjectWrapper:getTypeName(), 'Kub 1S91 str')
end

function TestSkynetIADSAbstractDCSObjectWrapper:testIsExist()
	lu.assertEquals(self.abstractObjectWrapper:isExist(), true)
	self.abstractObjectWrapper.dcsObject = nil
	lu.assertEquals(self.abstractObjectWrapper:isExist(), false)
end

function TestSkynetIADSAbstractDCSObjectWrapper:testGetDCSRepesentation()
	lu.assertEquals(self.abstractObjectWrapper:getDCSRepresentation(), Unit.getByName('EW-SA-6'))
end

end
