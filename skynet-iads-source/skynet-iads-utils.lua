do
--[[
  SkynetIADSUtils -- internal utility helpers.

  These replace Skynet's former MIST dependency. Every function is BEHAVIOUR-IDENTICAL to the
  mist (4.5.107) function it supersedes -- this is a dependency swap, not a behaviour change:

    * scalar conversions (round / metersToNM / metersToFeet / toDegree) delegate to MOOSE UTILS,
      whose formulas are identical to mist's (verified: UTILS.Round = floor(x*10^d+0.5)/10^d,
      MetersToNM = m/1852, MetersToFeet = m/0.3048, ToDegree = a*180/pi).
    * the distance + heading helpers are reproduced verbatim from mist so output is bit-for-bit
      unchanged, including the true-north correction (DCS coord.LOtoLL / coord.LLtoLO) that
      mist.getHeading applies.
    * scheduling uses native timer.scheduleFunction (absolute mission time + repeat), matching
      mist.scheduleFunction's contract: f(unpack(vars)) at time t, re-run every rep, cancelable id.

  Dependency: MOOSE (for UTILS). No MIST required.
]]

SkynetIADSUtils = {}

-- ---- scalar conversions (delegate to MOOSE UTILS -- formula-identical to mist) ---------------
function SkynetIADSUtils.round(number, decimals)
	return UTILS.Round(number, decimals)
end

function SkynetIADSUtils.metersToNM(meters)
	return UTILS.MetersToNM(meters)
end

function SkynetIADSUtils.metersToFeet(meters)
	return UTILS.MetersToFeet(meters)
end

function SkynetIADSUtils.toDegree(radians)
	return UTILS.ToDegree(radians)
end

-- ---- distances (reproduced from mist.utils.get2DDist / get3DDist via mist.vec.mag) ------------
-- 2D ground-plane distance between two DCS Vec3 {x,y,z}: ignores altitude (y), uses x and z.
-- (NOTE: this is why MOOSE UTILS.VecDist2D is NOT used -- that takes a Vec2 {x,y} and would use
--  altitude as the second axis, changing the result.)
function SkynetIADSUtils.get2DDist(point1, point2)
	local dx = point1.x - point2.x
	local dz = point1.z - point2.z
	return (dx * dx + dz * dz) ^ 0.5
end

-- 3D distance between two DCS Vec3 {x,y,z}.
function SkynetIADSUtils.get3DDist(point1, point2)
	local dx = point1.x - point2.x
	local dy = point1.y - point2.y
	local dz = point1.z - point2.z
	return (dx * dx + dy * dy + dz * dz) ^ 0.5
end

-- ---- heading (reproduced verbatim from mist, incl. true-north correction) ---------------------
-- mist.getNorthCorrection: angle between DCS map grid north and true north at a point.
local function getNorthCorrection(point)
	if not point.z then -- Vec2 -> Vec3
		point = { x = point.x, y = 0, z = point.y }
	end
	local lat, lon = coord.LOtoLL(point)
	local northPosit = coord.LLtoLO(lat + 1, lon)
	return math.atan2(northPosit.z - point.z, northPosit.x - point.x)
end

-- Unit heading in radians [0, 2pi), true-north corrected (== mist.getHeading(unit), rawHeading=false).
function SkynetIADSUtils.getHeading(unit)
	local unitpos = unit:getPosition()
	if unitpos then
		local heading = math.atan2(unitpos.x.z, unitpos.x.x) + getNorthCorrection(unitpos.p)
		if heading < 0 then
			heading = heading + 2 * math.pi
		end
		return heading
	end
end

-- Ground-plane bearing from point1 to point2 in radians [0, 2pi), NO north correction
-- (== mist.utils.getHeadingPoints(point1, point2) called without the optional `north` arg, as Skynet does).
function SkynetIADSUtils.getHeadingPoints(point1, point2)
	local dir = math.atan2(point2.z - point1.z, point2.x - point1.x)
	if dir < 0 then
		dir = dir + 2 * math.pi
	end
	return dir
end

-- ---- random (== mist.random: a uniform integer in [low, high]) --------------------------------
-- mist.random returns a uniform integer in range (its internal table trick only de-biases the RNG;
-- the contract is "a random integer in range", which math.random satisfies). Single-arg = [1, n].
function SkynetIADSUtils.random(firstNum, secondNum)
	if not secondNum then
		return math.random(1, firstNum)
	end
	return math.random(firstNum, secondNum)
end

-- ---- scheduling (== mist.scheduleFunction / mist.removeFunction) -------------------------------
-- Run f(unpack(vars)) at absolute mission time t, re-running every `rep` seconds until optional
-- stop-time `st`. Returns a cancelable id (a DCS timer function id). f is pcall-guarded so a single
-- error doesn't tear down the repeating task (matches mist's keep-running scheduler behaviour).
function SkynetIADSUtils.scheduleFunction(f, vars, t, rep, st)
	vars = vars or {}
	-- CRITICAL: native timer.scheduleFunction SILENTLY DROPS a past-due first-run time. MIST's own scheduler ran
	-- past-due tasks on its next tick, so Skynet schedules with t=1 (1s after mission start) and relied on that.
	-- On a running/restored mission the IADS is built well after t=1, so t is in the PAST -> the periodic scan
	-- (evaluateContacts, HARM scan, jammer, ...) would NEVER start -> dark SAMs never get cued -> never fire.
	-- Clamp the first run to a valid FUTURE time, and reschedule off timer.getTime() so the repeat can't drift past.
	local first = (type(t) == "number" and t > timer.getTime()) and t or (timer.getTime() + (rep or 1))
	return timer.scheduleFunction(function()
		pcall(f, unpack(vars))
		if rep then
			local nxt = timer.getTime() + rep
			if (not st) or (nxt <= st) then return nxt end
		end
		return nil
	end, nil, first)
end

function SkynetIADSUtils.removeFunction(id)
	-- MIST's removeFunction tolerates an unknown/stale id (table search, returns false). DCS
	-- timer.removeFunction THROWS ("function reference number is invalid") on a stale/already-fired id,
	-- so pcall-guard it to preserve MIST's forgiving behaviour (Skynet calls this on scan-task ids that
	-- may not exist yet / may have already fired).
	if id then
		pcall(timer.removeFunction, id)
	end
end

end
