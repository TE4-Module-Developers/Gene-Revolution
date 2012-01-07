newEntity{
	define_as = "BASE_NPC_MERCENARY",
	type = "humanoid", subtype = "mercenary",
	display = "m", color=colors.WHITE,
	desc = [[A paid thug, looking to earn his keep.]],

	ai = "move_simple", ai_state = { talent_in=3, },
	stats = { str=5, dex=5, con=5 },
	combat_armor = 0,
	-- body = { MAINHAND = 1, OFFHAND = 1, BODY = 1, HEAD = 1 },
	-- add equip resolver?
}

newEntity{ base = "BASE_NPC_MERCENARY",
	name = "merc initiate", color=colors.WHITE,
	level_range = {1, 4}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=2 },
}

newEntity{ base = "BASE_NPC_MERCENARY",
	name = "merc veteran", color=colors.YELLOW,
	level_range = {3, 8}, exp_worth = 3,
	rarity = 4,
	max_life = resolvers.rngavg(10,12),
	combat_armor = 2,
	combat = { dam=5 },
}

newEntity{ base = "BASE_NPC_MERCENARY",
	name = "merczerker", color=colors.RED,
	desc = [[A giant mercenary, twice the size of a human!]],
	level_range = {6, 10}, exp_worth = 3,
	rarity = 4,
	max_life = resolvers.rngavg(15,20),
	size = 50, --big!
	combat_armor = 5,
	combat = { dam = 7 },
}
