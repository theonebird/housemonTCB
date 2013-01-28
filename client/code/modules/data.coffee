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
        tag = obj.key.split('.').concat(param).join ' - '
        $rootScope.status["#{loc.title}/#{info.title}"] = [
          loc.title, info.title, value, info.unit, obj.time, tag
        ]

      processReading = (obj) ->
        segments = obj.key.split '.'
        loc = $rootScope.locations.find _.first segments
        drv = $rootScope.drivers.find _.last segments
        if loc and drv
          for param, value of obj
            unless param in ['id','key']
              info = drv[param]
              updateStatus obj, loc, info, param, value  if info

      $rootScope.$on 'set.readings', (event, obj, oldObj) ->
        processReading obj  if obj

      processReading obj  for obj in $rootScope.readings
    ]
