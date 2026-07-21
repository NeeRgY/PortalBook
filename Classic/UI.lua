local _, ns = ...
local L = ns.L

ns.Colors = {
    bg = { 0.06, 0.07, 0.10 },
    row = { 0.10, 0.11, 0.14 },
    border = { 0.25, 0.28, 0.35 },
    accent = { 0.35, 0.75, 0.95 },
    accentPortal = { 0.55, 0.45, 0.95 },
    textMuted = { 0.55, 0.58, 0.65 },
    text = { 0.90, 0.92, 0.95 },
    dangerMuted = { 0.45, 0.20, 0.22 },
}

local C = ns.Colors
local ROW_HEIGHT = 40
local ROW_GAP = 6
local ICON_SIZE = 36
local FRAME_WIDTH = 420
local HEADER_BTN_SIZE = 28
local MEDIA = "Interface\\AddOns\\PortalBook\\Media\\"
local ICON_CLOSE = MEDIA .. "Icon_Close"
local ICON_SETTINGS = MEDIA .. "Icon_Settings"
local LIST_TOP = 56
local FOOTER_HEIGHT = 44
local LIST_FOOTER_GAP = 10

local function ApplyBackdrop(frame, bgAlpha)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = false,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    local a = bgAlpha or (MageTeleportsDB and MageTeleportsDB.transparency) or 0.95
    frame:SetBackdropColor(C.bg[1], C.bg[2], C.bg[3], a)
    frame:SetBackdropBorderColor(C.accent[1], C.accent[2], C.accent[3], 0.6)
end

local function SetFontColor(fs, color)
    fs:SetTextColor(color[1], color[2], color[3], 1)
end

local function SetButtonBackground(btn, r, g, b, a)
    if not btn.Background then
        btn.Background = btn:CreateTexture(nil, "BACKGROUND")
        btn.Background:SetTexture("Interface\\Buttons\\WHITE8X8")
        btn.Background:SetAllPoints()
    end
    btn.Background:SetVertexColor(r, g, b, a)
end

local function CreateTitlebarButton(parent, iconPath, iconSize, hoverRed)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(HEADER_BTN_SIZE, HEADER_BTN_SIZE)
    btn:RegisterForClicks("AnyUp")
    SetButtonBackground(btn, 1, 1, 1, 0)

    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("CENTER")
    icon:SetSize(iconSize or 12, iconSize or 12)
    icon:SetTexture(iconPath)
    icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    btn.icon = icon

    btn:SetScript("OnEnter", function(self)
        self.icon:SetVertexColor(1, 1, 1, 1)
        if hoverRed then
            SetButtonBackground(self, 1, 0, 0, 0.2)
        else
            SetButtonBackground(self, 1, 1, 1, 0.05)
        end
    end)
    btn:SetScript("OnLeave", function(self)
        self.icon:SetVertexColor(0.7, 0.7, 0.7, 1)
        SetButtonBackground(self, 1, 1, 1, 0)
        GameTooltip:Hide()
    end)

    return btn
end

local function CreateIconButton(parent, size)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate,SecureActionButtonTemplate")
    btn:SetSize(size, size)
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = false,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    btn:SetBackdropColor(0.08, 0.09, 0.11, 0.95)
    btn:SetBackdropBorderColor(C.border[1], C.border[2], C.border[3], 1)

    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT", 2, -2)
    icon:SetPoint("BOTTOMRIGHT", -2, 2)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    btn.icon = icon

    btn:RegisterForClicks("AnyUp", "AnyDown")
    return btn
end

