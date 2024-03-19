
-- How to use this script:
-- Create a Spidertron and give it the tag "AISpider" followed by the spider ID (Must be sequential), example: "AISpider1".
-- For example, you could have "AISpider1", "AISpider2", "AISpider3", "AISpider4". The sequential number stays the same.
-- If it is not following a sequential order, like 1, 2, 3, 4, ect. then it will ignore any others after it. (Stops if ID is invalid/doesn't exist)
-- There are other points that can be used which will be listed belowed, but the format will always be "AISpider<ID>-<AttributeName><AttributeValue>".
-- The AttributeValue will only be needed if specified by the Attribute below.
-- Attributes: "Patrol" (requires ID) and "Restock".
-- Note: The spider will always restock to the amount it started at.

currentVersion = "0.1.0"

local function loadData()
    -- Initialize global data. (NOT PART OF CONFIG)
    global.AISpiders = {}
    global.AISpiders.AllSpiders = {} -- Used to keep track of all AI Spiders' data.
    global.AISpiders.currentUpdateTick = 0
    AISpiders_reloadSpiders()
end

function AISpiders_reloadSpiders()
    if (not global.AISpiders) then
        loadData()
        return
    end
    global.AISpiders.version = currentVersion
    global.AISpiders.Config = {}
    -- You can change the configuration settings below. The configuration with "Global" is global for all AISpiders, the others are the defaults per AISpider.
    global.AISpiders.GlobalDebugMessages = true -- Shows debug messages if true. Recommended to leave off.
    global.AISpiders.GlobalUpdateCooldown = 60 -- How often the spiders will update their states in ticks. (60 ticks = 1 second)
    global.AISpiders.GlobalGiveupTime = 300 -- How long the spider will wait without moving before giving up and returning. Used if the spider gets stuck. (60 ticks = 1 second)
    global.AISpiders.Config.PatrolLeave = 80 -- How far in tiles the spider is allowed to leave it's last patrol location. This is used when it is chasing something.
    global.AISpiders.Config.AggroRange = 45 -- How far in tiles the spider will aggro onto an enemy building or player and move towards it.
    global.AISpiders.Config.LowHealth = 0.60 -- How low the health has to be to be considered low. (Scale of 0-1)
    global.AISpiders.Config.LowAmmo = 0.40 -- How low the ammo has to be to be considered low. (Scale of 0-1 as fraction of max ammo)
    global.AISpiders.Config.AutoReplenish = true -- If false, the spider will wait until it meets the starting values of ammo and health. If true, the ammo will magically appear.
    global.AISpiders.Config.AutoReplenishTime = 30 -- How often the spider will heal/regain ammo if AutoReplenish is enabled in ticks. (60 ticks = 1 second)
    global.AISpiders.Config.FollowGroups = true -- If the spider should follow attack groups, attempting to destroy more player structures.

    if (true) then -- Set to false if using this in a scenario as this will reset all custom config on a scenario.
        for id, spiderData in pairs(global.AISpiders.AllSpiders) do
            for k, v in pairs(global.AISpiders.Config) do
                global.AISpiders.AllSpiders[id][k] = v
            end
        end
    end
    game.print("AISpiders: Reloaded all spider config.")
end

function AISpiders_loadSpider(spiderObject, options)
    if spiderObject and spiderObject.valid then
        if not global.AISpiders then
            loadData()
        end
        local i = #global.AISpiders.AllSpiders + 1
        if global.AISpiders.GlobalDebugMessages then
            game.print("AISpiders Debug: Adding spider ID " .. i)
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
                    game.print("AISpiders Debug: " .. positionIndex - 1 .. " patrol point(s) found for spider " .. i .. ".")
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
            AISpiders_findNextPosition(i)
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
        "----- AISpiders Debug -----",
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

function AISpiders_debugSpider(args)
    if not game.player.admin then
        return
    end
    game.player.print("Looking for closest enemy spider to debug...")
    local entity = game.player.surface.find_entities_filtered({position=game.player.position, radius=30, type="spider-vehicle"})[1]
    for id, spiderData in ipairs(global.AISpiders.AllSpiders) do
        if spiderData.spiderObject == entity then
            debugSpider(id)
            return
        end
    end
end
commands.add_command("aispiders_debug", nil, AISpiders_debugSpider)

local function findNext_patrolling(id)
    global.AISpiders.AllSpiders[id].patrolPoint = 1 + global.AISpiders.AllSpiders[id].patrolPoint
    if global.AISpiders.AllSpiders[id].patrolPoint > #global.AISpiders.AllSpiders[id].patrolPositions then
        global.AISpiders.AllSpiders[id].patrolPoint = 1
    end
    global.AISpiders.AllSpiders[id].chasingPath = {}
    global.AISpiders.AllSpiders[id].spiderObject.autopilot_destination = global.AISpiders.AllSpiders[id].patrolPositions[global.AISpiders.AllSpiders[id].patrolPoint]
end

local function findNext_chasing(id)
    if #global.AISpiders.AllSpiders[id].chasingPath > 0 then
        local nextDistance = distance(global.AISpiders.AllSpiders[id].chasingPath[#global.AISpiders.AllSpiders[id].chasingPath].x, global.AISpiders.AllSpiders[id].chasingPath[#global.AISpiders.AllSpiders[id].chasingPath].y, global.AISpiders.AllSpiders[id].spiderObject.position.x, global.AISpiders.AllSpiders[id].spiderObject.position.y)
        if nextDistance > 5 then
            table.insert(global.AISpiders.AllSpiders[id].chasingPath, global.AISpiders.AllSpiders[id].spiderObject.position)
        end
    else
        global.AISpiders.AllSpiders[id].lastPatrolPoint = global.AISpiders.AllSpiders[id].spiderObject.position
        table.insert(global.AISpiders.AllSpiders[id].chasingPath, global.AISpiders.AllSpiders[id].spiderObject.position)
    end
    if global.AISpiders.AllSpiders[id].chasing and global.AISpiders.AllSpiders[id].chasing.valid then
        local targetDistance = distance(global.AISpiders.AllSpiders[id].chasing.position.x, global.AISpiders.AllSpiders[id].chasing.position.y, global.AISpiders.AllSpiders[id].spiderObject.position.x, global.AISpiders.AllSpiders[id].spiderObject.position.y)
        local entityDistance = distance(global.AISpiders.AllSpiders[id].lastPatrolPoint.x, global.AISpiders.AllSpiders[id].lastPatrolPoint.y, global.AISpiders.AllSpiders[id].chasing.position.x, global.AISpiders.AllSpiders[id].chasing.position.y)
        -- Too far from target, move closer into desired range
        if targetDistance > 6 then
            global.AISpiders.AllSpiders[id].spiderObject.autopilot_destination = global.AISpiders.AllSpiders[id].chasing.position
        end
        -- Leave if too far from last patrol point
        if entityDistance > global.AISpiders.AllSpiders[id].PatrolLeave then
            -- Check if not escorting, that way it stays and attacks with the group.
            if not global.AISpiders.AllSpiders[id].wasEscorting then
                global.AISpiders.AllSpiders[id].state = "returning"
            end
        end
    end
    if global.AISpiders.AllSpiders[id].chasing and not global.AISpiders.AllSpiders[id].chasing.valid then
        global.AISpiders.AllSpiders[id].chasing = nil
    end
end

local function findNext_escorting(id)
    if #global.AISpiders.AllSpiders[id].chasingPath > 0 then
        local nextDistance = distance(global.AISpiders.AllSpiders[id].chasingPath[#global.AISpiders.AllSpiders[id].chasingPath].x, global.AISpiders.AllSpiders[id].chasingPath[#global.AISpiders.AllSpiders[id].chasingPath].y, global.AISpiders.AllSpiders[id].spiderObject.position.x, global.AISpiders.AllSpiders[id].spiderObject.position.y)
        if nextDistance > 5 then
            table.insert(global.AISpiders.AllSpiders[id].chasingPath, global.AISpiders.AllSpiders[id].spiderObject.position)
        end
    else
        global.AISpiders.AllSpiders[id].lastPatrolPoint = global.AISpiders.AllSpiders[id].spiderObject.position
        table.insert(global.AISpiders.AllSpiders[id].chasingPath, global.AISpiders.AllSpiders[id].spiderObject.position)
    end
    if global.AISpiders.AllSpiders[id].escorting and global.AISpiders.AllSpiders[id].escorting.valid then
        local targetDistance = distance(global.AISpiders.AllSpiders[id].escorting.position.x, global.AISpiders.AllSpiders[id].escorting.position.y, global.AISpiders.AllSpiders[id].spiderObject.position.x, global.AISpiders.AllSpiders[id].spiderObject.position.y)
        local entityDistance = distance(global.AISpiders.AllSpiders[id].lastPatrolPoint.x, global.AISpiders.AllSpiders[id].lastPatrolPoint.y, global.AISpiders.AllSpiders[id].escorting.position.x, global.AISpiders.AllSpiders[id].escorting.position.y)
        -- Too far from target, move closer into desired range
        if targetDistance > 6 then
            global.AISpiders.AllSpiders[id].spiderObject.autopilot_destination = global.AISpiders.AllSpiders[id].escorting.position
        end
    end
    if global.AISpiders.AllSpiders[id].escorting and not global.AISpiders.AllSpiders[id].escorting.valid then
        global.AISpiders.AllSpiders[id].escorting = nil
        global.AISpiders.AllSpiders[id].wasEscorting = false
    end
end

local function findNext_returning(id)
    if global.AISpiders.GlobalDebugMessages then
        game.print("AISpiders Debug: Spider " .. id .. " is returning to point #" .. #global.AISpiders.AllSpiders[id].chasingPath)
    end
    if #global.AISpiders.AllSpiders[id].chasingPath == 0 then
        global.AISpiders.AllSpiders[id].ignoreChase = false
        global.AISpiders.AllSpiders[id].state = "patrolling"
        global.AISpiders.AllSpiders[id].patrolPoint = global.AISpiders.AllSpiders[id].patrolPoint - 1
        AISpiders_findNextPosition(id)
    else
        global.AISpiders.AllSpiders[id].spiderObject.autopilot_destination = global.AISpiders.AllSpiders[id].chasingPath[#global.AISpiders.AllSpiders[id].chasingPath]
        table.remove(global.AISpiders.AllSpiders[id].chasingPath, #global.AISpiders.AllSpiders[id].chasingPath)
    end
end

local function findNext_restocking(id)
    local restockDistance = distance(global.AISpiders.AllSpiders[id].restockPoint.x, global.AISpiders.AllSpiders[id].restockPoint.y, global.AISpiders.AllSpiders[id].spiderObject.position.x, global.AISpiders.AllSpiders[id].spiderObject.position.y)
    global.AISpiders.AllSpiders[id].ignoreChase = true
    if restockDistance > 6 then
        global.AISpiders.AllSpiders[id].spiderObject.autopilot_destination = global.AISpiders.AllSpiders[id].restockPoint
    end
end

function AISpiders_findNextPosition(id)
    if global.AISpiders.AllSpiders[id].spiderObject and global.AISpiders.AllSpiders[id].spiderObject.valid then
        if global.AISpiders.AllSpiders[id].state == "patrolling" then
            findNext_patrolling(id)
        elseif global.AISpiders.AllSpiders[id].state == "chasing" then
            findNext_chasing(id)
        elseif global.AISpiders.AllSpiders[id].state == "escorting" then
            findNext_escorting(id)
        elseif global.AISpiders.AllSpiders[id].state == "returning" then
            findNext_returning(id)
        elseif global.AISpiders.AllSpiders[id].state == "restocking" then
            findNext_restocking(id)
        end
    end
end

local function update(id, spiderData)
    if spiderData.state == "chasing" then
        local entityDistance = distance(spiderData.lastPatrolPoint.x, spiderData.lastPatrolPoint.y, spiderData.spiderObject.position.x, spiderData.spiderObject.position.y)
        if entityDistance > spiderData.PatrolLeave then
            if not spiderData.wasEscorting then
                spiderData.state = "returning"
                AISpiders_findNextPosition(id)
            end
        end
    end
    -- Check if ammo is low
    if spiderData.startingAmmoType and spiderData.spiderObject.get_inventory(defines.inventory.spider_ammo).get_item_count(spiderData.startingAmmoType) < spiderData.startingAmmo * spiderData.LowAmmo then
        if spiderData.state == "chasing" or spiderData.state == "escorting" then
            spiderData.state = "returning"
            spiderData.ignoreChase = true
            if global.AISpiders.GlobalDebugMessages then
                game.print("AISpiders Debug: Spider " .. id .. " is low on ammo, forcing it to return.")
            end
            AISpiders_findNextPosition(id)
        else
            if spiderData.state == "patrolling" then
                spiderData.state = "restocking"
                if global.AISpiders.GlobalDebugMessages then
                    game.print("AISpiders Debug: Spider " .. id .. " is low on ammo, sending to restock point.")
                end
                AISpiders_findNextPosition(id)
            end
        end
    end
    -- Check if health is low
    if spiderData.spiderObject.get_health_ratio() < spiderData.startingHealth * spiderData.LowHealth then
        if spiderData.state == "chasing" or spiderData.state == "escorting" then
            spiderData.state = "returning"
            spiderData.ignoreChase = true
            if global.AISpiders.GlobalDebugMessages then
                game.print("AISpiders Debug: Spider " .. id .. " is low on health, forcing it to return.")
            end
            AISpiders_findNextPosition(id)
        else
            if spiderData.state == "patrolling" then
                spiderData.state = "restocking"
                if global.AISpiders.GlobalDebugMessages then
                    game.print("AISpiders Debug: Spider " .. id .. " is low on health, sending to restock point.")
                end
                AISpiders_findNextPosition(id)
            end
        end
    end
    -- Find closest target (player or military target)
    local closestEntity = nil
    local closestPlayer = nil
    local closestDistance = spiderData.AggroRange + 99999
    -- Make all players valid targets
    local checkEntities = game.connected_players
    local playerCount = #game.connected_players
    -- Add nearby military targets as valid
    for i, entity in pairs(spiderData.spiderObject.surface.find_entities_filtered({position=spiderData.spiderObject.position,radius=spiderData.AggroRange,is_military_target=true})) do
        table.insert(checkEntities, entity)
    end
    if spiderData.state == "patrolling" then
        spiderData.lastPatrolPoint = spiderData.spiderObject.position
    elseif spiderData.state == "escorting" then
        if spiderData.escorting and spiderData.escorting.valid then
            spiderData.giveupCooldown = 0
            AISpiders_findNextPosition(id)
        end
    end
    if spiderData.escorting and not spiderData.escorting.valid then
        if global.AISpiders.GlobalDebugMessages then
            game.print("AISpiders Debug: Spider " .. id .. " is no longer escorting a group.")
        end
        spiderData.state = "returning"
        spiderData.escorting = null
        AISpiders_findNextPosition(id)
    end
    -- Check targets to see if they are in range
    for i, attackEntity in pairs(checkEntities) do
        -- Ignore dead players / players with no physical character
        if not (attackEntity.object_name == "LuaPlayer" and not attackEntity.character) then
            local entityDistance = distance(attackEntity.position.x, attackEntity.position.y, spiderData.spiderObject.position.x, spiderData.spiderObject.position.y)
            if spiderData.spiderObject and spiderData.spiderObject.valid and spiderData.lastPatrolPoint then
                local returnDistance = distance(spiderData.lastPatrolPoint.x, spiderData.lastPatrolPoint.y, attackEntity.position.x, attackEntity.position.y)
            end
            local patrolDistance = 0
            if spiderData.spiderObject and spiderData.spiderObject.valid and spiderData.lastPatrolPoint then
                patrolDistance = distance(spiderData.lastPatrolPoint.x, spiderData.lastPatrolPoint.y, attackEntity.position.x, attackEntity.position.y)
            end
            if (patrolDistance < spiderData.PatrolLeave or spiderData.wasEscorting) and entityDistance < spiderData.AggroRange and entityDistance < closestDistance and not spiderData.spiderObject.force.get_friend(attackEntity.force) and not (attackEntity.force.name == spiderData.spiderObject.force.name) and not spiderData.ignoreChase then
                if i <= playerCount then
                    closestPlayer = attackEntity
                end
                closestEntity = attackEntity
                closestDistance = entityDistance
            end
        end
    end
    if closestEntity then
        if global.AISpiders.GlobalDebugMessages then
            game.print("AISpiders Debug: Spider " .. id .. " is now chasing a hostile entity.")
        end
        if closestPlayer then
            closestEntity = closestPlayer
        end
        if not spiderData.ignoreChase then
            spiderData.state = "chasing"
            spiderData.chasing = closestEntity
            spiderData.spiderObject.autopilot_destination = nil
            AISpiders_findNextPosition(id)
        end
    else
        if spiderData.state == "chasing" then
            spiderData.state = "returning"
            AISpiders_findNextPosition(id)
        elseif spiderData.escorting and spiderData.escorting.valid then
            spiderData.state = "escorting"
            AISpiders_findNextPosition(id)
        end
    end
end

script.on_init(
    function()
        -- Same code on tick for a janky update if the map isn't new.
        -- Not loaded yet, initialize default data.
        loadData()
        loadSpiders()

    end
)

script.on_event(defines.events.on_tick,
    function(tick)
        if (not global.AISpiders) then -- Janky update for if the mod is a different version.
            -- Not loaded yet, initialize default data.
            loadData()
            loadSpiders()
        elseif (global.AISpiders.version ~= currentVersion) then
            AISpiders_reloadSpiders()
        end
        for id, spiderData in pairs(global.AISpiders.AllSpiders) do
            if spiderData.spiderObject and spiderData.spiderObject.valid == false then
                if global.AISpiders.GlobalDebugMessages then
                    game.print("AISpiders Debug: Spider " .. id .. " has been removed.")
                end
                table.remove(global.AISpiders.AllSpiders, id)
            else
                if spiderData.state == "restocking" then
                    local restockDistance = distance(global.AISpiders.AllSpiders[id].restockPoint.x, global.AISpiders.AllSpiders[id].restockPoint.y, global.AISpiders.AllSpiders[id].spiderObject.position.x, global.AISpiders.AllSpiders[id].spiderObject.position.y)
                    if restockDistance <= 8 then
                        if spiderData.AutoReplenish then
                            spiderData.replenishTime = spiderData.replenishTime + 1
                            if spiderData.replenishTime > spiderData.AutoReplenishTime then
                                spiderData.replenishTime = 0
                                if spiderData.spiderObject.get_health_ratio() < spiderData.startingHealth then
                                    spiderData.spiderObject.health = spiderData.spiderObject.health + 0.1
                                end
                                if spiderData.startingAmmoType and spiderData.spiderObject.get_inventory(defines.inventory.spider_ammo).get_item_count(spiderData.startingAmmoType) < spiderData.startingAmmo then
                                    spiderData.spiderObject.get_inventory(defines.inventory.spider_ammo).insert({name=spiderData.startingAmmoType,count=1})
                                end
                                if (spiderData.spiderObject.get_health_ratio() >= spiderData.startingHealth) and (not spiderData.startingAmmoType or (spiderData.startingAmmoType and spiderData.spiderObject.get_inventory(defines.inventory.spider_ammo).get_item_count(spiderData.startingAmmoType) >= spiderData.startingAmmo)) then
                                    spiderData.state = "patrolling"
                                    global.AISpiders.AllSpiders[id].ignoreChase = false
                                end
                            end
                        else
                            if spiderData.startingAmmoType and spiderData.spiderObject.get_inventory(defines.inventory.spider_ammo).get_item_count(spiderData.startingAmmoType) < spiderData.startingAmmo then
                                spiderData.spiderObject.set_vehicle_logistic_slot(1, {name=spiderData.startingAmmoType, min=spiderData.startingAmmo,max=spiderData.startingAmmo})
                            end
                            if (spiderData.spiderObject.get_health_ratio() >= spiderData.startingHealth) and (not spiderData.startingAmmoType or (spiderData.startingAmmoType and spiderData.spiderObject.get_inventory(defines.inventory.spider_ammo).get_item_count(spiderData.startingAmmoType) >= spiderData.startingAmmo)) then
                                spiderData.state = "patrolling"
                                global.AISpiders.AllSpiders[id].ignoreChase = false
                            end
                        end
                    end
                end
                if spiderData.lastPosition and distance(spiderData.lastPosition.x, spiderData.lastPosition.y, spiderData.spiderObject.position.x, spiderData.spiderObject.position.y) < 0.01 then
                    if spiderData.giveupCooldown > global.AISpiders.GlobalGiveupTime and not (spiderData.state == "restocking") then
                        if global.AISpiders.GlobalDebugMessages then
                            game.print("AISpiders Debug: Spider " .. id .. " has given up as the target is unreachable.")
                        end
                        spiderData.state = "returning"
                        spiderData.giveupCooldown = 0
                        spiderData.ignoreChase = true
                        AISpiders_findNextPosition(id)
                    end
                    spiderData.giveupCooldown = spiderData.giveupCooldown + 1
                else
                    spiderData.giveupCooldown = 0
                end
                if spiderData.chasing and spiderData.chasing.valid then
                    local targetDistance = distance(spiderData.chasing.position.x, spiderData.chasing.position.y, spiderData.spiderObject.position.x, spiderData.spiderObject.position.y)
                    if targetDistance < 6 then
                        spiderData.giveupCooldown = 0
                    end
                end
                spiderData.lastPosition = spiderData.spiderObject.position
            end
        end
        global.AISpiders.currentUpdateTick = global.AISpiders.currentUpdateTick + 1
        if global.AISpiders.currentUpdateTick > global.AISpiders.GlobalUpdateCooldown then
            global.AISpiders.currentUpdateTick = 0
            for id, spiderData in pairs(global.AISpiders.AllSpiders) do
                update(id, spiderData)
            end
        end
    end
)

script.on_event(defines.events.on_spider_command_completed,
	function(event)
        if event.vehicle and event.vehicle.valid then
            for id, spiderData in pairs(global.AISpiders.AllSpiders) do
                if spiderData.spiderObject and spiderData.spiderObject.valid and spiderData.spiderObject == event.vehicle then
                    AISpiders_findNextPosition(id)
                    break
                end
            end
        end
    end
)

script.on_event(defines.events.on_unit_added_to_group,
    function(event)
        for id, spiderData in pairs(global.AISpiders.AllSpiders) do
            if (event.group.valid and spiderData.spiderObject and spiderData.spiderObject.valid and distance(event.group.position.x, event.group.position.y, spiderData.spiderObject.position.x, spiderData.spiderObject.position.y) <= 30 and math.random(1, 10) == 1 and not spiderData.escorting) then
                if global.AISpiders.GlobalDebugMessages then
                    game.print("AISpiders Debug: Spider " .. id .. " is now escorting a group.")
                end
                spiderData.escorting = event.group
                spiderData.state = "escorting"
                spiderData.wasEscorting = true
            end
        end
    end
)

-- Cancel any explosive rocket damage.
script.on_event(defines.events.on_entity_damaged,
    function(event)
        -- Might not work with mods or scenarios that add other forces.
        if ((event.entity.force == event.force) and (event.force.name == "enemy")) then
            -- Cancel damage by reverting damage
            event.entity.health = event.final_health + event.final_damage_amount
        end
    end
)
