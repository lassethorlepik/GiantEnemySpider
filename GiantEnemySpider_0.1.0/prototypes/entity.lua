local sounds = require("__GiantEnemySpider__.prototypes.sounds")
local spider_animations = require("__GiantEnemySpider__.spider-animations")
local scale = 1
local leg_scale = 1

-- Remnants
data:extend({
  {
    type = "corpse",
    name = "giantenemyspider-spider-remnant",
    icon = "__GiantEnemySpider__/graphics/spider/remnants/spider-corpse.png",
    icon_size = 1024,
    flags = {"placeable-neutral", "not-on-map"},
    subgroup = "remnants",
    order = "a-a-a",
    selection_box = {{-1, -1}, {1, 1}},
    tile_width = 3,
    tile_height = 3,
    selectable_in_game = false,
    time_before_removed = 60 * 60 * 15, -- 15 minutes
    final_render_layer = "remnants",
    remove_on_tile_placement = false,
    animation = {
      {
        filename = "__GiantEnemySpider__/graphics/spider/remnants/spider-corpse.png",
        line_length = 1,
        direction_count = 1,
        width = 1024,
        height = 1024,
        scale = 0.25
      },
    },
  }
})

-- Leg
local function make_spider_leg(number)
  return
  {
    type = "spider-leg",
    name = "giantenemyspider-spider-leg-" .. number,
    localised_name = {"entity-name.spider-leg"},
    collision_box = {{-0.01, -0.01}, {0.01, 0.01}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    icon = "__base__/graphics/icons/spidertron.png",
    icon_size = 64, icon_mipmaps = 4,
    walking_sound_volume_modifier = 0.2,
    target_position_randomisation_distance = 0.25,
    minimal_step_size = 1,
    working_sound = 
    {
      match_progress_to_activity = true,
      sound = sounds.spidertron_leg,
      audible_distance_modifier = 0.2,
    },
    part_length = 2.6,
    initial_movement_speed = 0.05,
    movement_acceleration = 0.02,
    max_health = 100,
    movement_based_position_selection_distance = 3,
    selectable_in_game = false,
    graphics_set = spider_animations.legs[number],
  }
end

-- Capsule
data:extend({
{
    type = "spider-vehicle",
    name = "giantenemyspider-spider",
    collision_box = {{-1, -1}, {1, 1}},
    selection_box = {{-1, -1}, {1, 1}},
    icon = "__GiantEnemySpider__/graphics/spider/spider.png",
    mined_sound = {filename = "__core__/sound/deconstruct-large.ogg",volume = 0.8},
    open_sound = { filename = "__GiantEnemySpider__/sounds/spider-door-open.ogg", volume= 0.35 },
    close_sound = { filename = "__GiantEnemySpider__/sounds/spider-door-close.ogg", volume = 0.4 },
    sound_minimum_speed = 0.1,
    sound_scaling_ratio = 0.6,
    working_sound =
    {
      sound =
      {
        filename = "__GiantEnemySpider__/sounds/spider-vox.ogg",
        volume = 0.15,
	    speed = 0.6
      },
      activate_sound =
      {
        filename = "__GiantEnemySpider__/sounds/spider-activate.ogg",
        volume = 0.8
      },
      deactivate_sound =
      {
        filename = "__GiantEnemySpider__/sounds/spider-deactivate.ogg",
        volume = 0.8
      },
      match_speed_to_activity = true,
    },
    icon_size = 128, icon_mipmaps = 4,
    weight = 1,
    braking_force = 1,
    friction_force = 1,
    flags = {"placeable-neutral", "player-creation", "placeable-off-grid"},
    collision_mask = {},
    max_health = 10000,
    resistances =
    {
	  {
        type = "acid",
        decrease = 0,
        percent = 60
      },
	  {
        type = "electric",
        decrease = 0,
        percent = 90
      },
	  {
        type = "explosion",
        decrease = 20,
        percent = 80
      },
	  {
        type = "fire",
        decrease = 15,
        percent = 60
      },
	  {
        type = "impact",
        decrease = 50,
        percent = 80
      },
	  {
        type = "laser",
        decrease = 0,
        percent = 70
      },
      {
        type = "physical",
        decrease = 15,
        percent = 60
      }           
    },
    minimap_representation =
    {
      filename = "__GiantEnemySpider__/graphics/spider/spider.png",
      flags = {"icon"},
      size = {128, 128},
      scale = 0.5
    },
    corpse = "giantenemyspider-spider-remnant",
    dying_explosion = "behemoth-worm-die",
    energy_per_hit_point = 1,
    guns = { "spidertron-rocket-launcher-1", "spidertron-rocket-launcher-2", "spidertron-rocket-launcher-3", "spidertron-rocket-launcher-4" },
    inventory_size = 60,
	  trash_inventory_size = 10,
    equipment_grid = "spidertron-equipment-grid",
    height = 1.25,
    torso_rotation_speed = 0.007,
    chunk_exploration_radius = 2,
    selection_priority = 51,
    graphics_set = spider_animations.torso,
    energy_source =
    {
      type = "void"
    },
    movement_energy_consumption = "5kW",
    automatic_weapon_cycling = false,
    chain_shooting_cooldown_modifier = 0.5,
    spider_engine =
    {
      legs =
      {
        { -- 1
          leg = "giantenemyspider-spider-leg-1",
          mount_position = util.by_pixel(15  * scale, -22 * scale),--{0.5, -0.75},
          ground_position = {2.25  * leg_scale, -2.5  * leg_scale},
          blocking_legs = {2},
          leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
        },
        { -- 2
          leg = "giantenemyspider-spider-leg-2",
          mount_position = util.by_pixel(23  * scale, -10  * scale),--{0.75, -0.25},
          ground_position = {3  * leg_scale, -1  * leg_scale},
          blocking_legs = {1, 3},
          leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
        },
        { -- 3
          leg = "giantenemyspider-spider-leg-3",
          mount_position = util.by_pixel(25  * scale, 4  * scale),--{0.75, 0.25},
          ground_position = {3  * leg_scale, 1  * leg_scale},
          blocking_legs = {2, 4},
          leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
        },
        { -- 4
          leg = "giantenemyspider-spider-leg-4",
          mount_position = util.by_pixel(15  * scale, 17  * scale),--{0.5, 0.75},
          ground_position = {2.25  * leg_scale, 2.5  * leg_scale},
          blocking_legs = {3},
          leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
        },
        { -- 5
          leg = "giantenemyspider-spider-leg-5",
          mount_position = util.by_pixel(-15 * scale, -22 * scale),--{-0.5, -0.75},
          ground_position = {-2.25 * leg_scale, -2.5 * leg_scale},
          blocking_legs = {6, 1},
          leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
        },
        { -- 6
          leg = "giantenemyspider-spider-leg-6",
          mount_position = util.by_pixel(-23 * scale, -10 * scale),--{-0.75, -0.25},
          ground_position = {-3 * leg_scale, -1 * leg_scale},
          blocking_legs = {5, 7},
          leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
        },
        { -- 7
          leg = "giantenemyspider-spider-leg-7",
          mount_position = util.by_pixel(-25 * scale, 4 * scale),--{-0.75, 0.25},
          ground_position = {-3 * leg_scale, 1 * leg_scale},
          blocking_legs = {6, 8},
          leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
        },
        { -- 8
          leg = "giantenemyspider-spider-leg-8",
          mount_position = util.by_pixel(-15 * scale, 17 * scale),--{-0.5, 0.75},
          ground_position = {-2.25 * leg_scale, 2.5 * leg_scale},
          blocking_legs = {7},
          leg_hit_the_ground_trigger = get_leg_hit_the_ground_trigger()
        }
      },
      military_target = "spidertron-military-target",
    }
  },
  make_spider_leg(1),
  make_spider_leg(2),
  make_spider_leg(3),
  make_spider_leg(4),
  make_spider_leg(5),
  make_spider_leg(6),
  make_spider_leg(7),
  make_spider_leg(8),
})