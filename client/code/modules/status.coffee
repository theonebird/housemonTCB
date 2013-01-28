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

        key = "#{loc.title}/#{info.title}"
        tag = obj.key.split('.').concat(param).join ' - '
        row = [ loc.title, info.title, value, info.unit, obj.time, tag ]

        $rootScope.status[key] = row
        $rootScope.$broadcast 'status', row

      processReading = (obj) ->
        [locName, other..., drvName] = obj.key.split '.'

        loc = $rootScope.locations.find locName
        unless loc
          loc = $rootScope.locations.find drvName
          drvName = drvName.replace /-.*/, ''
        drv = $rootScope.drivers.find drvName

        if loc and drv
          for param, value of obj
            unless param in ['id','key']
              info = drv[param]
              updateStatus obj, loc, info, param, value  if info

      $rootScope.$on 'set.readings', (event, obj, oldObj) ->
        processReading obj  if obj

      processReading obj  for obj in $rootScope.readings or []
    ]
