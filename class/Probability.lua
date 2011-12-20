require "engine.class"

module(..., package.seeall, class.make)

function _M:init(t)
	t = t or {}	
	self.val = t.val or 100
	self._resolved = t._resolved or false
	self._dependencies = t._dependencies or {}
        getmetatable(self).__call = _M.call
end

function _M:predict()
	local prob = self.val / 100
	for i, p in ipairs(self._dependencies) do
		if p[1] == 'and' then
			prob = prob * p[2].val/100
		elseif p[1] == 'or' then
			prob = math.max(prob, p[2].val/100)
		end
	end
	return prob*100
end

function _M:call()
	if not self._resolved then
		local result = rng.percent(self.val)
		for i, p in ipairs(self._dependencies) do
			if p[1] == 'and' then
				result = result and p[2]()
			elseif p[1] == 'or' then
				result = result or p[2]()
			end
		end
		self._result = result
		self._resolved = true
	end
	return self._result
end

function _M:add_and(other)
	assert(self._resolved == false, "tried to add a probability to a resolved object")
	if type(other) == "number" then
		other = _M.new{val=other}
	end
	self._dependencies[#self._dependencies+1] = {'and', other}
end

function _M:add_or(other)
	assert(self._resolved == false, "tried to add a probability to a resolved object")
	if type(other) == "number" then
		other = _M.new{val=other}
	end
	self._dependencies[#self._dependencies+1] = {'or', other}
end
