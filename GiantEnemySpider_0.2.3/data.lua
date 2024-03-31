require("prototypes.entity")
require("prototypes.item")
require("__GiantEnemySpider__.spider-animations")
require("__GiantEnemySpider__.utilities")

levels = 10

function create_spider(level)
    local spider_entity = table.deepcopy(data.raw["spider-vehicle"]["giantenemyspider-spider"])
    spider_entity.minable = nil
    spider_entity.name = "giantenemyspider-spider-" .. level
    spider_entity.localised_name = {"", {"custom.level"}, " ", level, " ", {"entity-name.giantenemyspider-spider"}}
    healths = {10, 50, 200, 250, 300, 500, 1000, 2500, 5000, 10000}
    spider_entity.max_health = healths[level] * settings.startup["giantenemyspider-health-scale"].value
    spider_entity.movement_energy_consumption = 3.5 * level .. "kW"
    spider_entity.height = -0.1 + 0.4 * level
    spider_entity.corpse = "giantenemyspider-spider-remnant-" .. math.ceil(level / 2)
    box_size = math.max(1, level / 2)
    spider_entity.selection_box = {{-box_size, -box_size}, {box_size, box_size}},
    build_sprites(spider_entity, level)
    data:extend{
        spider_entity
    }
end

function build_sprites(spider_entity, level)
    local scales = {0.2, 0.3, 0.4, 0.6, 0.8, 1, 1.5, 2, 2.5, 3}
    local leg_scales = {0.05, 0.1, 0.2, 0.6, 0.8, 1, 1.5, 2, 2.5, 3}
    local multiplier = scales[level]
    local leg_multiplier = leg_scales[level]
    local scaled_animation = build_animations(multiplier)
    spider_entity.graphics_set = scaled_animation.torso
    spider_entity.graphics_set.legs = scaled_animation.legs
    if (level > 7) then
        leg_scale_variant = "4"
    elseif (level > 4) then
        leg_scale_variant = "1"
    elseif (level > 2) then
        leg_scale_variant = "05"
    else
        leg_scale_variant = "01"
    end
    spider_entity.spider_engine.legs = build_legs(multiplier, leg_multiplier, leg_scale_variant)
end

for i = 1, levels do
    create_spider(i)
end

-- SPIDER SPAWNING ENTITY
local spider_spawner = table.deepcopy(data.raw["unit-spawner"]["biter-spawner"])
spider_spawner.name = "giantenemyspider-spawner"
spider_spawner.result_units = (function()
    local res = {}
    local names = {
        "giantenemyspider-spider-1", "giantenemyspider-spider-2", "giantenemyspider-spider-3",
        "giantenemyspider-spider-4", "giantenemyspider-spider-5", "giantenemyspider-spider-6",
        "giantenemyspider-spider-7", "giantenemyspider-spider-8", "giantenemyspider-spider-9",
        "giantenemyspider-spider-10"
    }
    
    for i = 1, #names do
        local start_factor = (i - 1) * 0.1
        local end_factor = start_factor + 0.3 -- Ensures overlap with the next 2 spiders
        end_factor = math.min(end_factor, 1) -- Caps the evolution factor at 1
        
        -- The weight decreases as new spiders start spawning
        local weight = (i <= #names - 2) and {0.5, 0.0} or {0.5, 0.5} -- Adjusts for the last 2 spiders

        table.insert(res, {names[i], {{start_factor, weight[1]}, {end_factor, weight[2]}}})
    end
    
    return res
end)()
spider_spawner.pollution_absorption_absolute = 20
spider_spawner.pollution_absorption_proportional = 0.01
spider_spawner.spawning_radius = 0
spider_spawner.max_friends_around_to_spawn = 0
spider_spawner.max_count_of_owned_units = 0
spider_spawner.absorbed_pollution = 1

data:extend{
    spider_spawner
}