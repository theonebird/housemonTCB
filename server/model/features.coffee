fs = require 'fs'

revision = 0

model = {}    # collection of name -> filename pairs
features = {} # collection of filename -> loaded module pairs

add = (filename, loaded) ->
  model[loaded.info.name] = filename
  features[filename] = loaded
  revision += 1

exports.make = (des, chan, ss) ->

  poll: () ->
    chan
      data: model
      hash: revision 

exports.loadAll = () ->
  fs.readdir './features', (err, files) ->
    throw err  if err
    for f in files
      add f, require("../../features/#{f}")

  # TODO: wait for newer node.js to use this on Mac OS X
  # fs.watch './features', (event, filename) ->
  #   console.log event, filename
