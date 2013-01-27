exports.info =
  name: 'jcw-collectd'
  description: 'Pick up incoming collectd reports via UDP'

# TODO: nesting logic to build up a nested object
#   see https://collectd.org/wiki/index.php/Binary_protocol

dgram = require 'dgram'
state = require '../server/state'

setupListener = (handler) ->
  listener = dgram.createSocket 'udp4'
  listener.bind 25826, '0.0.0.0'
  listener.addMembership('239.192.74.66')
  
  stringParts =
    0x0000: 'Host', 0x0002: 'Plugin', 0x0003: 'Plugin-inst'
    0x0004: 'Type', 0x0005: 'Type-inst', 0x0100: 'Message'
  numberParts =
    0x0001: 'Time', 0x0008: 'Time-hires', 0x0007: 'Interval'
    0x0009: 'Interval-hires', 0x0101: 'Severity'
  
  uintConv = (buf, offset) ->
    (buf.readUInt32BE(offset) << 32) | buf.readUInt32BE(offset + 4)
  sintConv = (buf, offset) ->
    (buf.readInt32BE(offset) << 32) | buf.readUInt32BE(offset + 4)
  dblConv = (buf, offset) ->
    buf.readDoubleLE(offset)
  
  valueConverters = [ uintConv, dblConv, sintConv, uintConv ]

  listener.on 'message', (msg, rinfo) ->
    console.log rinfo, Buffer.isBuffer(msg)
    offset = 0
    while offset  + 4 <= rinfo.size
      type = msg.readUInt16BE(offset)
      size = msg.readUInt16BE(offset + 2)
      data = msg.slice(offset + 4, offset + size)
      
      part = stringParts[type]
      if part
        value = data.toString('utf8', 0, size - 5)
      else
        part = numberParts[type]
        if part
          value = (data.readUInt32BE(0) << 32) + data.readUInt32BE(4)
        else if type == 0x0006
          part = '*'
          value = []
          count = data.readUInt16BE(0)
          for i in [0...count]
            code = data.readUInt8(2 + i)
            converter = valueConverters[code]
            if converter
              value.push converter(data, 2 + count + 8 * i)
          if value.length == 1
            value = value[0]
      offset += size
      
      if part
        handler type, part, value

  listener

debugHandler = (type, part, value) ->
  console.log type, part, value

levels = ['', '', '', '', '', '']

nestingHandler = (type, part, value) ->
    if type < 6
      levels[type] = value
      while ++type < 6
        levels[type] = ''
    else
      console.log (x for x in levels when x).join(' '), part, value
      #packet = (x for x in levels when x)
      #packet.push part, value
      #console.log packet
      # TODO state.emit 'collectd.packet', info, ainfo[info.id]

exports.factory = class
  
  constructor: ->
    @sock = setupListener nestingHandler

  destroy: ->
    @sock.close()
