# Controller definitions

exports.AppCtrl = [
  '$scope','pubsub','rpc',
  ($scope, pubsub, rpc) ->
    
    # pick up the 'ss-tick' events sent from server/startup
    $scope.tick = '?'
    $scope.$on 'ss-tick', (event, msg) ->
      $scope.tick = msg
    
    # example RPC call, the returned result will adjust the scope
    ss.rpc 'host.platform', (name) ->
      $scope.platform = name
      
    $scope.routes = require '/routes'
    
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
    
    # get initial model from the server
    ss.rpc 'host.api', 'fetch', (model) ->
      $scope.model = model
      $scope.appName = model.package['exact-name']
      console.info 'model fetched'
]
  
exports.AdminCtrl = [
  '$scope','rpc',
  ($scope, rpc) ->

    store = (hash, key, value) ->
      ss.rpc 'host.api', 'store', hash, key, value, ->

    $scope.selectBriq = (id) ->
      $scope.id = id
      for input in id.info.inputs or []
        input.value = null
      
    $scope.installBriq = () ->
      briq = $scope.id.info
      key = [briq.name]
      for input in briq.inputs or []
        key.push input.value or input.default
      store 'installed', key.join(':'), briq.name
      
    $scope.uninstallBriq = (id) ->
      $scope.id = null
      store 'installed', id
]
