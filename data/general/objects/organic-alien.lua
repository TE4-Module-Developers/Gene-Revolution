local Talents = require "mod.class.interface.PartTalents"

newEntity{base = "BASE_ORGANICPART",
	define_as = "ALIEN_ORGANICPART",
	subtype = "alien",
}

newEntity{base = "ALIEN_ORGANICPART",
	name = "Alien head",
	slot = "HEAD",
	size = 2,
	level_range = {1, 10},
	rarity = 1,
	body = { EYE = 2 },
	talents = {
		[Talents.T_ACID_BITE] = 5,
		[Talents.T_ACID_SPRAY] = 25,
		[Talents.T_DEVOUR] = 75,
	},
	desc = [[Remember the movie Aliens?  Like that.]],
}