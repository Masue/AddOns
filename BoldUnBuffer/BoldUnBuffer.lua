BUB = {}
BUB.debug = false
BUB.prep = "[BoldUnBuffer] "

function BUB.OnLoad()
	BUB.InitBuffTables()
	this:RegisterEvent("PLAYER_AURAS_CHANGED")
	this:RegisterEvent("UNIT_INVENTORY_CHANGED")
end

function BUB.OnEvent(event)
	if UnitName("target") == "Garr" then return end -- keep buffs for garr in case of dispel :(

	-- if equip shield
	if event == "UNIT_INVENTORY_CHANGED" then
		BUB.InitBuffTables()
	end

	for k, buff in pairs(BUB.buffs) do
		BC.RemoveBuffByName(buff)
	end
end

function BUB.InitBuffTables()
	BUB.buffs = {
		"Cozy Fire",
	}
	BUB.warrior = {
		"Blessing of Wisdom",
		"Greater Blessing of Wisdom",
		"Arcane Intellect",
		"Arcane Brilliance",
		"Divine Spirit",
		"Prayer of Spirit",
		"Intellect", -- int scroll.
		"Spirit", -- spi scroll.
		-- "Fury of Forgewright", -- ironfoe, might fuck the proc up?
		"Bloodthirst",
		"Blessing of Shahram",
		"Blessing of the claw",
	}
	BUB.paladin = {
		"Battle Shout",
	}
	
	BUB.rogue = {
		"Blessing of Wisdom",
		"Greater Blessing of Wisdom",
		"Arcane Intellect",
		"Arcane Brilliance",
		"Divine Spirit",
		"Prayer of Spirit",
		"Intellect", -- int scroll.
		"Spirit", -- spi scroll.
		"Blessing of Shahram",
		"Regrowth",
		"Blessing of the claw",
		"Greater Blessing of Sanctuary",
		"Greater Blessing of Light",
		"Blessing of Sanctuary",
		"Armor of Faith",
		"Inspiration",
		"Thorns",
	}
		BUB.warlock = {
		"Battle Shout",
		"Divine Spirit",
		"Prayer of Spirit",
		"Fist of Shahram",
		"Greater Blessing of Sanctuary",
		"Blessing of Sanctuary",
		"Greater Blessing of Light",
		"Agility",
		"Strength",
		"Spirit",
		"Juju Might",
		"Juju Flurry",
		"Juju Power",
		"Thorns",
	}

	local class = UnitClass("player")
	
	-- warrior stuffs. add another section like this with corresponding buff table for your class.
	if class == "Warrior" then
		if BC.IsShieldEquipped() then
			table.insert(BUB.warrior, "Blessing of Salvation")
			table.insert(BUB.warrior, "Greater Blessing of Salvation")
			table.insert(BUB.warrior, "Greater Blessing of Sanctuary")		
			table.insert(BUB.warrior, "Blessing of Sanctuary")				
			table.insert(BUB.warrior, "Force of Will") -- Force of Will trinket buff
		else
			table.insert(BUB.warrior, "Armor of Faith")
			table.insert(BUB.warrior, "Inspiration")
			table.insert(BUB.warrior, "Regrowth")
			table.insert(BUB.warrior, "Greater Blessing of Light")
			table.insert(BUB.warrior, "Blessing of Light")
			table.insert(BUB.warrior, "Greater Blessing of Sanctuary")	
			table.insert(BUB.warrior, "Blessing of Sanctuary")	
			table.insert(BUB.warrior, "Thorns")	

		end
		for k, buff in pairs(BUB.warrior) do table.insert(BUB.buffs, 1, buff) end
	end
	-- end of warrior stuffs.
	-- rogue stuffs
	if class == "Rogue" then
		for k, buff in pairs(BUB.rogue) do BUB.buffs[k] = buff end
	end	
	-- rogue end
	-- paladin stuffs.
	if class == "Paladin" then
		for k, buff in pairs(BUB.paladin) do BUB.buffs[k] = buff end
	end
	-- end of paladin stuffs.
	-- warlock
	if class == "Warlock" then
		for k, buff in pairs(BUB.warlock) do BUB.buffs[k] = buff end
	end
	-- warlock end
end