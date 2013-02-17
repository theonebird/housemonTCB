# Dependencies

As HouseMon starts to get features (in the form of Briqs), it will become more
important to have a clear image of how all these pieces are meant to be used
together. This is bound to be a moving target, but here's a first attempt to
describe the situation as of mid-February.

## The big picture

HouseMon is implemented as a collection of briqs, which can be installed more
or less independently. This is possible because most briqs do not "load" or
"call" each other to inter-operate, but instead they use the standard Node.js
"event emitter" mechanism. There is a "server/state" module, which is intended
as central exchange mechanism between the different briqs. There are two ways
for briqs to inter-operate, and for the server to communicate with clients:

1. Any briq can emit events via the state object - a hypothetical example:

        state = require '../server/state'
        state.emit 'bingo', new Date

   This will emit a single "bingo" event and pass the current time as argument.

   To pick up such events, any briq (the same or another one) can do this:

        state = require '../server/state'
        state.on 'bingo', (arg) ->
          console.log "got bingo event:", arg
    
   This mechanism works regardless of which order briqs are installed. in If no
   emitter or no listener is set up, such events quietly vanish into thin air.

   Events with names sarting with "ss-" will also be sent to all clients.

2. The other mechanism is to store state in a "collection". A collection is an
   array of objects with a unique "key" and an auto-assigned "id" field. The 
   main difference with events, is that state is persistent across restarts
   (via Redis) and that is gets replicated in both directions between server and
   clients. When a client connects, it automatically gets a copy of the current
   state as part of the startup process.

   Setting state in a briq can be done as follows - again as silly example:

        state = require '../server/state'
        state.store 'people', { key: 'Joe', age: 12 }

   This will then generate 'set.people' events on the server as well as on the
   client side, which lets code hook into additions, changes, and deletions.

   The main point of state is that it doesn't require the "producers" and
   "consumers" to be present at the same time. The last change will always be
   saved as part of the state, and can be picked up by briqs installed later.

This may all sound like a big clever "master plan", but in reality it's all
quite ad-hoc. These mechanisms may still change completely, as the requirements
are better understood. For now, it looks like "events" + "state" are fairly
practical and sufficient for the tasks performed in HouseMon.

## Briqs using other briqs

The above should also make it clear why most briqs can be installed and even
uninstalled at will: if something essential is not installed, the result will
simply be that _nothing happens!_ ... until the briq does get installed, and
then all of a sudden the system will start to do things.

This is definitely not a scalable solution, since debugging the cause of
"nothing happening" is going to be a nightmare once more briqs get added, and
once more of the briqs start inter-operating and _relying_ on each other.

The problem can hopefully be solved by implementing an explicit briq dependency
mechanism at some point.

## Current dependencies

These are some of the basic briqs which have been implemented as of mid-Feb:

* **rf12replay** - Generates fake data by replaying a fixed log file.

  This does not depend on any other briqs. Only useful for testting. Use the
  "rf12demo" briq to connect to a real JeeNode or JeeLink for real-world use.

* **logger** - Ties into raw serial events and saves each incoming line of data
  as-is in text-based log files. Log files roll over every day at midnight UTC.

* **drivers** - This briq is a wrapper for "drivers" which can decode / encode
  RF12 packets. See some first implementations in the "drivers/" directory.

  Does not depend on other briqs, but it needs the "drivers" collections to
  figure out which packets from which nodes should be handled by which drivers.

  As there is not yet a web interface to manage this information, you have to
  install the "jcw-staticdata" briq, to pre-load the "drivers" collection
  (it'll retain its contents after that, unless the Redis data is flushed).

  The decoded results from the drivers briq is stored in the "readings"
  collection. One entry per driver result (which can include multiple sensors).

* **status** - Pick up new readings and perform two operations on each of them:

   1. Split up readings into individual measurement values
   2. Convert the integers to properly scaled and formatted results

  The status briq also maps readings to locations, i.e. this is where a reading
  from "RF12:5:12" gets turned into four measurements tagged as coming from a
  room node in the "living room", for example.

  The results of the status briq is stored in the "status" collection.

* **history** - This briq picks up each change in the "status" collection and
  saves the values in Redis as historical data (as sorted sets, split out per
  parameter). This is where all the _previous_ values of an entry in the
  "status" collection end up.

* **archiver** - The archiver periodically goes through the history data in 
  Redis, and moves the oldest stuff to file. This way, only up to about two
  days worth of raw data is kept in Redis, while all older data values are
  aggregated in archive files on disk.

* **jcw-graphs** - A first attempt to get some graphs into the web browser.
  This briq depends on the historical data stored in Redis.  Still just for
  testing code, it has hard-coded settings, the checkboxes don't work yet.

So much for a first _very preliminary_ overview of some of the basic briqs.
