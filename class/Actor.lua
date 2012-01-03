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

require "engine.class"
require "engine.Actor"
require "engine.Autolevel"
require "engine.interface.ActorLife"
require "engine.interface.ActorProject"
require "engine.interface.ActorStats"
require "engine.interface.ActorResource"
require "engine.interface.ActorFOV"
require "engine.interface.ActorInventory"
require "mod.class.interface.Combat"
require "mod.class.interface.AtomicEffects"
require "mod.class.interface.ActorTalents"
local Map = require "engine.Map"

module(..., package.seeall, class.inherit(
	engine.Actor,
	engine.interface.ActorLife,
	engine.interface.ActorProject,
	engine.interface.ActorStats,
	engine.interface.ActorResource,
	engine.interface.ActorFOV,
	engine.interface.ActorInventory,
	mod.class.interface.Combat,
	mod.class.interface.AtomicEffects,
	mod.class.interface.ActorTalents
))

function _M:init(t, no_default)
	-- Define some basic combat stats
	t.size = 25 -- 25 is the "humanoid" reference size, used in combat accuracy calculations

	-- Default regen
	t.life_regen = t.life_regen or 0.25 -- Life regen real slow
	t.bioenergy_regen = t.bioenergy_regen or 1

	-- Default melee barehanded damage

	engine.Actor.init(self, t, no_default)
	engine.interface.ActorLife.init(self, t)
	engine.interface.ActorProject.init(self, t)
	engine.interface.ActorResource.init(self, t)
	engine.interface.ActorStats.init(self, t)
	engine.interface.ActorFOV.init(self, t)
	engine.interface.ActorInventory.init(self, t)
	mod.class.interface.AtomicEffects.init(self, t)
	mod.class.interface.ActorTalents.init(self, t)

	self.talents[self.T_ATTACK] = self.talents[self.T_ATTACK] or 1

end

function _M:act()
	if not engine.Actor.act(self) then return end

	self.changed = true

	-- Cooldown talents
	self:cooldownTalents()
	-- Regen resources
	self:regenLife()
	self:regenResources()
	-- Compute timed effects
	self:timedEffects()

	-- Still enough energy to act ?
	if self.energy.value < game.energy_to_act then return false end

	return true
end

function _M:move(x, y, force)
	local moved = false
	local ox, oy = self.x, self.y
	if force or self:enoughEnergy() then
		moved = engine.Actor.move(self, x, y, force)
		if not force and moved and (self.x ~= ox or self.y ~= oy) and not self.did_energy then self:useEnergy() end
	end
	self.did_energy = nil
	return moved
end

function _M:tooltip()
	return ([[%s%s
#ff0000#HP: %d (%d%%)
Stats: %d /  %d / %d
%s]]):format(
	self:getDisplayString(),
	self.name,
	self.life, self.life * 100 / self.max_life,
	self:getStr(),
	self:getDex(),
	self:getCon(),
	self.desc or ""
	)
end

function _M:onTakeHit(value, src)
	return value
end

function _M:die(src)
	engine.interface.ActorLife.die(self, src)

	return true
end

--- Notifies a change of stat value
function _M:onStatChange(stat, v)
	if stat == self.STAT_CON then
		self.max_life = self.max_life + 2
	end
end

function _M:attack(target)
	self:bumpInto(target)
end


--- Called before a talent is used
-- Check the actor can cast it
-- @param ab the talent (not the id, the table)
-- @return true to continue, false to stop
function _M:preUseTalent(ab, silent)
	if not self:enoughEnergy() then print("fail energy") return false end

	if ab.mode == "sustained" then
		if ab.sustain_bioenergy and self:getMaxBioenergy() < ab.sustain_bioenergy and not self:isTalentActive(ab.id) then
			game.logPlayer(self, "You do not have enough bioenergy to activate %s.", ab.name)
			return false
		end
	else
		if ab.bioenergy and self:getBioenergy() < ab.bioenergy then
			game.logPlayer(self, "You do not have enough bioenergy to activate %s.", ab.name)
			return false
		end
	end

	if not silent then
		-- Allow for silent talents
		if ab.message ~= nil then
			if ab.message then
				game.logSeen(self, "%s", self:useTalentMessage(ab))
			end
		elseif ab.mode == "sustained" and not self:isTalentActive(ab.id) then
			game.logSeen(self, "%s activates %s.", self.name:capitalize(), ab.name)
		elseif ab.mode == "sustained" and self:isTalentActive(ab.id) then
			game.logSeen(self, "%s deactivates %s.", self.name:capitalize(), ab.name)
		else
			game.logSeen(self, "%s uses %s.", self.name:capitalize(), ab.name)
		end
	end
	return true
end

--- Called before a talent is used
-- Check if it must use a turn, mana, stamina, ...
-- @param ab the talent (not the id, the table)
-- @param ret the return of the talent action
-- @return true to continue, false to stop
function _M:postUseTalent(ab, ret)
	if not ret then return end

	self:useEnergy()

	if ab.mode == "sustained" then
		if not self:isTalentActive(ab.id) then
			if ab.sustain_bioenergy then
				self:incMaxBioenergy(-ab.sustain_bioenergy)
			end
		else
			if ab.sustain_bioenergy then
				self:incMaxBioenergy(ab.sustain_bioenergy)
			end
		end
	else
		if ab.bioenergy then
			self:incBioenergy(-ab.bioenergy)
		end
	end

	return true
end

--- Return the full description of a talent
-- You may overload it to add more data (like power usage, ...)
function _M:getTalentFullDescription(t)
	local d = {}

	if t.mode == "passive" then d[#d+1] = "#6fff83#Use mode: #00FF00#Passive"
	elseif t.mode == "sustained" then d[#d+1] = "#6fff83#Use mode: #00FF00#Sustained"
	else d[#d+1] = "#6fff83#Use mode: #00FF00#Activated"
	end

	if t.power or t.sustain_power then d[#d+1] = "#6fff83#Power cost: #7fffd4#"..(t.power or t.sustain_power) end
	if self:getTalentRange(t) > 1 then d[#d+1] = "#6fff83#Range: #FFFFFF#"..self:getTalentRange(t)
	else d[#d+1] = "#6fff83#Range: #FFFFFF#melee/personal"
	end
	if t.cooldown then d[#d+1] = "#6fff83#Cooldown: #FFFFFF#"..t.cooldown end

	return table.concat(d, "\n").."\n#6fff83#Description: #FFFFFF#"..t.info(self, t)
end

--- Can the actor see the target actor
-- This does not check LOS or such, only the actual ability to see it.<br/>
-- Check for telepathy, invisibility, stealth, ...
function _M:canSee(actor, def, def_pct)
	if not actor then return false, 0 end

	if def ~= nil then
		return def, def_pct
	else
		return true, 100
	end
end
