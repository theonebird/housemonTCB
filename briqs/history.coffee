exports.info =
  name: 'history'
  description: 'Historical data storage (full details of the last few days)'
  rpcs: ['rawRange']
  
state = require '../server/state'
local = require '../local'
redis = require 'redis'

HISTSLOT = 32 * 3600 * 1000 # one day, in milliseconds

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
    slot = obj.time / HISTSLOT | 0
    # use a cache to avoid needless redundant saves
    unless slotCache[id] is slot
      db.sadd 'hist:slots', slot, ->
      db.sadd "hist:slot:#{slot}", id, ->
      slotCache[id] = slot
    # the score is milliseconds since the start of the slot
    db.zadd "hist:#{id}:#{slot}", obj.time % HISTSLOT, obj.origval, ->

# callable from client as rpc
exports.rawRange = (key, from, to, cb) ->
  from += Date.now()  if from < 0
  slot = from / HISTSLOT | 0
  id = keyMap[key]
  if id?
    if slotCache[id] >= slot
      slot = slotCache[id] # TODO temporary hack
      tag = "hist:#{id}:#{slot}"
      # TODO end of range is not honoured yet, always until last for now
      # TODO also not correct when wrapping across multiple slots
      db.zrangebyscore tag, from % HISTSLOT, '+inf', 'withscores', (err, res) ->
        cb err, [slot * HISTSLOT, res]
      return
  cb null, []

exports.factory = class
  constructor: -> state.on 'set.status', storeValue
  destroy: -> state.off 'set.status', storeValue
