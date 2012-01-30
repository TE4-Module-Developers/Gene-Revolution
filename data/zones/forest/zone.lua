return {
	name = "Forest",
	level_range = {1, 1},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	width = 50, height = 50,
	all_lited = true,
	day_night = true,
	persistent = "zone",
	ambient_music = "Rainy Day.ogg",
	min_material_level = function() return game.state:isAdvanced() and 3 or 1 end,
	max_material_level = function() return game.state:isAdvanced() and 4 or 2 end,
	generator =  {
		map = {
			class = "engine.generator.map.Forest",
			edge_entrances = {4,6},
			zoom = 4,
			sqrt_percent = 30,
			noise = "fbm_perlin",
			floor = function() if rng.chance(20) then return "FLOWER" else return "GRASS" end end,
			wall = "TREE",
			up = "GRASS_UP4",
			down = "GRASS_DOWN6",
			door = "GRASS",
--			road = "DIRT",
--			add_road = true,
			do_ponds =  {
				nb = {0, 2},
				size = {w=25, h=25},
				pond = {{0.6, "DEEP_WATER"}, {0.8, "DEEP_WATER"}},
			},

--			nb_rooms = {0,0,0,1},
--			rooms = {"lesser_vault"},
--			lesser_vaults_list = {"honey_glade", "forest-ruined-building1", "forest-ruined-building2", "forest-ruined-building3", "forest-snake-pit", "mage-hideout"},
--			lite_room_chance = 100,
		},
		actor = {
			class = "engine.generator.actor.Random",
			nb_npc = {20, 30},
--			filters = { {max_ood=2}, },
--			nb_spots = 2, on_spot_chance = 35,
--			guardian = "TROLL_PROX",
--			guardian_spot = {type="guardian", subtype="guardian"},
		},
		object = {
			class = "engine.generator.object.OnSpots",
			nb_object = {6, 9},
			nb_spots = 2, on_spot_chance = 80,
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {6, 9},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				up = "GRASS_UP_WILDERNESS",
			}, },
		},
	},

	foreground = function(level, x, y, nb_keyframes)
		if not config.settings.tome.weather_effects or not level.foreground_particle then return end
		level.foreground_particle.ps:toScreen(x, y, true, 1)

		if nb_keyframes > 10 then return end
		if nb_keyframes > 0 and rng.chance(400 / nb_keyframes) then local s = game:playSound("ambient/horror/ambient_horror_sound_0"..rng.range(1, 6)) if s then s:volume(s:volume() * 1.5) end end
	end,
}
