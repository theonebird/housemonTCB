exports.info =
  name: 'logger'
  description: 'Log incoming data to daily rotating text files'

state = require '../server/state'
fs = require 'fs'

LOGGER_PATH = './logger'
fs.mkdir LOGGER_PATH

dateFilename = (now) ->
  # construct the date value as 8 digits
  d = now.getUTCDate() + 100 *
     (now.getUTCMonth() + 1 + 100 *
      now.getUTCFullYear())
  # then massage it as a string to produce a file name
  "#{LOGGER_PATH}/#{d}.txt"

timeString = (now) ->
  # first construct the value as 10 digits
  digits = now.getUTCMilliseconds() + 1000 *
          (now.getUTCSeconds() + 100 *
          (now.getUTCMinutes() + 100 *
          (now.getUTCHours() + 100)))
  # then massage it as a string to get the punctuation right
  digits.toString().replace /.(..)(..)(..)(...)/, '$1:$2:$3.$4'

exports.factory = class
  
  logger: (type, device, data) ->
    now = new Date
    # L 01:02:03.537 usb-A40117UK OK 9 25 54 66 235 61 210 226 33 19
    log = "L #{timeString now} #{device} #{data}\n"
    if now.getUTCDate() is @currDate
      fs.write @fd, log
    else
      @currDate = now.getUTCDate() 
      fs.close @fd  if @fd?
      @fd = fs.openSync dateFilename(now), 'a'
      fs.write @fd, log

  constructor: ->
    @fd = null
    state.on 'incoming', @logger
          
  destroy: ->
    state.off 'incoming', @logger
    fs.close @fd  if @fd?
