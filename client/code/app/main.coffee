# Main app setup and controller, this all hooks into AngularJS
# Everything in this top-level scope is available in all the other scopes
routes = require '/routes'
  
exports.config = [
  '$routeProvider','$locationProvider','$controllerProvider','$filterProvider'
  ($routeProvider, $locationProvider, $controllerProvider, $filterProvider) ->
    
    # pass the extra providers to the routes module for lazy registrations later
    routes.setup $routeProvider,
       controller: $controllerProvider
       filter: $filterProvider
       
    $locationProvider.html5Mode true
]

exports.controllers = 
  MainCtrl: [
    '$scope','$route','pubsub','rpc',
    ($scope, $route, pubsub, rpc) ->
    
      $scope.routes = routes.routes
      
      # update routes dynamically, based on installed briq objects
      # TODO - this is a hack, see http://jsfiddle.net/4zwdf/6/
      # http://stackoverflow.com/questions/12800084
      #  /how-do-i-get-angularjs-routes-to-display-partials-in-ie-7-and-8
      
      eachMenu = (obj, add) ->
        if obj
          briq = $scope.briqs.byId[obj.briq_id] # TODO: generic parent lookup
          for r in briq.info.menus or []
            routes.adjustScope $scope, $route, r, add
      
      # TODO: combine set.* and unset.* (in second case, pass new obj as undef)
      $scope.$on 'set.bobs', (event, obj, oldObj) ->
        eachMenu oldObj, off
        eachMenu obj, on
      $scope.$on 'unset.bobs', (event, obj) ->
        eachMenu obj, off
      
      # pick up the 'ss-tick' events sent from server/launch
      $scope.tick = '?'
      $scope.$on 'ss-tick', (event, msg) ->
        $scope.tick = msg
        
      $scope.collection = (name) ->
        unless $scope[name]
          # create an array and add some object attributes to it
          # this way the extra attributes won't be enumerated
          coll = $scope[name] = []
          # map ID's to objects
          coll.byId = {}
          # find object in collection, given its key
          coll.find = (value) -> _.find @, (obj) -> obj.key is value
          # store an object (must have either a key, an id, or both)
          coll.store = (obj) -> ss.rpc 'host.api', 'store', name, obj, ->
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
          $scope.$broadcast "set.#{name}", obj, oldObj
          # $scope.$broadcast 'set', name, obj, oldObj
        else
          delete coll[obj.id]
          if oldObj
            coll.splice oldPos, 1
          $scope.$broadcast "unset.#{name}", oldObj
          # $scope.$broadcast 'unset', name, oldObj
          if coll.length is 0
            delete $scope[name]
          
      # the server emits ss-store events to update each of the client models
      $scope.$on 'ss-store', (event, [name, obj]) ->
        storeOne name, obj

      # postpone RPC's until the app is ready for use
      ss.server.once 'ready', ->
        # get initial models from the server
        ss.rpc 'host.api', 'fetch', (models) ->
          $scope.$apply -> 
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
