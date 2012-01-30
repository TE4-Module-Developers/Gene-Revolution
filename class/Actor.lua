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
require "mod.class.interface.ActorInventory"
require "mod.class.interface.Combat"
require "mod.class.interface.AtomicEffects"
local Map = require "engine.Map"

module(..., package.seeall, class.inherit(
	engine.Actor,
	engine.interface.ActorLife,
	engine.interface.ActorProject,
	engine.interface.ActorStats,
	engine.interface.ActorResource,
	engine.interface.ActorFOV,
	mod.class.interface.ActorInventory,
	mod.class.interface.Combat,
	mod.class.interface.AtomicEffects
))

function _M:init(t, no_default)
	-- Default regen
	t.life_regen = t.life_regen or 0.25 -- Life regen real slow
	t.fidelity_regen = t.fidelity_regen or 0 -- fidelity/sync (and regen) from parts, not (typically) innate
	t.sync_regen = t.sync_regen or 0
	t.bioenergy_regen = t.bioenergy_regen or 10

	-- Default melee barehanded damage

	engine.Actor.init(self, t, no_default)
	engine.interface.ActorLife.init(self, t)
	engine.interface.ActorProject.init(self, t)
	engine.interface.ActorResource.init(self, t)
	engine.interface.ActorStats.init(self, t)
	engine.interface.ActorFOV.init(self, t)
	mod.class.interface.ActorInventory.init(self, t)
	mod.class.interface.AtomicEffects.init(self, t)

end

function _M:act()
	if not engine.Actor.act(self) then return end

	self.changed = true

	-- Regen resources
	self:regenLife()
	self:regenResources()
	-- Compute timed effects
	self:timedEffects()
	-- Cooldowns on all attached parts
	for i, inven in ipairs(self.inven) do
		if inven.name ~= "INVEN" then
			for j, part in ipairs(inven) do
				part:cooldownTalents()
			end
		end
	end

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
	local parts_list = ""
	local collect_parts
	collect_parts = function(part)
		parts_list = parts_list .. part.name .. ", "
	end
	self:applyToWornParts(collect_parts)
	return ([[%s%s
#ff0000#HP: %d (%d%%)
Bioenergy: %d (%d%%)
Stats: %d /  %d / %d
Parts: %s
%s]]):format(
	self:getDisplayString(),
	self.name,
	self.life, self.life * 100 / self.max_life,
	self:getBioenergy(), self:getBioenergy() * 100 / self:getMaxBioenergy(),
	self:getStr(),
	self:getDex(),
	self:getCon(),
	parts_list,
	self.desc or ""
	)
end

function _M:onTakeHit(value, src)
	return value
end

function _M:die(src)
	engine.interface.ActorLife.die(self, src)

	-- Extract and drop the genes first
	local extract_genes
	extract_genes = function(part, slot)
		if part.slot == "GENE" or part.slot == "MODULE" then
			if part.parent then
				part.parent:removeObject(slot, part.parent:itemPosition(slot, part), true)
			end
			game.level.map:addObject(self.x, self.y, part)
		end
	end
	self:applyToWornParts(extract_genes)
	-- Drop the parts
	for i, slot in pairs(self.inven) do
		for j=1,slot.max do
			local part = slot[j]
			if part then
				self:removeObject(slot, j, true)
				game.level.map:addObject(self.x, self.y, part)
			end
		end
	end
	return true
end

--- Notifies a change of stat value
function _M:onStatChange(stat, v)
	if stat == self.STAT_CON then
		self.max_life = self.max_life + 2
	end
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

--- Show usage dialog
function _M:useTalents(add_cols)
	local d = require("mod.dialogs.UseTalents").new(self, add_cols)
	game:registerDialog(d)
end

-- @param filter A function(part, tid) that will filter out returned talents.
function _M:getTalents(filter)
	local talents = {}
	local collect_talent
	collect_talent = function(part)
		for tid, lvl in pairs(part.talents) do
			if not filter or filter(part, tid) then
				talents[#talents+1] = {part=part, tid=tid}
			end
		end
	end
	self:applyToWornParts(collect_talent)
	return talents
end

--- Actor is being attacked!
-- Module authors should rewrite it to handle combat, dialog, ...
-- @param target the actor attacking us
function _M:attack(target, x, y)
	game.logSeen(target, "%s tries to attack %s.", self.name:capitalize(), target.name:capitalize())
end

function _M:melee_attack_effects(target, params)
	local effs = {}
	local hit = self:calcEffect("ATOMICEFF_MELEE_ATTACK", target, params)
	effs[1] = hit
	effs.hit = hit
	if params.attack_with and params.attack_with.combat and params.attack_with.combat.on_hit then
		for eff, par in pairs(params.attack_with.combat.on_hit) do
			-- default to hitting target
			local current = self:calcEffect(eff, par.target or target, par)
			-- only apply if the melee attack hits
			current.prob = current.prob * hit.prob
			-- there may be situations where you want an effect to always apply (or only on misses)
			effs[#effs + 1] = current
		end
	end
	return effs
end

function _M:getFidelityEff()  -- ranges from 20% (at 0) to 100% (at max)
	if not self.max_fidelity or self.max_fidelity == 0 then return 0.2 end
	return (self:getFidelity()*.8 + self.max_fidelity*0.2)/(self.max_fidelity)
end

function _M:getSyncEff()
	if not self.max_sync or self.max_sync == 0  then return 0.2 end
	return (self:getSync()*.8 + self.max_sync*0.2)/(self.max_sync)
end