require "engine.class"
local ActorInventory = require "engine.interface.ActorInventory"

--- Handles actors stats
module(..., package.seeall, class.inherit(engine.interface.ActorInventory))

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
		for  i = 1, amount do
			local o = self:removeObject(inven, inven.max, true)
			if o then
				self:addObject(self.INVEN_INVEN, o)
			end
			inven.max = inven.max - 1
		end
		-- Now remove the slot
		if inven.max <= 0 then
			self.inven[self["INVEN_"..inven_id]] = nil
		end
		self:sortInven(self.INVEN_INVEN)
	end
end