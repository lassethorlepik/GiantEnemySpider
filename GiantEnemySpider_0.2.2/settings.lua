data:extend({
    {
        type = "double-setting",
        name = "giantenemyspider-health-scale",
        setting_type = "startup",
        default_value = 1,
        order = "a"
    },
    {
        type = "int-setting",
        name = "giantenemyspider-max-spiders",
        setting_type = "runtime-global",
        default_value = 80,
        order = "a"
    },
    {
        type = "int-setting",
        name = "giantenemyspider-despawn",
        setting_type = "runtime-global",
        default_value = 10,
        minimum_value = 1,
        order = "b"
    },
    {
        type = "int-setting",
        name = "giantenemyspider-spawn-distance",
        setting_type = "runtime-global",
        default_value = 2000,
        minimum_value = 100,
        maximum_value = 30000,
        order = "c"
    },
    {
        type = "bool-setting",
        name = "giantenemyspider-debug-path",
        setting_type = "runtime-global",
        default_value = false,
        order = "d"
    }
})
