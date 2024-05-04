function build_legs(scale, leg_scale, leg_scale_variant)
    scale = 0.8 * scale
    leg_scale = 0.8 * leg_scale
    return {
        { -- 1
            leg = "giantenemyspider-spider-leg-1-" .. leg_scale_variant,
            mount_position = util.by_pixel(15  * scale, -22 * scale),--{0.5, -0.75},
            ground_position = {2.25  * scale, -2.5  * leg_scale},
            blocking_legs = {2},
            leg_hit_the_ground_trigger = legTrigger(scale),
            collision_mask = {"object-layer", "water-tile", "rail-layer", "not-colliding-with-itself" }
        },
        { -- 2
            leg = "giantenemyspider-spider-leg-2-" .. leg_scale_variant,
            mount_position = util.by_pixel(23  * scale, -10  * scale),--{0.75, -0.25},
            ground_position = {3  * scale, -1  * leg_scale},
            blocking_legs = {1, 3},
            leg_hit_the_ground_trigger = legTrigger(scale),
            collision_mask = {"object-layer", "water-tile", "rail-layer", "not-colliding-with-itself" }
        },
        { -- 3
            leg = "giantenemyspider-spider-leg-3-" .. leg_scale_variant,
            mount_position = util.by_pixel(25  * scale, 4  * scale),--{0.75, 0.25},
            ground_position = {3  * scale, 1  * leg_scale},
            blocking_legs = {2, 4},
            leg_hit_the_ground_trigger = legTrigger(scale),
            collision_mask = {"object-layer", "water-tile", "rail-layer", "not-colliding-with-itself" }
        },
        { -- 4
            leg = "giantenemyspider-spider-leg-4-" .. leg_scale_variant,
            mount_position = util.by_pixel(15  * scale, 17  * scale),--{0.5, 0.75},
            ground_position = {2.25  * scale, 2.5  * leg_scale},
            blocking_legs = {3},
            leg_hit_the_ground_trigger = legTrigger(scale),
            collision_mask = {"object-layer", "water-tile", "rail-layer", "not-colliding-with-itself" }
        },
        { -- 5
            leg = "giantenemyspider-spider-leg-5-" .. leg_scale_variant,
            mount_position = util.by_pixel(-15 * scale, -22 * scale),--{-0.5, -0.75},
            ground_position = {-2.25 * scale, -2.5 * leg_scale},
            blocking_legs = {6, 1},
            leg_hit_the_ground_trigger = legTrigger(scale),
            collision_mask = {"object-layer", "water-tile", "rail-layer", "not-colliding-with-itself" }
        },
        { -- 6
            leg = "giantenemyspider-spider-leg-6-" .. leg_scale_variant,
            mount_position = util.by_pixel(-23 * scale, -10 * scale),--{-0.75, -0.25},
            ground_position = {-3 * scale, -1 * leg_scale},
            blocking_legs = {5, 7},
            leg_hit_the_ground_trigger = legTrigger(scale),
            collision_mask = {"object-layer", "water-tile", "rail-layer", "not-colliding-with-itself" }
        },
        { -- 7
            leg = "giantenemyspider-spider-leg-7-" .. leg_scale_variant,
            mount_position = util.by_pixel(-25 * scale, 4 * scale),--{-0.75, 0.25},
            ground_position = {-3 * scale, 1 * leg_scale},
            blocking_legs = {6, 8},
            leg_hit_the_ground_trigger = legTrigger(scale),
            collision_mask = {"object-layer", "water-tile", "rail-layer", "not-colliding-with-itself" }
        },
        { -- 8
            leg = "giantenemyspider-spider-leg-8-" .. leg_scale_variant,
            mount_position = util.by_pixel(-15 * scale, 17 * scale),--{-0.5, 0.75},
            ground_position = {-2.25 * scale, 2.5 * leg_scale},
            blocking_legs = {7},
            leg_hit_the_ground_trigger = legTrigger(scale),
            collision_mask = {"object-layer", "water-tile", "rail-layer", "not-colliding-with-itself" }
        }
    }
end

function legTrigger(scale)
    getTriggers = get_leg_hit_the_ground_trigger()
    for _, trigger in pairs(getTriggers) do
        trigger.repeat_count = 1
        trigger.probability = math.min(scale, 1)
    end
    return getTriggers
end