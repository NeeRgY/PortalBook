MageTeleportsFrame = nil

local L = {}
local locale = GetLocale()

if locale == "deDE" then
    L["TITLE"] = "Portal Book"
    L["TELEPORTS"] = "Teleports"
    L["PORTALS"] = "Portale"
    L["TOOLTIP_TITLE"] = "Portal Book"
    L["TOOLTIP_CLICK"] = "Linksklick: Fenster öffnen/schließen"
    L["TOOLTIP_RIGHTCLICK"] = "Rechtsklick + Ziehen: Icon verschieben"
    L["STORMWIND"] = "Sturmwind"
    L["IRONFORGE"] = "Eisenschmiede"
    L["DARNASSUS"] = "Darnassus"
    L["EXODAR"] = "Exodar"
    L["THERAMORE"] = "Theramore"
    L["SHATTRATH"] = "Shattrath"
    L["ORGRIMMAR"] = "Orgrimmar"
    L["UNDERCITY"] = "Unterstadt"
    L["THUNDERBLUFF"] = "Donnerfels"
    L["SILVERMOON"] = "Silbermond"
    L["STONARD"] = "Steinard"
    L["NOT_LEARNED"] = "Noch nicht gelernt"
    L["REQUIRED_LEVEL"] = "Ab Level %d"
    L["LOCKED"] = "Gesperrt"
    L["UNLOCKED"] = "Entsperrt - Verschiebbar"
    L["RUNE_OF_TELEPORTATION"] = "Runen der Teleportation: %d"
    L["RUNE_OF_PORTALS"] = "Runen der Portale: %d"
    L["SETTINGS"] = "Einstellungen"
    L["SHOW_COUNTER"] = "Counter anzeigen"
    L["RESET_COUNTER"] = "Reset"
    L["RESET_COUNTER_TOOLTIP"] = "Alle Counter zurücksetzen"
    L["TRANSPARENCY"] = "Transparenz"
    L["SHOW_ONLY_LEARNED"] = "Nur gelernte anzeigen"
    L["AUTO_CLOSE"] = "Automatisch schließen"
else 
    L["TITLE"] = "Portal Book"
    L["TELEPORTS"] = "Teleports"
    L["PORTALS"] = "Portals"
    L["TOOLTIP_TITLE"] = "Portal Book"
    L["TOOLTIP_CLICK"] = "Left-click: Open/Close Window"
    L["TOOLTIP_RIGHTCLICK"] = "Right-click + Drag: Move Icon"
    L["STORMWIND"] = "Stormwind"
    L["IRONFORGE"] = "Ironforge"
    L["DARNASSUS"] = "Darnassus"
    L["EXODAR"] = "Exodar"
    L["THERAMORE"] = "Theramore"
    L["SHATTRATH"] = "Shattrath"
    L["ORGRIMMAR"] = "Orgrimmar"
    L["UNDERCITY"] = "Undercity"
    L["THUNDERBLUFF"] = "Thunder Bluff"
    L["SILVERMOON"] = "Silvermoon"
    L["STONARD"] = "Stonard"
    L["NOT_LEARNED"] = "Not learned yet"
    L["REQUIRED_LEVEL"] = "Requires Level %d"
    L["LOCKED"] = "Locked"
    L["UNLOCKED"] = "Unlocked - Movable"
    L["RUNE_OF_TELEPORTATION"] = "Runes of Teleportation: %d"
    L["RUNE_OF_PORTALS"] = "Runes of Portals: %d"
    L["SETTINGS"] = "Options"
    L["SHOW_COUNTER"] = "Show Counter"
    L["RESET_COUNTER"] = "Reset"
    L["RESET_COUNTER_TOOLTIP"] = "Reset all counters"
    L["TRANSPARENCY"] = "Transparency"
    L["SHOW_ONLY_LEARNED"] = "Show only learned"
    L["AUTO_CLOSE"] = "Auto close on cast"
end

SLASH_PORTALBOOK1 = "/portalb"
SlashCmdList["PORTALBOOK"] = function(msg)
    if MageTeleportsFrame then
        if MageTeleportsFrame:IsShown() then
            MageTeleportsFrame:Hide()
        else
            MageTeleportsFrame:Show()
        end
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGOUT")

