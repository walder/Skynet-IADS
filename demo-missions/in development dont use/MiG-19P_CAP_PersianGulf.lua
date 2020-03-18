do
iranIADS = SkynetIADS:create()

---debug settings remove from here on if you do not wan't any output on what the IADS is doing
local iadsDebug = iranIADS:getDebugSettings()
iadsDebug.IADSStatus = true
iadsDebug.samWentDark = false
iadsDebug.contacts = true
iadsDebug.radarWentLive = false
iadsDebug.ewRadarNoConnection = false
iadsDebug.samNoConnection = false
iadsDebug.jammerProbability = true
iadsDebug.addedEWRadar = false
iadsDebug.addedSAMSite = false
iadsDebug.hasNoPower = true
iadsDebug.warnings = false
iadsDebug.harmDefence = true
---end remove debug ---

iranIADS:addEarlyWarningRadarsByPrefix('EW')
iranIADS:addSAMSitesByPrefix('SAM')

local commandCenter = Unit.getByName("CMDwest")
local comPowerSource = Unit.getByName("GPUwest")
iranIADS:addCommandCenter(commandCenter):addPowerSource(comPowerSource)

local commandCenter = Unit.getByName("CMDcentral")
local comPowerSource = Unit.getByName("GPUcentral")
iranIADS:addCommandCenter(commandCenter):addPowerSource(comPowerSource)

local commandCenter = Unit.getByName("CMDeast")
local comPowerSource = Unit.getByName("GPUeast")
iranIADS:addCommandCenter(commandCenter):addPowerSource(comPowerSource)

local commandCenter = Unit.getByName("CMDfareast")
local comPowerSource = Unit.getByName("GPUfareast")
iranIADS:addCommandCenter(commandCenter):addPowerSource(comPowerSource)


local connectionNode = Unit.getByName("NODEwest")
local powerSource = Unit.getByName("SAM-SA-9GPU")
ewRadar = iranIADS:getEarlyWarningRadarByUnitName('EW-west')
ewRadar:addConnectionNode(connectionNode):addPowerSource(powerSource)


local connectionNode = Unit.getByName("NODEwest")
local powerSource = Unit.getByName("SAM-ShilkaGPU")
ewRadar = iranIADS:getEarlyWarningRadarByUnitName('EW-west2')
ewRadar:addConnectionNode(connectionNode):addPowerSource(powerSource)


local connectionNode = Unit.getByName("NODEwest")
local powerSource = Unit.getByName("SAM-SA-19GPU")
ewRadar = iranIADS:getEarlyWarningRadarByUnitName('EW-west3')
ewRadar:addConnectionNode(connectionNode):addPowerSource(powerSource)


local connectionNode = Unit.getByName("NODEeast")
local powerSource = Unit.getByName("GPUeast")
ewRadar = iranIADS:getEarlyWarningRadarByUnitName('EW-east')
ewRadar:addConnectionNode(connectionNode):addPowerSource(powerSource)


local connectionNode = Unit.getByName("NODEeast")
local powerSource = Unit.getByName("SAM-SA-15-point-defence-EWeast2GPU")
ewRadar = iranIADS:getEarlyWarningRadarByUnitName('EW-east2')
ewRadar:addConnectionNode(connectionNode):addPowerSource(powerSource)


local connectionNode = Unit.getByName("NODEeast")
local powerSource = Unit.getByName("SAM-SA-11GPU")
ewRadar = iranIADS:getEarlyWarningRadarByUnitName('EW-east3')
ewRadar:addConnectionNode(connectionNode):addPowerSource(powerSource)


local connectionNode = Unit.getByName("NODEcentral")
local powerSource = Unit.getByName("EWcenterGPU")
ewRadar = iranIADS:getEarlyWarningRadarByUnitName('EW-center')
ewRadar:addConnectionNode(connectionNode):addPowerSource(powerSource)


local connectionNode = Unit.getByName("NODEcentral")
local powerSource = Unit.getByName("SAM-SA-8GPU")
ewRadar = iranIADS:getEarlyWarningRadarByUnitName('EW-center2')
ewRadar:addConnectionNode(connectionNode):addPowerSource(powerSource)


