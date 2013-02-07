module.exports =

  announcer: 14

  descriptions:
    value:
      title: '...'

  feed: 'rf12.packet'

  decode: (raw, cb) ->
    cb
      tag: "p#{raw[1]}"
      value: raw.readUInt16LE(2, true)
