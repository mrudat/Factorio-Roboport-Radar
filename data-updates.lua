if mods ['HighlyDerivative'] then
  require('__HighlyDerivative__/library').derive()
else
  local MakeRadars = require('make-radars')

  local make_radar = MakeRadars.make_radar

  local new_things = {}

  for roboport_name,roboport in pairs(data.raw["roboport"]) do
    make_radar(new_things, roboport, roboport_name, 'roboport')
  end

  data:extend(new_things)
end
