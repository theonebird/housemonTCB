# Standard wrappers, must be loaded first to tie into SocketStream
routes = require '/routes'

# Credit to https://github.com/polidore/ss-angular for ss rpc/pubsub wrapping
# Thx also to https://github.com/americanyak/ss-angular-demo for the demo code

exports.config = [
  '$routeProvider','$locationProvider',
  ($routeProvider, $locationProvider) ->
    for route in routes
      if route.title and route.path
        route.templateUrl = "#{route.title.toLowerCase()}.html"
        $routeProvider.when route.path, route
    $routeProvider.otherwise
        redirectTo: '/'
    $locationProvider.html5Mode true
]

exports.services =
  
  rpc: [
    '$q','$rootScope',
    ($q, $rootScope) ->
      # call ss.rpc with 'demoRpc.foobar', args..., {callback}
      exec: (args...) ->
        deferred = $q.defer()
        ss.rpc args, (err, res) ->
          $rootScope.$apply (scope) ->
            return deferred.reject(err)  if err
            deferred.resolve res
        deferred.promise
      # use cache across controllers for client-side caching
      cache: {}
  ]

  pubsub: [
    '$rootScope',
    ($rootScope) ->
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
