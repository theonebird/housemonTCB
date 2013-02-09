module.exports = (ng) ->

  ng.run [
    '$rootScope',
    ($rootScope) ->

      $rootScope.status = {}

      updateStatus = (obj, loc, info, param, value) ->
        if info.factor
          value *= info.factor
        if info.scale < 0
          value *= Math.pow 10, -info.scale
        else if info.scale >= 0
          value /= Math.pow 10, info.scale
          value = value.toFixed info.scale

        tag = obj.key.split '.'
        row =
          key: "#{loc.title}/#{info.title}"
          location: loc.title
          parameter: info.title
          value: value
          unit: info.unit
          time: obj.time
          origin: tag[0]
          type: tag[1]
          name: param

        $rootScope.status[row.key] = row
        $rootScope.$broadcast 'status', row

      processReading = (obj) ->
        [locName, other..., drvName] = obj.key.split '.'

        loc = $rootScope.locations.find locName
        unless loc
          loc = $rootScope.locations.find drvName
          drvName = drvName?.replace /-.*/, ''
        drv = $rootScope.drivers?.find drvName

        if loc and drv
          for param, value of obj
            unless param in ['id','key']
              info = drv[param]
              updateStatus obj, loc, info, param, value  if info

      $rootScope.$on 'set.readings', (event, obj, oldObj) ->
        processReading obj  if obj

      processReading obj  for obj in $rootScope.readings or []
  ]

  ng.controller 'StatusCtrl', [
    '$scope',
    ($scope) ->
      $scope.search = (item) ->
        item.toString().indexOf($scope.query) >= 0
  ]