local function WireSpellButton(btn, spellID, hoverColor, kindLabel, requiredLevel, sourceKey)
    btn.spellID = spellID
    local known = ns.IsSpellKnown(spellID)
    btn.icon:SetTexture(ns.GetSpellTexture(spellID))
    btn.icon:SetDesaturated(not known)

    if known then
        btn:SetBackdropBorderColor(C.border[1], C.border[2], C.border[3], 1)
        btn:SetAttribute("type", "spell")
        local spellName = ns.GetSpellName(spellID)
        btn:SetAttribute("spell", spellName or spellID)
        btn:SetAttribute("checkselfcast", true)
    else
        btn:SetBackdropBorderColor(C.dangerMuted[1], C.dangerMuted[2], C.dangerMuted[3], 0.8)
        btn:SetAttribute("type", nil)
        btn:SetAttribute("spell", nil)
    end

    btn:SetScript("OnEnter", function(self)
        if known then
            self:SetBackdropBorderColor(hoverColor[1], hoverColor[2], hoverColor[3], 1)
        end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if known and spellID then
            if GameTooltip.SetSpellByID then
                GameTooltip:SetSpellByID(spellID)
            else
                GameTooltip:SetText(ns.GetSpellName(spellID) or kindLabel, 1, 1, 1)
                GameTooltip:Show()
            end
        else
            local spellName = ns.GetSpellName(spellID)
            GameTooltip:SetText(spellName or kindLabel, 1, 1, 1)
            GameTooltip:AddLine(L["NOT_LEARNED"], 1, 0.7, 0.2, true)
            if requiredLevel then
                local playerLevel = UnitLevel("player") or 1
                local levelColor = playerLevel >= requiredLevel and { 0.5, 0.9, 0.5 } or { 1, 0.45, 0.45 }
                GameTooltip:AddLine(string.format(L["REQUIRED_LEVEL"], requiredLevel), levelColor[1], levelColor[2], levelColor[3], true)
            end
            if sourceKey and L[sourceKey] then
                GameTooltip:AddLine(string.format(L["LEARN_AT"], L[sourceKey]), 0.65, 0.8, 1, true)
            end
            GameTooltip:Show()
        end
    end)

    btn:SetScript("OnLeave", function(self)
        if known then
            self:SetBackdropBorderColor(C.border[1], C.border[2], C.border[3], 1)
        else
            self:SetBackdropBorderColor(C.dangerMuted[1], C.dangerMuted[2], C.dangerMuted[3], 0.8)
        end
        GameTooltip:Hide()
    end)
end

function ns.RegisterSpellButton(btn, spellID, counterText, destKey)
    if not ns.spellButtons then
        ns.spellButtons = {}
    end
    ns.spellButtons[spellID] = {
        button = btn,
        counterText = counterText,
        destKey = destKey,
    }
end

function ns.UpdateCounters()
    if not ns.spellButtons then
        return
    end
    for spellID, info in pairs(ns.spellButtons) do
        local counterText = info.counterText
        if counterText then
            if MageTeleportsDB.showCounter then
                local count = (MageTeleportsDB.stats and MageTeleportsDB.stats[spellID]) or 0
                counterText:SetText(count .. "x")
            else
                counterText:SetText("")
            end
        end
    end
end

function ns.AnnounceDestination(destKey)
    if not MageTeleportsDB.announcePortal then
        return
    end
    if not IsInGroup() then
        return
    end
    local destination = L[destKey] or destKey
    local message = string.format(L["ANNOUNCE_MSG"], destination)
    if IsInRaid() then
        SendChatMessage(message, "RAID")
    else
        SendChatMessage(message, "PARTY")
    end
end

