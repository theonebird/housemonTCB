myApp = angular.module 'myApp', ['ssAngular']

myApp.config [
  '$locationProvider',
  ($locationProvider) ->
    $locationProvider.html5Mode true
]

myApp.controller 'AppCtrl', [
  '$scope','pubsub','rpc',
  ($scope, pubsub, rpc) ->
    
    # pick up the 'ss-tick' events sent from server/startup
    $scope.tick = '?'
    $scope.$on 'ss-tick', (event, msg) ->
      $scope.tick = msg
      
    # example RPC call, the returned promise is automatically resolved
    $scope.platform = rpc 'host.platform'
    
    $scope.data = {}    

    idsOf = (group) ->
      pre = "#{group}:"
      len = pre.length
      (id for id of $scope.data when id.slice(0, len) is pre)

    store = (key, value) ->
      rpc 'host.api', 'store', key, value

    $scope.$on 'ss-store', (event, msg) ->
      [key, value] = msg
      if value?
        existed = $scope.data[key]?
        $scope.data[key] = value
        return if existed
      else
        delete $scope.data[key]
      # update collections in $scope when keys are added or removed
      keyEnd = key.indexOf ':'
      if keyEnd >= 0
        prefix = key.slice(0, keyEnd)
        # TODO: incrementally add or remove one item only
        $scope[prefix] = idsOf prefix
    
    # get initial model from the server
    ss.rpc 'host.api', 'fetch', (model) ->
      $scope.data = model
      # TODO: use a single loop and generalise
      $scope.briqs = idsOf 'briqs'
      $scope.installed = idsOf 'installed'
      console.info 'model fetched'

    $scope.selectBriq = (id) ->
      $scope.id = id
      $scope.details = $scope.data[id]
      
    $scope.installBriq = () ->
      key = ['installed', $scope.details.info.name]
      for p in $scope.details.info.parameters ? []
        key.push p.default
      store key.join(':'), $scope.id
      
    $scope.uninstallBriq = (id) ->
      $scope.id = null
      store id
]
