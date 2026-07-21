local _, ns = ...

ns.SHOW_RUNES = false

ns.EXPANSIONS = {
    "CAPITALS",
    "OUTLAND",
    "NORTHREND",
    "CATACLYSM",
    "PANDARIA",
    "WOD",
    "LEGION",
    "BFA",
    "SL",
    "DF",
    "TWW",
}

ns.EXPANSION_LABELS = {
    ALL = "EXP_ALL",
    CAPITALS = "EXP_CAPITALS",
    OUTLAND = "EXP_OUTLAND",
    NORTHREND = "EXP_NORTHREND",
    CATACLYSM = "EXP_CATACLYSM",
    PANDARIA = "EXP_PANDARIA",
    WOD = "EXP_WOD",
    LEGION = "EXP_LEGION",
    BFA = "EXP_BFA",
    SL = "EXP_SL",
    DF = "EXP_DF",
    TWW = "EXP_TWW",
}

ns.DESTINATIONS = {
    { key = "SILVERMOON_MIDNIGHT", expansion = "CAPITALS", faction = "Neutral", teleport = 1259190, portal = 1259194, teleportLevel = 82, portalLevel = 88, source = "SRC_SILVERMOON" },
    { key = "STORMWIND", expansion = "CAPITALS", faction = "Alliance", teleport = 3561, portal = 10059, teleportLevel = 21, portalLevel = 24, source = "SRC_TRAINER" },
    { key = "IRONFORGE", expansion = "CAPITALS", faction = "Alliance", teleport = 3562, portal = 11416, teleportLevel = 21, portalLevel = 24, source = "SRC_TRAINER" },
    { key = "DARNASSUS", expansion = "CAPITALS", faction = "Alliance", teleport = 3565, portal = 11419, teleportLevel = 21, portalLevel = 24, source = "SRC_TRAINER" },
    { key = "EXODAR", expansion = "CAPITALS", faction = "Alliance", teleport = 32271, portal = 32266, teleportLevel = 21, portalLevel = 24, source = "SRC_TRAINER" },
    { key = "THERAMORE", expansion = "CAPITALS", faction = "Alliance", teleport = 49359, portal = 49360, teleportLevel = 21, portalLevel = 24, source = "SRC_TRAINER" },
    { key = "ORGRIMMAR", expansion = "CAPITALS", faction = "Horde", teleport = 3567, portal = 11417, teleportLevel = 21, portalLevel = 24, source = "SRC_TRAINER" },
    { key = "UNDERCITY", expansion = "CAPITALS", faction = "Horde", teleport = 3563, portal = 11418, teleportLevel = 21, portalLevel = 24, source = "SRC_TRAINER" },
    { key = "THUNDERBLUFF", expansion = "CAPITALS", faction = "Horde", teleport = 3566, portal = 11420, teleportLevel = 21, portalLevel = 24, source = "SRC_TRAINER" },
    { key = "SILVERMOON", expansion = "CAPITALS", faction = "Horde", teleport = 32272, portal = 32267, teleportLevel = 21, portalLevel = 24, source = "SRC_TRAINER" },
    { key = "STONARD", expansion = "CAPITALS", faction = "Horde", teleport = 49358, portal = 49361, teleportLevel = 21, portalLevel = 24, source = "SRC_TRAINER" },
    { key = "SHATTRATH", expansion = "OUTLAND", faction = "Alliance", teleport = 33690, portal = 33691, teleportLevel = 21, portalLevel = 24, source = "SRC_TRAINER" },
    { key = "SHATTRATH", expansion = "OUTLAND", faction = "Horde", teleport = 35715, portal = 35717, teleportLevel = 21, portalLevel = 24, source = "SRC_TRAINER" },
    { key = "DALARAN_NR", expansion = "NORTHREND", faction = "Neutral", teleport = 53140, portal = 53142, teleportLevel = 21, portalLevel = 24, source = "SRC_TRAINER" },
    { key = "TOL_BARAD", expansion = "CATACLYSM", faction = "Alliance", teleport = 88342, portal = 88345, teleportLevel = 21, portalLevel = 24, source = "SRC_TRAINER" },
    { key = "TOL_BARAD", expansion = "CATACLYSM", faction = "Horde", teleport = 88344, portal = 88346, teleportLevel = 21, portalLevel = 24, source = "SRC_TRAINER" },
    { key = "DALARAN_CRATER", expansion = "CATACLYSM", faction = "Neutral", teleport = 120145, portal = 120146, teleportLevel = 35, portalLevel = 35, source = "SRC_ANCIENT_TOME" },
    { key = "VALE", expansion = "PANDARIA", faction = "Alliance", teleport = 132621, portal = 132620, teleportLevel = 21, portalLevel = 24, source = "SRC_TRAINER" },
    { key = "VALE", expansion = "PANDARIA", faction = "Horde", teleport = 132627, portal = 132626, teleportLevel = 21, portalLevel = 24, source = "SRC_TRAINER" },
    { key = "STORMSHIELD", expansion = "WOD", faction = "Alliance", teleport = 176248, portal = 176246, teleportLevel = 21, portalLevel = 24, source = "SRC_TRAINER" },
    { key = "WARSPEAR", expansion = "WOD", faction = "Horde", teleport = 176242, portal = 176244, teleportLevel = 21, portalLevel = 24, source = "SRC_TRAINER" },
    { key = "HALL_OF_GUARDIAN", expansion = "LEGION", faction = "Neutral", teleport = 193759, portal = nil, teleportLevel = 10, portalLevel = nil, source = "SRC_HALL_QUEST" },
    { key = "DALARAN_BI", expansion = "LEGION", faction = "Neutral", teleport = 224869, portal = 224871, teleportLevel = 21, portalLevel = 24, source = "SRC_TRAINER" },
    { key = "BORALUS", expansion = "BFA", faction = "Alliance", teleport = 281403, portal = 281400, teleportLevel = 21, portalLevel = 24, source = "SRC_TRAINER" },
    { key = "DAZARALOR", expansion = "BFA", faction = "Horde", teleport = 281404, portal = 281402, teleportLevel = 21, portalLevel = 24, source = "SRC_TRAINER" },
    { key = "ORIBOS", expansion = "SL", faction = "Neutral", teleport = 344587, portal = 344597, teleportLevel = 52, portalLevel = 58, source = "SRC_TRAINER" },
    { key = "VALDRAKKEN", expansion = "DF", faction = "Neutral", teleport = 395277, portal = 395289, teleportLevel = 62, portalLevel = 68, source = "SRC_ALREGOSA" },
    { key = "DORNOGAL", expansion = "TWW", faction = "Neutral", teleport = 446540, portal = 446534, teleportLevel = 72, portalLevel = 78, source = "SRC_CELINDRA" },
}

