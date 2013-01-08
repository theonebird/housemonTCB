# Manage the state which is shared with all clients

events = require 'events'

state = new events.EventEmitter

# set up central data model
model = 
  package: require '../package'

# fetch, idsOf, and store implement a simple distributed key-value store
# these are registered as ss.api for server-wide use
  
state.fetch = () ->
  console.info 'fetch', Object.keys(model).length
  model
  
state.idsOf = (group) ->
  pre = "#{group}:"
  len = pre.length
  result = (id for id of model when id.slice(0, len) is pre)
  console.info 'idsOf', group, result 
  result

state.store = (key, value) ->
  console.info 'store', key, value?
  unless value is model[key]
    if value?
      model[key] = value
    else
      delete model[key]
    state.emit 'store', key, value

module.exports = state
