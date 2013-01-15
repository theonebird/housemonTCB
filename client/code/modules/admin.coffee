# Admin module definitions

exports.controllers = 
  AdminCtrl: [
    '$scope',
    ($scope) ->

      $scope.selectBriq = (id) ->
        $scope.id = id
        for input in id.info.inputs or []
          input.value = null
          input.type ?= 'line'
      
      $scope.installBriq = ->
        info = $scope.id.info
        keys = [info.name]
        for input in info.inputs or []
          keys.push input.value?.keys or input.value or input.default
        console.log 'aaaa',keys
        $scope.store 'installed', keys.join(':'),
          briq: $scope.id.filename
          keys: keys.join(':')
      
      $scope.uninstallBriq = (id) ->
        $scope.id = null
        $scope.store 'installed', id
  ]
