# Skynet-IADS
![logo](/images/SA3_2.jpg)

An IADS (Integrated Air Defence System) script for DCS (Digital Combat Simulator).

# Abstract
This script simulates an IADS within the scripting possibilities of DCS. Early Warning Radar Stations (EW Radar) scan the sky for contacts. These contacts are correlated with SAM (Surface to Air Missile) sites. If a contact is within firing range of the SAM site it will become active.

A modern IADS also depends on command centers and datalinks to the SAM sites. The IADS can be set up with this infrastructure. Destroying it will degrade the capability of the IADS.

You can also connect [Skynet with the AI_A2A_DISPATCHER](#how-do-i-connect-skynet-with-the-moose-ai_a2a_dispatcher-and-what-are-the-benefits-of-that) by MOOSE to add interceptors to the IADS.

This all sounds gibberish to you? Watch [this video by Covert Cabal on modern IADS](https://www.youtube.com/watch?v=9J9kntzkSQY).

Visit [this DCS forum thread](https://forums.eagle.ru/showthread.php?p=4221918) for development updates.

Join the [Skynet discord group](https://discord.gg/pz8wcQs) and get support setting up your mission.



**So far over 200 hours of work went in to the development of Skynet.  
If you like using it, please consider a donation:**

[![Skynet IADS donation](/images/btn_donateCC_LG.gif.png)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=7GSVFH448BWFQ&source=url)




{TOC_PLACEHOLDER}

# Quick start
Tired of reading already? Download the [demo mission](/demo-missions/skynet-test-persian-gulf.miz) in the persian gulf map and see Skynet in action. More complex demo missions will follow soon.

# Skynet IADS Elements
![Skynet IADS overview](/images/skynet-overview.jpeg)

## IADS
A Skynet IADS is a complete operational network. You can have multiple Skynet IADS instances per coalition in a DCS mission. A simple setup would be one IADS for the blue side and one IADS for the red side.

## Track files
Skynet keeps a global track file of all detected targets. It queries all its units with radars and deduplicates contacts. By default lost contacts are stored up to 32 seconds in memory. 

## Comand Centers
You can add 0-n command centers to a Skynet IADS. Once all command centers are destroyed the IADS will go in to autonomous mode.

## SAM Sites
Skynet can handle 0-n SAM sites, it will try and keep emissions to a minimum, therefore by default SAM sites will be turned on only if a target is in range. 
Every single launcher and radar unit's distance of a SAM site is analysed individually. 
If at least one launcher and radar is within range, the SAM Site will become active. 
This allows for a scattered placement of radar and launcher units as in real life.

If SAM sites or radar guided AAA run out of ammo they will go dark. In the case of a SAM site it will wait with going dark as long as the last fired missile is still in the air.

If an EW radar or a SAM site acting as EW radar is destoyed surrounding SAM sites can be left withouth EW radar coverage. This can also happen if a SAM site is outside of AWACS coverage.
SAM sites will go autonomous in such a case meaning they will use their organic radars or just stay dark depending on setup.
Once a SAM site is within EW radar coverage again it will be updated by the IADS.

## Early Warning Radars
Skynet can handle 0-n EW radars. For detection of a target the DCS radar detection logic is used. You can use any type of radar listed after the comment ```--- Start of EW radars:``` in [skynet-iads-supported-types.lua](/skynet-iads-source/skynet-iads-supported-types.lua) in an EW role in Skynet. 
Some modern SAM radars have a greater detection range than older EW radars, e.g. the S-300PS 64H6E (160 km) vs EWR 55G6 (120 km).

You can also designate SAM sites to act as EW radars, in this case a SAM site will constantly have their radar on. Long range systems like the S-300 are used as EW radars in real life.
SAM sites that are out of ammo will stay live if they are set to act as EW radars.

Nice to know:
Terrain elevation around an EW radar will create blinds spots, allowing low and fast movers to penetrate radar networks through valleys.

##  Power Sources
By default Skynet IADS will run without having to add power sources. You can add 0-n power sources to SAM units, EW radars and command centers.
Once a power source is fully damaged the Skynet IADS unit will stop working.

Nice to know:
Taking out the power source of a command center is a real life tactic used in SEAD (Suppression of Enemy Air Defence).

## Connection Nodes
By default Skynet IADS will run without having to add connection nodes. You can add 0-n connection nodes to SAM units and EW radars.

When all the unit's connection nodes are fully damaged the unit will go in to autonomous mode. For a SAM unit this means it will behave in its autonomous mode setting. If an EW Radar looses its node it will no longer contribute information to the IADS but otherwise the IADS will still work. 

Nice to know:
A single node can be used to connect an arbitrary number of Skynet IADS units. This way you can add a single point of failure in to an IADS.

## AWACS (Airborne Early Warning and Control System)
Any aircraft with an air to air radar can be added as AWACS. Contacts detected will be added to the IADS. The AWACS will also detect ground units like ships.
These will however not be passed to the SAM sites.

You can add a connection node for the AWACS like an antenna, if it is destroyed, the AWACS will no longer be able to contribute contacts to the IADS.
Technically you can also add a power source. In this context it would represent the power source for the connection node, since an aircraft provides its own power.

## Ships
Ships will contribute to the IADS the same way AWACS units do. Add them as a regular EW radar. 

# Tactics

## HARM defence
SAM sites and EW radars will shut down their radars if they believe a HARM (High speed anti radiation missile) is heading for them. For this to happen, the SAM site has to detect the HARM missile with its radar. 
The SAM site will then calculate the probable impact point of the HARM, if it determines it is within 100 m of a radar it will shut down.

SAM sites and EW radars will react to air to ground missiles and even aircraft (when on a Kamikazee attack) in the same way. They currently don't react to bombs, since they are not detected by DCS radars. 
The site will calculate time to impact and shut down a random value between a few seconds after time to impact and 180 seconds after time to impact. 

This implementation is closer to real life. SAM sites like the patriot calculate the flight path and analyse the radar cross section to determine if a contact heading inbound is a HARM.

Since impact point calculation is almost always perfect in DCS there is also a reaction probability involved, newer SAM systems will have a higher probabilty than older ones in detecting an inbound HARM missile. 
See [skynet-iads-supported-types.lua](/skynet-iads-source/skynet-iads-supported-types.lua) field ```['harm_detection_chance']``` for the probability per SAM system.

## Point defence
When a radar emitter (EW radar or SAM site) is attacked by a HARM there is a chance it may detect the HARM and go dark. If this radar emitter is acting as the sole EW radar in the area, surrounding SAM sites will not be able to go live since they rely on the EW radar for target information.
This is an issue if you have SA-15 Tors next to the EW radar for point defence protection. They will stay dark and not engange the HARM.

You can tell a radar emitter it has a point denfence to rely on. If the radar emitter goes dark due to an inbound HARM it will activate its point defences to fire at the HARM.

You can set the radar emitter to keep emitting when a HARM is inbound as long as the point defence has ammo left. When the point defence is out of ammo the radar emitter will revert back to its previously set HARM defence behaviour.
Use this feature if you don't want the IADS to loose situational awareness just because a HARM is inbound. The radar emitter will shut down, if it believes its point defences won't be able to handle the number of HARMs inbound. 
As long as there is one point defence launcher per HARM inbound the radar emitter will keep emitting. If the HARMs exeed the number of point defence launchers if will shut down. Tests in DCS have shown that this is roughly the saturation point.

As of April 2020 I have only been able to get the SA-15 and the SA-10 to engage HARMS. The SA-10 seems to have dificullty engaging HARMS when they are launched above a certain altitude (in my tests 25 k feet).
The best option for a solid HARM defence is to add SA-15's around EW radars or high value SAM sites.

The SA-15 does not have a HARM detection chance by default in Skynet, since this would mean it would shut down when targeted by a HARM, defeating its purpose.

[Point defence setup example](#point-defence-1)

There's an interesting [documentary on the Tor by RT](https://www.youtube.com/watch?v=objljEE7B6M) (ignore politics and propaganda).

## Electronic Warfare
A simple form of jamming is part of the Skynet IADS package. It's off by default. The jamming works by setting the ROE state of a SAM Site. 
The closer the jamming emitter gets to a SAM site the less effective jamming will become (burn through). For the jammer to work it will need LOS (line of sight) to a radar unit. 
Older SAM sites are more susceptible to jamming. EW radars are currently not jammable.

I recommend you add an AI unit that follows the strike package you're flying in to act as a jammer aircraft. This will give you the most realistic experience. 
The jammer emitter will toggle the ROE state of a SAM site which affects how the SAM site reacts to all threats near or far.

I presume an aircraft very close to a SAM site beeing jammed by a emitter very far away would most likely be detected.
So the farther away you are from the jammer source the more unrealistic your experience will be.

Here is a [list of SAM sites currently supported by the jammer](https://docs.google.com/spreadsheets/d/16rnaU49ZpOczPEsdGJ6nfD0SLPxYLEYKmmo4i2Vfoe0/edit#gid=0) and the jammer's effectiveness on them. 
When setting up a jammer you can decide which SAM sites it is able to jam. For example you could design a mission in which the jammer is not able to jam a SA-6 but is able to jam a SA-2. 
The jammer effectiveness is not based on any real world data I just read about the different types and made my own conclusions.

Here is an old school documentary [showing the Prowler in action](https://www.youtube.com/watch?v=su44ZU7NcQU). They brief to turn on their jamming equipement at 60 nm from the target.
I suppose that must have been the effective range of 70's jamming tech.

# Using Skynet in the mission editor
It's quite simple to setup an IADS have a look at the demo missions in the [/demo-missions/](/demo-missions) folder.

## Placing units
This tutorial assumes you are familiar on how to set up a SAM site in DCS. If not I suggest you watch [this video](https://www.youtube.com/watch?v=YZPh-JNf6Ww) by the Grim Reapers.
Place the IADS elements you wish to add on the map.
![Mission Editor IADS Setup](/images/iads-setup.png)  

## Preparing a SAM site
There may be only be **one SAM site per group**. More than one SAM site per group will result in Skynet no being able to control a single SAM site. Also please refrain from from adding units to the SAM group that are not required for the SAM like trucks, tanks and soldiers.
The skill level you set on a SAM group is retained by Skynet. Make sure you name the **SAM site group** in a consistent manner with a prefix e.g. 'SAM-SA-2'.  
![Mission Editor add SAM site](/images/add-sam-site.png)  

## Preparing an EW radar
You can use any type of radar as an EW radar. Make sure you **name the unit** in a consistent manner with a prefix, e.g. 'EW-center3'. Make sure you have only **one EW radar in a group** otherwise Skynet will not be able to control single EW radars. 
![Mission Editor EW radar](/images/ew-setup.png)  

## Adding the Skynet code
Skynet requires MIST. A version is provided in this repository or you can download the most current version [here](https://github.com/mrSkortch/MissionScriptingTools).
Make sure you load MIST and the compiled skynet code in to a mission. The [skynet-iads-compiled.lua](/demo-missions/skynet-iads-compiled.lua) and [mist_4_3_74.lua](/demo-missions/mist_4_3_74.lua) files are located in the [/demo-missions/](/master/demo-missions) folder. 

I recommend you create a text file e.g. 'my-iads-setup.lua' and then add the code needed to get the IADS runing. When updating the setup remember to reload the file in the mission editor. Otherwise changes will not become effective.
You can also add the code directly in the mission editor, however that input field is quite small if you write more than a few lines of code.
![Mission Editor IADS Setup](/images/load-scripts.png)  

## Adding the Skynet IADS
For the IADS to work you need four lines of code.

create an instance of the IADS, the name string is optional and will be displayed in status output:
```lua
redIADS = SkynetIADS:create('name')
``` 


Give all SAM groups you want to add a common prefix in the mission editor eg: 'SAM-SA-10 west', then add this line of code:  
```lua
redIADS:addSAMSitesByPrefix('SAM')
``` 


Same for the EW radars, name all units with a common prefix in the mission editor eg: 'EW-radar-south':  
```lua
redIADS:addEarlyWarningRadarsByPrefix('EW')
``` 


Activate the IADS:  
```lua
redIADS:activate()
```

# Advanced setup
This is the danger zone. Call Kenny Loggins. Some experience with scripting is recommended.
You can handcraft your IADS with the following functions. If you refrence units that don't exist a message will be displayed when the mission loads.
The following examples use static objects for command centers, connection nodes and power sources, you can also use units instead.

## IADS configuration
Call this method to add or remove a radio menu to toggle the status output of the IADS. By default the radio menu option is not visible:
```lua
redIADS:addRadioMenu()  
```
```lua
redIADS:removeRadioMenu()
```

If you dereference the IADS remember to call ```deactivate()``` otherwise background tasks of the IADS will continue running, resulting in unexpected behaviour:
```lua
redIADS:deactivate()
```

Set the update interval in seconds of the IADS. This determines in what interval the IADS wil turn SAM sites of or on according to targets it has detected:
```lua
redIADS:setUpdateInterval(5)
```

### Warm up the SAM sites of an IADS
Every SAM site starts in a non-active green state on mission load. Calling this function will allow some time for the SAM sites to run through their setup cycle. After that they are frozen in a red state, ready to fire.
This has the advantage that the SAM sites will fire faster after beeing woken up by Skynet. The downside is that for the first few seconds of the mission the SAM sites will activate their radars giving away their position. 

If you start your mission at a friendly base far away from the enemy IADS this in no big deal.
If you start in the air close to the enemy IADS, you might want to refrain from using this function since a player or AI aircraft will see the SAM sites on the radar warning receiver.

This function will not shorten the time from a radar lock until a SAM site fires. It will however reduce total reaction time of a SAM site after beeing notified by Skynet to go live. 

For example: the SA-15 Tor needs roughtly 18 seconds to animate from green state until it fires a missile. It needs roughly 10 seconds to animate in to the red state.
Then it needs another 8 seconds to track and fire. An aircraft will only see the SAM on the RWR (radar warning receiver) for 8 seconds.

 By default Skynet will activate the SAMs for 60 seconds, this should allow enough time for all SAM types to run trough their activation animation:
```lua
redIADS:setupSAMSitesAndThenActivate()
```

You can also pass the number of seconds you would like to warm up the SAM sites if you think 60 seconds is too long:
```lua
redIADS:setupSAMSitesAndThenActivate(30)
```

No separate call to ```redIADS:activate()``` must be made.


### Adding a command center
The command center represents the place where information is collected and analysed. It if is destroyed the IADS disintegrates.

Add a command center like this:
```lua
local commandCenter = StaticObject.getByName("Command Center")
redIADS:addCommandCenter(commandCenter)
```

You can also add a command center with a power source:
```lua
local commandCenter = StaticObject.getByName("Command Center2")
local comPowerSource = StaticObject.getByName("Command Center2 Power Source")
redIADS:addCommandCenter(commandCenter):addPowerSource(comPowerSource)
```

### Connecting Skynet to the MOOSE AI_A2A_DISPATCHER
You can connect Skynet with MOOSE's [AI_A2A_DISPATCHER](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_A2A_Dispatcher.html). This allows the IADS not only to direct SAM sites but also to scramble fighters.
Skynet will set the radars it can use on the SET_GROUP object of a dispatcher. Meaning that if a radar is lost in Skynet it will no longer be availabe to detect and scramble interceptors.

Add the object of type SET_GROUP to the iads like this (in this example ```DectionSetGroup```):
```lua
redIADS:addMooseSetGroup(DetectionSetGroup)
```

## SAM site configuration

### Adding SAM sites

#### Add multiple SAM sites
Adds SAM sites with prefix in group name to the IADS. Previously added SAM sites are cleared:
```lua
redIADS:addSAMSitesByPrefix('SAM')
```

#### Add a SAM site manually
You can manually add a SAM site, must be a valid group name:
```lua
redIADS:addSAMSite('SA-6 Group2')
```

### Accessing SAM sites in the IADS
The following functions exist to access SAM sites added to the IADS. They all support daisy chaining options:

Returns all SAM sites with the corresponding Nato name, see [skynet-iads-supported-types.lua](/skynet-iads-source/skynet-iads-supported-types.lua). For all units beginning with 'SA-': Don't add Nato code names (Guideline, Gainful), just write 'SA-2', 'SA-6':
```lua
redIADS:getSAMSitesByNatoName('SA-6')
```

Returns all SAM sites in the IADS:
```lua
redIADS:getSAMSites()
```

Returns a SAM site with the specified group name:
```lua
redIADS:getSAMSiteByGroupName('SAM-SA-6')
```

Returns a SAM site with the specified group name prefix. Let's say you have a bunch of SAM sites that all will share the same power source. 
Give these sites a special prefix in the group name, e.g.: ```'SAM-SECTOR-A'```. Once you have added the SAM sites you can access them via the prefix to set whatever options you want:

```lua
redIADS:getSAMSitesByPrefix('SAM-SECTOR-A')
```

### Act as EW radar
Will set the SAM site to act as an EW radar. This will result in the SAM site always having its radar on. Contacts the SAM site sees are reported to the IADS. This option is recomended for long range systems like the S-300: 
```lua
samSite:setActAsEW(true)
```

### Engagement zone
Set the distance at which a SAM site will switch on its radar:
```lua
samSite:setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)
```

#### Engagement zone options  

SAM site will go live when target is within the red circle in the mission editor (default Skynet behaviour): 
```lua
SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_KILL_ZONE
```

SAM site will go live when target is within the yelow circle in the mission editor: 
```lua
SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE
```

This option sets the range in relation to the zone you set in ``setEngagementZone`` for a SAM site to go live. Be careful not to set the value too low. Some SAM sites need up to 30 seconds until they can fire. 
During this time a target might have already left the engagement zone of SAM site. This option is intended for long range systems like the S-300. You can also set the range above 100 this will have the effect that the SAM site goes live earlier:

```lua
samSite:setGoLiveRangeInPercent(90)
```

## EW radar configuration

### Adding EW radars

#### Add multiple EW radars
Adds EW radars with prefix in unit name to the IADS. Previously added EW sites are cleared:
```lua
redIADS:addEarlyWarningRadarsByPrefix('EW')
``` 

#### Add an EW radar manually
You can add EW radars manually, must be a valid unit name: 
```lua
redIADS:addEarlyWarningRadar('EWR West')
```

### Accessing EW radars in the IADS
The following functions exist to access EW radars added to the IADS. They all support daisy chaining options. 


Returns all EW radars in the IADS:
```lua
redIADS:getEarlyWarningRadars()
```

Returns the EW radar with the specified unit name:
```lua
redIADS:getEarlyWarningRadarByUnitName('EW-west')
```

## Options for SAM sites and EW radars

### Setting an option
In the following examples ```ewRadarOrSamSite``` refers to an single EW radar or SAM site or a table of EW radars and SAM sites you got from the Skynet IADS, by calling one of the functions named in [accessing EW radars](#accessing-ew-radars-in-the-iads) or [accessing SAM sites](#accessing-sam-sites-in-the-iads).

### Daisy chaining options
 You can daisy chain options on a single SAM site / EW Radar or a table of SAM sites / EW radars like this:
 ```lua
 redIADS:getSAMSites():setActAsEW(true):addPowerSource(powerSource):addConnectionNode(connectionNode):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE):setGoLiveRangeInPercent(90):setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK)
 ```  

### Power sources and connection nodes
You can use units or static objects. Call the function multiple times to add more than one power source or connection node:
```lua
local powerSource = StaticObject.getByName("EW Power Source")  
ewRadarOrSamSite:addPowerSource(powerSource)
```

```lua
local connectionNode = Unit.getByName("EW connection node") 
ewRadarOrSamSite:addConnectionNode(connectionNode)
```

### HARM Defence
You can set the reaction probability (between 0 and 100 percent). See [skynet-iads-supported-types.lua](/skynet-iads-source/skynet-iads-supported-types.lua) field ```['harm_detection_chance']``` for default detection probabilities:
```lua
ewRadarOrSamSite:setHARMDetectionChance(50)
```

### Point defence
You must use a point defence SAM that can engage HARM missiles. Can be used to protect SAM sites or EW radars. See [point defence](#point-defence) for information what this does:
```lua
--first get the SAM site you want to use as point defence from the IADS:
local sa15 = redIADS:getSAMSiteByGroupName('SAM-SA-15')
--then add it to the SAM site it should protect:
redIADS:getSAMSiteByGroupName('SAM-SA-10'):addPointDefence(sa15)
```

Will prevent the EW radar or SAM site from going dark if a HARM is inbound. Conditions are HARM saturation level is not reached and the point defence has ammo left. Default state is false:
```lua
ewRadarOrSamSite:setIgnoreHARMSWhilePointDefencesHaveAmmo(true)
```

### Autonomous mode behaviour
Set how the SAM site or EW radar will behave if it looses connection to the IADS:
```lua
ewRadarOrSamSite:setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK)
```

#### Autonomous mode options 
SAM site or EW radar will behave in the default DCS AI. Alarm State will be red and ROE weapons free (default Skynet behaviour for SAM sites):
```lua
SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DCS_AI
```

SAM Site or EW radar will go dark if it looses connection to IADS (default behaviour for EW radars):
```lua
SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK
```

## Adding a jammer
The jammer is quite easy to set up. You need a unit that acts as a jammer source, preferably it will be an aircraft in the strike package.
Once the jammer detects an emitter it starts jamming the radar. Set the [coresponding debug variable jammerProbability](#setting-debug-information) to see what the jammer is doing.
Check [skynet-iads-jammer.lua](/skynet-iads-source/skynet-iads-jammer.lua) to see which SAM sites are supported.

Remember to set the AI aircraft acting as jammer in the Mission editor to ```Reaction to Threat = EVADE FIRE``` otherwise the AI will try and actively attack the SAM site.
This way it will stick to the preset flight plan.

Create a jammer and assign it to an unit. Also make sure you add the IADS you wan't the jammer to work for:
```lua
local jammerSource = Unit.getByName("F-4 AI")
jammer = SkynetIADSJammer:create(jammerSource, iads)
```

The jammer will start listening for emitters and if it finds one of the emitters it is able to jam it will start jamming it:
```lua
jammer:masterArmOn()
```

Will disable jamming for the specified SAM type, pass the Nato name:
```lua
jammer:disableFor('SA-2')
```

Will turn off the jammer. Make sure you call this function before you dereference a jammer in the code, otherwise a background task will keep on jamming:
```lua
jammer:masterArmOff()
```

Will add jammer on / off to the radio menu:
```lua
jammer:addRadioMenu()
```

Will remove jammer on / off from the radio menu:
```lua
jammer:removeRadioMenu()
```

### Advanced functions

Add a second IADS the jammer should be able to jam, for example if you have two separate IADS running:
```lua
jammer:addIADS(iads2)
```

Add a new jammer function:

```lua
-- write a lambda function that expects one parameter:
-- given public available data on jammers their effeciveness drastically decreases the closer you get, so a non-linear function would make sense:
local function f(distanceNM)
	return ( 1.4 ^ distanceNM ) + 80
end

-- add the function: specify which SAM type it should apply for:
self.jammer:addFunction('SA-10', f)
```

Set the maximum range the jammer will work, the default value is set to 200 nautical miles:
```lua
jammer:setMaximumEffectiveDistance(100)
```

## Setting debug information
When developing a mission I suggest you add debug output to check how the IADS reacts to threats. Debug output may slow down DCS, so it's recommended to turn it off in a live environment:

```lua
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
iadsDebug.harmDefence = true
iadsDebug.samSiteStatusEnvOutput = true
iadsDebug.earlyWarningRadarStatusEnvOutput = true
```
![Mission Editor IADS Setup](/images/skynet-debug.png)  

# Example Setup
This is an example of how you can set up your IADS used in the [demo mission](/demo-missions/skynet-test-persian-gulf.miz):
```lua
do

--create an instance of the IADS
redIADS = SkynetIADS:create('RED')

---debug settings remove from here on if you do not wan't any output on what the IADS is doing by default
local iadsDebug = redIADS:getDebugSettings()
iadsDebug.IADSStatus = true
iadsDebug.samWentDark = true
iadsDebug.contacts = true
iadsDebug.radarWentLive = true
iadsDebug.noWorkingCommmandCenter = true
iadsDebug.ewRadarNoConnection = true
iadsDebug.samNoConnection = true
iadsDebug.jammerProbability = true
iadsDebug.addedEWRadar = true
iadsDebug.hasNoPower = true
iadsDebug.harmDefence = true
---end remove debug ---

--add all units with unit name beginning with 'EW' to the IADS:
redIADS:addEarlyWarningRadarsByPrefix('EW')

--add all groups begining with group name 'SAM' to the IADS:
redIADS:addSAMSitesByPrefix('SAM')

--add a command center:
commandCenter = StaticObject.getByName('Command-Center')
redIADS:addCommandCenter(commandCenter)

---we add a K-50 AWACs, manually. This could just as well be automated by adding an 'EW' prefix to the unit name:
redIADS:addEarlyWarningRadar('AWACS-K-50')

--add a power source and a connection node for this EW radar:
local powerSource = StaticObject.getByName('Power-Source-EW-Center3')
local connectionNodeEW = StaticObject.getByName('Connection-Node-EW-Center3')
redIADS:getEarlyWarningRadarByUnitName('EW-Center3'):addPowerSource(powerSource):addConnectionNode(connectionNodeEW)

--add a connection node to this SA-2 site, and set the option for it to go dark, if it looses connection to the IADS:
local connectionNode = Unit.getByName('Mobile-Command-Post-SAM-SA-2')
redIADS:getSAMSiteByGroupName('SAM-SA-2'):addConnectionNode(connectionNode):setAutonomousBehaviour(SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK)

--this SA-2 site will go live at 70% of its max search range:
redIADS:getSAMSiteByGroupName('SAM-SA-2'):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE):setGoLiveRangeInPercent(70)

--all SA-10 sites shall act as EW sites, meaning their radars will be on all the time:
redIADS:getSAMSitesByNatoName('SA-10'):setActAsEW(true)

--set the SA-15's as point defence for the SA-10 site. We set it to always react to a HARM so we can demonstrate the point defence mechanism in Skynet
-- the SA-10 will stay online when shot at by HARMS as long as the point defences have ammo and the SA-15 is not saturated by HARMS(setIgnoreHARMSWhilePointDefencesHaveAmmo(true))
local sa15 = redIADS:getSAMSiteByGroupName('SAM-SA-15-point-defence-SA-10')
redIADS:getSAMSiteByGroupName('SAM-SA-10'):addPointDefence(sa15):setHARMDetectionChance(100):setIgnoreHARMSWhilePointDefencesHaveAmmo(true)

--set this SA-11 site to go live 70% of max range of its missiles (default value: 100%), its HARM detection probability is set to 50% (default value: 70%)
redIADS:getSAMSiteByGroupName('SAM-SA-11'):setGoLiveRangeInPercent(70):setHARMDetectionChance(50)

--this SA-6 site will always react to a HARM being fired at it:
redIADS:getSAMSiteByGroupName('SAM-SA-6'):setHARMDetectionChance(100)

--set this SA-11 site to go live at maximunm search range (default is at maximung firing range):
redIADS:getSAMSiteByGroupName('SAM-SA-11-2'):setEngagementZone(SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE)

--activate the radio menu to toggle IADS Status output
redIADS:addRadioMenu()

--activate the IADS
redIADS:activate()	

--add the jammer
local jammer = SkynetIADSJammer:create(Unit.getByName('jammer-emitter'), redIADS)
jammer:masterArmOn()

--setup blue IADS:
blueIADS = SkynetIADS:create('UAE')
blueIADS:addSAMSitesByPrefix('BLUE-SAM')
blueIADS:addEarlyWarningRadarsByPrefix('BLUE-EW')
blueIADS:activate()
blueIADS:addRadioMenu()

local iadsDebug = blueIADS:getDebugSettings()
iadsDebug.IADSStatus = true
iadsDebug.contacts = true

end
```

# FAQ

## Does Skynet IADS have an impact on game performance?
Skynet may actually improve game performance when using a lot of SAM AI units. This is because Skynet will turn off the AI of all SAM groups currently not in range of a target. By default these SAM groups would otherwise have their AI on. Skynet caches target information for a few seconds to reduce expensive calls on DCS radar detection.

## What air defence units shall I add to the Skynet IADS?
In theory you can add all the types that are listed in the [skynet-iads-supported-types.lua](skynet-iads-source/skynet-iads-supported-types.lua) file. 
Very short range units (like the Shilka AAA, Rapier) won't really benefit from the IADS apart from reacting to HARMs. These are better just placed in a mission and handeled by the default AI of DCS.
This is due to the short range of their radars. By the time the IADS wakes them up, the contact has likely passed their engagement range.
The strength of the Skynet IADS lies with handling long range systems that operate by radar.

## What exactly does Skynet do with the SAMS?
Via the scripting engine one can toggle a radar emitter's group controller on and off. Further options are the alarm state and the rules of engagement. In a nutshell that's all that Skynet does. Skynet does however read the radar and firing range properties of a SAM site. Based on that data and the setup options a mission designer provides Skynet will turn a SAM site on or off. 

No god like intervention is used (like magically exploding HARMS via the scripting engine).
If a SAM site or EW radar detects an inbound HARM it just turns off its radar as in real life. The HARM as it is programmed in DCS will try and glide in to the last known position mostly resulting in misses by 20-80 meters.

## Are there known bugs?
Yes, when placing multi unit SAM sites (e.g. SA-3 Patriot..) make sure the first unit you place is the search radar. If you add any other element as the first unit, Skynet will not be able to read radar data.
The result will be that the SAM site won't go live. This bug was observed in DCS 2.5.5. The SAM site will work fine when used as a standalone unit outside of Skynet.

## How do I know if a SAM site is in range of an EW site or a SAM site in EW mode?
To get a rough idea you can look at the range circles in the mission editor. However these ranges are greater than the actual in game detection ranges of an EW radar or SAM site.
The following screenshot shows the range of the 1L13 EWR. The mission editor shows a range of 64 NM (nautical miles) where as the in game range is 43 NM.

In this example the SAM site to the north east would not be in range of the EW radar, therefore it would go in to autonomous mode once the mission starts. 


![1L13 EWR range differences](/images/ew-detection-distance-example.png)  

Set the debug options ```samSiteStatusEnvOutput``` and ```earlyWarningRadarStatusEnvOutput``` to get detailed information on every SAM site and EW radar.
The text marked in the red box will show you which SAM sites are in the covered area of a SAM site or EW radar.


![SAM sites in covered area](/images/radar-emitter-status-dcs-log.png) 

## How do I connect Skynet with the MOOSE AI_A2A_DISPATCHER and what are the benefits of that?
IRL an IADS would most likely not only handle SAM sites but also pass information to interceptor aircraft. By connecting Skynet to the [AI_A2A_DISPATCHER](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_A2A_Dispatcher.html) by MOOSE you are able
to add interceptors to the IADS. See [Skynet Moose AI_A2A_DISPATCHER](#connecting-skynet-to-the-moose-ai_a2a_dispatcher) and the [moose_a2a_connector demo mission](demo-missions/moose_a2a_connector) for more information.

An example setup of Skynet and the [AI_A2A_DISPATCHER](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_A2A_Dispatcher.html) :
```lua

--Setup Syknet IADS:
redIADS = SkynetIADS:create('Enemy IADS')
redIADS:addSAMSitesByPrefix('SAM')
redIADS:addEarlyWarningRadarsByPrefix('EW')
redIADS:activate()

-- START MOOSE CODE:
-- Define a SET_GROUP object that builds a collection of groups that define the EWR network.
DetectionSetGroup = SET_GROUP:New()

-- Setup the detection and group targets to a 30km range!
Detection = DETECTION_AREAS:New( DetectionSetGroup, 30000 )

-- Setup the A2A dispatcher, and initialize it.
A2ADispatcher = AI_A2A_DISPATCHER:New( Detection )

-- Set 100km as the radius to engage any target by airborne friendlies.
A2ADispatcher:SetEngageRadius() -- 100000 is the default value.

-- Set 200km as the radius to ground control intercept.
A2ADispatcher:SetGciRadius() -- 200000 is the default value.

CCCPBorderZone = ZONE_POLYGON:New( "RED-BORDER", GROUP:FindByName( "RED-BORDER" ) )
A2ADispatcher:SetBorderZone( CCCPBorderZone )
A2ADispatcher:SetSquadron( "Kutaisi", AIRBASE.Caucasus.Kutaisi, { "Squadron red SU-27" }, 2 )
A2ADispatcher:SetSquadronGrouping( "Kutaisi", 2 )
A2ADispatcher:SetSquadronGci( "Kutaisi", 900, 1200 )
A2ADispatcher:SetTacticalDisplay(true)
A2ADispatcher:Start()
--END MOOSE CODE

-- add the MOOSE SET_GROUP to the IADS, from now on Skynet will update active radars that the MOOSE SET_GROUP can use for EW detection.
redIADS:addMooseSetGroup(DetectionSetGroup)
```

# Thanks
Special thaks to Spearzone and Coranthia for researching public available information on IADS networks and getting me up to speed on how such a system works.
I based the SAM site setup on [Grimes SAM DB](https://forums.eagle.ru/showthread.php?t=118175) from his IADS script, however I removed range data since Skynet loads that from DCS.


