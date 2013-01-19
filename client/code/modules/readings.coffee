# Readings module definitions

exports.controllers = 
  ReadingsCtrl: [
    '$scope',
    ($scope) ->

      topBotMargin = 22   # pixels
      maxProduced = 5000  # Watt
      maxConsumed = 5000  # Watt
      scaleMinimum = 0    # Watt
      
      # 0 gives sqrt scaling, 30 is a nice value for log scaling
      mapFun = if scaleMinimum >= 1 then Math.log else Math.sqrt
      
      mp = mapFun maxProduced 
      mc = mapFun maxConsumed 
      sm = mapFun scaleMinimum 
      
      canvas = $('#mybar')[0]
      ctx = canvas.getContext '2d'
      w = canvas.width
      h = canvas.height
      scale = (h - 2 * topBotMargin) / ((mp - sm) + (mc - sm))      
      
      energyToPixel = (value) ->
        if value > scaleMinimum
          value = Math.min value, maxProduced
          pos = mp - mapFun value
        else if value < -scaleMinimum
          value = Math.min -value, maxConsumed
          pos = mp - sm + mapFun(value) - sm
        else
          pos = mp - sm
        pos * scale + topBotMargin

      drawLine = (colour, value) ->
        pos = energyToPixel value
        ctx.beginPath()
        ctx.strokeStyle = colour
        ctx.lineWidth = 1
        ctx.moveTo 0, pos
        ctx.lineTo w, pos
        ctx.stroke()
              
      drawCircle = (colour, value) ->
        pos = energyToPixel value
        radius = 2.3 * Math.log(2 + Math.abs value)
        radius = 20  if colour is 'blue'
        ctx.beginPath()
        ctx.arc 43, pos, radius, 0, 2 * Math.PI, false
        if colour is 'blue'
          ctx.lineWidth = 3
          ctx.strokeStyle = colour
          ctx.stroke()
        else
          ctx.fillStyle = colour
          ctx.fill()

      drawTicks = () ->
        ctx.clearRect 20, 0, w, h
        w = 8
        for i in [-29..29]
          drawLine 'lightgreen', i * 10
        w = 12
        for i in [-29..29]
          drawLine 'orange', i * 100
        w = 20
        for i in [-10..10]
          drawLine 'red', i * 1000
        w = 70
        drawLine 'lightgray', 0
        ctx.moveTo 0, topBotMargin
        ctx.lineTo 0, h-topBotMargin
        ctx.stroke()

      $scope.$on 'set.readings', (event, key, value, oldVal) ->
        if key is 'RF12:868:5:9.homePower'
          produced = value.p2 / 10
          if $scope.readings['RF12:868:5:15.smaRelay']?.acw is 0
            produced = 0 # ignore residual reading when the inverter is off
          consumed = (value.p1 + value.p3) / 10
          drawTicks()
          drawCircle 'red', -consumed
          drawCircle 'green', produced
          drawCircle 'blue', produced - consumed
  ]

exports.filters =
  cleanup: ->
    (obj) ->
      _.omit obj, 'time', '$$hashKey'
