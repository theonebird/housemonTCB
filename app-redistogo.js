// My SocketStream 0.3 app
var http = require('http');
var ss = require('socketstream');

var redis = require("redis");
var client = redis.createClient(10064, 'spadefish.redistogo.com');
client.auth('1122699edca3d801b4c4678133d6d991', function() {
  console.log("Connected!");
});

client.on("error", function (err) {
    console.log(err);
});

// Define a single-page client called 'main'
ss.client.define('main', {
  view: 'index.jade',
  css: ['libs', 'app.styl'],
  code: ['libs', 'app'],
});

// Serve this client on the root URL
ss.http.route('/', function(req, res) {
  return res.serveClient('main');
});

// Code Formatters
ss.client.formatters.add(require('ss-coffee'));
ss.client.formatters.add(require('ss-jade'));
ss.client.formatters.add(require('ss-stylus'));

// Use client-side templates
ss.client.templateEngine.use('angular');

// Responders
ss.responders.add(require('ss-angular'));

// Minimize and pack assets if you type: SS_ENV=production node app.js
if (ss.env === 'production')
  ss.client.packAssets();

// Start web server
var server = http.Server(ss.http.middleware);
server.listen(3333);

// Start Console Server (REPL)
// To install client: sudo npm install -g ss-console
// To connect: ss-console <optional_host_or_port>
var consoleServer = require('ss-console')(ss);
consoleServer.listen(5000);

// Start SocketStream
ss.start(server);

// Server-specific code
require('./server/startup')(ss);
