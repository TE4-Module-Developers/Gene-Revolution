--- Resolves equipment creation for an actor
function resolvers.equip(t)
        return {__resolver="equip", __resolve_last=true, t}
end
--- Actually resolve the equipment creation
function resolvers.calc.equip(t, e)
--      print("Equipment resolver for", e.name)
        -- Iterate of object requests, try to create them and equip them
        for i, filter in ipairs(t[1]) do
--              print("Equipment resolver", e.name, filter.type, filter.subtype, filter.defined)
                local o
                if not filter.defined then
                        o = game.zone:makeEntity(game.level, "object", filter, nil, true)
                else
                        local forced
                        o, forced = game.zone:makeEntityByName(game.level, "object", filter.defined, filter.random_art_replace and true or false)
                        -- If we forced the generation this means it was already found
                        if forced then
--                              print("Serving unique "..o.name.." but forcing replacement drop")
                                filter.random_art_replace.chance = 100
                        end
                end
                if o then
--                      print("Zone made us an equipment according to filter!", o:getName())

                        if e:wearObject(o, true, false) == false then
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
