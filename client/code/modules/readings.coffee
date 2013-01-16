# Readings module definitions

exports.controllers = 
  ReadingsCtrl: [
    '$scope',
    ($scope) ->

  ]

exports.filters =
  cleanup: ->
    (obj) ->
      cleanedObj = _.omit obj, 'time', 'tag', '$$hashKey'
      ("#{k}: #{v}" for k,v of cleanedObj).join ', '