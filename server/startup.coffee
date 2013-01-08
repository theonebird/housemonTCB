# loaded from app.js

state = require '../main/state'
briqs = require '../main/briqs'
http = require 'http'
ss = require 'socketstream'

# briqs are auto-loaded from the "briqs" directory
briqs.loadAll()

ss.api.add 'fetch', state.fetch
ss.api.add 'idsOf', state.idsOf
ss.api.add 'store', state.store

state.on 'store', (key, value) ->
  ss.api.publish.all 'ss-store', [key, value]
  
# Define a single-page client called 'main'
ss.client.define 'main',
  view: 'index.jade'
  css: ['libs', 'app.styl']
  code: ['libs', 'app']

# Serve this client on the root URL
ss.http.route '/', (req, res) ->
  res.serveClient 'main'

# Code Formatters
ss.client.formatters.add require('ss-coffee')
ss.client.formatters.add require('ss-jade')
ss.client.formatters.add require('ss-stylus')

# Use client-side templates
ss.client.templateEngine.use 'angular'

# Responders
ss.responders.add require('ss-angular')

# Minimize and pack assets if you type: SS_ENV=production node app.js
ss.client.packAssets()  if ss.env is 'production'

# Start web server
server = http.Server ss.http.middleware
server.listen 3333
ss.start server

# this event is periodically pushed to the clients to make them, eh, "tick"
setInterval ->
  ss.api.publish.all 'ss-tick', new Date
, 1000
