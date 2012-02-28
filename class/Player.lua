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
require "mod.class.Actor"
require "engine.interface.PlayerRest"
require "engine.interface.PlayerRun"
require "engine.interface.PlayerMouse"
require "engine.interface.PlayerHotkeys"
local Map = require "engine.Map"
local Dialog = require "engine.Dialog"
local DeathDialog = require "mod.dialogs.DeathDialog"
local Astar = require"engine.Astar"
local DirectPath = require"engine.DirectPath"

--- Defines the player
-- It is a normal actor, with some redefined methods to handle user interaction.<br/>
-- It is also able to run and rest and use hotkeys
module(..., package.seeall, class.inherit(
	mod.class.Actor,
	engine.interface.PlayerRest,
	engine.interface.PlayerRun,
	engine.interface.PlayerMouse,
	engine.interface.PlayerHotkeys
))

function _M:init(t, no_default)
	t.display=t.display or '@'
	t.color_r=t.color_r or 230
	t.color_g=t.color_g or 230
	t.color_b=t.color_b or 230

	t.player = true
	t.type = t.type or "humanoid"
	t.subtype = t.subtype or "player"
	t.faction = t.faction or "players"

	t.lite = t.lite or 0

	mod.class.Actor.init(self, t, no_default)
	engine.interface.PlayerHotkeys.init(self, t)

	self.descriptor = {}
end

function _M:move(x, y, force)
	local moved = mod.class.Actor.move(self, x, y, force)
	if moved then
		game.level.map:moveViewSurround(self.x, self.y, 8, 8)
	end
	return moved
end

function _M:act()
	if not mod.class.Actor.act(self) then return end

	-- Clean log flasher
	game.flash:empty()

	-- Resting ? Running ? Otherwise pause
	if not self:restStep() and not self:runStep() and self.player then
		game.paused = true
	end
end

-- Precompute FOV form, for speed
local fovdist = {}
for i = 0, 30 * 30 do
	fovdist[i] = math.max((20 - math.sqrt(i)) / 14, 0.6)
end

function _M:playerFOV()
	-- Clean FOV before computing it
	game.level.map:cleanFOV()
	-- Compute both the normal and the lite FOV, using cache
	self:computeFOV(self.sight or 20, "block_sight", function(x, y, dx, dy, sqdist)
		game.level.map:apply(x, y, fovdist[sqdist])
	end, true, false, true)
	self:computeFOV(self.lite, "block_sight", function(x, y, dx, dy, sqdist) game.level.map:applyLite(x, y) end, true, true, true)
end

--- Called before taking a hit, overload mod.class.Actor:onTakeHit() to stop resting and running
function _M:onTakeHit(value, src)
	self:runStop("taken damage")
	self:restStop("taken damage")
	local ret = mod.class.Actor.onTakeHit(self, value, src)
	if self.life < self.max_life * 0.3 then
		local sx, sy = game.level.map:getTileToScreen(self.x, self.y)
		game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, 2, "LOW HEALTH!", {255,0,0}, true)
	end
	return ret
end

function _M:die(src)
	if self.game_ender then
		engine.interface.ActorLife.die(self, src)
		game.paused = true
		self.energy.value = game.energy_to_act
		game:registerDialog(DeathDialog.new(self))
	else
		mod.class.Actor.die(self, src)
	end
end

function _M:setName(name)
	self.name = name
	game.save_name = name
end

--- Notify the player of available cooldowns
function _M:onTalentCooledDown(tid)
	local t = self:getTalentFromId(tid)

	local x, y = game.level.map:getTileToScreen(self.x, self.y)
	game.flyers:add(x, y, 30, -0.3, -3.5, ("%s available"):format(t.name:capitalize()), {0,255,00})
	game.log("#00ff00#Talent %s is ready to use.", t.name)
end

--- Tries to get a target from the user
function _M:getTarget(typ)
	return game:targetGetForPlayer(typ)
end

--- Sets the current target
function _M:setTarget(target)
	return game:targetSetForPlayer(target)
end

local function spotHostiles(self)
	local seen = false
	-- Check for visible monsters, only see LOS actors, so telepathy wont prevent resting
	core.fov.calc_circle(self.x, self.y, game.level.map.w, game.level.map.h, 20, function(_, x, y) return game.level.map:opaque(x, y) end, function(_, x, y)
		local actor = game.level.map(x, y, game.level.map.ACTOR)
		if actor and self:reactionToward(actor) < 0 and self:canSee(actor) and game.level.map.seens(x, y) then seen = true end
	end, nil)
	return seen
end

--- Can we continue resting ?
-- We can rest if no hostiles are in sight, and if we need life/mana/stamina (and their regen rates allows them to fully regen)
function _M:restCheck()
	if spotHostiles(self) then return false, "hostile spotted" end

	-- Check resources, make sure they CAN go up, otherwise we will never stop
	if self.life < self.max_life and self.life_regen> 0 then return true end

	return false, "all resources and life at maximum"
end

--- Can we continue running?
-- We can run if no hostiles are in sight, and if we no interesting terrains are next to us
function _M:runCheck()
	if spotHostiles(self) then return false, "hostile spotted" end

	-- Notice any noticeable terrain
	local noticed = false
	self:runScan(function(x, y)
		-- Only notice interesting terrains
		local grid = game.level.map(x, y, Map.TERRAIN)
		if grid and grid.notice then noticed = "interesting terrain" end
	end)
	if noticed then return false, noticed end

	self:playerFOV()

	return engine.interface.PlayerRun.runCheck(self)
