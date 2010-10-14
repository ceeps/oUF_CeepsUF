local FONT = [=[Interface\AddOns\oUF_CeepsUF\media\neuropol.ttf]=]
local TEXTURE = [=[Interface\ChatFrame\ChatFrameBackground]=]
local STATUSTEXTURE = [=[Interface\AddOns\oUF_CeepsUF\media\Otravi]=]
local BACKDROP = 
{
	bgFile = TEXTURE, insets = {top = -1, bottom = -1, left = -1, right = -1}
}
local BACKDROPBORDER = 
{
    bgFile = TEXTURE, insets = {top = -1, bottom = -1, left = -1, right = -1},
    edgeFile = TEXTURE
}

local UnitSpecific =
{
    player = function(self)
        self:SetAttribute('initial-width', 370)
        self:SetAttribute('initial-height', 25)
    end,
    
    target = function(self)
        self:SetAttribute('initial-width', 370)
        self:SetAttribute('initial-height', 25)
    end
}

local PostCastStart = function(Castbar, unit, name, rank, text, castid)
	Castbar.channeling = false
	if unit == "vehicle" then unit = "player" end

	if unit == "player" then
		local latency = GetTime() - Castbar.castSent
		latency = latency > Castbar.max and Castbar.max or latency
		Castbar.Latency:SetText(("%dms"):format(latency * 1e3))
		Castbar.SafeZone:SetWidth(Castbar:GetWidth() * latency / Castbar.max)
		Castbar.SafeZone:ClearAllPoints()
		Castbar.SafeZone:SetPoint("TOPRIGHT")
		Castbar.SafeZone:SetPoint("BOTTOMRIGHT")
	end
end

local PostChannelStart = function(Castbar, unit, name, rank, text)
	Castbar.channeling = true
	if unit == "vehicle" then unit = "player" end

	if unit == "player" then
		local latency = GetTime() - Castbar.castSent
		latency = latency > Castbar.max and Castbar.max or latency
		Castbar.Latency:SetText(("%dms"):format(latency * 1e3))
		Castbar.SafeZone:SetWidth(Castbar:GetWidth() * latency / Castbar.max)
		Castbar.SafeZone:ClearAllPoints()
		Castbar.SafeZone:SetPoint("TOPLEFT")
		Castbar.SafeZone:SetPoint("BOTTOMLEFT")
	end

end

local CustomCastTimeText = function(self, duration)
	self.Time:SetText(("%.1f / %.1f"):format(self.channeling and duration or self.max - duration, self.max))
end

local CustomCastDelayText = function(self, duration)
	self.Time:SetText(("%.1f |cffaf5050%s %.1f|r"):format(self.channeling and duration or self.max - duration, self.channeling and "- " or "+", self.delay))
end

local FormatTime = function(s)
	local day, hour, minute = 86400, 3600, 60
	if s >= day then
		return format("%dd", floor(s/day + 0.5)), s % day
	elseif s >= hour then
		return format("%dh", floor(s/hour + 0.5)), s % hour
	elseif s >= minute then
		if s <= minute * 5 then
			return format("%d:%02d", floor(s/60), s % minute), s - floor(s)
		end
		return format("%dm", floor(s/minute + 0.5)), s % minute
	elseif s >= minute / 12 then
		return floor(s + 0.5), (s * 100 - floor(s * 100))/100
	end
	return format("%.1f", s), (s * 100 - floor(s * 100))/100
end

