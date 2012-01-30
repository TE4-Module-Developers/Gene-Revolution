require "engine.class"
require "engine.HotkeysDisplay"

module(..., package.seeall, class.inherit(engine.HotkeysDisplay))

-- Displays the hotkeys, keybinds & cooldowns
function _M:display()
	local a = self.actor
	if not a or not a.changed then return self.surface end

	local page = a.hotkey_page
	if page == 1 and core.key.modState("ctrl") then page = 2
	elseif page == 1 and core.key.modState("shift") then page = 3 end

	local hks = {}
	for i = 1, 12 do
		local j = i + (12 * (page - 1))
		if a.hotkey[j] and a.hotkey[j][1] == "talent" then
			hks[#hks+1] = {a.hotkey[j][3], i, "talent", a.hotkey[j][2]}
		elseif a.hotkey[j] and a.hotkey[j][1] == "inventory" then
			hks[#hks+1] = {a.hotkey[j][2], i, "inventory"}
		end
	end

	self.surface:erase(self.bgcolor[1], self.bgcolor[2], self.bgcolor[3])
	if self.bg_surface then self.surface:merge(self.bg_surface, 0, 0) end

	local x = 0
	local y = 0
	self.clics = {}
	self.items = {}

	for ii, ts in ipairs(hks) do
		local s
		local i = ts[2]
		local txt, color = "", {0,255,0}
		if ts[3] == "talent" then
			local part = ts[4]
			local t = part:getTalentFromId(ts[1])
			if part:isTalentCoolingDown(t) then
				txt = ("%s (%d)"):format(t.name, a:isTalentCoolingDown(t))
				color = {255,0,0}
			elseif part:isTalentActive(t.id) then
				txt = t.name
				color = {255,255,0}
			elseif not part:preUseTalent(t, true, true) then
				txt = t.name
				color = {190,190,190}
			else
				txt = t.name
				color = {0,255,0}
			end
		elseif ts[3] == "inventory" then
			local o = a:findInAllInventories(ts[1], {no_add_name=true, force_id=true, no_count=true})
			local cnt = 0
			if o then cnt = o:getNumber() end
			txt = ("%s (%d)"):format(o and o:getName{no_count=true} or ts[1], cnt)
			if cnt == 0 then
				color = {128,128,128}
			end
		end

		txt = ("%1d/%2d) %s"):format(page, i, txt)
		local w, h, gen
		if self.cache[txt] then
			gen = self.cache[txt]
			w, h = gen.fw, gen.fh
		else
			w, h = self.font:size(txt)
			gen = self.font:draw(txt, self.w / self.nb_cols, color[1], color[2], color[3], true)[1]
			gen.fw, gen.fh = w, h
		end
		gen.x, gen.y = x, y
		gen.i = i
		self.items[#self.items+1] = gen
		self.clics[i + (12 * (page - 1))] = {x,y,w+4,h+4}

		if y + self.font_h * 2 > self.h then
			x = x + self.w / self.nb_cols
			y = 0
		else
			y = y + self.font_h
		end
	end
end

--[[
--- Call when a mouse event arrives in this zone
-- This is optional, only if you need mouse support
function _M:onMouse(button, mx, my, click, on_over, on_click)
	local a = self.actor

	if button == "wheelup" and click then
		a:prevHotkeyPage()
		return
	elseif button == "wheeldown" and click then
		a:nextHotkeyPage()
		return
	end

	mx, my = mx - self.display_x, my - self.display_y
	for i, zone in pairs(self.clics) do
		if mx >= zone[1] and mx < zone[1] + zone[3] and my >= zone[2] and my < zone[2] + zone[4] then
			if on_click and click then
				if on_click(i, a.hotkey[i]) then click = false end
			end
			if button == "left" and click then
				a:activateHotkey(i)
			elseif button == "right" and click then
				a.hotkey[i] = nil
				a.changed = true
			else
				a.changed = true
				local oldsel = self.cur_sel
				self.cur_sel = i
				if on_over and self.cur_sel ~= oldsel then
					local text = ""
					if a.hotkey[i] and a.hotkey[i][1] == "talent" then
						local part = a.hotkey[i][2]
						local t = part:getTalentFromId(a.hotkey[i][3])
						text = tstring{{"color","GOLD"}, {"font", "bold"}, t.name, {"font", "normal"}, {"color", "LAST"}, true}
						text:merge(part:getTalentFullDescription(t))
					elseif a.hotkey[i] and a.hotkey[i][1] == "inventory" then
						local o = a:findInAllInventories(a.hotkey[i][2])
						if o then text = o:getDesc() else text = "Missing!" end
					end
					on_over(text)
				end
			end
			return
		end
	end
	self.cur_sel = nil
end
--]]