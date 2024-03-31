-- Some base code by Electric131

-- How to use this script:
-- Create a Spidertron and give it the tag "AISpider" followed by the spider ID (Must be sequential), example: "AISpider1".
-- For example, you could have "AISpider1", "AISpider2", "AISpider3", "AISpider4". The sequential number stays the same.
-- If it is not following a sequential order, like 1, 2, 3, 4, ect. then it will ignore any others after it. (Stops if ID is invalid/doesn't exist)
-- There are other points that can be used which will be listed belowed, but the format will always be "AISpider<ID>-<AttributeName><AttributeValue>".
-- The AttributeValue will only be needed if specified by the Attribute below.
-- Attributes: "Patrol" (requires ID) and "Restock".
-- Note: The spider will always restock to the amount it started at.

currentVersion = "0.2.2"
allSpiderNames = {
    "giantenemyspider-spider-1",
    "giantenemyspider-spider-2",
    "giantenemyspider-spider-3",
    "giantenemyspider-spider-4",
    "giantenemyspider-spider-5",
    "giantenemyspider-spider-6",
    "giantenemyspider-spider-7",
    "giantenemyspider-spider-8",
    "giantenemyspider-spider-9",
    "giantenemyspider-spider-10"
}

function loadData()
    -- Initialize global data. (NOT PART OF CONFIG)
    global.AISpiders = global.AISpiders or {}
    global.AISpiders.AllSpiders = global.AISpiders.AllSpiders or {} -- Used to keep track of all AI Spiders' data.
    global.AISpiders.currentUpdateTick = global.AISpiders.currentUpdateTick or 0
    global.AISpiders.spawnerUnits = global.AISpiders.spawnerUnits or {} -- Each spawner keeps count of alive units
    global.AISpiders.spiderNest = global.AISpiders.spiderNest or {} -- Each spider keeps track of its spawner
    global.AISpiders.spiderLimit = global.AISpiders.spiderLimit or 80
    global.AISpiders.spiderMap = global.AISpiders.spiderMap or {} -- Maps entity unit_number to AllSpiders array index (spider id), used to speed up lookups to o(1) if only unit_number is known
    global.AISpiders.nests = global.AISpiders.nests or {} -- Stores all nest entites
    global.AISpiders.spawnTable = global.AISpiders.spawnTable or generateSpawnTable()
    global.AISpiders.despawnTime = global.AISpiders.despawnTime or 5 * 3600 -- 5 minutes in ticks
    global.AISpiders.lastVehicle = global.AISpiders.lastVehicle or {} -- Table to keep track of the last vehicle each player was in
    global.AISpiders.spawnDistance = global.AISpiders.spawnDistance or 2000
    global.AISpiders.healthScale = settings.startup["giantenemyspider-health-scale"].value
    AISpiders_reloadSpiders()
end

function generateSpawnTable()
    local res = {}
    local levels = 10
    for i = 1, levels do
        local start_factor = (i - 1) * 0.1
        local end_factor = start_factor + 0.3 -- Ensures overlap with the next 2 spiders
        end_factor = math.min(end_factor, 1) -- Caps the evolution factor at 1
        
        -- The weight decreases as new spiders start spawning
        local weight = (i <= levels - 2) and {0.5, 0.0} or {0.5, 0.5} -- Adjusts for the last 2 spiders

        table.insert(res, {i, {{start_factor, weight[1]}, {end_factor, weight[2]}}})
    end
    return res
end

function AISpiders_reloadSpiders()
    if (not global.AISpiders) then
        loadData()
        return
    end
    global.AISpiders.version = currentVersion
    global.AISpiders.Config = {}
    -- You can change the configuration settings below. The configuration with "Global" is global for all AISpiders, the others are the defaults per AISpider.
    global.AISpiders.GlobalDebugMessages = false -- Shows debug messages if true. Recommended to leave off.
    global.AISpiders.GlobalGiveupTime = 300 -- How long the spider will wait without moving before giving up and returning. Used if the spider gets stuck. (60 ticks = 1 second)
    global.AISpiders.Config.PatrolLeave = 100 -- How far in tiles the spider is allowed to leave it's last patrol location. This is used when it is chasing something.
    global.AISpiders.Config.AggroRange = 50 -- How far in tiles the spider will aggro onto an enemy building or player and move towards it.
    global.AISpiders.Config.LowHealth = 0.60 -- How low the health has to be to be considered low. (Scale of 0-1)
    global.AISpiders.Config.LowAmmo = 0.40 -- How low the ammo has to be to be considered low. (Scale of 0-1 as fraction of max ammo)
    global.AISpiders.Config.AutoReplenish = true -- If false, the spider will wait until it meets the starting values of ammo and health. If true, the ammo will magically appear.
    global.AISpiders.Config.AutoReplenishTime = 30 -- How often the spider will heal/regain ammo if AutoReplenish is enabled in ticks. (60 ticks = 1 second)

    if (true) then -- Set to false if using this in a scenario as this will reset all custom config on a scenario.
        for id, spiderData in pairs(global.AISpiders.AllSpiders) do
            for k, v in pairs(global.AISpiders.Config) do
                global.AISpiders.AllSpiders[id][k] = v
            end
        end
    end
end

function AISpiders_loadSpider(spiderObject, options)
    if spiderObject and spiderObject.valid then
        if not global.AISpiders then
            loadData()
        end
        local i = #global.AISpiders.AllSpiders + 1
        if global.AISpiders.GlobalDebugMessages then
            game.print("GiantEnemySpider: Adding spider ID " .. i)
        end
        local defaults = {
            ["spiderObject"] = spiderObject,
            ["state"] = "patrolling",
            ["chasing"] = nil,
            ["chasingPath"] = {},
            ["escorting"] = nil,
            ["wasEscorting"] = false,
            ["lastPatrolPoint"] = nil,
            ["patrolPoint"] = 0,
            ["giveupCooldown"] = 0,
            ["ignoreChase"] = false,
            ["replenishTime"] = 0,
            ["startingHealth"] = spiderObject.get_health_ratio(),
            ["patrolPositions"] = {},
            ["restockPoint"] = {},
            ["level"] = 1,
            ["spawner_number"] = -1,
            ["spawn_tick"] = game.tick,
            ["lastPosition"] = spiderObject.position,
        }
        if spiderObject.get_inventory(defines.inventory.spider_ammo).get_item_count("rocket") > 0 then
            defaults.startingAmmo = spiderObject.get_inventory(defines.inventory.spider_ammo).get_item_count("rocket")
            defaults.startingAmmoType = "rocket"
        else
            if spiderObject.get_inventory(defines.inventory.spider_ammo).get_item_count("explosive-rocket") > 0 then
                defaults.startingAmmo = spiderObject.get_inventory(defines.inventory.spider_ammo).get_item_count("explosive-rocket")
                defaults.startingAmmoType = "explosive-rocket"
            else
                if spiderObject.get_inventory(defines.inventory.spider_ammo).get_item_count("atomic-bomb") > 0 then
                defaults.startingAmmo = spiderObject.get_inventory(defines.inventory.spider_ammo).get_item_count("atomic-bomb")
                defaults.startingAmmoType = "atomic-bomb"
                else
                    defaults.startingAmmo = 0
                    defaults.startingAmmoType = nil
                end
            end
        end
        -- Find all patrol waypoints.
        local positionIndex = 0
        defaults.patrolPositions = {}
        while true do
            positionIndex = 1 + positionIndex
            local nextPosition = spiderObject.surface.get_script_position("AISpider" .. i .. "-Patrol" .. positionIndex)
            if not nextPosition then
                if global.AISpiders.GlobalDebugMessages then
                    game.print("GiantEnemySpider: " .. positionIndex - 1 .. " patrol point(s) found for spider " .. i .. ".")
                end
                break
            end
            defaults.patrolPositions[positionIndex] = nextPosition.position
        end
        -- Find restock waypoint.
        if spiderObject.surface.get_script_position("AISpider" .. i .. "-Restock") and spiderObject.surface.get_script_position("AISpider" .. i .. "-Restock").position then
            defaults.restockPoint = spiderObject.surface.get_script_position("AISpider" .. i .. "-Restock").position
        end
        -- Load Defaults and Config
        global.AISpiders.AllSpiders[i] = {}
        for k, v in pairs(defaults) do
            global.AISpiders.AllSpiders[i][k] = v
        end
        for k, v in pairs(global.AISpiders.Config) do
            global.AISpiders.AllSpiders[i][k] = v
        end
        -- Override Defaults
        if options then
            for k, v in pairs(options) do
                global.AISpiders.AllSpiders[i][k] = v
            end
        end
        if not global.AISpiders.AllSpiders[i].restockPoint then
            global.AISpiders.AllSpiders[i].restockPoint = spiderObject.position
        end

        if not global.AISpiders.AllSpiders[i].patrolPositions then
            global.AISpiders.AllSpiders[i].patrolPositions = {spiderObject.position}
        end
        return global.AISpiders.AllSpiders[i], i
    else
        return false
    end
end

local function loadSpiders()
    local i = 0
    while true do
        i = 1 + i
        local spiderObject = game.get_entity_by_tag("AISpider" .. i)
        if AISpiders_loadSpider(spiderObject) then
            AISpiders_findNextPosition(i, global.AISpiders.AllSpiders[id])
        else
            break
        end
    end
end

local function gps(position)
    return "[gps=" .. position.x .. "," .. position.y .. "]"
end

local function attemptFetch(data, name, exists)
    if data[name] ~= nil then
        if exists then
            return exists(data, name)
        end
        return data[name]
    end
    return tostring(data[name])
end

local function distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 -  y1)^2)
end

