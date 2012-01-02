require "engine.class"
local DamageType = require "engine.DamageType"

--- Handles actors temporary effects (temporary boost of a stat, ...)
module(..., package.seeall, class.make)

_M.atomiceffect_def = {}

--- Defines actor atomic effects
-- Static!
function _M:loadDefinition(file, env)
		local f, err = util.loadfilemods(file, setmetatable(env or {
				DamageType = require "engine.DamageType",
				AtomicEffects = self,
				newAtomicEffect = function(t) self:newAtomicEffect(t) end,
				load = function(f) self:loadDefinition(f, getfenv(2)) end
		}, {__index=_G}))
		if not f and err then error(err) end
		f()
end

--- Defines one effect
-- Static!
function _M:newAtomicEffect(t)
		assert(t.name, "no effect name")
		assert(t.desc, "no effect desc")
		assert(t.type, "no effect type")
		t.name = t.name:upper()
		-- The calculate function should return a table that is passed to apply
		-- It should contain at least the variable "prob", the probability of applying the effect
		t.calculate= t.calculate or function() end
		t.activate = t.activate or function() end
		t.deactivate = t.deactivate or function() end
		t.status = t.status or "detrimental"
		t.default_params = t.default_params or {}
		t.default_params.decrease = t.default_params.decrease or 1

		table.insert(self.atomiceffect_def, t)
		t.id = #self.atomiceffect_def
		self["ATOMICEFF_"..t.name] = #self.atomiceffect_def
end

function _M:init(t)
	self.effects = t.effects or {}
end

--- Counts down timed effects, call from your actors "act" method
-- @param filter if not nil a function that gets passed the effect and its parameters, must return true to handle the effect
function _M:timedEffects(filter)
	local todel = {}
	for eff_id, effs in pairs(self.effects) do
		for instance_id, eff in pairs(effs) do
			if (instance_id ~= "n") and (not filter or filter(eff.def, eff)) then
				if eff.dur and (eff.dur <= 0) then
					todel[#todel+1] = eff
				else
					if eff.def.on_timeout and eff.def.on_timeout(self, eff) then
						todel[#todel+1] = eff
					end
				end
				eff.dur = eff.dur - eff.decrease
			end
		end
	end

	while #todel > 0 do
		self:removeEffect(table.remove(todel))
	end
end

--- Calculates an effect instance
-- @param eff_id either a string (ATOMICEFF_MELEE) or a number referring to the effect
-- @param target the target of the effect, defaults to self
-- @param params additional parameters to pass to the calculate function
-- @return a table containing the specifics of an effect instance
function _M:calcEffect(eff_id, target, params)
	if type(eff_id) == "string" then
		eff_id = self[eff_id]
	end
	local eff_def = self.atomiceffect_def[eff_id]
	local eff = eff_def.calculate(self, eff_def, target, params)
	if not eff then return end

	-- Set defaults
	eff.def = eff.def or eff_def
	eff.source = eff.source or self
	eff.target = eff.target or (target or self)
	eff.params = eff.params or params
	for k, e in pairs(eff_def.default_params) do
		if eff[k] == nil then eff[k] = e end
	end
	return eff
end

--- Sets a timed effect on the actor
-- @param eff instance table from calcEffect method
-- @parm silent true to suppress messages
function _M:setEffect(eff, silent)
	if eff.active then return end
	if eff.dur then eff.dur = math.floor(eff.dur) end

	self:check("on_set_temporary_effect", eff)

	if eff.def.on_gain then
		local ret, fly = eff.def.on_gain(self, eff)
		if not silent then
			if ret then
				game.logSeen(self, ret:gsub("#Target#", self.name:capitalize()):gsub("#target#", self.name))
			end
			if fly and game.flyers and self.x and self.y and game.level.map.seens(self.x, self.y) then
				local sx, sy = game.level.map:getTileToScreen(self.x, self.y)
				if game.level.map.seens(self.x, self.y) then game.flyers:add(sx, sy, 20, (rng.range(0,2)-1) * 0.5, -3, fly, {255,100,80}) end
			end
		end
	end

	local active = eff.def.activate(self, eff)
	if active or eff.active then
		eff.active = true
		if not self.effects[eff.def.id] then self.effects[eff.def.id] = {n=1} end
		local effs = self.effects[eff.def.id]
		local id = effs.n
		while effs[id] ~= nil do id = id + 1 end
		eff.instance_id = id
		effs[id] = eff
		effs.n = id + 1
	end
	self.changed = true
end

--- Check timed effect
-- @param eff_id the effect to check for
-- @return either nil or the parameters table for the effect
function _M:hasEffect(eff_id)
	if type(eff_id) == "string" then
		eff_id = self[eff_id]
	end
	return self.effects[eff_id]
end

--- Removes the effect
function _M:removeEffect(eff, silent, force)
	if (eff.def.no_remove or not eff.active) and not force then return end
	self.changed = true
	if eff.def.on_lose then
		local ret, fly = eff.def.on_lose(self, eff)
		if not silent then
			if ret then
				game.logSeen(self, ret:gsub("#Target#", self.name:capitalize()):gsub("#target#", self.name))
			end
			if fly and game.flyers and self.x and self.y then
				local sx, sy = game.level.map:getTileToScreen(self.x, self.y)
				if game.level.map.seens(self.x, self.y) then game.flyers:add(sx, sy, 20, (rng.range(0,2)-1) * 0.5, -3, fly, {255,100,80}) end
			end
		end
	end
	eff.def.deactivate(self, eff)
	local effs = self.effects[eff.def.id]
	effs[eff.instance_id] = nil
	eff.active = nil
	effs.n = math.min(effs.n, eff.instance_id)
	eff.instance_id = nil
end

--- Removes the effect
function _M:removeAllEffects()
	local todel = {}
	for eff_id, effs in pairs(self.effects) do
		for instance_id, eff in pairs(effs) do
			if instance_id ~= "n" then
				todel[#todel+1] = eff
			end
		end
	end

	while #todel > 0 do
		self:removeEffect(table.remove(todel))
	end
end
