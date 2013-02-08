exports.info =
  name: 'jcw-status'
  description: 'Collect and show the current status'
  menus: [
    title: 'Status'
    controller: 'StatusCtrl'
  ]
  # FIXME depends on readings
  
exports.factory = class
