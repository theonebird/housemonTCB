# Sandbox module definitions

module.exports = (ng) ->

  ng.controller 'ResetCtrl', [
    '$scope','rpc',
    ($scope, rpc) ->

      $scope.remote = (cmd) -> rpc.exec 'host.api', cmd
  ]
