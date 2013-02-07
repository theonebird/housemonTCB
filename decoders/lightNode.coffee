module.exports =

  announcer: 19

  descriptions:
    value:
      title: 'Light level'
      unit: '%'
      min: 0
      max: 255
      factor: 100 / 255
      scale: 0

  feed: 'rf12.packet'

  decode: (raw, cb) ->
    cb
      value: raw[1]
