myApp = angular.module 'myApp', ['ssAngular']

myApp.config [
  '$locationProvider',
  ($locationProvider) ->
    $locationProvider.html5Mode true
]

myApp.controller 'AppCtrl', [
  '$scope','pubsub','rpc','model',
  ($scope, pubsub, rpc, model) ->
    
    # pick up the 'ss-tick' events sent from server/startup
    $scope.tick = '?'
    $scope.$on 'ss-tick', (event, msg) ->
      $scope.tick = msg
    
    # example RPC call, the returned promise is automatically resolved
    $scope.platform = rpc 'host.platform'
    
    # link to part of the "central" model, i.e. the server's "module.paths"
    $scope.linkModel 'central', { name: 'paths' }, 'serverModulePaths'
]