local sounds = require("__GiantEnemySpider__.prototypes.sounds")
require("__GiantEnemySpider__.spider-animations")
require("__GiantEnemySpider__.utilities")
spider_animations_01 = build_animations(0.3)
spider_animations_05 = build_animations(0.5)
spider_animations_1 = build_animations(1)
--spider_animations_4 = build_animations(2)
local scale = 1
local leg_scale = 1

-- Remnants
data:extend({
  {
    type = "corpse",
    name = "giantenemyspider-spider-remnant-5",
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
        scale = 0.65
      },
    },
  }
})

local remnant4 = table.deepcopy(data.raw["corpse"]["giantenemyspider-spider-remnant-5"])
remnant4.animation = {
  filename = "__GiantEnemySpider__/graphics/spider/remnants/spider-corpse.png",
  line_length = 1,
  direction_count = 1,
  width = 1024,
  height = 1024,
  scale = 0.4
}
remnant4.name = "giantenemyspider-spider-remnant-4"
local remnant3 = table.deepcopy(data.raw["corpse"]["giantenemyspider-spider-remnant-5"])
remnant3.animation = {
  filename = "__GiantEnemySpider__/graphics/spider/remnants/spider-corpse.png",
  line_length = 1,
  direction_count = 1,
  width = 1024,
  height = 1024,
  scale = 0.2
}
remnant3.name = "giantenemyspider-spider-remnant-3"
local remnant2 = table.deepcopy(data.raw["corpse"]["giantenemyspider-spider-remnant-5"])
remnant2.animation = {
  filename = "__GiantEnemySpider__/graphics/spider/remnants/spider-corpse.png",
  line_length = 1,
  direction_count = 1,
  width = 1024,
  height = 1024,
  scale = 0.125
}
remnant2.name = "giantenemyspider-spider-remnant-2"
local remnant1 = table.deepcopy(data.raw["corpse"]["giantenemyspider-spider-remnant-5"])
remnant1.animation = {
  filename = "__GiantEnemySpider__/graphics/spider/remnants/spider-corpse.png",
  line_length = 1,
  direction_count = 1,
  width = 1024,
  height = 1024,
  scale = 0.075
}
remnant1.name = "giantenemyspider-spider-remnant-1"
data:extend({
  remnant1, remnant2, remnant3, remnant4
})