end

--- Move with the mouse
-- We just feed our spotHostile to the interface mouseMove
function _M:mouseMove(tmx, tmy)
	return engine.interface.PlayerMouse.mouseMove(self, tmx, tmy, spotHostiles)
end

function _M:playerPickup()
    -- If 2 or more objects, display a pickup dialog, otherwise just picks up
    if game.level.map:getObject(self.x, self.y, 2) then
        local d d = self:showPickupFloor("Pickup", nil, function(o, item)
            self:pickupFloor(item, true)
            self.changed = true
            d:used()
        end)
    else
        self:pickupFloor(1, true)
        self:sortInven()
        self:useEnergy()
    self.changed = true
    end
end

function _M:playerDrop()
    local inven = self:getInven(self.INVEN_INVEN)
    local d d = self:showInventory("Drop object", inven, nil, function(o, item)
        self:dropFloor(inven, item, true, true)
        self:sortInven(inven)
        self:useEnergy()
        self.changed = true
        return true
    end)
end

--- Uses an hotkeyed talent
function _M:activateHotkey(id)
	if self.hotkey[id] then
		self["hotkey"..self.hotkey[id][1]:capitalize()](self, self.hotkey[id][2], self.hotkey[id][3])
	else
		Dialog:simplePopup("Hotkey not defined", "You may define a hotkey by pressing 'm' and following the instructions there.")
	end
end

--- Activates a hotkey with a type "talent"
function _M:hotkeyTalent(part, tid)
	part:useTalent(tid)
end

--- Activates a hotkey with a type "inventory"
function _M:hotkeyInventory(name)
	local o, item, inven = self:findInAllInventories(name)
	if not o then
		Dialog:simplePopup("Item not found", "You do not have any "..name..".")
	else
		self:playerUseItem(o, item, inven)
	end
end

local function spotHostiles(self)
        local seen = {}
        if not self.x then return seen end

	-- Check for visible monsters, only see LOS actors, so telepathy wont prevent resting
	core.fov.calc_circle(self.x, self.y, game.level.map.w, game.level.map.h, self.sight or 10, function(_, x, y) return game.level.map:opaque(x, y) end, function(_, x, y)
		local actor = game.level.map(x, y, game.level.map.ACTOR)
		if actor and self:reactionToward(actor) < 0 and self:canSee(actor) and game.level.map.seens(x, y) then
			seen[#seen + 1] = {x=x,y=y,actor=actor}
		end
	end, nil)
	return seen
end

--- Checks for hostiles while resting
function _M:restCheck()
	local spotted = spotHostiles(self)
	if #spotted > 0 then
		for _, node in ipairs(spotted) do
			node.actor:addParticles(engine.Particles.new("notice_enemy", 1))
		end
		return false, ("hostile spotted (%s%s)"):format(spotted[1].actor.name, game.level.map:isOnScreen(spotted[1].x, spotted[1].y) and "" or " - offscreen")
	end
	
	-- Check resources
	if self.life_regen <= 0 then return false, "losing health!" end
	if self.bioenergy_regen <= 0 then return false, "losing energy!" end
	if self.life < self.max_life then return true end
	if self:getBioenergy() < self:getMaxBioenergy() then return true end
	return false, "all resources are at maximum."
end


--- Checks for hostiles while running
function _M:runCheck()
	local spotted = spotHostiles(self)
	if #spotted > 0 then
		for _, node in ipairs(spotted) do
			node.actor:addParticles(engine.Particles.new("notice_enemy", 1))
		end
		return false, ("hostile spotted (%s%s)"):format(spotted[1].actor.name, game.level.map:isOnScreen(spotted[1].x, spotted[1].y) and "" or " - offscreen")
	end

	return engine.interface.PlayerRun.runCheck(self)
end

--- Called after running a step
function _M:runMoved()
        self:playerFOV()
        if self.running and self.running.explore then
                game.level.map:particleEmitter(self.x, self.y, 1, "dust_trail")
        end
end

--- Called after stopping running
function _M:runStopped()
	game.level.map.clean_fov = true
	self:playerFOV()
	local spotted = spotHostiles(self)
	if #spotted > 0 then
		for _, node in ipairs(spotted) do
			node.actor:addParticles(engine.Particles.new("notice_enemy", 1))
		end
	end

	-- if you stop at an object (such as on a trap), then mark it as seen
	local obj = game.level.map:getObject(x, y, 1)
	if obj then game.level.map.attrs(x, y, "obj_seen", true) end
end

--- Called after stopping running
function _M:runStopped()
	game.level.map.clean_fov = true
	self:playerFOV()
	local spotted = spotHostiles(self)
	if #spotted > 0 then
		for _, node in ipairs(spotted) do
			node.actor:addParticles(engine.Particles.new("notice_enemy", 1))
		end
	end

	-- if you stop at an object (such as on a trap), then mark it as seen
	local obj = game.level.map:getObject(x, y, 1)
	if obj then game.level.map.attrs(x, y, "obj_seen", true) end
end