eventFrame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "PortalBook" then
        if not MageTeleportsDB then
            MageTeleportsDB = {}
        end
        
        -- Statistik initialisieren
        if not MageTeleportsDB.stats then
            MageTeleportsDB.stats = {}
        end
        
        -- Counter-Einstellung initialisieren (Standard: aktiviert)
        if MageTeleportsDB.showCounter == nil then
            MageTeleportsDB.showCounter = true
        end
        
        -- Transparenz initialisieren (Standard: 0.95)
        if MageTeleportsDB.transparency == nil then
            MageTeleportsDB.transparency = 0.95
        end
        
        -- Nur gelernte anzeigen initialisieren (Standard: deaktiviert)
        if MageTeleportsDB.showOnlyLearned == nil then
            MageTeleportsDB.showOnlyLearned = false
        end
        
        -- Automatisch schließen initialisieren (Standard: deaktiviert)
        if MageTeleportsDB.autoClose == nil then
            MageTeleportsDB.autoClose = false
        end
        
        -- Minimap-Icon Position initialisieren (Standard: 0 = oben)
        if MageTeleportsDB.minimapIconAngle == nil then
            MageTeleportsDB.minimapIconAngle = 0
        end
        
        C_Timer.After(1.5, function()
            CreateMainFrame()
        end)
    end
end)

