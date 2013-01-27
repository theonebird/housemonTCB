# Main app setup and controller, this all hooks into AngularJS

module.exports = (ng) ->

  ng.controller 'MainCtrl', [
    'routes','$scope',
    (routes, $scope) ->

      $scope.routes = routes

      # reload app for any change in the bobs collection, to update the menus
      $scope.$on 'set.bobs', -> window.location.reload true

      # pick up the 'ss-tick' events sent from server/launch
      $scope.tick = '?'
      $scope.$on 'ss-tick', (event, msg) ->
        $scope.tick = msg
  ]
