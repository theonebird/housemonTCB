# Manage the state which is shared with all clients

events = require 'events'

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

state = new events.EventEmitter
  
state.fetch = ->
  models
  
state.store = (hash, key, value) ->
  console.info 'store', hash, key, value?
  collection = models[hash] or {}
  unless value is collection[key]
    if value?
      collection[key] = value
    else
      delete collection[key]
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
    client.hgetall 'installed', (err, res) ->
      throw err  if err
      for k,v of res
        state.store 'installed', k, JSON.parse(v)
      cb?()

module.exports = state
