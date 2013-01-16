exports.info =
  name: 'test-packets'
  description: 'RF12 test data generator'
  # needs: ['jeemon-log-parser']

logParser = require '../jeemon-log-parser'
fs = require 'fs'
zlib = require 'zlib'
nodeMap = require '../nodeMap'
events = require 'eventemitter2'
_ = require 'underscore'

class Tester extends events.EventEmitter2
  constructor: ->
    logs = []
    
    # trigger a similated packet event, then delay and schedule the next on
    emitNext = (pos) =>
      @emit 'packet', logs[pos]
      # careful with wrapping, reuse the same log every day
      thisTick = logs[pos++].time
      nextTick = logs[pos]?.time
      unless nextTick?
        pos = 0
        nextTick = logs[0].time + 86400000
      # TODO: adjust for exact timing, current logic will graduallly drift
      setTimeout (-> emitNext pos), nextTick - thisTick
    
    stream = fs.createReadStream("#{__dirname}/20121130.txt.gz")
                  .pipe(zlib.createGunzip())

    stream.on 'end', ->
      console.info "#{logs.length} test packets loaded"
      # start the process by locating the next time slot to use
      times = _.pluck logs, 'time'
      pos = _.sortedIndex times, Date.now() % 86400000
      emitNext pos
      
    parser = new logParser.factory
    
    parser.on 'packet', (packet) ->
      # add static info to the packet, if the device is listed in nodeMap
      _.extend packet, nodeMap[packet.device]  unless packet.band
      logs.push packet

    parser.parseStream stream 

exports.factory = Tester
