module.exports = (ng) ->

  ng.controller 'TempCtrl', [
    '$scope',
    ($scope) ->
      $scope.$on 'ss-temp', (event, value) ->
        $scope.value = value
  ]
