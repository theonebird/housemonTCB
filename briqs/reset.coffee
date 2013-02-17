exports.info =
  name: 'reset'
  description: 'Reset various data items (use with extreme care!)'
  menus: [
    title: 'Reset'
    controller: 'ResetCtrl'
  ]
  rpcs: [
    'resetStatus'
    'resetReadings'
    'flushRedis'
  ]
  
state = require '../server/state'
local = require '../local'
redis = require 'redis'

config = local.redisConfig
db = redis.createClient config.port, config.host, config
db.select config.db

exports.resetStatus = ->
  console.log 'resetStatus'
  state.reset 'status'

exports.resetReadings = ->
  console.log 'resetReadings'
  state.reset 'readings'

exports.flushRedis = ->
  console.log 'flushRedis'
  db.flushdb()
