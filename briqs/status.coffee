exports.info =
  name: 'status'
  description: 'Collect and show the current status'
  menus: [
    title: 'Status'
  ]
  # FIXME depends on readings
  
state = require '../server/state'

models = undefined
state.fetch (m) -> models = m

updateStatus = (obj, loc, info, param, value) ->
  if info.factor
    value *= info.factor
  if info.scale < 0
    value *= Math.pow 10, -info.scale
  else if info.scale >= 0
    value /= Math.pow 10, info.scale
    value = value.toFixed info.scale
  tag = obj.key.split '.'

  state.store 'status',
    key: "#{loc.title}/#{info.title}"
    location: loc.title
    parameter: info.title
    value: value
    unit: info.unit
    time: obj.time
    origin: tag[0]
    type: tag[1]
    name: param

findKey = (collection, key) ->
  for k,v of collection
    if key is v.key
      return v

processReading = (obj, oldObj) ->
  if obj
    [locName, other..., drvName] = obj.key.split '.'

    loc = findKey models.locations, locName
    unless loc
      loc = findKey models.locations, drvName
      drvName = drvName?.replace /-.*/, ''
    drv = findKey models.drivers, drvName

    if loc and drv
      for param, value of obj
        unless param in ['id','key']
          info = drv[param]
          updateStatus obj, loc, info, param, value  if info

exports.factory = class

  constructor: ->
    state.on 'set.readings', processReading

  destroy: ->
    state.off 'set.readings', processReading
