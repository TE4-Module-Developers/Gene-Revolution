require "engine.class"
local ActorTalents = require "engine.interface.ActorTalents"

--- Handles the talents, updated to use AtomicEffects
module(..., package.seeall, class.inherit(ActorTalents))

--- Make the actor use the talent
function _M:useTalent(id, who, force_level, ignore_cd, force_target)
	who = who or self
	local ab = _M.talents_def[id]
	assert(ab, "trying to cast talent "..tostring(id).." but it is not defined")

	if ab.mode == "activated" and ab.effects then
		if self:isTalentCoolingDown(ab) and not ignore_cd then
			game.logPlayer(who.actor, "%s is still on cooldown for %d turns.", ab.name:capitalize(), self.talents_cd[ab.id])
			return
		end
		if not self:preUseTalent(ab) then return end
		local co = coroutine.create(function()
			local old_level
			local old_target
			if force_level then old_level = who.talents[id]; who.talents[id] = force_level end
			if force_target then old_target = rawget(who.actor, "getTarget"); who.actor.getTarget = function(a) return force_target.x, force_target.y, not force_target.__no_self and force_target end end

			-- Handles the AtomicEffects
			local effs = ab.effects(who.actor, who, ab)
			local ret
			if effs then
				for i, eff in ipairs(effs) do
					eff.target:setEffect(eff)
				end
				ret = true
			else
				ret = false
			end

			if force_target then who.getTarget = old_target end
			if force_level then who.talents[id] = old_level end

			if not self:postUseTalent(ab, ret) then return end

			-- Everything went ok? then start cooldown if any
			if not ignore_cd then self:startTalentCooldown(ab) end
		end)
		local ok, err = coroutine.resume(co)
		if not ok and err then print(debug.traceback(co)) error(err) end
	elseif ab.mode == "sustained" and ab.effects then
		if self:isTalentCoolingDown(ab) and not ignore_cd then
			game.logPlayer(who.actor, "%s is still on cooldown for %d turns.", ab.name:capitalize(), self.talents_cd[ab.id])
			return
		end
		local co = coroutine.create(function()
			if not self.sustain_talents[id] then
				local old_level
				if force_level then old_level = who.talents[id]; who.talents[id] = force_level end

				-- Handles the AtomicEffects
				local effs = ab.effects(who.actor, who, ab)
				local ret
				if effs then
					for i, eff in ipairs(effs) do
						eff.target:setEffect(eff)
					end
					ret = true
				else
					ret = false
				end

				if force_level then who.talents[id] = old_level end

				if not self:postUseTalent(ab, ret) then return end

				self.sustain_talents[id] = effs
			else
				local old_level
				if force_level then old_level = who.talents[id]; who.talents[id] = force_level end

				-- Handles the AtomicEffects
				local effs = self.sustain_talents[id]
				local ret
				if effs then
					for i, eff in ipairs(effs) do
						eff.target:removeEffect(eff)
					end
					ret = true
				else
					ret = false
				end

				if force_level then who.talents[id] = old_level end

				if not self:postUseTalent(ab, ret) then return end

				-- Everything went ok? then start cooldown if any
				if not ignore_cd then self:startTalentCooldown(ab) end
				self.sustain_talents[id] = nil
			end
		end)
		local ret, err = coroutine.resume(co)
		if not ret and err then print(debug.traceback(co)) error(err) end
	else
		error("Activating non activable or sustainable talent: "..id.." :: "..ab.name.." :: "..ab.mode)
	end
	self.changed = true
	return true
end
