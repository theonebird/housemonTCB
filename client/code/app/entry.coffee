# This client-side code gets called first by SocketStream and must always exist
main = require '/main'

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
    for route in main.routes
      if route.title and route.path
        route.templateUrl = "#{route.title.toLowerCase()}.html"
        $routeProvider.when route.path, route
    $routeProvider.otherwise
        redirectTo: '/'
    $locationProvider.html5Mode true
]

# Credit to https://github.com/polidore/ss-angular for ss rpc/pubsub wrapping
# Thx also to https://github.com/americanyak/ss-angular-demo for the demo code

myApp.factory 'rpc', [
  '$q','$rootScope',
  ($q, $rootScope) ->
    # call ss.rpc with 'demoRpc.foobar', args..., {callback}
    exec: (args...) ->
      deferred = $q.defer()
      ss.rpc args, (err, res) ->
        $rootScope.$apply (scope) ->
          return deferred.reject(err)  if err
          deferred.resolve res
      deferred.promise
    # use cache across controllers for client-side caching
    cache: {}
]

myApp.factory 'pubsub', [
  '$rootScope',
  ($rootScope) ->
    # override the $on function
    old$on = $rootScope.$on
    Object.getPrototypeOf($rootScope).$on = (name, listener) ->
      scope = this
      ss.event.on name, (message) ->
        scope.$apply (s) ->
          scope.$broadcast name, message
      # call angular's $on version
      old$on.call scope, name, listener
]

myApp.filter name, def  for name,def of main.filters
myApp.factory name, def  for name,def of main.services
myApp.directive name, def  for name,def of main.directives
myApp.controller name, def  for name,def of main.controllers

ss.server.on 'ready', ->
  jQuery ->
    console.info 'app ready'
    ss.rpc 'host.api','log','client app is ready', ->
