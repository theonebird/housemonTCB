module.exports = (ng) ->

  ng.controller 'DemoCtrl', [
    '$scope',
    ($scope) ->
      $scope.$on 'ss-demo', (event, value) ->
        $scope.value = value
  ]
