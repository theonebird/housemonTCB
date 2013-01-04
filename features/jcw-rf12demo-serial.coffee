serialport = require 'serialport'

exports.info =
  name: 'rf12demo'
  desc: 'Serial interface to a JeeNode/JeeLink running the RF12demo sketch'

exports.parameters = [
  name: 'serial port'
  default: '/dev/tty...'
]

class RF12demo extends serialport.SerialPort
  
  constructor: (device) ->
    @info = {}
    
    # construct the serial port object
    super device,
      baudrate: 57600
      parser: serialport.parsers.readline '\n'

    @on 'data', (data) ->
      data = data.slice(0, -1)  if data.slice(-1) is '\r'
      words = data.split ' '
      if words.shift() is 'OK' and @info.recvid
        # conversion to ints can fail if the serial data is garbled
        head = parseInt words.shift()
        @info.id = head & 0x1F
        @info.head = head 
        @info.buffer = new Buffer(words)
        # generate new events, on generic channel and on node-specific one
        @emit 'packet', @info
        @emit "node-#{@info.id}", @info
      else # look for config lines of the form: A i1* g5 @ 868 MHz
        match = /^ \w i(\d+)\*? g(\d+) @ (\d\d\d) MHz/.exec data
        if match
          @info.recvid = parseInt(match[1])
          @info.group = parseInt(match[2])
          @info.band = parseInt(match[3])
          @emit 'config', data, match.slice(1)
        else
          @emit 'other', data
        
exports.interface = RF12demo
