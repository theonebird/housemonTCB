module.exports =

  announcer: 16

  descriptions:
    c1:
      title: 'Counter stove'
      unit: 'kWh'
      factor: 0.5
      scale: 3
      min: 0
      max: 33 # 65536 x 0.5W rollover
    c2:
      title: 'Counter solar'
      unit: 'kWh'
      factor: 0.5
      scale: 3
      min: 0
      max: 33 # 65536 x 0.5W rollover
    c3:
      title: 'Counter house'
      unit: 'kWh'
      factor: 0.5
      scale: 3
      min: 0
      max: 33 # 65536 x 0.5W rollover
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
    # only report values which have changed
    result = {}
    @prev ?= []
    if ints[0] isnt @prev[0]
      result.c1 = ints[0]
      result.p1 = time2watt ints[1]
    if ints[2] isnt @prev[2]
      result.c2 = ints[2]
      result.p2 = time2watt ints[3]
    if ints[4] isnt @prev[4]
      result.c3 = ints[4]
      result.p3 = time2watt ints[5]
    @prev = ints
    cb result

time2watt = (t) ->
  if t > 60000
    t = 1000 * (t - 60000)
  18000000 / t | 0  if t > 0
