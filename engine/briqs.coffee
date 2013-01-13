# Briqs are the installable modules in the ./briqs/ directory

state = require './state'
fs = require 'fs'

loadFile = (filename) ->
  loaded = require "../briqs/#{filename}"
  state.store 'briqs', filename, loaded.info.name and loaded

exports.loadAll = (cb) ->
  # TODO: delete existing briqs
  # scan and add all briqs, async
  fs.readdir './briqs', (err, files) ->
    throw err  if err
    for f in files
      loadFile f
    cb?()
  # TODO: need newer node.js to use fs.watch on Mac OS X
  #  see: https://github.com/joyent/node/issues/3343
  # fs.watch './briqs', (event, filename) ->
  #   console.log event, filename
