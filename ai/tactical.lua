--local print = function() end

-- Internal functions
local checkLOS = function(sx, sy, tx, ty)
	what = what or "block_sight"
	local l = core.fov.line(sx, sy, tx, ty, what)
	local lx, ly, is_corner_blocked = l:step()
	while lx and ly and not is_corner_blocked do
		if game.level.map:checkAllEntities(lx, ly, what) then break end

		lx, ly, is_corner_blocked = l:step()
	end
	-- Ok if we are at the end reset lx and ly for the next code
	if not lx and not ly and not is_corner_blocked then lx, ly = x, y end

	if lx == x and ly == y then return true, lx, ly end
	return false, lx, ly
end

newAI("use_tactical", function(self)
	-- Find available talents
	print("============================== TACTICAL AI", self.name)
	local avail = {}
	local ok = false
	local target_dist = self.ai_target.actor and core.fov.distance(self.x, self.y, self.ai_target.actor.x, self.ai_target.actor.y)
	local hate = self.ai_target.actor and (self:reactionToward(self.ai_target.actor) < 0)
	local has_los = self.ai_target.actor and self:hasLOS(self.ai_target.actor.x, self.ai_target.actor.y)
	local process_talents = function(part)
		for tid, _ in pairs(part.talents) do
			local t = part:getTalentFromId(tid)
			if t.mode ~= "passive" and not t.no_npc_use and part:preUseTalent(t, true, true) then
				print(self.name, self.uid, "tactical ai talents testing", t.name, tid)
				local effs = t.effects(self, t)
				if effs then
					local weights, wants = {}, {}
					for i, eff in ipairs(effs) do
						local def = self.atomiceffect_def[eff.id]
						if def.tactical then
							eff_weights, eff_wants = def.tactical(self, eff)
							table.merge(weights, eff_weights, nil, nil, nil, true)
							table.merge(wants, eff_wants, nil, nil, nil, true)
						end
					end
					local header = " Weights:"
					for key, val in pairs(weights) do
						if header then print(header) header = nil end
						print("* ", key, " :=: ", val)
					end
					header = " Wants:"
					for key, val in pairs(wants) do
						if header then print(header) header = nil end
						print("* ", key, " :=: ", val)
					end
					avail[t] = {effs=effs, weights=weights, wants=wants}
					ok = true
				end
			end
		end
	end
	self:applyToWornParts(process_talents)
	if ok then
		-- Sum up the wants
		local total_wants = {ATTACK=1, DEFENSE=1}	
		for t, t_tact in pairs(avail) do
			table.merge(total_wants, t_tact.wants, nil, nil, nil, true)
		end

		-- Specialize the wants with some long-term stuff here

		-- Combine the talents
		local combined_values = {}
		for t, t_tact in pairs(avail) do
			local val = 0
			for key, want in pairs(total_wants) do
				val = val + (t_tact.weights[key] or 0) * want
			end
			if val > 0 then
				combined_values[#combined_values+1] = {t, val}
			end
		end
		table.sort(combined_values, function(a, b) return a[2] > b[2] end)

		print("Tactical ai report for", self.name)
		print(" Wants:")
		for key, val in pairs(total_wants) do
			print("* ", key:capitalize(), val)
		end
		print(" Weights:")
		for _, t in ipairs(combined_values) do
			print("* ", t[1].name:capitalize(), t[2])
		end

		if #combined_values > 0 then
			return self:useTalent(combined_values[1][1].id)
		end
	end
end)

newAI("tactical", function(self)
	local targeted = self:runAI(self.ai_state.ai_target or "target_simple")

	local used_talent = self:runAI("use_tactical")

	if targeted and not self.energy.used then
		return self:runAI(self.ai_state.ai_move or "move_simple")
	end
	return false
end)
