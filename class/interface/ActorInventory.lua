require "engine.class"
local ActorInventory = require "engine.interface.ActorInventory"

--- Handles actors stats
module(..., package.seeall, class.inherit(engine.interface.ActorInventory))

local find_actor
find_actor = function(act)
	if act.parent then return find_actor(act.parent)
	else return act end
end

--- Call when an object is worn
function _M:onWear(o)
	ActorInventory.onWear(self, o)
	o.parent = self
	o.actor = find_actor(self)
	local set_actor
	set_actor = function(part)
		part.actor = o.actor
	end
	self:applyToWornParts(set_actor)
end

--- Call when an object is taken off
function _M:onTakeoff(o)
	o.actor = nil
	local set_actor
	set_actor = function(part)
		part.actor = o.actor
	end
	self:applyToWornParts(set_actor)
	o.parent = nil
	ActorInventory.onTakeoff(self, o)
end

function _M:addSlot(inven_id, amount)
	local amount = amount or 1
	-- If the inventory does not exist, add it first
	if not self.inven[self["INVEN_"..inven_id]] then
		self.inven[self["INVEN_"..inven_id]] = {max=0, worn=self.inven_def[self["INVEN_"..inven_id]].is_worn, id=self["INVEN_"..inven_id], name=inven_id}
	end
	self.inven[self["INVEN_"..inven_id]].max = self.inven[self["INVEN_"..inven_id]].max + amount
end

function _M:removeSlot(inven_id, amount)
	local amount = amount or 1
	if self.inven[self["INVEN_"..inven_id]] then
		-- Remove any item in that slot
		local inven = self.inven[self["INVEN_"..inven_id]]
		local inven_holder = self.actor or self
		for i = 1, amount do
			local o = self:removeObject(inven, inven.max, true)
			if o and inven_holder and inven_holder:getInven("INVEN") then
				inven_holder:addObject(inven_holder.INVEN_INVEN, o)
			end
			inven.max = inven.max - 1
		end
		-- Now remove the slot
		if inven.max <= 0 then
			self.inven[self["INVEN_"..inven_id]] = nil
		end
		if inven_holder and inven_holder:getInven("INVEN") then
			inven_holder:sortInven(inven_holder.INVEN_INVEN)
		end
	end
end

-- Have to wrap the default INVEN_INVEN behavior
function _M:sortInven(inven)
	if not inven then
		local inven_holder = self.actor or self
		if inven_holder and inven_holder:getInven("INVEN") then
			inven_holder:sortInven(inven_holder.INVEN_INVEN)
		end
	else
		ActorInventory.sortInven(self, inven)
	end
end

function _M:doDrop(inven, item)
end

function _M:doWear(inven, item, o)
	local wear_object
	wear_object = function(part, slot)
		if slot.id == o:wornInven() then
			if self:removeObject(inven, item, true) then
				part:wearObject(o, true, true)
				return true
			end
		end
	end
	if not self:applyToWornParts(nil, wear_object) then
		game.logSeen(self, "%s cannot wear %s.", self.name, o.name)
	end
-- Not sure what is happening here... looks like we try to wear the replaced object 
--	if ro then
--		if type(ro) == "table" then self:addObject(inven, ro) end
--	elseif not ro then
--		self:addObject(inven, o)
--	end
--	self:sortInven()
--	self:useEnergy()
--	self.changed = true
end

function _M:doTakeoff(inven, item)
	local o = self:takeoffObject(inven, item)
	if o then
		local inven_holder = self.actor or self
		if inven_holder and inven_holder:getInven("INVEN") then
			inven_holder:addObject(inven_holder.INVEN_INVEN, o)
			inven_holder:sortInven()
		end
	end
--	self:useEnergy()
--	self.changed = true
end

--- Recursively iterates through all worn parts and applies the functions
-- @param present_func A function that receives a part filling a slot, and returns true to stop recursion.
-- @param missing_func A function that receives the part and inven with an empty slot, and returns true to stop recursion.
function _M:applyToWornParts(present_func, missing_func)
	for i, slot in pairs(self.inven) do
		if slot.worn then
			-- Iterate through all parts
			for j=1,slot.max do
				local part = slot[j]
				if part then
					if present_func then
						if present_func(part, slot) then return true end
					end
					part:applyToWornParts(present_func, missing_func)
				elseif missing_func then
					if missing_func(self, slot) then return true end
				end
			end
		end
	end
end

function _M:getSize()
	local size = self.size or 0
	local sum_size = function(part)
		size = size + part:getSize()
	end
	self:applyToWornParts(sum_size)
	return size
end

function _M:getSizeTable()
	local t = {total = 0}
	local collect_size = function(part)
		if part.size then
			t.total = t.total + part.size
			t[#t+1] = {hit=t.total, e=part}
		end
	end
	self:applyToWornParts(collect_size)
	return t
end