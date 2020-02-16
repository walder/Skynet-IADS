# Skynet-IADS
![logo](https://github.com/walder/Skynet-IADS/raw/master/images/SA3_2.jpg)

An IADS (Integrated Air Defence System) script for DCS (Digital Combat Simulator).

# Abstract
This script simulates an IADS within the scripting possibilities of DCS. Early Warning Radar Stations (EW Radar) scan the sky for contacts. These contacts are correlated with SAM (Surface to Air Missile) Sites. If a contact is within firing range of the SAM Site it will become active. A modern IADS also depends on command centers and datalinks to the SAM Sites. The IADS can be set up with this infrastructure. Destroying it will degrade the capability of the IADS.

# IADS Elements

## IADS
The IADS doesn't exist as a physical object in the game world. Think of it as the network holding everything together. You can have multiple IADS instances in a DCS Mission. However individual IADS currently don't communicate between each other. Also don't add units to more than one Skynet IADS. You have seen the films, you know what happens when Skynet goes bananas.

## SAM Site
Skynet can handle 0-n Sam Sites. By default Skynet keeps SAM Sites turned off. It calculates if a contact is within firing range of a SAM Site. Every single launcher and radar unit's distance is analysed individually. If at least one launcher and radar is within range, the SAM Site will become active. This allows for a scattered placemend of radar and launcher units as in real life.

Please make sure the SAM Group in the mission editor consists only of one type. eg don't add SA-10 units with SA-6 units, this will mess up the distance calculation.

The Skill level you set on a SAM Group is retained by Skynet.

##  Early Warning Radar
Skynet can handle 0-n EW Radars. For detection of a target the DCS radar detection logic is used. You can use any type of radar for EW in Skynet. Some modern SAM Units have longer range radars then the EW Radars, eg S300 vs EWR 55G6.

##  Power Sources
By default Skynet IADS will run without having to add power sources. You can add power sources to SAM Units, EW Radars and Command Centers. A power source can be a unit oder static object in DCS. I recommend using the electric power box static object. Feel free to use the air show crowd, it will also work. 

Once a power source is fully damaged the linked Skynet IADS unit will stop working. You can add multiple power sources to a Skynet IADS unit.

Taking out the power source of a command center is a real life tactic used in Suppression of Enemy Air Defence (SEAD).

## Connection Nodes
By default Skynet IADS will run without having to add connection nodes. You can add connection nodes to SAM Units, EW Radars and Command Centers. Currently only one link between the IADS and a unit is supported. 

When a connection node is fully damaged the the unit disconnected from the IADS will go in to autonomous mode. For a SAM Unit this means it will behave in its autonomous mode setting. If a command center looses its node all SAM Sites will go autonomous. If a EW Radar looses its node it will no longer contribute information to the IADS but otherwise the IADS will still work. 

A single node can be used to connect an arbitrary number of Skynet IADS units. This way cou can add a single point of failure in to an IADS.

## Air Resources
Currently Skynet only works with ground based units. Incorporating air units is planned at a later date.

# Electronic Warfare
In this release there is no electronic warfare functionallity. It will be aded in a later release.

# Using it in the mission editor
Skynet requires MIST. A version is provided in this repository or you can download the most current version [here](https://github.com/mrSkortch/MissionScriptingTools).

#  Example Code
Think of yourself as the general planning the IADS.

## Quick setup

create an instance of the IADS:  
`iranianIADS = SkynetIADS:create()` 

Give all SAM groups you want to add a common prefix eg: 'SAM-SA-10 west', add this line of code:
`iranIADS:addSamSitesByPrefix('SAM')` 

Same for the EW radars, name all units with a common prefix eg: 'EW-radar-south':
`iranIADS:addEarlyWarningRadarsByPrefix('EW')` 

Avtivate the IADS: 
`iranIADS:activate()` 

## Advanced Setup

The advanced setup alows you to add a SAM Site individually and add connection nodes and power sources.

Add an early warning radar with a power source and a connection node. Make sure the Units and StaticObjects exist in the mission:  
`earlyWarningRadar = Unit.getByName('EWR')`  
`ewPower = StaticObject.getByName("EW Power Source")`    
`ewConnectionNode = StaticObject.getByName("EWR Connection Node")`    
`nevadaIADS:addEarlyWarningRadar(earlyWarningRadar, ewPower, ewConnectionNode))`  

You can also just add an EW Radar omitting the power source and connection node:  
`nevadaIADS:addEarlyWarningRadar(earlyWarningRadar)`

Add a SAM Site like this:  
`powerSource = StaticObject.getByName("SA6-PowerSource")`  
`sa6Site2 = Group.getByName('SA6 Group2')`   
`connectionNode = StaticObject.getByName("Connection Node")`   
`nevadaIADS:addSamSite(sa6Site2, powerSource, connectionNode, SkynetIADSSamSite.AUTONOMOUS_STATE_DARK)`  

The autonomous mode options are:  
`SkynetIADSSamSite.AUTONOMOUS_STATE_DARK` = SAM Site will go dark if it looses connection to IADS  
`SkynetIADSSamSite.AUTONOMOUS_STATE_DCS_AI` = SAM Site will behave in the default DCS AI. Alarm State will be red and ROE weapons free.

You can also just add a SAM site omitting power source and connection node:  
`nevadaIADS:addSamSite(sa6Site2)`

Add a command center (optional):  
`commandCenter = StaticObject.getByName("Command Center")`    
`nevadaIADS:addCommandCenter(commandCenter)`

Wake up the IADS:  
`nevadaIADS:activate()`  

# Thanks
Special thaks to Spearzone and Coranthia for researching public available information on IADS networks and getting me up to speed on how such a system works.
Also I shamelessly incorporated Grimes SAM DB.
