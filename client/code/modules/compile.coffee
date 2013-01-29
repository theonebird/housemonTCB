module.exports = (ng) ->

  ng.controller 'CompileCtrl', [
    '$scope','rpc',
    ($scope, rpc) ->

      $scope.compileAndInstall = (obj) ->
        $scope.result = rpc.exec 'host.api', 'compile', obj.key
        $scope.output = ''

      $scope.$on 'ss-output', (event, type, text) ->
        $scope.output += text

      $scope.removeUpload = (obj) ->
        $scope.uploads.store { id: obj.id }
  ]
