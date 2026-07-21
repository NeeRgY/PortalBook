local _, ns = ...

ns.SHOW_RUNES = true
ns.RUNE_TELEPORT_ID = 17031
ns.RUNE_PORTAL_ID = 17032

ns.DESTINATIONS = {
    { key = "STORMWIND", faction = "Alliance", teleport = 3561, portal = 10059, teleportLevel = 20, portalLevel = 40, source = "SRC_STORMWIND" },
    { key = "IRONFORGE", faction = "Alliance", teleport = 3562, portal = 11416, teleportLevel = 20, portalLevel = 40, source = "SRC_IRONFORGE" },
    { key = "DARNASSUS", faction = "Alliance", teleport = 3565, portal = 11419, teleportLevel = 30, portalLevel = 50, source = "SRC_DARNASSUS" },

    { key = "ORGRIMMAR", faction = "Horde", teleport = 3567, portal = 11417, teleportLevel = 20, portalLevel = 40, source = "SRC_ORGRIMMAR" },
    { key = "UNDERCITY", faction = "Horde", teleport = 3563, portal = 11418, teleportLevel = 20, portalLevel = 40, source = "SRC_UNDERCITY" },
    { key = "THUNDERBLUFF", faction = "Horde", teleport = 3566, portal = 11420, teleportLevel = 30, portalLevel = 50, source = "SRC_THUNDERBLUFF" },
}

function ns.GetVisibleDestinations(faction, showOnlyLearned)
    local list = {}
    for _, dest in ipairs(ns.DESTINATIONS) do
        if dest.faction == "Neutral" or dest.faction == faction then
            local knownTeleport = ns.IsSpellKnown(dest.teleport)
            local knownPortal = dest.portal and ns.IsSpellKnown(dest.portal)
            if not showOnlyLearned or knownTeleport or knownPortal then
                list[#list + 1] = dest
            end
        end
    end
    return list
end
