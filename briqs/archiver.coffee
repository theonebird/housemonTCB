exports.info =
  name: 'archiver'
  description: 'Archival data storage'
  
state = require '../server/state'
fs = require 'fs'
async = require 'async'

SLOTSIZE_MIN = 60 # each archive slot holds 60 minutes of aggragated values
SLOTSIZE_MS = SLOTSIZE_MIN * 60 * 1000 # archive slot size in milliseconds

FILESIZE = 1024 # number of slots per archive file
BYTES_PER_VALUE = 16 # stores four (16) or five (20) values

ARCHIVE_PATH = './archive'
ARCHREQ_PATH = '../archive'
ARCHMAP_PATH = './archive/index.json'

if fs.existsSync ARCHMAP_PATH
  archMap = require ARCHREQ_PATH
else
  archMap = _: 0 # sequence number

fs.mkdir ARCHIVE_PATH # ignore mkdir errors (it probably already exists)

aggregated = {} # in-memory cache of aggregated values

occasionalMapSave = _.debounce ->
  fs.writeFile ARCHMAP_PATH, JSON.stringify archMap, null, 2
, 3000

addOneValue = (time, param, value) ->
  # locate (or create) the proper collector slot in the aggregation cache
  slot = time / SLOTSIZE_MS | 0
  collector = aggregated[slot] ?= {}
  collector.dirty = true # tag as being modified recently
  # lookup (or assign and store) the id of the named parameter
  unless archMap[param]?
    archMap[param] = ++archMap._
    occasionalMapSave()
  id = archMap[param]
  # aggregate the value by combining it with what's already there
  item = collector[id] ?= { cnt: 0 }
  if item.cnt++
    item.sum += value
    item.min = Math.min value, item.min
    item.max = Math.max value, item.max
  else
    item.sum = item.min = item.max = value
    item.ssq = 0
  item.ssq += value * value  if BYTES_PER_VALUE >= 20

storeValue = (obj, oldObj) ->
  addOneValue obj.time, obj.key, obj.origval

saveToFile = (seg, slots, id, cb) ->
  path = "#{ARCHIVE_PATH}/p#{seg}/p#{seg}-#{id}.dat"
  console.log 'saveToFile', seg, slots, id, path
  fs.readFile path, (err, data) ->
    unless data?
      data = new Buffer(BYTES_PER_VALUE * FILESIZE)
      data.fill 0
    for slot in slots
      item = aggregated[slot]?[id]
      if item
        pos = (slot % FILESIZE) * BYTES_PER_VALUE
        data.writeUInt32LE item.cnt << 20, pos
        data.writeInt32LE item.sum, pos+4
        data.writeInt32LE item.min, pos+8
        data.writeInt32LE item.max, pos+12
        data.writeFloatLE item.ssq, pos+16  if BYTES_PER_VALUE >= 20
    fs.writeFile path, data, cb

cronTask = (minutes) ->
  if minutes % 3 is 0
    segments = {} # map of arrays with slots we need to save
    for hour, collector of aggregated
      if collector.dirty
        delete collector.dirty
      else
        seg = hour / FILESIZE | 0
        segments[seg] ?= []
        segments[seg].push hour
    # at this point, we know what slots and which id's to save (if any)
    console.log 'segs', segments
    async.eachSeries _.keys(segments), (seg, done) ->
      fs.mkdir "#{ARCHIVE_PATH}/p#{seg}", ->
        slots = segments[seg]
        async.eachSeries _.values(archMap), (id, cb) ->
          saveToFile seg, slots, id, cb
        , -> # called once all id's in this segment have been saved
          delete aggregated[slot]  for slot in slots
          done()

exports.factory = class
  constructor: ->
    state.on 'set.status', storeValue
    state.on 'minutes', cronTask
  destroy: ->
    state.off 'set.status', storeValue
    state.off 'minutes', cronTask
