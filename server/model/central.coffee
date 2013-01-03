crypto = require 'crypto'

exports.make = (des, chan, ss) ->

  poll: (filter) ->
    data = module[filter.name]
    # calculate a hash of the result so that it only gets sent when modified
    hash = crypto.createHash('md5').update(JSON.stringify(data)).digest('hex')
    chan
      hash: hash
      data: data