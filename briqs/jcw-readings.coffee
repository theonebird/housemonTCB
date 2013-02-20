exports.info =
  name: 'jcw-readings'
  description: 'The Readings page displays incoming measurement data'
  menus: [
    title: 'Readings'
    controller: 'ReadingsCtrl'
  ]
  connections:
    feeds:
      'readings': 'collection'
