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
newTalentType{ type="vine/passive", name = "vine", description = "Passive vegetation" }
newTalentType{ type="terrantech/active", name = "terrantech", description = "Terran technologies"}

-- Basic melee talent

newTalent{
	name = "Punch",
	type = {"role/combat", 1},
	points = 1,
	range = 1,
	requires_target = true,
	target = function(part, t)
		return {type="hit", range=part:getTalentRange(t)}
	end,
	effects = function(actor, part, t)
		local tg = part:getTalentTarget(t)
		local x, y, target = actor:getTarget(tg)
		if not x or not y or not target then game.logPlayer(actor, "No valid target selected.") return end
		if core.fov.distance(actor.x, actor.y, x, y) > 1 then return nil end
		return actor:melee_attack_effects(target, {attack_with = part })
	end,
	info = function(actor, part, t)
		return "A solid right hook."
	end,
}

-----------------------------------  BIONIC PARTS  -----------------------------------------

-- Pneumatic Arm

newTalent{
	name = "Concussive Punch",
	type = {"role/combat", 1},
	points = 1,
	cooldown = 6,
	bioenergy = 15,
	range = 1,
	requires_target = true,
	target = function(part, t)
		return {type="hit", range=part:getTalentRange(t)}
	end,
	effects = function(actor, part, t)
		local tg = part:getTalentTarget(t)
		local x, y, target = actor:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(actor.x, actor.y, x, y) > 1 then return nil end
		
		local effs = actor:melee_attack_effects(target, {attack_with = part})
		local knockback = actor:calcEffect("ATOMICEFF_KNOCKBACK", target, {dist=math.ceil(2)})
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
	name = "Power Sweep",
	type = {"role/combat", 1},
	points = 1,
	range = 1,
	cooldown = 4,
	bioenergy = 20,
	requires_target = true,
	target = function(part, t)
		return {type="hit", range=part:getTalentRange(t)}
	end,
	effects = function(actor, part, t)
		local tg = part:getTalentTarget(t)
		local x, y, target = actor:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(actor.x, actor.y, x, y) > 1 then return nil end
		local dir = util.getDir(x, y, actor.x, actor.y)
		if dir == 5 then return nil end

		local sides = util.dirSides(dir, actor.x, actor.y)
		local lx, ly = util.coordAddDir(actor.x, actor.y, sides.left)
		local rx, ry = util.coordAddDir(actor.x, actor.y, sides.right)
		local lt, rt = game.level.map(lx, ly, Map.ACTOR), game.level.map(rx, ry, Map.ACTOR)

		local effs = actor:melee_attack_effects(target, {attack_with = part, dam_mod = 2})
		if lt then
			local tmp = actor:melee_attack_effects(lt, {attack_with = part, dam_mod = 2})
			for i, eff in ipairs(tmp) do
				effs[#effs+1] = eff
			end
		end
		if rt then
			local tmp = actor:melee_attack_effects(rt, {attack_with = part, dam_mod = 2})
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
	bioenergy = 30,
	requires_target = true,
	target = function(part, t)
		return {type="ball", radius=1, talent=t}
	end,
	effects = function(actor, part, t)
		local tg = part:getTalentTarget(t)
		local effs = {}
		actor:project(tg, actor.x, actor.y, function(px, py, tg, actor)
			local act = game.level.map(px, py, engine.Map.ACTOR)
			if act and act ~= actor then
				local current = actor:melee_attack_effects(act, {attack_with = part, dam_mod = 0.75})
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

-----------------------------------  GENETICS  -----------------------------------------

-- Alien Head

newTalent{
	name = "Acid Spray",
	type = {"role/combat", 1},
	points = 1,
	cooldown = 6,
	bioenergy = 30,
	range = 6,
	requires_target = true,
	target = function(part, t)
		return {type="ball", range=part:getTalentRange(t), radius=1, talent=t}
	end,
	effects = function(actor, part, t)
		local tg = part:getTalentTarget(t)
		local x, y = actor:getTarget(tg)
		if not x or not y then return nil end

		local effs = {}
		actor:project(tg, x, y, function(px, py, tg, actor)
			local act = game.level.map(px, py, engine.Map.ACTOR)
			if act then
				local hit = actor:calcEffect("ATOMICEFF_ACIDBURN", act, {damage=3 , dur=4})
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
	name = "Acid Bite", --could also be a sustain that drains bioenergy on-hit
	type = {"role/combat", 1},
	points = 1,
	range = 1,
	cooldown = 5,
	bioenergy = 15,
	requires_target = true,
	target = function(part, t)
		return {type="hit", range=part:getTalentRange(t)}
	end,
	effects = function(actor, part, t)
		local tg = part:getTalentTarget(t)
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
	cooldown = 10,
	bioenergy = 30,
	requires_target = true,
	target = function(part, t)
		return {type="hit", range=part:getTalentRange(t)}
	end,
	effects = function(actor, part, t)
		local tg = part:getTalentTarget(t)
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

-----------------------------------  PLANTS  -----------------------------------------

-- Vine

newTalent{
	name = "Impale",
	type = {"role/combat",1},
	points = 1,
	range = 3,
	cooldown = 10,
	bioenergy = 30,
	target = function(part, t)
		return {type="hit", range=part:getTalentRange(t)}
	end,
	effects = function(actor, part, t)
		local tg = part:getTalentTarget(t)
		local x, y, target = actor:getTarget(tg)
		if not x or not y or not target then return nil end
	end,
	info = function(self,t)
		return "Thick vines shoots from the ground, attempting to impale it's target."
	end,
}

newTalent{
	name = "Trudge",
	type = {"vine/passive",1},
	points = 1,
	mode = "passive",
	on_learn = function(self,t)
		movespeed = 0.5
	end,
	on_unlearn = function(self,t)
		movespeed = 0
	end,
	info = function(self,t)
		return ("Enables moving through the ground at half movement speed.")
	end,
}

-----------------------------------  GRENADES  -----------------------------------------

-- Ideally I'd like some grenades to pop after X game time (this is the standard for 
-- grenades), rather than pop on impact.


newTalent{
	name = "Throw Frag Grenade",
	type = {"terrantech/active", 1},
	points = 1,
	cooldown = 0,
	range = 6,
	direct_hit = true,
	requires_target = true,
	proj_speed = 2.5,
	fragments = 12, -- We may want to make this variable so that it can go into more directions and damage more heavily if multiple fragments go through the same actor
	up_frags = 4,   -- the amount of fragments that goes "up" ie. hitting the person in the epicenter.				
	frag_damage = 2,-- Damage per fragment
	getDuration = function(self, t) return 1 end,
	getDamage = function(self, t) return 5 end,  -- each of the chemical explosion parts
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=3, talent=t}   
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		actor:project(tg, x, y, function(px, py, tg, actor)
			local act = game.level.map(px, py, engine.Map.ACTOR)
			if act then
				
				-- explode tg,tg2,tg3
				for radius = 1,3 do
					local _ _, _, _, x, y = self:canProject(tg, x, y)
					-- Add a lasting map effect  (copied from fireflash) that inferno part is obviously not correct
					game.level.map:addEffect(self,x, y, t.getDuration(self, t),	DamageType.ENERGY, t.getDamage(self, t),
					radius, 5, nil,{type="inferno"},	nil)
				end
				
				-- run through all the fragments
				for i = 1, fragments do
					self:project(tg, x, y, DamageType.KINETIC, frag_damage)
				end
			end
		end)
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[Throw a Fragmentation grenade. It explodes on contact doing energetic damage at the center of the explosion, and 
		releasing fragments in all directions doing kenetic damage. Explosion damage is reduced further from the epicenter.]])
	end,
}

newTalent{
	--- copied from smoke bomb alchemist spell in ToME some things may be redudant
	name = "Throw Smoke Grenade",
	type = {"terrantech/active", 1},
	points = 1,
	cooldown = 0,
	range = 5,
	direct_hit = true,
	requires_target = true,
	getDuration = function(self, t) return 5 end,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=1, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local e = Object.new{
				block_sight=true,
				temporary = t.getDuration(self, t),
				x = px, y = py,
				canAct = false,
				act = function(self)
					self:useEnergy()
					self.temporary = self.temporary - 1
					if self.temporary <= 0 then
						game.level.map:remove(self.x, self.y, engine.Map.TERRAIN+2)
						game.level:removeEntity(self)
						game.level.map:redisplay()
					end
				end,
				summoner_gain_exp = true,
				summoner = self,
			}
			game.level:addEntity(e)
			game.level.map(px, py, Map.TERRAIN+2, e)
		end, nil, {type="dark"})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[Throw a smoke grenade, blocking line of sight. The smoke dissipates after 5 turns.]])
	end,
}