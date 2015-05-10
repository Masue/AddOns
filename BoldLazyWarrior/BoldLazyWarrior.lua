BLW = {}
if UnitClass("player") ~= "Warrior" then return end

BLW.debug = false
BLW.prep = "[BLW] "

function BLW.OnLoad()
	if UnitClass("player") ~= "Warrior" then return end
	-- for target casting.
	this:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	this:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")
	this:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE")
	this:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF")
	-- for Overpower.
	this:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
	this:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
	-- for loading vars.
	this:RegisterEvent("PLAYER_LOGIN")
	-- misc.
	this:RegisterEvent("PLAYER_TARGET_CHANGED")
	-- for Revenge.
	this:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES")
	this:RegisterEvent("CHAT_MSG_COMBAT_HOSTILEPLAYER_MISSES")
	this:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE")
end

function BLW.OnEvent()
	if event == "PLAYER_LOGIN" then
		BLW.InitVariables()
		if BC.GetSpellId("Shield Slam") then
			BLW.prot = true
		else
			BLW.prot = false
		end
		BLW.mainAbility, BLW.mainAbilityCost = "Shield Slam", 20
		if not BLW.prot then 
			BLW.mainAbility, BLW.mainAbilityCost = "Bloodthirst", 30
		end
	elseif (event == "CHAT_MSG_COMBAT_SELF_MISSES" and string.find(arg1, BLW_OVERPOWER1)) then
		BLW.targetDodged = GetTime()
	elseif (event == "CHAT_MSG_SPELL_SELF_DAMAGE" and (string.find(arg1, BLW_OVERPOWER3) or string.find(arg1, BLW_OVERPOWER4) or string.find(arg1, BLW_OVERPOWER5))) then
		BLW.targetDodged = nil
	elseif (event == "CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE" or event == "CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF" or event == "CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE" or event == "CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF") then
		for mob, spell in string.gfind(arg1, BLW_CAST) do
			if (mob == UnitName("target") and UnitCanAttack("player", "target") and mob ~= spell) then
				BLW.targetCasting = GetTime()
			end
			return
		end
	elseif (event == "PLAYER_TARGET_CHANGED") then
		BLW.targetDodged = nil
		BLW.targetCasting = nil
	end
	if event == "CHAT_MSG_COMBAT_SELF_MISSES" or event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES" or event == "CHAT_MSG_COMBAT_HOSTILEPLAYER_MISSES" or event == "CHAT_MSG_SPELL_SELF_DAMAGE" or event == "CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE" then
		BLW.CheckDodgeParryBlockResist(arg1)
	end
	if event == "CHAT_MSG_SPELL_SELF_DAMAGE" then
		if string.find(arg1, BLW_OVERPOWER2) then
			BLW.targetDodged = GetTime()
		elseif string.find(arg1, BLW_INTERRUPT1) or string.find(arg1, BLW_INTERRUPT2) or string.find(arg1, BLW_INTERRUPT3) or string.find(arg1, BLW_INTERRUPT4) or string.find(arg1, BLW_INTERRUPT5) then
			BLW.targetCasting = nil
		elseif string.find(arg1, BLW_REVENGE1) or string.find(arg1, BLW_REVENGE2) or string.find(arg1, BLW_REVENGE3) then
			BLW.revengeTimer = nil
		end
		if string.find(arg1, BLW_REVENGE4) then
			BLW.revengeTimer = nil
		end
	end

end