-- Leg
local function make_spider_leg(number, multiplier)
  leg = {
    type = "spider-leg",
    name = "giantenemyspider-spider-leg-" .. number .. "-" .. string.gsub(tostring(multiplier), "%.", ""),
    localised_name = {"entity-name.spider-leg"},
    collision_box = multiplier >= 1 and {{-0.01, -0.01}, {0.01, 0.01}} or {{-0.0, -0.0}, {0.0, 0.0}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    icon = "__base__/graphics/icons/spidertron.png",
    icon_size = 64, icon_mipmaps = 4,
    walking_sound_volume_modifier = 0.2,
    target_position_randomisation_distance = 0.2 * multiplier,
    minimal_step_size = math.min(multiplier + 0.05, 1),
    working_sound = 
    {
      match_progress_to_activity = true,
      sound = sounds.spidertron_leg,
      audible_distance_modifier = 1,
    },
    part_length = 2.6 * multiplier,
    initial_movement_speed = 0.075,
    movement_acceleration = 0.025,
    max_health = 100,
    movement_based_position_selection_distance = 3 * multiplier,
    selectable_in_game = false
  }
  if multiplier > 1 then
    leg.graphics_set = spider_animations_1.legs[number]
  elseif multiplier > 0.5 then
    leg.graphics_set = spider_animations_1.legs[number]
  elseif multiplier > 0.4 then
    leg.graphics_set = spider_animations_05.legs[number]
  else
    leg.graphics_set = spider_animations_01.legs[number]
  end
  return leg
end

-- Capsule
data:extend({
{
    type = "spider-vehicle",
    name = "giantenemyspider-spider",
    inventory_size = 1,
    collision_box = {{-0.0, -0.0}, {0.0, 0.0}},
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
        decrease = 100,
        percent = 50
      },
	  {
        type = "explosion",
        decrease = 5,
        percent = 50
      },
	  {
        type = "fire",
        decrease = 5,
        percent = 30
      },
	  {
        type = "impact",
        decrease = 0,
        percent = 100
      },
	  {
        type = "laser",
        decrease = 0,
        percent = 50
      },
      {
        type = "physical",
        decrease = 3,
        percent = 50
      }           
    },
    minimap_representation =
    {
      filename = "__GiantEnemySpider__/graphics/spider/spider.png",
      flags = {"icon"},
      size = {128, 128},
      scale = 0.5
    },
    corpse = "giantenemyspider-spider-remnant-3",
    dying_explosion = "behemoth-worm-die",
    energy_per_hit_point = 1,
    guns = { "spidertron-rocket-launcher-1" },
    equipment_grid = "spidertron-equipment-grid",
    height = 1.25,
    torso_rotation_speed = 0.015,
    chunk_exploration_radius = 2,
    selection_priority = 51,
    graphics_set = spider_animations_1.torso,
    energy_source =
    {
      type = "void"
    },
    movement_energy_consumption = "5kW",
    automatic_weapon_cycling = false,
    chain_shooting_cooldown_modifier = 0.5,
    spider_engine =
    {
      legs = build_legs(1, 1, 1),
      military_target = "spidertron-military-target",
    }
  },
  {
    type = "beam",
    name = "giantenemyspider-web-beam",
    flags = {"not-on-map"},
    width = 1,
    damage_interval = 20,
    working_sound = {
      {
        filename = "__GiantEnemySpider__/sounds/web-beam.ogg",
        volume = 0.7
      },
    },
    action = {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {
          type = "damage",
          damage = {amount = 5, type = "physical"}
        }
      }
    },
    start = {
      filename = "__GiantEnemySpider__/graphics/web-beam/beam-tail.png",
      flags = beam_flags or beam_non_light_flags,
      line_length = 16,
      width = 45 - 6,
      height = 39,
      frame_count = 16,
      shift = util.by_pixel(6/2, 0),
      tint = {r = 0.0, g = 0.0, b = 0.0, a = 0.0},
      blend_mode = blend_mode or beam_blend_mode
    },
    ending = {
      filename = "__GiantEnemySpider__/graphics/web-beam/hr-tileable-beam-END.png",
        flags = beam_flags or beam_non_light_flags,
        line_length = 4,
        width = 91,
        height = 93,
        frame_count = 16,
        direction_count = 1,
        shift = {-0.078125, -0.046875},
        tint = beam_tint,
        scale = 0.5
    },
    head = {
      filename = "__GiantEnemySpider__/graphics/web-beam/beam-head.png",
      flags = beam_flags or beam_non_light_flags,
      line_length = 16,
      width = 45 - 7,
      height = 39,
      frame_count = 16,
      shift = util.by_pixel(-7/2, 0),
      tint = beam_tint,
      blend_mode = blend_mode or beam_blend_mode
    },
    tail = {
      filename = "__GiantEnemySpider__/graphics/web-beam/beam-tail.png",
      flags = beam_flags or beam_non_light_flags,
      line_length = 16,
      width = 45 - 6,
      height = 39,
      frame_count = 16,
      shift = util.by_pixel(6/2, 0),
      tint = beam_tint,
      blend_mode = blend_mode or beam_blend_mode
    },
    body = {
      {
        filename = "__GiantEnemySpider__/graphics/web-beam/beam-body-1.png",
        flags = beam_flags or beam_non_light_flags,
        line_length = 16,
        width = 32,
        height = 39,
        frame_count = 16,
        tint = beam_tint,
        blend_mode = blend_mode or beam_blend_mode
      },
      {
        filename = "__GiantEnemySpider__/graphics/web-beam/beam-body-2.png",
        flags = beam_flags or beam_non_light_flags,
        line_length = 16,
        width = 32,
        height = 39,
        frame_count = 16,
        blend_mode = blend_mode or beam_blend_mode
      },
      {
        filename = "__GiantEnemySpider__/graphics/web-beam/beam-body-3.png",
        flags = beam_flags or beam_non_light_flags,
        line_length = 16,
        width = 32,
        height = 39,
        frame_count = 16,
        blend_mode = blend_mode or beam_blend_mode
      },
      {
        filename = "__GiantEnemySpider__/graphics/web-beam/beam-body-4.png",
        flags = beam_flags or beam_non_light_flags,
        line_length = 16,
        width = 32,
        height = 39,
        frame_count = 16,
        blend_mode = blend_mode or beam_blend_mode
      },
      {
        filename = "__GiantEnemySpider__/graphics/web-beam/beam-body-5.png",
        flags = beam_flags or beam_non_light_flags,
        line_length = 16,
        width = 32,
        height = 39,
        frame_count = 16,
        blend_mode = blend_mode or beam_blend_mode
      },
      {
        filename = "__GiantEnemySpider__/graphics/web-beam/beam-body-6.png",
        flags = beam_flags or beam_non_light_flags,
        line_length = 16,
        width = 32,
        height = 39,
        frame_count = 16,
        blend_mode = blend_mode or beam_blend_mode
      }
    }
  },
})

-- Create leg prototypes
local spider_leg_definitions = {}
local modifiers = {0.1, 0.5, 1, 4}

for _, modifier in pairs(modifiers) do
    for leg_number = 1, 8 do
        table.insert(spider_leg_definitions, make_spider_leg(leg_number, modifier))
    end
end

data:extend(spider_leg_definitions)
