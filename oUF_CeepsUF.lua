--textures and shizzle

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

local playerClass = string.upper(select(2, UnitClass('player')))


oUF.Tags['CeepsUF:health'] = function(unit)
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
    local percent = min * 100 / max
	local status = not UnitIsConnected(unit) and 'Offline' or UnitIsGhost(unit) and 'Ghost' or UnitIsDead(unit) and 'Dead'

	if(status) then
		return status
	elseif(unit == 'player' and min ~= max) then
		return min
	elseif(unit == 'target' and min ~= max) then
		return min
    elseif(unit == 'targettarget') then
        return ('%d%%'):format(min / max * 100)
	else
		return max
	end
end

oUF.Tags['CeepsUF:power'] = function(unit)
	local power = UnitPower(unit)
	if(power >= 0 and not UnitIsDeadOrGhost(unit)) then
		local _, type = UnitClass(unit)
		local colors = _COLORS.class
		return ('%s%d|r'):format(Hex(colors[type] or colors['RUNES']), power)
	end
end
	
local function SpawnMenu(self)
	ToggleDropDownMenu(1, nil, _G[string.gsub(self.unit, '^.', string.upper)..'FrameDropDown'], 'cursor')
end
--units

local function PostCreateAura(element, button)
	button:SetBackdrop(BACKDROP)
	button:SetBackdropColor(0, 0, 0)
	button.cd:SetReverse()
	button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	button.icon:SetDrawLayer('ARTWORK')
end

local UnitSpecific = 
{
	player = function(self)
        self:SetAttribute('initial-width', 254)   
        
    end,
    
    target = function(self)
        self:SetAttribute('initial-width', 254)
        
        local Buffs = CreateFrame("Frame", nil, self)
	    Buffs:SetPoint('BOTTOM', self, 'TOP')
	    Buffs:SetPoint'LEFT'
	    Buffs:SetPoint'RIGHT'
	    Buffs:SetHeight(21)
        Buffs.PostCreateIcon = PostCreateAura
        Buffs.showBuffType = true

	    Buffs.size = 21
	    Buffs.num = math.floor(self:GetAttribute'initial-width' / Buffs.size + .5)

	    self.Buffs = Buffs
        
        local Debuffs = CreateFrame("Frame", nil, self)
	    Debuffs:SetPoint("BOTTOM", self, "TOP", 0, 21)
	    Debuffs:SetPoint'LEFT'
	    Debuffs:SetPoint'RIGHT'
	    Debuffs:SetHeight(21)
        Debuffs.PostCreateIcon = PostCreateAura

	    Debuffs.initialAnchor = "TOPLEFT"
	    Debuffs.size = 21
	    Debuffs.showDebuffType = true
	    Debuffs.num = math.floor(self:GetAttribute'initial-width' / Debuffs.size + .5)

	    self.Debuffs = Debuffs
    end,
    
    targettarget = function(self)
    
        self:SetAttribute('initial-width', 160)
    end,
       
    party = function(self)
        
        self:SetAttribute('initial-width', 100)
    end
    
}

