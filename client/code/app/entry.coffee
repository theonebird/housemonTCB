# This client-side code gets called first by SocketStream and must always exist
routes = require '/routes'

# Make 'ss' available to all modules and the browser console
window.ss = require 'socketstream'

ss.server.on 'disconnect', ->
  console.info 'Connection down :-('

ss.server.on 'reconnect', ->
  console.info 'Connection back up :-)'
  # force full reload to re-establish all model links
  window.location.reload true

ss.server.once 'ready', ->
  jQuery ->
    console.info 'app ready'
    ss.rpc 'host.api', 'fetch', (models) ->
      console.info 'models fetched:', _.keys models
      routes.loadStandardModules models
