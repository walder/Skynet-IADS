# Skynet-IADS
An IADS (Integrated Air Defence System) script for DCS (Digital Combat Simulator).

# Abstract
This script simulates an IADS within the scripting possibilities of DCS. Early Warning Radar Stations (EW Radar) scan the sky for contacts. These contacts are correlated with SAM (Surface to Air Missile) Sites. If a contact is within firing range of the the SAM Site it will become active. A modern IADS also depends on Command Centers and datalink to the SAM Sites. The IADS can be set up with this infrastructure. Destroying it will degrade the capability of the IADS.

# Elements

#  Sam Site
By default Skynet keeps SAM Sites turned off. It calculates if a contact is within firing range of a SAM Site. Every single launcher and radar unit's distance is analysed individually. If at least one launcher and radar is within range, the SAM Site will become active. This allows for a scattered placemend of radar and launcher units as in real life.

#  Early Warning Radar

#  Power Sources

#  Connection Nodes

# Electronig Warfare
In this release there is no electronig warfare functionallity. It will be aded in a later release.

#  Example Code
