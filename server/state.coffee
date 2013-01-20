# Manage the state which is shared with all clients
events = require 'eventemitter2'
redis = require 'redis'
db = null

# set up the central data models used by each client
models = 
  pkg: require '../package'
  local: require '../local'
  process: {}

# process info is useful in the client, but not all of it can be serialised
for k,v of process
  unless k in ['stdin', 'stdout', 'stderr', 'mainModule']
    unless typeof v is 'function'
      models.process[k] = v
      
# fetch and store implement a simple replicated key-value store
# when optionally tied to Redis, the store becomes persistent

state = new events.EventEmitter2

# state.onAny (arg) ->
#   console.info '>', @event, arg
  
state.fetch = (cb) ->
  cb models

state.newid = (key, cb) ->
  console.log 'newid',key,value
  db.hincr 'ids', key, (err, res) ->
    throw err  if err
    cb res
  
state.store = (key, id, value, cb) ->
  collection = models[key] ? {}
  oldValue = collection[id]
  unless value is oldValue 
    if value?
      collection[id] = value
      state.emit "set.#{key}", id, value, oldValue
    else if oldValue?
      delete collection[id]
      state.emit "unset.#{key}", id, oldValue
    models[key] = collection
    state.emit 'store', key, id, value
  cb?()
    
state.setupStorage = (collections, config) ->
  db = redis.createClient(config.port, config.host, config)
  
  state.on 'store', (key, id, value) ->
    if value?
      db.hmset key, id, JSON.stringify value
    else
      db.hdel key, id

  db.select config.db, ->
    loadData = (coll) ->
      db.hgetall coll, (err, res) ->
        throw err  if err
        for k,v of res
          state.store coll, k, JSON.parse(v)
      
    # loaded asynchronously, would need async module for completion callback
    loadData coll  for coll in collections

module.exports = state
