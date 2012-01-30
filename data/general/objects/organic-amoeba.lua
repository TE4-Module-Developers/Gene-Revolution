local Talents = require "mod.class.interface.PartTalents"

newEntity{base = "BASE_ORGANICPART",
	define_as = "AMOEBA_ORGANICPART",
	subtype = "amoeba",
}

newEntity{base = "AMOEBA_ORGANICPART",
	name = "Cytoplasm",
	slot = "TORSO",
	size = 10,
	body = { COVER = 1, HEAD = 1, ARM = 1},
	level_range = {1, 10},
	rarity = 1,
	desc = [[The core part of an amoeba.]],
	talents = {
		[Talents.T_DEVOUR] = 1,
	}
}

newEntity{base = "AMOEBA_ORGANICPART",
	name = "Pseudopodia",
	slot = "ARM",
	size = 5,
	body = { COVER = 1 },
	level_range = {1, 10},
	rarity = 1,
	desc = [[The extending part of an amoeba.]],
	talents = {
		[Talents.T_PUNCH] = 1,
	}
}

newEntity{base = "AMOEBA_ORGANICPART",
	name = "Nucleus",
	slot = "HEAD",
	size = 0,
	body = { GENE = 1 },
	level_range = {1, 10},
	rarity = 1,
	desc = [[The thinking part of an amoeba.]],
	resolvers.recursiveequip{type="gene", subtype="HEAD"},
}