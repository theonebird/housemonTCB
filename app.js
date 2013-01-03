// My SocketStream 0.3 app
var http = require('http');
var ss = require('socketstream');

// Define a single-page client called 'main'
ss.client.define('main', {
  view: 'index.jade',
  css: 'app.styl',
  code: ['libs', 'app'],
  tmpl: '*'
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
ss.responders.add(require('ss-angular'), {
  pollFreq: 1000
});

// Minimize and pack assets if you type: SS_ENV=production node app.js
if (ss.env === 'production') {
  ss.client.packAssets();
}

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
