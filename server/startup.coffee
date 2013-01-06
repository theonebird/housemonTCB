# loaded from main startup file

briqs = require './briqs'

model = {}

module.exports = (ss) ->
  
  # fetch, idsOf, and store implement a simple distributed key-value store
  # these are registered as ss.api for server-wide use
  
  fetch = () ->
    console.log 'fetch', Object.keys(model).length
    model
  
  idsOf = (group) ->
    pre = "#{group}:"
    len = pre.length
    result = (id for id of model when id.slice(0, len) is pre)
    console.log 'idsOf', group, result 
    result

  store = (key, value) ->
    console.log 'store', key, value?
    unless value is model[key]
      if value?
        model[key] = value
      else
        delete model[key]
      ss.api.publish.all 'ss-store', [key, value]

  # ss.api.add 'model', model
  ss.api.add 'fetch', fetch
  ss.api.add 'idsOf', idsOf
  ss.api.add 'store', store

  # this event is periodically pushed to the clients to make them, eh, "tick"
  setInterval ->
    ss.api.publish.all 'ss-tick', new Date
  , 1000

  # briqs are auto-loaded from the "briqs" directory
  briqs.loadAll()
