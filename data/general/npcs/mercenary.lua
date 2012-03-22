local slotCheck = function(slot)
	local temp = function(e) return e.slot == slot end
	return temp
end

newEntity{
	define_as = "BASE_NPC_MERCENARY",
	type = "humanoid", subtype = "mercenary",
	display = "m", color=colors.WHITE,
	desc = [[A paid thug, looking to earn his keep.]],

	ai = "tactical", ai_state = { talent_in=1.5, },
	stats = { str=5, dex=5, con=5 },
	body = { INVEN = 10, TORSO = 1 },
	resolvers.recursiveequip{type="organicpart", subtype="humanoid"},
}

newEntity{ base = "BASE_NPC_MERCENARY",
	name = "merc initiate", color=colors.WHITE,
	level_range = {1, 4},
	rarity = 4,
	max_life = resolvers.rngavg(5,9),
}

newEntity{ base = "BASE_NPC_MERCENARY",
	name = "merc veteran", color=colors.YELLOW,
	level_range = {1, 8},
	rarity = 4,
	max_life = resolvers.rngavg(10,12),
}

newEntity{ base = "BASE_NPC_MERCENARY",
	name = "merczerker", color=colors.RED,
	desc = [[A giant mercenary, twice the size of a human!]],
	level_range = {1, 10},
	rarity = 4,
	max_life = resolvers.rngavg(200,300),
	-- size = 50, --big!
	bioenergy_regen = 5,
	boss = true,
	resolvers.equip{
			{type="cyberpart", subtype="humanoid", special=slotCheck("ARM")},
			{type="organicpart", subtype="alien", special=slotCheck("HEAD")},
		},
}
