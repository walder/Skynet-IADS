do

_G.SKYNET_DEBUG_QUEUE = _G.SKYNET_DEBUG_QUEUE or {}

SkynetIADSLogger = {}
SkynetIADSLogger.__index = SkynetIADSLogger
SkynetIADSLogger.activeLoggers = {}
SkynetIADSLogger.liveTickerID = nil
SkynetIADSLogger.cardPayloadText = ""
SkynetIADSLogger.cardPayloadDuration = 0
SkynetIADSLogger.cardPayloadSeq = 0
SkynetIADSLogger.radioMenuOpen = false
SkynetIADSLogger.radioPanelHooked = false

-- Dedicated Debug & Error Tracking State (writes to SKYNET_IADS_DEBUG.log + dcs.log)
SkynetIADSLogger.debugEnabled = true
SkynetIADSLogger.maxQueueSize = 1000
SkynetIADSLogger.maxErrorHistory = 50
SkynetIADSLogger.errorHistory = {}
SkynetIADSLogger.globalEventHistory = {}
SkynetIADSLogger.maxGlobalEvents = 15
SkynetIADSLogger.eventCounter = 0
SkynetIADSLogger.totalErrorCount = 0
SkynetIADSLogger.trackedUnitLookup = {}
SkynetIADSLogger.directFileWriteAvailable = false
SkynetIADSLogger.directLogPaths = {}

pcall(function()
	local wDir = (lfs and type(lfs.writedir) == "function" and lfs.writedir()) or nil
	if wDir and wDir ~= "" then
		table.insert(SkynetIADSLogger.directLogPaths, wDir .. "Logs\\SKYNET_IADS_DEBUG.log")
	end
	local uProf = (os and type(os.getenv) == "function" and os.getenv("USERPROFILE"))
		or (wDir and string.match(wDir, "^([A-Za-z]:\\Users\\[^\\]+)"))
	if uProf and uProf ~= "" then
		table.insert(SkynetIADSLogger.directLogPaths, uProf .. "\\Desktop\\Scriptler\\SKYNET_IADS_DEBUG.log")
		table.insert(SkynetIADSLogger.directLogPaths, uProf .. "\\Desktop\\SKYNET_IADS_DEBUG.log")
	end
end)

-- Access Mode:
-- "COMMANDER_ALL_BLUE_OWN" (Default):
--   • Mission Commander sees both RED and BLUE IADS networks.
--   • Blue team players only see friendly BLUE IADS network; never RED IADS.
-- "COMMANDER_ONLY":
--   • Only Mission Commander sees the IADS radio menu.
SkynetIADSLogger.accessMode = "COMMANDER_ALL_BLUE_OWN"
SkynetIADSLogger.autoPrimaryCommanderName = nil
SkynetIADSLogger.groupSessions = {}
SkynetIADSLogger.eventHandlerRegistered = false

local COMMANDER_KEYWORDS = {
	"KOMUTAN", "COMMANDER", "ADMIN", "GAMEMASTER", "GAME MASTER",
	"TAKTIK", "TACTICAL", "KARARGAH", "HQ", "MASTER"
}

local function formatSimAndClockTime()
	local simSec = (timer and timer.getTime and timer.getTime()) or 0
	local absTime = (timer and timer.getAbsTime and timer.getAbsTime()) or 0
	local totalSec = math.floor(absTime)
	local hours = math.floor(totalSec / 3600) % 24
	local mins = math.floor((totalSec % 3600) / 60)
	local secs = totalSec % 60
	return string.format("Sim:%.2fs | Clock:%02d:%02d:%02d", simSec, hours, mins, secs)
end

local function enqueueDebugLine(line)
	if type(_G.SKYNET_DEBUG_QUEUE) ~= "table" then
		_G.SKYNET_DEBUG_QUEUE = {}
	end
	local q = _G.SKYNET_DEBUG_QUEUE
	if #q >= SkynetIADSLogger.maxQueueSize then
		table.remove(q, 1)
	end
	table.insert(q, line)

	-- If MissionScripting has io unsanitized and Hook hasn't claimed exclusive writing, also try direct append
	if not _G.SKYNET_HOOK_LOG_ACTIVE and io and type(io.open) == "function" then
		for i = 1, #SkynetIADSLogger.directLogPaths do
			pcall(function()
				local f = io.open(SkynetIADSLogger.directLogPaths[i], "a")
				if f then
					f:write(line .. "\n")
					f:flush()
					f:close()
				end
			end)
		end
	end
end

function SkynetIADSLogger.writeGlobalLog(level, category, message)
	if not SkynetIADSLogger.debugEnabled then
		return
	end
	SkynetIADSLogger.eventCounter = SkynetIADSLogger.eventCounter + 1
	level = tostring(level or "INFO")
	category = tostring(category or "GENERAL")
	message = tostring(message or "")

	local line = string.format("[SKYNET #%04d | %s] [%s] [%s] %s",
		SkynetIADSLogger.eventCounter,
		formatSimAndClockTime(),
		level,
		category,
		message)

	enqueueDebugLine(line)

	local shortEntry = string.format("[%02d:%02d:%02d] [%s] %s",
		math.floor(((timer and timer.getAbsTime and timer.getAbsTime()) or 0) / 3600) % 24,
		math.floor((((timer and timer.getAbsTime and timer.getAbsTime()) or 0) % 3600) / 60),
		math.floor(((timer and timer.getAbsTime and timer.getAbsTime()) or 0) % 60),
		category,
		message)
	table.insert(SkynetIADSLogger.globalEventHistory, 1, shortEntry)
	while #SkynetIADSLogger.globalEventHistory > SkynetIADSLogger.maxGlobalEvents do
		table.remove(SkynetIADSLogger.globalEventHistory)
	end

	if env then
		if level == "ERROR" and type(env.error) == "function" then
			env.error("[SKYNET-DEBUG] " .. line, false)
		elseif level == "WARN" and type(env.warning) == "function" then
			env.warning("[SKYNET-DEBUG] " .. line, false)
		elseif type(env.info) == "function" then
			env.info("[SKYNET-DEBUG] " .. line, false)
		end
	end
end

function SkynetIADSLogger.logError(category, errMsg, stackTrace)
	SkynetIADSLogger.totalErrorCount = SkynetIADSLogger.totalErrorCount + 1
	local timeTxt = formatSimAndClockTime()
	local fullMsg = tostring(errMsg or "Unknown Error")
	if stackTrace and stackTrace ~= "" then
		fullMsg = fullMsg .. " | STACK: " .. string.gsub(tostring(stackTrace), "[\r\n]+", " <- ")
	end

	local errRecord = {
		id = SkynetIADSLogger.totalErrorCount,
		time = timeTxt,
		category = tostring(category or "EXCEPTION"),
		message = tostring(errMsg or ""),
		stack = tostring(stackTrace or "")
	}
	table.insert(SkynetIADSLogger.errorHistory, 1, errRecord)
	while #SkynetIADSLogger.errorHistory > SkynetIADSLogger.maxErrorHistory do
		table.remove(SkynetIADSLogger.errorHistory)
	end

	SkynetIADSLogger.writeGlobalLog("ERROR", category or "EXCEPTION", fullMsg)
end

-- Lua 5.1 compatible xpcall wrapper with stack trace capture
function SkynetIADSLogger.safeCall(category, fn, ...)
	if type(fn) ~= "function" then
		SkynetIADSLogger.logError(category, "Target is not a function: " .. tostring(fn), "")
		return false, nil
	end
	local nArgs = select("#", ...)
	local args = { ... }
	local traceStr = ""
	local function errHandler(err)
		if debug and type(debug.traceback) == "function" then
			traceStr = debug.traceback(tostring(err), 2)
		else
			traceStr = tostring(err)
		end
		return err
	end

	local ok, r1, r2, r3, r4 = xpcall(function()
		if nArgs == 0 then
			return fn()
		elseif nArgs == 1 then
			return fn(args[1])
		elseif nArgs == 2 then
			return fn(args[1], args[2])
		elseif nArgs == 3 then
			return fn(args[1], args[2], args[3])
		else
			return fn(unpack(args, 1, nArgs))
		end
	end, errHandler)

	if not ok then
		SkynetIADSLogger.logError(category, r1, traceStr)
		return false, nil
	end
	return true, r1, r2, r3, r4
end

local function hasCommanderKeyword(str)
	if type(str) ~= "string" or str == "" then
		return false
	end
	local up = string.upper(str)
	for i = 1, #COMMANDER_KEYWORDS do
		if string.find(up, COMMANDER_KEYWORDS[i], 1, true) then
			return true
		end
	end
	return false
end

