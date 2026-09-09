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
local FRAME_HEIGHT = 540
local HEADER_BTN_SIZE = 28
local MEDIA = "Interface\\AddOns\\PortalBook\\Media\\"
local ICON_CLOSE = MEDIA .. "Icon_Close"
local ICON_SETTINGS = MEDIA .. "Icon_Settings"

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

local function WireSpellButton(btn, spellID, hoverColor, kindLabel, requiredLevel, sourceKey)
    btn.spellID = spellID
    local known = ns.IsSpellKnown(spellID)
    btn.icon:SetTexture(ns.GetSpellTexture(spellID))
    btn.icon:SetDesaturated(not known)

    if known then
        btn:SetBackdropBorderColor(C.border[1], C.border[2], C.border[3], 1)
        btn:SetAttribute("type", "spell")
        btn:SetAttribute("spell", spellID)
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
            GameTooltip:SetSpellByID(spellID)
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

-- Builds the reusable skeleton of a destination row. Per-destination content is
-- filled in by UpdateDestinationRow so rows can be pooled instead of recreated
-- (WoW never frees frames, so recreating them on every refresh leaks).
local function CreateDestinationRow(parent)
    local row = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    row:SetSize(FRAME_WIDTH - 58, ROW_HEIGHT)
    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = false,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    row:SetBackdropBorderColor(C.border[1], C.border[2], C.border[3], 0.5)

    local teleBtn = CreateIconButton(row, ICON_SIZE)
    teleBtn:SetPoint("LEFT", 6, 0)
    row.teleBtn = teleBtn

    local teleCounter = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    teleCounter:SetPoint("LEFT", teleBtn, "RIGHT", 6, 0)
    teleCounter:SetWidth(36)
    teleCounter:SetJustifyH("LEFT")
    SetFontColor(teleCounter, C.accent)
    row.teleCounter = teleCounter

    local portalSlot = CreateFrame("Frame", nil, row)
    portalSlot:SetSize(ICON_SIZE, ICON_SIZE)
    portalSlot:SetPoint("RIGHT", -4, 0)
    row.portalSlot = portalSlot

    local portalCounter = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    portalCounter:SetPoint("RIGHT", portalSlot, "LEFT", -6, 0)
    portalCounter:SetWidth(36)
    portalCounter:SetJustifyH("RIGHT")
    SetFontColor(portalCounter, C.accentPortal)
    row.portalCounter = portalCounter

    local portalBtn = CreateIconButton(row, ICON_SIZE)
    portalBtn:SetPoint("CENTER", portalSlot, "CENTER")
    row.portalBtn = portalBtn

    local portalPlaceholder = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    portalPlaceholder:SetPoint("CENTER", portalSlot, "CENTER")
    portalPlaceholder:SetText("—")
    SetFontColor(portalPlaceholder, C.textMuted)
    row.portalPlaceholder = portalPlaceholder

    local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameText:SetJustifyH("CENTER")
    nameText:SetWordWrap(false)
    SetFontColor(nameText, C.text)
    row.nameText = nameText

    local statusText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusText:SetJustifyH("CENTER")
    statusText:SetWordWrap(false)
    row.statusText = statusText

    return row
end

