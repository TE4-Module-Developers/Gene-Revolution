local Talents = require "mod.class.interface.PartTalents"

newEntity{base = "BASE_CYBERPART",
	define_as = "HUMANOID_CYBERPART",
	subtype = "humanoid",
}

newEntity{base = "HUMANOID_CYBERPART",
	name = "Pneumatic arm",
	slot = "ARMS",
	rarity = 10,
	level_range = {1, 10},
	power_level = 10,
	talents = {
		[Talents.T_PUNCH] = 5,
		[Talents.T_CONCUSSIVE_PUNCH] = 25,
		[Talents.T_POWER_SWEEP] = 50,
		[Talents.T_GROUND_POUND] = 75,
	},
	wielder = {
		max_sync = 20,
		sync_regen = 1,
	},
}