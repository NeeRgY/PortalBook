local _, ns = ...
local L = ns.L

-- Palette is defined by the loaded UI file (Retail\UI.lua or Classic\UI.lua).
local C = ns.Colors or {
    bg = { 0.06, 0.07, 0.10 },
    row = { 0.10, 0.11, 0.14 },
    border = { 0.25, 0.28, 0.35 },
    accent = { 0.35, 0.75, 0.95 },
    accentPortal = { 0.55, 0.45, 0.95 },
    textMuted = { 0.55, 0.58, 0.65 },
    text = { 0.90, 0.92, 0.95 },
    dangerMuted = { 0.45, 0.20, 0.22 },
}

local MEDIA = "Interface\\AddOns\\PortalBook\\Media\\"
local ICON_CLOSE = MEDIA .. "Icon_Close"
local WHITE = "Interface\\Buttons\\WHITE8X8"

--------------------------------------------------------------------------------
-- Changelog / About content
--------------------------------------------------------------------------------

-- Newest first. Rendered read-only in the Changelog popup; kept in English so it
-- reads the same in every locale (matching the addon-site changelog).
ns.CHANGELOG = {
    {
        version = "2.1.0",
        notes = {
            "Newly learned portals and teleports now show up in the window immediately.",
            "The usage counter records every portal/teleport cast now - including casts from the spellbook and from outside the active tab.",
            "Party/raid announce only fires for portals now, no longer for self-teleports, and always posts in English so everyone reads the same message.",
            "The destination list is reused instead of rebuilt on every change (no more frame leak).",
            "The location search is debounced - no more stutter while typing.",
            "The window can be closed with Esc.",
            "The minimap icon uses the bundled artwork.",
            "Added chat command: /pb.",
            "Translations tidied up and completed; localized addon description.",
            "Options window reworked: fully custom checkboxes, sliders and dropdown, a window-scale slider, an in-game language selector, a minimap-icon toggle, and Changelog and About sections.",
            "Added Italian and Latin-American Spanish translations; the language selector can force any of them regardless of the game client's language.",
        },
    },
    {
        version = "2.0.0",
        notes = {
            "Baseline version prior to the changes listed above.",
        },
    },
}

ns.ABOUT = {
    author = "NeRgY",
    links = {
        { label = "Discord",    url = "https://discord.gg/YjfyDKckCS",                     color = { 0.345, 0.396, 0.949 } },
        { label = "CurseForge", url = "https://www.curseforge.com/wow/addons/portal-book", color = { 0.945, 0.392, 0.212 } },
        { label = "GitHub",     url = "https://github.com/NeeRgY/PortalBook",              color = { 0.55, 0.55, 0.60 } },
        { label = "Wago",       url = "https://addons.wago.io/addons/portalbook",          color = { 0.788, 0.310, 0.996 } },
        { label = "Ko-fi",      url = "https://ko-fi.com/neergy",                          color = { 1.000, 0.370, 0.360 } },
    },
}

--------------------------------------------------------------------------------
-- Shared skinning helpers
--------------------------------------------------------------------------------

local function SetFontColor(fs, color)
    fs:SetTextColor(color[1], color[2], color[3], 1)
end

