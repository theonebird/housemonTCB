# Manage the state which is shared with all clients

events = require 'events'

# set up central data model
model = 
  package: require '../package'
  local: require '../local'

# fetch, idsOf, and store implement a simple distributed key-value store

state = new events.EventEmitter
  
state.fetch = ->
  model
  
state.idsOf = (hash) ->
  collection = model[hash] or {}
  Object.keys(collection)

state.store = (hash, key, value) ->
  console.info 'store', hash, key, value?
  collection = model[hash] or {}
  unless value is collection[key]
    if value?
      collection[key] = value
    else
      delete collection[key]
    model[hash] = collection
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
