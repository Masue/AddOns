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
		"Regrowth",
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
		"Blessing of Sanctuary",
	}

	local class = UnitClass("player")
	
	-- warrior stuffs. add another section like this with corresponding buff table for your class.
	if class == "Warrior" then
		if BC.IsShieldEquipped() then
			table.insert(BUB.warrior, "Blessing of Salvation")
			table.insert(BUB.warrior, "Greater Blessing of Salvation")
			table.insert(BUB.warrior, "Force of Will") -- Force of Will trinket buff

		else
			-- fury warrior specific things? remove inspiration etc?
		end
		for k, buff in pairs(BUB.warrior) do table.insert(BUB.buffs, 1, buff) end
	end
	-- end of warrior stuffs.
	-- rogue stuffs
	if class == "Rogue" then
		for k, buff in pairs(BUB.rogue) do BUB.buffs[k] = buff end
	end	
	-- paladin stuffs.
	if class == "Paladin" then
		for k, buff in pairs(BUB.paladin) do BUB.buffs[k] = buff end
	end
	-- end of paladin stuffs.
end