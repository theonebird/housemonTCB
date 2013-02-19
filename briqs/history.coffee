exports.info =
  name: 'history'
  description: 'Historical data storage (full details of the last few days)'
  rpcs: ['rawRange']
  
state = require '../server/state'
local = require '../local'
redis = require 'redis'

keyMap = {}
lastId = 0

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
    db.zadd "hist:#{keyMap[key]}", obj.time, obj.origval, ->

# callable from client as rpc
exports.rawRange = (key, from, to, cb) ->
  now = Date.now()
  from += now  if from < 0
  to += now  if to <= 0
  id = keyMap[key]
  if id? and dbReady
    db.zrangebyscore "hist:#{id}", from, to, 'withscores', cb
  else
    cb null, []

cronTask = (minutes) ->
  if minutes is 55
    console.log 'history cleanup time!'

exports.factory = class
  constructor: ->
    state.on 'set.status', storeValue
    state.on 'minutes', cronTask
  destroy: ->
    state.off 'set.status', storeValue
    state.off 'minutes', cronTask
