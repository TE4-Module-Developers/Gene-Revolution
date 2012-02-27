local Talents = require "mod.class.interface.PartTalents"

newEntity{base = "BASE_ORGANICPART",
	define_as = "VINE_ORGANICPART",
	subtype = "vine",
}

newEntity{base = "VINE_ORGANICPART",
	name = "Root",
	slot = "TORSO",
	size = 10,
	body = { COVER = 1, HEAD = 1, ARM = 1},
	level_range = {1, 10},
	rarity = 1,
	desc = [[The stuff in the ground]],
	talents = {
		[Talents.T_TRUDGE] = 1,
	}
}

newEntity{base = "VINE_ORGANICPART",
	name = "Branch",
	slot = "ARM",
	size = 5,
	body = { COVER = 1 },
	level_range = {1, 10},
	rarity = 1,
	desc = [[The vine's branches]],
	talents = {
		[Talents.T_PUNCH] = 1,
		[Talents.T_IMPALE] = 1,
	}
}

