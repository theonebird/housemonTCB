# These functions can be called from the client as: rpc 'host.NAME', ...
exports.actions = (req, res, ss) ->

  # rpc client access to the server-side ss object
  # FIXME: probably not safe enough for untrusted clients
  api: (cmd, args...) ->
    res ss[cmd](args...)