function SkynetIADSLogger.isPlayerOrGroupCommander(grp, unit, playerName)
	-- 1) Synced via Hook (Host / Server Owner / Tactical Commander / Game Master)
	if type(_G.SKYNET_AUTO_COMMANDERS) == "table" and type(playerName) == "string" and playerName ~= "" then
		if _G.SKYNET_AUTO_COMMANDERS[playerName] == true then
			return true
		end
	end

	-- 2) Singleplayer local player is always Mission Commander
	if world and type(world.getPlayer) == "function" then
		local okSp, spUnit = pcall(world.getPlayer)
		if okSp and spUnit and spUnit.isExist and spUnit:isExist() then
			if not unit or (unit.getName and spUnit:getName() == unit:getName()) then
				return true
			end
		end
	end

	-- 3) Group name, unit name, or player name contains Commander/Admin keyword
	local grpName = (grp and grp.getName and grp:getName()) or ""
	local unitName = (unit and unit.getName and unit:getName()) or ""
	if hasCommanderKeyword(grpName) or hasCommanderKeyword(unitName) or hasCommanderKeyword(playerName) then
		return true
	end

	-- 4) First player on dedicated server without Hook
	local hasHookCommanders = (type(_G.SKYNET_AUTO_COMMANDERS) == "table" and next(_G.SKYNET_AUTO_COMMANDERS) ~= nil)
	if not hasHookCommanders and type(playerName) == "string" and playerName ~= "" then
		if SkynetIADSLogger.autoPrimaryCommanderName == nil then
			SkynetIADSLogger.autoPrimaryCommanderName = playerName
			SkynetIADSLogger.writeGlobalLog("INFO", "COMMANDER-ASSIGN", "Primary Mission Commander automatically assigned: " .. tostring(playerName))
		end
		if SkynetIADSLogger.autoPrimaryCommanderName == playerName then
			return true
		end
	end

	return false
end

function SkynetIADSLogger.canSessionAccessIADS(session, iads)
	if not session or not iads then
		return false
	end
	if session.isCommander then
		return true
	end
	if SkynetIADSLogger.accessMode == "COMMANDER_ONLY" then
		return false
	end
	if session.coalitionID == coalition.side.BLUE and iads.coalitionID == coalition.side.BLUE then
		return true
	end
	return false
end

function SkynetIADSLogger.getOrCreateGroupSession(groupId, grpName, coaSide, playerName, isCommander)
	local s = SkynetIADSLogger.groupSessions[groupId]
	if not s then
		s = {
			groupId = groupId,
			groupName = grpName or tostring(groupId),
			coalitionID = coaSide,
			playerName = playerName or "",
			isCommander = (isCommander == true),
			menus = {},
			menuSig = {},
			views = {}
		}
		SkynetIADSLogger.groupSessions[groupId] = s
	else
		s.groupName = grpName or s.groupName
		s.coalitionID = coaSide or s.coalitionID
		s.playerName = playerName or s.playerName
		s.isCommander = (isCommander == true)
	end
	return s
end

function SkynetIADSLogger.getGroupViewForIADS(groupId, iads)
	local s = SkynetIADSLogger.groupSessions[groupId]
	if not s then
		return nil
	end
	local v = s.views[iads]
	if not v then
		v = {
			IADSStatus = false,
			samDetails = false,
			contacts = false,
			notifications = false,
			debugScreen = false,
			snapshotUntil = 0,
			wasActive = false
		}
		s.views[iads] = v
	end
	return v
end

function SkynetIADSLogger.collectHumanGroups()
	local found = {}
	local function considerUnit(u, fallbackSide)
		if not (u and u.isExist and u:isExist()) then
			return
		end
		local pName = nil
		if type(u.getPlayerName) == "function" then
			local okP, pn = pcall(u.getPlayerName, u)
			if okP and type(pn) == "string" and pn ~= "" then
				pName = pn
			end
		end
		if not pName and world and type(world.getPlayer) == "function" then
			local okSp, sp = pcall(world.getPlayer)
			if okSp and sp and sp.isExist and sp:isExist() and sp.getName and u.getName and sp:getName() == u:getName() then
				pName = "SinglePlayer"
			end
		end
		if not pName then
			return
		end
		if type(u.getGroup) ~= "function" then
			return
		end
		local okG, grp = pcall(u.getGroup, u)
		if not (okG and grp and grp.isExist and grp:isExist() and type(grp.getID) == "function") then
			return
		end
		local okId, gid = pcall(grp.getID, grp)
		if not (okId and gid) then
			return
		end
		local coa = fallbackSide
		if type(grp.getCoalition) == "function" then
			local okC, c = pcall(grp.getCoalition, grp)
			if okC and c then coa = c end
		elseif type(u.getCoalition) == "function" then
			local okC, c = pcall(u.getCoalition, u)
			if okC and c then coa = c end
		end
		local isCmd = SkynetIADSLogger.isPlayerOrGroupCommander(grp, u, pName)
		if not found[gid] or (isCmd and not found[gid].isCommander) then
			found[gid] = {
				groupId = gid,
				group = grp,
				groupName = (grp.getName and grp:getName()) or tostring(gid),
				unit = u,
				playerName = pName,
				coalitionID = coa,
				isCommander = isCmd
			}
		end
	end

	if world and type(world.getPlayer) == "function" then
		local okSp, spUnit = pcall(world.getPlayer)
		if okSp and spUnit then
			considerUnit(spUnit, nil)
		end
	end

	if coalition and type(coalition.getGroups) == "function" then
		local sides = { coalition.side.BLUE, coalition.side.RED, coalition.side.NEUTRAL }
		local cats = { 0, 1, 2, 3 }
		if Group and Group.Category then
			cats = {
				Group.Category.AIRPLANE or 0,
				Group.Category.HELICOPTER or 1,
				Group.Category.GROUND or 2,
				Group.Category.SHIP or 3
			}
		end
		for _, side in ipairs(sides) do
			if side ~= nil then
				for _, cat in ipairs(cats) do
					local okGrps, grps = pcall(coalition.getGroups, side, cat)
					if okGrps and type(grps) == "table" then
						for i = 1, #grps do
							local g = grps[i]
							if g and g.isExist and g:isExist() and type(g.getUnits) == "function" then
								local okU, units = pcall(g.getUnits, g)
								if okU and type(units) == "table" then
									for j = 1, #units do
										considerUnit(units[j], side)
									end
								end
							end
						end
					end
				end
			end
		end
	end

	return found
end

function SkynetIADSLogger.syncGroupRadioMenus()
	if not (missionCommands and type(missionCommands.addSubMenuForGroup) == "function" and type(missionCommands.addCommandForGroup) == "function") then
		return
	end
	local humanGroups = SkynetIADSLogger.collectHumanGroups()
	for gid, info in pairs(humanGroups) do
		local session = SkynetIADSLogger.getOrCreateGroupSession(gid, info.groupName, info.coalitionID, info.playerName, info.isCommander)
		for i = 1, #SkynetIADSLogger.activeLoggers do
			local lg = SkynetIADSLogger.activeLoggers[i]
			local iads = lg and lg.iads
			if iads and iads.radioMenuEnabled then
				local allowed = SkynetIADSLogger.canSessionAccessIADS(session, iads)
				local sig = tostring(allowed) .. "|" .. tostring(session.isCommander) .. "|" .. tostring(session.playerName)
				if session.menuSig[iads] ~= sig then
					if session.menus[iads] and type(missionCommands.removeItemForGroup) == "function" then
						pcall(missionCommands.removeItemForGroup, gid, session.menus[iads])
						session.menus[iads] = nil
					end
					session.menuSig[iads] = sig
					if allowed then
						local prefix = session.isCommander and "SKYNET IADS [COMMANDER] " or "SKYNET IADS "
						local subMenu = missionCommands.addSubMenuForGroup(gid, prefix .. iads:getCoalitionString())
						session.menus[iads] = subMenu
						missionCommands.addCommandForGroup(gid, 'Open Live IADS Dashboard (Continuous)', subMenu, SkynetIADS.updateDisplay, {self = iads, groupId = gid, value = true, option = 'IADSStatus'})
						missionCommands.addCommandForGroup(gid, 'Close Live IADS Dashboard', subMenu, SkynetIADS.updateDisplay, {self = iads, groupId = gid, value = false, option = 'closeAll'})
						missionCommands.addCommandForGroup(gid, 'Quick Status Snapshot (15 sec)', subMenu, SkynetIADS.updateDisplay, {self = iads, groupId = gid, value = true, option = 'snapshot'})
						missionCommands.addCommandForGroup(gid, 'Toggle SAM Battery Details', subMenu, SkynetIADS.updateDisplay, {self = iads, groupId = gid, value = 'toggle', option = 'samDetails'})
						missionCommands.addCommandForGroup(gid, 'Toggle Active Radar Contacts', subMenu, SkynetIADS.updateDisplay, {self = iads, groupId = gid, value = 'toggle', option = 'contacts'})
						missionCommands.addCommandForGroup(gid, 'Toggle Live Radar & HARM Alerts', subMenu, SkynetIADS.updateDisplay, {self = iads, groupId = gid, value = 'toggle', option = 'notifications'})
						missionCommands.addCommandForGroup(gid, 'Toggle Debug & Event Log Screen', subMenu, SkynetIADS.updateDisplay, {self = iads, groupId = gid, value = 'toggle', option = 'debugScreen'})
						missionCommands.addCommandForGroup(gid, 'Write Full Diagnostic Report to Log', subMenu, SkynetIADS.updateDisplay, {self = iads, groupId = gid, value = true, option = 'dumpDiagnostics'})
					else
						local v = session.views[iads]
						if v then
							v.IADSStatus = false
							v.samDetails = false
							v.contacts = false
							v.notifications = false
							v.debugScreen = false
							v.snapshotUntil = 0
						end
					end
				end
			end
		end
	end
