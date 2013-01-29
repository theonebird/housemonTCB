module.exports = (ng) ->

  ng.controller 'CompileCtrl', [
    '$scope','rpc',
    ($scope, rpc) ->

      $scope.compile = $scope.readings.find 'compile'

      $scope.$on 'set.readings.compile', (event, obj, oldObj) ->
        $scope.compile = obj

      # trigger only on changes in l1 or l2
      $scope.$watch 'compile.l1 + compile.l2', ->
        $scope.readings.store $scope.compile

      $scope.compileAndInstall = (obj) ->
        $scope.result = rpc.exec 'host.api', 'compile', obj.key
        $scope.output = ''

      $scope.$on 'ss-output', (event, type, text) ->
        $scope.output += text

      $scope.removeUpload = (obj) ->
        $scope.uploads.store { id: obj.id }
  ]
