exports.info =
  name: 'archiver'
  description: 'Archival data storage (i.e. older history aggregated as files)'
  
state = require '../server/state'
fs = require 'fs'
async = require 'async'

# TODO these constants are duplicated from history.coffee
HISTSLOT_HR = 32 # number of hours stored in each history slot
HISTSLOT_MS = HISTSLOT_HR * 3600 * 1000 # slot size, in milliseconds

SLOTSIZE_MIN = 60 # each archive slot holds 60 minutes of aggragated values
SLOTSIZE_MS = SLOTSIZE_MIN * 60 * 1000 # archive slot size in milliseconds
FILESIZE = 1024 # number of slots per archive file

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

addOneValue = (collector, id, value) ->
  item = collector[id] ?= { cnt: 0 }
  if item.cnt++
    item.sum += value
    item.min = Math.min value, item.min
    item.max = Math.max value, item.max
  else
    item.sum = item.min = item.max = value

storeValue = (obj, oldObj) ->
  param = obj.key
  unless archMap[param]?
    archMap[param] = ++archMap._
    occasionalMapSave()
  id = archMap[param]
  slot = obj.time / SLOTSIZE_MS | 0
  collector = aggregated[slot] ?= {}
  collector.dirty = true # tag as being modified recently
  addOneValue collector, id, obj.origval

saveToFile = (seg, slots, id, cb) ->
  path = "#{ARCHIVE_PATH}/p#{seg}/p#{seg}-#{id}.dat"
  console.log 'sta', seg, slots, id, path
  fs.readFile path, (err, data) ->
    unless data?
      data = new Buffer(16 * FILESIZE)
      data.fill 0
    for slot in slots
      item = aggregated[slot]?[id]
      if item
        pos = (slot % FILESIZE) * 16
        data.writeUInt32LE item.cnt << 20, pos
        data.writeInt32LE item.sum, pos+4
        data.writeInt32LE item.min, pos+8
        data.writeInt32LE item.max, pos+12
    fs.writeFile path, data, cb

cronTask = (minutes) ->
  if minutes % 3 is 0
    segments = {} # map of arrays with slots we need to save
    ids = {} # used to accumulate all the id's present in oldSlots
    for hour, collector of aggregated
      if collector.dirty
        delete collector.dirty
      else
        seg = hour / FILESIZE | 0
        segments[seg] ?= []
        segments[seg].push hour
        ids = _.extend ids, collector
    # at this point, we know what slots and which id's to save (if any)
    console.log 'segs', segments, ids
    async.eachSeries _.keys(segments), (seg, done) ->
      fs.mkdir "#{ARCHIVE_PATH}/p#{seg}", ->
        slots = segments[seg]
        async.eachSeries _.keys(ids), (id, cb) ->
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
