# Admin module definitions

# FIXME: need better way to store briqs and installed items, the current
#   approach requires extremely much "data navigation" code and logic :(
# would much better to load rows as instances with extra behavior

# briqs:
#   id = unique id
#   key = filename
#   info: object from exports, i.e. description, inputs, etc
#
# bobs:
#   id = unique id
#   key = briqname:and:args
#   briq_id: parent briq
#   more... config settings for this installed instance?

exports.controllers = 
  AdminCtrl: [
    '$scope',
    ($scope) ->

      $scope.selectBriq = (obj) ->
        # # if there are no args, it may already have been installed
        # if $scope.bobs?[obj.info.name]
        #   $scope.selectBob obj.info.name
        # else
        $scope.bob = null
        $scope.briq = obj
        for input in obj.info.inputs or []
          input.value = null
      
      $scope.selectBob = (obj) ->
        $scope.bob = obj
        $scope.briq = briq = $scope.briqs[obj.briq_id]

        keys = obj.key.split(':').slice 1
        for input in briq.info.inputs or []
          input.value = keys.shift()

      $scope.createBob = ->
        # TODO: candidate for a Bricklet method
        keys = [$scope.briq.info.name]
        for input in $scope.briq.info.inputs or []
          keys.push input.value?.keys or input.value or input.default

        $scope.store 'bobs',
          briq_id: $scope.briq.id
          key: keys.join(':')

        # TODO: hacked to capture actual store once it comes back from server
        done = $scope.$on 'set.bobs', (event, obj) ->
          $scope.selectBob obj
          done() # simulates $scope.$once
      
      $scope.removeBob = () ->
        $scope.store 'bobs', _.omit $scope.bob, 'key'
        $scope.briq = null
        $scope.active = null
  ]
