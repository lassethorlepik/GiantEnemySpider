require("AISpiders")



local function createGridTypes()
    -- Ammo Format: ["ammo"] = {type="<rocket type>", count=<rocket count>}   |   Example: ["ammo"] = {name="rocket", count=100}
    -- Health Format: ["health"] = <health value>   |   Example: ["health"] = 1000
    -- Grid Format: [{x, y}] = "<item name>"   |   Example: [{x, y}] = "solar-panel-equipment"
    return {
        {
            ["health"] = 10,
            [{0, 0}] = "giantenemyspider-fangs-1",
            [{0, 2}] = "giantenemyspider-armor-1",
            [{6, 2}] = "giantenemyspider-heart-1",
        },
        {
            ["health"] = 50,
            [{0, 0}] = "giantenemyspider-fangs-1",
            [{0, 2}] = "giantenemyspider-armor-1",
            [{6, 2}] = "giantenemyspider-heart-1",
        },
        {
            ["health"] = 200,
            [{0, 0}] = "giantenemyspider-fangs-1",
            [{0, 2}] = "giantenemyspider-fangs-1",
            [{0, 4}] = "battery-equipment",
            [{1, 4}] = "battery-equipment",
            [{2, 0}] = "giantenemyspider-armor-1",
            [{6, 2}] = "giantenemyspider-heart-1",
        },
        {
            ["health"] = 250,
            [{0, 0}] = "giantenemyspider-fangs-1",
            [{0, 2}] = "giantenemyspider-fangs-1",
            [{0, 4}] = "giantenemyspider-armor-1",
            [{2, 0}] = "battery-equipment",
            [{2, 2}] = "battery-equipment",
            [{3, 0}] = "battery-equipment",
            [{3, 2}] = "battery-equipment",
            [{6, 2}] = "giantenemyspider-heart-1",
        },
        {
            ["health"] = 300,
            [{0, 0}] = "giantenemyspider-fangs-1",
            [{0, 2}] = "personal-laser-defense-equipment",
            [{0, 4}] = "giantenemyspider-armor-1",
            [{2, 0}] = "giantenemyspider-web-1",
            [{3, 0}] = "battery-equipment",
            [{3, 2}] = "battery-equipment",
            [{6, 2}] = "giantenemyspider-heart-1",
        },
        {
            ["health"] = 500,
            [{0, 0}] = "giantenemyspider-armor-1",
            [{0, 2}] = "giantenemyspider-fangs-1",
            [{0, 4}] = "giantenemyspider-armor-1",
            [{2, 0}] = "giantenemyspider-web-1",
            [{2, 2}] = "giantenemyspider-web-1",
            [{2, 4}] = "giantenemyspider-web-1",
            [{4, 0}] = "battery-equipment",
            [{4, 1}] = "battery-equipment",
            [{4, 2}] = "giantenemyspider-leg-upgrade-1",
            [{4, 4}] = "giantenemyspider-leg-upgrade-1",
            [{6, 0}] = "battery-mk2-equipment",
            [{6, 2}] = "giantenemyspider-heart-1",
            [{7, 0}] = "battery-mk2-equipment",
            [{8, 0}] = "battery-mk2-equipment",
            [{9, 0}] = "battery-mk2-equipment"
        },
        {
            ["health"] = 1000,
            [{0, 0}] = "giantenemyspider-armor-1",
            [{0, 2}] = "giantenemyspider-fangs-1",
            [{0, 4}] = "giantenemyspider-armor-1",
            [{2, 0}] = "giantenemyspider-web-1",
            [{2, 2}] = "giantenemyspider-web-1",
            [{2, 4}] = "giantenemyspider-web-1",
            [{4, 0}] = "battery-equipment",
            [{4, 1}] = "battery-equipment",
            [{4, 2}] = "battery-equipment",
            [{4, 3}] = "battery-equipment",
            [{4, 4}] = "giantenemyspider-armor-1",
            [{6, 0}] = "giantenemyspider-leg-upgrade-2",
            [{6, 2}] = "giantenemyspider-heart-1",
            [{8, 0}] = "giantenemyspider-leg-upgrade-2"
        },
        {
            ["health"] = 2500,
            [{0, 0}] = "giantenemyspider-armor-1",
            [{0, 2}] = "giantenemyspider-armor-1",
            [{0, 4}] = "giantenemyspider-armor-1",
            [{2, 0}] = "giantenemyspider-fangs-1",
            [{2, 2}] = "giantenemyspider-poison-1",
            [{2, 4}] = "giantenemyspider-fangs-1",
            [{4, 0}] = "giantenemyspider-web-1",
            [{4, 2}] = "giantenemyspider-web-1",
            [{4, 4}] = "giantenemyspider-web-1",
            [{6, 0}] = "giantenemyspider-leg-upgrade-2",
            [{6, 2}] = "giantenemyspider-heart-1",
            [{8, 0}] = "giantenemyspider-leg-upgrade-2"
        },
        {
            ["health"] = 5000,
            [{0, 0}] = "giantenemyspider-fangs-1",
            [{0, 2}] = "giantenemyspider-fangs-1",
            [{0, 4}] = "giantenemyspider-fangs-1",
            [{2, 0}] = "giantenemyspider-armor-1",
            [{2, 2}] = "giantenemyspider-poison-1",
            [{2, 4}] = "giantenemyspider-armor-1",
            [{4, 0}] = "giantenemyspider-web-1",
            [{4, 2}] = "giantenemyspider-web-1",
            [{4, 4}] = "giantenemyspider-web-1",
            [{6, 0}] = "giantenemyspider-leg-upgrade-3",
            [{6, 2}] = "giantenemyspider-heart-1",
            [{8, 0}] = "giantenemyspider-leg-upgrade-3"
        },
        {
            ["health"] = 10000,
            ["ammo"] = {name="explosive-rocket", count=800},
            [{0, 0}] = "giantenemyspider-armor-1",
            [{0, 2}] = "giantenemyspider-fangs-1",
            [{0, 4}] = "giantenemyspider-armor-1",
            [{2, 0}] = "giantenemyspider-poison-1",
            [{2, 2}] = "giantenemyspider-poison-1",
            [{2, 4}] = "giantenemyspider-poison-1",
            [{4, 0}] = "giantenemyspider-web-1",
            [{4, 2}] = "giantenemyspider-web-1",
            [{4, 4}] = "giantenemyspider-web-1",
            [{6, 0}] = "giantenemyspider-leg-upgrade-3",
            [{6, 2}] = "giantenemyspider-heart-1",
            [{8, 0}] = "giantenemyspider-leg-upgrade-3"
        }
    }
