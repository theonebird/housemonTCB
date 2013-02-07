time2watt = (t) ->
  if t > 60000
    t = 1000 * (t - 60000)
  Math.floor(18000000 / t) if t > 0

module.exports =

  announcer: 16

  descriptions:
    c1:
      title: 'Counter stove'
      unit: 'kWh'
      factor: 0.5
      scale: 3
      min: 0
      max: 33
    c2:
      title: 'Counter solar'
      unit: 'kWh'
      factor: 0.5
      scale: 3
      min: 0
      max: 33
    c3:
      title: 'Counter house'
      unit: 'kWh'
      factor: 0.5
      scale: 3
      min: 0
      max: 33
    p1:
      title: 'Usage stove'
      unit: 'W'
      scale: 1
      min: 0
      max: 10000
    p2:
      title: 'Production solar'
      unit: 'W'
      scale: 1
      min: 0
      max: 10000
    p3:
      title: 'Usage house'
      unit: 'W'
      scale: 1
      min: 0
      max: 10000

  feed: 'rf12.packet'

  decode: (raw, cb) ->
    ints = (raw.readUInt16LE(1+2*i, true) for i in [0..5])
    cb
      c1: ints[0]
      p1: time2watt ints[1]
      c2: ints[2]
      p2: time2watt ints[3]
      c3: ints[4]
      p3: time2watt ints[5]

