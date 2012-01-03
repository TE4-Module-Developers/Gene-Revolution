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
local Birther = require "mod.class.Birther"
local Probability = require "mod.class.Probability"
local AtomicEffects = require "mod.class.interface.AtomicEffects"
local ActorTalents = require "mod.class.interface.ActorTalents"

-- Useful keybinds
KeyBind:load("move,hotkeys,inventory,actions,interface,debug")

-- Damage types
DamageType:loadDefinition("/data/damage_types.lua")

-- Talents
ActorTalents:loadDefinition("/data/talents.lua")

-- Atomic Effects
AtomicEffects:loadDefinition("/data/atomic_effects.lua")

-- Actor resources
ActorResource:defineResource("Homeostasis", "homeostasis", nil, nil, "Homeostasis is the measure of genetic stability.  It ranges from 100% (good) to 0% (bad).")
ActorResource:defineResource("Coherence", "coherence", nil, nil, "Coherence is the measure of communication between organic and cybernetic parts.  It ranges from 100% (good) to 0% (bad).")
ActorResource:defineResource("Bioenergy", "bioenergy", nil, "bioenergy_regen", "Bioenergy is the amount of energy available to your body, including cybernetic implants.")

-- Actor stats
ActorStats:defineStat("Strength",	"str", 10, 1, 100, "Strength defines your character's ability to apply physical force. It increases your melee damage, damage with heavy weapons, your chance to resist physical effects, and carrying capacity.")
ActorStats:defineStat("Dexterity",	"dex", 10, 1, 100, "Dexterity defines your character's ability to be agile and alert. It increases your chance to hit, your ability to avoid attacks and your damage with light weapons.")
ActorStats:defineStat("Constitution",	"con", 10, 1, 100, "Constitution defines your character's ability to withstand and resist damage. It increases your maximum life and physical resistance.")

-- Actor AIs
ActorAI:loadDefinition("/engine/ai/")

-- Birther descriptor
Birther:loadDefinition("/data/birth/descriptors.lua")

-- Equipment slots
ActorInventory:defineInventory("HEAD", "head", true, "")
ActorInventory:defineInventory("MAINHAND", "main hand", true, "")
ActorInventory:defineInventory("OFFHAND", "off hand", true, "")
ActorInventory:defineInventory("BODY", "body", true, "")

return {require "mod.class.Game" }
