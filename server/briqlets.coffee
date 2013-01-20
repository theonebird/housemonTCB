# Briqlets are the installable modules in the ./briqlets/ directory
fs = require 'fs'

installedBriqlets = {}

module.exports = (state) ->
  
  state.fetch (models) ->
  
    state.on 'set.actives', (newVal, oldVal) ->
      briqlet = models.briqlets[newVal.briqlet_id]
      if briqlet.factory
        args = newVal.key.split(':').slice 1
        installedBriqlets[newVal.key] = new briqlet.factory(args...)
    
    state.on 'unset.actives', (value) ->
      briqlet = installedBriqlets[value.key]
      if briqlet?
        briqlet.destroy?()
        delete installedBriqlets[value.key]

    loadFile = (filename) ->
      loaded = require "../briqlets/#{filename}"
      if loaded.info?.name
        loaded.key = filename
        state.store 'briqlets', loaded

    loadAll: (cb) ->
      # TODO: delete existing briqlets
      # scan and add all briqlets, async
      fs.readdir './briqlets', (err, files) ->
        throw err  if err
        for f in files
          loadFile f
        cb?()
      # TODO: need newer node.js to use fs.watch on Mac OS X
      #  see: https://github.com/joyent/node/issues/3343
      # fs.watch './briqlets', (event, filename) ->
      #   briqlet_id event, filename
