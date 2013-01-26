# This client-side code gets called first by SocketStream and must always exist

# Make 'ss' available to all modules and the browser console
# FIXME looks like window.ss is needed to reconnect properly?
window.ss = ss = require 'socketstream'

ss.server.on 'disconnect', ->
  console.info 'Connection down'

ss.server.on 'reconnect', ->
  console.info 'Connection back up'
  # force full reload to re-establish all model links
  window.location.reload true

ss.server.once 'ready', ->
  #jQuery ->
    console.info 'app ready'
    ss.rpc 'host.api', 'fetch', (models) ->
      console.info 'models fetched', _.keys models

      # collect routes from the current list of installed briq objects
      for k,obj of models.bobs
        briq = models.briqs[obj.briq_id] # TODO: generic parent lookup
        routes.push r  for r in briq.info.menus or []

      # set up a list of modules which need to be loaded
      paths = ['/main']
      for r in routes
        if r.title
          name = r.title.toLowerCase()
          r.route ?= "/#{name}"
          r.templateUrl ?= "#{name}.html"
          paths.push "/#{name}"

      # make the models available via dependency injection
      app.value 'models', models

      console.info 'require', paths
      require(path) app  for path in paths

      console.info 'ng bootstrap'
      angular.bootstrap document, ['app']

# routes which have a title will appear in the main menu
# the order in the menu is the order in the routes array below
# load and route both default to "/title-in-lowercase" if title is set

routes = [
  { title: 'Home', controller: 'HomeCtrl', route: '/' }
  { title: 'Admin', controller: 'AdminCtrl' }
]

app = angular.module 'app', []

app.config [
  '$routeProvider','$locationProvider',
  ($routeProvider, $locationProvider) ->
    console.info 'app config'
    
    for r in routes
      $routeProvider.when r.route, r
    $routeProvider.otherwise
      redirectTo: '/'
       
    $locationProvider.html5Mode true
]

app.run [
  '$rootScope',
  ($rootScope) ->
    $rootScope.routes = routes
]

# Credit to https://github.com/polidore/ss-angular for ss rpc/pubsub wrapping
# Thx also to https://github.com/americanyak/ss-angular-demo for the demo code

app.service 'rpc', [
  '$q','$rootScope',
  ($q, $rootScope) ->

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

app.service 'pubsub', [
  '$rootScope',
  ($rootScope) ->

    # override the $on function
    old$on = $rootScope.$on
    Object.getPrototypeOf($rootScope).$on = (name, listener) ->
      scope = this
      ss.event.on name, (args) ->
        scope.$apply -> scope.$broadcast name, args...
      # call angular's $on version
      old$on.call scope, name, listener
]
