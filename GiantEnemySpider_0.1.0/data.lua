require("prototypes.entity")
require("prototypes.item")

levels = 10

function create_spider(level)
    local spider_entity = table.deepcopy(data.raw["spider-vehicle"]["giantenemyspider-spider"])
    spider_entity.name = "giantenemyspider-spider-" .. level
    spider_entity.localised_name = "lvl. " .. level .. " Spider"
    healths = {10, 50, 200, 250, 300, 500, 1000, 2500, 5000, 10000}
    spider_entity.max_health = healths[level]
    data:extend{
        spider_entity
    }
end

for i = 1, levels do
    create_spider(i)
end
