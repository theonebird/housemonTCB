# Briqs are the installable modules in the ./briqs/ directory
fs = require 'fs'

installedBriqs = {}

module.exports = (state) ->
  
  state.fetch (models) ->
  
    state.on 'set.bobs', (newVal, oldVal) ->
      briq = models.briqs[newVal.briq_id]
      if briq.factory
        args = newVal.key.split(':').slice 1
        installedBriqs[newVal.key] = new briq.factory(args...)
    
    state.on 'unset.bobs', (value) ->
      briq = installedBriqs[value.key]
      if briq?
        briq.destroy?()
        delete installedBriqs[value.key]

    loadFile = (filename) ->
      loaded = require "../briqs/#{filename}"
      if loaded.info?.name
        loaded.key = filename
        state.store 'briqs', loaded

    loadAll: (cb) ->
      # TODO: delete existing briqs
      # scan and add all briqs, async
      fs.readdir './briqs', (err, files) ->
        throw err  if err
        for f in files
          loadFile f  unless f[0] is '.'
        cb?()
      # TODO: need newer node.js to use fs.watch on Mac OS X
      #  see: https://github.com/joyent/node/issues/3343
      # fs.watch './briqs', (event, filename) ->
      #   ... briq event, filename
