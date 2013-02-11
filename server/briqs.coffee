# Briqs are the installable modules in the ./briqs/ directory

ss = require 'socketstream'
fs = require 'fs'

installedBriqs = {}

module.exports = (state) ->
  
  state.fetch (models) ->
  
    state.on 'set.bobs', (obj, oldObj) ->
      if obj?
        briq = models.briqs[obj.briq_id]
        if briq?
          if briq.factory
            console.info 'install briq', obj.key
            args = obj.key.split(':').slice 1
            installedBriqs[obj.key] = new briq.factory(args...)
          if briq.info.rpcs
            ss.api.add name, briq[name]  for name in briq.info.rpcs

      else
        briq = installedBriqs[oldObj.key]
        if briq?
          console.info 'uninstall briq', oldObj.key
          briq.destroy?()
          delete installedBriqs[oldObj.key]

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
