module.exports = (ng) ->

  ng.controller 'DataCtrl', [
    '$scope',
    ($scope) ->

      $scope.$on 'set.readings', (event, obj, oldObj) ->
        console.log 'dcsr', event, obj, oldObj
        if obj
          segments = obj.key.split '.'
          console.log segments...
  ]
