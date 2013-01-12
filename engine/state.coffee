# Manage the state which is shared with all clients

events = require 'events'

# set up central data model
model = 
  package: require '../package'

# fetch, idsOf, and store implement a simple distributed key-value store

state = new events.EventEmitter
  
state.fetch = () ->
  model
  
state.idsOf = (group) ->
  pre = "#{group}:"
  len = pre.length
  (id for id of model when id.slice(0, len) is pre)

state.store = (key, value) ->
  console.info 'store', key, value?
  unless value is model[key]
    if value?
      model[key] = value
    else
      delete model[key]
    state.emit 'store', key, value
    
state.setupStorage = (db) ->
  redis = require 'redis'
  client = redis.createClient()
  client.select db
  state.on 'store', (key, value) ->
    client.set key, JSON.stringify value

module.exports = state
