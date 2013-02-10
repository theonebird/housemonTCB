# Web server startup, i.e. first code loaded from app.js

global._ = require 'underscore'

# This list is also the order in which everything gets initialised
state = require './state'
briqs = require('./briqs') state
local = require '../local'
http = require 'http'
ss = require 'socketstream'

# Auto-load all briqs from a central directory
briqs.loadAll ->
  console.info "briqs loaded"

# Hook state management into SocketStream
ss.api.add 'fetch', state.fetch
ss.api.add 'store', state.store
ss.api.add 'saveNow', state.saveNow
state.on 'publish', (hash, value) ->
  ss.api.publish.all 'ss-store', hash, value
  
# Define a single-page client called 'main'
ss.client.define 'main',
  view: 'index.jade'
  css: ['libs', 'app.styl']
  code: ['libs', 'app', 'modules']

# Serve this client on the root URL
ss.http.route '/', (req, res) ->
  res.serveClient 'main'

# Persistent sessions and storage based on Redis
ss.session.store.use 'redis', local.redisConfig
# ss.publish.transport.use 'redis', local.redisConfig
collections = ['bobs','readings','locations','drivers','uploads','status']
state.setupStorage collections, local.redisConfig

# Code Formatters known by SocketStream
ss.client.formatters.add require('ss-coffee')
ss.client.formatters.add require('ss-jade')
ss.client.formatters.add require('ss-stylus')

# Use client-side templates
ss.client.templateEngine.use 'angular'

# Minimise and pack assets if you type: SS_ENV=production node app.js
if ss.env is 'production'
  ss.client.packAssets()
else
  # show request log in dev mode
  # see http://www.senchalabs.org/connect/middleware-logger.html
  ss.http.middleware.prepend ss.http.connect.logger 'dev'

# support uploads, this will generate an 'upload' event with details
# TODO clean up files if this was not done by any event handlers
require('fs').mkdir './uploads'
ss.http.middleware.prepend ss.http.connect.bodyParser
  uploadDir: './uploads'
ss.http.middleware.prepend (req, res, next) ->
  state.emit 'upload', req.url, req.files  unless _.isEmpty req.files
  next()

# Start web server
server = http.Server ss.http.middleware
server.listen local.httpPort
ss.start server

# This event is periodically pushed to the clients to make them, eh, "tick"
setInterval ->
  ss.api.publish.all 'ss-tick', Date.now()
, 1000
