BLW.doNotTarget = {
	"Qiraji Scorpion",
	"Qiraji Scarab",
}

-- function BC.MakeMacro(name, macro, perCharacter, macroIconTexture, iconIndex, replace, show, noCreate, replaceMacroIndex, replaceMacroName)
function BLW.MakeMacros()
	BC.MakeMacro("Tank", "/blw tank", 0, "Ability_Warrior_DefensiveStance", nil, 1, 1)
	BC.MakeMacro("KT Tank", "/blw kt", 0, "Ability_Warrior_DefensiveStance", nil, 1, 1)
	BC.MakeMacro("DPS", "/blw dps", 0, "Spell_Nature_BloodLust", nil, 1, 1)
	BC.MakeMacro("DPS2", "/blw dps2", 0, "Ability_Warrior_OffensiveStance", nil, 1, 1)
	BC.MakeMacro("NF", "/blw nf", 0, "Spell_Holy_ElunesGrace", nil, 1, 1)
	BC.MakeMacro("AoE", "/blw aoe", 0, "Ability_Creature_Cursed_04", nil, 1, 1)
end

function BLW.HP(unit)
	local unit = unit or "target"
	local percent = (UnitHealth(unit) / UnitHealthMax(unit)) * 100
	return percent
end

function BLW.Rage()
	return UnitMana("player")
end

function BLW.SpellOnCD(spellName)
	local id = BC.GetSpellId(spellName)
	if id then
		local start, duration = GetSpellCooldown(id, 0)
		if start == 0 and duration == 0 then
			return nil
		end
	end
	return true
end

function BLW.TargetAndAttack()
	if UnitExists("target") then
		BC.EnableAttack()
		return true
	end
	TargetNearestEnemy()
	local counter = 0
	while counter < 10 and BLW.UnwantedTarget() do
		TargetNearestEnemy()
		counter = counter + 1
	end
	if BLW.UnwantedTarget() then
		ClearTarget()
		return false
	else
		BC.EnableAttack()
		return true
	end
end

function BLW.CheckDodgeParryBlockResist(arg1)
	local dodged = ".+ attacks%. You dodge%."
	local dodgedSpell = ".+'s? .+ was dodged%."
	local parried = ".+ attacks%. You parry%."
	local parriedSpell = ".+'s? .+ was parried%."
	local blocked = ".+ attacks%. You block%."
	local blockedSpell = ".+'s? .+ was blocked%."
	local resistedSpell = ".+'s? .+ was resisted%."
	local now = GetTime()

	if string.find(arg1, dodged) or string.find(arg1, dodgedSpell) or string.find(arg1, parried) or string.find(arg1, parriedSpell) or string.find(arg1, blocked) or string.find(arg1, blockedSpell) or string.find(arg1, resistedSpell) then
		BLW.revengeTimer = now
	end
end

function BLW.UnwantedTarget()
	for k,v in pairs(BLW.doNotTarget) do
		if UnitName("target") == v then
			return true
		end
	end
	return false
end

function BLW.BattleShout(hp)
	if hp == nil then
		hp = 99
	end
	if UnitMana("player") >= 10 and BLW.HP() <= hp and not BC.HasBuff("player", "BattleShout") then
		CastSpellByName("Battle Shout")
	end
end

function BLW.GetStances()
	local _,_,battle,_ = GetShapeshiftFormInfo(1)
	local _,_,defensive, _ = GetShapeshiftFormInfo(2)
	local _,_,berserk, _ = GetShapeshiftFormInfo(3)
	return battle, defensive, berserk
end