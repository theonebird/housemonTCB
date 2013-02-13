exports.info =
  name: 'archiver'
  description: 'Archival data storage'
  
state = require '../server/state'
local = require '../local'
redis = require 'redis'
fs = require 'fs'

# TODO this constant is duplicated from history.coffee
HISTSLOT = 32 * 3600 * 1000 # one day, in milliseconds

SLOTSIZE = 3600 * 1000 # archive slots hold one hour of aggragated values
FILESIZE = 1024 # number of slots per archive file

ARCHIVE_PATH = './archive'
ARCHREQ_PATH = '../archive'
ARCHMAP_PATH = './archive/index.json'

if fs.existsSync ARCHMAP_PATH
  archMap = require ARCHREQ_PATH
else
  archMap = _: 0 # sequence number

occasionalMapSave = _.debounce ->
  fs.writeFileSync ARCHMAP_PATH, JSON.stringify archMap, null, 2
, 3000

archKey = (param) ->
  unless archMap[param]?
    archMap[param] = ++archMap._
    occasionalMapSave()
  archMap[param]

config = local.redisConfig
db = redis.createClient config.port, config.host, config
dbReady = false

fs.mkdir ARCHIVE_PATH, ->
  # ignore mkdir errors (it probably already exists)
  db.select config.db, ->
    dbReady = true # ready for use

timeToBytePos = (time) ->
  ((time / SLOTSIZE | 0) % FILESIZE) * 16

aggregate = (buffer, time, value) ->
  pos = timeToBytePos time
  hdr = buffer.readUInt32LE pos
  cnt = hdr >> 20 # lower 20 bits reserved for future use
  if cnt is 0
    sum = min = max = value
  else
    sum = value + buffer.readInt32LE pos+4
    min = Math.min value, buffer.readInt32LE pos+8
    max = Math.max value, buffer.readInt32LE pos+12
  hdr += 1 << 20
  buffer.writeUInt32LE hdr, pos
  buffer.writeInt32LE sum, pos+4
  buffer.writeInt32LE min, pos+8
  buffer.writeInt32LE max, pos+12

saveOneDataset = (param, offset, pairs, cb) ->
  id = archKey param
  slot = offset / SLOTSIZE | 0
  pnum = slot / FILESIZE | 0
  console.log 'ap', param, offset, pairs.length, slot, pnum, id
  fs.mkdir "#{ARCHIVE_PATH}/p#{pnum}", ->
    path = "#{ARCHIVE_PATH}/p#{pnum}/p#{pnum}-#{id}"
    # TODO add I/O error handling
    fs.readFile path, (err, data) ->
      unless data?
        data = new Buffer(16 * FILESIZE)
        data.fill 0
      for i in [0...pairs.length] by 2
        time = offset + parseInt pairs[i+1]
        value = parseInt pairs[i]
        aggregate data, time, value  unless isNaN value
      fs.writeFile path, data, cb

getInvertedKeyMap = (cb) ->
  db.zrange 'hist:keys', 0, -1, 'withscores', (err, res) ->
    invKeyMap = {}
    for i in [0...res.length] by 2
      lastId = parseInt res[i+1]
      invKeyMap[lastId] = res[i]
    cb invKeyMap

moveToArchive = (slot, cb) ->
  console.info 'archiving slot', slot
  getInvertedKeyMap (invKeyMap) ->
    db.smembers "hist:slot:#{slot}", (err, res) ->
      # TODO should find a clean way to throttle all these async calls
      remain = res.length
      for id in res
        do (id) ->
          tag = "hist:#{id}:#{slot}"
          db.zrangebyscore tag, 0, '+inf', 'withscores', (err, res) ->
            saveOneDataset invKeyMap[id], slot * HISTSLOT, res, ->
              db.del tag, ->
              # callback executes when all the slots have been saved
              db.del "hist:slot:#{slot}", cb  unless --remain

cronTask = (minutes) ->
  if dbReady
    db.smembers 'hist:slots', (err, res) ->
      last = Math.max res...
      for slot in res when slot < last - 1
        do (slot) ->
          moveToArchive slot, ->
            db.srem 'hist:slots', slot, ->
              console.info 'slot moved to archive:', slot

exports.factory = class
  constructor: -> state.on 'minutes', cronTask
  destroy: -> state.off 'minutes', cronTask
