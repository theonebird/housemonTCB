# This automatically gets called first by SocketStream and must always exist

# Make 'ss' available to all modules and the browser console
window.ss = require 'socketstream'

ss.server.on 'disconnect', ->
  console.info 'Connection down :-('

ss.server.on 'reconnect', ->
  console.info 'Connection back up :-)'
  # force full reload to re-establish all model links
  window.location.reload true

myApp = angular.module 'myApp', []

myApp.config [
  '$routeProvider','$locationProvider',
  ($routeProvider, $locationProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'home.html'
      .when '/admin',
        templateUrl: 'admin.html'
      .when '/sandbox',
        templateUrl: 'sandbox.html'
      .otherwise
        redirectTo: '/'
    $locationProvider.html5Mode true
]

for name, service of require '/services'
  myApp.factory name, service
  
for name, controller of require '/controllers'
  myApp.controller name, controller

ss.server.on 'ready', ->
  jQuery ->
    require '/app'