local function SkinDialog(frame, alpha)
    frame:SetBackdrop({
        bgFile = WHITE,
        edgeFile = WHITE,
        tile = false,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    frame:SetBackdropColor(C.bg[1], C.bg[2], C.bg[3], alpha or 0.97)
    frame:SetBackdropBorderColor(C.accent[1], C.accent[2], C.accent[3], 0.6)
end

local function MakeDraggable(frame)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
end

local function AddTitle(frame, text)
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOPLEFT", 14, -12)
    title:SetText(text)
    SetFontColor(title, C.text)

    local underline = frame:CreateTexture(nil, "ARTWORK")
    underline:SetColorTexture(C.accent[1], C.accent[2], C.accent[3], 0.7)
    underline:SetHeight(1)
    underline:SetPoint("TOPLEFT", 12, -34)
    underline:SetPoint("TOPRIGHT", -12, -34)
    return title
end

local function AddCloseButton(frame, onClick)
    local btn = CreateFrame("Button", nil, frame)
    btn:SetSize(24, 24)
    btn:SetPoint("TOPRIGHT", -4, -4)

    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(1, 1, 1, 0)

    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("CENTER")
    icon:SetSize(10, 10)
    icon:SetTexture(ICON_CLOSE)
    icon:SetVertexColor(0.7, 0.7, 0.7, 1)

    btn:SetScript("OnEnter", function()
        icon:SetVertexColor(1, 1, 1, 1)
        bg:SetColorTexture(1, 0, 0, 0.2)
    end)
    btn:SetScript("OnLeave", function()
        icon:SetVertexColor(0.7, 0.7, 0.7, 1)
        bg:SetColorTexture(1, 1, 1, 0)
    end)
    btn:SetScript("OnClick", onClick)
    return btn
end

local function SectionHeader(parent, text)
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fs:SetText(string.upper(text))
    SetFontColor(fs, C.textMuted)
    return fs
end

local function ThemedButton(parent, text, tint)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetHeight(24)
    btn:SetBackdrop({
        bgFile = WHITE,
        edgeFile = WHITE,
        tile = false,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })

    local col = tint or C.accent
    local function base()
        btn:SetBackdropColor(col[1] * 0.22, col[2] * 0.22, col[3] * 0.22, 0.85)
    end
    local function hover()
        btn:SetBackdropColor(col[1] * 0.42, col[2] * 0.42, col[3] * 0.42, 0.95)
    end
    base()
    btn:SetBackdropBorderColor(col[1], col[2], col[3], 0.7)

    local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fs:SetPoint("CENTER")
    fs:SetText(text)
    SetFontColor(fs, C.text)
    btn.label = fs

    btn:HookScript("OnEnter", hover)
    btn:HookScript("OnLeave", base)
    return btn
end

--------------------------------------------------------------------------------
-- Themed checkbox (matches the row / icon-button look, no Blizzard art)
--------------------------------------------------------------------------------

-- Returns a CheckButton plus a `.label` FontString and a wide `.hit` button so
-- the whole label row toggles. get()/set() default to a MageTeleportsDB key.
local function CreateCheckbox(parent, labelText, dbKey, onChange)
    local BOX = 18

    local cb = CreateFrame("CheckButton", nil, parent)
    cb:SetSize(BOX, BOX)

    local box = cb:CreateTexture(nil, "BACKGROUND")
    box:SetAllPoints()
    box:SetColorTexture(C.row[1], C.row[2], C.row[3], 1)

    local border = CreateFrame("Frame", nil, cb, "BackdropTemplate")
    border:SetPoint("TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", 1, -1)
    border:SetBackdrop({ edgeFile = WHITE, edgeSize = 1 })
    border:SetBackdropBorderColor(C.border[1], C.border[2], C.border[3], 1)
    cb.border = border

    local checked = cb:CreateTexture(nil, "ARTWORK")
    checked:SetPoint("TOPLEFT", 4, -4)
    checked:SetPoint("BOTTOMRIGHT", -4, 4)
    checked:SetColorTexture(C.accent[1], C.accent[2], C.accent[3], 1)
    cb.checkedTex = checked

    local highlight = cb:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetColorTexture(C.accent[1], C.accent[2], C.accent[3], 0.12)

    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", cb, "RIGHT", 8, 0)
    label:SetText(labelText)
    SetFontColor(label, C.text)
    cb.label = label

    local hit = CreateFrame("Button", nil, parent)
    hit:SetPoint("TOPLEFT", cb, "TOPLEFT")
    hit:SetPoint("BOTTOMRIGHT", label, "BOTTOMRIGHT", 4, -2)
    hit:SetScript("OnClick", function()
        cb:Click()
    end)
    hit:SetScript("OnEnter", function()
        cb.border:SetBackdropBorderColor(C.accent[1], C.accent[2], C.accent[3], 1)
    end)
    hit:SetScript("OnLeave", function()
        cb.border:SetBackdropBorderColor(C.border[1], C.border[2], C.border[3], 1)
    end)
    cb.hit = hit

    cb:SetScript("OnEnter", function(self)
        self.border:SetBackdropBorderColor(C.accent[1], C.accent[2], C.accent[3], 1)
    end)
    cb:SetScript("OnLeave", function(self)
        self.border:SetBackdropBorderColor(C.border[1], C.border[2], C.border[3], 1)
    end)

    cb:SetChecked(MageTeleportsDB[dbKey] and true or false)
    checked:SetShown(cb:GetChecked())
    cb:SetScript("OnClick", function(self)
        local on = self:GetChecked() and true or false
        MageTeleportsDB[dbKey] = on
        self.checkedTex:SetShown(on)
        if onChange then
            onChange()
        end
    end)

    return cb
end

--------------------------------------------------------------------------------
-- Themed dropdown
--------------------------------------------------------------------------------

-- options = { { value = ..., label = ... }, ... }
-- Returns a Frame (label on top, dropdown button below). `.Refresh()` re-reads.
local function CreateDropdown(parent, labelText, options, getValue, onSelect)
    local wrap = CreateFrame("Frame", nil, parent)
    wrap:SetHeight(40)

    local label = wrap:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("TOPLEFT", 0, 0)
    label:SetText(labelText)
    SetFontColor(label, C.text)

    local button = CreateFrame("Button", nil, wrap, "BackdropTemplate")
    button:SetPoint("TOPLEFT", 0, -16)
    button:SetPoint("TOPRIGHT", 0, -16)
    button:SetHeight(22)
    button:SetBackdrop({
        bgFile = WHITE,
        edgeFile = WHITE,
        tile = false,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    button:SetBackdropColor(C.row[1], C.row[2], C.row[3], 0.9)
    button:SetBackdropBorderColor(C.border[1], C.border[2], C.border[3], 1)

    local current = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    current:SetPoint("LEFT", 8, 0)
    current:SetPoint("RIGHT", -20, 0)
    current:SetJustifyH("LEFT")
    SetFontColor(current, C.text)

    local caret = button:CreateTexture(nil, "ARTWORK")
    caret:SetSize(12, 12)
    caret:SetPoint("RIGHT", -6, -2)
    caret:SetTexture("Interface\\Buttons\\Arrow-Down-Down")
    caret:SetVertexColor(C.textMuted[1], C.textMuted[2], C.textMuted[3], 1)

    local menu = CreateFrame("Frame", nil, button, "BackdropTemplate")
    menu:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -2)
    menu:SetPoint("TOPRIGHT", button, "BOTTOMRIGHT", 0, -2)
    menu:SetFrameStrata("FULLSCREEN_DIALOG")
    menu:SetBackdrop({
        bgFile = WHITE,
        edgeFile = WHITE,
        tile = false,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    menu:SetBackdropColor(C.bg[1], C.bg[2], C.bg[3], 0.98)
    menu:SetBackdropBorderColor(C.accent[1], C.accent[2], C.accent[3], 0.75)
    menu:Hide()

    local ROW = 20
    for i, opt in ipairs(options) do
        local row = CreateFrame("Button", nil, menu)
        row:SetHeight(ROW)
        row:SetPoint("TOPLEFT", 3, -3 - (i - 1) * ROW)
        row:SetPoint("TOPRIGHT", -3, -3 - (i - 1) * ROW)

        local hl = row:CreateTexture(nil, "BACKGROUND")
        hl:SetAllPoints()
        hl:SetColorTexture(C.accent[1], C.accent[2], C.accent[3], 0)

        local marker = row:CreateTexture(nil, "ARTWORK")
        marker:SetSize(3, ROW - 8)
        marker:SetPoint("LEFT", 2, 0)
        marker:SetColorTexture(C.accent[1], C.accent[2], C.accent[3], 1)
        row.marker = marker

        local rt = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        rt:SetPoint("LEFT", 10, 0)
        rt:SetText(opt.label)
        SetFontColor(rt, C.text)

        row.value = opt.value
        row:SetScript("OnEnter", function()
            hl:SetColorTexture(C.accent[1], C.accent[2], C.accent[3], 0.2)
        end)
        row:SetScript("OnLeave", function()
            hl:SetColorTexture(C.accent[1], C.accent[2], C.accent[3], 0)
        end)
        row:SetScript("OnClick", function()
            menu:Hide()
            onSelect(opt.value)
        end)
        menu[i] = row
    end
    menu:SetHeight(#options * ROW + 6)

    local function Refresh()
        local v = getValue()
        current:SetText("")
        for i, opt in ipairs(options) do
            local on = (opt.value == v)
            if on then
                current:SetText(opt.label)
            end
            if menu[i] then
                menu[i].marker:SetShown(on)
            end
        end
    end

    local closer = CreateFrame("Frame", nil, wrap)
    closer:Hide()
    closer:SetScript("OnMouseDown", function()
        menu:Hide()
    end)

    menu:SetScript("OnShow", function(self)
        closer:SetAllPoints(UIParent)
        closer:SetFrameStrata("FULLSCREEN_DIALOG")
        closer:SetFrameLevel(math.max(self:GetFrameLevel() - 1, 1))
        closer:EnableMouse(true)
        closer:Show()
        self:Raise()
    end)
    menu:SetScript("OnHide", function()
        closer:Hide()
    end)

    button:SetScript("OnClick", function()
        if menu:IsShown() then
            menu:Hide()
        else
            Refresh()
            menu:Show()
        end
    end)
    button:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(C.accent[1], C.accent[2], C.accent[3], 1)
    end)
    button:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(C.border[1], C.border[2], C.border[3], 1)
    end)
    wrap:SetScript("OnShow", Refresh)
    wrap:SetScript("OnHide", function()
        menu:Hide()
    end)

    Refresh()
    wrap.Refresh = Refresh
    return wrap
end

--------------------------------------------------------------------------------
-- Themed slider
--------------------------------------------------------------------------------

-- opts = { name, labelText, minV, maxV, step, get(), onChange(v), format(v) }
local function CreateSlider(parent, opts)
    local wrap = CreateFrame("Frame", nil, parent)
    wrap:SetHeight(34)

    local label = wrap:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("TOPLEFT", 0, 0)
    label:SetText(opts.labelText)
    SetFontColor(label, C.text)

    local value = wrap:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    value:SetPoint("TOPRIGHT", 0, 0)
    SetFontColor(value, C.accent)

    local slider = CreateFrame("Slider", opts.name, wrap)
    slider:SetOrientation("HORIZONTAL")
    slider:SetPoint("TOPLEFT", 0, -16)
    slider:SetPoint("TOPRIGHT", 0, -16)
    slider:SetHeight(16)
    slider:SetMinMaxValues(opts.minV, opts.maxV)
    slider:SetValueStep(opts.step)
    slider:SetObeyStepOnDrag(true)
    slider:SetHitRectInsets(0, 0, -6, -6)

    local track = slider:CreateTexture(nil, "BACKGROUND")
    track:SetColorTexture(C.row[1], C.row[2], C.row[3], 1)
    track:SetPoint("LEFT")
    track:SetPoint("RIGHT")
    track:SetHeight(5)

    local trackBorder = slider:CreateTexture(nil, "BORDER")
    trackBorder:SetColorTexture(C.border[1], C.border[2], C.border[3], 0.7)
    trackBorder:SetPoint("TOPLEFT", track, "TOPLEFT", -1, 1)
    trackBorder:SetPoint("BOTTOMRIGHT", track, "BOTTOMRIGHT", 1, -1)

    local fill = slider:CreateTexture(nil, "ARTWORK")
    fill:SetColorTexture(C.accent[1], C.accent[2], C.accent[3], 0.9)
    fill:SetPoint("TOPLEFT", track, "TOPLEFT")
    fill:SetPoint("BOTTOMLEFT", track, "BOTTOMLEFT")

    local thumb = slider:CreateTexture(nil, "OVERLAY")
    thumb:SetColorTexture(C.text[1], C.text[2], C.text[3], 1)
    thumb:SetSize(4, 16)
    slider:SetThumbTexture(thumb)

    local function Redraw(v)
        local w = slider:GetWidth()
        if not w or w <= 0 then
            w = 240
        end
        local pct = (v - opts.minV) / (opts.maxV - opts.minV)
        fill:SetWidth(math.max(1, pct * w))
        value:SetText(opts.format(v))
    end

    slider:SetScript("OnValueChanged", function(_, v)
        opts.onChange(v)
        Redraw(v)
    end)
    slider:SetScript("OnSizeChanged", function()
        Redraw(slider:GetValue())
    end)
    wrap:SetScript("OnShow", function()
        local v = opts.get()
        slider:SetValue(v)
        Redraw(v)
    end)

    slider:SetValue(opts.get())
    Redraw(opts.get())

    wrap.slider = slider
    return wrap
end

--------------------------------------------------------------------------------
-- Window scale
--------------------------------------------------------------------------------

-- Applies the saved scale to the main window and every popup that exists.
function ns.ApplyScale(value)
    value = value or MageTeleportsDB.scale or 1.0
    MageTeleportsDB.scale = value
    local frames = { ns.mainFrame, ns.settingsFrame, ns.changelogFrame, ns.aboutFrame }
    for _, f in ipairs(frames) do
        if f and f.SetScale then
            f:SetScale(value)
        end
    end
end

--------------------------------------------------------------------------------
-- Language switching
--------------------------------------------------------------------------------

ns.LOCALE_OPTIONS = {
    { value = "auto", label = nil }, -- label filled in from L["LOCALE_AUTO"] at build time
    { value = "enUS", label = "English" },
    { value = "deDE", label = "Deutsch" },
    { value = "esES", label = "Español (EU)" },
    { value = "esMX", label = "Español (AL)" },
    { value = "frFR", label = "Français" },
    { value = "itIT", label = "Italiano" },
    { value = "ruRU", label = "Русский" },
}

-- Rebuilds every window so freshly-loaded strings take effect. The main frame
-- and settings frame are torn down and recreated; popups are dropped so they
-- rebuild on next open. Deferred out of combat (creates secure buttons).
function ns.RebuildForLocale()
    if InCombatLockdown() then
        if not ns.localeRebuildPending then
            ns.localeRebuildPending = true
            local defer = CreateFrame("Frame")
            defer:RegisterEvent("PLAYER_REGEN_ENABLED")
            defer:SetScript("OnEvent", function(self)
                self:UnregisterAllEvents()
                ns.localeRebuildPending = false
                ns.RebuildForLocale()
            end)
        end
        return
    end

    if ns.changelogFrame then
        ns.changelogFrame:Hide()
        ns.changelogFrame = nil
    end
    if ns.aboutFrame then
        ns.aboutFrame:Hide()
        ns.aboutFrame = nil
    end

    local settingsShown = ns.settingsFrame and ns.settingsFrame:IsShown()
    if ns.settingsFrame then
        ns.settingsFrame:Hide()
        ns.settingsFrame:SetParent(nil)
        ns.settingsFrame = nil
    end

    if ns.mainFrame then
        local mainShown = ns.mainFrame:IsShown()
        ns.CreateMainFrame() -- full teardown + rebuild; also recreates the settings frame
        if mainShown then
            ns.mainFrame:Show()
        end
    end

    if not ns.settingsFrame then
        ns.CreateSettingsFrame()
    end
    if settingsShown and ns.settingsFrame then
        ns.settingsFrame:Show()
    end

    ns.ApplyScale()
end

function ns.SetLocale(code)
    MageTeleportsDB.locale = code or "auto"
    ns.ApplyLocale()
    C_Timer.After(0, ns.RebuildForLocale)
end

--------------------------------------------------------------------------------
-- Copy-link popup (shared by the About links)
--------------------------------------------------------------------------------

StaticPopupDialogs["PORTALBOOK_COPY_LINK"] = {
    text = "%s",
    button1 = CLOSE,
    hasEditBox = true,
    editBoxWidth = 340,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
    OnShow = function(self, data)
        local eb = self.editBox or (self.GetEditBox and self:GetEditBox())
        if not eb then
            return
        end
        eb:SetText(data or "")
        eb:HighlightText()
        eb:SetFocus()
    end,
    EditBoxOnEscapePressed = function(eb)
        eb:GetParent():Hide()
    end,
    EditBoxOnEnterPressed = function(eb)
        eb:GetParent():Hide()
    end,
    EditBoxOnTextChanged = function(eb, data)
        if eb:GetText() ~= data then
            eb:SetText(data)
            eb:HighlightText()
        end
    end,
}

--------------------------------------------------------------------------------
-- Changelog popup
--------------------------------------------------------------------------------

local function BuildChangelogFrame()
    local f = CreateFrame("Frame", "MageTeleportsChangelogFrame", UIParent, "BackdropTemplate")
    f:SetSize(440, 470)
    f:SetPoint("CENTER")
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:SetToplevel(true)
    f:SetClampedToScreen(true)
    f:SetScale(MageTeleportsDB.scale or 1.0)
    f:Hide()
    SkinDialog(f)
    MakeDraggable(f)

    AddTitle(f, L["CHANGELOG"])
    AddCloseButton(f, function() f:Hide() end)

    local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 14, -44)
    scroll:SetPoint("BOTTOMRIGHT", -32, 14)

    local wrapWidth = 440 - 14 - 32 - 12
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(wrapWidth, 1)
    scroll:SetScrollChild(content)

    local y = 4
    for _, entry in ipairs(ns.CHANGELOG) do
        local ver = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        ver:SetPoint("TOPLEFT", 2, -y)
        ver:SetText("v" .. entry.version)
        SetFontColor(ver, C.accent)
        y = y + 24

        for _, note in ipairs(entry.notes) do
            local dot = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            dot:SetPoint("TOPLEFT", 8, -y - 1)
            dot:SetText("\226\128\162")
            SetFontColor(dot, C.textMuted)

            local txt = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            txt:SetPoint("TOPLEFT", 20, -y)
            txt:SetWidth(wrapWidth - 24)
            txt:SetJustifyH("LEFT")
            txt:SetText(note)
            SetFontColor(txt, C.text)
            y = y + math.max(txt:GetStringHeight() + 6, 16)
        end
        y = y + 14
    end
    content:SetHeight(math.max(y, 1))

    if not tContains(UISpecialFrames, "MageTeleportsChangelogFrame") then
        tinsert(UISpecialFrames, "MageTeleportsChangelogFrame")
    end
    return f
end

function ns.ShowChangelog()
    if not ns.changelogFrame then
        ns.changelogFrame = BuildChangelogFrame()
    end
    local f = ns.changelogFrame
    if f:IsShown() then
        f:Hide()
    else
        f:Show()
        f:Raise()
    end
end

--------------------------------------------------------------------------------
-- About popup
--------------------------------------------------------------------------------

local function BuildAboutFrame()
    local WIDTH = 360
    local f = CreateFrame("Frame", "MageTeleportsAboutFrame", UIParent, "BackdropTemplate")
    f:SetSize(WIDTH, 320)
    f:SetPoint("CENTER")
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:SetToplevel(true)
    f:SetClampedToScreen(true)
    f:SetScale(MageTeleportsDB.scale or 1.0)
    f:Hide()
    SkinDialog(f)
    MakeDraggable(f)

    AddTitle(f, L["ABOUT"])
    AddCloseButton(f, function() f:Hide() end)

    local textWidth = WIDTH - 32

    local name = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    name:SetPoint("TOPLEFT", 16, -46)
    name:SetText(L["TITLE"])
    SetFontColor(name, C.text)

    local ver = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    ver:SetPoint("LEFT", name, "RIGHT", 8, 0)
    ver:SetText("v" .. (ns.VERSION or ""))
    SetFontColor(ver, C.textMuted)

    local author = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    author:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -6)
    author:SetText(L["AUTHOR"] .. ":  |cffffffff" .. ns.ABOUT.author .. "|r")
    SetFontColor(author, C.textMuted)

    local body = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    body:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -12)
    body:SetWidth(textWidth)
    body:SetJustifyH("LEFT")
    body:SetText(L["ABOUT_BODY"])
    SetFontColor(body, C.text)

    local linksHdr = SectionHeader(f, L["LINKS"])
    linksHdr:SetPoint("TOPLEFT", body, "BOTTOMLEFT", 0, -16)

    local rowHeight = 22
    local rowGap = 4
    local prev = linksHdr
    for i, link in ipairs(ns.ABOUT.links) do
        local row = CreateFrame("Button", nil, f, "BackdropTemplate")
        row:SetHeight(rowHeight)
        row:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", (i == 1 and -1 or 0), (i == 1 and -8 or -rowGap))
        row:SetPoint("RIGHT", f, "RIGHT", -16, 0)
        row:SetBackdrop({
            bgFile = WHITE,
            edgeFile = WHITE,
            tile = false,
            edgeSize = 1,
            insets = { left = 0, right = 0, top = 0, bottom = 0 },
        })
        row:SetBackdropColor(C.row[1], C.row[2], C.row[3], 0.55)
        row:SetBackdropBorderColor(C.border[1], C.border[2], C.border[3], 0.5)

        local dot = row:CreateTexture(nil, "ARTWORK")
        dot:SetSize(8, 8)
        dot:SetPoint("LEFT", 8, 0)
        dot:SetColorTexture(link.color[1], link.color[2], link.color[3], 1)

        local lbl = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:SetPoint("LEFT", dot, "RIGHT", 8, 0)
        lbl:SetText(link.label)
        SetFontColor(lbl, C.text)

        local url = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        url:SetPoint("RIGHT", -8, 0)
        url:SetJustifyH("RIGHT")
        url:SetText(link.url)
        SetFontColor(url, C.textMuted)

        row:SetScript("OnEnter", function(self)
            self:SetBackdropColor(C.row[1] * 1.7, C.row[2] * 1.7, C.row[3] * 1.7, 0.85)
            SetFontColor(url, C.accent)
        end)
        row:SetScript("OnLeave", function(self)
            self:SetBackdropColor(C.row[1], C.row[2], C.row[3], 0.55)
            SetFontColor(url, C.textMuted)
        end)
        row:SetScript("OnClick", function()
            StaticPopup_Show("PORTALBOOK_COPY_LINK", link.label, nil, link.url)
        end)
        prev = row
    end

    local hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 1, -10)
    hint:SetText(L["ABOUT_LINK_HINT"])
    SetFontColor(hint, C.textMuted)

    -- Size the frame to fit its content.
    local bodyLines = math.max(body:GetStringHeight(), 14)
    local total = 46 + 20 + 6 + 14 + 12 + bodyLines + 16 + 12
        + (#ns.ABOUT.links * (rowHeight + rowGap)) + 8 + 16 + 16
    f:SetHeight(math.max(total, 200))

    if not tContains(UISpecialFrames, "MageTeleportsAboutFrame") then
        tinsert(UISpecialFrames, "MageTeleportsAboutFrame")
    end
    return f
end

function ns.ShowAbout()
    if not ns.aboutFrame then
        ns.aboutFrame = BuildAboutFrame()
    end
    local f = ns.aboutFrame
    if f:IsShown() then
        f:Hide()
    else
        f:Show()
        f:Raise()
    end
end

--------------------------------------------------------------------------------
-- Settings frame
--------------------------------------------------------------------------------

function ns.CreateSettingsFrame()
    if ns.settingsFrame then
        return ns.settingsFrame
    end

    local settings = CreateFrame("Frame", "MageTeleportsSettingsFrame", UIParent, "BackdropTemplate")
    settings:SetSize(360, 452)
    settings:SetPoint("CENTER")
    settings:SetClampedToScreen(true)
    settings:SetFrameStrata("DIALOG")
    settings:Hide()
    SkinDialog(settings)
    MakeDraggable(settings)
    ns.settingsFrame = settings

    AddTitle(settings, L["SETTINGS"])
    AddCloseButton(settings, function() settings:Hide() end)

    local function AddCheckbox(anchor, yOff, labelText, dbKey, onChange)
        local cb = CreateCheckbox(settings, labelText, dbKey, onChange)
        cb:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOff)
        return cb
    end

    -- Display section --------------------------------------------------------
    local displayHdr = SectionHeader(settings, L["SECTION_DISPLAY"])
    displayHdr:SetPoint("TOPLEFT", 16, -46)

    local cbCounter = AddCheckbox(displayHdr, -8, L["SHOW_COUNTER"], "showCounter", function()
        ns.UpdateCounters()
    end)

    local resetBtn = ThemedButton(settings, L["RESET_COUNTER"], C.dangerMuted)
    resetBtn:SetSize(58, 20)
    resetBtn:SetPoint("LEFT", cbCounter.label, "RIGHT", 10, 0)
    resetBtn:SetScript("OnClick", function()
        MageTeleportsDB.stats = {}
        ns.UpdateCounters()
    end)
    resetBtn:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["RESET_COUNTER_TOOLTIP"], 1, 1, 1)
        GameTooltip:Show()
    end)
    resetBtn:HookScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    local cbLearned = AddCheckbox(cbCounter, -8, L["SHOW_ONLY_LEARNED"], "showOnlyLearned", function()
        if ns.RebuildTabs then
            ns.RebuildTabs()
        elseif ns.RefreshDestinationList then
            ns.RefreshDestinationList()
        end
    end)
    local cbAuto = AddCheckbox(cbLearned, -8, L["AUTO_CLOSE"], "autoClose")
    local cbAnnounce = AddCheckbox(cbAuto, -8, L["ANNOUNCE_PORTAL"], "announcePortal")

    -- Appearance section ----------------------------------------------------
    local appHdr = SectionHeader(settings, L["SECTION_APPEARANCE"])
    appHdr:SetPoint("TOPLEFT", cbAnnounce, "BOTTOMLEFT", 0, -16)

    local pctFormat = function(v)
        return math.floor(v * 100 + 0.5) .. "%"
    end

    local transpSlider = CreateSlider(settings, {
        name = "MageTeleportsTransparencySlider",
        labelText = L["TRANSPARENCY"],
        minV = 0.3, maxV = 1.0, step = 0.05,
        get = function() return MageTeleportsDB.transparency or 0.95 end,
        format = pctFormat,
        onChange = function(v)
            MageTeleportsDB.transparency = v
            if ns.mainFrame and ns.mainFrame.SetBackdropColor then
                ns.mainFrame:SetBackdropColor(C.bg[1], C.bg[2], C.bg[3], v)
            end
        end,
    })
    transpSlider:SetPoint("TOPLEFT", appHdr, "BOTTOMLEFT", 2, -10)
    transpSlider:SetPoint("RIGHT", settings, "RIGHT", -18, 0)

    local scaleSlider = CreateSlider(settings, {
        name = "MageTeleportsScaleSlider",
        labelText = L["SCALE"],
        minV = 0.7, maxV = 1.5, step = 0.05,
        get = function() return MageTeleportsDB.scale or 1.0 end,
        format = pctFormat,
        onChange = function(v)
            ns.ApplyScale(v)
        end,
    })
    scaleSlider:SetPoint("TOPLEFT", transpSlider, "BOTTOMLEFT", 0, -8)
    scaleSlider:SetPoint("RIGHT", settings, "RIGHT", -18, 0)

    local langOptions = {}
    for _, opt in ipairs(ns.LOCALE_OPTIONS) do
        langOptions[#langOptions + 1] = {
            value = opt.value,
            label = opt.label or L["LOCALE_AUTO"],
        }
    end
    local langRow = CreateDropdown(settings, L["LANGUAGE"], langOptions, function()
        return MageTeleportsDB.locale or "auto"
    end, function(code)
        ns.SetLocale(code)
    end)
    langRow:SetPoint("TOPLEFT", scaleSlider, "BOTTOMLEFT", 0, -10)
    langRow:SetPoint("RIGHT", settings, "RIGHT", -18, 0)

    local cbMinimap = AddCheckbox(langRow, -12, L["SHOW_MINIMAP"], "showMinimap", function()
        if ns.UpdateMinimapButton then
            ns.UpdateMinimapButton()
        end
    end)
    cbMinimap:ClearAllPoints()
    cbMinimap:SetPoint("TOPLEFT", langRow, "BOTTOMLEFT", -2, -10)

    -- Footer --------------------------------------------------------------
    local footerLine = settings:CreateTexture(nil, "ARTWORK")
    footerLine:SetColorTexture(C.border[1], C.border[2], C.border[3], 0.6)
    footerLine:SetHeight(1)
    footerLine:SetPoint("BOTTOMLEFT", 12, 44)
    footerLine:SetPoint("BOTTOMRIGHT", -12, 44)

    local changelogBtn = ThemedButton(settings, L["CHANGELOG"])
    changelogBtn:SetPoint("BOTTOMLEFT", 14, 14)
    changelogBtn:SetPoint("BOTTOMRIGHT", settings, "BOTTOM", -3, 14)
    changelogBtn:SetScript("OnClick", ns.ShowChangelog)

    local aboutBtn = ThemedButton(settings, L["ABOUT"])
    aboutBtn:SetPoint("BOTTOMLEFT", settings, "BOTTOM", 3, 14)
    aboutBtn:SetPoint("BOTTOMRIGHT", -14, 14)
    aboutBtn:SetScript("OnClick", ns.ShowAbout)

    if not tContains(UISpecialFrames, "MageTeleportsSettingsFrame") then
        tinsert(UISpecialFrames, "MageTeleportsSettingsFrame")
    end

    ns.ApplyScale()

    return settings
end

function ns.ToggleSettingsFrame()
    local sf = ns.CreateSettingsFrame()
    if sf:IsShown() then
        sf:Hide()
    else
        sf:Show()
    end
end
