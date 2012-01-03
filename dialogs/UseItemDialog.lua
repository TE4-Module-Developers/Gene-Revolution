require "engine.class"
require "engine.ui.Dialog"
local List = require "engine.ui.List"
local Savefile = require "engine.Savefile"
local Map = require "engine.Map"

module(..., package.seeall, class.inherit(engine.ui.Dialog))

function _M:init(center_mouse, actor, object, item, inven, onuse)
    self.actor = actor
    self.object = object
    self.inven = inven
    self.item = item
    self.onuse = onuse

    self:generateList()
    local name = object:getName()
    local w = self.font_bold:size(name)
    engine.ui.Dialog.init(self, name, 1, 1)

    local list = List.new{width=math.max(w, self.max) + 10, nb_items=#self.list, list=self.list, fct=function(item) self:use(item) end}

    self:loadUI{
        {left=0, top=0, ui=list},
    }
    self:setupUI(true, true, function(w, h)
        if center_mouse then
            local mx, my = core.mouse.get()
            self.force_x = mx - w / 2
            self.force_y = my - (self.h - self.ih + list.fh / 3)
        end
    end)

    self.key:addBinds{ EXIT = function() game:unregisterDialog(self) end, }
end

function _M:use(item)
    if not item then return end
    game:unregisterDialog(self)

    local act = item.action

    --if act == "use" then
        --self.actor:playerUseItem(self.object, self.item, self.inven, self.onuse)
        --self.onuse(self.inven, self.item, self.object, true)
    --else
    if act == "drop" then
        self.actor:doDrop(self.inven, self.item, function() self.onuse(self.inven, self.item, self.object, false) end)
    elseif act == "wear" then
        self.actor:doWear(self.inven, self.item, self.object)
        self.onuse(self.inven, self.item, self.object, false)
    elseif act == "takeoff" then
        self.actor:doTakeoff(self.inven, self.item, self.object)
        self.onuse(self.inven, self.item, self.object, false)
    end
end

function _M:generateList()
    local list = {}

    --if self.object:canUseObject() then list[#list+1] = {name="Use", action="use"} end
    if self.inven == self.actor.INVEN_INVEN and self.object:wornInven() and self.actor:getInven(self.object:wornInven()) then list[#list+1] = {name="Wield/Wear", action="wear"} end
    if self.inven ~= self.actor.INVEN_INVEN and self.object:wornInven() then list[#list+1] = {name="Take off", action="takeoff"} end
    if self.inven == self.actor.INVEN_INVEN then list[#list+1] = {name="Drop", action="drop"} end

    self.max = 0
    self.maxh = 0
    for i, v in ipairs(list) do
        local w, h = self.font:size(v.name)
        self.max = math.max(self.max, w)
        self.maxh = self.maxh + self.font_h
    end

    self.list = list
end