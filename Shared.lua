local _, ns = ...

ns.VERSION = "2.0.0"

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