SLASH_BLW_ROTATION1 = '/blw'
function SlashCmdList.BLW_ROTATION(rotation)
	if rotation == "dps" then
		BLW.DPS()
	elseif rotation == "dps2" then
		BLW.DPS2(true)
	elseif rotation == "dps3" then
		BLW.DPS2()
	elseif rotation == "tank" then
		BLW.Tank()
	elseif rotation == "kt" then
		BLW.Kt()
	elseif rotation == "nf" then
		BLW.Nightfall()
	elseif rotation == "aoe" then
		BLW.AoE()
	elseif rotation == "mm" then
		BLW.MakeMacros()
	else
		BC.my("BoldLazyWarrior has the following warrior rotations:", BLW.prep)
		BC.mb("/blw dps", BLW.prep)
		BC.m("A dps rotation (both fury and prot).", BLW.prep)
		BC.mb("/blw dps2", BLW.prep)
		BC.m("A dps rotation in battle stance (only fury).", BLW.prep)
		BC.mb("/blw dps3", BLW.prep)
		BC.m("Same as dps2 but execute in berserker stance.", BLW.prep)
		BC.mb("/blw tank", BLW.prep)
		BC.m("A tank rotation (both fury and prot).", BLW.prep)
		BC.mb("/blw kt", BLW.prep)
		BC.m("A tank rotation for Kel thuzad, doesn't include shield bash.", BLW.prep)
		BC.mb("/blw nf", BLW.prep)
		BC.m("A Nightfall rotation.", BLW.prep)
		BC.mb("/blw aoe", BLW.prep)
		BC.m("A multi-target rotation.", BLW.prep)
		BC.mb("/blw mm", BLW.prep)
		BC.m("Make macros for the rotations.", BLW.prep)
	end
end

function BLW.InitVariables()
	BLW.lastStanceChange = 0
	BLW.targetCasting = 0
	BLW.targetDodged = 0
	BLW.revengeTimer = 0

	BLW.lastAbility = 0
	BLW.lastMainAbility = 0
	BLW.revenge = 0
	BLW.shieldBash = 0
	BLW.pummel = 0
	BLW.sunder = 0
	BLW.overpower = 0
	BLW.execute = 0
	BLW.hamstring = 0

	BINDING_HEADER_BLW = "BoldLazyWarrior"
	BINDING_NAME_BLW_DPS = "DPS rotation"
	BINDING_NAME_BLW_TANK = "Tank rotation"
	BINDING_NAME_BLW_NIGHTFALL = "Nightfall Rotation"
	BINDING_NAME_BLW_AOE = "Multi-target rotation"

	BLW_CAST = "(.+) begins to cast (.+)."
	BLW_OVERPOWER1 = "You attack.(.+) dodges."
	BLW_OVERPOWER2 = "Your (.+) was dodged by (.+)."
	BLW_OVERPOWER3 = "Your Overpower crits (.+) for (%d+)."
	BLW_OVERPOWER4 = "Your Overpower hits (.+) for (%d+)."
	BLW_OVERPOWER5 = "Your Overpower missed (.+)."
	BLW_INTERRUPT1 = "You interrupt (.+)."
	BLW_INTERRUPT2 = "Your Pummel was (.+) by (.+)."
	BLW_INTERRUPT3 = "Your Shield Bash was (.+) by (.+)."
	BLW_INTERRUPT4 = "Your Pummel missed (.+)."
	BLW_INTERRUPT5 = "Your Shield Bash missed (.+)."

	BLW_REVENGE1 = "Your Revenge crits (.+) for (%d+)."
	BLW_REVENGE2 = "Your Revenge hits (.+) for (%d+)."
	BLW_REVENGE3 = "Your Revenge missed (.+)."
	BLW_REVENGE4 = "Your Revenge was dodged by (.+)."
end

