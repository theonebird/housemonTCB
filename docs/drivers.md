# Drivers

In the context of HouseMon, a "driver" is a bit of code to convert incoming
data to meaningful values (i.e. a decoder) and to transform commands into the
format needed to send them out. Drivers bridge the gap between physical devices,
such as USB ports and network interfaces, and the event and state mechanism in
HouseMon, which communicates in higher-level terms (readings and commands).

The "drivers" briq creates a simple way to manage these little bits of code and
data as separate CoffeeScript or JavaScript files in the `drivers/` directory.

## Simple example driver

Here is the "lightNode" driver, as implemented in `drivers/lightNode.coffee`:

    module.exports =

      announcer: 19

      descriptions:
        value:
          title: 'Light level'
          unit: '%'
          min: 0
          max: 255
          factor: 100 / 255
          scale: 0

      feed: 'rf12.packet'

      decode: (raw, cb) ->
        cb
          value: raw[1]

It contains an "announcer" setting, a description of the decoded reading, the
name of the event source from which it gets new data, and a "decode" function
for that incoming data.

The "lightNode" driver is an example of a very simple input-only decoder which
operates on incoming "RF12" wireless packets from a JeeNode or JeeLink. The
"rf12.packet" feed always passes the incoming data as a byte buffer to the
decoder, and provides a "callback" function as second argument. That callback
must be called once for each complete reading, passing an object with the
decoded "readings".

## Special cases

Note that the "cb" callback function can be called zero or more times, depending
on the number of readings which have been extracted from the raw input buffer.
In this case, each buffer consists of just the header byte and one data byte,
so decoding the data ia a matter of simply returning the second byte as result.

The decoder is called with "this" set to the same object each time, so it can
store temporary values there if it needs to track state from call to call.

## Announcer ID

The "announcer" id is a value which can be used for nodes to announce their
type to the central node, and thus avoid manual "_node id_ to _driver type_"
association, see <http://jeelabs.org/2013/01/16/remote-node-discovery-code/>.

This proposed mechanism has not been fully fleshed out (as of mid-February).

## Meta-data

The "descriptions" object should contain one field per field in the decoded
readings (just one in this case: "value"), and must specify at least a title
for it. The other fields are optional:

* **title** - the friendly name to use in reports for this parameter (required)
* **unit** - a short name for the measureent unit (e.g. "%", "m3", "W", etc)
* **min** - the minimum acceptable value (not enforced yet)
* **max** - the maximum acceptable value (not enforced yet)
* **factor** - a scale factor to be applied to the reading (default 1.0)
* **scale** - numeric scaling: >= 0 is number of decimals, < 0 to add zeroes

## Important note

Note that decoded values should be returned as **integers**, because internally
all readings are passed around and stored in signed int format (up to 32 bits).
The reason for this is not just to reduce floating-point processing overhead on
the server (which might be a very low-power Linux box without hardware FP), but
also because integers are better suited for keeping track of the precision of
a reading. So the value "1000" with scale 2 represents the value "10.00", not
"10", "10.0", or "10.000". Some people care about such distinctions!

If you truly, really _cannot_ avoid floating point, then here is a work-around:
return two different parameters in the reading, one representing the mantissa
and the other the exponent. These can be turned into a floating point result
in the browser, when the time comes to display or otherwise use that reading.

## Other examples

* For a simple driver which returns multiple sensor values, see the "roomNode".

* For a driver which "de-multiplexes" incoming packets into readings from
  _multiple_ wireless nodes, see the "ookRelay" code.

* For a driver which reports only changes and keeps track of the previous data,
  see the "p1scanner" implementation.
