module.exports = (ng) ->

  ng.controller 'DataCtrl', [
    '$scope',
    ($scope) ->

      $scope.status = {}

      updateStatus = (where, info, value) ->
        if info.factor
          value *= info.factor
        if info.scale < 0
          value *= Math.pow 10, -info.scale
        else if info.scale >= 0
          value /= Math.pow 10, info.scale
          value = value.toFixed info.scale
        $scope.status["#{where}/#{info.title}"] = [
          where, info.title, value, info.unit
        ]

      processReading = (obj) ->
        segments = obj.key.split '.'
        loc = $scope.locations.find _.first segments
        drv = $scope.drivers.find _.last segments
        if loc and drv
          for param, value of obj
            unless param in ['id','key']
              info = drv[param]
              updateStatus loc.title, info, value  if info

      $scope.$on 'set.readings', (event, obj, oldObj) ->
        processReading obj  if obj

      processReading obj  for obj in $scope.readings
    ]