local function CreateDestinationRow(parent, dest, index)
    local row = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    row:SetSize(FRAME_WIDTH - 24, ROW_HEIGHT)
    row:SetPoint("TOPLEFT", 12, -((index - 1) * (ROW_HEIGHT + ROW_GAP)))
    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = false,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    row:SetBackdropColor(C.row[1], C.row[2], C.row[3], 0.9)
    row:SetBackdropBorderColor(C.border[1], C.border[2], C.border[3], 0.5)

    local teleKnown = ns.IsSpellKnown(dest.teleport)
    local portalKnown = dest.portal and ns.IsSpellKnown(dest.portal)

    local teleBtn = CreateIconButton(row, ICON_SIZE)
    teleBtn:SetPoint("LEFT", 6, 0)
    WireSpellButton(teleBtn, dest.teleport, C.accent, L["TELEPORT"], dest.teleportLevel, dest.source)

    local teleCounter = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    teleCounter:SetPoint("LEFT", teleBtn, "RIGHT", 6, 0)
    teleCounter:SetWidth(36)
    teleCounter:SetJustifyH("LEFT")
    SetFontColor(teleCounter, C.accent)
    local teleCount = (MageTeleportsDB.stats and MageTeleportsDB.stats[dest.teleport]) or 0
    if MageTeleportsDB.showCounter then
        teleCounter:SetText(teleCount .. "x")
    else
        teleCounter:SetText("")
    end

    local portalSlot = CreateFrame("Frame", nil, row)
    portalSlot:SetSize(ICON_SIZE, ICON_SIZE)
    portalSlot:SetPoint("RIGHT", -6, 0)

    local portalCounter = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    portalCounter:SetPoint("RIGHT", portalSlot, "LEFT", -6, 0)
    portalCounter:SetWidth(36)
    portalCounter:SetJustifyH("RIGHT")
    SetFontColor(portalCounter, C.accentPortal)

    if dest.portal then
        local portalBtn = CreateIconButton(row, ICON_SIZE)
        portalBtn:SetPoint("CENTER", portalSlot, "CENTER")
        WireSpellButton(portalBtn, dest.portal, C.accentPortal, L["PORTAL"], dest.portalLevel, dest.source)
        local portalCount = (MageTeleportsDB.stats and MageTeleportsDB.stats[dest.portal]) or 0
        if MageTeleportsDB.showCounter then
            portalCounter:SetText(portalCount .. "x")
        else
            portalCounter:SetText("")
        end
        ns.RegisterSpellButton(portalBtn, dest.portal, portalCounter, dest.key)
    else
        local placeholder = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        placeholder:SetPoint("CENTER", portalSlot, "CENTER")
        placeholder:SetText("—")
        SetFontColor(placeholder, C.textMuted)
        portalCounter:SetText("")
    end

    local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameText:SetJustifyH("CENTER")
    nameText:SetWordWrap(false)
    nameText:SetText(L[dest.key] or dest.key)
    SetFontColor(nameText, C.text)

    local statusText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusText:SetJustifyH("CENTER")
    statusText:SetWordWrap(false)

    local knownAny = teleKnown or portalKnown
    local fullyKnown = teleKnown and (not dest.portal or portalKnown)
    if not fullyKnown then
        nameText:SetPoint("LEFT", teleCounter, "RIGHT", 8, 7)
        nameText:SetPoint("RIGHT", portalCounter, "LEFT", -8, 7)
        statusText:SetPoint("LEFT", teleCounter, "RIGHT", 8, -8)
        statusText:SetPoint("RIGHT", portalCounter, "LEFT", -8, -8)

        local teleNeed = (not teleKnown) and dest.teleportLevel or nil
        local portalNeed = (dest.portal and not portalKnown) and dest.portalLevel or nil
        if teleNeed and portalNeed and teleNeed ~= portalNeed then
            statusText:SetText(string.format(L["LEVEL_SPLIT"], teleNeed, portalNeed))
        else
            local level = teleNeed or portalNeed
            if level then
                statusText:SetText(string.format(L["LEVEL_SHORT"], level))
            else
                statusText:SetText(L["NOT_LEARNED"])
            end
        end
        SetFontColor(statusText, { 1, 0.7, 0.35 })
    else
        nameText:SetPoint("LEFT", teleCounter, "RIGHT", 8, 0)
        nameText:SetPoint("RIGHT", portalCounter, "LEFT", -8, 0)
        statusText:SetText("")
    end

    ns.RegisterSpellButton(teleBtn, dest.teleport, teleCounter, dest.key)

    if not knownAny then
        row:SetBackdropColor(0.08, 0.07, 0.08, 0.75)
        nameText:SetAlpha(0.85)
    end

    return row
end

