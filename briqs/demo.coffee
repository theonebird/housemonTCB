exports.info =
  name: 'demo'
  description: 'This demo briq is used by the "Dive Into JeeNodes" series'
  menus: [
    title: 'Demo'
    controller: 'DemoCtrl'
  ]
  connections:
    feeds:
      'rf12.packet': 'event'
    results:
      'ss-demo': 'event'

state = require '../server/state'
ss = require 'socketstream'

exports.factory = class
  
  constructor: ->
    state.on 'rf12.packet', packetListener
        
  destroy: ->
    state.off 'rf12.packet', packetListener

packetListener = (packet, ainfo) ->
  if packet.id is 1 and packet.group is 100
    value = packet.buffer[1]
    ss.api.publish.all 'ss-demo', value
