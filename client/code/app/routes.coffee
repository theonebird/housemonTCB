# routes which have a title will appear in the main menu
# the order in the menu is the order in the reoutes array
module.exports = [
  title: 'Home'
  path: '/'
  controller: 'HomeCtrl'
,
  title: 'Admin'
  path: '/admin'
  controller: 'AdminCtrl'
,
  title: 'Sandbox'
  path: '/sandbox'
  controller: 'SandboxCtrl'
]
