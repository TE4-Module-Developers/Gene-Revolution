-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

local AtomicEffects = require "mod.class.AtomicEffects"
local DamageType = require "engine.DamageType"

newTalentType{ type="role/combat", name = "combat", description = "Combat techniques" }

newTalent{
	name = "Attack",
	type = {"role/combat", 1},
	points = 1,
	range = 1,
	effects = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hit = AtomicEffects:getEffectFromId(AtomicEffects.ATOMICEFF_MELEE_ATTACK):calculate(self, target)
		return {hit}
	end,
	action = function(self, t)
		local effs = t.effects(self, t)
		if not effs then return end

		for i, eff in ipairs(effs) do
			game.log("Effect %s has a %d%% of hitting.", eff.def.name, eff.prob:predict())
			eff.def:apply(eff)
			game.log("Effect %s %s.", eff.def.name, eff.prob._result and "succeeded" or "failed")
		end

		return true
	end,
	info = function(self, t)
		return "Attack!"
	end,
}

newTalent{
	name = "Kick",
	type = {"role/combat", 1},
	points = 1,
	cooldown = 6,
	bioenergy = 2,
	range = 1,
	effects = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hit = AtomicEffects:getEffectFromId(AtomicEffects.ATOMICEFF_MELEE_ATTACK):calculate(self, target)
		local knockback = AtomicEffects:getEffectFromId(AtomicEffects.ATOMICEFF_KNOCKBACK):calculate(self, target, {dist=2})
		-- Modify the knockback probability to only fire if "hit" lands
		knockback.prob:add_and(hit.prob)
		return {hit, knockback}
	end,
	action = function(self, t)
		local effs = t.effects(self, t)
		if not effs then return end

		for i, eff in ipairs(effs) do
			game.log("Effect %s has a %d%% of hitting.", eff.def.name, eff.prob:predict())
			eff.def:apply(eff)
			game.log("Effect %s %s.", eff.def.name, eff.prob._result and "succeeded" or "failed")
		end

		return true
	end,
	info = function(self, t)
		return "Kick!"
	end,
}

newTalent{
	name = "Acid Spray",
	type = {"role/combat", 1},
	points = 1,
	cooldown = 6,
	bioenergy = 2,
	range = 6,
	effects = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=1, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local effs = {}
		self:project(tg, x, y, function(px, py, tg, self)
			local act = game.level.map(px, py, engine.Map.ACTOR)
			if act then
				local hit = AtomicEffects:getEffectFromId(AtomicEffects.ATOMICEFF_RANGED_ATTACK):calculate(self, act, {damtype=DamageType.ACID})
				effs[#effs+1] = hit
			end
		end)
		return effs
	end,
	action = function(self, t)
		local effs = t.effects(self, t)
		if not effs then return end

		for i, eff in ipairs(effs) do
			game.log("Effect %s has a %d%% of hitting.", eff.def.name, eff.prob:predict())
			eff.def:apply(eff)
			game.log("Effect %s %s.", eff.def.name, eff.prob._result and "succeeded" or "failed")
		end

		return true
	end,
	info = function(self, t)
		return "Zshhhhhhhhh!"
	end,
}

