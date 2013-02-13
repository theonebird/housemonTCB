exports.info =
  name: 'archiver'
  description: 'Archival data storage'
  
state = require '../server/state'
local = require '../local'
redis = require 'redis'
fs = require 'fs'

# TODO this constant is duplicated from history.coffee
HISTSLOT = 24 * 3600 * 1000 # one day, in milliseconds

SLOTSIZE = 3600 * 1000 # archive slots hold one hour of aggragated values
FILESIZE = 1024 # number of slots per archive file

ARCHIVE_PATH = './archive'
ARCHREQ_PATH = '../archive'
ARCHMAP_PATH = './archive/index.json'

if fs.existsSync ARCHMAP_PATH
  archMap = require ARCHREQ_PATH
else
  archMap = _: 0 # sequence number
# fs.writeFileSync ARCHMAP_PATH, JSON.stringify archMap, null, 2

config = local.redisConfig
db = redis.createClient config.port, config.host, config
dbReady = false

fs.mkdir ARCHIVE_PATH, ->
  # ignore mkdir errors (it probably already exists)
  db.select config.db, ->
    dbReady = true # ready for use

getInvertedKeyMap = (cb) ->
  db.zrange 'hist:keys', 0, -1, 'withscores', (err, res) ->
    invKeyMap = {}
    for i in [0...res.length] by 2
      lastId = parseInt res[i+1]
      invKeyMap[lastId] = res[i]
    cb invKeyMap

archivePath = (time, param) ->
  slot = Math.floor time / (SLOTSIZE * 1000)

saveOneDataset = (param, offset, values) ->
  console.log param, offset, values.length

saveToArchive = (slot) ->
  console.log 'archiving slot', slot
  getInvertedKeyMap (invKeyMap) ->
    db.smembers "hist:slot:#{slot}", (err, res) ->
      for id in res
        do (id) ->
          tag = "hist:#{id}:#{slot}"
          db.zrangebyscore tag, 0, '+inf', 'withscores', (err, res) ->
            saveOneDataset invKeyMap[id], slot * HISTSLOT, res

cronTask = (minutes) ->
  if dbReady
    db.smembers 'hist:slots', (err, res) ->
      last = Math.max res...
      saveToArchive slot  for slot in res when slot < last - 1

exports.factory = class
  constructor: -> state.on 'minutes', cronTask
  destroy: -> state.off 'minutes', cronTask
