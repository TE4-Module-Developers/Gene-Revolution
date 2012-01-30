newEntity{
	name = "Acidic Amoeba",
	type = "alien", subtype = "amoeba",
	display = "a", color=colors.BROWN,
	desc = [[A large amoeba.]],

	rarity = 5,
	level_range = {1, 10},
	max_life = resolvers.rngavg(35, 45),
	bioenergy_regen = 5,

	ai = "dumb_talented_simple", ai_state = { talent_in=1, },
	stats = { str=5, dex=5, con=5 },
	body = { INVEN = 100, TORSO = 1 },
	resolvers.recursiveequip{type="organicpart", subtype="amoeba"},
}