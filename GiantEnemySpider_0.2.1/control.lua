require("AISpiders")

commands.add_command("aispiders_spawn", "Creates a spider near the player, requires level as argument.", function(command)
    if not game.player.admin then
        return
    end
    character = game.players[command.player_index].character
    local level = command.parameter
    if level == nil then
        game.players[command.player_index].print("Pass a number as argument")
        return 
    end
    local spider_entity = character.surface.create_entity{
        name="giantenemyspider-spider-" .. level,
        position=character.position,
        force="enemy"
    }
    loadGrid(spider_entity, tonumber(level))
    local options = {}
    options["patrolPositions"] = generatePositions(spider_entity)
    options["restockPoint"] = character.position
    options["spawner_number"] = -1
    options["level"] = tonumber(level)
    spider, id = AISpiders_loadSpider(spider_entity, options)
    global.AISpiders.spiderMap[spider_entity.unit_number] = id
    global.AISpiders.spiderNest[id] = -1
    AISpiders_findNextPosition(id, spider)
end)

commands.add_command("aispiders_reset", "Reloads most global variables", function(command)
    if not game.player.admin then
        return
    end
    loadData()
end)

script.on_event(defines.events.on_chunk_generated, function(event)
    local surface = event.surface
    local area = event.area
    local enemy_bases = surface.find_entities_filtered{
        area=area,
        type="unit-spawner",
        force="enemy"
    }
    for _, base in pairs(enemy_bases) do
        -- Decide whether to add a custom spawner near this base.
        if math.random() < 0.5 then
            local position = surface.find_non_colliding_position("giantenemyspider-spawner", base.position, 15, 1)
            if position then
                local new_nest = surface.create_entity{
                    name="giantenemyspider-spawner",
                    position=position,
                    force="enemy"
                }
                global.AISpiders.nests[new_nest.unit_number] = {position=position, surface=surface, force=base.force, spawner_id=new_nest.unit_number}
                global.AISpiders.spawnerUnits[new_nest.unit_number] = 0
            end
        end
    end
end)

script.on_event(defines.events.on_biter_base_built, function(event)
    local surface = event.entity.surface
    local area = event.area
    local enemy_bases = surface.find_entities_filtered{
        position=event.entity.position, 
        type="unit-spawner",
        force=event.entity.force
    }
    for _, base in pairs(enemy_bases) do
        -- Decide whether to add a spider spawner near this base.
        if math.random() < 0.5 then
            local position = surface.find_non_colliding_position("giantenemyspider-spawner", base.position, 15, 1)
            if position then
                local new_nest = surface.create_entity{
                    name="giantenemyspider-spawner",
                    position=position,
                    force="enemy"
                }
                global.AISpiders.nests[new_nest.unit_number] = {position=position, surface=surface, force=event.entity.force, spawner_id=new_nest.unit_number}
                global.AISpiders.spawnerUnits[new_nest.unit_number] = 0
            end
        end
    end
end)

script.on_event(defines.events.on_entity_died, function(event)
    global.AISpiders.nests[event.entity.unit_number] = nil
end, {{filter = "name", name = "giantenemyspider-spawner"}})

corpseModEnabled = script.active_mods["SpidertronEnhancements"]
if corpseModEnabled then
    script.on_event(defines.events.on_post_entity_died, function(event)
        local corpses = game.surfaces[event.surface_index].find_entities_filtered{name = "spidertron-enhancements-corpse", position = position}
        for _, corpse in pairs(corpses) do
            if corpse.get_item_count("giantenemyspider-heart-1") > 0 then
                corpse.destroy()
            end
        end
    end, {{filter = "type", type = "spider-vehicle"}})
end
