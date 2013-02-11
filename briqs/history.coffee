exports.info =
  name: 'history'
  description: 'Historical data storage'
  rpcs: ['rawRange']
  
state = require '../server/state'
local = require '../local'
redis = require 'redis'
fs = require 'fs'

SLOTSIZE = 24 * 3600 * 1000 # one day, in milliseconds

###
HISTORY_PATH = './histdata'
HISTREQ_PATH = '../histdata'
HISTMAP_PATH = './histdata/index.json'
fs.mkdir HISTORY_PATH

if fs.existsSync HISTMAP_PATH
  histMap = require HISTREQ_PATH
else
  histMap = _: 0 # sequence number
# fs.writeFileSync HISTMAP_PATH, JSON.stringify histMap, null, 2
###

keyMap = {}
lastId = 0
slotCache = {}

config = local.redisConfig
db = redis.createClient config.port, config.host, config
dbReady = false

db.select config.db, ->
  # restore keyMap from last info in hist:keys
  db.zrange 'hist:keys', 0, -1, 'withscores', (err, res) ->
    for i in [0...res.length] by 2
      lastId = parseInt res[i+1]
      keyMap[res[i]] = lastId
    dbReady = true # ready to accept new results

storeValue = (obj, oldObj) ->
  if obj and dbReady
    key = obj.key
    # map each key to a unique id, and remeber that mapping
    unless keyMap[key]?
      keyMap[key] = ++lastId
      db.zadd 'hist:keys', lastId, key, ->
    id = keyMap[key]
    slot = Math.floor obj.time / SLOTSIZE
    # use a cache to avoid needless redundant saves
    unless slotCache[id] is slot
      db.sadd 'hist:slots', slot, ->
      db.sadd "hist:slot:#{slot}", id, ->
      slotCache[id] = slot
    # the score is milliseconds since the start of the slot
    db.zadd "hist:#{id}:#{slot}", obj.time % SLOTSIZE, obj.origval, ->

# callable from client as rpc
exports.rawRange = (key, from, to, cb) ->
  from += Date.now()  if from < 0
  slot = Math.floor from / SLOTSIZE
  id = keyMap[key]
  if id?
    if slotCache[id] >= slot
      slot = slotCache[id] # TODO temporary hack
      tag = "hist:#{id}:#{slot}"
      # TODO end of range is not honoured yet, always until last for now
      #db.zrangebyscore tag, from % SLOTSIZE, '+inf', 'withscores', (a,b) ->
      db.zrangebyscore tag, 0, '+inf', 'withscores', (err, res) ->
        cb err, [slot, res]
      return
  cb null, []

exports.factory = class
  constructor: -> state.on 'set.status', storeValue
  destroy: -> state.off 'set.status', storeValue
