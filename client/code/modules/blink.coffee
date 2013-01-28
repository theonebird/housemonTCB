module.exports = (ng) ->

  ng.controller 'BlinkCtrl', [
    '$scope',
    ($scope) ->

      $scope.blink = $scope.readings.find 'blink'

      $scope.$on 'set.readings.blink', (event, obj, oldObj) ->
        $scope.blink = obj

      # trigger only on changes in l1 or l2
      $scope.$watch 'blink.l1 + blink.l2', ->
        $scope.readings.store $scope.blink
  ]
