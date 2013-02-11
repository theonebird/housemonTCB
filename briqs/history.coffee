exports.info =
  name: 'history'
  description: 'Historical data storage'
  
state = require '../server/state'
local = require '../local'
fs = require 'fs'
redis = require 'redis'

config = local.redisConfig
db = redis.createClient config.port, config.host, config
dbReady = false
db.select config.db, ->
  dbReady = true

HISTORY_PATH = './histdata'
HISTREQ_PATH = '../histdata'
HISTMAP_PATH = './histdata/index.json'
fs.mkdir HISTORY_PATH

DURATION = 24 * 3600 * 1000 # one day, in milliseconds

if fs.existsSync HISTMAP_PATH
  keyMap = require HISTREQ_PATH
else
  keyMap = _: 0 # sequence number

keyToId = (key) ->
  unless keyMap[key]?
    keyMap[key] = ++keyMap._
    fs.writeFileSync HISTMAP_PATH, JSON.stringify keyMap, null, 2
  keyMap[key]

histTag = (key, time) ->
  id = ('000' + keyToId key).slice -4
  slot = Math.floor time / DURATION
  "#{id}-#{slot}"

storeValue = (obj, oldObj) ->
  if obj and dbReady
    tag =  histTag obj.key, obj.time
    db.sadd 'hist:tags', tag, ->
    # score is milliseconds since the start of the slot
    db.zadd "hist:#{tag}", obj.time % DURATION, obj.origval, ->

exports.factory = class

  constructor: ->
    state.on 'set.status', storeValue

  destroy: ->
    state.off 'set.status', storeValue
