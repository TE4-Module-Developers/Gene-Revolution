require "engine.class"
local Birther = require "engine.Birther"

module(..., package.seeall, class.inherit(Birther))

--- Defines birth descriptors
-- Static!
function _M:loadDefinition(file)
        local f, err = util.loadfilemods(file, setmetatable({
                newBirthDescriptor = function(t) self:newBirthDescriptor(t) end,
                getBirthDescriptor = function(type, name) return self:getBirthDescriptor(type, name) end,
                setAuto = function(type, v) self.birth_auto[type] = v end,
                setStepNames = function(names) self.step_names = names end,
                load = function(f) self:loadDefinition(f) end
        }, {__index=_G}))
        if not f and err then error(err) os.exit() end
        local ok, err = pcall(f)
        if not ok and err then error(err) end
end