end

local function safeObjNameAndType(obj)
	if not obj then
		return "Unknown", "Unknown", "Unknown"
	end
	local uName, uType, gName = "Unknown", "Unknown", "Single/Static"
	pcall(function()
		if obj.getName then uName = tostring(obj:getName() or "Unknown") end
		if obj.getTypeName then uType = tostring(obj:getTypeName() or "Unknown") end
		if obj.getGroup then
			local g = obj:getGroup()
			if g and g.getName then
				gName = tostring(g:getName() or "Single/Static")
			end
		end
	end)
	return uName, uType, gName
end

local function findIADSOwnerInfo(unitName, groupName)
	for i = 1, #SkynetIADSLogger.activeLoggers do
		local lg = SkynetIADSLogger.activeLoggers[i]
		local iads = lg and lg.iads
		if iads then
			local netName = tostring(iads.name or iads:getCoalitionString())
			local sams = iads.samSites or {}
			for j = 1, #sams do
				local sam = sams[j]
				if sam and (sam:getDCSName() == groupName or sam:getDCSName() == unitName) then
					return lg, string.format("SAM:%s (%s) [%s]", tostring(sam:getDCSName()), tostring(sam:getNatoName()), netName)
				end
				for _, pSrc in ipairs(sam:getPowerSources() or {}) do
					if pSrc and pSrc:getName() == unitName then
						return lg, string.format("PowerSource for SAM:%s [%s]", tostring(sam:getDCSName()), netName)
					end
				end
				for _, cNode in ipairs(sam:getConnectionNodes() or {}) do
					if cNode and cNode:getName() == unitName then
						return lg, string.format("ConnectionNode for SAM:%s [%s]", tostring(sam:getDCSName()), netName)
					end
				end
			end
			local ewrs = iads.earlyWarningRadars or {}
			for j = 1, #ewrs do
				local ew = ewrs[j]
				if ew and (ew:getDCSName() == unitName or ew:getDCSName() == groupName) then
					return lg, string.format("EWR:%s (%s) [%s]", tostring(ew:getDCSName()), tostring(ew:getNatoName()), netName)
				end
				for _, pSrc in ipairs(ew:getPowerSources() or {}) do
					if pSrc and pSrc:getName() == unitName then
						return lg, string.format("PowerSource for EWR:%s [%s]", tostring(ew:getDCSName()), netName)
					end
				end
				for _, cNode in ipairs(ew:getConnectionNodes() or {}) do
					if cNode and cNode:getName() == unitName then
						return lg, string.format("ConnectionNode for EWR:%s [%s]", tostring(ew:getDCSName()), netName)
					end
				end
			end
			local ccs = iads.commandCenters or {}
			for j = 1, #ccs do
				local cc = ccs[j]
				if cc and (cc:getDCSName() == unitName or cc:getDCSName() == groupName) then
					return lg, string.format("CommandCenter:%s [%s]", tostring(cc:getDCSName()), netName)
				end
				for _, pSrc in ipairs(cc:getPowerSources() or {}) do
					if pSrc and pSrc:getName() == unitName then
						return lg, string.format("PowerSource for CommandCenter:%s [%s]", tostring(cc:getDCSName()), netName)
					end
				end
				for _, cNode in ipairs(cc:getConnectionNodes() or {}) do
					if cNode and cNode:getName() == unitName then
						return lg, string.format("ConnectionNode for CommandCenter:%s [%s]", tostring(cc:getDCSName()), netName)
					end
				end
			end
		end
	end
	return nil, nil
end

function SkynetIADSLogger.handleGlobalWorldEvent(event)
	if not event or not world or not world.event then
		return
	end
	local evId = event.id
	if evId == world.event.S_EVENT_BIRTH or evId == world.event.S_EVENT_PLAYER_ENTER_UNIT then
		local uName, uType, gName = safeObjNameAndType(event.initiator)
		local evTag = (evId == world.event.S_EVENT_PLAYER_ENTER_UNIT) and "PLAYER-ENTER" or "UNIT-BIRTH"
		SkynetIADSLogger.writeGlobalLog("INFO", evTag, string.format("Unit=%s | Type=%s | Group=%s", uName, uType, gName))
		pcall(SkynetIADSLogger.syncGroupRadioMenus)
	elseif evId == world.event.S_EVENT_SHOT then
		local sName, sType, sGrp = safeObjNameAndType(event.initiator)
		local wType = "UnknownWeapon"
		local tName, tType, tGrp = "None", "None", "None"
		pcall(function()
			if event.weapon then
				if event.weapon.getTypeName then wType = tostring(event.weapon:getTypeName() or "UnknownWeapon") end
				if event.weapon.getTarget then
					local tgt = event.weapon:getTarget()
					if tgt then
						tName, tType, tGrp = safeObjNameAndType(tgt)
					end
				end
			end
		end)
		local ownerLg, ownerDesc = findIADSOwnerInfo(sName, sGrp)
		local msg = string.format("Shooter=%s (%s, Grp:%s)%s | Weapon=%s | Target=%s (%s, Grp:%s)",
			sName, sType, sGrp, ownerDesc and (" [" .. ownerDesc .. "]") or "", wType, tName, tType, tGrp)
		SkynetIADSLogger.writeGlobalLog("INFO", "WEAPON-SHOT", msg)
		if ownerLg then
			ownerLg:appendHistoryOnly("SAM SHOT", string.format("%s fired %s -> %s", sGrp, wType, tName))
		end
	elseif evId == world.event.S_EVENT_HIT then
		local tName, tType, tGrp = safeObjNameAndType(event.target)
		local aName, aType, aGrp = safeObjNameAndType(event.initiator)
		local wType = "UnknownWeapon"
		local hpStr = ""
		pcall(function()
			if event.weapon and event.weapon.getTypeName then
				wType = tostring(event.weapon:getTypeName() or "UnknownWeapon")
			end
			if event.target and event.target.getLife and event.target.getLife0 then
				local l = tonumber(event.target:getLife()) or 0
				local l0 = tonumber(event.target:getLife0()) or 0
				if l0 > 0 then
					hpStr = string.format(" | RemainingHP:%.1f/%.1f (%.0f%%)", l, l0, (l / l0) * 100)
				end
			end
		end)
		local ownerLg, ownerDesc = findIADSOwnerInfo(tName, tGrp)
		local msg = string.format("Target=%s (%s, Grp:%s)%s | HitBy=%s | Attacker=%s (%s)%s",
			tName, tType, tGrp, ownerDesc and (" [" .. ownerDesc .. "]") or "", wType, aName, aType, hpStr)
		SkynetIADSLogger.writeGlobalLog("WARN", "UNIT-HIT", msg)
		if ownerLg then
			ownerLg:appendHistoryOnly("UNIT HIT", string.format("%s (%s) hit by %s%s", tName, tType, wType, hpStr))
		end
	elseif evId == world.event.S_EVENT_DEAD or evId == world.event.S_EVENT_UNIT_LOST then
		local dName, dType, dGrp = safeObjNameAndType(event.initiator)
		local ownerLg, ownerDesc = findIADSOwnerInfo(dName, dGrp)
		local msg = string.format("Destroyed=%s | Type=%s | Group=%s%s",
			dName, dType, dGrp, ownerDesc and (" | IADS-Role=" .. ownerDesc) or "")
		SkynetIADSLogger.writeGlobalLog("WARN", "UNIT-DESTROYED", msg)
		if ownerLg then
			ownerLg:appendHistoryOnly("DESTROYED", string.format("%s (%s) [%s]", dName, dType, ownerDesc or dGrp))
		end
	end
end