local function UpdateDestinationRow(row, dest, index)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 8, -((index - 1) * (ROW_HEIGHT + ROW_GAP)))

    local teleKnown = ns.IsSpellKnown(dest.teleport)
    local portalKnown = dest.portal and ns.IsSpellKnown(dest.portal)

    WireSpellButton(row.teleBtn, dest.teleport, C.accent, L["TELEPORT"], dest.teleportLevel, dest.source)
    local teleCount = (MageTeleportsDB.stats and MageTeleportsDB.stats[dest.teleport]) or 0
    row.teleCounter:SetText(MageTeleportsDB.showCounter and (teleCount .. "x") or "")

    if dest.portal then
        row.portalBtn:Show()
        row.portalPlaceholder:Hide()
        WireSpellButton(row.portalBtn, dest.portal, C.accentPortal, L["PORTAL"], dest.portalLevel, dest.source)
        local portalCount = (MageTeleportsDB.stats and MageTeleportsDB.stats[dest.portal]) or 0
        row.portalCounter:SetText(MageTeleportsDB.showCounter and (portalCount .. "x") or "")
        ns.RegisterSpellButton(row.portalBtn, dest.portal, row.portalCounter, dest.key)
    else
        row.portalBtn:Hide()
        row.portalBtn:SetAttribute("type", nil)
        row.portalBtn:SetAttribute("spell", nil)
        row.portalPlaceholder:Show()
        row.portalCounter:SetText("")
    end

    row.nameText:SetText(L[dest.key] or dest.key)
    row.nameText:ClearAllPoints()
    row.statusText:ClearAllPoints()

    local knownAny = teleKnown or portalKnown
    local fullyKnown = teleKnown and (not dest.portal or portalKnown)
    if not fullyKnown then
        row.nameText:SetPoint("LEFT", row.teleCounter, "RIGHT", 8, 7)
        row.nameText:SetPoint("RIGHT", row.portalCounter, "LEFT", -8, 7)
        row.statusText:SetPoint("LEFT", row.teleCounter, "RIGHT", 8, -8)
        row.statusText:SetPoint("RIGHT", row.portalCounter, "LEFT", -8, -8)

        local teleNeed = (not teleKnown) and dest.teleportLevel or nil
        local portalNeed = (dest.portal and not portalKnown) and dest.portalLevel or nil
        if teleNeed and portalNeed and teleNeed ~= portalNeed then
            row.statusText:SetText(string.format(L["LEVEL_SPLIT"], teleNeed, portalNeed))
        else
            local level = teleNeed or portalNeed
            if level then
                row.statusText:SetText(string.format(L["LEVEL_SHORT"], level))
            else
                row.statusText:SetText(L["NOT_LEARNED"])
            end
        end
        SetFontColor(row.statusText, { 1, 0.7, 0.35 })
    else
        row.nameText:SetPoint("LEFT", row.teleCounter, "RIGHT", 8, 0)
        row.nameText:SetPoint("RIGHT", row.portalCounter, "LEFT", -8, 0)
        row.statusText:SetText("")
    end

    ns.RegisterSpellButton(row.teleBtn, dest.teleport, row.teleCounter, dest.key)

    if not knownAny then
        row:SetBackdropColor(0.08, 0.07, 0.08, 0.75)
        row.nameText:SetAlpha(0.85)
    else
        row:SetBackdropColor(C.row[1], C.row[2], C.row[3], 0.9)
        row.nameText:SetAlpha(1)
    end
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

function ns.AnnounceDestination(destKey)
    if not MageTeleportsDB.announcePortal then
        return
    end
    if not IsInGroup() then
        return
    end
    -- Always announce in English so party/raid members read the same message
    -- regardless of the caster's client locale.
    local EN = ns.enL or L
    local destination = EN[destKey] or L[destKey] or destKey
    local message = string.format(EN["ANNOUNCE_MSG"] or "Open a Portal to %s", destination)
    if IsInRaid() then
        SendChatMessage(message, "RAID")
    else
        SendChatMessage(message, "PARTY")
    end
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

