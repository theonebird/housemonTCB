module.exports = (ss) ->
  
  # this event gets pushed to the clients
  setInterval ->
    ss.api.publish.all 'ss-tick', new Date
  , 1000
