# Web server startup, i.e. first code loaded from app.js

# This list is also the order in which everything gets initialised
state = require '../engine/state'
briqs = require '../engine/briqs'
local = require '../local'
http = require 'http'
ss = require 'socketstream'

# Auto-load all briqs from a central directory
briqs.loadAll ->
  console.info "briqs loaded"

# Hook state management into SocketStream
ss.api.add 'fetch', state.fetch
ss.api.add 'store', state.store
state.on 'store', (hash, key, value) ->
  ss.api.publish.all 'ss-store', [hash, key, value]
  
# Define a single-page client called 'main'
ss.client.define 'main',
  view: 'index.jade'
  css: ['libs', 'app.styl']
  code: 'app'

# Serve this client on the root URL
ss.http.route '/', (req, res) ->
  res.serveClient 'main'

# Persistent sessions with Redis
if local.useRedis
  console.info 'redisConfig', local.redisConfig
  ss.session.store.use 'redis', local.redisConfig
  # ss.publish.transport.use 'redis', local.redisConfig
  state.setupStorage local.redisConfig

# Code Formatters known by SocketStream
ss.client.formatters.add require('ss-coffee')
ss.client.formatters.add require('ss-jade')
ss.client.formatters.add require('ss-stylus')

# Use client-side templates
ss.client.templateEngine.use 'angular'

# Minimise and pack assets if you type: SS_ENV=production node app.js
ss.client.packAssets()  if ss.env is 'production'

# Start web server
server = http.Server ss.http.middleware
server.listen local.httpPort
ss.start server

# This event is periodically pushed to the clients to make them, eh, "tick"
setInterval ->
  ss.api.publish.all 'ss-tick', new Date
, 1000
