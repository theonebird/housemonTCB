# Sandbox module definitions

module.exports = (ng) ->

  ng.controller 'ResetCtrl', [
    '$scope','rpc',
    ($scope, rpc) ->

      $scope.resetStatus = -> rpc.exec 'host.api', 'resetStatus'
      $scope.resetReadings = -> rpc.exec 'host.api', 'resetReadings'
      $scope.flushRedis = -> rpc.exec 'host.api', 'flushRedis'
  ]
