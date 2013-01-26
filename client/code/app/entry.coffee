# This client-side code gets called first by SocketStream and must always exist

# Make 'ss' available to all modules and the browser console
ss = require 'socketstream'

ss.server.on 'disconnect', ->
  console.info 'Connection down'

ss.server.on 'reconnect', ->
  console.info 'Connection back up'
  # force full reload to re-establish all model links
  window.location.reload true

# routes which have a title will appear in the main menu
# the order in the menu is the order in the routes array below
# load and route both default to "/title-in-lowercase" if title is set

routes = [
  { title: 'Home', route: '/', controller: 'HomeCtrl' }
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

      # make these values available via dependency injection
      app.value 'ss', ss
      app.value 'models', models
      app.value 'routes', routes

      console.info 'require', paths
      require(path) app  for path in paths

      console.info 'ng bootstrap'
      angular.bootstrap document, ['app']
