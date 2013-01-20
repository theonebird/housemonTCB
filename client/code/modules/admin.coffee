# Admin module definitions

# FIXME: need better way to store briqlets and installed items, the current
#   approach requires extremely much "data navigation" code and logic :(
# would much better to load rows as instances with extra behavior

# briqlets:
#   id = unique id
#   key = filename
#   info: object from exports, i.e. description, inputs, etc
#
# actives:
#   id = unique id
#   key = briqname:and:args
#   briqlet_id: parent briqlet
#   more... config settings for this installed instance?

exports.controllers = 
  AdminCtrl: [
    '$scope',
    ($scope) ->

      $scope.selectBriqlet = (obj) ->
        # # if there are no args, it may already have been installed
        # if $scope.actives?[obj.info.name]
        #   $scope.selectActive obj.info.name
        # else
        $scope.active = null
        $scope.briqlet = obj
        for input in obj.info.inputs or []
          input.value = null
      
      $scope.selectActive = (obj) ->
        $scope.active = obj
        $scope.briqlet = briqlet = $scope.briqlets[obj.briqlet_id]

        keys = obj.key.split(':').slice 1
        for input in briqlet.info.inputs or []
          input.value = keys.shift()

      $scope.createActive = ->
        # TODO: candidate for a Bricklet method
        keys = [$scope.briqlet.info.name]
        for input in $scope.briqlet.info.inputs or []
          keys.push input.value?.keys or input.value or input.default

        $scope.store 'actives',
          briqlet_id: $scope.briqlet.id
          key: keys.join(':')

        # TODO: hacked to capture actual store once it comes back from server
        done = $scope.$on 'set.actives', (event, obj) ->
          $scope.selectActive obj
          done() # simulates $scope.$once
      
      $scope.removeActive = () ->
        $scope.store 'actives', _.omit $scope.active, 'key'
        $scope.briqlet = null
        $scope.active = null
  ]