function ns.RefreshDestinationList()
    local frame = ns.mainFrame
    if not frame or not frame.scrollChild then
        return
    end

    if InCombatLockdown() then
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

    local faction = UnitFactionGroup("player")
    local expansion = frame.activeExpansion
    if not expansion then
        for _, row in ipairs(frame.rows) do
            row:Hide()
        end
        frame.scrollChild:SetHeight(1)
        return
    end

    local destinations = ns.GetVisibleDestinations(
        faction,
        expansion,
        MageTeleportsDB.showOnlyLearned,
        frame.searchText
    )

    for i, dest in ipairs(destinations) do
        local row = frame.rows[i]
        if not row then
            row = CreateDestinationRow(frame.scrollChild)
            frame.rows[i] = row
        end
        UpdateDestinationRow(row, dest, i)
        row:Show()
    end

    for i = #destinations + 1, #frame.rows do
        frame.rows[i]:Hide()
    end

    local contentHeight = math.max(#destinations * (ROW_HEIGHT + ROW_GAP), 1)
    frame.scrollChild:SetHeight(contentHeight)
    frame.scrollFrame:SetVerticalScroll(0)
end

local function CreateTabBar(parent)
    local tabScroll = CreateFrame("ScrollFrame", nil, parent)
    tabScroll:SetPoint("TOPLEFT", 12, -74)
    tabScroll:SetPoint("TOPRIGHT", -12, -74)
    tabScroll:SetHeight(26)
    parent.tabScroll = tabScroll

    local tabBar = CreateFrame("Frame", nil, tabScroll)
    tabBar:SetHeight(26)
    tabBar:SetWidth(1)
    tabScroll:SetScrollChild(tabBar)
    parent.tabBar = tabBar
    parent.tabs = {}

    tabScroll:EnableMouseWheel(true)
    tabScroll:SetScript("OnMouseWheel", function(self, delta)
        local maxX = math.max(tabBar:GetWidth() - self:GetWidth(), 0)
        local cur = self:GetHorizontalScroll()
        self:SetHorizontalScroll(math.min(math.max(cur - delta * 40, 0), maxX))
    end)

    return tabBar
end

local function SelectTab(frame, expansion)
    frame.activeExpansion = expansion
    for id, tab in pairs(frame.tabs) do
        if id == expansion then
            tab:SetBackdropColor(C.accent[1], C.accent[2], C.accent[3], 0.35)
            tab:SetBackdropBorderColor(C.accent[1], C.accent[2], C.accent[3], 0.9)
            SetFontColor(tab.label, C.text)
        else
            tab:SetBackdropColor(0.08, 0.09, 0.11, 0.9)
            tab:SetBackdropBorderColor(C.border[1], C.border[2], C.border[3], 0.7)
            SetFontColor(tab.label, C.textMuted)
        end
    end
    ns.RefreshDestinationList()
end

function ns.RebuildTabs()
    local frame = ns.mainFrame
    if not frame or not frame.tabBar then
        return
    end

    if InCombatLockdown() then
        if not ns.pendingRebuild then
            ns.pendingRebuild = true
            local defer = CreateFrame("Frame")
            defer:RegisterEvent("PLAYER_REGEN_ENABLED")
            defer:SetScript("OnEvent", function(self)
                self:UnregisterAllEvents()
                ns.pendingRebuild = false
                ns.RebuildTabs()
            end)
        end
        return
    end

    for _, tab in pairs(frame.tabs) do
        tab:Hide()
        tab:SetParent(nil)
    end
    frame.tabs = {}

    local faction = UnitFactionGroup("player")
    local expansions = ns.GetAvailableExpansions(faction, MageTeleportsDB.showOnlyLearned)
    local x = 0

    for _, expansion in ipairs(expansions) do
        local tab = CreateFrame("Button", nil, frame.tabBar, "BackdropTemplate")
        tab:SetHeight(24)
        tab:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            tile = false,
            edgeSize = 1,
            insets = { left = 0, right = 0, top = 0, bottom = 0 },
        })

        local labelKey = ns.EXPANSION_LABELS[expansion]
        local label = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("CENTER", 0, 0)
        label:SetText(L[labelKey] or expansion)
        tab.label = label

        local width = math.max(label:GetStringWidth() + 16, 48)
        tab:SetWidth(width)
        tab:SetPoint("LEFT", frame.tabBar, "LEFT", x, 0)
        x = x + width + 4

        tab:SetScript("OnClick", function()
            SelectTab(frame, expansion)
        end)

        frame.tabs[expansion] = tab
    end

    frame.tabBar:SetWidth(math.max(x, frame.tabScroll:GetWidth()))
    frame.tabScroll:SetHorizontalScroll(0)

    local preferred = "ALL"
    if frame.activeExpansion and frame.tabs[frame.activeExpansion] then
        preferred = frame.activeExpansion
    end
    if frame.tabs[preferred] then
        SelectTab(frame, preferred)
    elseif frame.tabs.ALL then
        SelectTab(frame, "ALL")
    elseif expansions[1] then
        SelectTab(frame, expansions[1])
    else
        ns.RefreshDestinationList()
    end
end

