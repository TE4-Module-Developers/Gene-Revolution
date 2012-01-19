local Talents = require "mod.class.interface.PartTalents"

newEntity{base = "BASE_ORGANICPART",
	define_as = "HUMANOID_ORGANICPART",
	subtype = "humanoid",
}

newEntity{base = "HUMANOID_ORGANICPART",
	name = "Torso",
	slot = "TORSO",
	rarity = 10,
	on_wear = function(self, actor)
		self:addSlot("ARM", 2)
		self:addSlot("LEG", 2)
		self:addSlot("HEAD", 1)
	end,
	on_takeoff = function(self, actor)
		self:removeSlot("ARM", 2)
		self:removeSlot("LEG", 2)
		self:removeSlot("HEAD", 1)
	end,
	level_range = {1, 10},
	power_level = 10,
	wielder = {
		max_fidelity = 20,
		fidelity_regen = 1,
	},
	desc = [[The business part of a humanoid.]],
}

newEntity{base = "HUMANOID_ORGANICPART",
	name = "Head",
	slot = "HEAD",
	rarity = 10,
	on_wear = function(self, actor)
		self:addSlot("EYE", 2)
	end,
	on_takeoff = function(self, actor)
		self:removeSlot("EYE", 2)
	end,
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
	slot = "ARM",
	rarity = 10,
	on_wear = function(self, actor)
		self:addSlot("HAND", 1)
	end,
	on_takeoff = function(self, actor)
		self:removeSlot("HAND", 1)
	end,
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
	slot = "LEG",
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
	slot = "EYE",
	rarity = 10,
	level_range = {1, 10},
	power_level = 10,
	wielder = {
		max_fidelity = 20,
		fidelity_regen = 1,
	},
	desc = [[Knowledge is survival.]],
}