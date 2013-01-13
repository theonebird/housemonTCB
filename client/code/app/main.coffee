# Main app definitions, these all hook into AngularJS

# routes which have a title will appear in the main menu
# the order in the menu is the order in the reoutes array
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
    
      $scope.store = (hash, key, value) ->
        ss.rpc 'host.api', 'store', hash, key, value, ->

      # the server emits ss-store events to update each of the client models
      $scope.$on 'ss-store', (event, msg) ->
        [hash,key,value] = msg
        collection = $scope[hash] or {}
        if value?
          collection[key] = value
        else
          delete collection[key]
        $scope[hash] = collection
          
      $scope.routes = routes
    
      # postpone RPC's until the app is ready for use
      ss.server.on 'ready', ->
      
        # get initial models from the server
        ss.rpc 'host.api', 'fetch', (models) ->
          $scope[k] = v  for k,v of models
          console.info "models fetched: #{Object.keys(models)}"
  ]
  
  AdminCtrl: [
    '$scope','rpc',
    ($scope, rpc) ->

      $scope.selectBriq = (id) ->
        $scope.id = id
        for input in id.info.inputs or []
          input.value = null
      
      $scope.installBriq = ->
        info = $scope.id.info
        key = [info.name]
        for input in info.inputs or []
          key.push input.value or input.default
        $scope.store 'installed', key.join(':'), info.name
      
      $scope.uninstallBriq = (id) ->
        $scope.id = null
        $scope.store 'installed', id
  ]
