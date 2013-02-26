exports.info =
  name: 'rf12demo'
  description: 'Serial interface for a JeeNode running the RF12demo sketch'
  inputs: [
    name: 'Serial port'
    default: 'ttyUSB0' # TODO: list choices with serialport.list
  ]
  connections:
    packages:
      'serialport': '*'
    results:
      'rf12.announce': 'event'
      'rf12.packet': 'event'
      'rf12.config': 'event'
      'rf12.other': 'event'

serialport = require 'serialport'
state = require '../server/state'

class RF12demo extends serialport.SerialPort
  
  constructor: (device) ->
    info = {}
    ainfo = {}
    
    # support some platform-specific shorthands
    switch process.platform
      when 'darwin' then port = device.replace /^usb-/, '/dev/tty.usbserial-'
      when 'linux' then port = device.replace /^tty/, '/dev/tty'
      else port = device
    
    # FIXME open with delay to work around an FTDI serial kernel bug (!)
    setTimeout =>
      # construct the serial port object
      super port,
        baudrate: 57600
        parser: serialport.parsers.readline '\n'
    , 1000

    @on 'data', (data) ->
      data = data.slice(0, -1)  if data.slice(-1) is '\r'
      if data.length < 300 # ignore outrageously long lines of text
        # broadcast raw event for data logging
        state.emit 'incoming', 'rf12demo', device, data
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
            state.emit 'rf12.announce', ainfo[aid]
          else
            # generate normal packet event, for decoders
            state.emit 'rf12.packet', info, ainfo[info.id]
        else # look for config lines of the form: A i1* g5 @ 868 MHz
          match = /^ \w i(\d+)\*? g(\d+) @ (\d\d\d) MHz/.exec data
          if match
            state.emit 'rf12.config', data, match.slice(1)
            info.recvid = parseInt(match[1])
            info.group = parseInt(match[2])
            info.band = parseInt(match[3])
          else
            # unrecognized input, usually a "?" line
            state.emit 'rf12.other', data
          
  destroy: -> @close()
        
exports.factory = RF12demo
