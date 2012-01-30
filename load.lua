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

-- This file loads the game module, and loads data
local KeyBind = require "engine.KeyBind"
local DamageType = require "engine.DamageType"
local ActorStats = require "engine.interface.ActorStats"
local ActorResource = require "engine.interface.ActorResource"
local ActorAI = require "engine.interface.ActorAI"
local ActorLevel = require "engine.interface.ActorLevel"
local ActorInventory = require "engine.interface.ActorInventory"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local ActorInventory = require "engine.interface.ActorInventory"
local Birther = require "mod.class.Birther"
local Probability = require "mod.class.Probability"
local AtomicEffects = require "mod.class.interface.AtomicEffects"
local PartTalents = require "mod.class.interface.PartTalents"
local PlayerDisplay = require "mod.class.PlayerDisplay"

-- Useful keybinds
KeyBind:load("move,hotkeys,inventory,actions,interface,debug")

-- Damage types
DamageType:loadDefinition("/data/damage_types.lua")

-- Body parts
ActorInventory:defineInventory("TORSO", "Torso", true, "The big middle bit... hopefully not too squishy.")
ActorInventory:defineInventory("ARM", "Arm", true, "The things that you use to whack other things with.")
ActorInventory:defineInventory("HAND", "Hand", true, "Those opposable thumbs do come in handy.")
ActorInventory:defineInventory("HEAD", "Head", true, "Where most creatures keep their brain and sensory organs.")
ActorInventory:defineInventory("EYE", "Eye", true, "See Spot run.")
ActorInventory:defineInventory("LEG", "Leg", true, "Run away!")
ActorInventory:defineInventory("COVER", "Cover", true, "We cannot have nudity.")
ActorInventory:defineInventory("GRIP", "Grip", true, "Put those opposable appendages to work.")
ActorInventory:defineInventory("GENE", "Gene", true, "Evolution is the name of the game.")
ActorInventory:defineInventory("MODULE", "Module", true, "Remember, the square peg goes in the square hole.")

-- Talents
PartTalents:loadDefinition("/data/talents.lua")

-- Atomic Effects
AtomicEffects:loadDefinition("/data/atomic_effects.lua")

-- Actor resources
ActorResource:defineResource("Fidelity", "fidelity", nil, "fidelity_regen", "Fidelity is the measure of genetic stability.  It ranges from 100% (good) to 0% (bad).", 0, 100) -- fidelity/sync come from parts
ActorResource:defineResource("Sync", "sync", nil, "sync_regen", "Sync is the measure of communication between organic and cybernetic parts.  It ranges from 100% (good) to 0% (bad).", 0, 100)
ActorResource:defineResource("Bioenergy", "bioenergy", nil, "bioenergy_regen", "Bioenergy is the amount of energy available to your body, including cybernetic implants.", 0, 50) -- bioenergy is innate but can also come from other sources

-- Actor stats
ActorStats:defineStat("Strength",	"str", 10, 1, 100, "Strength defines your character's ability to apply physical force. It increases your melee damage, damage with heavy weapons, your chance to resist physical effects, and carrying capacity.")
ActorStats:defineStat("Dexterity",	"dex", 10, 1, 100, "Dexterity defines your character's ability to be agile and alert. It increases your chance to hit, your ability to avoid attacks and your damage with light weapons.")
ActorStats:defineStat("Constitution",	"con", 10, 1, 100, "Constitution defines your character's ability to withstand and resist damage. It increases your maximum life and physical resistance.")

-- Actor AIs
ActorAI:loadDefinition("/engine/ai/")
ActorAI:loadDefinition("/mod/ai/")

-- Additional resolvers
dofile("/mod/resolvers.lua")

-- Birther descriptor
Birther:loadDefinition("/data/birth/descriptors.lua")

return {require "mod.class.Game" }
