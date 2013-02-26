exports.info =
  name: 'temp'
  description: 'This temp briq is used by to display temperature from the Modern Device 421 TMP chip on a JeeNode
  menus: [
    title: 'Temperature'
    controller: 'TempCtrl'
  ]
  connections:
    feeds:
      'rf12.packet': 'event'
    results:
      'ss-temp': 'event'

state = require '../server/state'
ss = require 'socketstream'

exports.factory = class
  
  constructor: ->
    state.on 'rf12.packet', packetListener
        
  destroy: ->
    state.off 'rf12.packet', packetListener

packetListener = (packet, ainfo) ->
  if packet.id is 2 and packet.group is 100
    value = packet.buffer[1]
    ss.api.publish.all 'ss-temp', value
