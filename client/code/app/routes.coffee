# routes which have a title will appear in the main menu
# the order in the menu is the order in the routes array below
# load and route both default to "/title-in-lowercase" if title is set

module.exports = [
  load: '/main'  # must be first
,
  title: 'Home'
  route: '/'
  controller: 'HomeCtrl'
,
  title: 'Admin'
  controller: 'AdminCtrl'
,
  title: 'Sandbox'
  controller: 'SandboxCtrl'
]
