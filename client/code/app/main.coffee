# Main app setup and controller, this all hooks into AngularJS
# Everything in this top-level scope is available in all the other scopes
routes = require '/routes'
# classes = '/classes'

# TODO: instantiate all incoming hashes as objects?
#
# class RemoteObject
#   save: (key) ->
#     ss.store @remoteName, @
# 
# classes = 
#   briqs: class Briq extends RemoteObject
#   bobs: class Bobs extends RemoteObject 
#   readings: class Readings extends RemoteObject

exports.config = [
  '$routeProvider','$locationProvider',
  ($routeProvider, $locationProvider) ->
    
    for r in routes
      if r.title
        r.route ?= "/#{r.title.toLowerCase()}"
        r.templateUrl ?= "#{r.title.toLowerCase()}.html"
        $routeProvider.when r.route, r
    $routeProvider.otherwise
      redirectTo: '/'

    $locationProvider.html5Mode true
]

exports.controllers = 
  MainCtrl: [
    '$scope','pubsub','rpc',
    ($scope, pubsub, rpc) ->
    
      $scope.routes = routes
      
      # pick up the 'ss-tick' events sent from server/launch
      $scope.tick = '?'
      $scope.$on 'ss-tick', (event, msg) ->
        $scope.tick = msg
    
      $scope.store = (hash, obj) ->
        ss.rpc 'host.api', 'store', hash, obj, ->

      # the server emits ss-store events to update each of the client models
      $scope.$on 'ss-store', (event, [hash, obj]) ->
        collection = $scope[hash] ?= {}
        oldObj = collection[obj.id]
        if obj.key
          collection[obj.id] = obj
          $scope.$broadcast "set.#{hash}", obj, oldObj
          # $scope.$broadcast 'set', hash, obj, oldObj
        else
          delete collection[obj.id]
          $scope.$broadcast "unset.#{hash}", oldObj
          # $scope.$broadcast 'unset', hash, oldObj

      # postpone RPC's until the app is ready for use
      ss.server.once 'ready', ->
        # get initial models from the server
        ss.rpc 'host.api', 'fetch', (models) ->
          $scope[k] = v  for k,v of models
          console.info 'models fetched:', _.keys models
          $scope.ready = true
  ]

# Credit to https://github.com/polidore/ss-angular for ss rpc/pubsub wrapping
# Thx also to https://github.com/americanyak/ss-angular-demo for the demo code

exports.services =
  
  rpc: [
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

  pubsub: [
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
