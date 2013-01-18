# Readings module definitions

exports.controllers = 
  ReadingsCtrl: [
    '$scope',
    ($scope) ->

      margin = 22         # pixels
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
      scale = (h - 20) / ((mp - sm) + (mc - sm))      
      
      energyPos = (value) ->
        if value > scaleMinimum
          value = Math.min value, maxProduced
          pos = mp - mapFun value
        else if value < -scaleMinimum
          value = Math.min -value, maxConsumed
          pos = mp - sm + mapFun(value) - sm
        else
          pos = mp - sm
        pos * scale + margin

      line = (colour, value) ->
        pos = energyPos value
        ctx.beginPath()
        ctx.strokeStyle = colour
        ctx.lineWidth = 1
        ctx.moveTo 0, pos
        ctx.lineTo w, pos
        ctx.stroke()
              
      energyDraw = (colour, hor, value) ->
        pos = energyPos value
        radius = 2.3 * Math.log(2 + Math.abs value)
        radius = 20  if colour is 'blue'
        ctx.beginPath()
        ctx.arc 10 + w/2, pos, radius, 0, 2 * Math.PI, false
        if colour is 'blue'
          ctx.lineWidth = 3
          ctx.strokeStyle = colour
          ctx.stroke()
        else
          ctx.fillStyle = colour
          ctx.fill()

      # draw the tick marks
      energyInit = () ->
        ctx.clearRect 20, 0, w, h
        line 'lightgray', 0
        ctx.moveTo 0, margin
        ctx.lineTo 0, h-margin
        ctx.stroke()
        w = 8
        for i in [-29..29]
          line 'lightgreen', i * 10
        w = 12
        for i in [-29..29]
          line 'orange', i * 100
        w = 20
        for i in [-10..10]
          line 'red', i * 1000
        w = canvas.width

      $scope.$on 'set.readings', (event, key, value, oldVal) ->
        if key is 'RF12:868:5:9.homePower'
          produced = value.p2 / 10
          consumed = (value.p1 + value.p3) / 10
          energyInit()
          energyDraw 'red', +1, -consumed
          energyDraw 'green', -1, produced
          energyDraw 'blue', 0, produced - consumed
  ]

exports.filters =
  cleanup: ->
    (obj) ->
      _.omit obj, 'time', 'tag', '$$hashKey'
