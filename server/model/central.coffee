crypto = require 'crypto'

model = [
  { name: 'paths', value: module.paths }
]

checkFilter = (row, filter) ->
  for k,v of filter
    return false  if row[k] isnt v
  return true

exports.make = (des, chan, ss) ->

  poll: (filter) ->
    if filter?
      data = (row for row in model when checkFilter(row, filter))
    else
      data = model
    chan
      # calculate a hash of the result so that it only gets sent when modified
      hash: crypto.createHash('md5').update(JSON.stringify(data)).digest('hex')
      data: data