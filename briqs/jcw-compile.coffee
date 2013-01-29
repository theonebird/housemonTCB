exports.info =
  name: 'jcw-compile'
  description: 'Compile for embedded systems'
  inputs: [
    name: 'Serial port'
    default: 'usb-A40115A2' # TODO: list choices with serialport.list
  ]
  menus: [
    title: 'Compile'
    controller: 'CompileCtrl'
  ]

serialport = require 'serialport'
state = require '../server/state'
fs = require 'fs'
child_process = require 'child_process'
ss = require 'socketstream'

# TODO hardcoded paths for now
SKETCHDIR = switch process.platform
  when 'darwin' then '/Users/jcw/Tools/sketch'
  when 'linux' then '/home/pi/sketchbook'

# callable from client as: rpc.exec 'host.api', 'compile', path
ss.api.add 'compile', (path, cb) ->
  # TODO totally unsafe, will accept any path as input file
  wr = fs.createWriteStream "#{SKETCHDIR}/sketch.ino"
  fs.createReadStream(path).pipe wr
  wr.on 'close', ->
    make = child_process.spawn 'make', ['upload'], cwd: SKETCHDIR
    make.stdout.on 'data', (data) ->
      ss.api.publish.all 'ss-output', 'stdout', "#{data}"
    make.stderr.on 'data', (data) ->
      ss.api.publish.all 'ss-output', 'stderr', "#{data}"
    make.on 'exit', (code) ->
      cb? null, code

# triggered when bodyParser middleware completes processing a file upload
state.on 'upload', (url, files) ->
  for file, info of files # FIXME multiple files won't work async
    state.store 'uploads',
      key: info.path
      file: file
      name: info.name
      type: info.type
      size: info.size
      date: Date.parse(info.lastModifiedDate)

# triggered when the uploads collection changes, used to clean up files
state.on 'store.uploads', (obj, oldObj) ->
  unless obj.key # only act on deletions
    fs.unlink oldObj.key

exports.factory = class extends serialport.SerialPort
  
  constructor: (device) ->
    # TODO expand platform-specific shorthands, not just Mac
    device = device.replace /^usb-/, '/dev/tty.usbserial-'
    
    # construct the serial port object
    super device,
      baudrate: 57600
      parser: serialport.parsers.readline '\r\n'

    info = key: 'compile', b1: false, b2: false, l1: false, l2: false

    @on 'data', (data) ->
      switch data
        when '-1' then info.b1 = false
        when '+1' then info.b1 = true
        when '-2' then info.b2 = false
        when '+2' then info.b2 = true
      state.store 'readings', _.extend {}, info

    adjustLeds = (obj) =>
      info = obj
      @write if info.l1 then 'A' else 'a'
      @write if info.l2 then 'B' else 'b'

    # FIXME without the delay, MacOSX will kernel panic (reliably!!!)
    #   maybe the FTDI driver can't handle output immediately after opening?
    setTimeout =>
      state.on 'store.readings.compile', adjustLeds
    , 1000
          
  destroy: -> @close()
