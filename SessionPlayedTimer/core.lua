-- A ticker to keep checking for the start time in player login
local loginChecker

-- Create the saved variables table
if not SessionPlayedTimerDB then
	SessionPlayedTimerDB = {
		elapsedTime = 0,
	}
end

-- Create a lookup table to store the translations
local LocaleTable = {
	-- Translations for the stranger
	["SessionPlayedTimerTitle_deDE"] = "Session gespielt Timer",
	["SessionPlayedTimerTitle_esES"] = "Session Jugado Timer",
	["SessionPlayedTimerTitle_esMX"] = "Session Jugado Timer",
	["SessionPlayedTimerTitle_frFR"] = "Session jouée Timer",
	["SessionPlayedTimerTitle_itIT"] = "Session Giocato Timer",
	["SessionPlayedTimerTitle_koKR"] = "세션 재생 타이머",
	["SessionPlayedTimerTitle_ptBR"] = "Session Jogada Timer",
	["SessionPlayedTimerTitle_ruRU"] = "Сессия воспроизведена Timer",
	["SessionPlayedTimerTitle_zhCN"] = "会话播放计时器",
	["SessionPlayedTimerTitle_zhTW"] = "會話播放計時器",
	-- Translations for the desc of the addon
	["SessionPlayedTimerInfo_deDE"] = "Anzeige der Zeit, die Sie in dieser Sitzung gespielt haben.",
	["SessionPlayedTimerInfo_esES"] = "Muestra la cantidad de tiempo que has jugado durante esta sesión.",
	["SessionPlayedTimerInfo_esMX"] = "Muestra la cantidad de tiempo que has jugado durante esta sesión.",
	["SessionPlayedTimerInfo_frFR"] = "Affiche le temps que vous avez joué pendant cette session.",
	["SessionPlayedTimerInfo_itIT"] = "Visualizza la quantità di tempo che hai giocato durante questa sessione.",
	["SessionPlayedTimerInfo_koKR"] = "이 세션에서 플레이한 시간을 표시합니다.",
	["SessionPlayedTimerInfo_ptBR"] = "Exibe a quantidade de tempo que você jogou durante esta sessão.",
	["SessionPlayedTimerInfo_ruRU"] = "Отображает количество времени, которое вы провели в этой сессии.",
	["SessionPlayedTimerInfo_zhCN"] = "显示您在此会话中游戏的时间量。",
	["SessionPlayedTimerInfo_zhTW"] = "顯示您在此會話中遊戲的時間量。",
}

-- Retrieve the current locale and store the translation in `ThanksText`
-- If the locale is not found in the `LocaleTable`, the default value of "Stranger" is used
local SessionPlayerTimeTitle = LocaleTable["SessionPlayedTimerTitle_" .. GetLocale()] or "Session Played Timer"

-- Retrieve the translation for the `TradeTargetInfo` text, using the current locale
local SessionPlayerTimeInfo = LocaleTable["SessionPlayedTimerInfo_" .. GetLocale()] or "Displays the amount of time you have played during this session."

-- Create a frame to display the timer
local timerFrame = CreateFrame("Frame", "TimerFrame", UIParent)
timerFrame:SetSize(80, 26)
timerFrame:SetPoint("CENTER", UIParent, "CENTER")
timerFrame:RegisterEvent("PLAYER_LOGIN")
timerFrame:RegisterEvent("PLAYER_LOGOUT")

-- Add a background texture to the frame
local texture = timerFrame:CreateTexture(nil, "BACKGROUND")
texture:SetAllPoints(timerFrame)
texture:SetColorTexture(0, 0, 0, 0.5)

-- Add a label to display the time
local timeLabel = timerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium")
timeLabel:SetPoint("CENTER", timerFrame, "CENTER")
timeLabel:SetText("Timer 00:00")

-- Create a texture to display the class icon
local classTexture = timerFrame:CreateTexture(nil, "OVERLAY")
classTexture:SetSize(26, 26)
classTexture:SetPoint("RIGHT", texture, "LEFT", -2, 0)
-- Set the texture to display the icon
classTexture:SetTexture([[Interface\ICONS\INV_Misc_PocketWatch_01]])
classTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92)

-- Add a tooltip to the timer display
timerFrame:SetScript("OnEnter", function(self)
	if not GameTooltip:IsForbidden() then
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:AddLine(SessionPlayerTimeTitle)
		GameTooltip:AddLine(SessionPlayerTimeInfo)
		GameTooltip:Show()
	end
end)

-- Hide tooltip for timer display
timerFrame:SetScript("OnLeave", function()
	if not GameTooltip:IsForbidden() then
		GameTooltip:Hide()
	end
end)

-- Handle the PLAYER_LOGIN and PLAYER_LOGOUT events
timerFrame:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		-- Check if the elapsed time is stored in the saved variables
		if SessionPlayedTimerDB.elapsedTime then
			self.startTime = GetTime() - SessionPlayedTimerDB.elapsedTime
		else
			self.startTime = GetTime()
			SessionPlayedTimerDB.elapsedTime = 0
		end

		-- Start the login checker
		loginChecker = C_Timer.NewTicker(0.1, function()
			if self.startTime then
				-- Stop the timer once startTime is found
				loginChecker:Cancel()

				-- Start the timer update
				timerFrame:SetScript("OnUpdate", function(self)
					local currentTime = GetTime()
					local elapsedTime = currentTime - self.startTime
					SessionPlayedTimerDB.elapsedTime = elapsedTime
					local hours = math.floor(elapsedTime / 3600)
					local minutes = math.floor((elapsedTime - hours * 3600) / 60)
					local seconds = math.floor(elapsedTime - hours * 3600 - minutes * 60)

					-- Set the text to display the timer
					if hours > 0 then
						timeLabel:SetText(string.format("%dh %02dm %02ds", hours, minutes, seconds))
					else
						timeLabel:SetText(string.format("%02dm %02ds", minutes, seconds))
					end
				end)
			end
		end)
	elseif event == "PLAYER_LOGOUT" then
		-- Stop the timer update
		timerFrame:SetScript("OnUpdate", nil)
		self.startTime = nil
	end
end)

-- Make the timer frame moveable
timerFrame:SetMovable(true)
timerFrame:EnableMouse(true)
timerFrame:SetClampedToScreen(true)
timerFrame:RegisterForDrag("LeftButton")
timerFrame:SetScript("OnDragStart", timerFrame.StartMoving)
timerFrame:SetScript("OnDragStop", timerFrame.StopMovingOrSizing)

-- Add a chat command to show and hide the timer display
SLASH_SESSIONPLAYEDTIMER1 = "/sptimer"
SlashCmdList["SESSIONPLAYEDTIMER"] = function()
	if timerFrame:IsShown() then
		timerFrame:Hide()
	else
		timerFrame:Show()
	end
end
