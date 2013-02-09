exports.info =
  name: 'jcw-staticdata'
  description: 'Static data definitions (temporary)'
  menus: [
    title: 'Data'
  ]
  
nodeMap = require './nodeMap'
state = require '../server/state'

exports.factory = class
  
  constructor: ->
    for k,v of nodeMap.locations
      v.key = k
      state.store 'locations', v
