--[[

	Stats

	Author:		Fleetfoot
	Mail:		blomma@gmail.com

	Credits:	lynstats
	
	This is a recode of lynstats to my liking.

--]]
local addon = CreateFrame("Button", "LynStats", UIParent)

local print = function(a) ChatFrame1:AddMessage("|cff33ff99Stats:|r "..tostring(a)) end

local classcolors = true
local color, time, lag, fps, xp, text, addonmem, totalmem, memory, entry, mem
local playerLevel = UnitLevel("player")
local addoncount = 50
local update, slowupdate = 1,60
local addons= {}
local GetFramerate = GetFramerate
local GetNetStats = GetNetStats

if classcolors == true then
	color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
else
	color = { r=0, g=0.8, b=1 }
end

local OnEvent = function(self, event, level)
	if event == "PLAYER_LEVEL_UP" then
		playerLevel = level
	elseif event == "PLAYER_XP_UPDATE" then
		CalculateXp()
	end
end

local CalculateXp = function()
	xp = "|c00ffffff"..floor(UnitXPMax("player") - UnitXP("player")).."|r"
	if GetXPExhaustion("player") ~= nil then	
		xp = xp.."|c00ffffff(|r|c0000ccffR|r|c00ffffff)|rxp  "
	else
		xp = xp.."xp  "
	end		
end

local OnUpdate = function(self, elapsed)
	update = update + elapsed
	slowupdate = slowupdate + elapsed
	if slowupdate > 60 then
		mem = "|c00ffffff"..floor(collectgarbage("count") / 1024).."|rmb  "
		slowupdate = 0
	end
	if update > 1 then
		time = "|c00ffffff"..date("%H.%M").."|r"
		fps = "|c00ffffff"..floor(GetFramerate()).."|rfps  "
		lag = "|c00ffffff"..select(3, GetNetStats()).."|rms  "

		if playerLevel < MAX_PLAYER_LEVEL then
			text:SetText(fps..lag..mem..xp..time)
		else
			text:SetText(fps..lag..mem..time)
		end
		
		local width = text:GetStringWidth()/addon:GetEffectiveScale()
		local height = text:GetStringHeight()/addon:GetEffectiveScale()
		addon:SetWidth(width)
		addon:SetHeight(height)

		update = 0
	end
end

local addoncompare = function(a, b)
	return a.memory > b.memory
end

local memformat = function(number)
	if number > 1000 then
		return string.format("%.2f mb", (number / 1000))
	else
		return string.format("%.1f kb", floor(number))
	end
end

local OnEnter = function(self)
	GameTooltip:SetOwner(addon, "ANCHOR_NONE")
	GameTooltip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -90, 35)
	totalmem = collectgarbage("count")
	addonmem = 0
	UpdateAddOnMemoryUsage()
	addoncount = GetNumAddOns() < 50 and GetNumAddOns() or 50
	for i=1, addoncount, 1 do
		local name,_,_,enabled = GetAddOnInfo(i)
		if enabled == 1 then
			memory = GetAddOnMemoryUsage(i)
			entry = {name = name, memory = memory}
			table.insert(addons, entry)
			addonmem = addonmem + memory
		end
	end
	table.sort(addons, addoncompare)
	GameTooltip:AddLine("---------------------------------------")
	GameTooltip:AddDoubleLine("Total", memformat(addonmem), color.r, color.g, color.b, color.r, color.g, color.b)
	GameTooltip:AddDoubleLine("Total incl. Blizzard", memformat(totalmem), color.r, color.g, color.b, color.r, color.g, color.b)
	GameTooltip:AddLine("---------------------------------------")
	for _, entry in pairs(addons) do
		GameTooltip:AddDoubleLine(entry.name, memformat(entry.memory), 1, 1, 1, 1, 1, 1)
	end
	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
	for k in pairs(addons) do 
		addons[k] = nil 
	end 
end

local OnClick = function(self, button)
	if button == "LeftButton" then
		if IsShiftKeyDown() then
			ToggleCalendar()
		else
			ToggleTimeManager()
		end
	end
end


text = addon:CreateFontString(nil, "OVERLAY")
text:SetFont("Fonts\\ARIALN.TTF", 12, nil)
text:SetShadowOffset(1,-1)
text:SetTextColor(color.r, color.g, color.b)
text:SetPoint("BOTTOMRIGHT", addon)

addon:SetWidth(50)
addon:SetHeight(13)

addon:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -10, 10)

addon:SetScript("OnUpdate", OnUpdate)
addon:SetScript("OnEnter", OnEnter)
addon:SetScript("OnLeave", OnLeave)
addon:SetScript("OnClick", OnClick)

addon:RegisterEvent("PLAYER_LEVEL_UP")
if playerLevel < MAX_PLAYER_LEVEL then
	addon:RegisterEvent("PLAYER_XP_UPDATE")
	CalculateXp()
end
