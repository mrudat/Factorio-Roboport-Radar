-- shamelessly borrowed from Big Brother
local Entity   = require '__stdlib__/stdlib/entity/entity'
local Event    = require '__stdlib__/stdlib/event/event'
local table    = require '__stdlib__/stdlib/utils/table'

Event.register(
  {
    defines.events.on_built_entity,
    defines.events.on_robot_built_entity
  },
  function(event)
    local roboport = event.created_entity
    if not (roboport.type == 'roboport') then return end
    add_radar(roboport)
  end
)

Event.register(
  {
    defines.events.script_raised_built,
    defines.script_raised_revive
  },
  function(event)
    local roboport = event.entity
    if not (roboport.type == 'roboport') then return end
    add_radar(roboport)
  end
)

Event.register(
  {
    defines.events.on_entity_died,
    defines.events.on_robot_pre_mined,
    defines.events.on_player_mined_entity,
    defines.script_raised_destroy
  },
  function(event)
    local roboport = event.entity
    if not (roboport.type == 'roboport') then return end
    remove_radar(roboport)
  end
)

-- Scan the map once if the mod is updated
Event.register({Event.core_events.init, Event.core_events.configuration_changed}, function(event)
  table.each(game.surfaces, function(surface)
    table.each(surface.find_entities_filtered({type = 'roboport'}), add_radar)
  end)
end)

function add_radar(roboport)
  local data = Entity.get_data(roboport)
  if data then return end
  local radar_name = roboport.name .. "-radar"
  -- we don't create radars for degenerate roboports (with no logistics/construction radius); not sure if this is the most efficient method, but it should work.
  pcall(
    function()
      local radar = roboport.surface.create_entity({
        name = radar_name,
        position = roboport.position,
        force = roboport.force
      })
      Entity.set_indestructible(radar)
      Entity.set_data(roboport, { radar = radar })
    end
  )
end

function remove_radar(roboport)
  local data = Entity.get_data(roboport)
  if data and data.radar and data.radar.valid then
    data.radar.destroy()
    Entity.set_data(roboport, nil)
  end
end