function BLW.DPS2(battleOnly)
	if BLW.prot then BC.m("This rotation requires a fury spec.", BLW.prep) return end
	if not BLW.TargetAndAttack() then return end
	local battle, _, berserk = BLW.GetStances()
	BLW.BattleShout()

	if battle then
		if BLW.HP() <= 20 then
			if BLW.Rage() >= 5 and BLW.targetDodged and not BLW.SpellOnCD("Overpower") then
				CastSpellByName("Overpower")
				if BLW.SpellOnCD("Overpower") then
					BLW.overpower = GetTime()
					BLW.targetDodged = nil
				end
			end
			if battleOnly then
				if BLW.Rage() >= 10 and not BLW.SpellOnCD("Execute") then
					CastSpellByName("Execute")
					-- if BLW.SpellOnCD("Execute") then
					-- 	BLW.execute = GetTime()
					-- end
				end
			else
				if BLW.Rage() <= 25 then
					CastSpellByName("Berserker Stance")
				else
					if rage >= 10 and not BLW.SpellOnCD("Execute") then
						CastSpellByName("Execute")
						-- if BLW.SpellOnCD("Execute") then
						-- 	BLW.execute = GetTime()
						-- end
					end
				end
			end
		else
			if BLW.Rage() >= 5 and BLW.targetDodged and not BLW.SpellOnCD("Overpower") then
				CastSpellByName("Overpower")
				if BLW.SpellOnCD("Overpower") then
					BLW.overpower = GetTime()
					BLW.targetDodged = nil
				end
			end
			if BLW.Rage() >= 30 and not BLW.SpellOnCD("Bloodthirst") then
				CastSpellByName("Bloodthirst")
				if BLW.SpellOnCD("Bloodthirst") then
					BLW.lastMainAbility = GetTime()
				end
			end
			if BLW.Rage() > 50 then
				if BLW.Rage() < 30 and (GetTime() - BLW.lastMainAbility) < 4.5 then
					if not BLW.targetDodged or (GetTime() - BLW.overpower) < 3.5 then
						CastSpellByName("Hamstring")
						-- if BLW.SpellOnCD("Hamstring") then
						-- 	BLW.hamstring = GetTime()
						-- end
					end
				end
				if BLW.Rage() > 60 then
					CastSpellByName("Heroic Strike")
				end
			end
		end
	elseif berserk then
		if not battleOnly and BLW.HP() <= 20 and not BLW.SpellOnCD("Execute") then
			CastSpellByName("Execute")
			-- if BLW.SpellOnCD("Execute") then
			-- 	BLW.execute = GetTime()
			-- end
		else
			CastSpellByName("Battle Stance")
		end
	else
		CastSpellByName("Battle Stance")
	end
	-- BLW.lastAbility = BLW.lastMainAbility
	-- if BLW.lastAbility < BLW.overpower then
	-- 	BLW.lastAbility = BLW.overpower
	-- end
	-- if BLW.lastAbility < BLW.execute then
	-- 	BLW.lastAbility = BLW.execute
	-- end
	-- if BLW.lastAbility < BLW.hamstring then
	-- 	BLW.lastAbility = BLW.hamstring
	-- end
end

function BLW.Tank()
	if not BLW.TargetAndAttack() then return end
	local _, defensive, _ = BLW.GetStances()
	BLW.BattleShout(80)

	if defensive then
		-- off gce
		if UnitExists("targettarget") and UnitClass("targettarget") ~= "Warrior" then
			CastSpellByName("Taunt")
		end	
		if UnitIsUnit("player", "targettarget") and BLW.Rage() > (BLW.mainAbilityCost + 15) and UnitAffectingCombat("player") and CheckInteractDistance("target", 3) and not BC.BuffIndexByName("Shield Block") then
			CastSpellByName("Shield Block")
		end
		if BLW.Rage() > (BLW.mainAbilityCost + 15) then
			CastSpellByName("Heroic Strike")
		end

		-- on gcd
		-- if (GetTime() - BLW.lastAbility) > 1.5 then
		--	if UnitClassification("target") ~= "worldboss" and BLW.targetCasting and not BLW.SpellOnCD("Shield Bash") then
		--		CastSpellByName("Shield Bash")
		--		if BLW.SpellOnCD("Shield Bash") then
		--			BLW.shieldBash = GetTime()
		--		end
		--	end
		
			if not BLW.SpellOnCD(BLW.mainAbility) then
				CastSpellByName(BLW.mainAbility)
				if BLW.SpellOnCD(BLW.mainAbility) then
					BLW.lastMainAbility = GetTime()
				end
			end
			if BLW.Rage() < BLW.mainAbilityCost and not BLW.SpellOnCD("Revenge") then
				CastSpellByName("Revenge")
				if BLW.SpellOnCD("Revenge") then
					BLW.revenge = GetTime()
				end
			end
			if not BLW.SpellOnCD("Revenge") then
				CastSpellByName("Revenge")
				if BLW.SpellOnCD("Revenge") then
					BLW.revenge = GetTime()
				end
			end
			if not ((GetTime() - BLW.lastMainAbility) > 4.5) and not ((GetTime() - BLW.revenge) > 3.5 and BLW.revengeTimer) then
				if BC.HasDebuff("target", "Sunder") < 5 and BLW.Rage() > 19 then
					CastSpellByName("Sunder Armor")
					if BLW.SpellOnCD("Sunder Armor") then
						BLW.sunder = GetTime()
					end
				end
				if BLW.Rage() > (BLW.mainAbilityCost + 40) then
					CastSpellByName("Sunder Armor")
					if BLW.SpellOnCD("Sunder Armor") then
						BLW.sunder = GetTime()
					end
				end
			end
		-- end
	else
		CastSpellByName("Defensive Stance")
	end
	-- BLW.lastAbility = BLW.lastMainAbility
	-- if BLW.lastAbility < BLW.revenge then
	-- 	BLW.lastAbility = BLW.revenge
	-- end
	-- if BLW.lastAbility < BLW.shieldBash then
	-- 	BLW.lastAbility = BLW.shieldBash
	-- end
	-- if BLW.lastAbility < BLW.sunder then
	-- 	BLW.lastAbility = BLW.sunder
	-- end
