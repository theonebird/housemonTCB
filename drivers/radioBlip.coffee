module.exports =

  announcer: 17

  descriptions:
    ping:
      title: 'Ping count'
      min: 0
    age:
      title: 'Estimated age'
      unit: 'days'
      min: 0

  feed: 'rf12.packet'

  decode: (raw, cb) ->
    count = raw.readUInt32LE(1)
    cb
      ping: count
      age: count / (86400 / 64) | 0
  
 
