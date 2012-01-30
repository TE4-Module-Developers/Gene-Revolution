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
require "engine.Grid"
local DamageType = require "engine.DamageType"

module(..., package.seeall, class.inherit(engine.Grid))

function _M:init(t, no_default)
	engine.Grid.init(self, t, no_default)
end

function _M:block_move(x, y, e, act, couldpass)
	-- Open doors
	if self.door_opened and act then
		game.level.map(x, y, engine.Map.TERRAIN, game.zone.grid_list.DOOR_OPEN)
		return true
	elseif self.door_opened and not couldpass then
		return true
	end

	-- Pass walls
	if e and self.can_pass and e.can_pass then
		for what, check in pairs(e.can_pass) do
			if self.can_pass[what] and self.can_pass[what] <= check then return false end
		end
	end

	return self.does_block_move
end

function _M:on_move(x, y, who, forced)
	if forced then return end
	if who.move_project and next(who.move_project) then
		for typ, dam in pairs(who.move_project) do
			DamageType:get(typ).projector(who, x, y, typ, dam)
		end
	end
end
function _M:tooltip()
	if self.show_tooltip then
		local name = ((self.show_tooltip == true) and self.name or self.show_tooltip)
		if self.desc then
			return self:getDisplayString()..name.."\n"..self.desc
		else
			return self:getDisplayString()..name
		end
	else
		return self:getDisplayString()..self.name
	end
end

--- Generate sub entities to make nice trees
function _M:makeTrees(base, max, bigheight_limit, tint)
        local function makeTree(nb, z)
                local inb = 4 - nb
                local treeid = rng.range(1, max or 5)
                return engine.Entity.new{
                        z = z,
                        display_scale = 1,
                        display_scale = rng.float(0.5 + inb / 6, 1),
                        display_x = rng.float(-1 / 3 * nb / 3, 1 / 3 * nb / 3),
                        display_y = rng.float(-1 / 3 * nb / 3, 1 / 3 * nb / 3) - (treeid < (bigheight_limit or 9) and 0 or 1),
                        display_on_seen = true,
                        display_on_remember = true,
                        display_h = treeid < (bigheight_limit or 9) and 1 or 2,
                        image = (base or "terrain/tree_alpha")..treeid..".png",
                        tint = tint,
                }
        end

        local v = rng.range(0, 100)
        local tbl
        if v < 33 then
                tbl = { makeTree(3, 16), makeTree(3, 17), makeTree(3, 18), }
        elseif v < 66 then
                tbl = { makeTree(2, 16), makeTree(2, 17), }
        else
                tbl = { makeTree(1, 16), }
        end
        table.sort(tbl, function(a,b) return a.display_scale < b.display_scale end)
        for i = 1, #tbl do tbl[i].z = 16 + i - 1 end
        return tbl
end

--- Generate sub entities to make nice trees
function _M:makeSubTrees(base, max)
        local function makeTree(nb, z)
                local inb = 4 - nb
                return engine.Entity.new{
                        z = z,
                        display_scale = rng.float(0.5 + inb / 6, 1.3),
                        display_x = rng.float(-1 / 3 * nb / 3, 1 / 3 * nb / 3),
                        display_y = rng.float(-1 / 3 * nb / 3, 1 / 3 * nb / 3),
                        display_on_seen = true,
                        display_on_remember = true,
                        image = (base or "terrain/tree_alpha")..rng.range(1,max or 5)..".png",
                }
        end

        local v = rng.range(0, 100)
        local tbl
        if v < 40 then
--              tbl = { makeTree(3, 16), makeTree(3, 17), makeTree(3, 18), }
--      elseif v < 66 then
                tbl = { makeTree(2, 16), makeTree(2, 17), }
        else
                tbl = { makeTree(1, 16), }
        end
        table.sort(tbl, function(a,b) return a.display_scale < b.display_scale end)
        for i = 1, #tbl do tbl[i].z = 16 + i - 1 end
        return tbl
end