function SkynetIADSLogger.ensureWorldEventHandler()
	if SkynetIADSLogger.eventHandlerRegistered then
		return
	end
	if world and type(world.addEventHandler) == "function" then
		SkynetIADSLogger.eventHandlerRegistered = true
		world.addEventHandler({
			onEvent = function(_, event)
				SkynetIADSLogger.safeCall("WorldEventHandler", SkynetIADSLogger.handleGlobalWorldEvent, event)
			end
		})
	end
end

function SkynetIADSLogger.emitCardTextForGroup(groupId, text, duration)
	local payload = tostring(text or "")
	local dur = tonumber(duration) or 5
	if groupId and trigger and trigger.action and type(trigger.action.outTextForGroup) == "function" then
		if payload == "__CLOSE__" then
			trigger.action.outTextForGroup(groupId, "__CLOSE__", 1, true)
		else
			trigger.action.outTextForGroup(groupId, payload, dur, true)
		end
	else
		SkynetIADSLogger.emitCardText(payload, dur)
	end
end

function SkynetIADSLogger.checkRadioMenuState()
	local rcdp = _G and _G.RadioCommandDialogsPanel
	if type(rcdp) == "table" then
		if not SkynetIADSLogger.radioPanelHooked and type(rcdp.setShowMenu) == "function" then
			SkynetIADSLogger.radioPanelHooked = true
			local origSetShowMenu = rcdp.setShowMenu
			rcdp.setShowMenu = function(on, ...)
				local res = origSetShowMenu(on, ...)
				local isOpen = (on == true)
				if SkynetIADSLogger.radioMenuOpen ~= isOpen then
					SkynetIADSLogger.radioMenuOpen = isOpen
					if SkynetIADSLogger.isAnyDashboardActive() then
						SkynetIADSLogger.renderGlobalDashboard(2)
					elseif SkynetIADSLogger.cardPayloadText ~= "" and SkynetIADSLogger.cardPayloadText ~= "__CLOSE__" then
						SkynetIADSLogger.emitCardText(SkynetIADSLogger.cardPayloadText, 3)
					end
				end
				return res
			end
		end
		if type(rcdp.isVisible) == "function" then
			local okV, vis = pcall(rcdp.isVisible)
			if okV and type(vis) == "boolean" then
				SkynetIADSLogger.radioMenuOpen = vis
			end
		elseif type(rcdp.showMenu) == "boolean" then
			SkynetIADSLogger.radioMenuOpen = rcdp.showMenu
		end
	end
	return SkynetIADSLogger.radioMenuOpen and 1 or 0
end

function SkynetIADSLogger.emitCardText(text, duration)
	SkynetIADSLogger.cardPayloadText = tostring(text or "")
	SkynetIADSLogger.cardPayloadDuration = tonumber(duration) or 5
	SkynetIADSLogger.cardPayloadSeq = (SkynetIADSLogger.cardPayloadSeq or 0) + 1
	SkynetIADSLogger.checkRadioMenuState()
	if SkynetIADSLogger.cardPayloadText == "__CLOSE__" then
		trigger.action.outText("__CLOSE__", 1, true)
	else
		trigger.action.outText(SkynetIADSLogger.cardPayloadText, SkynetIADSLogger.cardPayloadDuration, true)
	end
end

local CHAR_WIDTHS = {
	[" "]=313, ["!"]=410, ["\""]=469, ["#"]=754, ["$"]=626, ["%"]=901, ["&"]=785, ["'"]=275,
	["("]=411, [")"]=411, ["*"]=470, ["+"]=754, [","]=342, ["-"]=374, ["."]=342, ["/"]=329,
	["0"]=626, ["1"]=626, ["2"]=626, ["3"]=626, ["4"]=626, ["5"]=626, ["6"]=626, ["7"]=626,
	["8"]=626, ["9"]=626, [":"]=360, [";"]=360, ["<"]=754, ["="]=754, [">"]=754, ["?"]=522,
	["@"]=900, ["A"]=696, ["B"]=686, ["C"]=660, ["D"]=747, ["E"]=615, ["F"]=615, ["G"]=738,
	["H"]=753, ["I"]=334, ["J"]=334, ["K"]=697, ["L"]=573, ["M"]=896, ["N"]=753, ["O"]=765,
	["P"]=659, ["Q"]=765, ["R"]=693, ["S"]=648, ["T"]=614, ["U"]=730, ["V"]=696, ["W"]=993,
	["X"]=694, ["Y"]=651, ["Z"]=652, ["["]=411, ["\\"]=329, ["]"]=411, ["^"]=754, ["_"]=450,
	["`"]=450, ["a"]=607, ["b"]=644, ["c"]=533, ["d"]=644, ["e"]=610, ["f"]=391, ["g"]=644,
	["h"]=641, ["i"]=308, ["j"]=308, ["k"]=598, ["l"]=308, ["m"]=938, ["n"]=641, ["o"]=618,
	["p"]=644, ["q"]=644, ["r"]=444, ["s"]=536, ["t"]=430, ["u"]=641, ["v"]=586, ["w"]=831,
	["x"]=580, ["y"]=586, ["z"]=523, ["{"]=641, ["|"]=329, ["}"]=641, ["~"]=754,
	["Ç"]=660, ["Ğ"]=738, ["İ"]=334, ["Ö"]=765, ["Ş"]=648, ["Ü"]=730,
	["ç"]=533, ["ğ"]=644, ["ı"]=308, ["ö"]=618, ["ş"]=536, ["ü"]=641,
	["•"]=575, ["▶"]=692, ["–"]=450, ["—"]=900
}

local SPACE_W = 313

local function visualWidth(str)
	str = tostring(str or "")
	local total = 0
	for ch in string.gmatch(str, "[%z\1-\127\194-\244][\128-\191]*") do
		total = total + (CHAR_WIDTHS[ch] or 630)
	end
	return total
end

local function padToVisualTab(str, targetUnits)
	str = tostring(str or "")
	local w = visualWidth(str)
	if w >= targetUnits then
		return str .. " "
	end
	local spaces = math.floor(((targetUnits - w) + (SPACE_W / 2)) / SPACE_W)
	if spaces < 1 then
		spaces = 1
	end
	return str .. string.rep(" ", spaces)
end

local BOX_VISUAL_WIDTH = 43732
local RULE_DOUBLE = string.rep("=", 58)
local RULE_SINGLE = string.rep("-", 117)

local TAB_COLON = 14250
local TAB_PIPE1 = 21780
local TAB_PIPE2 = 29010
local TAB_PIPE3 = 36240
local TAB_EVENT_COLON = 16650

local function formatFourColumnRow(leftText, c1, c2, c3, c4)
	local line = padToVisualTab(leftText, TAB_COLON) .. ":  " .. tostring(c1)
	line = padToVisualTab(line, TAB_PIPE1) .. "|  " .. tostring(c2)
	line = padToVisualTab(line, TAB_PIPE2) .. "|  " .. tostring(c3)
	line = padToVisualTab(line, TAB_PIPE3) .. "|  " .. tostring(c4)
	return line
end

function SkynetIADSLogger:create(iads)
	local logger = {}
	setmetatable(logger, SkynetIADSLogger)
	logger.debugOutput = {}
	logger.debugOutput.IADSStatus = false
	logger.debugOutput.samDetails = false
	logger.debugOutput.samWentDark = false
	logger.debugOutput.radarWentDark = false
	logger.debugOutput.contacts = false
	logger.debugOutput.radarWentLive = false
	logger.debugOutput.jammerProbability = false
	logger.debugOutput.addedEWRadar = false
	logger.debugOutput.addedSAMSite = false
	logger.debugOutput.warnings = true
	logger.debugOutput.harmDefence = false
	logger.debugOutput.samSiteStatusEnvOutput = false
	logger.debugOutput.earlyWarningRadarStatusEnvOutput = false
	logger.debugOutput.commandCenterStatusEnvOutput = false
	logger.debugOutput.debugScreen = false
	logger.iads = iads
	logger.eventHistory = {}
	logger.maxEvents = 10
	logger.snapshotUntil = 0

	local alreadyRegistered = false
	for i = 1, #SkynetIADSLogger.activeLoggers do
		if SkynetIADSLogger.activeLoggers[i].iads == iads then
			SkynetIADSLogger.activeLoggers[i] = logger
			alreadyRegistered = true
			break
		end
	end
	if not alreadyRegistered then
		table.insert(SkynetIADSLogger.activeLoggers, logger)
	end

	SkynetIADSLogger.ensureWorldEventHandler()
	SkynetIADSLogger.writeGlobalLog("INFO", "IADS-CREATE", "SkynetIADS instance created: " .. tostring(iads and iads.name or "Unnamed"))

	return logger
end

function SkynetIADSLogger:getDebugSettings()
	return self.debugOutput
end

