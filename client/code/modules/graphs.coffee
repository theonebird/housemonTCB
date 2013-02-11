# Readings module definitions

module.exports = (ng) ->

  ng.controller 'GraphsCtrl', [
    '$scope','rpc',
    ($scope, rpc) ->

      key = 'meterkast/Usage house'
      promise = rpc.exec 'host.api', 'rawRange', key, -86400000, 0
      promise.then (values) ->
        console.log 'res',values
  ]
