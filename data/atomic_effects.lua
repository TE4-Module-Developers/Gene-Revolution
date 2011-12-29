local Probability = require "mod.class.Probability"

newAtomicEffect{
	name = "MELEE_ATTACK",
	desc = "Melee attack.",
	type = "physical",
	status = "detrimental",
	calculate = function(self, def, target, params)
		eff = {}
		-- Compute the probability of hitting
		eff.prob = Probability.new{val=0.50}
		eff.damage = 5
		eff.damtype = params and params.damtype or DamageType.PHYSICAL
		eff.params = params
		return eff
	end,
	activate = function(self, eff)
		if eff.prob() then
			DamageType:get(eff.damtype).projector(eff.source, eff.target.x, eff.target.y, eff.damtype, eff.damage)
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
		eff.params = params
		return eff
	end,
	activate = function(self, eff)
		if eff.prob() then
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
		eff = {}
		-- Compute the probability of hitting
		eff.prob = Probability.new{val=0.25}
		eff.damage = 5
		eff.damtype = params and params.damtype or DamageType.PHYSICAL
		eff.params = params
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
	on_gain = function(self, err) return "#Target# is covered in acid!", "+Acid" end,
	on_lose = function(self, err) return "#Target# is free from the acid.", "-Acid" end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.ACID).projector(eff.source or self, self.x, self.y, DamageType.ACID, eff.damage)
	end,
}
