# Readings module definitions

exports.controllers = 
  ReadingsCtrl: [
    '$scope',
    ($scope) ->

      maxProduced = 5000
      maxConsumed = 8000
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
        ctx.beginPath()
        ctx.strokeStyle = colour
        ctx.lineWidth = 2
        ctx.arc w/2 + 25 * hor, pos, 10, 0, 2 * Math.PI, false
        ctx.stroke()

      w = 20
      for i in [-8..5]
        line 'black', energyPos i * 1000
      w = 10
      for i in [-15..15]
        line 'black', energyPos i * 100
      w = 5
      for i in [-15..15]
        line 'black', energyPos i * 10
      w = canvas.width
      
      line 'green', 10
      line 'red', h-10
      line 'blue', energyPos 0
      
      $scope.$on 'set.readings', (event, key, value, oldVal) ->
        if key is 'RF12:868:5:9.homePower'
          produced = value.p2 / 10
          consumed = (value.p1 + value.p3) / 10
          console.log produced, consumed 
          energyDraw 'green', -1, produced
          energyDraw 'red', +1, -consumed
          energyDraw 'blue', 0, produced - consumed
  ]

exports.filters =
  cleanup: ->
    (obj) ->
      _.omit obj, 'time', 'tag', '$$hashKey'
