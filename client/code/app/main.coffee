# Main app definitions, these all hook into AngularJS

# Routes which have a title set will appear in the main menu
# The order in the meny is the order in the reoutes array
exports.routes = routes = [
  { title: 'Home', path: '/' }
  { title: 'Admin', path: '/admin' }
  { title: 'Sandbox', path: '/sandbox' }
]

exports.controllers = 

  AppCtrl: [
    '$scope','pubsub','rpc',
    ($scope, pubsub, rpc) ->
    
      # pick up the 'ss-tick' events sent from server/startup
      $scope.tick = '?'
      $scope.$on 'ss-tick', (event, msg) ->
        $scope.tick = msg
          
      $scope.routes = routes
    
      $scope.model = {}    

      idsOf = (hash) ->
        Object.keys($scope.model[hash])

      $scope.$on 'ss-store', (event, msg) ->
        [hash,key,value] = msg
        collection = $scope.model[hash] or {}
        if value?
          prevValue = collection[key]
          collection[key] = value
        else
          delete collection[key]
        $scope.model[hash] = collection
        return if prevValue?
        # update collections in $scope when keys are added or removed
        # TODO: incrementally add or remove one item only
        $scope[hash] ?= []
        if value?
          $scope[hash].push key
        else
          index = $scope[hash].indexOf(key)
          $scope[hash].splice(index, 1)
    
      # RPC isn't ready for use yet, so we must postpone these calls slightly
      ss.server.on 'ready', ->
      
        # example RPC call, the returned result will adjust the scope
        ss.rpc 'host.platform', (name) ->
          $scope.platform = name

        # get initial model from the server
        ss.rpc 'host.api', 'fetch', (model) ->
          $scope.model = model
          $scope.appName = model.package.exactName
          console.info 'model fetched'
  ]
  
  AdminCtrl: [
    '$scope','rpc',
    ($scope, rpc) ->

      store = (hash, key, value) ->
        ss.rpc 'host.api', 'store', hash, key, value, ->

      $scope.selectBriq = (id) ->
        $scope.id = id
        for input in id.info.inputs or []
          input.value = null
      
      $scope.installBriq = ->
        briq = $scope.id.info
        key = [briq.name]
        for input in briq.inputs or []
          key.push input.value or input.default
        store 'installed', key.join(':'), briq.name
      
      $scope.uninstallBriq = (id) ->
        $scope.id = null
        store 'installed', id
  ]
