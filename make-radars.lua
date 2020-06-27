local MakeRadar = {}

local rusty_locale = require("__rusty-locale__.locale")
local rusty_icons = require("__rusty-locale__.icons")

local locale_of = rusty_locale.of
local icons_of = rusty_icons.of

local PREFIX = "Roboport_Radar-"

local radar_icons = icons_of(data.raw.radar.radar)

local seen = {}

function MakeRadar.make_radar(new_radars, roboport, roboport_name, _)
  if seen[roboport_name] then return end

  local construction_radius = roboport.construction_radius
  if not construction_radius then
    error("Construction radius not defined for " .. roboport_name)
  end
  if construction_radius == 0 then return end

  local energy_source = roboport.energy_source

  local chunk_radius = math.ceil(roboport.construction_radius / 32)

  local roboport_locale = locale_of(roboport)

  -- parse_energy returns J/tick.
  local energy_usage = util.parse_energy(roboport.energy_usage) * 60
  if energy_usage > 0 then
    roboport.energy_usage = energy_usage - 1 .. "W"
  end

  new_radars[#new_radars+1] = {
    type = "radar",
    name = PREFIX .. roboport_name,
    localised_name = { "entity-name.Roboport_Radar", roboport_locale.name },
    icons = radar_icons,
    max_health = 1,
    flags = {
      "no-automated-item-insertion",
      "no-automated-item-removal"
    },
    collision_box = roboport.collision_box,
    collision_mask = {},
    selectable_in_game = false,
    energy_per_sector = "10MJ",
    max_distance_of_sector_revealed = 0,
    max_distance_of_nearby_sector_revealed = chunk_radius,
    energy_per_nearby_scan = "3J", -- 1 pulse every 3 seconds; once every 4 wasn't enough.
    energy_source =
    {
      type = energy_source.type,
      usage_priority = "secondary-input",
      render_no_power_icon = false,
      render_no_network_icon = false,
      drain = "0W"
    },
    energy_usage = "1W",
    pictures = {
      filename = "__core__/graphics/empty.png",
      priority = "low",
      width = 1,
      height = 1,
      apply_projection = false,
      direction_count = 1,
    }
  }
end

return MakeRadar