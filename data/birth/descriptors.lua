-- ToME - Tales of Middle-Earth
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

newBirthDescriptor{
	type = "base",
	name = "base",
	desc = {
	},

        body = { INVEN = 100, ARMS = 2, TORSO = 1, HEAD = 1, EYES = 2, LEGS = 1 },

	copy = {
		lite = 4,
		max_life = 25,
	},
}

newBirthDescriptor{
	type = "role",
	name = "Mr. Roboto",
	desc =
	{
		"I am the modern man.",
	},
        copy = {
                equipment = resolvers.equip{
                        {type="cyberpart", slot="LEFTARM",},
                },
        },
}

newBirthDescriptor{
	type = "role",
	name = "Aliens",
	desc =
	{
		"As in the movie.",
	},
        copy = {
                equipment = resolvers.equip{
                        {type="organicpart", slot="HEAD",},
                },
        },
}
