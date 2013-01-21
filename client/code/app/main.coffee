# Main app setup and controller, this all hooks into AngularJS
# Everything in this top-level scope is available in all the other scopes
routes = require '/routes'
# classes = '/classes'

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
        
      $scope.collection = (name) ->
        unless $scope[name]
          # create an array and add some object attributes to it
          # this way the extra attributes won't be enumerated
          coll = $scope[name] = []
          coll.name = name # TODO: could stay in local scope
          coll.byId = {}
          coll.find = (value) -> _.find @, (obj) -> obj.key is value
          coll.store = (obj) -> ss.rpc 'host.api', 'store', @name, obj, ->
        $scope[name]
    
      storeOne = (name, obj, cb) ->
        coll = $scope.collection name
        oldObj = coll.byId[obj.id]
        if oldObj 
          oldPos = coll.indexOf(oldObj)
        if obj.key
          coll.byId[obj.id] = obj
          if oldObj
            coll[oldPos] = obj
          else
            coll.push obj
          cb? "set.#{name}", obj, oldObj
          # cb? 'set', name, obj, oldObj
        else
          delete coll[obj.id]
          if oldObj
            coll.splice oldPos, 1
          cb? "unset.#{name}", oldObj
          # cb? 'unset', name, oldObj
          if coll.length is 0
            delete $scope[name]
          
      # the server emits ss-store events to update each of the client models
      $scope.$on 'ss-store', (event, [name, obj]) ->
        storeOne name, obj, (args...) ->
          $scope.$broadcast args...

      # postpone RPC's until the app is ready for use
      ss.server.once 'ready', ->
        # get initial models from the server
        ss.rpc 'host.api', 'fetch', (models) ->
          for name,coll of models
            # use storeOne to get all the collection details right
            storeOne name, v  for k,v of coll
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
