# Readings module definitions

exports.controllers = 
  ReadingsCtrl: [
    '$scope',
    ($scope) ->

  ]

exports.filters =
  cleanup: ->
    (obj) ->
      out = []
      for k,v of _.omit obj, 'time', 'tag', '$$hashKey'
        out.push "#{k}: #{v}"
      out.join ', '