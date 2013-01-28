exports.info =
  name: 'rf12ookrelay'
  description: 'Decoders for packets forwarded by the OOK relay'

nodeMap = require './nodeMap'
state = require '../server/state'

ookDecoderType = [ 'dcf', 'viso', 'emx', 'ksx', 'fsx',
                   'orsc', 'cres', 'kaku', 'xrf', 'hez', 'elro' ]

getBits = (raw, bitpos, count) ->
  (raw.readUInt32LE(bitpos>>3, true) >> (bitpos&7)) & ((1 << count) - 1)
  
ookDecoders =

  dcf: (raw, cb) ->
    bytes = (raw[i] for i in [0..5])
    cb
      tag: 'DCF77'
      date: ((2000 + bytes[0]) * 100 + bytes[1]) * 100 + bytes[2]
      tod: bytes[3] * 100 + bytes[4]
      dst: bytes[5]
    
  ksx: (raw, cb) ->
    s = getBits(raw, 0, 4)
    switch s
      when 1
        v = (getBits(raw, i*5, 4) for i in [0..7])
        t = 100 * v[4] + 10 * v[3] + v[2]
        cb
          tag: "S300-#{v[1]&7}"
          temp: if v[1] & 8 then -t else t
          humi: 100 * v[7] + 10 * v[6] + v[5]
      when 7
        v = (getBits(raw, i*5, 4) for i in [0..12])
        t = 100 * v[4] + 10 * v[3] + v[2]
        cb
          tag: 'KS300'
          temp: if v[1] & 0x08 then -t else t
          humi: 10 * v[6] + v[5]
          wind: 100 * v[9] + 10 * v[8] + v[7]
          rain: 256 * v[12] + 16 * v[11] + v[10]
          rnow: (v[1] >> 1) & 0x01
      else
        cb
          tag: "KSX-#{s}"
          hex: raw.toString('hex').toUpperCase()
          
  emx: (raw, cb) ->
    v = (getBits(raw, i*9, 8) for i in [0..8])
    cb
      tag: "EMX#{v[0]}-#{v[1]}"
      seq: v[2]
      avg: 12 * (256 * v[6] + v[5])
      max: 12 * (256 * v[8] + v[7])
      tot: 256 * v[4] + v[3]
      
  fsx: (raw, cb) ->
    # TODO decoding looks like it's still a bit off
    v = (getBits(raw, i*9, 8) for i in [0..4])
    console.log 'fsx',v
    house = 256 * v[1] + v[0]
    addr = 2 * v[2] + (v[3] >> 7)
    if v[3] & 32
      cb
        tag: "FS20X-#{house}:#{addr}"
        cmd: v[3] & 31
        ext: v[4]
    else
      cb
        tag: "FS20-#{house}:#{addr}"
        cmd: v[3] & 31

ookRelayDecoder = (raw, cb) ->
  offset = 1
  while offset < raw.length
    type = raw[offset] & 0x0F
    size = raw[offset] >> 4
    name = ookDecoderType[type]
    offset += 1
    seg = raw.slice(offset, offset+size)
    offset += size
    if ookDecoders[name]
      ookDecoders[name] seg, cb
    else
      cb
        tag: name
        hex: seg.toString('hex').toUpperCase()

# TODO this is very similar to code in rf12-decoders.coffee!
packetListener = (packet, ainfo) ->
  name = ainfo?.name or
          nodeMap[packet.band]?[packet.group]?[packet.id]
  if name is 'ookRelay2'
    ookRelayDecoder packet.buffer, (info) ->
      info.key = "RF12:#{packet.band}:#{packet.group}:#{packet.id}.#{info.tag}"
      delete info.tag
      now = Date.now()
      time = packet.time or now
      if time < 86400000
        time += now - now % 86400000
      info.time = time
      state.store 'readings', info
        
exports.factory = class
  
  constructor: ->
    state.on 'rf12.packet', packetListener

  destroy: ->
    state.off 'rf12.packet', packetListener