local function MatchesSearch(dest, searchText)
    if not searchText or searchText == "" then
        return true
    end
    local needle = string.lower(searchText)
    local name = ns.L[dest.key] or dest.key
    if string.find(string.lower(name), needle, 1, true) then
        return true
    end
    if string.find(string.lower(dest.key), needle, 1, true) then
        return true
    end
    local spellName = ns.GetSpellName(dest.teleport)
    if spellName and string.find(string.lower(spellName), needle, 1, true) then
        return true
    end
    return false
end

function ns.GetVisibleDestinations(faction, expansion, showOnlyLearned, searchText)
    local list = {}
    for _, dest in ipairs(ns.DESTINATIONS) do
        local expansionMatch = (expansion == "ALL") or (dest.expansion == expansion)
        if expansionMatch then
            if dest.faction == "Neutral" or dest.faction == faction then
                local knownTeleport = ns.IsSpellKnown(dest.teleport)
                local knownPortal = dest.portal and ns.IsSpellKnown(dest.portal)
                if (not showOnlyLearned or knownTeleport or knownPortal) and MatchesSearch(dest, searchText) then
                    list[#list + 1] = dest
                end
            end
        end
    end
    return list
end

function ns.GetAvailableExpansions(faction, showOnlyLearned)
    local available = { "ALL" }
    for _, expansion in ipairs(ns.EXPANSIONS) do
        local destinations = ns.GetVisibleDestinations(faction, expansion, showOnlyLearned)
        if #destinations > 0 then
            available[#available + 1] = expansion
        end
    end
    return available
end
