# Controller definitions

exports.AppCtrl = [
  '$scope','pubsub','rpc',
  ($scope, pubsub, rpc) ->
    
    # pick up the 'ss-tick' events sent from server/startup
    $scope.tick = '?'
    $scope.$on 'ss-tick', (event, msg) ->
      $scope.tick = msg
    
    # example RPC call, the returned result adjust the scope
    ss.rpc 'host.platform', (name) ->
      $scope.platform = name
      
    $scope.routes = require '/routes'
    
    $scope.model = {}    

    idsOf = (group) ->
      pre = "#{group}:"
      len = pre.length
      (id for id of $scope.model when id.slice(0, len) is pre)

    $scope.$on 'ss-store', (event, msg) ->
      [key, value] = msg
      if value?
        existed = $scope.model[key]?
        $scope.model[key] = value
        return if existed
      else
        delete $scope.model[key]
      # update collections in $scope when keys are added or removed
      keyEnd = key.indexOf ':'
      if keyEnd >= 0
        prefix = key.slice(0, keyEnd)
        # TODO: incrementally add or remove one item only
        $scope[prefix] = idsOf prefix
    
    # get initial model from the server
    ss.rpc 'host.api', 'fetch', (model) ->
      $scope.model = model
      $scope.appName = model.package['exact-name']
      # TODO: use a single loop and generalise
      $scope.briqs = idsOf 'briqs'
      $scope.installed = idsOf 'installed'
      console.info 'model fetched'
]
  
exports.AdminCtrl = [
  '$scope','rpc',
  ($scope, rpc) ->

    store = (key, value) ->
      ss.rpc 'host.api', 'store', key, value, ->

    $scope.selectBriq = (id) ->
      $scope.id = id
      $scope.details = $scope.model[id]
      
    $scope.installBriq = () ->
      key = ['installed', $scope.details.info.name]
      for input in $scope.details.info.inputs ? []
        key.push input.default
      store key.join(':'), $scope.id
      
    $scope.uninstallBriq = (id) ->
      $scope.id = null
      store id
]
