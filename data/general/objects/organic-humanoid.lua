local Talents = require "mod.class.interface.PartTalents"

newEntity{base = "BASE_ORGANICPART",
	define_as = "HUMANOID_ORGANICPART",
	subtype = "humanoid",
}

newEntity{base = "HUMANOID_ORGANICPART",
	name = "Head",
	slot = "HEAD",
	rarity = 10,
	level_range = {1, 10},
	power_level = 10,
	wielder = {
		max_fidelity = 20,
		fidelity_regen = 1,
	},
	desc = [[Two eyes, two ears, a nose and a mouth.  Fairly standard stuff.]],
}

newEntity{base = "HUMANOID_ORGANICPART",
	name = "Arm",
	slot = "ARMS",
	rarity = 10,
	level_range = {1, 10},
	power_level = 10,
	wielder = {
		max_fidelity = 20,
		fidelity_regen = 1,
	},
	desc = [[Where would the opposable thumb be without these babies?]],
}

newEntity{base = "HUMANOID_ORGANICPART",
	name = "Leg",
	slot = "LEGS",
	rarity = 10,
	level_range = {1, 10},
	power_level = 10,
	wielder = {
		max_fidelity = 20,
		fidelity_regen = 1,
	},
	desc = [[Mobility is survival.]],
}

newEntity{base = "HUMANOID_ORGANICPART",
	name = "Eye",
	slot = "EYES",
	rarity = 10,
	level_range = {1, 10},
	power_level = 10,
	wielder = {
		max_fidelity = 20,
		fidelity_regen = 1,
	},
	desc = [[Knowledge is survival.]],
}

newEntity{base = "HUMANOID_ORGANICPART",
	name = "Torso",
	slot = "TORSO",
	rarity = 10,
	level_range = {1, 10},
	power_level = 10,
	wielder = {
		max_fidelity = 20,
		fidelity_regen = 1,
	},
	desc = [[The business part of a humanoid.]],
}