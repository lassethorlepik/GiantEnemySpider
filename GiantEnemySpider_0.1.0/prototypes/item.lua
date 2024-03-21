local sounds = require ("__base__.prototypes.entity.sounds")

data:extend({
  {
    type = "movement-bonus-equipment",
    name = "giantenemyspider-leg-upgrade-1",
    sprite = 
    {
      filename = "__GiantEnemySpider__/graphics/equipment/leg-upgrade-1.png",
      width = 803,
      height = 803,
    },
    shape = 
    {
      width = 2,
      height = 2,
      type = "full"
    },
    energy_source = 
    {
      type = "electric",
      buffer_capacity = "10kJ",
      input_flow_limit = "5kW",
      output_flow_limit = "0W",
      usage_priority = "secondary-input"
    },
    energy_consumption = "1kW",
    movement_bonus = 0.25,
    categories = {"armor"},
  },
  {
    type = "movement-bonus-equipment",
    name = "giantenemyspider-leg-upgrade-2",
    sprite = 
    {
      filename = "__GiantEnemySpider__/graphics/equipment/leg-upgrade-2.png",
      width = 803,
      height = 803,
    },
    shape = 
    {
      width = 2,
      height = 2,
      type = "full"
    },
    energy_source = 
    {
      type = "electric",
      buffer_capacity = "20kJ",
      input_flow_limit = "10kW",
      output_flow_limit = "0W",
      usage_priority = "secondary-input"
    },
    energy_consumption = "2kW",
    movement_bonus = 0.5,
    categories = {"armor"},
  },
  {
    type = "movement-bonus-equipment",
    name = "giantenemyspider-leg-upgrade-3",
    sprite = 
    {
      filename = "__GiantEnemySpider__/graphics/equipment/leg-upgrade-3.png",
      width = 803,
      height = 803,
    },
    shape = 
    {
      width = 2,
      height = 2,
      type = "full"
    },
    energy_source = 
    {
      type = "electric",
      buffer_capacity = "50kJ",
      input_flow_limit = "10kW",
      output_flow_limit = "0W",
      usage_priority = "secondary-input"
    },
    energy_consumption = "10kW",
    movement_bonus = 1,
    categories = {"armor"},
  },
  {
    type = "item",
    name = "giantenemyspider-leg-upgrade-1",
    icon = "__GiantEnemySpider__/graphics/equipment/leg-upgrade-1.png",
    placed_as_equipment_result = "giantenemyspider-leg-upgrade-1",
    subgroup = "equipment",
    order = "z1",
    stack_size = 10,
    icon_size = 803,
  },
  {
    type = "item",
    name = "giantenemyspider-leg-upgrade-2",
    icon = "__GiantEnemySpider__/graphics/equipment/leg-upgrade-2.png",
    placed_as_equipment_result = "giantenemyspider-leg-upgrade-2",
    subgroup = "equipment",
    order = "z2",
    stack_size = 10,
    icon_size = 803,
  },
  {
    type = "item",
    name = "giantenemyspider-leg-upgrade-3",
    icon = "__GiantEnemySpider__/graphics/equipment/leg-upgrade-3.png",
    placed_as_equipment_result = "giantenemyspider-leg-upgrade-3",
    subgroup = "equipment",
    order = "z3",
    stack_size = 10,
    icon_size = 803,
  },
  {
    type = "active-defense-equipment",
    name = "giantenemyspider-web-1",
    sprite =
    {
      filename = "__GiantEnemySpider__/graphics/equipment/web-1.png",
      width = 512,
      height = 512,
      priority = "medium",
    },
    shape =
    {
      width = 2,
      height = 2,
      type = "full"
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "primary-input",
      buffer_capacity = "10kJ"
    },

    attack_parameters =
    {
      type = "beam",
      turn_range = 0.75,
      cooldown = 40,
      range = 30,
      damage_modifier = 3,
      health_penalty = -0.1,
      movement_slow_down_factor = 1,
      movement_slow_down_cooldown = 1,
      ammo_type =
      {
        category = "laser",
        energy_consumption = "1kJ",
        action =
        {
          type = "direct",
          action_delivery =
          {
            type = "beam",
            beam = "giantenemyspider-web-beam",
            max_length = 30,
            duration = 40,
            source_offset = {0, 0 }
          }
        }
      }
    },

    automatic = true,
    categories = {"armor"}
  },
  {
    type = "active-defense-equipment",
    name = "giantenemyspider-fangs-1",
    sprite =
    {
      filename = "__GiantEnemySpider__/graphics/equipment/fangs-1.png",
      width = 512,
      height = 512,
      priority = "medium",
    },
    shape =
    {
      width = 2,
      height = 2,
      type = "full"
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      buffer_capacity = "220kJ"
    },

    attack_parameters =
    {
      type = "projectile",
      turn_range = 0.5,
      range = 1,
      cooldown = 50,
      cooldown_deviation = 0.15,
      ammo_type = make_unit_melee_ammo_type(90),
      sound =  sounds.biter_roars_behemoth(0.65),
      animation = biterattackanimation(behemoth_biter_scale, behemoth_biter_tint1, behemoth_biter_tint2),
      range_mode = "bounding-box-to-bounding-box"
    },

    automatic = true,
    categories = {"armor"}
  },
  {
    type = "active-defense-equipment",
    name = "giantenemyspider-poison-1",
    sprite =
    {
      filename = "__GiantEnemySpider__/graphics/equipment/poison-1.png",
      width = 640,
      height = 640,
      priority = "medium",
    },
    shape =
    {
      width = 2,
      height = 2,
      type = "full"
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "primary-input",
      buffer_capacity = "10kJ"
    },

    attack_parameters = spitter_behemoth_attack_parameters({
      acid_stream_name = "acid-stream-spitter-behemoth",
      health_penalty = -0.2,
      turn_range = 0.5,
      range = 20,
      min_attack_distance = 0,
      cooldown = 100,
      cooldown_deviation = 0.35,
      damage_modifier = damage_modifier_spitter_behemoth,
      scale = scale_spitter_behemoth,
      tint1 = tint_1_spitter_behemoth,
      tint2 = tint_2_spitter_behemoth,
      roarvolume = 0.8,
      range_mode = "bounding-box-to-bounding-box"
    }),

    automatic = true,
    categories = {"armor"}
  },
  {
    type = "item",
    name = "giantenemyspider-web-1",
    icon = "__GiantEnemySpider__/graphics/equipment/web-1.png",
    placed_as_equipment_result = "giantenemyspider-web-1",
    subgroup = "equipment",
    order = "z5",
    stack_size = 10,
    icon_size = 512,
  },
  {
    type = "item",
    name = "giantenemyspider-fangs-1",
    icon = "__GiantEnemySpider__/graphics/equipment/fangs-1.png",
    placed_as_equipment_result = "giantenemyspider-fangs-1",
    subgroup = "equipment",
    order = "z4",
    stack_size = 10,
    icon_size = 512,
  },
  {
    type = "item",
    name = "giantenemyspider-poison-1",
    icon = "__GiantEnemySpider__/graphics/equipment/poison-1.png",
    placed_as_equipment_result = "giantenemyspider-poison-1",
    subgroup = "equipment",
    order = "z6",
    stack_size = 10,
    icon_size = 640,
  },
  {
    type = "generator-equipment",
    name = "giantenemyspider-heart-1",
    sprite = 
    {
      filename = "__GiantEnemySpider__/graphics/equipment/heart-1.png",
      width = 350,
      height = 350,
    },
    shape = 
    {
      width = 4,
      height = 4,
      type = "full"
    },
    energy_source =
    {
      type = "electric",
      usage_priority = "primary-output"
    },
    power = "1MW",
    categories = {"armor"},
  },
  {
    type = "item",
    name = "giantenemyspider-heart-1",
    icon = "__GiantEnemySpider__/graphics/equipment/heart-1.png",
    placed_as_equipment_result = "giantenemyspider-heart-1",
    subgroup = "equipment",
    order = "z7",
    stack_size = 10,
    icon_size = 350,
  },
  {
    type = "energy-shield-equipment",
    name = "giantenemyspider-armor-1",
    sprite =
    {
      filename = "__GiantEnemySpider__/graphics/equipment/armor-1.png",
      width = 400,
      height = 400,
    },
    shape =
    {
      width = 2,
      height = 2,
      type = "full"
    },
    max_shield_value = 100,
    energy_source =
    {
      type = "electric",
      buffer_capacity = "1MJ",
      input_flow_limit = "1MW",
      usage_priority = "primary-input"
    },
    energy_per_shield = "100kJ",
    categories = {"armor"}
  },
  {
    type = "item",
    name = "giantenemyspider-armor-1",
    icon = "__GiantEnemySpider__/graphics/equipment/armor-1.png",
    placed_as_equipment_result = "giantenemyspider-armor-1",
    subgroup = "equipment",
    order = "z8",
    stack_size = 10,
    icon_size = 400,
  }
})
