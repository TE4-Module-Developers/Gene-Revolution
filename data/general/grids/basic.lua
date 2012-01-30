-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

-----------------------------------------
-- Dungeony exits
-----------------------------------------
newEntity{
	define_as = "UP_WILDERNESS",
	type = "floor", subtype = "floor",
	name = "exit to the worldmap", image = "terrain/marble_floor.png", add_mos = {{image="terrain/stair_up_wild.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
}

newEntity{
	define_as = "UP", image = "terrain/marble_floor.png", add_mos = {{image="terrain/stair_up.png"}},
	type = "floor", subtype = "floor",
	name = "previous level",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "DOWN", image = "terrain/marble_floor.png", add_mos = {{image="terrain/stair_down.png"}},
	type = "floor", subtype = "floor",
	name = "next level",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}

-----------------------------------------
-- Outworld exits
-----------------------------------------
newEntity{
	define_as = "FLAT_UP_WILDERNESS",
	type = "floor", subtype = "floor",
	name = "exit to the worldmap", image = "terrain/marble_floor.png", add_mos = {{image="terrain/worldmap.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
}

newEntity{
	define_as = "FLAT_UP8",
	type = "floor", subtype = "floor",
	name = "way to the previous level", image = "terrain/marble_floor.png", add_mos = {{image="terrain/way_next_8.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "FLAT_UP2",
	type = "floor", subtype = "floor",
	name = "way to the previous level", image = "terrain/marble_floor.png", add_mos = {{image="terrain/way_next_2.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "FLAT_UP4",
	type = "floor", subtype = "floor",
	name = "way to the previous level", image = "terrain/marble_floor.png", add_mos = {{image="terrain/way_next_4.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "FLAT_UP6",
	type = "floor", subtype = "floor",
	name = "way to the previous level", image = "terrain/marble_floor.png", add_mos = {{image="terrain/way_next_6.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "FLAT_DOWN8",
	type = "floor", subtype = "floor",
	name = "way to the next level", image = "terrain/marble_floor.png", add_mos = {{image="terrain/way_next_8.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "FLAT_DOWN2",
	type = "floor", subtype = "floor",
	name = "way to the next level", image = "terrain/marble_floor.png", add_mos = {{image="terrain/way_next_2.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "FLAT_DOWN4",
	type = "floor", subtype = "floor",
	name = "way to the next level", image = "terrain/marble_floor.png", add_mos = {{image="terrain/way_next_4.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "FLAT_DOWN6",
	type = "floor", subtype = "floor",
	name = "way to the next level", image = "terrain/marble_floor.png", add_mos = {{image="terrain/way_next_6.png"}},
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}

-----------------------------------------
-- Basic floors
-----------------------------------------
newEntity{
	define_as = "FLOOR",
	type = "floor", subtype = "floor",
	name = "floor", image = "terrain/marble_floor.png",
	display = '.', color_r=255, color_g=255, color_b=255, back_color=colors.DARK_GREY,
	grow = "WALL",
}

-----------------------------------------
-- Walls
-----------------------------------------
newEntity{
	define_as = "WALL",
	type = "wall", subtype = "floor",
	name = "wall", image = "terrain/granite_wall1.png",
	display = '#', color_r=255, color_g=255, color_b=255, back_color=colors.GREY,
	z = 3,
	nice_tiler = { method="wall3d", inner={"WALL", 100, 1, 5}, north={"WALL_NORTH", 100, 1, 5}, south={"WALL_SOUTH", 10, 1, 17}, north_south="WALL_NORTH_SOUTH", small_pillar="WALL_SMALL_PILLAR", pillar_2="WALL_PILLAR_2", pillar_8={"WALL_PILLAR_8", 100, 1, 5}, pillar_4="WALL_PILLAR_4", pillar_6="WALL_PILLAR_6" },
	always_remember = true,
	does_block_move = true,
	can_pass = {pass_wall=1},
	block_sight = true,
	air_level = -20,
	dig = "FLOOR",
}
for i = 1, 5 do
	newEntity{ base = "WALL", define_as = "WALL"..i, image = "terrain/granite_wall1_"..i..".png", z = 3}
	newEntity{ base = "WALL", define_as = "WALL_NORTH"..i, image = "terrain/granite_wall1_"..i..".png", z = 3, add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}}
	newEntity{ base = "WALL", define_as = "WALL_PILLAR_8"..i, image = "terrain/granite_wall1_"..i..".png", z = 3, add_displays = {class.new{image="terrain/granite_wall_pillar_8.png", z=18, display_y=-1}}}
end
newEntity{ base = "WALL", define_as = "WALL_NORTH_SOUTH", image = "terrain/granite_wall2.png", z = 3, add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}}
newEntity{ base = "WALL", define_as = "WALL_SOUTH", image = "terrain/granite_wall2.png", z = 3}
for i = 1, 17 do newEntity{ base = "WALL", define_as = "WALL_SOUTH"..i, image = "terrain/granite_wall2_"..i..".png", z = 3} end
newEntity{ base = "WALL", define_as = "WALL_SMALL_PILLAR", image = "terrain/marble_floor.png", z=1, add_displays = {class.new{image="terrain/granite_wall_pillar_small.png",z=3}, class.new{image="terrain/granite_wall_pillar_small_top.png", z=18, display_y=-1}}}
newEntity{ base = "WALL", define_as = "WALL_PILLAR_6", image = "terrain/marble_floor.png", z=1, add_displays = {class.new{image="terrain/granite_wall_pillar_3.png",z=3}, class.new{image="terrain/granite_wall_pillar_9.png", z=18, display_y=-1}}}
newEntity{ base = "WALL", define_as = "WALL_PILLAR_4", image = "terrain/marble_floor.png", z=1, add_displays = {class.new{image="terrain/granite_wall_pillar_1.png",z=3}, class.new{image="terrain/granite_wall_pillar_7.png", z=18, display_y=-1}}}
newEntity{ base = "WALL", define_as = "WALL_PILLAR_2", image = "terrain/marble_floor.png", z=1, add_displays = {class.new{image="terrain/granite_wall_pillar_2.png",z=3}}}

-----------------------------------------
-- Hard Walls
-----------------------------------------
newEntity{
	define_as = "HARDWALL",
	type = "wall", subtype = "floor",
	name = "wall", image = "terrain/granite_wall1.png",
	display = '#', color_r=255, color_g=255, color_b=255, back_color=colors.GREY,
	z = 3,
	nice_tiler = { method="wall3d", inner={"HARDWALL", 100, 1, 5}, north={"HARDWALL_NORTH", 100, 1, 5}, south={"HARDWALL_SOUTH", 10, 1, 17}, north_south="HARDWALL_NORTH_SOUTH", small_pillar="HARDWALL_SMALL_PILLAR", pillar_2="HARDWALL_PILLAR_2", pillar_8={"HARDWALL_PILLAR_8", 100, 1, 5}, pillar_4="HARDWALL_PILLAR_4", pillar_6="HARDWALL_PILLAR_6" },
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	air_level = -20,
}
for i = 1, 5 do
	newEntity{ base = "HARDWALL", define_as = "HARDWALL"..i, image = "terrain/granite_wall1_"..i..".png", z = 3}
	newEntity{ base = "HARDWALL", define_as = "HARDWALL_NORTH"..i, image = "terrain/granite_wall1_"..i..".png", z = 3, add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}}
	newEntity{ base = "HARDWALL", define_as = "HARDWALL_PILLAR_8"..i, image = "terrain/granite_wall1_"..i..".png", z = 3, add_displays = {class.new{image="terrain/granite_wall_pillar_8.png", z=18, display_y=-1}}}
end
newEntity{ base = "HARDWALL", define_as = "HARDWALL_NORTH_SOUTH", image = "terrain/granite_wall2.png", z = 3, add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}}
newEntity{ base = "HARDWALL", define_as = "HARDWALL_SOUTH", image = "terrain/granite_wall2.png", z = 3}
for i = 1, 17 do newEntity{ base = "HARDWALL", define_as = "HARDWALL_SOUTH"..i, image = "terrain/granite_wall2_"..i..".png", z = 3} end
newEntity{ base = "HARDWALL", define_as = "HARDWALL_SMALL_PILLAR", image = "terrain/marble_floor.png", z=1, add_displays = {class.new{image="terrain/granite_wall_pillar_small.png", z=3}, class.new{image="terrain/granite_wall_pillar_small_top.png", z=18, display_y=-1}}}
newEntity{ base = "HARDWALL", define_as = "HARDWALL_PILLAR_6", image = "terrain/marble_floor.png", z=1, add_displays = {class.new{image="terrain/granite_wall_pillar_3.png", z=3}, class.new{image="terrain/granite_wall_pillar_9.png", z=18, display_y=-1}}}
newEntity{ base = "HARDWALL", define_as = "HARDWALL_PILLAR_4", image = "terrain/marble_floor.png", z=1, add_displays = {class.new{image="terrain/granite_wall_pillar_1.png", z=3}, class.new{image="terrain/granite_wall_pillar_7.png", z=18, display_y=-1}}}
newEntity{ base = "HARDWALL", define_as = "HARDWALL_PILLAR_2", image = "terrain/marble_floor.png", z=1, add_displays = {class.new{image="terrain/granite_wall_pillar_2.png", z=3}}}


-----------------------------------------
-- Doors
-----------------------------------------
newEntity{
	define_as = "DOOR",
	type = "wall", subtype = "floor",
	name = "door", image = "terrain/granite_door1.png",
	display = '+', color_r=238, color_g=154, color_b=77, back_color=colors.DARK_UMBER,
	nice_tiler = { method="door3d", north_south="DOOR_VERT", west_east="DOOR_HORIZ" },
	notice = true,
	always_remember = true,
	block_sight = true,
	is_door = true,
	door_opened = "DOOR_OPEN",
	dig = "FLOOR",
}
newEntity{
	define_as = "DOOR_OPEN",
	type = "wall", subtype = "floor",
	name = "open door", image="terrain/granite_door1_open.png",
	display = "'", color_r=238, color_g=154, color_b=77, back_color=colors.DARK_GREY,
	always_remember = true,
	is_door = true,
	door_closed = "DOOR",
}
newEntity{ base = "DOOR", define_as = "DOOR_HORIZ", image = "terrain/granite_door1.png", add_displays = {class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}, door_opened = "DOOR_HORIZ_OPEN"}
newEntity{ base = "DOOR_OPEN", define_as = "DOOR_HORIZ_OPEN", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/granite_door1_open.png", z=17}, class.new{image="terrain/granite_wall3.png", z=18, display_y=-1}}, door_closed = "DOOR_HORIZ"}
newEntity{ base = "DOOR", define_as = "DOOR_VERT", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/granite_door1_vert.png", z=17}, class.new{image="terrain/granite_door1_vert_north.png", z=18, display_y=-1}}, door_opened = "DOOR_OPEN_VERT", dig = "DOOR_OPEN_VERT"}
newEntity{ base = "DOOR_OPEN", define_as = "DOOR_OPEN_VERT", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/granite_door1_open_vert.png", z=17}, class.new{image="terrain/granite_door1_open_vert_north.png", z=18, display_y=-1}}, door_closed = "DOOR_VERT"}
