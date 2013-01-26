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
      
# fetch and store implement a simple persistent and sharable key-value store
# "fetch" returnss everything, "store" saves & propagates keyed object changes
# if the object has no "id", a new one will be assigned
# if the object has no "key", the old copy will be deleted

module.exports = state = new events.EventEmitter2

# state.onAny (args...) ->
#   console.info '>', @event, args...
  
# make sure this object has an id, issue a new one via redis if needed
# TODO: could avoid async with a scan for highest ID on node.js startup
setId = (name, obj, cb) ->
  if obj.id
    # noting to do
    cb obj.id
  else if obj.key?
    db.hget "#{name}:ids", obj.key, (err, id)->
      throw err  if err
      if id
        # there is an existing entry with this key, use it
        cb obj.id = id
      else
        db.hincrby 'ids', name, 1, (err, id) ->
          throw err  if err
          # issue and assign a new id
          cb obj.id = id

state.fetch = (cb) ->
  cb models

state.store = (name, obj, cb) ->
  setId name, obj, (id) ->
    collection = models[name] ? {}
    oldObj = collection[id]
    unless obj is oldObj # TODO: is this comparison useful?
      if obj.key?
        collection[id] = obj
        state.emit "set.#{name}", obj, oldObj
      else if oldObj?
        delete collection[id]
        state.emit "unset.#{name}", oldObj
      models[name] = collection
      state.emit 'store', name, obj
    cb?()
    
state.setupStorage = (collections, config) ->
  db = redis.createClient(config.port, config.host, config)
  
  state.on 'store', (name, obj) ->
    if obj.key?
      db.hset name, obj.id, JSON.stringify(obj)
      db.hset "#{name}:ids", obj.key, obj.id
    else
      # key is gone, need to fetch original to recover it
      db.hget name, obj.id, (err, res) ->
        throw err  if err
        obj = JSON.parse res
        db.hdel name, obj.id
        db.hdel "#{name}:ids", obj.key

  db.select config.db, ->
    loadData = (name) ->
      db.hgetall name, (err, ids) ->
        for k,v of ids
          state.store name, JSON.parse(v)
    # loaded asynchronously, will need async module for completion callback
    loadData name  for name in collections
