require "engine.class"
require "engine.Object"

local Stats = require("engine.interface.ActorStats")
local ActorInventory = require "mod.class.interface.ActorInventory"
local Talents = require("mod.class.interface.PartTalents")
local DamageType = require("engine.DamageType")

module(..., package.seeall, class.inherit(
	engine.Object,
	mod.class.interface.ActorInventory,
	mod.class.interface.PartTalents
))

function _M:init(t, no_default)
	t.encumber = t.encumber or 0

	engine.Object.init(self, t, no_default)
	mod.class.interface.ActorInventory.init(self, t)
	-- Remove the INVEN_INVEN value
	self.inven[self.INVEN_INVEN] = nil
	mod.class.interface.PartTalents.init(self, t)
end

function _M:useEnergy(val)
	if self.actor then return self.actor:useEnergy(val) end
end

--- Called before a talent is used
-- Check the actor can cast it
-- @param ab the talent (not the id, the table)
-- @return true to continue, false to stop
function _M:preUseTalent(ab, silent)
	if not (self.actor and self.actor:enoughEnergy()) then print("fail energy") return false end

	if ab.mode == "sustained" then
		if ab.sustain_bioenergy and self.actor:getMaxBioenergy() < ab.sustain_bioenergy and not self:isTalentActive(ab.id) then
			game.logPlayer(self.actor, "You do not have enough bioenergy to activate %s.", ab.name)
			return false
		end
	else
		if ab.bioenergy and self.actor:getBioenergy() < ab.bioenergy then
			game.logPlayer(self.actor, "You do not have enough bioenergy to activate %s.", ab.name)
			return false
		end
	end

	if not silent then
		-- Allow for silent talents
		if ab.message ~= nil then
			if ab.message then
				game.logSeen(self.actor, "%s", self:useTalentMessage(ab))
			end
		elseif ab.mode == "sustained" and not self:isTalentActive(ab.id) then
			game.logSeen(self.actor, "%s activates %s.", self.actor.name:capitalize(), ab.name)
		elseif ab.mode == "sustained" and self:isTalentActive(ab.id) then
			game.logSeen(self.actor, "%s deactivates %s.", self.actor.name:capitalize(), ab.name)
		else
			game.logSeen(self.actor, "%s uses %s.", self.actor.name:capitalize(), ab.name)
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

	self.actor:useEnergy()

	if ab.mode == "sustained" then
		if not self:isTalentActive(ab.id) then
			if ab.sustain_bioenergy then
				self.actor:incMaxBioenergy(-ab.sustain_bioenergy)
			end
		else
			if ab.sustain_bioenergy then
				self.actor:incMaxBioenergy(ab.sustain_bioenergy)
			end
		end
	else
		if ab.bioenergy then
			self.actor:incBioenergy(-ab.bioenergy)
		end
	end
	
	if ab.fidelity then
		self.actor:incFidelity(-ab.fidelity) -- sync/fidelity are charged after using the talent - keep this in mind if you want a talent to "fail" but still reduce sync/fidelity
	end
	
	if ab.sync then
		self.actor:incSync(-ab.sync)
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

	if t.bioenergy or t.sustain_bioenergy then d[#d+1] = "#6fff83#Bioenergy cost: #7fffd4#"..(t.bioenergy or t.sustain_bioenergy) end
	if self:getTalentRange(t) > 1 then d[#d+1] = "#6fff83#Range: #FFFFFF#"..self:getTalentRange(t)
	else d[#d+1] = "#6fff83#Range: #FFFFFF#melee/personal"
	end
	if t.cooldown then d[#d+1] = "#6fff83#Cooldown: #FFFFFF#"..t.cooldown end

	return table.concat(d, "\n").."\n#6fff83#Description: #FFFFFF#"..t.info(self, t)
end

--- Returns a tooltip for the object
function _M:tooltip()
	return ([[%s
%s]]):format(
	self.name,
	self.desc or ""
	)
end