local _, ns = ...

ns.VERSION = "2.1.0"

-- Locale registry. Each Locales\*.lua file registers its table here instead of
-- writing ns.L directly, so the active language can be switched at runtime.
ns.locales = ns.locales or {}
ns.L = ns.L or {}

-- Rebuilds ns.L in place (English base + chosen overlay) so every
-- `local L = ns.L` reference stays valid. Pass nothing to use the saved choice.
function ns.ApplyLocale()
    local choice = MageTeleportsDB and MageTeleportsDB.locale
    local code = (choice and choice ~= "auto") and choice or GetLocale()
    if not ns.locales[code] then
        code = "enUS"
    end

    wipe(ns.L)
    local base = ns.locales.enUS or {}
    for k, v in pairs(base) do
        ns.L[k] = v
    end
    if code ~= "enUS" and ns.locales[code] then
        for k, v in pairs(ns.locales[code]) do
            if v ~= nil and v ~= "" then
                ns.L[k] = v
            end
        end
    end

    ns.activeLocale = code
end

function ns.IsMage()
    local _, classFile = UnitClass("player")
    return classFile == "MAGE"
end

function ns.GetSpellName(spellID)
    if not spellID then
        return nil
    end
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID)
        if info then
            return info.name
        end
    end
    if GetSpellInfo then
        return GetSpellInfo(spellID)
    end
    return nil
end

function ns.GetSpellTexture(spellID)
    if not spellID then
        return "Interface\\Icons\\INV_Misc_QuestionMark"
    end
    if C_Spell and C_Spell.GetSpellTexture then
        local texture = C_Spell.GetSpellTexture(spellID)
        if texture then
            return texture
        end
    end
    if GetSpellTexture then
        local texture = GetSpellTexture(spellID)
        if texture then
            return texture
        end
    end
    return "Interface\\Icons\\INV_Misc_QuestionMark"
end

function ns.IsSpellKnown(spellID)
    if not spellID then
        return false
    end
    if IsPlayerSpell and IsPlayerSpell(spellID) then
        return true
    end
    if IsSpellKnown and IsSpellKnown(spellID) then
        return true
    end
    return false
end

function ns.GetItemIcon(itemID)
    if GetItemIcon then
        return GetItemIcon(itemID)
    end
    if C_Item and C_Item.GetItemIconByID then
        return C_Item.GetItemIconByID(itemID)
    end
    return "Interface\\Icons\\INV_Misc_Rune_01"
end

-- Static spellID -> destination map, independent of what the UI currently shows.
-- Used for cast tracking so counts are recorded even for spells cast from the
-- spellbook while a different tab/filter is active.
function ns.BuildSpellIndex()
    if ns.spellIndex then
        return ns.spellIndex
    end
    if not ns.DESTINATIONS then
        return {}
    end
    local index = {}
    for _, dest in ipairs(ns.DESTINATIONS) do
        if dest.teleport then
            index[dest.teleport] = { destKey = dest.key, isPortal = false }
        end
        if dest.portal then
            index[dest.portal] = { destKey = dest.key, isPortal = true }
        end
    end
    ns.spellIndex = index
    return index
end

-- Debounced refresh, shared by all client flavours. Triggered by SPELLS_CHANGED
-- so newly learned portals/teleports show up without reopening the window.
function ns.ScheduleSpellRefresh()
    if ns.spellRefreshTimer then
        ns.spellRefreshTimer:Cancel()
    end
    ns.spellRefreshTimer = C_Timer.NewTimer(0.5, function()
        ns.spellRefreshTimer = nil
        if ns.RebuildTabs then
            ns.RebuildTabs()
        elseif ns.RefreshDestinationList then
            ns.RefreshDestinationList()
        end
    end)
end
