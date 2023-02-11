-- A ticker to keep checking for the start time in player login
local loginChecker

-- Create the saved variables table
if not SessionPlayedTimerDB then
	SessionPlayedTimerDB = {}
end

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
		GameTooltip:AddLine("Session Played Timer")
		GameTooltip:AddLine("Displays the amount of time you have played during this session.")
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
					local minutes = math.floor(elapsedTime / 60)
					local seconds = math.floor(elapsedTime - minutes * 60)

					-- Set the text to display the timer
					timeLabel:SetText(string.format("%02d:%02d", minutes, seconds))
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
