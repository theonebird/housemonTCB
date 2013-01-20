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

# primary key lookup to id, issue a new id if it doesn't exist
idOf = (name, key, cb) ->
  db.hget "#{name}:ids", key, (err, id)->
    throw err  if err
    if id
      cb id
    else
      db.hincrby 'ids', name, 1, (err, id) ->
        throw err  if err
        cb id
      
state = new events.EventEmitter2

# state.onAny (arg) ->
#   console.info '>', @event, arg
  
state.fetch = (cb) ->
  cb models

state.store = (name, id, value, cb) ->
  collection = models[name] ? {}
  oldValue = collection[id]
  unless value is oldValue 
    if value?
      collection[id] = value
      state.emit "set.#{name}", id, value, oldValue
    else if oldValue?
      delete collection[id]
      state.emit "unset.#{name}", id, oldValue
    models[name] = collection
    state.emit 'store', name, id, value
  cb?()
    
state.setupStorage = (collections, config) ->
  db = redis.createClient(config.port, config.host, config)
  
  state.on 'store', (name, key, obj) ->
    idOf name, key, (id) ->
      if obj?
        obj.id = id
        db.hmset name, id, JSON.stringify(obj)
        db.hmset "#{name}:ids", key, id
      else
        db.srem name, xid
        db.hmdel "#{name}:ids", key, xid

  db.select config.db, ->
    loadData = (name) ->
      db.hgetall "#{name}:ids", (err, ids) ->
        throw err  if err
        db.hgetall name, (err, res) ->        
          for k,v of ids
            state.store name, k, JSON.parse(res[v])
      
    # loaded asynchronously, would need async module for completion callback
    loadData name  for name in collections

module.exports = state
