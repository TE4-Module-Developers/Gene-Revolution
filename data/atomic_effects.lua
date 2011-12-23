local Probability = require "mod.class.Probability"

newAtomicEffect{
	name = "MELEE_ATTACK",
	desc = "Melee attack.",
	type = "physical",
	status = "detrimental",
	calculate = function(self, source, target, params)
		eff = {def=self, source=source, target=target}
		-- Compute the probability of hitting
		eff.prob = Probability.new{val=0.50}
		eff.damage = 5
		eff.damtype = params and params.damtype or DamageType.PHYSICAL
		eff.params = params
		return eff
	end,
	apply = function(self, eff)
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
	calculate = function(self, source, target, params)
		eff = {def=self, source=source, target=target}
		-- Compute the probability of hitting
		eff.prob = Probability.new{val=0.50}
		eff.dist = params.dist or 5
		eff.params = params
		return eff
	end,
	apply = function(self, eff)
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
	calculate = function(self, source, target, params)
		eff = {def=self, source=source, target=target}
		-- Compute the probability of hitting
		eff.prob = Probability.new{val=0.25}
		eff.damage = 5
		eff.damtype = params and params.damtype or DamageType.PHYSICAL
		eff.params = params
		return eff
	end,
	apply = function(self, eff)
		if eff.prob() then
			DamageType:get(eff.damtype).projector(eff.source, eff.target.x, eff.target.y, eff.damtype, eff.damage)
		end
	end,
}