local function getPosition(data, name)
    if not data[name].valid then
        return "Destroyed"
    end 
    return gps(data[name].position)
end

local function debugSpider(id)
    local spiderData = global.AISpiders.AllSpiders[id]
    local message = {
        "----- GiantEnemySpider -----",
        "ID: " .. id,
        "Position: " .. gps(spiderData.spiderObject.position),
        "State: " .. spiderData.state,
        "Patrol Points: " .. #spiderData.patrolPositions,
        "Restock Point: " .. gps(spiderData.restockPoint),
        "Giveup Ticks: " .. spiderData.giveupCooldown,
        "Chasing: " .. attemptFetch(spiderData, "chasing", getPosition),
        "Ignore Chase: " .. tostring(spiderData.ignoreChase),
        "Escorting: " .. attemptFetch(spiderData, "escorting", getPosition),
        "Was Escorting: " .. tostring(spiderData.wasEscorting),
        "---------------------------"
    }
    for i, msg in ipairs(message) do
        game.player.print(msg)
    end
end

local function findNext_patrolling(id, spiderData)
    -- Minimize table lookups by using local variables
    local patrolPoint = spiderData.patrolPoint + 1
    local patrolPositions = spiderData.patrolPositions
    
    -- Calculate the next patrol point, wrapping around if necessary
    patrolPoint = ((patrolPoint - 1) % #patrolPositions) + 1
    
    -- Update spiderData with the new patrol point and reset chasing path
    spiderData.patrolPoint = patrolPoint
    spiderData.chasingPath = {}
    spiderData.spiderObject.autopilot_destination = patrolPositions[patrolPoint]
end

local function findNext_chasing(id, spiderData)
    local spiderObject = spiderData.spiderObject
    local spiderPosition = spiderObject.position
    local chasingPath = spiderData.chasingPath
    local chasingPathLength = #chasingPath

    if chasingPathLength > 0 then
        local lastPathPoint = chasingPath[chasingPathLength]
        local nextDistance = distance(lastPathPoint, spiderPosition)
        if nextDistance > 1 then
            table.insert(chasingPath, spiderPosition)
        end
    else
        spiderData.lastPatrolPoint = spiderPosition
        table.insert(chasingPath, spiderPosition)
    end

    local chasing = spiderData.chasing
    if chasing and chasing.valid then
        local targetDistance = distance(chasing.position, spiderPosition)
        local lastPatrolPointDistance = distance(spiderData.lastPatrolPoint, chasing.position)
        
        if targetDistance > spiderData.level / 2 then
            spiderObject.autopilot_destination = chasing.position
        end

        if lastPatrolPointDistance > spiderData.PatrolLeave then
            if not spiderData.wasEscorting then
                spiderData.state = "returning"
            end
        end
    elseif chasing then
        spiderData.chasing = nil
    end
end

local function findNext_escorting(id, spiderData)
    local chasingPath = spiderData.chasingPath
    local spiderObject = spiderData.spiderObject
    local spiderPosition = spiderObject.position
    local chasingPathLength = #chasingPath

    if chasingPathLength > 0 then
        local lastPathPoint = chasingPath[chasingPathLength]
        local nextDistance = distance(lastPathPoint, spiderPosition)
        if nextDistance > spiderData.level * 8 then
            table.insert(chasingPath, spiderPosition)
        end
    else
        spiderData.lastPatrolPoint = spiderPosition
        table.insert(chasingPath, spiderPosition)
    end

    local escorting = spiderData.escorting
    if escorting and escorting.valid then
        local targetDistance = distance(escorting.position, spiderPosition)
        if targetDistance > spiderData.level then
            spiderObject.autopilot_destination = escorting.position
        end
    elseif escorting then
        spiderData.escorting = nil
        spiderData.wasEscorting = false
    end
end

local function findNext_returning(id, spiderData)
    local chasingPath = spiderData.chasingPath
    local chasingPathLength = #chasingPath

    if global.AISpiders.GlobalDebugMessages then
        game.print("GiantEnemySpider: Spider " .. id .. " is returning to point #" .. chasingPathLength)
    end

    if chasingPathLength == 0 then
        spiderData.ignoreChase = false
        spiderData.state = "restocking"
        spiderData.patrolPoint = spiderData.patrolPoint - 1
        AISpiders_findNextPosition(id, spiderData)
    else
        spiderData.spiderObject.autopilot_destination = chasingPath[chasingPathLength]
        table.remove(chasingPath)
    end
end

local function findNext_restocking(id, spiderData)
    local restockPoint = spiderData.restockPoint
    local spiderPosition = spiderData.spiderObject.position

    local restockDistance = distance(restockPoint, spiderPosition)
    spiderData.ignoreChase = true

    if restockDistance > 6 then
        spiderData.spiderObject.autopilot_destination = restockPoint
    end
end

stateActions = {
    patrolling = findNext_patrolling,
    chasing = findNext_chasing,
    escorting = findNext_escorting,
    returning = findNext_returning,
    restocking = findNext_restocking
}

function AISpiders_findNextPosition(id, spiderData)
	if spiderData ~= nil then
        local action = stateActions[spiderData.state]
        action(id, spiderData)
    end
end

local function update(id, spiderData)
    if spiderData.state == "chasing" then
        local entityDistance = distance(spiderData.lastPatrolPoint, spiderData.spiderObject.position)
        if entityDistance > spiderData.PatrolLeave then
            if not spiderData.wasEscorting then
                spiderData.state = "chasing"
                AISpiders_findNextPosition(id, spiderData)
            end
        end
    end
    healthAmmoCheck(spiderData, id)
    -- Find closest target (player or military target)
    local closestEntity = nil
    local closestPlayer = nil
    local closestDistance = spiderData.AggroRange
    -- Make all players valid targets
    local checkEntities = game.connected_players
    local playerCount = #game.connected_players
    -- Add nearby military targets as valid
    getTargets(spiderData, id, checkEntities)
    closestEntity, closestPlayer, closestDistance = rangeCheck(spiderData, checkEntities, playerCount, closestEntity, closestPlayer, closestDistance)
    hostileCheck(spiderData, id, closestEntity, closestPlayer)
end

function healthAmmoCheck(spiderData, id)
    local spider = spiderData.spiderObject
    local inventory = spider.get_inventory(defines.inventory.spider_ammo)
    local ammoCount = spiderData.startingAmmoType and inventory.get_item_count(spiderData.startingAmmoType) or nil
    local healthRatio = spider.get_health_ratio()
    -- Determine if either health or ammo is below the threshold
    local isLowAmmo = ammoCount and ammoCount < spiderData.startingAmmo * spiderData.LowAmmo
    local isLowHealth = healthRatio < spiderData.startingHealth * spiderData.LowHealth
    if isLowAmmo or isLowHealth then
        -- Shared logic for handling low ammo or health
        handleLowResources(spiderData, id, isLowAmmo, "ammo")
        handleLowResources(spiderData, id, isLowHealth, "health")
    end
end

function handleLowResources(spiderData, id, isResourceLow, resourceType)
    if not isResourceLow then return end
    local messagePart = resourceType == "ammo" and "on ammo" or "on health"
    local nextState
    if spiderData.state == "chasing" or spiderData.state == "escorting" then
        nextState = "returning"
    elseif spiderData.state == "patrolling" then
        nextState = "restocking"
    end
    if nextState then
        spiderData.state = nextState
        spiderData.ignoreChase = true -- Assuming we want to set this true for both ammo and health checks
        if global.AISpiders.GlobalDebugMessages then
            game.print("GiantEnemySpider: Spider " .. id .. " is low " .. messagePart .. ".")
        end
        AISpiders_findNextPosition(id, spiderData)
    end
end

function getTargets(spiderData, id, checkEntities)
    local spider = spiderData.spiderObject
    local surface = spider.surface
    local position = spider.position
    local entities = surface.find_entities_filtered({
        position = position,
        radius = spiderData.AggroRange,
        is_military_target = true
    })

    for _, entity in ipairs(entities) do
        table.insert(checkEntities, entity)
    end

    if spiderData.state == "patrolling" then
        spiderData.lastPatrolPoint = position
    elseif spiderData.state == "escorting" and spiderData.escorting and spiderData.escorting.valid then
        spiderData.giveupCooldown = 0
        AISpiders_findNextPosition(id, spiderData)
    elseif spiderData.state == "escorting" and (not spiderData.escorting or not spiderData.escorting.valid) then
        handleEscortFailure(spiderData, id)
    end
end

function handleEscortFailure(spiderData, id)
    if global.AISpiders.GlobalDebugMessages then
        game.print("GiantEnemySpider: Spider " .. id .. " is no longer escorting a group.")
    end
    spiderData.state = "returning"
    spiderData.escorting = nil
    AISpiders_findNextPosition(id, spiderData)
end

function rangeCheck(spiderData, checkEntities, playerCount, closestEntity, closestPlayer, closestDistance)
    local spiderPosition = spiderData.spiderObject.position
    local spiderForce = spiderData.spiderObject.force
    local lastPatrolPoint = spiderData.lastPatrolPoint
    local spiderValid = spiderData.spiderObject and spiderData.spiderObject.valid
    local ignoreChase = spiderData.ignoreChase
    if not spiderValid or ignoreChase then
        return closestEntity, closestPlayer, closestDistance
    end

    for _, attackEntity in pairs(checkEntities) do
        -- Ignore entities without physical form and friendly entities
        if isValidTarget(attackEntity, spiderForce) then
            local entityDistance = distance(attackEntity.position, spiderPosition)

            if entityDistance < spiderData.AggroRange and entityDistance < closestDistance then
                local patrolDistance = lastPatrolPoint and distance(lastPatrolPoint, attackEntity.position) or 0
                
                if patrolDistance < spiderData.PatrolLeave or spiderData.wasEscorting then
                    -- Update closest player if within playerCount
                    if _ <= playerCount then
                        closestPlayer = attackEntity
                    end
                    closestEntity = attackEntity
                    closestDistance = entityDistance
                end
            end
        end
    end
    return closestEntity, closestPlayer, closestDistance
end

function isValidTarget(entity, spiderForce)
    return not (entity.object_name == "LuaPlayer" and not entity.character) 
           and not spiderForce.get_friend(entity.force) 
           and entity.force.name ~= spiderForce.name
end

function distance(pos1, pos2)
    return ((pos1.x - pos2.x)^2 + (pos1.y - pos2.y)^2)^0.5
end

function hostileCheck(spiderData, id, closestEntity, closestPlayer)
    if closestEntity then
        if global.AISpiders.GlobalDebugMessages then
            game.print("GiantEnemySpider: Spider " .. id .. " is now chasing a hostile entity.")
        end
        if closestPlayer then
            closestEntity = closestPlayer
        end
        if not spiderData.ignoreChase then
            spiderData.state = "chasing"
            spiderData.chasing = closestEntity
            spiderData.spiderObject.autopilot_destination = nil
            AISpiders_findNextPosition(id, spiderData)
        end
    else
        if spiderData.state == "chasing" then
            spiderData.state = "returning"
            AISpiders_findNextPosition(id, spiderData)
        elseif spiderData.escorting and spiderData.escorting.valid then
            spiderData.state = "escorting"
            AISpiders_findNextPosition(id, spiderData)
        end
    end
end

script.on_init(
    function()
        loadData()
        loadSpiders()
    end
)

script.on_configuration_changed(
    function()
        resetAllSpiders()
    end
)

function resetAllSpiders()
    global.AISpiders = {}
    global.AISpiders.spiderMap = {}
    global.AISpiders.AllSpiders = {}
    loadData()
    loadSpiders()
    for _, surface in pairs(game.surfaces) do
        local spiders = surface.find_entities_filtered({name=allSpiderNames})
        for _, spider in ipairs(spiders) do
            spider.destroy()
        end
    end
    for _, spawner in pairs(global.AISpiders.spawnerUnits) do
        spawner = 0
    end
    for _, surface in pairs(game.surfaces) do
        local spawners = surface.find_entities_filtered({name="giantenemyspider-spawner"})
        for _, spawner in ipairs(spawners) do
            global.AISpiders.nests[spawner.unit_number] = {position=spawner.position, surface=spawner.surface, force=spawner.force, spawner_id=spawner.unit_number}
            global.AISpiders.spawnerUnits[spawner.unit_number] = 0
        end
    end
    game.print({"custom.reset-message"})
end

function handle_spider_removal(id)
    local spawner_number = global.AISpiders.spiderNest[id]
    if spawner_number ~= -1 then
        global.AISpiders.spawnerUnits[spawner_number] = global.AISpiders.spawnerUnits[spawner_number] - 1
    end
    global.AISpiders.spiderNest[id] = nil
    if global.AISpiders.GlobalDebugMessages then
        game.print("GiantEnemySpider: Spider " .. id .. " has been removed.")
    end
    global.AISpiders.AllSpiders[id] = nil
end

function process_spider_state(spiderData, id)
    if spiderData.state == "restocking" and check_if_close_to_restock(spiderData, id) then
        attempt_restock(spiderData, id)
    --elseif spiderData.lastPosition then
        --evaluate_spider_movement(spiderData, id)
    end
    check_chasing_condition(spiderData)
end

function check_if_close_to_restock(spiderData, id)
    local restockDistance = distance(spiderData.restockPoint, spiderData.spiderObject.position)
    return restockDistance <= global.AISpiders.AllSpiders[id].level * 20
end

function attempt_restock(spiderData, id)
    if spiderData.AutoReplenish then
        spiderData.replenishTime = spiderData.replenishTime + 1
        if spiderData.replenishTime > spiderData.AutoReplenishTime then
            spiderData.replenishTime = 0
            if spiderData.spiderObject.get_health_ratio() < spiderData.startingHealth then
                spiderData.spiderObject.health = spiderData.spiderObject.health + global.AISpiders.AllSpiders[id].level * 5
            end
            if spiderData.startingAmmoType then
                local inventory = spiderData.spiderObject.get_inventory(defines.inventory.spider_ammo)
                if inventory.get_item_count(spiderData.startingAmmoType) < spiderData.startingAmmo then
                    inventory.insert({name=spiderData.startingAmmoType, count=1})
                end
            end
            if (spiderData.spiderObject.get_health_ratio() >= spiderData.startingHealth) and (not spiderData.startingAmmoType or (inventory.get_item_count(spiderData.startingAmmoType) >= spiderData.startingAmmo)) then
                spiderData.state = "patrolling"
                spiderData.ignoreChase = false
            end
        end
    end
end

function evaluate_spider_movement(spiderData, id)
    local current_position = spiderData.spiderObject.position
    local last_position = spiderData.lastPosition
    -- Using squared distance to check if the spider has moved significantly
    if (current_position.x - last_position.x)^2 + (current_position.y - last_position.y)^2 < 0.1 then
        spiderData.giveupCooldown = (spiderData.giveupCooldown or 0) + 1
        if spiderData.giveupCooldown > global.AISpiders.GlobalGiveupTime and spiderData.state ~= "restocking" then
            if global.AISpiders.GlobalDebugMessages then
                game.print("GiantEnemySpider: Spider " .. id .. " has given up as the target is unreachable.")
            end
            spiderData.state = "returning"
            spiderData.giveupCooldown = 0
            spiderData.ignoreChase = true
            AISpiders_findNextPosition(id, spiderData)
        end
    else
        spiderData.giveupCooldown = 0
    end
    spiderData.lastPosition = current_position
end

function check_chasing_condition(spiderData)
    if spiderData.chasing and spiderData.chasing.valid then
        local chasing_position = spiderData.chasing.position
        local spider_position = spiderData.spiderObject.position
        local targetDistance = (chasing_position.x - spider_position.x)^2 + (chasing_position.y - spider_position.y)^2
        if targetDistance < 6^2 then
            spiderData.giveupCooldown = 0
        end
    end
end

script.on_nth_tick(7, function()
    processSpidersInChunks()
end)

function processSpidersInChunks()
    local chunkSize = 10
    -- Initialize or increment the index to start processing from
    global.AISpiders.currentSpiderIndex = global.AISpiders.currentSpiderIndex or 1
    local spiders = global.AISpiders.AllSpiders
    local spiderKeys = {}
    local n = 0
    for k,v in pairs(spiders) do
        n = n + 1
        spiderKeys[n] = k
    end
    table.sort(spiderKeys)
    local count = #spiderKeys

    -- Calculate the last index for this update chunk
    local lastSpiderIndex = math.min(global.AISpiders.currentSpiderIndex + chunkSize - 1, count)
    for i = global.AISpiders.currentSpiderIndex, lastSpiderIndex do
        local id = spiderKeys[i]
        local spiderData = spiders[id]
        if spiderData.spiderObject and not spiderData.spiderObject.valid then
            handle_spider_removal(id)
        else
            process_spider_state(spiderData, id)
            update(id, spiderData)
        end
    end

    -- Update the index for the next chunk. Reset if we've reached the end.
    if lastSpiderIndex >= count then
        global.AISpiders.currentSpiderIndex = 1 -- Reset to start on the next cycle
    else
        global.AISpiders.currentSpiderIndex = lastSpiderIndex + 1
    end
end

script.on_nth_tick(18000, function() -- Every 5 minutes clean unmanaged cache, basic garbage collection
    cleanSpiderMap()
end)

function cleanSpiderMap()
    global.AISpiders.spiderMap = {}
    for id, spiderData in pairs(global.AISpiders.AllSpiders) do
        global.AISpiders.spiderMap[spiderData.spiderObject.unit_number] = id
    end
end

script.on_event(defines.events.on_spider_command_completed,
    function(event)
        if event.vehicle and event.vehicle.valid then
            local id = global.AISpiders.spiderMap[event.vehicle.unit_number]
            AISpiders_findNextPosition(id, global.AISpiders.AllSpiders[id])
        end
    end
)

script.on_event(defines.events.on_unit_added_to_group,
    function(event)
        for id, spiderData in pairs(global.AISpiders.AllSpiders) do
            if (math.random(1, 2) == 1 and event.group.valid and spiderData.spiderObject and spiderData.spiderObject.valid and distance(event.group.position, spiderData.spiderObject.position) <= 50 and not spiderData.escorting) then
                if global.AISpiders.GlobalDebugMessages then
                    game.print("GiantEnemySpider: Spider " .. id .. " is now escorting a group.")
                end
                spiderData.escorting = event.group
                spiderData.state = "escorting"
                spiderData.wasEscorting = true
            end
        end
    end
)

-- Disable friendly fire for enemy force
script.on_event(defines.events.on_entity_damaged,
    function(event)
        -- Might not work with mods or scenarios that add other forces.
        if ((event.entity.force == event.force) and (event.force.name == "enemy")) then
            -- Cancel damage by reverting damage
            event.entity.health = event.final_health + event.final_damage_amount
        end
    end
)

function despawnCheck(id, spiderData)
    if (spiderData.state == "patrolling" or spiderData.state == "idle") then -- Do not despawn when doing something actively
        local currentTick = game.tick + math.random(0, 5000) -- Random time to avoid despawing every spider at the same wave
        local birthTick = spiderData.spawn_tick
        -- Early exit if spider hasn't reached its lifespan
        if currentTick <= birthTick + global.AISpiders.despawnTime then
            return
        end

        if global.AISpiders.GlobalDebugMessages then
            game.print("GiantEnemySpider: Spider " .. id .. " is old enough to despawn")
        end

        local spiderPosition = spiderData.spiderObject.position
        local isNearPlayer = false
        for _, player in pairs(game.players) do
            if player.connected and distance(spiderPosition, player.position) < 150 then
                isNearPlayer = true
                break
            end
        end

        -- Proceed to despawn if no player is nearby
        if not isNearPlayer then
            handle_spider_removal(id)
            spiderData.spiderObject.destroy()
            if global.AISpiders.GlobalDebugMessages then
                game.print("GiantEnemySpider: Spider " .. id .. " was despawned")
            end
        end
    end
end

script.on_nth_tick(3600, function()  -- Every minute check
    for id, spiderData in pairs(global.AISpiders.AllSpiders) do
        despawnCheck(id, spiderData)
    end
end)

script.on_nth_tick(600, function()  -- Every 10 seconds
    local connectedPlayersCount = #game.connected_players
    local spiderLimitReached = #global.AISpiders.spiderNest >= global.AISpiders.spiderLimit
    if spiderLimitReached or connectedPlayersCount == 0 then
        return -- Early exit if limit reached or no players connected
    end

    local randomPlayerIndex = math.random(1, connectedPlayersCount)
    local randomPlayer = game.connected_players[randomPlayerIndex]
    -- Only proceed if the randomly selected player has a character
    if not randomPlayer.character then
        return
    end
    local playerPosition = randomPlayer.character.position

    -- Collect and shuffle nest keys
    local keys = {}
    for key in pairs(global.AISpiders.nests) do
        table.insert(keys, key)
    end
    for i = #keys, 2, -1 do
        local j = math.random(i)
        keys[i], keys[j] = keys[j], keys[i]
    end
    
    -- Attempt spawning
    for _, key in ipairs(keys) do
        if #global.AISpiders.spiderNest >= global.AISpiders.spiderLimit then break end
        local data = global.AISpiders.nests[key]
        local spawner_id = data.spawner_id
        local spawnerUnits = global.AISpiders.spawnerUnits[spawner_id] or 0
        if spawnerUnits < 3 then
            local spawnPosition = data.position
            if distance(playerPosition, spawnPosition) < global.AISpiders.spawnDistance then -- Limit spawns to a radius of tiles from players
                local surface = data.surface
                local force = data.force
                local level = getLevelBasedOnEvolution(force.evolution_factor)
                global.AISpiders.spawnerUnits[spawner_id] = global.AISpiders.spawnerUnits[spawner_id] + 1
                local spider_entity = surface.create_entity{
                    name="giantenemyspider-spider-" .. level,
                    position=spawnPosition,
                    force=force
                }
                loadGrid(spider_entity, level)
                local options = {}
                options["patrolPositions"] = generatePositions(spider_entity)
                options["restockPoint"] = spawnPosition
                options["spawner_number"] = spawner_id
                options["level"] = level
                spiderData, id = AISpiders_loadSpider(spider_entity, options)
                global.AISpiders.spiderMap[spider_entity.unit_number] = id
                global.AISpiders.spiderNest[id] = spawner_id
                AISpiders_findNextPosition(id, spiderData)
            end
        end
    end
end)

function getLevelBasedOnEvolution(evolutionFactor)
    local eligibleSpiders = {}
    local totalWeight = 0
    local weightedSpiders = {}
    
    for _, entry in ipairs(global.AISpiders.spawnTable) do
        local level = entry[1]
        local factors = entry[2]
        local start_factor = factors[1][1]
        local end_factor = factors[2][1]

        if evolutionFactor >= start_factor and evolutionFactor <= end_factor then
            -- Calculate weight based on evolutionFactor's proximity to the range's midpoint
            local midpoint = (start_factor + end_factor) / 2
            local distance = math.abs(midpoint - evolutionFactor)
            local maxDistance = (end_factor - start_factor) / 2
            local weight = 1 - (distance / maxDistance) -- Inversely proportional to distance from midpoint
            
            table.insert(weightedSpiders, {level = level, weight = weight})
            totalWeight = totalWeight + weight
        end
    end

    if #weightedSpiders == 0 then
        return nil -- No eligible spiders found
    end

    -- Select a spider based on weights
    local target = math.random() * totalWeight
    local runningTotal = 0
    for _, spider in ipairs(weightedSpiders) do
        runningTotal = runningTotal + spider.weight
        if target <= runningTotal then
            return spider.level
        end
    end
end

-- Event handler for when a mod setting is changed
script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    global.AISpiders.despawnTime = settings.global["giantenemyspider-despawn"].value
    global.AISpiders.spawnDistance = settings.global["giantenemyspider-spawn-distance"].value
    if event.setting == "giantenemyspider-max-spiders" then
        global.AISpiders.spiderLimit = settings.global["giantenemyspider-max-spiders"].value
        for id, spiderData in pairs(global.AISpiders.AllSpiders) do
            despawnCheck(id, spiderData)
        end
    end
end)