local function Shared(self, unit)

    if (unit == 'player' or unit == 'target') then

        self:RegisterForClicks('AnyUp')
	    self:SetScript('OnEnter', UnitFrame_OnEnter)
	    self:SetScript('OnLeave', UnitFrame_OnLeave)
        
        self.FrameBackdrop = CreateFrame("Frame", nil, self)
	    self.FrameBackdrop:SetPoint("TOPLEFT", self, -30, 8)
        self.FrameBackdrop:SetPoint("BOTTOMRIGHT", self, 5, -8)
	    self.FrameBackdrop:SetFrameStrata("BACKGROUND")
	    self.FrameBackdrop:SetBackdrop(BACKDROPBORDER)
	    self.FrameBackdrop:SetBackdropColor(0, 0, 0, 0)
	    self.FrameBackdrop:SetBackdropBorderColor(0, 0, 0, 0.3)

        
        local castbar = CreateFrame("StatusBar", nil, self)
	    castbar:SetStatusBarTexture(TEXTURE)
	    castbar:SetStatusBarColor(1/7, 1/7, 1/7)
	    castbar:SetAllPoints()
	    castbar:SetToplevel(true)
        castbar:SetFrameStrata("HIGH")
        self.Castbar = castbar
        
        castbar.PostCastStart = PostCastStart
		castbar.PostChannelStart = PostChannelStart
        
        local castbarBG = castbar:CreateTexture(nil, 'BORDER')
	    castbarBG:SetAllPoints()
        castbarBG:SetTexture(TEXTURE)
	    castbarBG:SetTexture(1/3, 1/3, 1/3)
        
        castbar.Icon = castbar:CreateTexture(nil, "ARTWORK")
        castbar.Icon:SetSize(25, 25)
		castbar.Icon:SetTexCoord(0, 1, 0, 1)
		if unit == "player" then
			castbar.Icon:SetPoint("LEFT", -25, 0)
		elseif unit == "target" then
			castbar.Icon:SetPoint("LEFT", -25, 0)
		end
        
        self.IconBackdrop = CreateFrame("Frame", nil, castbar)
		self.IconBackdrop:SetPoint("TOPLEFT", castbar.Icon, -1, 1)
		self.IconBackdrop:SetPoint("BOTTOMRIGHT", castbar.Icon, 1, -1)
		self.IconBackdrop:SetBackdrop(BACKDROP)
		self.IconBackdrop:SetBackdropColor(0, 0, 0, 0)
		self.IconBackdrop:SetBackdropBorderColor(0, 0, 0, 0.7)
        
        castbar.Time = castbar:CreateFontString(nil, "OVERLAY")
        castbar.Time:SetFont(FONT, 10, "OUTLINE")
		castbar.Time:SetPoint("RIGHT", -1, 1)
		castbar.Time:SetTextColor(1, 1, 1)
		castbar.Time:SetJustifyH("LEFT")
		castbar.CustomTimeText = CustomCastTimeText
		castbar.CustomDelayText = CustomCastDelayText
        
        castbar.Text = castbar:CreateFontString(nil, "OVERLAY")
        castbar.Text:SetFont(FONT, 12, "OUTLINE")
		castbar.Text:SetPoint("LEFT", 1, 1)
		castbar.Text:SetTextColor(1, 1, 1)

		castbar:HookScript("OnShow", function() castbar.Text:Show(); castbar.Time:Show(); self.FrameBackdrop:Show() end)
		castbar:HookScript("OnHide", function() castbar.Text:Hide(); castbar.Time:Hide(); self.FrameBackdrop:Hide() end)

        
        if unit == "player" then
			castbar.SafeZone = castbar:CreateTexture(nil, "ARTWORK")
			castbar.SafeZone:SetTexture(TEXTURE)
			castbar.SafeZone:SetVertexColor(0.69, 0.31, 0.31, 0.75)

			castbar.Latency = castbar:CreateFontString(nil, "OVERLAY")
			castbar.Latency:SetFont(FONT, 9, "OUTLINE")
			castbar.Latency:SetTextColor(1, 1, 1)
			castbar.Latency:SetPoint("BOTTOMLEFT", castbar.SafeZone, "BOTTOMRIGHT")
			
			self:RegisterEvent("UNIT_SPELLCAST_SENT", function(self, event, caster)
				if caster == "player" or caster == "vehicle" then
					castbar.castSent = GetTime()
				end
			end)
		end
   
    end
    
    if(UnitSpecific[unit]) then
		return UnitSpecific[unit](self)
	end
    
end

oUF:RegisterStyle('castbar', Shared)
oUF:Factory(function(self)
	self:SetActiveStyle('castbar')
	self:Spawn('player'):SetPoint('CENTER', 11, -410)
    self:Spawn('target'):SetPoint('CENTER', 11, -375)

end)
    