exports.info =
  name: 'test-packets'
  description: 'RF12 test data generator'
  # needs: ['jeemon-log-parser']

parser = require '../jeemon-log-parser'
fs = require 'fs'
zlib = require 'zlib'
gunzip = zlib.createGunzip()

class Tester extends parser
  constructor: ->
    log = []

    stream = fs.createReadStream("#{__dirname}/20121130.txt.gz").pipe(gunzip)
    @stream = stream
    
    stream.on 'end', ->
      console.info "#{log.length} test packets loaded"
      
    parser = new parser.factory
    parser.on 'packet', (packet) ->
      log.push packet

    parser.parseStream stream 

  # FIXME: need a way to clean up, currently re-open fails
  destroy: () ->

exports.factory = Tester
