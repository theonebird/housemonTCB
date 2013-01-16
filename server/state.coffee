# Manage the state which is shared with all clients
events = require 'eventemitter2'

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
  
state.fetch = ->
  models
  
state.store = (hash, key, value) ->
  collection = models[hash] ? {}
  oldValue = collection[key]
  unless value is oldValue 
    if value?
      collection[key] = value
      state.emit "set.#{hash}", key, value, oldValue
    else if oldValue?
      delete collection[key]
      state.emit "unset.#{hash}", key, oldValue
    models[hash] = collection
    state.emit 'store', hash, key, value
    
state.setupStorage = (config, cb) ->
  redis = require 'redis'
  client = redis.createClient(config.port, config.host, config)
  
  state.on 'store', (hash, key, value) ->
    if value?
      client.hmset hash, key, JSON.stringify value
    else
      client.hdel hash, key

  client.select config.db, ->
    # TODO: needs a more generic "restore everything we need" approach
    collections = ['installed', 'readings']
    counter = collections.length
    for coll in collections
      client.hgetall coll, (err, res) ->
        throw err  if err
        for k,v of res
          state.store coll, k, JSON.parse(v)
        # TODO: mess async sequencer
        if --counter == 0
          cb?()

module.exports = state