end

function BLW.Kt()
	if not BLW.TargetAndAttack() then return end
	local _, defensive, _ = BLW.GetStances()
	BLW.BattleShout(80)

	if defensive then
	-- If target == self do full threat rotation, no bash
	if UnitExists("targettarget") and UnitIsUnit("player", "targettarget") then
		if UnitIsUnit("player", "targettarget") and BLW.Rage() > (BLW.mainAbilityCost + 15) and UnitAffectingCombat("player") and CheckInteractDistance("target", 3) and not BC.BuffIndexByName("Shield Block") then
			CastSpellByName("Shield Block")
		end
		if BLW.Rage() > (BLW.mainAbilityCost + 15) then
			CastSpellByName("Heroic Strike")
		end
		if not BLW.SpellOnCD(BLW.mainAbility) then
			CastSpellByName(BLW.mainAbility)
			if BLW.SpellOnCD(BLW.mainAbility) then
				BLW.lastMainAbility = GetTime()
			end
		end
		if BLW.Rage() < BLW.mainAbilityCost and not BLW.SpellOnCD("Revenge") then
			CastSpellByName("Revenge")
			if BLW.SpellOnCD("Revenge") then
				BLW.revenge = GetTime()
			end
		end
		if not BLW.SpellOnCD("Revenge") then
			CastSpellByName("Revenge")
			if BLW.SpellOnCD("Revenge") then
				BLW.revenge = GetTime()
			end
		end
		if not ((GetTime() - BLW.lastMainAbility) > 4.5) and not ((GetTime() - BLW.revenge) > 3.5 and BLW.revengeTimer) then
			if BC.HasDebuff("target", "Sunder") < 5 and BLW.Rage() > 19 then
				CastSpellByName("Sunder Armor")
				if BLW.SpellOnCD("Sunder Armor") then
					BLW.sunder = GetTime()
				end
			end
			if BLW.Rage() > (BLW.mainAbilityCost + 40) then
				CastSpellByName("Sunder Armor")
				if BLW.SpellOnCD("Sunder Armor") then
					BLW.sunder = GetTime()
				end
			end
		end
	end
	-- if target != self and targettarget class != warrior do shield slam and threat rotation
	if UnitExists("targettarget") and UnitClass("targettarget") ~= "Warrior" then
		if BLW.Rage() > (BLW.mainAbilityCost + 25) then
			CastSpellByName("Heroic Strike")
		end
		if not BLW.SpellOnCD(BLW.mainAbility) then
			CastSpellByName(BLW.mainAbility)
			if BLW.SpellOnCD(BLW.mainAbility) then
				BLW.lastMainAbility = GetTime()
			end
		end
		if BLW.Rage() < BLW.mainAbilityCost and not BLW.SpellOnCD("Revenge") then
			CastSpellByName("Revenge")
			if BLW.SpellOnCD("Revenge") then
				BLW.revenge = GetTime()
			end
		end
		if not BLW.SpellOnCD("Revenge") then
			CastSpellByName("Revenge")
			if BLW.SpellOnCD("Revenge") then
				BLW.revenge = GetTime()
			end
		end
		if not ((GetTime() - BLW.lastMainAbility) > 4.5) and not ((GetTime() - BLW.revenge) > 3.5 and BLW.revengeTimer) then
			if BC.HasDebuff("target", "Sunder") < 5 and BLW.Rage() > 19 then
				CastSpellByName("Sunder Armor")
				if BLW.SpellOnCD("Sunder Armor") then
					BLW.sunder = GetTime()
				end
			end
			if BLW.Rage() > (BLW.mainAbilityCost + 40) then
				CastSpellByName("Sunder Armor")
				if BLW.SpellOnCD("Sunder Armor") then
					BLW.sunder = GetTime()
				end
			end
		end		
	end
	-- if target != self and targettarget class == warrior do only heroic strikes and sunder, save rage for shield slam
	if UnitExists("targettarget") and UnitClass("targettarget") == "Warrior" and not UnitIsUnit("player", "targettarget")then
		if BLW.Rage() > (BLW.mainAbilityCost + 25) then
			CastSpellByName("Heroic Strike")
		end
	end
	else
		CastSpellByName("Defensive Stance")
	end

