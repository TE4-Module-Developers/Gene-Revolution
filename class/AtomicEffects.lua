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
        t.apply = t.apply or function() end
        t.status = t.status or "detrimental"

        table.insert(self.atomiceffect_def, t)
        t.id = #self.atomiceffect_def
        self["ATOMICEFF_"..t.name] = #self.atomiceffect_def
end

function _M:getEffectFromId(id)
	return self.atomiceffect_def[id]
end
