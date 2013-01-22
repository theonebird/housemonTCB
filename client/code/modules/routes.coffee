# routes which have a title will appear in the main menu
# the order in the menu is the order in the routes array below
# load and route both default to "/title-in-lowercase" if title is set

myApp = null

setRouteDefaults = (r) ->
  if r.title
    r.route ?= "/#{r.title.toLowerCase()}"
    r.templateUrl ?= "#{r.title.toLowerCase()}.html"

loadModule = (r) ->
  loadPath = r.load or (r.title and "/#{r.title.toLowerCase()}")
  if loadPath
    module = require loadPath
    myApp.config module.config  if module.config
    myApp.filter name, def  for name,def of module.filters
    myApp.factory name, def  for name,def of module.services
    myApp.directive name, def  for name,def of module.directives
    myApp.controller name, def  for name,def of module.controllers

exports.routes = routes = [
  title: 'Home'
  route: '/'
  controller: 'HomeCtrl'
,
  title: 'Admin'
  controller: 'AdminCtrl'
]

exports.setup = (routeProvider, providers) ->
  for type,func of providers
    myApp[type] = func.register
  for r in routes
    setRouteDefaults r
    routeProvider.when r.route, r
  routeProvider.otherwise
    redirectTo: '/'

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

exports.loadStandardModules = (app) ->
  myApp = _.clone app
  loadModule load: '/main'
  loadModule r  for r in routes
