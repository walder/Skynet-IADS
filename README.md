# Skynet-IADS
![logo](https://github.com/walder/Skynet-IADS/raw/master/images/SA3_2.jpg)

An IADS (Integrated Air Defence System) script for DCS (Digital Combat Simulator).

# Abstract
This script simulates an IADS within the scripting possibilities of DCS. Early Warning Radar Stations (EW Radar) scan the sky for contacts. These contacts are correlated with SAM (Surface to Air Missile) sites. If a contact is within firing range of the SAM site it will become active.

A modern IADS also depends on command centers and datalinks to the SAM sites. The IADS can be set up with this infrastructure. Destroying it will degrade the capability of the IADS.

This all sounds gibberish to you? Watch [this video by Covert Cabal on modern IADS](https://www.youtube.com/watch?v=kHV12DPE1kk).

Visit [this DCS forum thread](https://forums.eagle.ru/showthread.php?p=4221918) for development updates.

# Quick start
Tired of reading already? Download the [demo mission](https://github.com/walder/Skynet-IADS/blob/master/demo-missions/skynet-test-persian-gulf.miz) in the persian gulf map and see what Skynet in action. More complex demo missions will follow soon.

# Skynet IADS Elements
![Skynet IADS overview](https://github.com/walder/Skynet-IADS/raw/master/images/skynet-overview.jpeg)

## IADS
A Skynet IADS is a complete operational network. You can have multiple Skynet IADS instances per coalition in a DCS mission. A simple setup would be one IADS for the blue side and one IADS for the red side.

## Track files
Skynet keeps a global track file of all detected targets. It queries all its units with radars and deduplicates contacts. By default lost contacts are stored up to 32 seconds in memory. 

## Comand Center
You can add 0-n command centers to a Skynet IADS. Once all command centers are destroyed the IADS will go in to autonomous mode.

## SAM Site
Skynet can handle 0-n SAM sites, it will try and keep emissions to a minimum, therefore SAM sites will be turned on only if a target is in range. Every single launcher and radar unit's distance of a SAM site is analysed individually. If at least one launcher and radar is within range, the SAM Site will become active. This allows for a scattered placement of radar and launcher units as in real life.

## Early Warning Radar
Skynet can handle 0-n EW radars. For detection of a target the DCS radar detection logic is used. You can use any type of radar in an EW role in Skynet. 
Some modern SAM radars have a greater detection range than older EW radars, e.g. the S-300PS 64H6E (160 km) vs EWR 55G6 (120 km).

You can also designate SAM Sites to act as EW radars, in this case a SAM site will constantly have their radar on. Long range systems like the S-300 are used as EW radars in real life.

Nice to know:
Terrain elevation around an EW radar will create blinds spots, allowing low and fast movers to penetrate radar networks through valleys.

##  Power Sources
By default Skynet IADS will run without having to add power sources. You can add 0-n power sources to SAM units, EW radars and command centers.
Once a power source is fully damaged the Skynet IADS unit will stop working.

Nice to know:
Taking out the power source of a command center is a real life tactic used in SEAD (Suppression of Enemy Air Defence).

## Connection Nodes
By default Skynet IADS will run without having to add connection nodes. You can add 0-n connection nodes to SAM Units, EW Radars and Command Centers.

When all the unit's connection nodes are fully damaged the unit will go in to autonomous mode. For a SAM unit this means it will behave in its autonomous mode setting. If an EW Radar looses its node it will no longer contribute information to the IADS but otherwise the IADS will still work. 

Nice to know:
A single node can be used to connect an arbitrary number of Skynet IADS units. This way you can add a single point of failure in to an IADS.

## Air Resources
Currently Skynet only works with ground based units. Incorporating air units is planned at a later date.

# Tactics

## HARM defence
SAM sites and EW radars will shut down their radars if they believe a HARM (High speed anti radiation missile) is heading for them. For this to happen, the SAM site has to detect the HARM missile with its radar. The SAM site will then calculate the probable impact point of the HARM, if it determines it is within 100 m of a radar it will shut down.

SAM site and EW radars will react to bombs, air to ground missiles and even aircraft (when on a Kamikazee attack) in the same way. The site will shut down between 1 and 3 minutes. This implementation is closer to real life. SAM Sites like the patriot calculate the flight path and analyse the radar cross section to determine if a contact heading inbound is a HARM.

Since impact point calculation is almost always perfect in DCS there is also a reaction probability involved, newer SAM systems will have a higher probabilty than older ones in detecting an inbound HARM missile. See [skynet-iads-sam-types-db-extension.lua](https://github.com/walder/Skynet-IADS/blob/master/skynet-iads-source/skynet-iads-sam-types-db-extension.lua) for the probability per SAM system.

## Electronic Warfare
A simple form of jamming is part of the Skynet IADS package. It's off by default. The jamming works by setting the ROE state of a SAM Site. The closer you get to a SAM site the more ineffective the jamming will become. For the jammer to work it will need LOS (line of sight) to a radar unit. 
Older SAM sites are more susceptible to jamming. EW radars are currently not jammable.

Here is a [list of SAM sites currently supported by the jammer](https://docs.google.com/spreadsheets/d/16rnaU49ZpOczPEsdGJ6nfD0SLPxYLEYKmmo4i2Vfoe0/edit#gid=0) and its effectiveness on them. 
When setting up a jammer you can decide which SAM sites it is able to jam. For example you could design a mission in which the jammer is not able to jam a SA-6 but is able to jam a SA-2. The jammer effeciveness is not based on any real world data I just read about the different types and made my own conclusions.
In the mission editor you add the jammer to a unit. I suggest you take an F-111 as jammer plattform and add it to your strike package.

# Using Skynet in the mission editor
It's quite simple to setup an IADS have a look at the demo missions in the [/demo-missions/](https://github.com/walder/Skynet-IADS/tree/master/demo-missions) folder.

## Placing units
This tutorial assumes you are familiar on how to set up a SAM site in DCS. If not I suggest you watch [this video](https://www.youtube.com/watch?v=YZPh-JNf6Ww) by the Grim Reapers.
Place the IADS elements you wish to add on the map. Currently only russian units have been tested although western units should work just as fine.
![Mission Editor IADS Setup](https://github.com/walder/Skynet-IADS/raw/master/images/iads-setup.png)  

## Preparing a SAM site
There should be only be one SAM site type per group. If differenct SAM sites are mixed in one group distance calculation for the IADS will be messed up. Don't do it you have seen the films, you know what happens when Skynet goes bananas.
The skill level you set on a SAM group is retained by Skynet. Make sure you name the **SAM site group** in a consistent manner with a prefix e.g. 'SAM-SA-2'.  
![Mission Editor add SAM site](https://github.com/walder/Skynet-IADS/raw/master/images/add-sam-site.png)  

## Preparing an EW radar
You can use any type of radar as an EW radar. Make sure you **name the unit** in a consistent manner with a prefix, e.g. 'EW-center3'.  
![Mission Editor EW radar](https://github.com/walder/Skynet-IADS/raw/master/images/ew-setup.png)  

## Adding the Skynet Code
Skynet requires MIST. A version is provided in this repository or you can download the most current version [here](https://github.com/mrSkortch/MissionScriptingTools).
Make sure you load MIST and the compiled skynet code in to a mission. The [skynet-iads-compiled.lua](https://github.com/walder/Skynet-IADS/tree/master/demo-missions/skynet-iads-compiled.lua) and [mist_4_3_74.lua](https://github.com/walder/Skynet-IADS/tree/master/demo-missions/mist_4_3_74.lua) files are located in the [/demo-missions/](https://github.com/walder/Skynet-IADS/tree/master/demo-missions) folder. 
![Mission Editor IADS Setup](https://github.com/walder/Skynet-IADS/raw/master/images/load-scripts.png)  

## Setting up yor IADS
I recommend you create a text file e.g. 'my-iads-setup.lua' and then add the code needed to get the IADS runing. When updating the setup remember to reload the file in the mission editor. Otherwise changes will not become effective.
You can also add the code directly in the mission editor, however that input field is quite small if you write more than a few lines of code.
![Mission Editor IADS Setup](https://github.com/walder/Skynet-IADS/raw/master/images/iads-setup-code.png)  

## Adding the Skynet IADS
For the IADS to work you need three lines of code:

create an instance of the IADS:  
```
redIADS = SkynetIADS:create()
``` 

Give all SAM groups you want to add a common prefix in the mission editor eg: 'SAM-SA-10 west', then add this line of code:  
```
redIADS:addSamSitesByPrefix('SAM')
``` 

Same for the EW radars, name all units with a common prefix in the mission editor eg: 'EW-radar-south':  
```
redIADS:addEarlyWarningRadarsByPrefix('EW')
``` 

Activate the IADS:  
```
redIADS:activate()
```

## Advanced setup
This is the danger zone. Call Kenny Loggins. Some experience with scripting is recommended.
You can handcraft your IADS with the following functions. If you refrence units that don't exist a message will be displayed when the mission loads.
The following examples use static objects for command centers and power sources, you can also use units instead.

### Adding a command center
The command center represents the place where information is collected and analysed. It if is destroyed the IADS disintegrates.

Add a command center like this:
```
local commandCenter = StaticObject.getByName("Command Center")
redIADS:addCommandCenter(commandCenter)
```

You can also add a command center with a power source:
```
local commandCenter = StaticObject.getByName("Command Center2")
local comPowerSource = StaticObject.getByName("Command Center2 Power Source")
redIADS:addCommandCenter(commandCenter, comPowerSource)
```

## SAM site options
You can set the following options for a SAM site: 

### Act as EW radar
Will set the SAM site to act as an EW radar. This will result in the SAM site always having its radar on. Contacts the SAM site sees are reported to the IADS. This option is recomended for long range systems like the S-300. 
```
samSite:setActAsEW(true)
```

### Power sources and connection nodes
Add a power source to a SAM Site. You can add Units and StaticObjects. Call the function multiple times to add more than one power source:
```
local powerSource = StaticObject.getByName("SA-6 Power Source")  
samSite:addPowerSource(powerSource)
```

Add a connection node to a SAM site. You can add Units and StaticObjects. Call the function multiple times to add more than one connection node:
```
local connectionNode = Unit.getByName("SA-6 connection node") 
samSite:addConnectionNode(connectionNode)
```

### Engagement zone
Set the distance at which a SAM site wil switch on its radar.
```
samSite:setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
```

***The engagement zone options are:***

SAM site will go live when target is within the red circle in the mission editor (default Skynet behaviour): 
```
SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE
```

SAM site will go live when target is within the yelow circle in the mission editor: 
```
SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE
```

This option sets the range in relation to the zone you set in setEngagementZone when a SAM site wil go live. Be carefull not to set the value too low. Some SAM sites need up to 30 seconds until they can fire. If you set this too low, the target will pass over the cone of silence of a SAM site.
```
samSite:setGoLiveRangeInPercent(90)
```

### Autonomous mode behaviour
Set how the SAM site will behave if it looses connection to the IADS:
```
samSite:setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK)
```

***The autonomous mode options are:*** 
SAM Site will behave in the default DCS AI. Alarm State will be red and ROE weapons free (default Skynet behaviour):
```
SkynetIADSSamSite.AUTONOMOUS_STATE_DCS_AI
```

SAM Site will go dark if it looses connection to IADS:
```
SkynetIADSSamSite.AUTONOMOUS_STATE_DARK
```

### How to set the options
You can daisy chain the values like this:
```
redIADS:getSamSites():setActAsEW(true):addPowerSource(powerSource):addConnectionNode(connectionNode):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE):setGoLiveRangeInPercent(90):setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK)
```

### Accessing SAM sites in the IADS

The following functions exist to access SAM sites added to the IADS. They all support daisy chaining options:

Returns all SAM sites with the corresponding Nato name, see [sam-types-db.lua](https://github.com/walder/Skynet-IADS/blob/master/skynet-iads-source/sam-types-db.lua). Don't add Nato code names like Grumble, Gainful, just wite SA-6, SA-9.
```
redIADS:getSAMSitesByNatoName('SA-6')
```

Returns all SAM sites in the IADS:
```
redIADS:getSamSites()
```

Adds SAM sites with prefix in group name to the IADS. Make sure you only call this method once:
```
redIADS:addSamSitesByPrefix('SAM')
```

Returns a SAM site with the specified group name:
```
redIADS:getSAMSiteByGroupName('SAM-SA-6')
```

## EW radar options
EW radars support the following options:

### Power sources and connection nodes
Add a power source to a EW Site. You can add Units and StaticObjects. Call the function multiple times to add more than one power source:
```
local powerSource = StaticObject.getByName("EW Power Source")  
ewRadar:addPowerSource(powerSource)
```

Add a connection node to a SAM site. You can add Units and StaticObjects. Call the function multiple times to add more than one connection node:
```
local connectionNode = Unit.getByName("EW connection node") 
ewRadar:addConnectionNode(connectionNode)
```

### Accessing EW radars in the IADS

The following functions exist to access EW radars added to the IADS. They all support daisy chaining options:  

Adds EW sites with prefix in unit name to the IADS. Make sure you only call this method once.
```
redIADS:addEarlyWarningRadarsByPrefix("EW")
```

Returns all EW sites in the IADS:
```
redIADS:getEarlyWarningRadars()
```

Returns the EW site with the specified unit name:
```
redIADS:getEarlyWarningRadarByUnitName('EW-west')
```

## Adding units manually
You can add IADS elements individually. Use this if of you want to add units based on some kind of some progress in a mission.

Add an EW radar, must be a unit name:  
```
redIADS:addEarlyWarningRadar('EWR West')
```

Add a SAM site, must be a group name:
```
redIADS:addSamSite('SA-6 Group2')
```

## Adding a jammer
The jammer is quite easy to set up. You need a unit that acts as an emitter. Once the jammer detects an emitter it starts jamming the radar.
Set the coresponding debug level to see what the jammer is doing.
```
local jammerSource = Unit.getByName("Player Hornet")
jammer = SkynetIADSJammer:create(jammerSource)
jammer:addIADS(redIADS)
-- sets the jammer to listen for emitters
jammer:masterArmOn()
```
You can disable the jammer for a certain SAM type.  
The jammable SAM Types are: SA-2, SA-3, SA-6, SA-10, SA-11, SA-15:
```
jammer:disableFor('SA-2')
```
You can turn the jammer off like this:
```
jammer:masterArmOff()
```

### Debug information
When developing a mission I suggest you add debug output to check how the IADS reacts to threats:

```
local iadsDebug = redIADS:getDebugSettings()  
iadsDebug.IADSStatus = true
iadsDebug.samWentDark = true
iadsDebug.contacts = true
iadsDebug.radarWentLive = true
iadsDebug.ewRadarNoConnection = true
iadsDebug.samNoConnection = true
iadsDebug.jammerProbability = true
iadsDebug.addedEWRadar = true
iadsDebug.hasNoPower = true
iadsDebug.addedSAMSite = true
iadsDebug.warnings = true
```
![Mission Editor IADS Setup](https://github.com/walder/Skynet-IADS/raw/master/images/skynet-debug.png)  

# Thanks
Special thaks to Spearzone and Coranthia for researching public available information on IADS networks and getting me up to speed on how such a system works.
Also I shamelessly incorporated [Grimes SAM DB](https://forums.eagle.ru/showthread.php?t=118175) from his IADS script.

# FAQ

## What air defence units shall I add to the Skynet IADS?
In theory you can add all the types that are listed in the [sam-types-db.lua](https://github.com/walder/Skynet-IADS/blob/master/skynet-iads-source/sam-types-db.lua) file. 
Types without a radar (some AAA, Manpads) won't really benefit from the IADS. These are better just placed in a mission and handeled by the default AI of DCS. 
This is due to the short range of their weapons. By the time the IADS wakes them up, the contact has likely passed their engagement range.
The strength of the Skynet IADS lies with handling long range systems that operate by radar.

## How do I set up a point defence?
As of March 2020 only the Tor (Nato name SA-15 Gauntlet) is able to engage HARMs on the red side. Place the SA-15s as separate SAM groups next to a larger SAM group like the S-300. Skynet will turn off the SA-15's radar. Once a HARM is in range of the SA-15 it will go live and engage the inbound HARM.




