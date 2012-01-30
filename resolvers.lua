--- Resolves equipment creation for an actor
function resolvers.equip(t)
	return {__resolver="equip", __resolve_last=true, t}
end
--- Actually resolve the equipment creation
function resolvers.calc.equip(t, e)
	print("Equipment resolver for", e.name)
	-- Iterate of object requests, try to create them and equip them
	for i, filter in ipairs(t[1]) do
		print("Equipment resolver", e.name, filter.type, filter.subtype, filter.slot, filter.defined)
		local o
		if not filter.defined then
			o = game.zone:makeEntity(game.level, "object", filter, nil, true)
		else
			local forced
			o, forced = game.zone:makeEntityByName(game.level, "object", filter.defined, filter.random_art_replace and true or false)
			-- If we forced the generation this means it was already found
			if forced then
--				print("Serving unique "..o.name.." but forcing replacement drop")
				filter.random_art_replace.chance = 100
			end
		end
		if o then
			print("Zone made us an equipment according to filter!", o:getName())

			-- Find a slot for the object, recursing down
			local recursive_wear
			recursive_wear = function(e, o)
				local worn = e:wearObject(o, true, false)
				if worn == false then
					for i, inven in pairs(e.inven) do
						for j, part in ipairs(inven) do
							worn = recursive_wear(part, o)
							if worn == true then return worn end
						end
					end
				else return worn end
			end
			if recursive_wear(e, o) == false then
				e:addObject(e.INVEN_INVEN, o)
			end
			-- Do not drop it unless it is an ego or better
			if filter.force_drop then o.no_drop = nil end
			if filter.never_drop then o.no_drop = true end
			game.zone:addEntity(game.level, o, "object")

		end
	end
	-- Delete the origin field
	return nil
end

--- Recursively resolves equipment creation for an actor
function resolvers.recursiveequip(t)
	return {__resolver="recursiveequip", __resolve_last=true, t}
end
--- Actually resolve the equipment creation
function resolvers.calc.recursiveequip(t, e)
	local slotCheck = function(slot)
		return function(e) return e.slot == slot end
	end
	local added = true
	local equip
	equip = function(part, slot)
		print("Equipment resolver", slot.name, t[1].type, t[1].subtype)
		local filter = table.clone(t[1], true)
		filter.special = slotCheck(slot.name)
		local o = game.zone:makeEntity(game.level, "object", filter, nil, true)
		if o then
			added = added or part:wearObject(o, true, false)
		end
	end
	while added do
		added = false
		e:applyToWornParts(nil, equip)
	end
end