local PREFIX = "Roboport_Radar-"

local roboport_name_to_radar_name
local roboport_to_radar

local function add_radar(roboport)
  local radar_name = roboport_name_to_radar_name[roboport.name]
  if not radar_name then return end -- shouldn't happen, but...

  local unit_number = roboport.unit_number

  local radar = roboport_to_radar[unit_number]
  if radar and radar.valid then return end

  radar = roboport.surface.create_entity({
    name = radar_name,
    position = roboport.position,
    force = roboport.force
  })
  radar.minable = false
  radar.destructible = false
  roboport_to_radar[unit_number] = radar
end

local function remove_radar(roboport)
  local radar_name = roboport_name_to_radar_name[roboport.name]
  if not radar_name then return end -- shouldn't happen, but...

  local unit_number = roboport.unit_number

  local radar = roboport_to_radar[unit_number]
  if radar and radar.valid then
    radar.destroy()
  end
  roboport_to_radar[unit_number] = nil
end

local function index_prototypes_and_place_radars()
  roboport_name_to_radar_name = {}
  local radar_prototypess = game.get_filtered_entity_prototypes{{
    filter = "type",
    type = "radar"
  }}
  local roboport_prototypes = game.get_filtered_entity_prototypes{{
    filter = "type",
    type = "roboport"
  }}

  local roboport_names = {}
  local roboport_filter = {}

  for roboport_name in pairs(roboport_prototypes) do
    local radar_name = PREFIX .. roboport_name
    if radar_prototypess[radar_name] then
      roboport_name_to_radar_name[roboport_name] = radar_name
      roboport_names[#roboport_names+1] = roboport_name
      roboport_filter[#roboport_filter+1] = {
        filter = "name",
        name = roboport_name
      }
    end
  end

  global.roboport_name_to_radar_name = roboport_name_to_radar_name
  global.roboport_filter = roboport_filter
  roboport_to_radar = global.roboport_to_radar

  for _, surface in pairs(game.surfaces) do
    local roboports = surface.find_entities_filtered({
      type = 'roboport',
      name = roboport_names
    })
    for _, roboport in pairs(roboports) do
      add_radar(roboport)
    end
  end
end

local all_events = {}

local function on_load()
  roboport_name_to_radar_name = global.roboport_name_to_radar_name
  roboport_to_radar = global.roboport_to_radar
  local roboport_filter = global.roboport_filter
  for i = 1,#all_events do
    local event = all_events[i]
    script.set_event_filter(event, roboport_filter)
  end
end

local function on_init()
  global.roboport_to_radar = {}

  index_prototypes_and_place_radars()

  on_load()
end

local function on_configuration_changed()
  global._entity_data = nil -- Entity.get_data used to store stuff here
  index_prototypes_and_place_radars()

  on_load()
end

script.on_init(on_init)

script.on_load(on_load)

script.on_configuration_changed(on_configuration_changed)

local function register_events(events, handler)
  for _,event in ipairs(events) do
    all_events[#all_events+1] = event
    script.on_event(event, handler)
  end
end

register_events(
  {
    defines.events.on_entity_cloned
  },
  function(event)
    add_radar(event.destination)
  end
)
register_events(
  {
    defines.events.on_built_entity,
    defines.events.on_robot_built_entity
  },
  function(event)
    add_radar(event.created_entity)
  end
)

register_events(
  {
    defines.events.script_raised_built,
    defines.script_raised_revive
  },
  function(event)
    add_radar(event.entity)
  end
)

register_events(
  {
    defines.events.on_entity_died,
    defines.events.on_robot_pre_mined,
    defines.events.on_player_mined_entity,
    defines.script_raised_destroy
  },
  function(event)
    remove_radar(event.entity)
  end
)

script.on_event(
  {
    defines.events.on_chunk_deleted,
    defines.events.on_surface_cleared,
    defines.events.on_surface_deleted
  },
  function()
    for unit_number, radar in pairs(roboport_to_radar) do
      if not radar.valid then
        roboport_to_radar[unit_number] = nil
      end
    end
  end
)