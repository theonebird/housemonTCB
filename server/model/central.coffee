revision = 0
model = []

model.push
  name: 'paths'
  value: module.paths

checkFilter = (row, filter) ->
  for k,v of filter
    return false  if row[k] isnt v
  return true

exports.make = (des, chan, ss) ->

  poll: (filter) ->
    data = model
    if filter?
      data = (row for row in data when checkFilter(row, filter))
    chan
      hash: model.revision 
      data: data