function SkynetIADSLogger:formatMissionTime()
	local absTime = timer and timer.getAbsTime and timer.getAbsTime() or 0
	local totalSec = math.floor(absTime)
	local hours = math.floor(totalSec / 3600) % 24
	local mins = math.floor((totalSec % 3600) / 60)
	local secs = totalSec % 60
	return string.format("%02d:%02d:%02d", hours, mins, secs)
end

function SkynetIADSLogger:appendHistoryOnly(tag, message)
	local timeStr = self:formatMissionTime()
	local prefix = padToVisualTab("  • [" .. timeStr .. "] " .. tostring(tag), TAB_EVENT_COLON)
	local entry = prefix .. ":  " .. tostring(message)
	table.insert(self.eventHistory, 1, entry)
	while #self.eventHistory > self.maxEvents do
		table.remove(self.eventHistory)
	end
end

function SkynetIADSLogger.isViewActive(v, now)
	if not v then
		return false
	end
	now = now or (timer and timer.getTime and timer.getTime() or 0)
	if (v.snapshotUntil or 0) > now then
		return true
	end
	return (v.IADSStatus == true) or (v.contacts == true) or (v.samDetails == true) or (v.debugScreen == true)
end

function SkynetIADSLogger.isGroupDashboardActive(groupId)
	local s = SkynetIADSLogger.groupSessions[groupId]
	if not s then
		return false
	end
	local now = timer and timer.getTime and timer.getTime() or 0
	for i = 1, #SkynetIADSLogger.activeLoggers do
		local lg = SkynetIADSLogger.activeLoggers[i]
		local iads = lg and lg.iads
		if iads and SkynetIADSLogger.canSessionAccessIADS(s, iads) then
			local v = s.views[iads]
			if SkynetIADSLogger.isViewActive(v, now) then
				return true
			end
		end
	end
	return false
end

function SkynetIADSLogger.renderGroupDashboard(groupId, overrideDuration)
	SkynetIADSLogger.ensureLiveTicker()
	local s = SkynetIADSLogger.groupSessions[groupId]
	if not s then
		return false
	end
	local now = timer and timer.getTime and timer.getTime() or 0
	local activeSections = {}

	for i = 1, #SkynetIADSLogger.activeLoggers do
		local lg = SkynetIADSLogger.activeLoggers[i]
		local iads = lg and lg.iads
		if iads and SkynetIADSLogger.canSessionAccessIADS(s, iads) then
			local v = s.views[iads]
			if SkynetIADSLogger.isViewActive(v, now) then
				v.wasActive = true
				table.insert(activeSections, lg:buildCoalitionSection(v))
			end
		end
	end

	if #activeSections == 0 then
		return false
	end

	local title = "SKYNET INTEGRATED AIR DEFENSE (IADS) LIVE DASHBOARD"
	local leftPadUnits = math.max(0, math.floor((BOX_VISUAL_WIDTH - visualWidth(title)) / 2))
	local centeredTitle = padToVisualTab("", leftPadUnits) .. title

	local panelLines = {
		RULE_DOUBLE,
		centeredTitle,
		RULE_DOUBLE,
		table.concat(activeSections, "\n" .. RULE_DOUBLE .. "\n"),
		RULE_DOUBLE
	}

	local duration = overrideDuration or 3
	SkynetIADSLogger.emitCardTextForGroup(groupId, table.concat(panelLines, "\n"), duration)
	return true
end

function SkynetIADSLogger.liveTickerTick()
	SkynetIADSLogger.safeCall("liveTickerTick", function()
		SkynetIADSLogger.checkRadioMenuState()
		pcall(SkynetIADSLogger.syncGroupRadioMenus)

		for gid, session in pairs(SkynetIADSLogger.groupSessions) do
			local rendered = SkynetIADSLogger.renderGroupDashboard(gid, 2)
			if not rendered then
				local hadActive = false
				for _, v in pairs(session.views) do
					if v.wasActive then
						v.wasActive = false
						hadActive = true
					end
				end
				if hadActive then
					SkynetIADSLogger.emitCardTextForGroup(gid, "__CLOSE__", 1)
				end
			end
		end

		if SkynetIADSLogger.isAnyDashboardActive() then
			SkynetIADSLogger.renderGlobalDashboard(2)
		end
	end)
end

function SkynetIADSLogger.ensureLiveTicker()
	SkynetIADSLogger.ensureWorldEventHandler()
	if SkynetIADSLogger.liveTickerID == nil and mist and mist.scheduleFunction and timer and timer.getTime then
		SkynetIADSLogger.liveTickerID = mist.scheduleFunction(SkynetIADSLogger.liveTickerTick, {}, timer.getTime() + 1, 1)
	end
end

function SkynetIADSLogger:recordEvent(tag, message, isEnabled, targetGroupId, category)
	local coaLabel = (self.iads and (self.iads.name or self.iads:getCoalitionString())) or "IADS"
	-- Always write every event to the dedicated SKYNET_IADS_DEBUG.log file and dcs.log!
	SkynetIADSLogger.writeGlobalLog("INFO", tostring(category or tag or "IADS-EVENT"), "[" .. tostring(coaLabel) .. "] " .. tostring(message))

	if self.iads and self.iads.ewRadarScanMistTaskID == nil and tag ~= "NOTIFICATION" and tag ~= "DIAGNOSTIC" then
		return
	end
	self:appendHistoryOnly(tag, message)
	local entry = self.eventHistory[1]

	local popup = RULE_DOUBLE .. "\n"
		.. "  SKYNET IADS TACTICAL ALERT  [" .. tostring(coaLabel) .. "]\n"
		.. RULE_SINGLE .. "\n"
		.. tostring(entry) .. "\n"
		.. RULE_DOUBLE

	if targetGroupId then
		local s = SkynetIADSLogger.groupSessions[targetGroupId]
		if s and SkynetIADSLogger.canSessionAccessIADS(s, self.iads) then
			if SkynetIADSLogger.isGroupDashboardActive(targetGroupId) then
				SkynetIADSLogger.renderGroupDashboard(targetGroupId, 2)
			else
				SkynetIADSLogger.emitCardTextForGroup(targetGroupId, popup, 6)
			end
		end
		return
	end

	for gid, s in pairs(SkynetIADSLogger.groupSessions) do
		if SkynetIADSLogger.canSessionAccessIADS(s, self.iads) then
			local v = s.views[self.iads]
			if v and (v.notifications or v.debugScreen) then
				if SkynetIADSLogger.isGroupDashboardActive(gid) then
					SkynetIADSLogger.renderGroupDashboard(gid, 2)
				elseif v.notifications then
					SkynetIADSLogger.emitCardTextForGroup(gid, popup, 6)
				end
			end
		end
	end

	if isEnabled and next(SkynetIADSLogger.groupSessions) == nil then
		if SkynetIADSLogger.isAnyDashboardActive() then
			SkynetIADSLogger.renderGlobalDashboard(2)
		else
			SkynetIADSLogger.emitCardText(popup, 6)
		end
	end
end

function SkynetIADSLogger:printOutput(output, typeWarning)
	local coaLabel = (self.iads and (self.iads.name or self.iads:getCoalitionString())) or "IADS"
	if typeWarning == true then
		SkynetIADSLogger.writeGlobalLog("WARN", "IADS-WARNING", "[" .. tostring(coaLabel) .. "] " .. tostring(output))
	else
		SkynetIADSLogger.writeGlobalLog("INFO", "IADS-OUTPUT", "[" .. tostring(coaLabel) .. "] " .. tostring(output))
	end
end

function SkynetIADSLogger:printOutputToLog(output, typeWarning)
	local coaLabel = (self.iads and (self.iads.name or self.iads:getCoalitionString())) or "IADS"
	if typeWarning == true then
		SkynetIADSLogger.writeGlobalLog("WARN", "IADS-WARNING", "[" .. tostring(coaLabel) .. "] " .. tostring(output))
	else
		SkynetIADSLogger.writeGlobalLog("INFO", "IADS-LOG", "[" .. tostring(coaLabel) .. "] " .. tostring(output))
	end
end