local connectionNode = Unit.getByName("NODEcentral")
local powerSource = Unit.getByName("SAM-SA-3GPU2")
ewRadar = iranIADS:getEarlyWarningRadarByUnitName('EW-center3')
ewRadar:addConnectionNode(connectionNode):addPowerSource(powerSource)

local connectionNode = Unit.getByName("NODEwest") 
iranIADS:getSAMSites()iranIADS:getSAMSiteByGroupName('SAM-Shilka-SPAAA'):setActAsEW(false):addConnectionNode(connectionNode):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE):setGoLiveRangeInPercent(90):setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI)

local connectionNode = Unit.getByName("NODEwest")
local powerSource = Unit.getByName("SAM-SA-2GPU")  
iranIADS:getSAMSites()iranIADS:getSAMSiteByGroupName('SAM-SA-2'):setActAsEW(false):addPowerSource(powerSource):addConnectionNode(connectionNode):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE):setGoLiveRangeInPercent(90):setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI)

local connectionNode = Unit.getByName("NODEwest")
local powerSource = Unit.getByName("SAM-SA-9GPU")  
iranIADS:getSAMSites()iranIADS:getSAMSiteByGroupName('SAM-SA-9'):setActAsEW(false):addPowerSource(powerSource):addConnectionNode(connectionNode):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE):setGoLiveRangeInPercent(90):setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI)

local connectionNode = Unit.getByName("NODEwest")
local powerSource = Unit.getByName("SAM-SA-19GPU")  
iranIADS:getSAMSites()iranIADS:getSAMSiteByGroupName('SAM-SA-19'):setActAsEW(false):addPowerSource(powerSource):addConnectionNode(connectionNode):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE):setGoLiveRangeInPercent(90):setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI)

local connectionNode = Unit.getByName("NODEwest")
iranIADS:getSAMSites()iranIADS:getSAMSiteByGroupName('SAM-SA-15'):setActAsEW(false):addConnectionNode(connectionNode):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE):setGoLiveRangeInPercent(90):setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI)

local connectionNode = Unit.getByName("NODEwest")
iranIADS:getSAMSites()iranIADS:getSAMSiteByGroupName('SAM-SA-15-EWwest-point-defence'):setActAsEW(false):addConnectionNode(connectionNode):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE):setGoLiveRangeInPercent(90):setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI)

local connectionNode = Unit.getByName("NODEcentral")
local powerSource = Unit.getByName("SAM-SA-3GPU")  
iranIADS:getSAMSites()iranIADS:getSAMSiteByGroupName('SAM-SA-3'):setActAsEW(false):addPowerSource(powerSource):addConnectionNode(connectionNode):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE):setGoLiveRangeInPercent(90):setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI)

local connectionNode = Unit.getByName("NODEcentral")
local powerSource = Unit.getByName("SAM-SA-6GPU")  
iranIADS:getSAMSites()iranIADS:getSAMSiteByGroupName('SAM-SA-6'):setActAsEW(false):addPowerSource(powerSource):addConnectionNode(connectionNode):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE):setGoLiveRangeInPercent(90):setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI)

local connectionNode = Unit.getByName("NODEcentral")
iranIADS:getSAMSites()iranIADS:getSAMSiteByGroupName('SAM-SA-8'):setActAsEW(false):addConnectionNode(connectionNode):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE):setGoLiveRangeInPercent(90):setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI)

local connectionNode = Unit.getByName("NODEcentral")
local powerSource = Unit.getByName("SAM-Bandar-Abbas-mobile-power")  
iranIADS:getSAMSites()iranIADS:getSAMSiteByGroupName('SAM-SA-10-S-300-Bandar-Abbas'):setActAsEW(false):addPowerSource(powerSource):addConnectionNode(connectionNode):setGoLiveRangeInPercent(80):setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI)

