# Automatic loading of "briqs"

fs = require 'fs'
ss = require 'socketstream'

loadFile = (filename) ->
  loaded = require("../briqs/#{filename}")  
  ss.api.store "briqs:#{filename}", loaded.info.name and loaded

loadAll = () ->
  # delete existing briqs
  ss.api.store key  for key in ss.api.idsOf 'briqs'
  # scan and add all briqs, async
  fs.readdir './briqs', (err, files) ->
    throw err  if err
    for f in files
      loadFile f
  # TODO: need newer node.js to use fs.watch on Mac OS X
  #  see: https://github.com/joyent/node/issues/3343
  # fs.watch './briqs', (event, filename) ->
  #   console.log event, filename

module.exports =
  loadAll: loadAll
