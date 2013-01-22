# routes which have a title will appear in the main menu
# the order in the menu is the order in the routes array below
# load and route both default to "/title-in-lowercase" if title is set

myApp = null

exports.routes = routes = [
  title: 'Home'
  route: '/'
  controller: 'HomeCtrl'
,
  title: 'Admin'
  controller: 'AdminCtrl'
]

exports.loadModule = loadModule = (route) ->
  console.log 'loadModule', route
  loadPath = route.load or (route.title and "/#{route.title.toLowerCase()}")
  if loadPath
    module = require loadPath
    myApp.config module.config  if module.config
    myApp.filter name, def  for name,def of module.filters
    myApp.factory name, def  for name,def of module.services
    myApp.directive name, def  for name,def of module.directives
    myApp.controller name, def  for name,def of module.controllers

exports.loadStandardModules = (app) ->
  myApp = app
  loadModule load: '/main'
  loadModule r  for r in routes
  