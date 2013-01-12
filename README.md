# HouseMon

Real-time home monitoring and automation.

More info at <http://jeelabs.org/tag/housemon/>.

# Installation

Install [Node.js](http://nodejs.org) including [npm](https://npmjs.org), then:

    $ git clone https://github.com/jcw/housemon.git
    $ cd housemon
    $ npm install
    
If you don't have [Redis](http://redis.io) installed and running: change the 
"use-redis" entry in `package.json` to "false". This app selects database #1.
    
Launch the web server:

    $ npm start

Then browse to <http://localhost:3333/>.

# Seed use

To use this project as the starting point for a fresh project:

* clone this project, then install all the required packages as described above
* remove everything from the `briqs/` directory, except for `demo.coffee`
* change the project name, author, version, etc. as needed in `package.json`

# License

MIT
