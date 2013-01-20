# Admin module definitions

# FIXME: need better way to store briqlets and installed items, the current
#   approach requires extremely much "data navigation"

exports.controllers = 
  AdminCtrl: [
    '$scope',
    ($scope) ->

      $scope.selectBriqlet = (id) ->
        console.log 'b-id',id
        $scope.idConf = null
        $scope.id = id
        for input in id.info.inputs or []
          input.value = null
          input.type ?= 'line'
      
      $scope.installBriqlet = ->
        info = $scope.id.info
        keys = [info.name]
        for input in info.inputs or []
          keys.push input.value?.keys or input.value or input.default
        $scope.store 'installed', keys.join(':'),
          briq: $scope.id.filename
          keys: keys.join(':')
      
      $scope.selectInstalled = (id) ->
        keys = id.split(':')
        keys.shift()
        $scope.idConf = inst = $scope.installed[id]
        console.log 'aa',inst,inst.briq
        $scope.id = briqlet = $scope.briqlets[inst.briq]
        for input in briqlet.info.inputs or []
          input.value = keys.shift()
          input.type ?= 'line'
        console.log 'i-id',id,keys,$scope.idConf,briqlet.info.inputs

      $scope.removeInstalled = () ->
        id = $scope.idConf
        console.log 'r-id',id
        $scope.id = null
        $scope.store 'installed', id.keys
  ]
