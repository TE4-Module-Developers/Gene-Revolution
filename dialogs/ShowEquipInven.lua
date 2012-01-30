require "engine.class"
local ShowEquipInven = require "engine.dialogs.ShowEquipInven"

module(..., package.seeall, class.inherit(engine.dialogs.ShowEquipInven))

function _M:generateList(no_update)
	-- Makes up the list
	self.equip_list = {}
	local list = self.equip_list
	local chars = {}
	local i = 1
	self.max_h = 0
	local recurse_parts
	recurse_parts = function(part)
		for inven_id =  1, #part.inven_def do
			if part.inven[inven_id] and (part.inven_def[inven_id].is_worn or part.inven_def[inven_id].is_shown_equip) then
				self.max_h = math.max(self.max_h, #part.inven_def[inven_id].description:splitLines(self.iw - 10, self.font))
	
				for item=1,part.inven[inven_id].max do
					local o = part.inven[inven_id][item]
					if not o then
						list[#list+1] = { id=#list+1, char="", name=tstring{{"font", "bold"}, "Missing ", part.inven_def[inven_id].name:capitalize(), {"font", "normal"}}, color={0x90, 0x90, 0x90}, inven=inven_id, cat="", encumberance="", desc=part.inven_def[inven_id].description }
					else
						if not self.filter or self.filter(o) then
							local char = self:makeKeyChar(i)
		
							local enc = 0
							o:forAllStack(function(o) enc=enc+o.encumber end)
		
							list[#list+1] = { id=#list+1, char=char, name=o:getName(), sortname=o:getName():toString():removeColorCodes(), color=o:getDisplayColor(), object=o, part=part, inven=inven_id, item=item, cat=o.subtype, encumberance=enc, desc=o:getDesc() }
							chars[char] = #list
							i = i + 1
						end
						recurse_parts(o)
					end
				end
			end
		end
	end
	recurse_parts(self.actor)

	list.chars = chars
	self.equip_list = list

	-- Makes up the list
	self.inven_list = {}
	local list = self.inven_list
	local chars = {}
	local i = 1
	for item, o in ipairs(self.actor:getInven("INVEN") or {}) do
		if not self.filter or self.filter(o) then
			local char = self:makeKeyChar(i)

			local enc = 0
			o:forAllStack(function(o) enc=enc+o.encumber end)

			list[#list+1] = { id=#list+1, char=char, name=o:getName(), sortname=o:getName():toString():removeColorCodes(), color=o:getDisplayColor(), object=o, part=self.actor, inven=self.actor.INVEN_INVEN, item=item, cat=o.subtype, encumberance=enc, desc=o:getDesc() }
			chars[char] = #list
			i = i + 1
		end
	end
	list.chars = chars

	if not no_update then
		self.c_inven:setList(self.inven_list)
		self.c_equip:setList(self.equip_list)
	end
end

function _M:use(item, button, event)
	if item then
		if self.action(item.object, item.part, item.inven, item.item, button, event) then
			game:unregisterDialog(self)
		end
	end
end