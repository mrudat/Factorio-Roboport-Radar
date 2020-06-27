if mods ['HighlyDerivative'] then
  local HighlyDerivative = require('__HighlyDerivative__/library')
  local MakeRadars = require('make-radars')

  HighlyDerivative.register_derivation('roboport', MakeRadars.make_radar)
end
