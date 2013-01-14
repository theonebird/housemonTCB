# Main app controller, this hooks into AngularJS
# Everything in this top-level scope is available in all the other scopes

routes = require '/routes'

exports.controllers = 

  MainCtrl: [
    '$scope','pubsub','rpc',
    ($scope, pubsub, rpc) ->
    
      $scope.routes = routes
    
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
          
      # postpone RPC's until the app is ready for use
      ss.server.on 'ready', ->
      
        # get initial models from the server
        ss.rpc 'host.api', 'fetch', (models) ->
          $scope[k] = v  for k,v of models
          console.info "models fetched: #{Object.keys(models)}"
  ]
