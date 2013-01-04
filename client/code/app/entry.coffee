# This automatically gets called first by SocketStream and must always exist

# Make 'ss' available to all modules and the browser console
window.ss = require 'socketstream'

ss.server.on 'disconnect', ->
  console.log 'Connection down :-('

ss.server.on 'reconnect', ->
  console.log 'Connection back up :-)'
  # force full reload to re-establish all model links
  # FIXME: this is a bit drastic, it loses all client state
  window.location.reload true

require 'ssAngular'
require '/controllers'

ss.server.on 'ready', ->
  jQuery ->
    require '/app'
