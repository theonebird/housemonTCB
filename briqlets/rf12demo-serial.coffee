exports.info =
  name: 'rf12demo'
  description: 'Serial interface for a JeeNode running the RF12demo sketch'
  inputs: [
    name: 'Serial port'
    default: 'usb-AH01A0GD' # TODO: list choices with serialport.list
  ]
  # events: ['packet', 'data']
  # dependencies:
  #   'serialport': '*'

serialport = require 'serialport'

class RF12demo extends serialport.SerialPort
  
  constructor: (device) ->
    info = {}
    ainfo = {}
    
    # TODO: expand platform-specific shorthands, not just Mac
    device = device.replace /^usb-/, '/dev/tty.usbserial-'
    
    # construct the serial port object
    super device,
      baudrate: 57600
      parser: serialport.parsers.readline '\n'

    @on 'data', (data) =>
      data = data.slice(0, -1)  if data.slice(-1) is '\r'
      words = data.split ' '
      if words.shift() is 'OK' and info.recvid
        # TODO: conversion to ints can fail if the serial data is garbled
        info.id = words[0] & 0x1F
        info.buffer = new Buffer(words)
        if info.id is 0
          # announcer packet: remember this info for each node id
          aid = words[1] & 0x1F
          ainfo[aid] ?= {}
          ainfo[aid].buffer = info.buffer
          @emit 'announce', ainfo[aid]
        else
          # generate normal packet event, for decoders
          @emit 'packet', info, ainfo[info.id]
          console.log info
      else # look for config lines of the form: A i1* g5 @ 868 MHz
        match = /^ \w i(\d+)\*? g(\d+) @ (\d\d\d) MHz/.exec data
        if match
          @emit 'config', data, match.slice(1)
          info.recvid = parseInt(match[1])
          info.group = parseInt(match[2])
          info.band = parseInt(match[3])
        else
          # unrecognized input, usually a "?" line
          @emit 'other', data
          
  destroy: () -> @close()
        
exports.factory = RF12demo
