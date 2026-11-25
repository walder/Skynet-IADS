-- ============================================================================
-- SKYNET-IADS DATA CARD HUD & DEDICATED DEBUG LOG BRIDGE HOOK MODULE
-- ============================================================================
-- • Renders Skynet IADS Live Dashboard & Debug Screen inside the 640px
--   3-slice SkynetDataCard HUD window (SkynetCard_Top640 / Mid640 / Bot640).
-- • Automatically shifts down when the F10 / Radio Communication menu is open
--   and returns to the top-right corner when closed.
-- • Continuously drains _G.SKYNET_DEBUG_QUEUE from the Mission Scripting
--   environment and writes all Skynet IADS events, status diagnostics, and
--   caught runtime exceptions to a dedicated separate log file:
--     1) Saved Games\DCS\Logs\SKYNET_IADS_DEBUG.log
--     2) C:\Users\TurkishCommunity\Desktop\Scriptler\SKYNET_IADS_DEBUG.log
-- ============================================================================

do
	if not package then
		return
	end
	package.path = package.path .. ";.\\Scripts\\?.lua;.\\Scripts\\UI\\?.lua;.\\dxgui\\loader\\?.lua;.\\dxgui\\bind\\?.lua;.\\dxgui\\skins\\skinME\\?.lua;.\\dxgui\\skins\\common\\?.lua;"

	local okLfs, lfs = pcall(require, "lfs")
	local okGui, Gui = pcall(require, "dxgui")
	local okDl, DialogLoader = pcall(require, "DialogLoader")
	local okSt, Static = pcall(require, "Static")
	if not (okLfs and lfs and okGui and Gui and okDl and DialogLoader and okSt and Static) then
		return
	end

	local CARD_W = 640
	local TOP_H = 75
	local MID_MIN_H = 70
	local BOT_H = 51
	local TEXT_TOP_OFFSET = 58
	local TEXT_BOT_MARGIN = 36
	local LINE_H = 16
	local MAX_LINES = 45
	local MARGIN_RIGHT = 14
	local DEFAULT_TOP_Y = 4
	local RADIO_OPEN_FALLBACK_Y = 252

	local writeDir = lfs.writedir()
	local assetDir = writeDir .. "Scripts\\Hooks\\SkynetDataCard\\"
	local dlgPath  = assetDir .. "SkynetDataCard.dlg"
	local topPng   = assetDir .. "SkynetCard_Top640.png"
	local midPng   = assetDir .. "SkynetCard_Mid640.png"
	local botPng   = assetDir .. "SkynetCard_Bot640.png"

	local debugLogPaths = {
		writeDir .. "Logs\\SKYNET_IADS_DEBUG.log"
	}
	pcall(function()
		local userProfile = (os and type(os.getenv) == "function" and os.getenv("USERPROFILE")) or string.match(writeDir, "^([A-Za-z]:\\Users\\[^\\]+)")
		if userProfile and userProfile ~= "" then
			local desktopProjDir = userProfile .. "\\Desktop\\Scriptler"
			local attr = lfs.attributes(desktopProjDir)
			if attr and attr.mode == "directory" then
				table.insert(debugLogPaths, desktopProjDir .. "\\SKYNET_IADS_DEBUG.log")
			else
				local desktopDir = userProfile .. "\\Desktop"
				local dAttr = lfs.attributes(desktopDir)
				if dAttr and dAttr.mode == "directory" then
					table.insert(debugLogPaths, desktopDir .. "\\SKYNET_IADS_DEBUG.log")
				end
			end
		end
	end)

	local cardWin = nil
	local sTop, sMid, sBot, sTextTemplate = nil, nil, nil, nil
	local lineStatics = {}
	local expireClock = 0
	local isCardShowing = false
	local currentTopY = DEFAULT_TOP_Y
	local lastTotalH = TOP_H + MID_MIN_H + BOT_H
	local lastSyncClock = 0
	local lastCmdSyncClock = 0
	local lastDebugFlushClock = 0
	local hookEventCounter = 0
	local lastLoggedCardState = ""
	local lastLoggedCmdList = ""

	local function writeToDebugFiles(linesTbl)
		if not (io and type(io.open) == "function") then
			return
		end
		if type(linesTbl) == "string" then
			linesTbl = { linesTbl }
		end
		if #linesTbl == 0 then
			return
		end
		local payload = table.concat(linesTbl, "\n") .. "\n"
		for i = 1, #debugLogPaths do
			pcall(function()
				local f = io.open(debugLogPaths[i], "a")
				if f then
					f:write(payload)
					f:flush()
					f:close()
				end
			end)
		end
	end

	local function hookDebugLog(level, category, msg)
		hookEventCounter = hookEventCounter + 1
		local wallTime = (os and type(os.date) == "function" and os.date("%Y-%m-%d %H:%M:%S")) or "00:00:00"
		local modelTime = 0
		if DCS and type(DCS.getModelTime) == "function" then
			local okT, mt = pcall(DCS.getModelTime)
			if okT and type(mt) == "number" then modelTime = mt end
		end
		local formatted = string.format("[%s | HOOK #%04d | Model:%.2fs] [%s] [%s] %s",
			wallTime, hookEventCounter, modelTime, tostring(level or "INFO"), tostring(category or "HOOK"), tostring(msg or ""))
		if net and net.log then
			net.log("[Skynet-IADS-Hook] " .. formatted)
		end
		writeToDebugFiles(formatted)
	end

	local function hookSafeCall(category, fn, ...)
		local args = { ... }
		local nArgs = select("#", ...)
		local traceStr = ""
		local ok, res = xpcall(function()
			if nArgs == 0 then
				return fn()
			elseif nArgs == 1 then
				return fn(args[1])
			elseif nArgs == 2 then
				return fn(args[1], args[2])
			else
				return fn(args[1], args[2], args[3])
			end
		end, function(err)
			if debug and type(debug.traceback) == "function" then
				traceStr = debug.traceback(tostring(err), 2)
			else
				traceStr = tostring(err)
			end
			return err
		end)
		if not ok then
			hookDebugLog("ERROR", category, "HOOK EXCEPTION: " .. tostring(res) .. " | STACK: " .. string.gsub(traceStr, "[\r\n]+", " <- "))
			return false, nil
		end
		return true, res
	end

	local function verifyAssetFiles()
		local files = {
			{ label = "DLG", path = dlgPath },
			{ label = "TOP_PNG", path = topPng },
			{ label = "MID_PNG", path = midPng },
			{ label = "BOT_PNG", path = botPng },
		}
		for i = 1, #files do
			local item = files[i]
			local attr = lfs.attributes(item.path)
			if attr and attr.size then
				hookDebugLog("INFO", "ASSET-CHECK", string.format("%s OK (%d bytes): %s", item.label, attr.size, item.path))
			else
				hookDebugLog("ERROR", "ASSET-CHECK", string.format("%s MISSING: %s", item.label, item.path))
			end
		end
	end

	local drainMissionDebugQueueCode = [[
		_G.SKYNET_HOOK_LOG_ACTIVE = true
		if type(_G.SKYNET_DEBUG_QUEUE) == "table" and #_G.SKYNET_DEBUG_QUEUE > 0 then
			local out = table.concat(_G.SKYNET_DEBUG_QUEUE, "\n")
			_G.SKYNET_DEBUG_QUEUE = {}
			return out
		end
		return ""
	]]

	local function flushMissionDebugQueues()
		if not (net and type(net.dostring_in) == "function") then
			return
		end
		for _, envName in ipairs({ "server", "mission", "scripting" }) do
			local okD, resD = pcall(net.dostring_in, envName, drainMissionDebugQueueCode)
			if okD and type(resD) == "string" and resD ~= "" then
				local wallTime = (os and type(os.date) == "function" and os.date("%Y-%m-%d %H:%M:%S")) or "00:00:00"
				local outLines = {}
				for line in string.gmatch(resD .. "\n", "(.-)\r?\n") do
					if line ~= "" then
						table.insert(outLines, string.format("[%s | %s] %s", wallTime, string.upper(envName), line))
					end
				end
				if #outLines > 0 then
					writeToDebugFiles(outLines)
				end
			end
		end
	end

	local guiSyncCode = [[
		local gm = (package and package.loaded and package.loaded["gameMessages"]) or _G.gameMessages
		if gm then
			if not gm._skynetSuppressInstalled then
				gm._skynetSuppressInstalled = true
				gm.addTriggerMessage = function(a_text, a_duration, a_clearView)
					if gm.window and gm.window.autoScrollTextTrig then
						pcall(function()
							gm.window.autoScrollTextTrig:clear()
							gm.window.autoScrollTextTrig:setVisible(false)
						end)
					end
				end
			end
			if gm.window and gm.window.autoScrollTextTrig then
				pcall(function()
					gm.window.autoScrollTextTrig:clear()
					gm.window.autoScrollTextTrig:setVisible(false)
				end)
			end
		end
		return "OK"
	]]

	local radioMenuVisibleCheckCode = [[
		if RadioCommandDialogsPanel and type(RadioCommandDialogsPanel.isVisible) == "function" then
			local ok, vis = pcall(RadioCommandDialogsPanel.isVisible)
			if ok and vis == true then
				if RadioCommandDialogsPanel.window and RadioCommandDialogsPanel.window.getVisible then
					local okW, wVis = pcall(function() return RadioCommandDialogsPanel.window:getVisible() end)
					if okW and wVis == false then
						return "0"
					end
				end
				local bottomY = 252
				pcall(function()
					local winY = 14
					local contY = 25
					if RadioCommandDialogsPanel.window and RadioCommandDialogsPanel.window.getBounds then
						local _, wy = RadioCommandDialogsPanel.window:getBounds()
						if wy then winY = wy end
					end
					if RadioCommandDialogsPanel.container and RadioCommandDialogsPanel.container.getBounds then
						local _, cy = RadioCommandDialogsPanel.container:getBounds()
						if cy then contY = cy end
					end
					local el = RadioCommandDialogsPanel.curDialogIt and RadioCommandDialogsPanel.curDialogIt.element_
					if el and el.commandMenu then
						local listY = 25
						if el.commandMenu.getContainer then
							local lc = el.commandMenu:getContainer()
							if lc and lc.getBounds then
								local _, ly = lc:getBounds()
								if ly then listY = ly end
							end
						end
						local itemsH = 175
						if el.commandMenu.staticList and el.commandMenu.staticList.getItemsHeight then
							local ih = el.commandMenu.staticList:getItemsHeight()
							if ih and ih > 0 then itemsH = ih end
						end
						bottomY = winY + contY + listY + itemsH
					end
				end)
				return tostring(math.floor(bottomY))
			end
		end
		return "0"
	]]

	local function applyPngBkg(widget, filePath)
		if not widget or not widget.getSkin then return end
		local sk = widget:getSkin()
		if sk and sk.skinData and sk.skinData.states and sk.skinData.states.released and sk.skinData.states.released[1] then
			sk.skinData.states.released[1].bkg = {
				["center_center"] = "0xffffffff",
				["file"] = filePath,
			}
			widget:setSkin(sk)
		end
	end

	local function ensureCardWindow()
		if cardWin then
			return true
		end
		local ok, win = pcall(DialogLoader.spawnDialogFromFile, dlgPath, {})
		if not (ok and win) then
			hookDebugLog("ERROR", "UI-DIALOG", "Failed to load SkynetDataCard.dlg: " .. tostring(win))
			return false
		end
		cardWin = win
		sTop = cardWin.sTop
		sMid = cardWin.sMid
		sBot = cardWin.sBot
		sTextTemplate = cardWin.sText

		applyPngBkg(sTop, topPng)
		applyPngBkg(sMid, midPng)
		applyPngBkg(sBot, botPng)

		local textSkin = sTextTemplate:getSkin()
		sTextTemplate:setText("")
		sTextTemplate:setVisible(false)

		lineStatics = {}
		for i = 1, MAX_LINES do
			local st = Static.new()
			st:setSkin(textSkin)
			if st.setZIndex then
				st:setZIndex(10)
			end
			st:setText("")
			st:setVisible(false)
			st:setBounds(36, TEXT_TOP_OFFSET + (i - 1) * LINE_H, CARD_W - 68, LINE_H + 4)
			cardWin:insertWidget(st)
			table.insert(lineStatics, st)
		end

		cardWin:setBounds(-3000, -3000, CARD_W, lastTotalH)
		cardWin:setVisible(false)
		hookDebugLog("INFO", "UI-DIALOG", "SkynetDataCard HUD window (" .. MAX_LINES .. " lines) initialized.")
		return true
	end

	local function updateCardPosition(totalH)
		if not cardWin then return end
		totalH = totalH or lastTotalH
		lastTotalH = totalH
		if not isCardShowing then
			cardWin:setBounds(-3000, -3000, CARD_W, totalH)
			cardWin:setVisible(false)
			return
		end
		local main_w, main_h = Gui.GetWindowSize()
		if not main_w or main_w <= 0 then
			main_w = 1920
		end
		local x = main_w - CARD_W - MARGIN_RIGHT
		local y = currentTopY or DEFAULT_TOP_Y
		cardWin:setBounds(x, y, CARD_W, totalH)
		cardWin:setVisible(true)

		local stateKey = string.format("SHOW:%d,%d,%dx%d", x, y, CARD_W, totalH)
		if stateKey ~= lastLoggedCardState then
			lastLoggedCardState = stateKey
			hookDebugLog("INFO", "UI-POS", string.format("SkynetDataCard bounds: x=%d, y=%d, w=%d, h=%d (Screen=%dx%s)",
				x, y, CARD_W, totalH, main_w, tostring(main_h)))
		end
	end

	local function syncGuiStateAndRadioOffset()
		if not (net and type(net.dostring_in) == "function") then
			return
		end
		pcall(net.dostring_in, "gui", guiSyncCode)

		local now = os.clock()
		if (now - lastDebugFlushClock) >= 0.5 then
			lastDebugFlushClock = now
			flushMissionDebugQueues()
		end

		if (now - lastCmdSyncClock) >= 1.0 then
			lastCmdSyncClock = now
			pcall(function()
				local cmdNames = {}
				local srvId = (type(net.get_server_id) == "function" and net.get_server_id()) or 1
				local myId = (type(net.get_my_player_id) == "function" and net.get_my_player_id()) or 1
				local function addPidName(pid)
					if pid and type(net.get_player_info) == "function" then
						local okN, pName = pcall(net.get_player_info, pid, "name")
						if okN and type(pName) == "string" and pName ~= "" then
							cmdNames[pName] = true
						end
					end
				end
				addPidName(srvId)
				if not (DCS and type(DCS.isMultiplayer) == "function" and DCS.isMultiplayer()) or (DCS and type(DCS.isServer) == "function" and DCS.isServer()) then
					addPidName(myId)
				end
				if type(net.get_player_list) == "function" and type(net.get_player_info) == "function" then
					local okL, plist = pcall(net.get_player_list)
					if okL and type(plist) == "table" then
						for _, pid in ipairs(plist) do
							local okI, info = pcall(net.get_player_info, pid)
							if okI and type(info) == "table" and type(info.name) == "string" and info.name ~= "" then
								local slotStr = string.lower(tostring(info.slot or ""))
								if pid == srvId
									or string.find(slotStr, "artillery_commander", 1, true)
									or string.find(slotStr, "instructor", 1, true)
									or string.find(slotStr, "forward_observer", 1, true)
									or string.find(slotStr, "observer", 1, true) then
									cmdNames[info.name] = true
								end
							end
						end
					end
				end
				if next(cmdNames) ~= nil then
					local parts = {
						"_G.SKYNET_AUTO_COMMANDERS = _G.SKYNET_AUTO_COMMANDERS or {}"
					}
					local logNames = {}
					for k, _ in pairs(cmdNames) do
						table.insert(logNames, k)
						table.insert(parts, string.format("_G.SKYNET_AUTO_COMMANDERS[%q] = true", k))
					end
					table.sort(logNames)
					local cmdSig = table.concat(logNames, ", ")
					if cmdSig ~= lastLoggedCmdList then
						lastLoggedCmdList = cmdSig
						hookDebugLog("INFO", "COMMANDER-SYNC", "Synced Mission Commander(s): " .. cmdSig)
					end
					local syncCmdCode = table.concat(parts, "; ")
					pcall(net.dostring_in, "server", syncCmdCode)
					pcall(net.dostring_in, "mission", syncCmdCode)
					pcall(net.dostring_in, "scripting", syncCmdCode)
				end
			end)
		end

		local menuBottomY = 0
		local foundInState = nil
		for _, stName in ipairs({ "server", "main", "export", "gui" }) do
			local okR, resR = pcall(net.dostring_in, stName, radioMenuVisibleCheckCode)
			if okR and type(resR) == "string" and resR ~= "" and resR ~= "0" then
				local parsedY = tonumber(resR)
				if parsedY and parsedY > 0 then
					menuBottomY = parsedY
					foundInState = stName
					break
				end
			end
		end

		local targetY = DEFAULT_TOP_Y
		if menuBottomY > 0 then
			targetY = math.max(RADIO_OPEN_FALLBACK_Y, menuBottomY + 8)
		end

		if targetY ~= currentTopY then
			hookDebugLog("INFO", "RADIO-OFFSET", string.format("Radio menu Y-offset updated: %d -> %d (menuBottomY=%d, state=%s)",
				currentTopY, targetY, menuBottomY, tostring(foundInState or "CLOSED")))
			currentTopY = targetY
			if isCardShowing then
				updateCardPosition(lastTotalH)
			end
		end
	end

	local function hideDataCard()
		if isCardShowing or (cardWin and cardWin.getVisible and cardWin:getVisible()) then
			isCardShowing = false
			lastLoggedCardState = "HIDDEN"
			for i = 1, #lineStatics do
				lineStatics[i]:setText("")
				lineStatics[i]:setVisible(false)
			end
			if cardWin then
				cardWin:setBounds(-3000, -3000, CARD_W, lastTotalH)
				cardWin:setVisible(false)
			end
			hookDebugLog("INFO", "UI-HIDE", "SkynetDataCard hidden.")
		end
	end

	local function parseCardLines(msg)
		if type(msg) ~= "string" then
			return { tostring(msg or "") }
		end
		local lines = {}
		for line in string.gmatch(msg .. "\n", "(.-)\r?\n") do
			table.insert(lines, line)
		end
		if #lines >= 5 and string.match(lines[1], "^=+$") and string.find(lines[2], "SKYNET", 1, true) and string.match(lines[3], "^[=%-]+$") then
			local out = {}
			local endIdx = #lines
			while endIdx > 4 and (lines[endIdx] == "" or string.match(lines[endIdx], "^=+$")) do
				endIdx = endIdx - 1
			end
			for i = 4, endIdx do
				table.insert(out, lines[i])
			end
			return out
		end
		while #lines > 1 and lines[#lines] == "" do
			table.remove(lines)
		end
		return lines
	end

	local function showOnDataCard(rawText, durationSec)
		if type(rawText) ~= "string" or rawText == "" then
			return false
		end
		if rawText == "__CLOSE__" then
			hideDataCard()
			return true
		end
		if not string.find(rawText, "SKYNET", 1, true) then
			return false
		end
		if not ensureCardWindow() then
			return false
		end

		syncGuiStateAndRadioOffset()

		local lines = parseCardLines(rawText)
		local numLines = math.min(#lines, MAX_LINES)
		if numLines == 0 then
			return false
		end

		local textH = numLines * LINE_H + 4
		local totalH = TEXT_TOP_OFFSET + textH + TEXT_BOT_MARGIN
		local midH = totalH - TOP_H - BOT_H
		if midH < MID_MIN_H then
			midH = MID_MIN_H
			totalH = TOP_H + midH + BOT_H
		end

		sTop:setBounds(0, 0, CARD_W, TOP_H)
		sMid:setBounds(0, TOP_H, CARD_W, midH)
		sBot:setBounds(0, TOP_H + midH, CARD_W, BOT_H)
		sTop:setVisible(true)
		sMid:setVisible(true)
		sBot:setVisible(true)

		local padLeft = 36
		for i = 1, MAX_LINES do
			local st = lineStatics[i]
			if i <= numLines then
				st:setBounds(padLeft, TEXT_TOP_OFFSET + (i - 1) * LINE_H, CARD_W - padLeft - 32, LINE_H + 4)
				st:setText(lines[i])
				st:setVisible(true)
			else
				st:setText("")
				st:setVisible(false)
			end
		end

		isCardShowing = true
		local dur = tonumber(durationSec) or 5
		if dur > 1000 then
			dur = dur / 1000
		end
		expireClock = os.clock() + dur
		updateCardPosition(totalH)
		return true
	end

	local cb = {}
	function cb.onSimulationStart()
		hookSafeCall("onSimulationStart", function()
			currentTopY = DEFAULT_TOP_Y
			lastLoggedCardState = ""
			lastLoggedCmdList = ""
			hookDebugLog("INFO", "SIM-START", "Simulation started (onSimulationStart).")
			verifyAssetFiles()
			syncGuiStateAndRadioOffset()
			hideDataCard()
		end)
	end

	function cb.onSimulationStop()
		hookSafeCall("onSimulationStop", function()
			flushMissionDebugQueues()
			currentTopY = DEFAULT_TOP_Y
			hideDataCard()
			hookDebugLog("INFO", "SIM-STOP", "Simulation stopped (onSimulationStop).")
		end)
	end

	function cb.onTriggerMessage(message, duration, clearView)
		hookSafeCall("onTriggerMessage", function()
			syncGuiStateAndRadioOffset()
			if type(message) == "string" and message ~= "" then
				showOnDataCard(message, duration)
			end
		end)
	end

	function cb.onSimulationFrame()
		local now = os.clock()
		if (now - lastSyncClock) >= 0.08 then
			lastSyncClock = now
			hookSafeCall("onSimulationFrame", function()
				syncGuiStateAndRadioOffset()
			end)
		end
		if isCardShowing and now >= expireClock then
			hookSafeCall("onCardExpire", function()
				hideDataCard()
			end)
		end
	end

	if DCS and DCS.setUserCallbacks then
		DCS.setUserCallbacks(cb)
	end
	hookDebugLog("INFO", "HOOK-INIT", "Skynet-IADS DataCard HUD & Dedicated Debug Log Bridge Hook active.")
	verifyAssetFiles()
end
