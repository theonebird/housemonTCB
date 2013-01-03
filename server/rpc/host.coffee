# These functions can be called from the client as: rpc 'host.NAME', ...

exports.actions = (req, res, ss) ->
  
  # this example function returns some information about the server
  platform: () ->
    res process.platform