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

myApp = angular.module 'myApp', []

# set up all NG modules, the '/main' entry must always be the first one
# this now uses the routes list to figure out what files to load
for r in routes
  loadPath = r.load or (r.title and "/#{r.title.toLowerCase()}")
  if loadPath
    module = require loadPath
    myApp.config module.config  if module.config
    myApp.filter name, def  for name,def of module.filters
    myApp.factory name, def  for name,def of module.services
    myApp.directive name, def  for name,def of module.directives
    myApp.controller name, def  for name,def of module.controllers

ss.server.once 'ready', ->
  jQuery ->
    console.info 'app ready'
