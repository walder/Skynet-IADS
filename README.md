# Skynet-IADS
An IADS (Integrated Air Defence System) script for DCS (Digital Combat Simulator). It has been developed with generous assistance of Cyberdyne Corporation.

# Abstract
This script simulates an IADS within the scripting possibilities of DCS. Early Warning Radar Stations (EW Radar) scan the sky for contacts. These contacts are correlated with SAM (Surface to Air Missile) Sites. If a contact is within firing range of the the SAM Site it will become active. A modern IADS also depends on command centers and datalinks to the SAM Sites. The IADS can be set up with this infrastructure. Destroying it will degrade the capability of the IADS.

# IADS Elements

## Sam Site
Skynet can handle 0-n Sam Sites. By default Skynet keeps SAM Sites turned off. It calculates if a contact is within firing range of a SAM Site. Every single launcher and radar unit's distance is analysed individually. If at least one launcher and radar is within range, the SAM Site will become active. This allows for a scattered placemend of radar and launcher units as in real life.

Please make sure the SAM Group in the mission editor consists only of one type. eg don't add SA-10 units with SA-6 units, this will mess up the distance calculation.

The Skill level you set on a SAM Group is retained by Skynet.

##  Early Warning Radar
Skynet can handle 1-n EW Radars. For detection of a target the DCS radar detection logic is used. You can use any type of radar for EW in Skynet. Some modern SAM Units have longer range radars then the EW Radars, eg S300 vs EWR 55G6.

##  Power Sources
By default Skynet IADS will run without having to add power sources. You can add power sources to SAM Units, EW Radars and Command Centers. A power source can be any Unit oder StaticUnit in DCS. Once it is fully damaged the linked Skynet IADS unit will stop working. You can add multiple power sources to a Skynet IADS unit.

Taking out the power source of a command center is a real life tactic used in Suppression of Enemy Air Defence (SEAD).

## Connection Nodes
By default Skynet IADS will run without having to add connection nodes. You can add connection nodes to SAM Units, EW Radars and Command Centers. Currently only one link between the IADS and the Skynet IADS unit is supported. When a connection node is fully damaged the the unit connected to the IADS will go in to autonomous mode. For a SAM Unit this means it will behave in its autonomous mode setting. If a command center looses its connection node all SAM Sites will go autonomous. If a EW Radar looses its node it will no longer contribute information to the IADS but otherwise the IADS will still work.

# Electronig Warfare
In this release there is no electronig warfare functionallity. It will be aded in a later release.

#  Example Code

# Thanks
Special thaks to Spearzone for digging up a ton of obscure information on IADS and getting me up to speed on how such a system works.
Also I shamelessly incorporated Grimes SAM DB.
