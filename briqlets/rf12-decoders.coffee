exports.info =
  name: 'rf12decoders'
  description: 'Some simple decoders for RF12 packets'
  inputs: [
    name: 'Packet source'
    type: 'briq'
  ]
  
events = require 'eventemitter2'
nodeMap = require './nodeMap'
state = require '../server/state'
models = state.fetch()

time2watt = (t) ->
  if t > 60000
    t = 1000 * (t - 60000)
  Math.floor(18000000 / t) if t > 0

decoders =

  radioBlip: (raw, cb) ->
    count = raw.readUInt32LE(1)
    cb
      ping: count 
      age: Math.floor(count / (86400 / 64))
  
  homePower: (raw, cb) ->
    ints = (raw.readUInt16LE(1+2*i, true) for i in [0..5])
    cb
      c1: ints[0]
      p1: time2watt ints[1]
      c2: ints[2]
      p2: time2watt ints[3]
      c3: ints[4]
      p3: time2watt ints[5]
  
  smaRelay: (raw, cb) ->
    ints = (raw.readUInt16LE(1+2*i, true) for i in [0..6])
    cb
      yield: ints[0]
      total: ints[1]
      acw: ints[2]
      dcv1: ints[3]
      dcv2: ints[4]
      dcw1: ints[5]
      dcw2: ints[6]

  roomNode: (raw, cb) ->
    t = raw.readUInt16LE(3, true) & 0x3FF
    cb
      light: raw[1]
      humi: raw[2] >> 1
      moved: raw[2] & 1
      temp: if t < 0x200 then t else 0x200 - t

  # see http://jeelabs.org/2012/12/01/extracting-data-from-p1-packets/
  p1scanner: (raw, cb) ->
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

class Decoder extends events.EventEmitter2
  constructor: (args...) ->
    # have to wait for the proper installed briqlet before hooking up to it
    # TODO: very messy, args are in the wrong format, this timing dep sucks
    
    listener = (key, value, oldVal) ->
      if key is args.join(':') and value.emitter
        state.off 'set.installed', listener
        feed = value.emitter
      
        feed.on 'announce', (ainfo) ->
          ainfo.swid = ainfo.buffer.readUInt16LE(3)
          ainfo.name = nodeMap[ainfo.swid]
          console.info 'swid', ainfo.swid, ainfo.name, ainfo.buffer
      
        feed.on 'packet', (packet, ainfo) ->
          # use announcer info if present, else look for own static mapping
          name = ainfo?.name or
                  nodeMap[packet.band]?[packet.group]?[packet.id]
          decoder = decoders[name]
          if decoder 
            decoder packet.buffer, (info) ->
              console.log 'decoded', info
          else
            console.info 'raw', packet
                
    state.on 'set.installed', listener

exports.factory = Decoder
