# routes which have a title will appear in the main menu
# the order in the menu is the order in the routes array below
# load and route both default to "/title-in-lowercase" if title is set

app = angular.module 'app', []

exports.routes = routes = [
  title: 'Home'
  route: '/'
  controller: 'HomeCtrl'
,
  title: 'Admin'
  controller: 'AdminCtrl'
]

setRouteDefaults = (r) ->
  if r.title
    r.route ?= "/#{r.title.toLowerCase()}"
    r.templateUrl ?= "#{r.title.toLowerCase()}.html"

loadModule = (r) ->
  setRouteDefaults r
  loadPath = (r.title and "/#{r.title.toLowerCase()}")
  if loadPath
    console.log 'load', loadPath
    require(loadPath) app

exports.adjustScope = ($scope, $route, r, add) ->
  if r.title
    setRouteDefaults r
    if add
      $route.routes[r.route] = r
      $scope.routes.push r
      loadModule r
    else
      delete $route.routes[r.route]
      $scope.routes = _.reject $scope.routes, (obj) -> obj.route is r.route
      # TODO: wishful thinking ... routes.unloadModule r

exports.loadStandardModules = (models) ->
  app.value 'models', models
  console.log 'loading main'
  require('/main') app
  loadModule r  for r in routes
  angular.bootstrap document, ['app']
