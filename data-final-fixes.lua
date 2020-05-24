for _,roboport in pairs(data.raw["roboport"]) do
  if logistics_radius == 0 or construction_radius == 0 then goto next_roboport end

  local chunk_radius = math.ceil(roboport.construction_radius / 32)

  local roboport_name = roboport.name

  local roboport_localised_name = roboport.localised_name or { "entity-name." .. roboport_name }

  -- TODO roboport.energy_usage = roboport.energy_usage - 1W

  data:extend({
    {
      type = "radar",
      name = roboport_name .. "-radar",
      localised_name = { "entity-name.Roboport_Radar", roboport_localised_name },
      icon = "__base__/graphics/icons/radar.png", -- TODO a different icon
      icon_size = 64, icon_mipmaps = 4,
      order = 'd-f',
      max_health = 1,
      flags = {
        "no-automated-item-insertion",
        "no-automated-item-removal"
      },
      collision_box = roboport.collision_box, -- so that if roboport is powered we're powered
      collision_mask = {}, -- we don't collide with anything, so we can be placed on a roboport
      selectable_in_game = false,
      energy_per_sector = "10MJ",
      max_distance_of_sector_revealed = 0,
      max_distance_of_nearby_sector_revealed = chunk_radius,
      energy_per_nearby_scan = "3J", -- 1 pulse every 3 seconds; once every 4 wasn't enough.
      energy_source =
      {
--        type = "void",
        type = "electric",
        usage_priority = "secondary-input",
        render_no_power_icon = false, -- we're always running on low power
        render_no_network_icon = false -- roboport covers this
      },
      energy_usage = "1W", -- Logically, this is part of the roboport, so shouldn't cost moar power, but if we don't charge anything, it will still run if the roboport is out of power.
      pictures =
      {
        filename = "__base__/graphics/entity/radar/radar.png",
        priority = "low",
        width = 1,
        height = 1,
        apply_projection = false,
        direction_count = 1,
        line_length = 1,
        shift = {0.0, 0.0}
      }
    },
  })

  ::next_roboport::
end