function CreateMainFrame()
    -- Alten Frame bereinigen falls vorhanden (verhindert doppelte Event-Handler)
    if MageTeleportsFrame then
        MageTeleportsFrame:UnregisterAllEvents()
        MageTeleportsFrame:Hide()
        MageTeleportsFrame:SetParent(nil)
    end
    
    MageTeleportsFrame = CreateFrame("Frame", "MageTeleportsFrame", UIParent, "BackdropTemplate")
    MageTeleportsFrame:SetSize(480, 465)
    MageTeleportsFrame:SetClampedToScreen(true)
    
    if MageTeleportsDB.point then
        MageTeleportsFrame:ClearAllPoints()
        MageTeleportsFrame:SetPoint(MageTeleportsDB.point, UIParent, MageTeleportsDB.relativePoint or "CENTER", MageTeleportsDB.xOfs or 0, MageTeleportsDB.yOfs or 0)
    else
        MageTeleportsFrame:SetPoint("CENTER")
    end
    
    MageTeleportsFrame:Hide()
    MageTeleportsFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = false, 
        edgeSize = 2,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    MageTeleportsFrame:SetBackdropColor(0.05, 0.05, 0.05, MageTeleportsDB.transparency or 0.95)
    MageTeleportsFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

    local title = MageTeleportsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", 0, -10)
    title:SetText(L["TITLE"])

    local teleportHeader = MageTeleportsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    teleportHeader:SetPoint("TOP", -115, -40)
    teleportHeader:SetText(L["TELEPORTS"])

    local portalHeader = MageTeleportsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    portalHeader:SetPoint("TOP", 115, -40)
    portalHeader:SetText(L["PORTALS"])
    
    local teleRuneIcon = MageTeleportsFrame:CreateTexture(nil, "ARTWORK")
    teleRuneIcon:SetSize(16, 16)
    teleRuneIcon:SetPoint("TOPLEFT", 35, -410)
    teleRuneIcon:SetTexture(GetItemIcon(17031))
    
    local teleRuneText = MageTeleportsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    teleRuneText:SetPoint("LEFT", teleRuneIcon, "RIGHT", 5, 0)
    teleRuneText:SetTextColor(0.8, 0.8, 0.8, 1)
    
    local portalRuneIcon = MageTeleportsFrame:CreateTexture(nil, "ARTWORK")
    portalRuneIcon:SetSize(16, 16)
    portalRuneIcon:SetPoint("TOPRIGHT", -175, -410)
    portalRuneIcon:SetTexture(GetItemIcon(17032))
    
    local portalRuneText = MageTeleportsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    portalRuneText:SetPoint("LEFT", portalRuneIcon, "RIGHT", 5, 0)
    portalRuneText:SetTextColor(0.8, 0.8, 0.8, 1)
    
    local function UpdateRuneCount()
        local teleRuneCount = GetItemCount(17031)
        local portalRuneCount = GetItemCount(17032)
        teleRuneText:SetText(string.format(L["RUNE_OF_TELEPORTATION"], teleRuneCount))
        portalRuneText:SetText(string.format(L["RUNE_OF_PORTALS"], portalRuneCount))
    end
    
    UpdateRuneCount()
    
    
    local statsTexts = {}
    
    
    MageTeleportsFrame:RegisterEvent("BAG_UPDATE")
    MageTeleportsFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    MageTeleportsFrame:RegisterEvent("UNIT_SPELLCAST_START")
    MageTeleportsFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "BAG_UPDATE" then
            UpdateRuneCount()
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            local unit, castGUID, spellID = ...
            if unit == "player" and MageTeleportsDB.stats and statsTexts[spellID] then
                MageTeleportsDB.stats[spellID] = (MageTeleportsDB.stats[spellID] or 0) + 1
                if MageTeleportsDB.showCounter then
                    statsTexts[spellID]:SetText(MageTeleportsDB.stats[spellID] .. "x")
                end
            end
        elseif event == "UNIT_SPELLCAST_START" then
            local unit, castGUID, spellID = ...
            -- Nach Cast-Start schließen, nicht im PostClick (sonst wird der Cast abgebrochen)
            if unit == "player" and statsTexts[spellID] and MageTeleportsDB.autoClose and not InCombatLockdown() then
                MageTeleportsFrame:Hide()
            end
        end
    end)

    local closeBtn = CreateFrame("Button", nil, MageTeleportsFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:SetSize(24, 24)
    closeBtn:SetScript("OnClick", function()
        MageTeleportsFrame:Hide()
    end)

    local lockBtn = CreateFrame("Button", nil, MageTeleportsFrame)
    lockBtn:SetPoint("RIGHT", closeBtn, "LEFT", 0, 0)
    lockBtn:SetSize(24, 24)

    local lockTexture = lockBtn:CreateTexture(nil, "BACKGROUND")
    lockTexture:SetSize(24, 24)
    lockTexture:SetPoint("CENTER")
    lockTexture:SetTexture("Interface\\Buttons\\LockButton-Locked-Up")
    lockBtn.lockTexture = lockTexture

    local highlight = lockBtn:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetSize(24, 24)
    highlight:SetPoint("CENTER")
    highlight:SetTexture("Interface\\Buttons\\UI-Common-MouseHilight")
    highlight:SetBlendMode("ADD")

    local isLocked = true
    if MageTeleportsDB.isLocked ~= nil then
        isLocked = MageTeleportsDB.isLocked
    end

    if isLocked then
        lockTexture:SetTexture("Interface\\Buttons\\LockButton-Locked-Up")
    else
        lockTexture:SetTexture("Interface\\Buttons\\LockButton-Unlocked-Up")
        MageTeleportsFrame:SetMovable(true)
        MageTeleportsFrame:EnableMouse(true)
        MageTeleportsFrame:RegisterForDrag("LeftButton")
    end

    lockBtn:SetScript("OnClick", function(self)
        isLocked = not isLocked
        MageTeleportsDB.isLocked = isLocked
        
        if isLocked then
            lockTexture:SetTexture("Interface\\Buttons\\LockButton-Locked-Up")
            MageTeleportsFrame:SetMovable(false)
            MageTeleportsFrame:EnableMouse(false)
        else
            lockTexture:SetTexture("Interface\\Buttons\\LockButton-Unlocked-Up")
            MageTeleportsFrame:SetMovable(true)
            MageTeleportsFrame:EnableMouse(true)
            MageTeleportsFrame:RegisterForDrag("LeftButton")
            MageTeleportsFrame:SetScript("OnDragStart", function(self) 
                self:StartMoving() 
            end)
            MageTeleportsFrame:SetScript("OnDragStop", function(self) 
                self:StopMovingOrSizing()
                local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint(1)
                MageTeleportsDB.point = point
                MageTeleportsDB.relativePoint = relativePoint
                MageTeleportsDB.xOfs = xOfs
                MageTeleportsDB.yOfs = yOfs
            end)
        end
    end)

    if not isLocked then
        MageTeleportsFrame:SetScript("OnDragStart", function(self) 
            self:StartMoving() 
        end)
        MageTeleportsFrame:SetScript("OnDragStop", function(self) 
            self:StopMovingOrSizing()
            local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint(1)
            MageTeleportsDB.point = point
            MageTeleportsDB.relativePoint = relativePoint
            MageTeleportsDB.xOfs = xOfs
            MageTeleportsDB.yOfs = yOfs
        end)
    end

    lockBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        if isLocked then
            GameTooltip:SetText(L["LOCKED"], 1, 1, 1)
        else
            GameTooltip:SetText(L["UNLOCKED"], 1, 1, 1)
        end
        GameTooltip:Show()
    end)
    lockBtn:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)


    
    local settingsBtn = CreateFrame("Button", "MageTeleportsSettingsBtn", MageTeleportsFrame)
    settingsBtn:SetPoint("TOPLEFT", 5, -5)
    settingsBtn:SetSize(24, 24)

    local settingsTexture = settingsBtn:CreateTexture(nil, "BACKGROUND")
    settingsTexture:SetSize(24, 24)
    settingsTexture:SetPoint("CENTER")
    settingsTexture:SetTexture("Interface\\Icons\\INV_Misc_Gear_01")

    local settingsHighlight = settingsBtn:CreateTexture(nil, "HIGHLIGHT")
    settingsHighlight:SetAllPoints()
    settingsHighlight:SetTexture("Interface\\Buttons\\UI-Common-MouseHilight")
    settingsHighlight:SetBlendMode("ADD")

    local settingsFrame = CreateFrame("Frame", "MageTeleportsSettingsFrame", UIParent, "BackdropTemplate")
    settingsFrame:SetSize(300, 200)
    settingsFrame:SetPoint("CENTER")
    settingsFrame:SetClampedToScreen(true)
    settingsFrame:Hide()
    settingsFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = false, 
        edgeSize = 2,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    settingsFrame:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
    settingsFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    settingsFrame:SetFrameStrata("DIALOG")
    settingsFrame:SetMovable(true)
    settingsFrame:EnableMouse(true)
    settingsFrame:RegisterForDrag("LeftButton")
    settingsFrame:SetScript("OnDragStart", settingsFrame.StartMoving)
    settingsFrame:SetScript("OnDragStop", settingsFrame.StopMovingOrSizing)

    local settingsTitle = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    settingsTitle:SetPoint("TOP", 0, -10)
    settingsTitle:SetText(L["SETTINGS"])

    local settingsCloseBtn = CreateFrame("Button", nil, settingsFrame, "UIPanelCloseButton")
    settingsCloseBtn:SetPoint("TOPRIGHT", -5, -5)
    settingsCloseBtn:SetSize(24, 24)
    settingsCloseBtn:SetScript("OnClick", function()
        settingsFrame:Hide()
    end)

    
    local counterCheckbox = CreateFrame("CheckButton", "MageTeleportsCounterCheckbox", settingsFrame, "UICheckButtonTemplate")
    counterCheckbox:SetPoint("TOPLEFT", 20, -50)
    counterCheckbox:SetSize(24, 24)
    counterCheckbox:SetChecked(MageTeleportsDB.showCounter)
    
    local counterLabel = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    counterLabel:SetPoint("LEFT", counterCheckbox, "RIGHT", 5, 0)
    counterLabel:SetText(L["SHOW_COUNTER"])
    
    counterCheckbox:SetScript("OnClick", function(self)
        MageTeleportsDB.showCounter = self:GetChecked()
        
        MageTeleportsFrame:Hide()
        CreateMainFrame()
        MageTeleportsFrame:Show()
        settingsFrame:Show()
    end)
    
    -- Reset-Button für Counter
    local resetBtn = CreateFrame("Button", nil, settingsFrame, "BackdropTemplate")
    resetBtn:SetPoint("LEFT", counterLabel, "RIGHT", 10, 0)
    resetBtn:SetSize(50, 20)
    resetBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = false, edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    resetBtn:SetBackdropColor(0.3, 0.15, 0.15, 0.9)
    resetBtn:SetBackdropBorderColor(0.5, 0.3, 0.3, 1)
    
    local resetBtnText = resetBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    resetBtnText:SetPoint("CENTER", 0, 0)
    resetBtnText:SetText(L["RESET_COUNTER"])
    
    resetBtn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.5, 0.2, 0.2, 1)
        self:SetBackdropBorderColor(0.7, 0.4, 0.4, 1)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["RESET_COUNTER_TOOLTIP"], 1, 1, 1)
        GameTooltip:Show()
    end)
    resetBtn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.3, 0.15, 0.15, 0.9)
        self:SetBackdropBorderColor(0.5, 0.3, 0.3, 1)
        GameTooltip:Hide()
    end)
    
    resetBtn:SetScript("OnClick", function(self)
        -- Alle Counter auf 0 zurücksetzen
        MageTeleportsDB.stats = {}
        
        -- UI aktualisieren
        MageTeleportsFrame:Hide()
        CreateMainFrame()
        MageTeleportsFrame:Show()
        settingsFrame:Show()
    end)
    
    -- Checkbox für "Nur gelernte anzeigen"
    local onlyLearnedCheckbox = CreateFrame("CheckButton", "MageTeleportsOnlyLearnedCheckbox", settingsFrame, "UICheckButtonTemplate")
    onlyLearnedCheckbox:SetPoint("TOPLEFT", 20, -75)
    onlyLearnedCheckbox:SetSize(24, 24)
    onlyLearnedCheckbox:SetChecked(MageTeleportsDB.showOnlyLearned)
    
    local onlyLearnedLabel = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    onlyLearnedLabel:SetPoint("LEFT", onlyLearnedCheckbox, "RIGHT", 5, 0)
    onlyLearnedLabel:SetText(L["SHOW_ONLY_LEARNED"])
    
    onlyLearnedCheckbox:SetScript("OnClick", function(self)
        MageTeleportsDB.showOnlyLearned = self:GetChecked()
        
        MageTeleportsFrame:Hide()
        CreateMainFrame()
        MageTeleportsFrame:Show()
        settingsFrame:Show()
    end)
    
    -- Checkbox für "Automatisch schließen"
    local autoCloseCheckbox = CreateFrame("CheckButton", "MageTeleportsAutoCloseCheckbox", settingsFrame, "UICheckButtonTemplate")
    autoCloseCheckbox:SetPoint("TOPLEFT", 20, -100)
    autoCloseCheckbox:SetSize(24, 24)
    autoCloseCheckbox:SetChecked(MageTeleportsDB.autoClose)
    
    local autoCloseLabel = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    autoCloseLabel:SetPoint("LEFT", autoCloseCheckbox, "RIGHT", 5, 0)
    autoCloseLabel:SetText(L["AUTO_CLOSE"])
    
    autoCloseCheckbox:SetScript("OnClick", function(self)
        MageTeleportsDB.autoClose = self:GetChecked()
    end)

    
    local transparencySlider = CreateFrame("Slider", "MageTeleportsTransparencySlider", settingsFrame, "OptionsSliderTemplate")
    transparencySlider:SetPoint("TOPLEFT", 20, -150)
    transparencySlider:SetMinMaxValues(0.3, 1.0)
    transparencySlider:SetValue(MageTeleportsDB.transparency or 0.95)
    transparencySlider:SetValueStep(0.05)
    transparencySlider:SetObeyStepOnDrag(true)
    transparencySlider:SetWidth(200)
    
    -- Slider-Hintergrund (Track) hinzufügen
    local sliderBg = transparencySlider:CreateTexture(nil, "BACKGROUND")
    sliderBg:SetPoint("TOPLEFT", 2, -8)
    sliderBg:SetPoint("BOTTOMRIGHT", -2, 8)
    sliderBg:SetColorTexture(0.3, 0.3, 0.3, 0.8)
    
    -- Rahmen für den Slider
    local sliderBorder = transparencySlider:CreateTexture(nil, "BORDER")
    sliderBorder:SetPoint("TOPLEFT", 1, -7)
    sliderBorder:SetPoint("BOTTOMRIGHT", -1, 7)
    sliderBorder:SetColorTexture(0.5, 0.5, 0.5, 1)
    
    -- Innerer Hintergrund (dunkler)
    local sliderInner = transparencySlider:CreateTexture(nil, "ARTWORK")
    sliderInner:SetPoint("TOPLEFT", 3, -9)
    sliderInner:SetPoint("BOTTOMRIGHT", -3, 9)
    sliderInner:SetColorTexture(0.15, 0.15, 0.15, 1)
    
    getglobal(transparencySlider:GetName() .. 'Low'):SetText('30%')
    getglobal(transparencySlider:GetName() .. 'High'):SetText('100%')
    getglobal(transparencySlider:GetName() .. 'Text'):SetText(L["TRANSPARENCY"])
    
    transparencySlider:SetScript("OnValueChanged", function(self, value)
        MageTeleportsDB.transparency = value
        MageTeleportsFrame:SetBackdropColor(0.05, 0.05, 0.05, value)
    end)

    settingsBtn:SetScript("OnClick", function()
        if settingsFrame:IsShown() then
            settingsFrame:Hide()
        else
            settingsFrame:Show()
        end
    end)

    settingsBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(L["SETTINGS"], 1, 1, 1)
        GameTooltip:Show()
    end)
    settingsBtn:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)



    local authorText = MageTeleportsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    authorText:SetPoint("BOTTOM", 0, 10)
    authorText:SetText("An addon by NeRgY")
    authorText:SetTextColor(0.6, 0.6, 0.6, 1)

    local versionText = MageTeleportsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    versionText:SetPoint("BOTTOMLEFT", 10, 10)
    versionText:SetText("v1.0.7")
    versionText:SetTextColor(0.6, 0.6, 0.6, 1)

    local playerFaction = UnitFactionGroup("player")
    
    local locations = {}
    local portals = {}
    
    if playerFaction == "Alliance" then
        locations = {
            { id = 3561,  name = L["STORMWIND"], level = 20 },
            { id = 3562,  name = L["IRONFORGE"], level = 20 },
            { id = 32271, name = L["EXODAR"], level = 20 },
            { id = 3565,  name = L["DARNASSUS"], level = 30 },
            { id = 49359, name = L["THERAMORE"], level = 35 },
            { id = 33690, name = L["SHATTRATH"], level = 60 },
        }
        portals = {
            { id = 10059, name = L["STORMWIND"], level = 40 },
            { id = 11416, name = L["IRONFORGE"], level = 40 },
            { id = 32266, name = L["EXODAR"], level = 40 },
            { id = 11419, name = L["DARNASSUS"], level = 50 },
            { id = 49360, name = L["THERAMORE"], level = 35 },
            { id = 33691, name = L["SHATTRATH"], level = 65 },
        }
    else
        locations = {
            { id = 3567,  name = L["ORGRIMMAR"], level = 20 },
            { id = 3563,  name = L["UNDERCITY"], level = 20 },
            { id = 32272, name = L["SILVERMOON"], level = 20 },
            { id = 3566,  name = L["THUNDERBLUFF"], level = 30 },
            { id = 49358, name = L["STONARD"], level = 35 },
            { id = 33690, name = L["SHATTRATH"], level = 60 },
        }
        portals = {
            { id = 11417, name = L["ORGRIMMAR"], level = 40 },
            { id = 11418, name = L["UNDERCITY"], level = 40 },
            { id = 32267, name = L["SILVERMOON"], level = 40 },
            { id = 11420, name = L["THUNDERBLUFF"], level = 50 },
            { id = 49361, name = L["STONARD"], level = 35 },
            { id = 33691, name = L["SHATTRATH"], level = 65 },
        }
    end

    local teleportIndex = 0
    for i, spell in ipairs(locations) do
        local playerLevel = UnitLevel("player")
        local spellName = GetSpellInfo(spell.id)
        
        local isKnown = false
        if IsSpellKnown and IsSpellKnown(spell.id) then
            isKnown = true
        elseif spellName then
            local j = 1
            while true do
                local name, rank = GetSpellBookItemName(j, BOOKTYPE_SPELL)
                if not name then break end
                if name == spellName then
                    isKnown = true
                    break
                end
                j = j + 1
            end
        end
        local canLearn = playerLevel >= spell.level
        
        -- Wenn "Nur gelernte anzeigen" aktiv ist, überspringe nicht gelernte Spells
        if MageTeleportsDB.showOnlyLearned and not isKnown then
            -- Spell überspringen
        else
            local btn = CreateFrame("Button", nil, MageTeleportsFrame, "BackdropTemplate,SecureActionButtonTemplate")
            btn:SetSize(210, 50)
            btn:SetPoint("TOPLEFT", 15, -70 - teleportIndex*55)
            teleportIndex = teleportIndex + 1
            
            btn:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8X8",
                edgeFile = "Interface\\Buttons\\WHITE8X8",
                tile = false, edgeSize = 1,
                insets = { left = 0, right = 0, top = 0, bottom = 0 }
            })
            
            if not canLearn or not isKnown then
                btn:SetBackdropColor(0.3, 0.1, 0.1, 0.8)
                btn:SetBackdropBorderColor(0.6, 0.2, 0.2, 1)
            else
                btn:SetBackdropColor(0.15, 0.15, 0.15, 0.8)
                btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
            end
            
            local icon = btn:CreateTexture(nil, "ARTWORK")
            icon:SetSize(32, 32)
            icon:SetPoint("LEFT", 5, 5)
            if spellName then
                icon:SetTexture(GetSpellTexture(spell.id))
            else
                icon:SetTexture("Interface\\Icons\\INV_Misc_Rune_01")
            end
            
            if not canLearn or not isKnown then
                icon:SetDesaturated(true)
            end
            
            local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            text:SetPoint("TOPLEFT", icon, "TOPRIGHT", 10, 0)
            text:SetText(spell.name)
            
            
            local statsText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            statsText:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -5, -5)
            local useCount = MageTeleportsDB.stats[spell.id] or 0
            if MageTeleportsDB.showCounter then
                statsText:SetText(useCount .. "x")
            else
                statsText:SetText("")
            end
            statsText:SetTextColor(0.5, 0.8, 1, 0.8)
            statsTexts[spell.id] = statsText
            
            local statusText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            statusText:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 10, 0)
            
            if not canLearn then
                statusText:SetText(string.format(L["REQUIRED_LEVEL"], spell.level))
                statusText:SetTextColor(1, 0.5, 0.5, 1)
            elseif not isKnown then
                statusText:SetText(L["NOT_LEARNED"])
                statusText:SetTextColor(1, 0.7, 0, 1)
            else
                statusText:SetText("")
            end
            
            btn:RegisterForClicks("AnyUp", "AnyDown")
            if isKnown and canLearn and spellName then
                btn:SetAttribute("type", "spell")
                btn:SetAttribute("spell", spellName)
                btn:SetAttribute("checkselfcast", true)
            end
            
            btn:SetScript("OnEnter", function()
                if isKnown and canLearn then
                    btn:SetBackdropColor(0.25, 0.35, 0.45, 1)
                    btn:SetBackdropBorderColor(0.5, 0.7, 0.9, 1)
                end
            end)
            btn:SetScript("OnLeave", function()
                if not canLearn or not isKnown then
                    btn:SetBackdropColor(0.3, 0.1, 0.1, 0.8)
                    btn:SetBackdropBorderColor(0.6, 0.2, 0.2, 1)
                else
                    btn:SetBackdropColor(0.15, 0.15, 0.15, 0.8)
                    btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
                end
            end)
        end
    end

    local portalIndex = 0
    for i, spell in ipairs(portals) do
        local playerLevel = UnitLevel("player")
        local spellName = GetSpellInfo(spell.id)
        
        local isKnown = false
        if IsSpellKnown and IsSpellKnown(spell.id) then
            isKnown = true
        elseif spellName then
            local j = 1
            while true do
                local name, rank = GetSpellBookItemName(j, BOOKTYPE_SPELL)
                if not name then break end
                if name == spellName then
                    isKnown = true
                    break
                end
                j = j + 1
            end
        end
        local canLearn = playerLevel >= spell.level
        
        -- Wenn "Nur gelernte anzeigen" aktiv ist, überspringe nicht gelernte Spells
        if MageTeleportsDB.showOnlyLearned and not isKnown then
            -- Spell überspringen
        else
            local btn = CreateFrame("Button", nil, MageTeleportsFrame, "BackdropTemplate,SecureActionButtonTemplate")
            btn:SetSize(210, 50)
            btn:SetPoint("TOPRIGHT", -15, -70 - portalIndex*55)
            portalIndex = portalIndex + 1
            
            btn:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8X8",
                edgeFile = "Interface\\Buttons\\WHITE8X8",
                tile = false, edgeSize = 1,
                insets = { left = 0, right = 0, top = 0, bottom = 0 }
            })
            
            if not canLearn or not isKnown then
                btn:SetBackdropColor(0.3, 0.1, 0.1, 0.8)
                btn:SetBackdropBorderColor(0.6, 0.2, 0.2, 1)
            else
                btn:SetBackdropColor(0.15, 0.15, 0.15, 0.8)
                btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
            end
            
            local icon = btn:CreateTexture(nil, "ARTWORK")
            icon:SetSize(32, 32)
            icon:SetPoint("LEFT", 5, 5)
            if spellName then
                icon:SetTexture(GetSpellTexture(spell.id))
            else
                icon:SetTexture("Interface\\Icons\\INV_Misc_Rune_01")
            end
            
            if not canLearn or not isKnown then
                icon:SetDesaturated(true)
            end
            
            local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            text:SetPoint("TOPLEFT", icon, "TOPRIGHT", 10, 0)
            text:SetText(spell.name)
            
            
            local statsText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            statsText:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -5, -5)
            local useCount = MageTeleportsDB.stats[spell.id] or 0
            if MageTeleportsDB.showCounter then
                statsText:SetText(useCount .. "x")
            else
                statsText:SetText("")
            end
            statsText:SetTextColor(0.5, 0.8, 1, 0.8)
            statsTexts[spell.id] = statsText
            
            local statusText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            statusText:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 10, 0)
            
            if not canLearn then
                statusText:SetText(string.format(L["REQUIRED_LEVEL"], spell.level))
                statusText:SetTextColor(1, 0.5, 0.5, 1)
            elseif not isKnown then
                statusText:SetText(L["NOT_LEARNED"])
                statusText:SetTextColor(1, 0.7, 0, 1)
            else
                statusText:SetText("")
            end
            
            btn:RegisterForClicks("AnyUp", "AnyDown")
            if isKnown and canLearn and spellName then
                btn:SetAttribute("type", "spell")
                btn:SetAttribute("spell", spellName)
                btn:SetAttribute("checkselfcast", true)
            end
            
            btn:SetScript("OnEnter", function()
                if isKnown and canLearn then
                    btn:SetBackdropColor(0.25, 0.35, 0.45, 1)
                    btn:SetBackdropBorderColor(0.5, 0.7, 0.9, 1)
                end
            end)
            btn:SetScript("OnLeave", function()
                if not canLearn or not isKnown then
                    btn:SetBackdropColor(0.3, 0.1, 0.1, 0.8)
                    btn:SetBackdropBorderColor(0.6, 0.2, 0.2, 1)
                else
                    btn:SetBackdropColor(0.15, 0.15, 0.15, 0.8)
                    btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
                end
            end)
        end
    end

    -- Minimap-Button nur erstellen, wenn er noch nicht existiert
    if not MageTeleportsMinimapButton then
        local minimapButton = CreateFrame("Button", "MageTeleportsMinimapButton", Minimap)
        minimapButton:SetSize(32, 32)
        minimapButton:SetFrameStrata("MEDIUM")
        minimapButton:SetFrameLevel(8)
        minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -15, 0)

        local icon = minimapButton:CreateTexture(nil, "BACKGROUND")
        icon:SetSize(20, 20)
        icon:SetPoint("CENTER", 0, 1)
        icon:SetTexture("Interface\\AddOns\\PortalBook\\MinimapIcon")

        local border = minimapButton:CreateTexture(nil, "OVERLAY")
        border:SetSize(52, 52)
        border:SetPoint("TOPLEFT", 0, 0)
        border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

        minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

        minimapButton:RegisterForClicks("LeftButtonUp")
        minimapButton:SetScript("OnClick", function(self, button)
            if MageTeleportsFrame:IsShown() then
                MageTeleportsFrame:Hide()
            else
                MageTeleportsFrame:Show()
            end
        end)

        minimapButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText(L["TOOLTIP_TITLE"], 1, 1, 1)
            GameTooltip:AddLine(L["TOOLTIP_CLICK"], 1, 0.82, 0, 1)
            GameTooltip:AddLine(L["TOOLTIP_RIGHTCLICK"], 1, 0.82, 0, 1)
            GameTooltip:Show()
        end)
        minimapButton:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        local function UpdateMinimapButtonPosition()
            local angle = minimapButton.angle or 0
            local x = math.cos(angle) * 80
            local y = math.sin(angle) * 80
            minimapButton:ClearAllPoints()
            minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
        end

        -- Position aus Datenbank laden
        minimapButton.angle = MageTeleportsDB.minimapIconAngle or 0

        minimapButton:EnableMouse(true)
        minimapButton:SetScript("OnMouseDown", function(self, button)
            if button == "RightButton" then
                self.isMoving = true
            end
        end)
        
        minimapButton:SetScript("OnMouseUp", function(self, button)
            if button == "RightButton" then
                self.isMoving = false
                -- Position in Datenbank speichern
                MageTeleportsDB.minimapIconAngle = self.angle
            end
        end)
        
        minimapButton:SetScript("OnUpdate", function(self)
            if self.isMoving then
                local mx, my = Minimap:GetCenter()
                local px, py = GetCursorPosition()
                local scale = Minimap:GetEffectiveScale()
                px, py = px / scale, py / scale
                local angle = math.atan2(py - my, px - mx)
                self.angle = angle
                UpdateMinimapButtonPosition()
            end
        end)

        UpdateMinimapButtonPosition()
    end
end