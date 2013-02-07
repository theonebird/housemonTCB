module.exports =

  announcer: 18

  descriptions:
    a0:
      title: 'Input 0'
      unit: 'V'
      factor: 3300 / 1023 / 32
      scale: 3
      min: 0
      max: 4
    a1:
      title: 'Input 1'
      unit: 'V'
      factor: 3300 / 1023 / 32
      scale: 3
      min: 0
      max: 4
    a2:
      title: 'Input 2'
      unit: 'V'
      factor: 3300 / 1023 / 32
      scale: 3
      min: 0
      max: 4
    a3:
      title: 'Input 3'
      unit: 'V'
      factor: 3.3 / 32
      scale: 3
      min: 0
      max: 4

  feed: 'rf12.packet'

  decode: (raw, cb) ->
    cb
      a0: raw.readUInt16LE(1, true)
      a1: raw.readUInt16LE(3, true)
      a2: raw.readUInt16LE(5, true)
      a3: raw.readUInt16LE(7, true)
      