end

local function loadGrid(entity, templateID)
    grid = entity.grid
    if not (templateID > #createGridTypes()) then
        local gridToLoad = createGridTypes()[templateID]
        for slot, item in pairs(gridToLoad) do
            if slot == "ammo" then
                entity.get_inventory(defines.inventory.spider_ammo).insert(item)
            else
                if slot == "health" then
                    entity.health = item
                else
                    grid.put({name=item, position=slot})
                end
            end
        end
    end
    return grid
end

-- Create a ring of positions for the spider to patrol
local function generatePositions(spider)
    local points = {}
    local x, y, r, p, s = spider.position.x, spider.position.y, 23, 10, 5
    for i = 1, p do
        local angle = 360 / p * i * math.pi / 180
        local ptx, pty = x + (r + math.random(-1 * s, s)) * math.cos( angle ), y + (r + math.random(-1 * s, s)) * math.sin( angle )
        points[#points + 1] = {ptx, pty}
    end
    return points
end

local function nestBuilt(nestEntity)
    -- Unused
end

script.on_event(defines.events.on_chunk_generated,
    function(event)
        for i, spawner in pairs(event.surface.find_entities_filtered({area=event.area, type="unit-spawner"})) do
            nestBuilt(spawner)
        end
    end
)

script.on_event(defines.events.on_biter_base_built,
    function(event)
        if event.entity and event.entity.valid and event.entity.type == "unit-spawner" then
            nestBuilt(event.entity)
        end
    end
)

-- Converts a spidertron's grid to a file to be used in custom grid layouts here.
-- /sc convertSpiderGrid(game.players["Electric131"].surface.find_entities_filtered({position=game.players[1].position, radius=5, type="spider-vehicle"})[1])
function convertSpiderGrid(spider)
    local takenItems = "{"
    if spider.get_inventory(defines.inventory.spider_ammo).get_item_count("rocket") > 0 then
        takenItems = takenItems .. "\n\t[\"ammo\"] = {" .. "name=\"rocket\", count=" .. spider.get_inventory(defines.inventory.spider_ammo).get_item_count("rocket") .. "}"
    else
        if spider.get_inventory(defines.inventory.spider_ammo).get_item_count("explosive-rocket") > 0 then
            takenItems = takenItems .. "\n\t[\"ammo\"] = {" .. "name=\"explosive-rocket\", count=" .. spider.get_inventory(defines.inventory.spider_ammo).get_item_count("explosive-rocket") .. "}"
        else
            if spider.get_inventory(defines.inventory.spider_ammo).get_item_count("atomic-bomb") > 0 then
                takenItems = takenItems .. "\n\t[\"ammo\"] = {" .. "name=\"atomic-bomb\", count=" .. spider.get_inventory(defines.inventory.spider_ammo).get_item_count("atomic-bomb") .. "}"
            end
        end
    end
    local replaceItems = {}
    local x = 0
    local y = 0
    while x < spider.grid.width do
        while y < spider.grid.height do
            local takenItem = spider.grid.take({position={x, y}})
            if takenItem then
                if not (takenItems == "{") then
                    takenItems = takenItems .. ","
                end
                takenItems = takenItems .. "\n\t[{" .. x .. ", " .. y .. "}] = \"" .. takenItem.name .. "\""
                replaceItems[{x, y}] = takenItem.name
            end
            y = y + 1
        end
        x = x + 1
        y = 0
    end
    takenItems = takenItems .. "\n}"
    game.write_file("spidergrid_out.txt", takenItems)
    for slot, item in pairs(replaceItems) do
        spider.grid.put({name=item, position=slot})
    end
end

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
    spawnSpider(character, level, true)
end)

function spawnSpider(spawner, level, commandSpawned)
    if #spawner.surface.find_tiles_filtered({position=spawner.position,radius=5,name="water"}) == 0 then -- Don't spawn on water
        if commandSpawned then
            force = game.forces["enemy"]
            level = tonumber(level)
        else
            force = spawner.force
            level = math.floor(evolution * 10) + 1
        end
        local evolution = force.evolution_factor
        local spider = spawner.surface.create_entity({name="giantenemyspider-spider-" .. level, force=force, position=spawner.position})
        spider.color = {r = 1, g = 0, b = 0, a = 0.5}
        loadGrid(spider, level)
        local options = {}
        options["patrolPositions"] = generatePositions(spider)
        options["restockPoint"] = spawner.position
        options["level"] = level
        spider, id = AISpiders_loadSpider(spider, options)
        AISpiders_findNextPosition(id)
    end
end