--main code
local function Shared(self, unit)

	self:RegisterForClicks('AnyUp')
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)

	self:SetBackdrop(BACKDROP)
	self:SetBackdropColor(0, 0, 0)    

    --health bar

	local health = CreateFrame('StatusBar', nil, self)
    health:SetStatusBarTexture(TEXTURE)
	health:SetStatusBarColor(1/7, 1/7, 1/7)
    health:SetFrameStrata("MEDIUM")
	health.frequentUpdates = true
	self.Health = health
    
    local healthBG = health:CreateTexture(nil, 'BORDER')
	healthBG:SetAllPoints()
    healthBG:SetTexture(TEXTURE)
	healthBG:SetTexture(1/3, 1/3, 1/3)
    
    local healthValue = health:CreateFontString(nil, 'OVERLAY')
	healthValue:SetFont(FONT, 26, 'OUTLINE')
    healthValue:SetTextColor(1, 1, 1)
	healthValue.frequentUpdates = 0.1
	self:Tag(healthValue, '[CeepsUF:health]')
    
    local powerValue = health:CreateFontString(nil, 'OVERLAY')
	powerValue:SetFont(FONT, 24, 'OUTLINE')
	powerValue.frequentUpdates = 0.1
	self:Tag(powerValue, '[CeepsUF:power]') 
    
    --player frame

	if(unit == 'player' or unit == 'target') then
		local power = CreateFrame('StatusBar', nil, self)
		power:SetPoint('BOTTOMRIGHT')
		power:SetPoint('BOTTOMLEFT')
		power:SetPoint('TOP', health, 'BOTTOM', 0, -1)
        power:SetStatusBarTexture(TEXTURE)
		power.frequentUpdates = true
		self.Power = power

		power.colorClass = true
		power.colorTapping = true
		power.colorDisconnected = true
		
		if(unit == 'target' and not UnitIsPlayer(unit)) then
			power.colorReaction = true
		end
        
        local powerbg = power:CreateTexture(nil, 'BORDER')
		powerbg:SetAllPoints()
		powerbg:SetTexture(TEXTURE)
		powerbg.multiplier = 1/3
		power.bg = powerbg

		health:SetHeight(38)
		health:SetPoint('TOPRIGHT')
		health:SetPoint('TOPLEFT')
        
        healthValue:SetPoint('LEFT', health, -2, -45)
        healthValue:SetJustifyH('RIGHT')
        powerValue:SetPoint('LEFT', health, -2, -73)
        powerValue:SetJustifyH('LEFT')
        
        --name
        
        local Name = health:CreateFontString(nil, "OVERLAY")
	    Name:SetPoint("LEFT", -302, -1)
	    Name:SetPoint("RIGHT", -265, -1)
	    Name:SetJustifyH("RIGHT")
	    Name:SetFont(FONT, 26, 'OUTLINE')
        Name:SetTextColor(1, 1, 1) --TODO change the colour so that it matches the class colour
        
        self:Tag(Name, '[name]')
	    self.Name = Name
        
        if (unit == 'target') then
            healthValue:SetPoint('RIGHT', health, -2, -45)
            powerValue:SetPoint('RIGHT', health, -2, -73)
            powerValue:SetJustifyH('RIGHT')
            Name:SetJustifyH("LEFT")
            Name:SetPoint("LEFT", 265, -1)
            Name:SetPoint("RIGHT", 302, -1)
        end
        
        if IsAddOnLoaded("oUF_CombatFeedback") then
        
        	local combatfeedback = health:CreateFontString(nil, "OVERLAY")
	        combatfeedback:SetPoint("CENTER", health, "CENTER")
	        combatfeedback:SetFontObject(GameFontNormal)
	        self.CombatFeedbackText = combatfeedback
        end
                
        --menu

		self.menu = SpawnMenu
		self:SetAttribute('type2', 'menu')
		self:SetAttribute('initial-height', 50)

    elseif (unit == 'party') then
    
		local power = CreateFrame('StatusBar', nil, self)
		power:SetPoint('BOTTOMRIGHT')
		power:SetPoint('BOTTOMLEFT')
		power:SetPoint('TOP', health, 'BOTTOM', 0, -1)
        power:SetStatusBarTexture(TEXTURE)
		power.frequentUpdates = true
		self.Power = power

		power.colorClass = true
		power.colorDisconnected = true
        
        local powerbg = power:CreateTexture(nil, 'BORDER')
		powerbg:SetAllPoints()
		powerbg:SetTexture(TEXTURE)
		powerbg.multiplier = 1/3
		power.bg = powerbg

		health:SetHeight(20)
		health:SetPoint('TOPRIGHT')
		health:SetPoint('TOPLEFT')

		self:SetAttribute('initial-height', 30)
        
        local Name = health:CreateFontString(nil, "OVERLAY")
	    Name:SetPoint("LEFT", 0, -1)
	    Name:SetPoint("RIGHT", 0, -1)
	    Name:SetJustifyH("LEFT")
	    Name:SetFont(FONT, 10, 'OUTLINE')
        Name:SetTextColor(1, 1, 1) --TODO change the colour so that it matches the class colour
        
        self:Tag(Name, '[name]')
	    self.Name = Name
        
    elseif (unit == 'targettarget') then

		health:SetHeight(30)
		health:SetPoint('TOPRIGHT')
		health:SetPoint('TOPLEFT')
        health.colorClass = true

		self:SetAttribute('initial-height', 30)
        
        local healthValue = health:CreateFontString(nil, 'OVERLAY')
	    healthValue:SetFont(FONT, 14, 'OUTLINE')
        healthValue:SetTextColor(1, 1, 1)
	    healthValue.frequentUpdates = 0.1
        healthValue:SetPoint('RIGHT', health, 50, 0)
        healthValue:SetJustifyH('RIGHT')

	    self:Tag(healthValue, '[CeepsUF:health]')        
        
        local Name = health:CreateFontString(nil, "OVERLAY")
	    Name:SetPoint("LEFT", 0, -1)
	    Name:SetPoint("RIGHT", 0, -1)
	    Name:SetJustifyH("LEFT")
	    Name:SetFont(FONT, 14, 'THINOUTLINE')
        Name:SetTextColor(1, 1, 1) --TODO change the colour so that it matches the class colour
        
        self:Tag(Name, '[name]')
	    self.Name = Name


	end
    
    if (unit == 'player' or unit == 'target' or unit == 'party' or unit == 'targettarget') then
    
    self.FrameBackdrop = CreateFrame("Frame", nil, self)
	self.FrameBackdrop:SetPoint("TOPLEFT", self, -5, 4)
    self.FrameBackdrop:SetPoint("BOTTOMRIGHT", self, 5, -4)
	self.FrameBackdrop:SetBackdrop(BACKDROPBORDER)
    self.FrameBackdrop:SetFrameStrata("BACKGROUND")
	self.FrameBackdrop:SetBackdropColor(0, 0, 0, 0)
	self.FrameBackdrop:SetBackdropBorderColor(0, 0, 0, 0.3)
    
    if (unit == 'player' and playerClass == 'SHAMAN') then
    self.FrameBackdrop:SetPoint("TOPLEFT", self, -5, 15)
    end
	
    end

	--SHAMAN--
    
    if IsAddOnLoaded("oUF_TotemBar") and unit == "player"  and playerClass == "SHAMAN" then
	self.TotemBar = {}
	for i = 1, 4 do
		self.TotemBar[i] = CreateFrame("StatusBar", nil, self)
		self.TotemBar[i]:SetHeight(9)
		self.TotemBar[i]:SetWidth(254/4)
		if (i == 1) then
			self.TotemBar[i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 1)
		else
			self.TotemBar[i]:SetPoint("BOTTOMLEFT", self.TotemBar[i-1], "BOTTOMRIGHT", 0, 0)
		end
		self.TotemBar[i]:SetStatusBarTexture(TEXTURE)
		self.TotemBar[i]:SetBackdrop(BACKDROP)
		self.TotemBar[i]:SetBackdropColor(0, 0, 0)
		self.TotemBar[i]:SetMinMaxValues(0, 1)
						
		self.TotemBar[i].bg = self.TotemBar[i]:CreateTexture(nil, "BORDER")
		self.TotemBar[i].bg:SetAllPoints(self.TotemBar[i])
		self.TotemBar[i].bg:SetTexture(TEXTURE)
		self.TotemBar[i].bg.multiplier = 0.25

	    end
    end     

	--DEATH KNIGHT--

	if(unit == 'player' and playerClass == "DEATHKNIGHT") then
		self.Runes = CreateFrame("Frame", nil, self)
		self.Runes:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -1, 1)
		self.Runes:SetHeight(9)
		self.Runes:SetWidth(254)
		self.Runes:SetBackdrop(BACKDROP)
		self.Runes:SetBackdropColor(0, 0, 0)

		for i = 1, 6 do
			self.Runes[i] = CreateFrame("StatusBar", self:GetName().."_Runes"..i, self)
			self.Runes[i]:SetSize(((254 - 5) / 6), 9)
			if (i == 1) then
				self.Runes[i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 1)
			else
				self.Runes[i]:SetPoint("LEFT", self.Runes[i-1], "RIGHT", 1, 0)
			end
			self.Runes[i]:SetStatusBarTexture(TEXTURE)

			self.Runes[i].bd = self.Runes[i]:CreateTexture(nil, "BORDER")
			self.Runes[i].bd:SetAllPoints()
			self.Runes[i].bd:SetTexture(TEXTURE)
			self.Runes[i].bd:SetVertexColor(0.15, 0.15, 0.15)
		end
	end
    
        if(UnitSpecific[unit]) then
		return UnitSpecific[unit](self)
	end
end

oUF:RegisterStyle('CeepsUF', Shared)
oUF:Factory(function(self)
	self:SetActiveStyle('CeepsUF')
	self:Spawn('player'):SetPoint('CENTER', -170, -280)
    self:Spawn('target'):SetPoint('CENTER', 170, -280)
    self:Spawn('targettarget'):SetPoint('CENTER', 300, -195)
    
    local party = self:SpawnHeader(nil, nil, 'party',
		'showParty', true,
		'yOffset', -20,
		'xOffset', -20,
		'maxColumns', 1,
		'unitsPerColumn', 4,
		'columnAnchorPoint', 'LEFT',
		'columnSpacing', 0
	)
    party:SetPoint('TOPLEFT', 20, -350)

    
end)

CompactRaidFrameManager:UnregisterAllEvents()
CompactRaidFrameManager:Hide() 
CompactRaidFrameContainer:UnregisterAllEvents() 
CompactRaidFrameContainer:Hide() 