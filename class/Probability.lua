require "engine.class"

module(..., package.seeall, class.make)

function _M:init(t)
	t = t or {}
	-- val can be either a numeric value or a 3-member table describing a logical operator
	self._val = t.val or 1
	self._resolved = t._resolved or false
	local mt = getmetatable(self)
	mt.__call = _M.call
	mt.__mul = _M.land
	mt.__div = _M.lor
	mt.__mod = _M.lxor
	mt.__unm = _M.lnot
        getmetatable(self).__call = _M.call
end

--- Perform a logical AND operation between two Probabliity objects
-- @param other The probability object to perform a logical AND with
-- @return A combined Probability object
function _M:land(other)
	return _M.new{val={self, 'and', other}}
end

--- Perform a logical OR operation between two Probabliity objects
-- @param other The probability object to perform a logical OR with
-- @return A combined Probability object
function _M:lor(other)
	return _M.new{val={self, 'or', other}}
end

--- Perform a logical XOR operation between two Probabliity objects
-- @param other The probability object to perform a logical XOR with
-- @return A combined Probability object
function _M:lxor(other)
	return _M.new{val={self, 'xor', other}}
end

--- Perform a logical NOT operation on a Probability object
-- @return A new Probability object
function _M:lnot()
	return _M.new{val={'not', self}}
end

--- Predict the probability of success
-- WARNING: does not handle combining the same object, for example p1 * (p1 * p2) should be equivalent to (p1 * p2) but isn't.
-- @return float between 0 and 1
function _M:predict()
	if type(self._val) == "number" then
		return self._val
	elseif (type(self._val) == "table") and (#self._val == 3) then
		local p1 = self._val[1]:predict()
		local p3 = self._val[3]:predict()
		if self._val[2] == 'and' then
			return (p1 * p3)
		elseif self._val[2] == 'or' then
			return 1 - (1 - p1) * (1 - p3)
		elseif self._val[2] == 'xor' then
			return (1 - p1) * p3 + (1 - p3) * p1
		else
			game.log("Could not handle %s.", self._val)
		end
	elseif (type(self._val) == "table") and (#self._val == 2) then
		if self._val[1] == 'not' then
			return (1 - self._val[2]:predict())
		else
			game.log("Could not handle %s.", self._val)
		end
	else
		game.log("Could not handle %s.", self._val)
	end
end

--- Resolve the success/failure
-- @return boolean
function _M:call()
	if not self._resolved then
		local result
		if type(self._val) == "number" then
			result = rng.float(0, 1) <= self._val 
		elseif (type(self._val) == "table") and (#self._val == 3) then
			local r1 = self._val[1]()
			local r3 = self._val[3]()
			if self._val[2] == 'and' then
				result = r1 and r3
			elseif self._val[2] == 'or' then
				result = r1 or r3
			elseif self._val[2] == 'xor' then
				result = (r1 or r3) and not (r1 and r3)
			end
		end
		self._result = result
		self._resolved = true
	end
	return self._result
end

