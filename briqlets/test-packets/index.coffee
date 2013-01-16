exports.info =
  name: 'test-packets'
  description: 'RF12 test data generator'
  # needs: ['jeemon-log-parser']

parser = require '../jeemon-log-parser'
fs = require 'fs'
zlib = require 'zlib'

class Tester extends parser.factory
  constructor: ->
    log = []
    @on 'packet', (packet) ->
      log.push packet

    stream = fs.createReadStream("#{__dirname}/20121130.txt.gz")
                  .pipe(zlib.createGunzip())
    stream.on 'end', ->
      console.info "#{log.length} test packets loaded"
      
    @parseStream stream 

exports.factory = Tester