local connectionNode = Unit.getByName("NODEcentral")
iranIADS:getSAMSites()iranIADS:getSAMSiteByGroupName('SAM-Bandar-Abbas-point-defence'):setActAsEW(false):addConnectionNode(connectionNode):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE):setGoLiveRangeInPercent(90):setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI)

local connectionNode = Unit.getByName("NODEcentral")
local powerSource = Unit.getByName("Rapier-FSA-central-power-supply")
iranIADS:getSAMSites()iranIADS:getSAMSiteByGroupName('SAM-Rapier-FSA-central'):setActAsEW(false):addPowerSource(powerSource):addConnectionNode(connectionNode):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE):setGoLiveRangeInPercent(90):setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI)

local connectionNode = Unit.getByName("NODEeast")
iranIADS:getSAMSites()iranIADS:getSAMSiteByGroupName('SAM-SA-13'):setActAsEW(false):addConnectionNode(connectionNode):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE):setGoLiveRangeInPercent(90):setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI)

local connectionNode = Unit.getByName("NODEeast")
local powerSource = Unit.getByName("SAM-SA-11GPU")  
iranIADS:getSAMSites()iranIADS:getSAMSiteByGroupName('SAM-SA-11'):setActAsEW(false):addPowerSource(powerSource):addConnectionNode(connectionNode):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE):setGoLiveRangeInPercent(90):setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI)

local connectionNode = Unit.getByName("NODEeast")
iranIADS:getSAMSites()iranIADS:getSAMSiteByGroupName('SAM-SA-15-point-defence-EWeast2'):setActAsEW(false):addConnectionNode(connectionNode):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE):setGoLiveRangeInPercent(90):setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI)

local connectionNode = Unit.getByName("NODEfareast")
local powerSource = Unit.getByName("SAM-SA-10GPU")  
iranIADS:getSAMSites()iranIADS:getSAMSiteByGroupName('SAM-SA-10'):setActAsEW(true):addPowerSource(powerSource):addConnectionNode(connectionNode):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE):setGoLiveRangeInPercent(90):setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI)

local connectionNode = Unit.getByName("NODEfareast")
iranIADS:getSAMSites()iranIADS:getSAMSiteByGroupName('SAM-SA-15-point-defence-SA-10'):setActAsEW(false):addConnectionNode(connectionNode):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE):setGoLiveRangeInPercent(90):setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI)

local connectionNode = Unit.getByName('NODEcentral')
iranIADS:getSAMSiteByGroupName('SAM-SA-10'):addConnectionNode(connectionNode)

local connectionNode = Unit.getByName('NODEeast')
iranIADS:getSAMSiteByGroupName('SAM-SA-10-S-300-Bandar-Abbas'):addConnectionNode(connectionNode)

iranIADS:addEarlyWarningRadar('AWACS-K-50')

local connectionNode = Unit.getByName('NODEeast')
ewRadar = iranIADS:getEarlyWarningRadarByUnitName('AWACS-K-50')
ewRadar:addConnectionNode(connectionNode)

local connectionNode = Unit.getByName('NODEfareast')
ewRadar = iranIADS:getEarlyWarningRadarByUnitName('AWACS-K-50')
ewRadar:addConnectionNode(connectionNode)

local connectionNode = Unit.getByName('NODEcentral')
ewRadar = iranIADS:getEarlyWarningRadarByUnitName('AWACS-K-50')
ewRadar:addConnectionNode(connectionNode)

local connectionNode = Unit.getByName('NODEwest')
ewRadar = iranIADS:getEarlyWarningRadarByUnitName('AWACS-K-50')
ewRadar:addConnectionNode(connectionNode)

local jammerSource = Unit.getByName("JAMMER-Norman")
jammer = SkynetIADSJammer:create(jammerSource)
jammer:addIADS(iranIADS)
jammer:masterArmOn()

local jammerSource = Unit.getByName("JAMMER-Harry")
jammer = SkynetIADSJammer:create(jammerSource)
jammer:addIADS(iranIADS)
jammer:masterArmOn()

iranIADS:addRadioMenu()

iranIADS:activate()
end