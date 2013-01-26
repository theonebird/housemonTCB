# Main app setup and controller, this all hooks into AngularJS

module.exports = (ng) ->

  ng.controller 'MainCtrl', [
    'models','$scope','pubsub','rpc',
    (models, $scope, pubsub, rpc) ->
      console.log 'main controller'
    
      # pick up the 'ss-tick' events sent from server/launch
      $scope.tick = '?'
      $scope.$on 'ss-tick', (event, msg) ->
        $scope.tick = msg
        
      $scope.collection = (name) ->
        unless $scope[name]
          # create an array and add some object attributes to it
          # this way the extra attributes won't be enumerated
          coll = $scope[name] = []
          # map ID's to objects
          coll.byId = {}
          # find object in collection, given its key
          coll.find = (value) -> _.find @, (obj) -> obj.key is value
          # store an object (must have either a key, an id, or both)
          coll.store = (obj) -> rpc.exec 'host.api', 'store', name, obj
        $scope[name]
    
      # the server emits ss-store events to update each of the client models
      $scope.$on 'ss-store', (event, name, obj) ->
        coll = $scope.collection name
        oldObj = coll.byId[obj.id]
        if oldObj
          oldPos = coll.indexOf(oldObj)
        if obj.key
          coll.byId[obj.id] = obj
          if oldObj
            coll[oldPos] = obj
          else
            coll.push obj
          $scope.$broadcast "set.#{name}", obj, oldObj
          # $scope.$broadcast 'set', name, obj, oldObj
        else
          delete coll[obj.id]
          coll.splice oldPos, 1  if oldPos >= 0
          $scope.$broadcast "unset.#{name}", oldObj
          # $scope.$broadcast 'unset', name, oldObj
          
      for name,coll of models
        if name in ['pkg', 'local', 'process']
          $scope[name] = coll
        else
          # make sure the collection gets set up, even if it has no data
          $scope.collection name
          # emit an ss-store event to get all the collection details right
          $scope.$emit 'ss-store', name, v  for k,v of coll
  ]