function ns.RefreshDestinationList()
    local frame = ns.mainFrame
    if not frame or not frame.listFrame then
        return
    end

    if InCombatLockdown and InCombatLockdown() then
        if not ns.pendingRefresh then
            ns.pendingRefresh = true
            local defer = CreateFrame("Frame")
            defer:RegisterEvent("PLAYER_REGEN_ENABLED")
            defer:SetScript("OnEvent", function(self)
                self:UnregisterAllEvents()
                ns.pendingRefresh = false
                ns.RefreshDestinationList()
            end)
        end
        return
    end

    ns.spellButtons = {}
    frame.rows = frame.rows or {}
    for _, row in ipairs(frame.rows) do
        row:Hide()
        row:SetParent(nil)
    end
    wipe(frame.rows)

    local faction = UnitFactionGroup("player")
    local destinations = ns.GetVisibleDestinations(faction, MageTeleportsDB.showOnlyLearned)

    for i, dest in ipairs(destinations) do
        frame.rows[i] = CreateDestinationRow(frame.listFrame, dest, i)
    end

    local listHeight = math.max(#destinations * (ROW_HEIGHT + ROW_GAP) - ROW_GAP, ROW_HEIGHT)
    frame.listFrame:SetHeight(listHeight)
    frame:SetHeight(LIST_TOP + LIST_FOOTER_GAP + listHeight + FOOTER_HEIGHT)
end

local function CreateSettingsFrame()
    local settings = CreateFrame("Frame", "MageTeleportsSettingsFrame", UIParent, "BackdropTemplate")
    settings:SetSize(320, 250)
    settings:SetPoint("CENTER")
    settings:SetClampedToScreen(true)
    settings:Hide()
    settings:SetFrameStrata("DIALOG")
    settings:SetMovable(true)
    settings:EnableMouse(true)
    settings:RegisterForDrag("LeftButton")
    settings:SetScript("OnDragStart", settings.StartMoving)
    settings:SetScript("OnDragStop", settings.StopMovingOrSizing)
    ApplyBackdrop(settings, 0.95)
    ns.settingsFrame = settings

    local title = settings:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", 0, -12)
    title:SetText(L["SETTINGS"])
    SetFontColor(title, C.text)

    local closeBtn = CreateTitlebarButton(settings, ICON_CLOSE, 10, true)
    closeBtn:SetPoint("TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function()
        settings:Hide()
    end)

    local function AddCheckbox(y, labelText, dbKey, onChange)
        local cb = CreateFrame("CheckButton", nil, settings, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 18, y)
        cb:SetSize(24, 24)
        cb:SetChecked(MageTeleportsDB[dbKey])

        local label = settings:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("LEFT", cb, "RIGHT", 4, 0)
        label:SetText(labelText)
        SetFontColor(label, C.text)

        cb:SetScript("OnClick", function(self)
            MageTeleportsDB[dbKey] = self:GetChecked() and true or false
            if onChange then
                onChange(self)
            end
        end)
        return cb, label
    end

    local _, counterLabel = AddCheckbox(-48, L["SHOW_COUNTER"], "showCounter", function()
        ns.UpdateCounters()
    end)

    local resetBtn = CreateFrame("Button", nil, settings, "BackdropTemplate")
    resetBtn:SetPoint("LEFT", counterLabel, "RIGHT", 10, 0)
    resetBtn:SetSize(54, 20)
    resetBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = false,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    resetBtn:SetBackdropColor(C.dangerMuted[1], C.dangerMuted[2], C.dangerMuted[3], 0.9)
    resetBtn:SetBackdropBorderColor(0.6, 0.3, 0.3, 1)
    local resetText = resetBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    resetText:SetPoint("CENTER")
    resetText:SetText(L["RESET_COUNTER"])
    resetBtn:SetScript("OnClick", function()
        MageTeleportsDB.stats = {}
        ns.UpdateCounters()
    end)

    AddCheckbox(-76, L["SHOW_ONLY_LEARNED"], "showOnlyLearned", function()
        ns.RefreshDestinationList()
    end)
    AddCheckbox(-104, L["AUTO_CLOSE"], "autoClose")
    AddCheckbox(-132, L["ANNOUNCE_PORTAL"], "announcePortal")

    local slider = CreateFrame("Slider", "MageTeleportsTransparencySlider", settings, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", 20, -185)
    slider:SetMinMaxValues(0.3, 1.0)
    slider:SetValue(MageTeleportsDB.transparency or 0.95)
    slider:SetValueStep(0.05)
    slider:SetObeyStepOnDrag(true)
    slider:SetWidth(240)
    _G[slider:GetName() .. "Low"]:SetText("30%")
    _G[slider:GetName() .. "High"]:SetText("100%")
    _G[slider:GetName() .. "Text"]:SetText(L["TRANSPARENCY"])
    slider:SetScript("OnValueChanged", function(_, value)
        MageTeleportsDB.transparency = value
        if ns.mainFrame then
            ns.mainFrame:SetBackdropColor(C.bg[1], C.bg[2], C.bg[3], value)
        end
    end)
end

function ns.CreateMainFrame()
    if ns.mainFrame then
        ns.mainFrame:UnregisterAllEvents()
        ns.mainFrame:Hide()
        ns.mainFrame:SetParent(nil)
        ns.mainFrame = nil
    end

    local frame = CreateFrame("Frame", "MageTeleportsFrame", UIParent, "BackdropTemplate")
    frame:SetSize(FRAME_WIDTH, 400)
    frame:SetClampedToScreen(true)
    frame:Hide()
    ApplyBackdrop(frame)
    ns.mainFrame = frame
    MageTeleportsFrame = frame

    if MageTeleportsDB.point then
        frame:ClearAllPoints()
        frame:SetPoint(
            MageTeleportsDB.point,
            UIParent,
            MageTeleportsDB.relativePoint or "CENTER",
            MageTeleportsDB.xOfs or 0,
            MageTeleportsDB.yOfs or 0
        )
    else
        frame:SetPoint("CENTER")
    end

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOPLEFT", 14, -12)
    title:SetText(L["TITLE"])
    SetFontColor(title, C.text)

    local classWarning = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    classWarning:SetPoint("LEFT", title, "RIGHT", 10, 0)
    if not ns.IsMage() then
        classWarning:SetText(L["NOT_A_MAGE"])
        classWarning:SetTextColor(1, 0.25, 0.25, 1)
    else
        classWarning:SetText("")
    end

    local underline = frame:CreateTexture(nil, "ARTWORK")
    underline:SetColorTexture(C.accent[1], C.accent[2], C.accent[3], 0.7)
    underline:SetHeight(1)
    underline:SetPoint("TOPLEFT", 12, -34)
    underline:SetPoint("TOPRIGHT", -12, -34)

    local closeBtn = CreateTitlebarButton(frame, ICON_CLOSE, 10, true)
    closeBtn:SetPoint("TOPRIGHT", -4, -4)
    closeBtn:SetScript("OnClick", function()
        frame:Hide()
    end)

    local settingsBtn = CreateTitlebarButton(frame, ICON_SETTINGS, 12, false)
    settingsBtn:SetPoint("RIGHT", closeBtn, "LEFT", 0, 0)
    settingsBtn:SetScript("OnClick", function()
        if not ns.settingsFrame then
            CreateSettingsFrame()
        end
        if ns.settingsFrame:IsShown() then
            ns.settingsFrame:Hide()
        else
            ns.settingsFrame:Show()
        end
    end)
    settingsBtn:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(L["SETTINGS"], 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)

    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, xOfs, yOfs = self:GetPoint(1)
        MageTeleportsDB.point = point
        MageTeleportsDB.relativePoint = relativePoint
        MageTeleportsDB.xOfs = xOfs
        MageTeleportsDB.yOfs = yOfs
    end)

    local teleHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    teleHeader:SetPoint("TOPLEFT", 26, -40)
    teleHeader:SetText(L["TELEPORTS"])
    SetFontColor(teleHeader, C.accent)

    local portalHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    portalHeader:SetPoint("TOPRIGHT", -26, -40)
    portalHeader:SetText(L["PORTALS"])
    SetFontColor(portalHeader, C.accentPortal)

    local listFrame = CreateFrame("Frame", nil, frame)
    listFrame:SetPoint("TOPLEFT", 0, -LIST_TOP)
    listFrame:SetPoint("TOPRIGHT", 0, -LIST_TOP)
    listFrame:SetHeight(1)
    frame.listFrame = listFrame


    local COLUMN_INSET = 12 + 6

    local teleRuneIcon = frame:CreateTexture(nil, "ARTWORK")
    teleRuneIcon:SetSize(16, 16)
    teleRuneIcon:SetPoint("BOTTOMLEFT", COLUMN_INSET, 26)
    teleRuneIcon:SetTexture(ns.GetItemIcon(ns.RUNE_TELEPORT_ID))

    local teleRuneText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    teleRuneText:SetPoint("LEFT", teleRuneIcon, "RIGHT", 5, 0)
    SetFontColor(teleRuneText, C.textMuted)

    local portalRuneText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    portalRuneText:SetPoint("BOTTOMRIGHT", -COLUMN_INSET, 26)
    portalRuneText:SetJustifyH("RIGHT")
    SetFontColor(portalRuneText, C.textMuted)

    local portalRuneIcon = frame:CreateTexture(nil, "ARTWORK")
    portalRuneIcon:SetSize(16, 16)
    portalRuneIcon:SetPoint("RIGHT", portalRuneText, "LEFT", -5, 0)
    portalRuneIcon:SetTexture(ns.GetItemIcon(ns.RUNE_PORTAL_ID))

    local function UpdateRuneCount()
        local teleCount = GetItemCount(ns.RUNE_TELEPORT_ID) or 0
        local portalCount = GetItemCount(ns.RUNE_PORTAL_ID) or 0
        teleRuneText:SetText(string.format(L["RUNE_OF_TELEPORTATION"], teleCount))
        portalRuneText:SetText(string.format(L["RUNE_OF_PORTALS"], portalCount))
    end
    UpdateRuneCount()

    local versionText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    versionText:SetPoint("BOTTOMLEFT", 12, 6)
    versionText:SetText("v" .. ns.VERSION)
    SetFontColor(versionText, C.textMuted)

    frame:RegisterEvent("BAG_UPDATE")
    frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    frame:RegisterEvent("UNIT_SPELLCAST_START")
    frame:SetScript("OnEvent", function(_, event, unit, _, spellID)
        if event == "BAG_UPDATE" then
            UpdateRuneCount()
            return
        end
        if unit ~= "player" then
            return
        end
        if event == "UNIT_SPELLCAST_SUCCEEDED" then
            if ns.spellButtons and ns.spellButtons[spellID] then
                MageTeleportsDB.stats = MageTeleportsDB.stats or {}
                MageTeleportsDB.stats[spellID] = (MageTeleportsDB.stats[spellID] or 0) + 1
                if MageTeleportsDB.showCounter then
                    ns.UpdateCounters()
                end
            end
        elseif event == "UNIT_SPELLCAST_START" then
            local info = ns.spellButtons and ns.spellButtons[spellID]
            if info then
                if MageTeleportsDB.announcePortal then
                    ns.AnnounceDestination(info.destKey)
                end
                if MageTeleportsDB.autoClose and not (InCombatLockdown and InCombatLockdown()) then
                    frame:Hide()
                end
            end
        end
    end)

    if not ns.settingsFrame then
        CreateSettingsFrame()
    end

    ns.RefreshDestinationList()
end

function ns.ToggleMainFrame()
    if not ns.mainFrame then
        ns.CreateMainFrame()
    end
    if ns.mainFrame:IsShown() then
        ns.mainFrame:Hide()
    else
        ns.mainFrame:Show()
    end
end
