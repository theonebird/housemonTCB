# Main app setup and controller, this all hooks into AngularJS

module.exports = (ng) ->

  ng.controller 'MainCtrl', [
    'routes','$scope',
    (routes, $scope) ->
      console.info 'main controller'

      $scope.routes = routes

      # pick up the 'ss-tick' events sent from server/launch
      $scope.tick = '?'
      $scope.$on 'ss-tick', (event, msg) ->
        $scope.tick = msg
  ]
