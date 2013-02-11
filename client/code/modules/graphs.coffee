# Readings module definitions

module.exports = (ng) ->

  ng.controller 'GraphsCtrl', [
    '$scope','rpc',
    ($scope, rpc) ->

      key = 'meterkast - Usage house'
      info = $scope.status.find key

      promise = rpc.exec 'host.api', 'rawRange', key, -86400000, 0
      promise.then (values) ->
        [ offset, pairs ] = values
        if pairs
          series = []
          for i in [0...pairs.length] by 2
            series.push
              x: offset + parseInt pairs[i+1]
              y: adjustValue parseInt(pairs[i]), info
          console.info 'series #', series.length, key
          data = [
            values: series
            key: 'Usage House'
          ]
          nv.addGraph ->
            chart = nv.models.lineChart()
            formatter = d3.time.format '%X'
            chart.xAxis.tickFormat (d) -> formatter new Date (d)
            chart.xAxis.showMaxMin false
            chart.yAxis.showMaxMin false
            d3.select('#chart svg').datum(data).call(chart)
  ]

# TODO this duplicates the same code on the server, see status.coffee
adjustValue = (value, info) ->
  if info.factor
    value *= info.factor
  if info.scale < 0
    value *= Math.pow 10, -info.scale
  else if info.scale >= 0
    value /= Math.pow 10, info.scale
    # Note: this is different from server version - do not use exact decimal
    # formatting because strings appear to mess up the nvd3 graphing, numbers
    # are also probably a lot more efficient.
    #value = value.toFixed info.scale
  value