end

function BLW.Nightfall()
	if not BLW.TargetAndAttack() then return end
	local battle, _, _ = BLW.GetStances()
	BLW.BattleShout()

	if battle then
		CastSpellByName("Overpower")
		if BC.HasDebuff("target", "Sunder") < 5 then
			CastSpellByName("Sunder Armor")
		end
		CastSpellByName("Hamstring")
	else
		CastSpellByName("Battle Stance")
	end
end

function BLW.DPS()
	if BLW.prot then
		BLW.ProtDPSRotation()
	else
		BLW.FuryDPSRotation()
	end
end

function BLW.ProtDPSRotation(prioHamstring)
	if not BLW.TargetAndAttack() then return end
	local battle, _, berserk = BLW.GetStances()
	BLW.BattleShout()

	if battle then
		if BLW.HP() <= 20 and not UnitIsDead("target") then
			if BLW.Rage() < 15 then
				CastSpellByName("Berserker Stance")
				BLW.lastStanceChange = GetTime()
			else
				if not BLW.SpellOnCD("Execute") then
					CastSpellByName("Execute")
					if BLW.SpellOnCD("Execute") then
						BLW.execute = GetTime()
					end
				end
			end
		end
		if BLW.targetDodged and not BLW.SpellOnCD("Overpower") then
			CastSpellByName("Overpower")
			if BLW.SpellOnCD("Overpower") then
				BLW.overpower = GetTime()
			end
		else
			CastSpellByName("Berserker Stance")
			BLW.lastStanceChange = GetTime()
		end
	elseif berserk then
		if UnitClassification("target") ~= "worldboss" and BLW.targetCasting and not BLW.SpellOnCD("Pummel") then
			CastSpellByName("Pummel")
			if BLW.SpellOnCD("Pummel") then
				BLW.pummel = GetTime()
			end
		end
		if BLW.HP() <= 20 and not BLW.SpellOnCD("Execute") then
			CastSpellByName("Execute")
			if BLW.SpellOnCD("Execute") then
				BLW.execute = GetTime()
			end
		end
		if not BLW.SpellOnCD("Whirlwind") then
			CastSpellByName("Whirlwind")
			if BLW.SpellOnCD("Whirlwind") then
				BLW.whirlwind = GetTime()
			end
		end
		if BLW.targetDodged and (GetTime() - BLW.targetDodged) > 4 then
			BLW.targetDodged = nil
		end
		if (BLW.SpellOnCD("Whirlwind") or BLW.Rage() < 25) and BLW.targetDodged and not BLW.SpellOnCD("Overpower") then
			CastSpellByName("Battle Stance")
			BLW.lastStanceChange = GetTime()
		end
		local hamstringRage, HSRage = 52, 42
		if prioHamstring then
			hamstringRage, HSRage = 42, 52
		end
		if BLW.Rage() > hamstringRage and not BLW.SpellOnCD("Hamstring") then
			CastSpellByName("Hamstring")
			if BLW.SpellOnCD("Hamstring") then
				BLW.hamstring = GetTime()
			end
		end
		if BLW.Rage() > HSRage then
			CastSpellByName("Heroic Strike")
		end
	else
		CastSpellByName("Berserker Stance")
		BLW.lastStanceChange = GetTime()
	end
end

