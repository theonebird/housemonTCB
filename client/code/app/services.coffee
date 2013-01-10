# Service definitions

# Credit due to https://github.com/polidore/ss-angular for 
# figuring out a good way to wrap socketstream RPC and pubsub
# as an angular service.  The code for the rpc and pubsub
# services we taken / derived from there.
# 
# Thx also to https://github.com/americanyak/ss-angular-demo for the demo code.

exports.rpc = [
  '$q','$rootScope',
  ($q, $rootScope) ->
    console.info 'rpc service created'
    
    # call ss.rpc with 'demoRpc.foobar', args..., {callback}
    exec: (args...) ->
      deferred = $q.defer()
      ss.rpc args..., (err, res) ->
        $rootScope.$apply (scope) ->
          return deferred.reject(err)  if err
          deferred.resolve res
      deferred.promise

    # use cache across controllers for client-side caching
    cache: {}
]

exports.pubsub = [
  '$rootScope',
  ($rootScope) ->
    console.info 'pubsub service created'
  
    # override the $on function
    old$on = $rootScope.$on
    Object.getPrototypeOf($rootScope).$on = (name, listener) ->
      scope = this
      ss.event.on name, (message) ->
        scope.$apply (s) ->
          scope.$broadcast name, message
    
      # call angular's $on version
      old$on.call scope, name, listener
]
