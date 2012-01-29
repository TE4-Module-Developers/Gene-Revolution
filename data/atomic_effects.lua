local Probability = require "mod.class.Probability"

newAtomicEffect{
	name = "MELEE_ATTACK",
	desc = "Melee attack.",
	type = "physical",
	status = "detrimental",
	default_params = { dam_mod = 1 },
	calculate = function(self, def, target, params)
		local eff = {}
		eff.params = params or {}
		eff.damage = (params.attack_with and params.attack_with.combat and type(params.attack_with.combat.dam) == "number" and params.attack_with.combat.dam) or 5
		eff.precision = (params.attack_with and params.attack_with.combat and type(params.attack_with.combat.precision) == "number" and params.attack_with.combat.precision) or 1
		-- lukep's size-hit formula
		local target_size = target:getSize()
		local prob_hit = target_size / (target_size + 5 * ((self.x - target.x)^2 + (self.y-target.y)^2))
		-- Apply the precision OR chain
		eff.prob = Probability.new{val = prob_hit}
		for i = 2, eff.precision do
			eff.prob = eff.prob / Probability.new{val = prob_hit}
		end
		eff.damtype = eff.params.damtype or DamageType.KINETIC
		eff.damage = eff.damage * ( eff.params.dam_mod or 1 )
		return eff
	end,
	activate = function(self, eff)
		if eff.prob() then
			DamageType:get(eff.damtype).projector(eff.source, eff.target.x, eff.target.y, eff.damtype, eff.damage)
		else
			game.log("%s misses.", eff.source.name:capitalize())
		end
	end,
}

newAtomicEffect{
	name = "KNOCKBACK",
	desc = "Knockback.",
	type = "physical",
	status = "detrimental",
	calculate = function(self, def, target, params)
		eff = {}
		-- Compute the probability of hitting
		eff.prob = Probability.new{val=0.50}
		eff.dist = params.dist or 5
		eff.source = self
		eff.params = params
		return eff
	end,
	activate = function(self, eff)
		if eff.prob() then
			game.logSeen(eff.target, "%s is knocked away from %s.", eff.target.name:capitalize(), eff.source.name)
			eff.target:knockback(eff.source.x, eff.source.y, eff.dist)
		end
	end,
}

newAtomicEffect{
	name = "RANGED_ATTACK",
	desc = "Ranged attack.",
	type = "physical",
	status = "detrimental",
	calculate = function(self, def, target, params)
		local eff = {}
		eff.params = params or {}
		eff.damage = (params.attack_with and params.attack_with.combat and type(params.attack_with.combat.dam) == "number" and params.attack_with.combat.dam) or 5
		eff.precision = (params.attack_with and params.attack_with.combat and type(params.attack_with.combat.precision) == "number" and params.attack_with.combat.precision) or 1
		-- lukep's size-hit formula
		local prob_hit = target.size / (target.size + 5 * ((self.x - target.x)^2 + (self.y-target.y)^2))
		-- Apply the precision OR chain
		eff.prob = Probability.new{val = prob_hit}
		for i = 2, eff.precision do
			eff.prob = eff.prob / Probability.new{val = prob_hit}
		end
		eff.damtype = eff.params.damtype or DamageType.KINETIC
		eff.damage = eff.damage * ( eff.params.dam_mod or 1 )
		return eff
	end,
	activate = function(self, eff)
		if eff.prob() then
			DamageType:get(eff.damtype).projector(eff.source, eff.target.x, eff.target.y, eff.damtype, eff.damage)
		end
	end,
}

newAtomicEffect{
	name = "ACIDBURN",
	desc = "Burning from acid",
	type = "physical",
	status = "detrimental",
	default_params = {dur=1},
	calculate = function(self, def, target, params)
		eff = {}
		eff.prob = Probability.new{val=1.0}
		eff.damage = params.damage or 5
		eff.dur = params.dur
		return eff
	end,
	activate = function() return true end,
	on_gain = function(self, err) return "#Target# is covered in acid!", "+Acid" end,
	on_lose = function(self, err) return "#Target# is free from the acid.", "-Acid" end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.CHEMICAL).projector(eff.source or self, self.x, self.y, DamageType.CHEMICAL, eff.damage)
	end,
}

newAtomicEffect{
	name = "DRAIN_BIOENERGY",
	desc = "Drains bioenergy.",
	type = "physical",
	status = "detrimental",
	default_params = {drain=1},
	calculate = function(self, def, target, params)
		local eff = {}
		-- Compute the probability of hitting
		eff.prob = Probability.new{val=1}
		eff.drain = params.drain
		eff.params = params
		return eff
	end,
	activate = function(self, eff)
		if eff.prob() then
			self.bioenergy_regen = self.bioenergy_regen - eff.drain
			return true
		end
	end,
	deactivate = function(self, eff)
		if eff.prob() then
			self.bioenergy_regen = self.bioenergy_regen + eff.drain
		end
	end,
}

newAtomicEffect{
	name = "GAIN_LIFE",
	desc = "Gain life.",
	type = "physical",
	status = "beneficial",
	default_params = {heal = 0},
	calculate = function(self, def, target, params)
		local eff = {}
		eff.params = params or {}
		eff.heal = eff.params.heal
		eff.prob = Probability.new{val = 1}
		return eff
	end,
	activate = function(self, eff)
		if eff.prob() then
			local old_life = eff.target.life
			eff.target:heal(eff.heal, eff.self)
			if eff.target.life > old_life then
				game.logSeen(eff.target, "%s heals %d.", eff.target.name:capitalize(), eff.target.life - old_life)
			end
		end
	end,
}	

newAtomicEffect{
	name = "DECREASE_BIOENERGY",
	desc = "Decreases bioenergy.",
	type = "physical",
	status = "detrimental",
	default_params = {drain=1},
	calculate = function(self, def, target, params)
		local eff = {}
		eff.params = params or {}
		eff.drain = params.drain
		eff.prob = Probability.new{val = 1}
		return eff
	end,
	activate = function(self, eff)
		if eff.prob() then
			eff.target:incBioenergy(-eff.drain)
		end
	end,
}


--[[ --this is going to take some more thought
newAtomicEffect{
	name = "ADD_COMBAT_EFFECT",
	desc = "Adds an atomic effect to a part's combat.",
	type = "physical",
	status = "beneficial",
	calculate = function(self, def, target, params)
		local eff = {}
		eff.prob = Probability.new{val=1}
		eff.part = params.part
		eff.params = params
		return eff
	end,
	activate = function(self, eff)
		if eff.prob() then
			eff.part.combat.on_hit = eff.part.combat.on_hit or {}
			eff.part.combat.on_hit
			return true
		end
	end,
	deactivate = function(self, eff)
		if eff.prob() then
			eff.part.combat.on_hit:removeTemporaryValue(eff.params.eff, eff.temp)
		end
	end,
}]]
