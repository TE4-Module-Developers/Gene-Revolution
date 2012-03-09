local Talents = require "mod.class.interface.PartTalents"

newEntity{base = "BASE_ITEM",
	define_as = "TERRAN_TECHNOLOGY",
	subtype = "Terran",
}

newEntity{base = "TERRAN_TECHNOLOGY",
	name = "Fragmentation Grenade",
	slot = "HAND",   -- though can be stored in a bandolier type stuff? , needs to be HAND or HAND?
	size = 0.5,  -- Needed?
	rarity = 1,  -- needs to be rare (I have no idea what rare is), in fact I think it should only be found in munitions depots
	desc = [[A grenade for throwing]],
	talents = {
		[Talents.T_THROW_FRAG_GRENADE] = 1,
	}
}

newEntity{base = "TERRAN_TECHNOLOGY",
	name = "Smoke Grenade",
	slot = "HAND",   -- though can be stored in a bandolier type stuff? , needs to be HAND or HAND?
	size = 0.5,  -- Needed?
	rarity = 1,  -- needs to be rare (I have no idea what rare is), in fact I think it should only be found in munitions depots
	desc = [[A grenade for throwing]],
	talents = {
		[Talents.T_THROW_SMOKE_GRENADE] = 1,
	}
}

newEntity{base = "TERRAN_TECHNOLOGY",
	name = "Poison Grenade",
	slot = "HAND",   -- though can be stored in a bandolier type stuff? , needs to be HAND or HAND?
	size = 0.5,  -- Needed?
	rarity = 1,  -- needs to be rare (I have no idea what rare is), in fact I think it should only be found in munitions depots
	desc = [[A grenade for throwing]],
	talents = {
		[Talents.T_THROW_SMOKE_GRENADE] = 1,
	}
}

newEntity{base = "TERRAN_TECHNOLOGY",
	name = "Flashbang",
	slot = "HAND",   -- though can be stored in a bandolier type stuff? , needs to be HAND or HAND?
	size = 0.5,  -- Needed?
	rarity = 1,  -- needs to be rare (I have no idea what rare is), in fact I think it should only be found in munitions depots
	desc = [[A grenade for throwing]],
	talents = {
		[Talents.T_THROW_FLASHBANG] = 1,
	}
}

newEntity{base = "TERRAN_TECHNOLOGY",
	name = "Concussion Grenade",
	slot = "HAND",   -- though can be stored in a bandolier type stuff? , needs to be HAND or HAND?
	size = 0.5,  -- Needed?
	rarity = 1,  -- needs to be rare (I have no idea what rare is), in fact I think it should only be found in munitions depots
	desc = [[A grenade for throwing]],
	talents = {
		[Talents.T_THROW_CONCUSSION_GRENADE] = 1,
	}
}