function noWaterInPath(surface, from, to)
    local x0, y0 = from[1], from[2]
    local x1, y1 = to[1], to[2]
    local dx = x1 - x0
    local dy = y1 - y0
    local n = math.max(math.abs(dx), math.abs(dy))
    local xStep = dx / n
    local yStep = dy / n

    local function isNotWater(tile)
        if tile.valid then
            local waterTiles = { "water", "deepwater", "water-green", "deepwater-green", "water-shallow", "water-mud" }
            for _, waterTileName in ipairs(waterTiles) do
                if tile.name == waterTileName then
                    return false
                end
            end
            return true
        else
            return false
        end
    end

    for step = 0, n do
        local x = x0 + xStep * step
        local y = y0 + yStep * step
        if x ~= x or y ~= y then return false end -- nan check
        local tile = surface.get_tile(math.floor(x + 0.5), math.floor(y + 0.5))
        if not tile.valid or not isNotWater(tile) then
            return false
        end
    end

    return true
end

local function distance(p1, p2)
    local dx = p1[1] - p2[1]
    local dy = p1[2] - p2[2]
    return math.sqrt(dx * dx + dy * dy)
end

local function pruneClosePoints(points, minDistance)
    local i = 1
    while i <= #points do
        local pointToRemove = false
        for j = i + 1, #points do
            if distance(points[i], points[j]) < minDistance then
                pointToRemove = true
                break -- A close point found, prepare to remove the current point i
            end
        end
        if pointToRemove then
            table.remove(points, i)
        else
            i = i + 1 -- Only increment i if no point was removed
        end
    end
