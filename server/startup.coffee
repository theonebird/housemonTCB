features = require './model/features'

module.exports = (ss) ->
  
  # this event gets pushed to the clients
  setInterval ->
    ss.api.publish.all 'ss-tick', new Date
  , 1000

  # these modules are auto-loaded from the "features" directory
  features.loadAll()
