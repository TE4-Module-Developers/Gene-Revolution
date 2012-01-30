local Talents = require "mod.class.interface.PartTalents"

newEntity{base = "BASE_ORGANICPART",
	define_as = "HUMANOID_ORGANICPART",
	subtype = "humanoid",
}

newEntity{base = "HUMANOID_ORGANICPART",
	name = "Torso",
	slot = "TORSO",
	size = 10,
	body = { ARM = 2, LEG = 2, HEAD = 1 },
	level_range = {1, 10},
	rarity = 1,
	desc = [[The business part of a humanoid.]],
}

newEntity{base = "HUMANOID_ORGANICPART",
	name = "Head",
	slot = "HEAD",
	size = 1,
	body = { GENE = 1, EYE = 2 },
	level_range = {1, 10},
	rarity = 1,
	desc = [[Two eyes, two ears, a nose and a mouth.  Fairly standard stuff.]],
}

newEntity{base = "HUMANOID_ORGANICPART",
	name = "Arm",
	slot = "ARM",
	size = 3,
	body = { HAND = 1 },
	level_range = {1, 10},
	rarity = 1,
	desc = [[Where would the opposable thumb be without these babies?]],
}

newEntity{base = "HUMANOID_ORGANICPART",
	name = "Hand",
	slot = "HAND",
	body = { GRIP = 1 },
	level_range = {1, 10},
	rarity = 1,
	desc = [[Opposable thumbs are a great thing.]],
}

newEntity{base = "HUMANOID_ORGANICPART",
	name = "Leg",
	slot = "LEG",
	size = 8,
	level_range = {1, 10},
	rarity = 1,
	desc = [[Mobility is survival.]],
}

newEntity{base = "HUMANOID_ORGANICPART",
	name = "Eye",
	slot = "EYE",
	level_range = {1, 10},
	rarity = 1,
	desc = [[Knowledge is survival.]],
}