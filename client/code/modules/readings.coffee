# Readings module definitions

exports.controllers = 
  ReadingsCtrl: [
    '$scope',
    ($scope) ->

      maxProduced = 5000
      maxConsumed = 5000
      scaleMinimum = 50
      
      mp = Math.log maxProduced 
      mc = Math.log maxConsumed 
      sm = Math.log scaleMinimum 
      
      canvas = $('#mybar')[0]
      ctx = canvas.getContext '2d'
      w = canvas.width
      h = canvas.height
      scale = (h - 20) / ((mp - sm) + (mc - sm))      
      
      line = (colour, pos) ->
        ctx.beginPath()
        ctx.strokeStyle = colour
        # ctx.lineWidth = 2
        ctx.moveTo 0, pos
        ctx.lineTo w, pos
        ctx.stroke()
              
      energyPos = (value) ->
        if value > scaleMinimum
          value = Math.min value, maxProduced
          pos = mp - Math.log value
        else if value < -scaleMinimum
          value = Math.min -value, maxConsumed
          pos = mp - sm + Math.log(value) - sm
        else
          pos = mp - sm
        pos * scale + 10

      energyDraw = (colour, hor, value) ->
        pos = energyPos value
        radius = 2 * Math.log(2 + Math.abs value)
        radius = 20  if colour is 'blue'
        ctx.beginPath()
        ctx.fillStyle = colour
        ctx.strokeStyle = colour
        ctx.lineWidth = 3
        ctx.arc 10 + w/2, pos, radius, 0, 2 * Math.PI, false
        if colour is 'blue'
          ctx.stroke()
        else
          ctx.fill()

      # draw the tick marks
      w = 5
      for i in [-15..15]
        line 'green', energyPos i * 10
      w = 10
      for i in [-15..15]
        line 'orange', energyPos i * 100
      w = 20
      for i in [-5..5]
        line 'red', energyPos i * 1000
      w = canvas.width      

      $scope.$on 'set.readings', (event, key, value, oldVal) ->
        if key is 'RF12:868:5:9.homePower'
          produced = value.p2 / 10
          consumed = (value.p1 + value.p3) / 10
          ctx.clearRect 20, 0, w, h
          energyDraw 'red', +1, -consumed
          energyDraw 'green', -1, produced
          energyDraw 'blue', 0, produced - consumed
  ]

exports.filters =
  cleanup: ->
    (obj) ->
      _.omit obj, 'time', 'tag', '$$hashKey'
