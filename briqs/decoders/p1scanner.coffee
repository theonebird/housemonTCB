module.exports =

  announcer: 15

  descriptions:
    use1:
      title: 'Elec usage - low'
      unit: 'kWh'
      scale: 3
      min: 0
    use2:
      title: 'Elec usage - high'
      unit: 'kWh'
      scale: 3
      min: 0
    gen1:
      title: 'Elec return - low'
      unit: 'kWh'
      scale: 3
      min: 0
    gen2:
      title: 'Elec return - high'
      unit: 'kWh'
      scale: 3
      min: 0
    mode:
      title: 'Elec tariff'
    usew:
      title: 'Elec usage now'
      unit: 'W'
      scale: -1
      min: 0
      max: 15000
    genw:
      title: 'Elec return now'
      unit: 'W'
      scale: -1
      min: 0
      max: 10000
    gas:
      title: 'Gas total'
      unit: 'm3'
      scale: 3
      min: 0

  feed: 'rf12.packet'

  decode: (raw, cb) ->
    # see http://jeelabs.org/2012/12/01/extracting-data-from-p1-packets/
    ints = []
    v = 0
    for i in [1...raw.length]
      b = raw[i]
      v = (v << 7) + (b & 0x7F)
      if b & 0x80
        ints.push v
        v = 0
    if ints[0] is 1
      cb
        use1: ints[1]
        use2: ints[2]
        gen1: ints[3]
        gen2: ints[4]
        mode: ints[5]
        usew: ints[6]
        genw: ints[7]
        gas: ints[9]
