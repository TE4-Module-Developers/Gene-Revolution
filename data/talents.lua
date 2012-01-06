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
	name = "Attack",
	type = {"role/combat", 1},
	points = 1,
	range = 1,
	get_effects = function(self, target, params)
		local effs = {}
		local hit = self:calcEffect("ATOMICEFF_MELEE_ATTACK", target, params)
		effs[1] = hit
		if params.attack_with and params.attack_with.combat.on_hit then
			for eff, par in pairs(params.attack_with.combat.on_hit) do
				local current = self:calcEffect(eff, (par.force_target == "self" and self) or target, par) -- default to hitting target
				current.prob = current.prob * hit.prob -- only apply if the melee attack hits
				-- there may be sitautions where you want an effect to always apply (or only on misses)
				effs[#effs + 1] = current
			end
		end
		return effs
	end,
	effects = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		local part
		if self:getInven(self.INVEN_MAINHAND) then part = self:getInven(self.INVEN_MAINHAND)[1] end
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		--local hit = self:calcEffect("ATOMICEFF_MELEE_ATTACK", target, {attack_with = part})
		return t.get_effects(self, target, {attack_with = part})
	end,
	info = function(self, t)
		return "Attack!"
	end,
}

newTalent{
	name = "Knockback",
	type = {"role/combat", 1},
	points = 1,
	cooldown = 6,
	bioenergy = 5,
	range = 1,
	effects = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local part
		if self:getInven(self.INVEN_MAINHAND) then part = self:getInven(self.INVEN_MAINHAND)[1] end
		local hit = self:calcEffect("ATOMICEFF_MELEE_ATTACK", target, {attack_with = part, dam_mod = 1.5})
		local knockback = self:calcEffect("ATOMICEFF_KNOCKBACK", target, {dist=2})
		-- Modify the knockback probability to only fire if "hit" lands
		knockback.prob = knockback.prob * hit.prob
		return {hit, knockback}
	end,
	info = function(self, t)
		return "Knock back a foe with a mighty swing of your arm."
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
				local hit = self:calcEffect("ATOMICEFF_ACIDBURN", act, {damage=3, dur=4})
				effs[#effs+1] = hit
			end
		end)
		return effs
	end,
	info = function(self, t)
		return "Zshhhhhhhhh!"
	end,
}

newTalent{
	name = "Run",
	type = {"role/combat", 1},
	points = 1,
	cooldown = 1,
	mode="sustained",
	effects = function(self, t)
		local running = self:calcEffect("ATOMICEFF_DRAIN_BIOENERGY", self, {drain=2})
		-- Hack it to look like a temporary effect?
		running.dur = 1
		running.decrease = 0
		return {running}
	end,
	info = function(self, t)
		return "Run!"
	end,
}

newTalent{
	name = "Acid Bite", --could also be a sustain that drain bioenergy on-hit
	type = {"role/combat", 1},
	points = 1,
	range = 1,
	effects = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hit = self:calcEffect("ATOMICEFF_MELEE_ATTACK", target)
		local acid_bite = self:calcEffect("ATOMICEFF_ACIDBURN", target, {damage=2, dur = 3})
		acid_bite.prob = acid_bite.prob * hit.prob
		return {hit, acid_bite}
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
	effects = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		local part
		if self:getInven(self.INVEN_MAINHAND) then part = self:getInven(self.INVEN_MAINHAND)[1] end
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local dam_mod = target:hasEffect("ATOMICEFF_ACIDBURN") and 2 or 1
		local hit = self:calcEffect("ATOMICEFF_MELEE_ATTACK", target, {attack_with = part, dam_mod = dam_mod})
		local heal = self:calcEffect("ATOMICEFF_GAIN_LIFE", self, {heal = hit.damage/2})
		return {hit, heal}
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
	effects = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local dir = util.getDir(x, y, self.x, self.y)
		if dir == 5 then return nil end
		local lx, ly = util.coordAddDir(self.x, self.y, dir_sides[dir].left)
		local rx, ry = util.coordAddDir(self.x, self.y, dir_sides[dir].right)
		local lt, rt = game.level.map(lx, ly, Map.ACTOR), game.level.map(rx, ry, Map.ACTOR)
		
		local part
		if self:getInven(self.INVEN_MAINHAND) then part = self:getInven(self.INVEN_MAINHAND)[1] end
		local eff = {self:calcEffect("ATOMICEFF_MELEE_ATTACK", target, {attack_with = part, dam_mod = 2})}
		if lt then
			eff[#eff + 1] = self:calcEffect("ATOMICEFF_MELEE_ATTACK", lt, {attack_with = part, dam_mod = 2})
		end
		if rt then
			eff[#eff + 1] = self:calcEffect("ATOMICEFF_MELEE_ATTACK", rt, {attack_with = part, dam_mod = 2})
		end
		return eff
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
	effects = function(self, t)
		local part
		if self:getInven(self.INVEN_MAINHAND) then part = self:getInven(self.INVEN_MAINHAND)[1] end
		local eff = {}
		for i = -1, 1 do for j = -1, 1 do
			local x, y = self.x + i, self.y + j
			if (self.x ~= x or self.y ~= y) and game.level.map:isBound(x, y) and game.level.map(x, y, Map.ACTOR) then
				local target = game.level.map(x, y, Map.ACTOR)
				local current = self:calcEffect("ATOMICEFF_MELEE_ATTACK", target, {dam_mod = 0.5})
				current.prob = Probability.new{val = prob_hit}
				eff[#eff + 1] = current
			end
		end end
		return eff
	end,
	info = function(self, t)
		return "Smash the ground, hitting all adjacent foes."
	end,
}