exports.info =
  name: 'jcw-staticdata'
  description: 'Static data definitions (temporary)'
  menus: [
    title: 'Data'
    controller: 'DataCtrl'
  ]
  
nodeMap = require './nodeMap'
state = require '../server/state'
console.log 66666

exports.factory = class
  
  constructor: ->
    for k,v of nodeMap.locations
      v.key = k
      state.store 'locations', v
    for k,v of nodeMap.drivers
      v.key = k
      state.store 'drivers', v
