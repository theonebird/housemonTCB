# Main app setup and controller, this all hooks into AngularJS
# Everything in this top-level scope is available in all the other scopes
routes = require '/routes'

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
    
      $scope.store = (hash, key, value) ->
        ss.rpc 'host.api', 'store', hash, key, value, ->

      # the server emits ss-store events to update each of the client models
      $scope.$on 'ss-store', (event, msg) ->
        [hash,key,value] = msg
        collection = $scope[hash] ? {}
        oldValue = collection[key]
        if value?
          collection[key] = value
          $scope.$broadcast "set.#{hash}", key, value, oldValue
        else
          delete collection[key]
          $scope.$broadcast "unset.#{hash}", key, oldValue
        $scope[hash] = collection

      # postpone RPC's until the app is ready for use
      ss.server.once 'ready', ->
        # get initial models from the server
        ss.rpc 'host.api', 'fetch', (models) ->
          $scope[k] = v  for k,v of models
          console.info "models fetched: #{Object.keys(models)}"          
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