function SkynetIADSLogger:dumpFullDiagnosticReport(triggerReason)
	local iads = self.iads
	if not iads then
		return
	end
	local lines = {}
	local netName = tostring(iads.name or iads:getCoalitionString())
	table.insert(lines, "==================== SKYNET-IADS FULL DIAGNOSTIC REPORT ====================")
	table.insert(lines, string.format("Network: %s | Coalition: %s | Trigger: %s | %s",
		netName, tostring(iads:getCoalitionString()), tostring(triggerReason or "Manual/Startup"), formatSimAndClockTime()))
	table.insert(lines, string.format("Caught Runtime Exceptions: %d | Total Logged Events: %d",
		SkynetIADSLogger.totalErrorCount, SkynetIADSLogger.eventCounter))
	table.insert(lines, "MIST Version: " .. ((_G.mist and _G.mist.majorVersion) and string.format("v%s.%s.%s", tostring(_G.mist.majorVersion), tostring(_G.mist.minorVersion), tostring(_G.mist.build)) or "Not Loaded"))

	local ccs = iads:getCommandCenters() or {}
	local ewrs = iads:getEarlyWarningRadars() or {}
	local sams = iads:getSAMSites() or {}
	table.insert(lines, string.format("Summary -> Command Centers: %d (Usable: %s) | Early Warning Radars: %d | SAM Sites: %d | Active Contacts: %d",
		#ccs, tostring(iads:isCommandCenterUsable()), #ewrs, #sams, #(iads:getContacts() or {})))

	for i = 1, #ccs do
		local cc = ccs[i]
		table.insert(lines, string.format("  [CC #%d] Name=%s | Destroyed=%s | HasPower=%s (PowerSources=%d) | HasConnection=%s (Nodes=%d)",
			i, tostring(cc:getDCSName()), tostring(cc:isDestroyed()), tostring(cc:hasWorkingPowerSource()), #(cc:getPowerSources() or {}),
			tostring(cc:hasActiveConnectionNode()), #(cc:getConnectionNodes() or {})))
	end

	for i = 1, #ewrs do
		local ew = ewrs[i]
		table.insert(lines, string.format("  [EWR #%d] Name=%s | NATO=%s | Active=%s | Destroyed=%s | Autonomous=%s | HARM-Chance=%d%% | DefendingHARM=%s | ChildSAMs=%d | Power=%d | Nodes=%d",
			i, tostring(ew:getDCSName()), tostring(ew:getNatoName()), tostring(ew:isActive()), tostring(ew:isDestroyed()),
			tostring(ew:getAutonomousState()), tonumber(ew:getHARMDetectionChance()) or 0, tostring(ew:isDefendingHARM()),
			#(ew:getChildRadars() or {}), #(ew:getPowerSources() or {}), #(ew:getConnectionNodes() or {})))
	end

	for i = 1, #sams do
		local sam = sams[i]
		local zoneStr = (sam:getEngagementZone() == SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE) and "SEARCH_RANGE" or "KILL_ZONE"
		local autoModeStr = (sam:getAutonomousBehaviour() == SkynetIADSAbstractRadarElement.AUTONOMOUS_STATE_DARK) and "DARK" or "DCS_AI"
		table.insert(lines, string.format("  [SAM #%d] Group=%s | NATO=%s | Active=%s | Destroyed=%s | WorkingRadar=%s | Autonomous=%s (Mode:%s) | Zone=%s (%d%%) | ActAsEW=%s | PointDefRole=%s |AttachedPDs=%d | Missiles=%d/%d (InFlight:%d) | HARM-Chance=%d%% (EngageHARM:%s, Defending:%s) | Parents=%d | Children=%d | Power=%d | Nodes=%d",
			i, tostring(sam:getDCSName()), tostring(sam:getNatoName()), tostring(sam:isActive()), tostring(sam:isDestroyed()),
			tostring(sam:hasWorkingRadar()), tostring(sam:getAutonomousState()), autoModeStr,
			zoneStr, tonumber(sam:getGoLiveRangeInPercent()) or 100, tostring(sam:getActAsEW()),
			tostring(sam:getIsAPointDefence()), #(sam:getPointDefences() or {}),
			tonumber(sam:getRemainingNumberOfMissiles()) or 0, tonumber(sam:getInitialNumberOfMissiles()) or 0,
			tonumber(sam:getNumberOfMissilesInFlight()) or 0,
			tonumber(sam:getHARMDetectionChance()) or 0, tostring(sam:getCanEngageHARM()), tostring(sam:isDefendingHARM()),
			#(sam:getParentRadars() or {}), #(sam:getChildRadars() or {}),
			#(sam:getPowerSources() or {}), #(sam:getConnectionNodes() or {})))
	end

	if #SkynetIADSLogger.errorHistory > 0 then
		table.insert(lines, "-------------------- CAUGHT RUNTIME EXCEPTIONS --------------------")
		for i = 1, math.min(#SkynetIADSLogger.errorHistory, 10) do
			local e = SkynetIADSLogger.errorHistory[i]
			table.insert(lines, string.format("  [ERROR #%d | %s | %s] %s", e.id, e.time, e.category, e.message))
			if e.stack and e.stack ~= "" then
				table.insert(lines, "    Stack: " .. string.gsub(e.stack, "[\r\n]+", " <- "))
			end
		end
	else
		table.insert(lines, "Caught Runtime Exceptions: NONE (0 Errors)")
	end
	table.insert(lines, "============================================================================")

	for i = 1, #lines do
		SkynetIADSLogger.writeGlobalLog("INFO", "DIAGNOSTIC-REPORT", lines[i])
	end
	return lines
end

function SkynetIADSLogger:isDashboardActive()
	local now = timer and timer.getTime and timer.getTime() or 0
	if self.snapshotUntil > now then
		return true
	end
	local dbg = self:getDebugSettings()
	return dbg.IADSStatus or dbg.contacts or dbg.samDetails or dbg.debugScreen
end

function SkynetIADSLogger.isAnyDashboardActive()
	for i = 1, #SkynetIADSLogger.activeLoggers do
		local lg = SkynetIADSLogger.activeLoggers[i]
		if lg and lg.iads and lg:isDashboardActive() then
			return true
		end
	end
	return false
end

function SkynetIADSLogger:buildCoalitionSection(viewOverride)
	local now = timer and timer.getTime and timer.getTime() or 0
	local dbg = viewOverride or self:getDebugSettings()
	local snapUntil = (viewOverride and viewOverride.snapshotUntil) or self.snapshotUntil or 0
	local isSnapshot = (snapUntil > now)
	local showDebugScreen = (dbg.debugScreen == true)
	local showEvents = showDebugScreen or (viewOverride and viewOverride.notifications) or (not viewOverride and (dbg.radarWentLive or dbg.radarWentDark or dbg.harmDefence)) or isSnapshot
	local lines = {}

	local coaStr = "RED"
	if self.iads.coalitionID == coalition.side.BLUE then
		coaStr = "BLUE"
	elseif self.iads.coalitionID == coalition.side.NEUTRAL then
		coaStr = "NEUTRAL"
	end
	local netName = self.iads.name and string.len(self.iads.name) > 0 and self.iads.name or coaStr

	local hdrLine = padToVisualTab("▶ " .. netName, TAB_PIPE1)
		.. "|  Side: " .. coaStr
	hdrLine = padToVisualTab(hdrLine, TAB_PIPE2)
		.. "|  Time: " .. self:formatMissionTime()
	if isSnapshot then
		local remSnap = math.max(1, math.ceil(snapUntil - now))
		hdrLine = padToVisualTab(hdrLine, TAB_PIPE3) .. "|  Snap: " .. remSnap .. "s"
	elseif showDebugScreen then
		hdrLine = padToVisualTab(hdrLine, TAB_PIPE3) .. "|  Err: " .. tostring(SkynetIADSLogger.totalErrorCount)
	else
		hdrLine = padToVisualTab(hdrLine, TAB_PIPE3) .. "|  Mode: LIVE"
	end
	table.insert(lines, hdrLine)
	table.insert(lines, RULE_SINGLE)

	if dbg.IADSStatus or isSnapshot or showDebugScreen then
		-- 1) Command Centers
		local commandCenters = self.iads:getCommandCenters()
		local numComCenters = #commandCenters
		local numComCentersNoPower = 0
		local numIntactComCenters = 0
		for i = 1, #commandCenters do
			local cc = commandCenters[i]
			if cc:hasWorkingPowerSource() == false then numComCentersNoPower = numComCentersNoPower + 1 end
			if cc:isDestroyed() == false then numIntactComCenters = numIntactComCenters + 1 end
		end
		local numDestroyedComCenters = numComCenters - numIntactComCenters

		-- 2) Early Warning Radars
		local earlyWarningRadars = self.iads:getEarlyWarningRadars()
		local ewTotal = #earlyWarningRadars
		local ewActive = 0
		for i = 1, #earlyWarningRadars do
			local ew = earlyWarningRadars[i]
			if ew:isActive() then ewActive = ewActive + 1 end
		end
		local numEWRadarsDestroyed = #self.iads:getDestroyedEarlyWarningRadars()
		local ewRadarsInactive = math.max(0, ewTotal - ewActive - numEWRadarsDestroyed)

		-- 3) SAM Sites
		local samSites = self.iads:getSAMSites()
		local samSitesTotal = #samSites
		local samSitesActive = 0
		local samSitesOutOfAmmo = 0
		local samSiteAutonomous = 0
		local samSiteRadarDestroyed = 0
		local samSiteDefendingHarm = 0
		for i = 1, #samSites do
			local sam = samSites[i]
			if sam:isActive() then samSitesActive = samSitesActive + 1 end
			if sam:hasRemainingAmmo() == false then samSitesOutOfAmmo = samSitesOutOfAmmo + 1 end
			if sam:getAutonomousState() == true then samSiteAutonomous = samSiteAutonomous + 1 end
			if sam:hasWorkingRadar() == false then samSiteRadarDestroyed = samSiteRadarDestroyed + 1 end
			if sam:isDefendingHARM() then samSiteDefendingHarm = samSiteDefendingHarm + 1 end
		end
		local samSitesInactive = math.max(0, samSitesTotal - samSitesActive)
		local samSitesReady = math.max(0, samSitesTotal - samSiteRadarDestroyed - samSitesOutOfAmmo)

		table.insert(lines, formatFourColumnRow("  • Command Center",
			"Total: " .. numComCenters,
			"Intact: " .. numIntactComCenters,
			"Dead: " .. numDestroyedComCenters,
			"NoPwr: " .. numComCentersNoPower))

		table.insert(lines, formatFourColumnRow("  • Early Warning",
			"Total: " .. ewTotal,
			"Live: " .. ewActive,
			"Dark: " .. ewRadarsInactive,
			"Dead: " .. numEWRadarsDestroyed))

		table.insert(lines, formatFourColumnRow("  • SAM Batteries",
			"Total: " .. samSitesTotal,
			"Live: " .. samSitesActive,
			"Dark: " .. samSitesInactive,
			"Auton: " .. samSiteAutonomous))

		table.insert(lines, formatFourColumnRow("  • SAM Readiness",
			"Ready: " .. samSitesReady,
			"HARM: " .. samSiteDefendingHarm,
			"RdrDead: " .. samSiteRadarDestroyed,
			"NoAmmo: " .. samSitesOutOfAmmo))
	end

	-- Optional Per-Battery SAM Detail List
	if dbg.samDetails or isSnapshot then
		local samSites = self.iads:getSAMSites()
		if #samSites > 0 then
			table.insert(lines, RULE_SINGLE)
			table.insert(lines, "  [ SAM BATTERY LIST (" .. #samSites .. ") ]")
			for i = 1, #samSites do
				local sam = samSites[i]
				local stateStr = "DARK"
				if sam:isDestroyed() or sam:hasWorkingRadar() == false then
					stateStr = "RADAR DEAD"
				elseif sam:isDefendingHARM() then
					local remHarm = sam.getRemainingHARMShutdownTime and sam:getRemainingHARMShutdownTime() or sam:getHARMShutdownTime()
					stateStr = "HARM (" .. tostring(remHarm) .. "s)"
				elseif sam:hasRemainingAmmo() == false then
					stateStr = "NO AMMO"
				elseif sam:isActive() then
					stateStr = "LIVE"
				end
				local roleStr = sam:getIsAPointDefence() and "PointDef" or "MainSAM"
				local remMsl = sam:getRemainingNumberOfMissiles()
				local initMsl = sam:getInitialNumberOfMissiles()
				local ammoTxt = string.format("Msl: %d/%d", remMsl, initMsl)
				table.insert(lines, formatFourColumnRow("  • " .. tostring(sam:getDCSName()),
					"Type: " .. tostring(sam:getNatoName()),
					stateStr,
					"Role: " .. roleStr,
					ammoTxt))
			end
		end
	end

	-- Optional Active Radar Contacts
	if dbg.contacts or isSnapshot then
		local contacts = self.iads:getContacts()
		local numContacts = contacts and #contacts or 0
		table.insert(lines, RULE_SINGLE)
		table.insert(lines, "  [ ACTIVE RADAR CONTACTS (" .. numContacts .. ") ]")
		if numContacts == 0 then
			table.insert(lines, "  • No active radar contacts detected.")
		else
			local maxShow = math.min(numContacts, 8)
			for i = 1, maxShow do
				local c = contacts[i]
				local spdTxt = string.format("Spd: %d kt", tonumber(c:getGroundSpeedInKnots(0)) or 0)
				local hdgTxt = string.format("Hdg: %03d", tonumber(c:getMagneticHeading()) or 0)
				local ageTxt = string.format("Age: %ds", tonumber(c:getAge()) or 0)
				table.insert(lines, formatFourColumnRow("  • " .. tostring(c:getName()),
					"Type: " .. tostring(c:getTypeName()),
					spdTxt,
					hdgTxt,
					ageTxt))
			end
			if numContacts > maxShow then
				table.insert(lines, string.format("  ... and %d more contacts", numContacts - maxShow))
			end
		end
	end

	-- Dedicated Debug & Error Monitor Screen Section
	if showDebugScreen then
		table.insert(lines, RULE_SINGLE)
		table.insert(lines, formatFourColumnRow("  • Debug Logger",
			"File: SKYNET_IADS_DEBUG.log",
			"Events: " .. tostring(SkynetIADSLogger.eventCounter),
			"Errors: " .. tostring(SkynetIADSLogger.totalErrorCount),
			"Queue: " .. tostring(#(_G.SKYNET_DEBUG_QUEUE or {}))))
		if #SkynetIADSLogger.errorHistory > 0 then
			table.insert(lines, "  [ CAUGHT RUNTIME ERRORS (" .. #SkynetIADSLogger.errorHistory .. ") ]")
			for i = 1, math.min(#SkynetIADSLogger.errorHistory, 4) do
				local err = SkynetIADSLogger.errorHistory[i]
				table.insert(lines, string.format("  ! [#%d | %s] %s", err.id, err.category, err.message))
			end
		else
			table.insert(lines, "  • Runtime Exceptions: NONE (0 Errors Caught)")
		end
	end

	-- Recent Events Feed inside panel when notifications, debugScreen, or snapshot active
	if showEvents and #self.eventHistory > 0 then
		table.insert(lines, RULE_SINGLE)
		table.insert(lines, "  [ RECENT IADS & COMBAT EVENTS ]")
		local maxEv = showDebugScreen and math.min(#self.eventHistory, 8) or math.min(#self.eventHistory, 5)
		for i = 1, maxEv do
			table.insert(lines, self.eventHistory[i])
		end
	end

	return table.concat(lines, "\n")
end

function SkynetIADSLogger.renderGlobalDashboard(overrideDuration)
	SkynetIADSLogger.ensureLiveTicker()

	local activeSections = {}
	local minInterval = 2

	for i = 1, #SkynetIADSLogger.activeLoggers do
		local lg = SkynetIADSLogger.activeLoggers[i]
		if lg and lg.iads and lg:isDashboardActive() then
			table.insert(activeSections, lg:buildCoalitionSection())
		end
	end

	if #activeSections == 0 then
		return
	end

	local title = "SKYNET INTEGRATED AIR DEFENSE (IADS) LIVE DASHBOARD"
	local leftPadUnits = math.max(0, math.floor((BOX_VISUAL_WIDTH - visualWidth(title)) / 2))
	local centeredTitle = padToVisualTab("", leftPadUnits) .. title

	local panelLines = {
		RULE_DOUBLE,
		centeredTitle,
		RULE_DOUBLE,
		table.concat(activeSections, "\n" .. RULE_DOUBLE .. "\n"),
		RULE_DOUBLE
	}

	local duration = overrideDuration or (minInterval + 1)
	SkynetIADSLogger.emitCardText(table.concat(panelLines, "\n"), duration)
end

function SkynetIADSLogger:printEarlyWarningRadarStatus()
	local ewRadars = self.iads:getEarlyWarningRadars()
	self:printOutputToLog("------------------------------------------ EARLY WARNING RADAR STATUS: "..self.iads:getCoalitionString().." -------------------------------")
	for i = 1, #ewRadars do
		local ewRadar = ewRadars[i]
		local numConnectionNodes = #ewRadar:getConnectionNodes()
		local numPowerSources = #ewRadar:getPowerSources()
		local isActive = ewRadar:isActive()
		local connectionNodes = ewRadar:getConnectionNodes()
		local firstRadar = nil
		local radars = ewRadar:getRadars()
		
		for j = 1, #radars do
			if radars[j]:isExist() then
				firstRadar = radars[j]
				break
			end
		end
		local numDamagedConnectionNodes = 0
		for j = 1, #connectionNodes do
			local connectionNode = connectionNodes[j]
			if connectionNode:isExist() == false then
				numDamagedConnectionNodes = numDamagedConnectionNodes + 1
			end
		end
		local intactConnectionNodes = numConnectionNodes - numDamagedConnectionNodes
		
		local powerSources = ewRadar:getPowerSources()
		local numDamagedPowerSources = 0
		for j = 1, #powerSources do
			local powerSource = powerSources[j]
			if powerSource:isExist() == false then
				numDamagedPowerSources = numDamagedPowerSources + 1
			end
		end
		local intactPowerSources = numPowerSources - numDamagedPowerSources 
		
		local detectedTargets = ewRadar:getDetectedTargets()
		local samSitesInCoveredArea = ewRadar:getChildRadars()
		
		local unitName = "DESTROYED"
		if ewRadar:getDCSRepresentation():isExist() then
			unitName = ewRadar:getDCSName()
		end
		
		self:printOutputToLog("UNIT: "..unitName.." | TYPE: "..ewRadar:getNatoName())
		self:printOutputToLog("ACTIVE: "..tostring(isActive).." | DETECTED TARGETS: "..#detectedTargets.." | DEFENDING HARM: "..tostring(ewRadar:isDefendingHARM()))
		if numConnectionNodes > 0 then
			self:printOutputToLog("CONNECTION NODES: "..numConnectionNodes.." | DAMAGED: "..numDamagedConnectionNodes.." | INTACT: "..intactConnectionNodes)
		else
			self:printOutputToLog("NO CONNECTION NODES CONFIGURED")
		end
		if numPowerSources > 0 then
			self:printOutputToLog("POWER SOURCES: "..numPowerSources.." | DAMAGED: "..numDamagedPowerSources.." | INTACT: "..intactPowerSources)
		else
			self:printOutputToLog("NO POWER SOURCES CONFIGURED")
		end
		
		self:printOutputToLog("SAM SITES IN COVERED AREA: "..#samSitesInCoveredArea)
		for j = 1, #samSitesInCoveredArea do
			local samSiteCovered = samSitesInCoveredArea[j]
			self:printOutputToLog(samSiteCovered:getDCSName())
		end
		
		for j = 1, #detectedTargets do
			local contact = detectedTargets[j]
			if firstRadar ~= nil and firstRadar:isExist() then
				local distance = mist.utils.round(mist.utils.metersToNM(ewRadar:getDistanceInMetersToContact(firstRadar:getDCSRepresentation(), contact:getPosition().p)), 2)
				self:printOutputToLog("CONTACT: "..contact:getName().." | TYPE: "..contact:getTypeName().." | DISTANCE (NM): "..distance)
			end
		end
		
		self:printOutputToLog("---------------------------------------------------")
	end
end

function SkynetIADSLogger:getMetaInfo(abstractElementSupport)
	local info = {}
	info.numSources = #abstractElementSupport
	info.numDamagedSources = 0
	info.numIntactSources = 0
	for j = 1, #abstractElementSupport do
		local source = abstractElementSupport[j]
		if source:isExist() == false then
			info.numDamagedSources = info.numDamagedSources + 1
		end
	end
	info.numIntactSources = info.numSources - info.numDamagedSources
	return info
end

function SkynetIADSLogger:printSAMSiteStatus()
	local samSites = self.iads:getSAMSites()
	
	self:printOutputToLog("------------------------------------------ SAM SITE STATUS: "..self.iads:getCoalitionString().." -------------------------------")
	for i = 1, #samSites do
		local samSite = samSites[i]
		local numConnectionNodes = #samSite:getConnectionNodes()
		local numPowerSources = #samSite:getPowerSources()
		local isAutonomous = samSite:getAutonomousState()
		local isActive = samSite:isActive()
		
		local connectionNodes = samSite:getConnectionNodes()
		local firstRadar = samSite:getRadars()[1]
		local numDamagedConnectionNodes = 0
		for j = 1, #connectionNodes do
			local connectionNode = connectionNodes[j]
			if connectionNode:isExist() == false then
				numDamagedConnectionNodes = numDamagedConnectionNodes + 1
			end
		end
		local intactConnectionNodes = numConnectionNodes - numDamagedConnectionNodes
		
		local powerSources = samSite:getPowerSources()
		local numDamagedPowerSources = 0
		for j = 1, #powerSources do
			local powerSource = powerSources[j]
			if powerSource:isExist() == false then
				numDamagedPowerSources = numDamagedPowerSources + 1
			end
		end
		local intactPowerSources = numPowerSources - numDamagedPowerSources 
		
		local detectedTargets = samSite:getDetectedTargets()
		local samSitesInCoveredArea = samSite:getChildRadars()
		local engageAirWeapons = samSite:getCanEngageAirWeapons()
		local engageHARMS = samSite:getCanEngageHARM()
		local hasAmmo = samSite:hasRemainingAmmo()
		
		self:printOutputToLog("GROUP: "..samSite:getDCSName().." | TYPE: "..samSite:getNatoName())
		self:printOutputToLog("ACTIVE: "..tostring(isActive).." | AUTONOMOUS: "..tostring(isAutonomous).." | ACT AS EW: "..tostring(samSite:getActAsEW()).." | ENGAGE AIR WEAPONS: "..tostring(engageAirWeapons).." | ENGAGE HARM: "..tostring(engageHARMS).." | HAS AMMO: "..tostring(hasAmmo).." | DETECTED TARGETS: "..#detectedTargets.." | DEFENDING HARM: "..tostring(samSite:isDefendingHARM()).." | MISSILES IN FLIGHT: "..tostring(samSite:getNumberOfMissilesInFlight()))
		
		if numConnectionNodes > 0 then
			self:printOutputToLog("CONNECTION NODES: "..numConnectionNodes.." | DAMAGED: "..numDamagedConnectionNodes.." | INTACT: "..intactConnectionNodes)
		else
			self:printOutputToLog("NO CONNECTION NODES CONFIGURED")
		end
		if numPowerSources > 0 then
			self:printOutputToLog("POWER SOURCES: "..numPowerSources.." | DAMAGED: "..numDamagedPowerSources.." | INTACT: "..intactPowerSources)
		else
			self:printOutputToLog("NO POWER SOURCES CONFIGURED")
		end
		
		self:printOutputToLog("SAM SITES IN COVERED AREA: "..#samSitesInCoveredArea)
		for j = 1, #samSitesInCoveredArea do
			local samSiteCovered = samSitesInCoveredArea[j]
			self:printOutputToLog(samSiteCovered:getDCSName())
		end
		
		for j = 1, #detectedTargets do
			local contact = detectedTargets[j]
			if firstRadar ~= nil and firstRadar:isExist() then
				local distance = mist.utils.round(mist.utils.metersToNM(samSite:getDistanceInMetersToContact(firstRadar:getDCSRepresentation(), contact:getPosition().p)), 2)
				self:printOutputToLog("CONTACT: "..contact:getName().." | TYPE: "..contact:getTypeName().." | DISTANCE (NM): "..distance)
			end
		end
		
		self:printOutputToLog("---------------------------------------------------")
	end
end

function SkynetIADSLogger:printCommandCenterStatus()
	local commandCenters = self.iads:getCommandCenters()
	self:printOutputToLog("------------------------------------------ COMMAND CENTER STATUS: "..self.iads:getCoalitionString().." -------------------------------")
	
	for i = 1, #commandCenters do
		local commandCenter = commandCenters[i]
		local powerSourceInfo = self:getMetaInfo(commandCenter:getPowerSources())
		local connectionNodeInfo = self:getMetaInfo(commandCenter:getConnectionNodes())
		self:printOutputToLog("OBJECT: "..commandCenter:getDCSName().." | TYPE: "..commandCenter:getNatoName())
		if connectionNodeInfo.numSources > 0 then
			self:printOutputToLog("CONNECTION NODES: "..connectionNodeInfo.numSources.." | DAMAGED: "..connectionNodeInfo.numDamagedSources.." | INTACT: "..connectionNodeInfo.numIntactSources)
		else
			self:printOutputToLog("NO CONNECTION NODES CONFIGURED")
		end
		if powerSourceInfo.numSources > 0 then
			self:printOutputToLog("POWER SOURCES: "..powerSourceInfo.numSources.." | DAMAGED: "..powerSourceInfo.numDamagedSources.." | INTACT: "..powerSourceInfo.numIntactSources)
		else
			self:printOutputToLog("NO POWER SOURCES CONFIGURED")
		end
		self:printOutputToLog("---------------------------------------------------")
	end
end

function SkynetIADSLogger:printSystemStatus()
	if self:isDashboardActive() then
		SkynetIADSLogger.renderGlobalDashboard()
	end
	
	if self:getDebugSettings().commandCenterStatusEnvOutput then
		self:printCommandCenterStatus()
	end

	if self:getDebugSettings().earlyWarningRadarStatusEnvOutput then
		self:printEarlyWarningRadarStatus()
	end
	
	if self:getDebugSettings().samSiteStatusEnvOutput then
		self:printSAMSiteStatus()
	end
end

end
