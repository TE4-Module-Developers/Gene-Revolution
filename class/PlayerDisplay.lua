-- ToME - Tales of Maj'Eyal
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
local Mouse = require "engine.Mouse"
local Button = require "engine.ui.Button"
--local TooltipsData = require "mod.class.interface.TooltipsData"

module(..., package.seeall, class.make)

function _M:init(x, y, w, h, bgcolor, font, size)
	self.display_x = x
	self.display_y = y
	self.w, self.h = w, h
	self.bgcolor = bgcolor
	self.font = core.display.newFont(font, size)
	self.fontbig = core.display.newFont(font, size * 2)
	self.mouse = Mouse.new()
	self:resize(x, y, w, h)
end
--- Resize the display area
function _M:resize(x, y, w, h)
	self.display_x, self.display_y = x, y
	self.mouse.delegate_offset_x = x
	self.mouse.delegate_offset_y = y
	self.w, self.h = w, h
	self.font_h = self.font:lineSkip()
	self.font_w = self.font:size(" ")
	self.bars_x = self.font_w * 9
	self.bars_w = self.w - self.bars_x - 5
	self.surface = core.display.newSurface(w, h)
	self.surface_line = core.display.newSurface(w, self.font_h)
	self.surface_portrait = core.display.newSurface(40, 40)
	self.texture, self.texture_w, self.texture_h = self.surface:glTexture()
	self.items = {}
end

function _M:mouseTooltip(text, w, h, x, y, click)
	self.mouse:registerZone(x, y, w, h, function(button, mx, my, xrel, yrel, bx, by, event)
		game.tooltip_x, game.tooltip_y = 1, 1; game:tooltipDisplayAtMap(game.w, game.h, text)
		if click and event == "button" and button == "left" then
			click()
		end
	end)
end

function _M:makeTexture(text, x, y, r, g, b, max_w)
	local s = self.surface_line
	s:erase(0, 0, 0, 0)
	s:drawColorStringBlended(self.font, text, 0, 0, r, g, b, true, max_w)

	local item = { s:glTexture() }
	item.x = x
	item.y = y
	item.w = self.w
	item.h = self.font_h
	self.items[#self.items+1] = item

	return item.w, item.h, item.x, item.y
end

function _M:makeTextureBar(text, nfmt, val, max, reg, x, y, r, g, b, bar_col, bar_bgcol)
	local s = self.surface_line
	s:erase(0, 0, 0, 0)
	s:erase(bar_bgcol.r, bar_bgcol.g, bar_bgcol.b, 255, self.bars_x, h, self.bars_w, self.font_h)
	s:erase(bar_col.r, bar_col.g, bar_col.b, 255, self.bars_x, h, self.bars_w * val / max, self.font_h)

	s:drawColorStringBlended(self.font, text, 0, 0, r, g, b, true)
	s:drawColorStringBlended(self.font, (nfmt or "%d/%d"):format(val, max), self.bars_x + 5, 0, r, g, b)
	if reg and reg ~= 0 then
		local reg_txt = (" (%s%.2f)"):format((reg > 0 and "+") or "",reg)
		local reg_txt_w = self.font:size(reg_txt)
		s:drawColorStringBlended(self.font, reg_txt, self.bars_x + self.bars_w - reg_txt_w - 3, 0, r, g, b)
	end
	local item = { s:glTexture() }
	item.x = x
	item.y = y
	item.w = self.w
	item.h = self.font_h
	self.items[#self.items+1] = item

	return item.w, item.h, item.x, item.y
end

-- Displays the stats
function _M:display()
	local player = game.player
	if not player or not player.changed or not game.level then return end

	self.mouse:reset()
	self.items = {}

--	local cur_exp, max_exp = player.exp, player:getExpChart(player.level+1)
	local h = 6
	local x = 2
	
	self:mouseTooltip("Don't run out!", self:makeTextureBar("#c00000#Life:", nil, player.life, player.max_life, player.life_regen, x, h, 255, 255, 255,
		colors.DARK_RED,
		colors.VERY_DARK_RED
		)) h = h + self.font_h
	
	self:mouseTooltip("Bioenergy powers all actions.", self:makeTextureBar("#7fffd4#B.energy:", nil, player:getBioenergy(), player.max_bioenergy, player.bioenergy_regen, x, h, 255, 255, 255,
		{r=0x7f / 2, g=0xff / 2, b=0xd4 / 2},
		{r=0x7f / 5, g=0xff / 5, b=0xd4 / 5}
	)) h = h + self.font_h
	
	local eff = player:getFidelityEff() * 100
	self:mouseTooltip("As you utilize your genetic abilities, your Fidelity decreases, reducing the effectiveness of all genetic abilities.  The exact effects depend upon the ability.", self:makeTextureBar("#c0c000#Fidelity:", ("%d/%d (%d%s)"):format(player:getFidelity(), player.max_fidelity, eff, "%%"), player:getFidelity(), player.max_fidelity, player.fidelity_regen, x, h, 255, 255, 255,
		{r=0xff / 2, g=0xff / 2, b=0x00 / 2},
		{r=0xff / 5, g=0xff / 5, b=0x00 / 5}
	)) h = h + self.font_h
	
	local eff = player:getSyncEff() * 100
	self:mouseTooltip("As you utilize your cybernetic abilities, your Sync decreases, reducing the effectiveness of all cybernetic abilities.  The exact effects depend upon the ability.", self:makeTextureBar("#00c000#Sync:", ("%d/%d (%d%s)"):format(player:getSync(), player.max_sync, eff, "%%"), player:getSync(), player.max_sync, player.sync_regen, x, h, 255, 255, 255,
		{r=0x00 / 2, g=0xff / 2, b=0x00 / 2},
		{r=0x00 / 5, g=0xff / 5, b=0x00 / 5}
	)) h = h + self.font_h
end

function _M:toScreen(nb_keyframes)
	self:display()
	for i = 1, #self.items do
		local item = self.items[i]
		if type(item) == "table" then
			if item.glow then
				local glow = (1+math.sin(core.game.getTime() / 500)) / 2 * 100 + 120
				item[1]:toScreenFull(self.display_x + item.x, self.display_y + item.y, item.w, item.h, item[2], item[3], 1, 1, 1, glow / 255)
			else
				item[1]:toScreenFull(self.display_x + item.x, self.display_y + item.y, item.w, item.h, item[2], item[3])
			end
		else
			item(self.display_x, self.display_y)
		end
	end
end