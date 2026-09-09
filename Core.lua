local _, ns = ...
local L = ns.L

MageTeleportsFrame = nil

SLASH_PORTALBOOK1 = "/portalb"
SLASH_PORTALBOOK2 = "/pb"
SlashCmdList["PORTALBOOK"] = function()
    ns.ToggleMainFrame()
end

local function InitDB()
    if not MageTeleportsDB then
        MageTeleportsDB = {}
    end
    MageTeleportsDB.stats = MageTeleportsDB.stats or {}
    if MageTeleportsDB.showCounter == nil then
        MageTeleportsDB.showCounter = true
    end
    if MageTeleportsDB.transparency == nil then
        MageTeleportsDB.transparency = 0.95
    end
    if MageTeleportsDB.showOnlyLearned == nil then
        MageTeleportsDB.showOnlyLearned = false
    end
    if MageTeleportsDB.autoClose == nil then
        MageTeleportsDB.autoClose = false
    end
    if MageTeleportsDB.announcePortal == nil then
        MageTeleportsDB.announcePortal = false
    end
    if MageTeleportsDB.minimapIconAngle == nil then
        MageTeleportsDB.minimapIconAngle = 0
    end
    if MageTeleportsDB.scale == nil then
        MageTeleportsDB.scale = 1.0
    end
    if MageTeleportsDB.showMinimap == nil then
        MageTeleportsDB.showMinimap = true
    end
    if MageTeleportsDB.locale == nil then
        MageTeleportsDB.locale = "auto"
    end

    ns.ApplyLocale()
end

local function CreateMinimapButton()
    if MageTeleportsMinimapButton then
        return
    end

    local minimapButton = CreateFrame("Button", "MageTeleportsMinimapButton", Minimap)
    minimapButton:SetSize(32, 32)
    minimapButton:SetFrameStrata("MEDIUM")
    minimapButton:SetFrameLevel(8)

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

    minimapButton:SetScript("OnClick", function()
        ns.ToggleMainFrame()
    end)

    minimapButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(L["TOOLTIP_TITLE"], 1, 1, 1)
        GameTooltip:AddLine(L["TOOLTIP_CLICK"], 1, 0.82, 0, 1)
        GameTooltip:AddLine(L["TOOLTIP_RIGHTCLICK"], 1, 0.82, 0, 1)
        GameTooltip:Show()
    end)
    minimapButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    local function UpdateMinimapButtonPosition()
        local angle = minimapButton.angle or 0
        local x = math.cos(angle) * 80
        local y = math.sin(angle) * 80
        minimapButton:ClearAllPoints()
        minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
    end

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
            MageTeleportsDB.minimapIconAngle = self.angle
        end
    end)

    minimapButton:SetScript("OnUpdate", function(self)
        if self.isMoving then
            local mx, my = Minimap:GetCenter()
            local px, py = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            px, py = px / scale, py / scale
            self.angle = math.atan2(py - my, px - mx)
            UpdateMinimapButtonPosition()
        end
    end)

    UpdateMinimapButtonPosition()

    if not MageTeleportsDB.showMinimap then
        minimapButton:Hide()
    end
end

function ns.UpdateMinimapButton()
    if not MageTeleportsMinimapButton then
        return
    end
    if MageTeleportsDB.showMinimap then
        MageTeleportsMinimapButton:Show()
    else
        MageTeleportsMinimapButton:Hide()
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "PortalBook" then
        InitDB()
        self:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_LOGIN" then
        if not MageTeleportsDB then
            InitDB()
        end
        C_Timer.After(0.5, function()
            ns.CreateMainFrame()
            CreateMinimapButton()
        end)
    end
end)