end

-- Create a ring of positions for the spider to patrol
function generatePositions(spider)
    local surface = spider.surface
    local points = {}
    local x, y, r, p, s = spider.position.x, spider.position.y, 50, 8, 2
    local lastValidPoint = {x, y}
    for i = 1, p do
        local foundLand = false
        local attempts = 0
        local ptx, pty
        while not foundLand and attempts < 5 do
            local angle = 360 / p * i * math.pi / 180
            ptx, pty = x + (r + math.random(-1 * s, s)) * math.cos(angle), y + (r + math.random(-1 * s, s)) * math.sin(angle)
            if noWaterInPath(surface, lastValidPoint, {ptx, pty}) then
                foundLand = true
            else
                r = r - 8
            end
            attempts = attempts + 1
        end
        if foundLand then
            points[#points + 1] = {ptx, pty}
            lastValidPoint = {ptx, pty} -- Update the last valid point for the next path check
        end
    end

    --pruneClosePoints(points, 5)

    if #points == 1 then -- Do not provide list of one point, because it may impact performance, perhaps spider will complete patrol every tick
        return {}
    end

    if (settings.global["giantenemyspider-debug-path"].value) then
        -- Draw lines between consecutive points to visualize the patrol path
        for i = 1, #points do
            local point1 = points[i]
            local point2 = points[i % #points + 1]  -- Wrap around to connect the last point to the first
            
            -- Convert the point format from {x, y} to the expected format by rendering.draw_line
            local from = {x = point1[1], y = point1[2]}
            local to = {x = point2[1], y = point2[2]}
            
            drawLineBetweenPoints(from, to, spider.surface)
        end
    end

    return points
end

function drawLineBetweenPoints(point1, point2, surface) -- Debug visualization
    rendering.draw_line{
        color = {r = 1, g = 0, b = 0}, -- Red line
        width = 2,
        from = point1,
        to = point2,
        surface = surface,
        draw_on_ground = true
    }
end

function loadGrid(entity, templateID)
    grid = entity.grid
    if not (templateID > #gridData) then
        local gridToLoad = gridData[templateID]
        for slot, item in pairs(gridToLoad) do
            if slot == "ammo" then
                entity.get_inventory(defines.inventory.spider_ammo).insert(item)
            else
                if slot == "health" then
                    entity.health = item * global.AISpiders.healthScale
                else
                    grid.put({name=item, position=slot})
                end
            end
        end
    end
    return grid
end

script.on_event(defines.events.on_player_driving_changed_state, function(event)
    local player = game.players[event.player_index]
    if player.vehicle then
        -- Player has entered a vehicle, store this vehicle
        global.AISpiders.lastVehicle[player.index] = player.vehicle
    else
        -- Player has exited a vehicle, retrieve and use the stored vehicle
        local exited_vehicle = global.AISpiders.lastVehicle[player.index]
        if exited_vehicle then
            local id = global.AISpiders.spiderMap[exited_vehicle.unit_number]
            if id ~= nil then -- Is spider? Otherwise is spidertron
                AISpiders_findNextPosition(id, global.AISpiders.AllSpiders[id]) -- Let spider resume activities
            end
        end
        global.AISpiders.lastVehicle[player.index] = nil
    end
end)

gridData = {
    {
        ["health"] = 10,
        [{0, 0}] = "giantenemyspider-fangs-1",
        [{6, 2}] = "giantenemyspider-heart-1",
    },
    {
        ["health"] = 50,
        [{0, 0}] = "giantenemyspider-fangs-1",
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
        [{0, 2}] = "giantenemyspider-armor-1",
        [{0, 4}] = "giantenemyspider-armor-1",
        [{2, 0}] = "giantenemyspider-web-1",
        [{3, 0}] = "battery-equipment",
        [{3, 2}] = "battery-equipment",
        [{6, 2}] = "giantenemyspider-heart-1",
    },
    {
        ["health"] = 500,
        [{0, 0}] = "giantenemyspider-armor-1",
        [{0, 2}] = "giantenemyspider-fangs-2",
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
        [{0, 2}] = "giantenemyspider-fangs-2",
        [{0, 4}] = "giantenemyspider-armor-1",
        [{2, 0}] = "giantenemyspider-web-1",
        [{2, 2}] = "giantenemyspider-web-1",
        [{2, 4}] = "giantenemyspider-web-1",
        [{4, 0}] = "battery-equipment",
        [{4, 1}] = "battery-equipment",
        [{4, 2}] = "battery-equipment",
        [{4, 3}] = "battery-equipment",
        [{4, 4}] = "giantenemyspider-armor-1",
        [{6, 0}] = "giantenemyspider-leg-upgrade-1",
        [{6, 2}] = "giantenemyspider-heart-1",
        [{8, 0}] = "giantenemyspider-leg-upgrade-1"
    },
    {
        ["health"] = 2500,
        [{0, 0}] = "giantenemyspider-armor-1",
        [{0, 2}] = "giantenemyspider-armor-1",
        [{0, 4}] = "giantenemyspider-armor-1",
        [{2, 0}] = "giantenemyspider-fangs-2",
        [{2, 2}] = "giantenemyspider-poison-1",
        [{2, 4}] = "giantenemyspider-fangs-2",
        [{4, 0}] = "giantenemyspider-web-1",
        [{4, 2}] = "giantenemyspider-web-1",
        [{4, 4}] = "giantenemyspider-web-1",
        [{6, 0}] = "giantenemyspider-leg-upgrade-1",
        [{6, 2}] = "giantenemyspider-heart-1",
        [{8, 0}] = "giantenemyspider-leg-upgrade-1"
    },
    {
        ["health"] = 5000,
        [{0, 0}] = "giantenemyspider-fangs-2",
        [{0, 2}] = "giantenemyspider-fangs-2",
        [{0, 4}] = "giantenemyspider-fangs-2",
        [{2, 0}] = "giantenemyspider-armor-1",
        [{2, 2}] = "giantenemyspider-poison-1",
        [{2, 4}] = "giantenemyspider-armor-1",
        [{4, 0}] = "giantenemyspider-web-1",
        [{4, 2}] = "giantenemyspider-web-1",
        [{4, 4}] = "giantenemyspider-web-1",
        [{6, 0}] = "giantenemyspider-leg-upgrade-1",
        [{6, 2}] = "giantenemyspider-heart-1",
        [{8, 0}] = "giantenemyspider-leg-upgrade-1"
    },
    {
        ["health"] = 10000,
        --["ammo"] = {name="explosive-rocket", count=800},
        [{0, 0}] = "giantenemyspider-armor-1",
        [{0, 2}] = "giantenemyspider-fangs-2",
        [{0, 4}] = "giantenemyspider-armor-1",
        [{2, 0}] = "giantenemyspider-poison-1",
        [{2, 2}] = "giantenemyspider-poison-1",
        [{2, 4}] = "giantenemyspider-poison-1",
        [{4, 0}] = "giantenemyspider-web-1",
        [{4, 2}] = "giantenemyspider-web-1",
        [{4, 4}] = "giantenemyspider-web-1",
        [{6, 0}] = "giantenemyspider-leg-upgrade-1",
        [{6, 2}] = "giantenemyspider-heart-1",
        [{8, 0}] = "giantenemyspider-leg-upgrade-1"
    }
}