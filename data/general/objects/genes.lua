newEntity{
	define_as = "GENE",
	type = "gene",
	slot = "GENE",
	desc = [[Double-stranded and ready to kill.]],
	use_simple = function(self, who, ...)
	end,
}

newEntity{base = "GENE",
	name = "Acid Glands",
	subtype = "HEAD",
	rarity = 10,
	level_range = {1, 10},
	on_wear = function(self, part)
		part:learnTalent(part.T_ACID_SPRAY, true)
	end,
	on_takeoff = function(self, part)
		part:unlearnTalent(part.T_ACID_SPRAY, true)
	end,
}