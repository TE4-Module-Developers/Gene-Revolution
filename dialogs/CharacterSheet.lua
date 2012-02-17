require "engine.class"
require "engine.Dialog"
local Talents = require "mod.class.interface.PartTalents"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(actor)
	self.actor = actor
	engine.Dialog.init(self, "Character Sheet: "..self.actor.name, 800, 400, nil, nil, nil, core.display.newFont("/data/font/VeraMono.ttf", 12))

	self:keyCommands(nil, {
		ACCEPT = "EXIT",
		EXIT = function()
			game:unregisterDialog(self)
		end,
	})
end

function _M:drawDialog(s)
	local h = 0
	local w = 0
	s:drawColorString(self.font, ("#c00000#Life:    #00ff00#%d/%d"):format(game.player.life, game.player.max_life), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorString(self.font, ("#ffcc80#Bioenergy: #00ff00#%d/%d"):format(game.player:getBioenergy(), game.player:getMaxBioenergy()), w, h, 255, 255, 255) h = h + self.font_h

	h = h + self.font_h
	s:drawColorString(self.font, ("STR: #00ff00#%3d"):format(game.player:getStr()), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorString(self.font, ("DEX: #00ff00#%3d"):format(game.player:getDex()), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorString(self.font, ("CON: #00ff00#%3d"):format(game.player:getCon()), w, h, 255, 255, 255) h = h + self.font_h

	h = 0
	w = 600
	s:drawColorString(self.font, ("#LIGHT_BLUE#Current effects:"):format(game.player.fatigue), w, h, 255, 255, 255) h = h + self.font_h
--	for tid, act in pairs(game.player.sustain_talents) do
--		if act then s:drawColorString(self.font, ("#LIGHT_GREEN#%s"):format(game.player:getTalentFromId(tid).name), w, h, 255, 255, 255) h = h + self.font_h end
--	end
	for eff_id, p in pairs(game.player.effects) do
		local e = game.player.atomiceffect_def[eff_id]
		if e.status == "detrimental" then
			s:drawColorString(self.font, ("#LIGHT_RED#%s"):format(e.desc), w, h, 255, 255, 255) h = h + self.font_h
		else
			s:drawColorString(self.font, ("#LIGHT_GREEN#%s"):format(e.desc), w, h, 255, 255, 255) h = h + self.font_h
		end
	end

	self.changed = false
end