function BLW.FuryDPSRotation(prioHamstring)
	if not BLW.TargetAndAttack() then return end
	local battle, _, berserk = BLW.GetStances()
	BLW.BattleShout()

	if battle then
		if BLW.HP() < 20 and not UnitIsDead("target") then
			if BLW.Rage() < 10 then
				CastSpellByName("Berserker Stance")
				BLW.lastStanceChange = GetTime()
			else
				if not BLW.SpellOnCD("Execute") then
					CastSpellByName("Execute")
					-- if BLW.SpellOnCD("Execute") then
					-- 	BLW.execute = GetTime()
					-- end
				end
			end
		end
		if BLW.targetDodged and not BLW.SpellOnCD("Overpower") then
			CastSpellByName("Overpower")
			if BLW.SpellOnCD("Overpower") then
				BLW.overpower = GetTime()
			end
		else
			CastSpellByName("Berserker Stance")
			BLW.lastStanceChange = GetTime()
		end
		if (GetTime() - BLW.overpower) > 5 then
			CastSpellByName("Berserker Stance")
			BLW.lastStanceChange = GetTime()
		end
	elseif berserk then
		if UnitClassification("target") ~= "worldboss" and BLW.targetCasting and not BLW.SpellOnCD("Pummel") then
			CastSpellByName("Pummel")
			-- if BLW.SpellOnCD("Pummel") then
			-- 	BLW.pummel = GetTime()
			-- end
		end
		if BLW.HP() <= 20 and not BLW.SpellOnCD("Execute") then
			CastSpellByName("Execute")
			-- if BLW.SpellOnCD("Execute") then
			-- 	BLW.execute = GetTime()
			-- end
		end
		if BLW.Rage() > 29 and not BLW.SpellOnCD("Bloodthirst") then
			CastSpellByName("Bloodthirst")
			if BLW.SpellOnCD("Bloodthirst") then
				BLW.lastMainAbility = GetTime()
			end
		end
		if CheckInteractDistance("target", 3) and not BLW.SpellOnCD("Whirlwind") then
			if BLW.Rage() > 29 and (GetTime() - BLW.lastMainAbility) < 2 then
				CastSpellByName("Whirlwind")
				-- if BLW.SpellOnCD("Whirlwind") then
				-- 	BLW.whirlwind = GetTime()
				-- end
			end
			if BLW.Rage() > 39 and (GetTime() - BLW.lastMainAbility) < 3 then
				CastSpellByName("Whirlwind")
				-- if BLW.SpellOnCD("Whirlwind") then
				-- 	BLW.whirlwind = GetTime()
				-- end
			end
			if BLW.Rage() > 54 and (GetTime() - BLW.lastMainAbility) < 4 then
				CastSpellByName("Whirlwind")
				-- if BLW.SpellOnCD("Whirlwind") then
				-- 	BLW.whirlwind = GetTime()
				-- end
			end
		end
		if BLW.targetDodged and BLW.HP() > 20 then
			if (GetTime() - BLW.targetDodged) < 4 then
				if BLW.SpellOnCD("Bloodthirst") and BLW.Rage() <= 41 then
					if BLW.SpellOnCD("Whirlwind") and BLW.Rage() <= 41 then
						if not BLW.SpellOnCD("Overpower") and BLW.Rage() <= 41 then
							CastSpellByName("Battle Stance")
							BLW.lastStanceChange = GetTime()
						end
					end
				end
			else
				BLW.targetDodged = nil
			end
		end

		if BLW.Rage() > 55 and BC.BuffIndexByName("Flurry") then
			CastSpellByName("Heroic Strike")
		end
		if BLW.Rage() > 65 and (GetTime() - BLW.lastMainAbility) < 4.5 and not BLW.SpellOnCD("Hamstring") then
			if BLW.targetDodged and (GetTime() - BLW.overpower) < 3.5 or not BLW.targetDodged then
				CastSpellByName("Hamstring")
				-- if BLW.SpellOnCD("Hamstring") then
				-- 	BLW.hamstring = GetTime()
				-- 	BC.my("Casted Hamstring")
				-- end
			end
		end
	else
		CastSpellByName("Berserker Stance")
	end
end

function BLW.AoE()
	if not BLW.TargetAndAttack() then return end
	local _, _, berserk = BLW.GetStances()
	BLW.BattleShout()

	if berserk then
		if CheckInteractDistance("target", 3) then
			CastSpellByName("Whirlwind")
		end
		if BLW.Rage() > 45 then
			CastSpellByName("Cleave")
		end
	else
		CastSpellByName("Berserker Stance")
	end
end