local Talents = require "mod.class.interface.PartTalents"

newEntity{
	define_as = "BASE_CYBERPART",
	level_resource = "sync",
	use_resource = "bioenergy",
	type = "cyberpart",
	desc = [[A bunch of metal and electronics.]],
}

newEntity{base = "BASE_CYBERPART",
	define_as = "ARM_PART",
	slot = "ARMS",
}

newEntity{base = "ARM_PART",
	name = "Pneumatic arm",
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

newEntity{
	define_as = "BASE_ORGANICPART",
	level_resource = "fidelity",
	use_resource = "bioenergy",
	type = "organicpart",
	desc = [[It all comes down to the carbon.]],
}

newEntity{base = "BASE_ORGANICPART",
	define_as = "HEAD_ORGANICPART",
	slot = "HEAD",
}

newEntity{base = "HEAD_ORGANICPART",
	name = "Alien head",
	rarity = 10,
	level_range = {1, 10},
	power_level = 10,
	talents = {
		[Talents.T_ACID_BITE] = 5,
		[Talents.T_ACID_SPRAY] = 25,
		[Talents.T_DEVOUR] = 75,
	},
	wielder = {
		max_fidelity = 20,
		fidelity_regen = 1,
	},
	desc = [[Remember the movie Aliens?  Like that.]],
}