function ns.CreateMainFrame()
    if ns.mainFrame then
        ns.mainFrame:UnregisterAllEvents()
        ns.mainFrame:Hide()
        ns.mainFrame:SetParent(nil)
        ns.mainFrame = nil
    end

    local frame = CreateFrame("Frame", "MageTeleportsFrame", UIParent, "BackdropTemplate")
    frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    frame:SetClampedToScreen(true)
    frame:Hide()
    ApplyBackdrop(frame)
    ns.mainFrame = frame
    MageTeleportsFrame = frame
    frame:SetScale((MageTeleportsDB and MageTeleportsDB.scale) or 1.0)

    if not tContains(UISpecialFrames, "MageTeleportsFrame") then
        tinsert(UISpecialFrames, "MageTeleportsFrame")
    end

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
    closeBtn:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(CLOSE or "Close", 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)

    local settingsBtn = CreateTitlebarButton(frame, ICON_SETTINGS, 12, false)
    settingsBtn:SetPoint("RIGHT", closeBtn, "LEFT", 0, 0)
    settingsBtn:SetScript("OnClick", function()
        ns.ToggleSettingsFrame()
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


    local searchBox = CreateFrame("EditBox", nil, frame, "BackdropTemplate")
    searchBox:SetPoint("TOPLEFT", 12, -42)
    searchBox:SetPoint("TOPRIGHT", -12, -42)
    searchBox:SetHeight(24)
    searchBox:SetAutoFocus(false)
    searchBox:SetFontObject("GameFontHighlight")
    searchBox:SetTextInsets(8, 28, 0, 0)
    searchBox:SetMaxLetters(40)
    searchBox:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = false,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    searchBox:SetBackdropColor(0.04, 0.05, 0.07, 0.95)
    searchBox:SetBackdropBorderColor(C.border[1], C.border[2], C.border[3], 0.9)
    frame.searchBox = searchBox
    frame.searchText = ""

    local searchPlaceholder = searchBox:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    searchPlaceholder:SetPoint("LEFT", 8, 0)
    searchPlaceholder:SetText(L["SEARCH"])
    SetFontColor(searchPlaceholder, C.textMuted)

    local clearSearchBtn = CreateTitlebarButton(searchBox, ICON_CLOSE, 9, true)
    clearSearchBtn:SetPoint("RIGHT", -2, 0)
    clearSearchBtn:SetSize(20, 20)
    clearSearchBtn:Hide()
    local searchTimer

    local function CancelSearchTimer()
        if searchTimer then
            searchTimer:Cancel()
            searchTimer = nil
        end
    end

    local function RunSearch()
        searchTimer = nil
        local text = strtrim(searchBox:GetText() or "")
        frame.searchText = text
        if text ~= "" and frame.activeExpansion ~= "ALL" and frame.tabs.ALL then
            SelectTab(frame, "ALL")
        else
            ns.RefreshDestinationList()
        end
    end

    -- Placeholder / clear button update instantly; the (expensive) list rebuild
    -- is debounced so it does not run on every keystroke.
    local function ApplySearchText(immediate)
        local text = strtrim(searchBox:GetText() or "")
        if text == "" then
            searchPlaceholder:Show()
            clearSearchBtn:Hide()
        else
            searchPlaceholder:Hide()
            clearSearchBtn:Show()
        end
        CancelSearchTimer()
        if immediate then
            RunSearch()
        else
            searchTimer = C_Timer.NewTimer(0.2, RunSearch)
        end
    end

    clearSearchBtn:SetScript("OnClick", function()
        CancelSearchTimer()
        searchBox:SetText("")
        searchBox:ClearFocus()
        frame.searchText = ""
        searchPlaceholder:Show()
        clearSearchBtn:Hide()
        ns.RefreshDestinationList()
    end)

    searchBox:SetScript("OnTextChanged", function(self, userInput)
        if userInput then
            ApplySearchText(false)
        end
    end)
    searchBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
        ApplySearchText(true)
    end)
    searchBox:SetScript("OnEscapePressed", function(self)
        self:SetText("")
        self:ClearFocus()
        ApplySearchText(true)
    end)
    searchBox:SetScript("OnEditFocusGained", function()
        searchPlaceholder:Hide()
    end)
    searchBox:SetScript("OnEditFocusLost", function()
        if (searchBox:GetText() or "") == "" then
            searchPlaceholder:Show()
        end
    end)

    CreateTabBar(frame)

    local columnHeader = CreateFrame("Frame", nil, frame)
    columnHeader:SetPoint("TOPLEFT", 12, -104)
    columnHeader:SetPoint("TOPRIGHT", -30, -104)
    columnHeader:SetHeight(16)
    frame.columnHeader = columnHeader

    local teleHeader = columnHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    teleHeader:SetPoint("LEFT", 14, 0)
    teleHeader:SetText(L["TELEPORTS"])
    SetFontColor(teleHeader, C.accent)

    local portalHeader = columnHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    portalHeader:SetPoint("RIGHT", -14, 0)
    portalHeader:SetText(L["PORTALS"])
    SetFontColor(portalHeader, C.accentPortal)

    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 12, -122)
    scrollFrame:SetPoint("BOTTOMRIGHT", -34, 36)
    frame.scrollFrame = scrollFrame

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(FRAME_WIDTH - 58, 1)
    scrollFrame:SetScrollChild(scrollChild)
    frame.scrollChild = scrollChild

    local versionText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    versionText:SetPoint("BOTTOMLEFT", 12, 12)
    versionText:SetText("v" .. ns.VERSION)
    SetFontColor(versionText, C.textMuted)

    frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    frame:RegisterEvent("UNIT_SPELLCAST_START")
    frame:RegisterEvent("SPELLS_CHANGED")
    frame:SetScript("OnEvent", function(_, event, unit, _, spellID)
        if event == "SPELLS_CHANGED" then
            ns.ScheduleSpellRefresh()
            return
        end
        if unit ~= "player" then
            return
        end
        local entry = ns.BuildSpellIndex()[spellID]
        if not entry then
            return
        end
        if event == "UNIT_SPELLCAST_SUCCEEDED" then
            MageTeleportsDB.stats = MageTeleportsDB.stats or {}
            MageTeleportsDB.stats[spellID] = (MageTeleportsDB.stats[spellID] or 0) + 1
            if MageTeleportsDB.showCounter then
                ns.UpdateCounters()
            end
        elseif event == "UNIT_SPELLCAST_START" then
            if MageTeleportsDB.announcePortal and entry.isPortal then
                ns.AnnounceDestination(entry.destKey)
            end
            if MageTeleportsDB.autoClose and not InCombatLockdown() then
                frame:Hide()
            end
        end
    end)

    ns.CreateSettingsFrame()

    frame.activeExpansion = "ALL"
    ns.RebuildTabs()
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
