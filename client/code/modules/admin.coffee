# Admin module definitions

# FIXME: need better way to store briqlets and installed items, the current
#   approach requires extremely much "data navigation" code and logic :(
# would much better to load rows as instances with extra behavior

# briqlets:
#   key = filename ("demo.coffee")
#   fields:
#     filename = own key
#     info: object from exports, i.e. description, inputs, etc
#
# installed:
#   key = briname:and:args
#   fields:
#     keys = own key
#     briq: key in briqlets
#     more... config settings for this installed instance?

exports.controllers = 
  AdminCtrl: [
    '$scope',
    ($scope) ->

      $scope.selectBriqlet = (id) ->
        # if there are no args, it may already have been installed
        if $scope.installed?[id.info.name]
          $scope.selectInstalled id.info.name
        else
          $scope.selInst = null
          $scope.selBriq = id
          for input in id.info.inputs or []
            input.value = null
            input.type ?= 'line'
      
      $scope.installBriqlet = ->
        info = $scope.selBriq.info
        keys = [info.name]
        for input in info.inputs or []
          keys.push input.value?.keys or input.value or input.default
        keyStr = keys.join(':')
        $scope.store 'installed', keyStr,
          briq: $scope.selBriq.filename
          keys: keyStr
        # TODO: hacked to capture actual store once it comes back from server
        done = $scope.$on 'set.installed', () ->
          $scope.selectInstalled keyStr
          done() # simulates $scope.$once
      
      $scope.selectInstalled = (id) ->
        keys = id.split(':').slice 1
        $scope.selInst = inst = $scope.installed[id]
        $scope.selBriq = briqlet = $scope.briqlets[inst.briq]
        for input in briqlet.info.inputs or []
          input.value = keys.shift()
          input.type ?= 'line'

      $scope.removeInstalled = () ->
        $scope.selBriq = null
        $scope.store 'installed', $scope.selInst.keys
  ]
