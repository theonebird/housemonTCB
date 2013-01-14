# This client-side code gets called first by SocketStream and must always exist

# Make 'ss' available to all modules and the browser console
window.ss = require 'socketstream'

ss.server.on 'disconnect', ->
  console.info 'Connection down :-('

ss.server.on 'reconnect', ->
  console.info 'Connection back up :-)'
  # force full reload to re-establish all model links
  window.location.reload true

myApp = angular.module 'myApp', []

# set up all NG modules, the '/wrappers' entry must always be the first one
for path in ['/wrappers', '/main', '/home', '/admin', '/sandbox']
  module = require path
  myApp.config module.config  if module.config
  myApp.filter name, def  for name,def of module.filters
  myApp.factory name, def  for name,def of module.services
  myApp.directive name, def  for name,def of module.directives
  myApp.controller name, def  for name,def of module.controllers

ss.server.on 'ready', ->
  jQuery ->
    console.info 'app ready'
    ss.rpc 'host.api','log','client app is ready', ->
