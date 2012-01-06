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

local DamageType = require "engine.DamageType"
local Probability = require "mod.class.Probability"

newTalentType{ type="role/combat", name = "combat", description = "Combat techniques" }

newTalent{
	name = "Punch",
	type = {"role/combat", 1},
	points = 1,
	range = 1,
	effects = function(actor, part, t)
		local tg = {type="hit", range=part:getTalentRange(t)}
		local x, y, target = actor:getTarget(tg)
		if not x or not y or not target then game.logPlayer(actor, "No valid target selected.") return end
		if core.fov.distance(actor.x, actor.y, x, y) > 1 then return nil end
		return actor:melee_attack_effects(target, {attack_with = part })
	end,
	info = function(actor, part, t)
		return "A solid right hook."
	end,
}

newTalent{
	name = "Concussive Punch",
	type = {"role/combat", 1},
	points = 1,
	cooldown = 6,
	bioenergy = 5,
	range = 1,
	effects = function(actor, part, t)
		local tg = {type="hit", range=part:getTalentRange(t)}
		local x, y, target = actor:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(actor.x, actor.y, x, y) > 1 then return nil end

		local effs = actor:melee_attack_effects(target, {attack_with = part})
		local knockback = actor:calcEffect("ATOMICEFF_KNOCKBACK", target, {dist=2})
		-- Modify the knockback probability to only fire if "hit" lands
		knockback.prob = knockback.prob * effs.hit.prob
		effs[#effs+1] = knockback
		return effs
	end,
	info = function(actor, part, t)
		return "A punch followed by a compressed blast of air."
	end,
}

newTalent{
	name = "Acid Spray",
	type = {"role/combat", 1},
	points = 1,
	cooldown = 6,
	bioenergy = 2,
	range = 6,
	effects = function(actor, part, t)
		local tg = {type="ball", range=part:getTalentRange(t), radius=1, talent=t}
		local x, y = actor:getTarget(tg)
		if not x or not y then return nil end

		local effs = {}
		actor:project(tg, x, y, function(px, py, tg, actor)
			local act = game.level.map(px, py, engine.Map.ACTOR)
			if act then
				local hit = actor:calcEffect("ATOMICEFF_ACIDBURN", act, {damage=3, dur=4})
				effs[#effs+1] = hit
			end
		end)
		return effs
	end,
	info = function(actor, part, t)
		return "Spit a large amount of acid."
	end,
}

newTalent{
	name = "Acid Bite", --could also be a sustain that drain bioenergy on-hit
	type = {"role/combat", 1},
	points = 1,
	range = 1,
	effects = function(actor, part, t)
		local tg = {type="hit", range=part:getTalentRange(t)}
		local x, y, target = actor:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(actor.x, actor.y, x, y) > 1 then return nil end

		local effs = actor:melee_attack_effects(target, {attack_with = part })
		local acid_bite = actor:calcEffect("ATOMICEFF_ACIDBURN", target, {damage=2, dur = 3})
		acid_bite.prob = acid_bite.prob * effs.hit.prob
		effs[#effs+1] = acid_bite
		return effs
	end,
	info = function(self, t)
		return "You bite your target with an acidic saliva attack."
	end,
}

newTalent{
	name = "Devour",
	type = {"role/combat", 1},
	points = 1,
	range = 1,
	effects = function(actor, part, t)
		local tg = {type="hit", range=part:getTalentRange(t)}
		local x, y, target = actor:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(actor.x, actor.y, x, y) > 1 then return nil end

		local dam_mod = target:hasEffect("ATOMICEFF_ACIDBURN") and 2 or 1
		local effs = actor:melee_attack_effects(target, {attack_with = part, dam_mod = dam_mod})
		local total_damage = 0
		for i, eff in ipairs(effs) do
			total_damage = total_damage + (eff.damage or 0)
		end
		local heal = actor:calcEffect("ATOMICEFF_GAIN_LIFE", self, {heal = total_damage/2})
		heal.prob = heal.prob * effs.hit.prob
		effs[#effs+1] = heal
		return effs
	end,
	info = function(self, t)
		return "With great ferocity, you devour a portion of your target, healing yourself for 50%% of the damage.  The damage is doubled if the target is covered with acid."
	end,
}

newTalent{
	name = "Power Sweep",
	type = {"role/combat", 1},
	points = 1,
	range = 1,
	cooldown = 4,
	bioenergy = 10,
	effects = function(actor, part, t)
		local tg = {type="hit", range=part:getTalentRange(t)}
		local x, y, target = actor:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(actor.x, actor.y, x, y) > 1 then return nil end
		local dir = util.getDir(x, y, actor.x, actor.y)
		if dir == 5 then return nil end

		local lx, ly = util.coordAddDir(actor.x, actor.y, dir_sides[dir].left)
		local rx, ry = util.coordAddDir(actor.x, actor.y, dir_sides[dir].right)
		local lt, rt = game.level.map(lx, ly, Map.ACTOR), game.level.map(rx, ry, Map.ACTOR)
		
		local effs = actor:melee_attack_effects(target, {attack_with = part, dam_mod = 2})
		if lt then
			local tmp = actor:melee_attack_effects(lt, {attack_with = part, dam_mod = 2})
			for i, eff in ipairs(tmp) do
				effs[#effs+1] = eff
			end
		end
		if rt then
			local tmp = actor:melee_attack_effects(lt, {attack_with = part, dam_mod = 2})
			for i, eff in ipairs(tmp) do
				effs[#effs+1] = eff
			end
		end
		return effs
	end,
	info = function(self, t)
		return "Sweep out with your arm, attacking your target and any adjacent."
	end,
}

newTalent{
	name = "Ground Pound",
	type = {"role/combat", 1},
	points = 1,
	range = 1,
	cooldown = 10,
	bioenergy = 15,
	effects = function(actor, part, t)
		local tg = {type="ball", radius=1, talent=t}
		local effs = {}
		actor:project(tg, actor.x, actor.y, function(px, py, tg, actor)
			local act = game.level.map(px, py, engine.Map.ACTOR)
			if act and act ~= actor then
				local current = actor:melee_attack_effects(act, {attack_with = part, dam_mod = 0.5})
				current.hit.prob = Probability.new{ val = 1 }
				for i, eff in ipairs(current) do
					effs[#effs + 1] = eff
				end
			end
		end)
		return effs
	end,
	info = function(self, t)
		return "Smash the ground, hitting all adjacent foes."
	end,
}
