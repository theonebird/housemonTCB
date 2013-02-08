exports.info =
  name: 'drivers'
  description: 'Driver collection'
  
nodeMap = require './nodeMap'
state = require '../server/state'
fs = require 'fs'

announcers = nodeMap.announcers or {}
rf12nodes = nodeMap.rf12nodes or {}
drivers = nodeMap.drivers or {}
decoders = {}

announceListener = (ainfo) ->
  ainfo.swid = ainfo.buffer.readUInt16LE(3)
  ainfo.name = announcers[ainfo.swid]
  console.info 'swid', ainfo.swid, ainfo.name, ainfo.buffer

packetListener = (packet, ainfo) ->
  # use announcer info if present, else look for own static mapping
  name = ainfo?.name or rf12nodes[packet.band]?[packet.group]?[packet.id]
  if name
    decoder = decoders[name]
    if decoder
      decoder.decode packet.buffer, (info) ->
        if info.tag
          name = info.tag
          delete info.tag
        info.key = "RF12:#{packet.band}:#{packet.group}:#{packet.id}.#{name}"
        now = Date.now()
        time = packet.time or now
        if time < 86400000
          time += now - now % 86400000
        info.time = time
        state.store 'readings', info
  else
    console.info 'raw', packet
        
loadAllDecoders = ->
  fs.readdir './drivers', (err, files) ->
    throw err  if err
    for f in files
      f = f.replace /\..*/, ''
      obj = require "../drivers/#{f}"
      if obj.descriptions
        if obj.descriptions.length # TODO real array check
          # demultiplexing driver, with multiple descriptions
          drivers[d] = obj[d]  for d in obj.descriptions
        else
          drivers[f] = obj.descriptions
      if obj.announcer
        announcers[obj.announcer] = f
      if obj.decode
        decoders[f] = obj

exports.factory = class
  
  constructor: ->
    loadAllDecoders()
    state.on 'rf12.announce', announceListener
    state.on 'rf12.packet', packetListener
        
  destroy: ->
    state.off 'rf12.announce', announceListener
    state.off 'rf12.packet', packetListener
