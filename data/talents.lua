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
		local hit = actor:calcEffect("ATOMICEFF_MELEE_ATTACK", target, {weapon=part})
		return {hit}
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
	bioenergy = 2,
	range = 1,
	effects = function(actor, part, t)
		local tg = {type="hit", range=part:getTalentRange(t)}
		local x, y, target = actor:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(actor.x, actor.y, x, y) > 1 then return nil end

		local hit = actor:calcEffect("ATOMICEFF_MELEE_ATTACK", target, {weapon=part})
		local knockback = actor:calcEffect("ATOMICEFF_KNOCKBACK", target, {dist=2})
		-- Modify the knockback probability to only fire if "hit" lands
		knockback.prob = knockback.prob * hit.prob
		return {hit, knockback}
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
				local hit = actor:calcEffect("ATOMICEFF_ACIDBURN", act, {damage=1, dur=4})
				effs[#effs+1] = hit
			end
		end)
		return effs
	end,
	info = function(actor, part, t)
		return "Spit a large amount of acid."
	end,
}
