local loadIfNot = function(f)
	if loaded[f] then return end
	load(f, entity_mod)
end

-- Some base definitions
newEntity{
	define_as = "BASE_ORGANICPART",
	level_resource = "fidelity",
	use_resource = "bioenergy",
	type = "organicpart",
	desc = [[It all comes down to the carbon.]],
}

newEntity{
	define_as = "BASE_CYBERPART",
	level_resource = "sync",
	use_resource = "bioenergy",
	type = "cyberpart",
	desc = [[A bunch of metal and electronics.]],
}

-- And now everything else
loadIfNot("/data/general/objects/organic-humanoid.lua")
loadIfNot("/data/general/objects/cyber-humanoid.lua")
loadIfNot("/data/general/objects/organic-alien.lua")
loadIfNot("/data/general/objects/organic-amoeba.lua")
loadIfNot("/data/general/objects/genes.lua")