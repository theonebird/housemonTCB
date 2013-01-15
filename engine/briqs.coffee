# Briqs are the installable modules in the ./briqs/ directory
fs = require 'fs'

module.exports = (state) ->
  
  models = state.fetch()
  
  state.on 'set.installed', (key, newVal, oldVal) ->
    briq = models.briqs[newVal.briq]
    if briq.factory
      args = key.split(':').slice(1)
      newVal.emitter = new briq.factory(args...)
      newVal.emitter.on 'packet', (packet) ->
        console.log 'got data', packet
    
  state.on 'unset.installed', (key, value) ->
    briq = models.briqs[value.briq]
    if value.emitter
      value.emitter.destroy?()
      value.emitter.removeAllListeners?()
      delete value.emitter

  loadFile = (filename) ->
    loaded = require "../briqs/#{filename}"
    loaded.filename = filename # TODO: really put the key inside the object?
    state.store 'briqs', filename, loaded.info.name and loaded

  loadAll: (cb) ->
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
