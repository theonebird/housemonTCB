# HouseMon

Real-time home monitoring and automation.

More info at <http://jeelabs.org/tag/housemon/>.

# Installation

Install [Node.js](http://nodejs.org) and [redis](http://redis.io), then:

    $ git clone https://github.com/jcw/housemon.git
    $ cd housemon
    $ npm install
    
Make sure Redis is running (this app uses database #1, see `local.json`):

    $ redis-server &

Then launch the app as a Node.js web server:

    $ npm start

Now browse to <http://localhost:3333/> (this can be changed in `local.json`).

# Seed use

To use this project as starting point for a fresh project:

* clone this project, then install all the required packages as described above
* remove everything from the `briqs/` directory, except for `sandbox.coffee`
* change project name, author, version, etc. in `package.json` and `local.json`

# License

MIT
