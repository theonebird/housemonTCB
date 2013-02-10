# Briqs

Briqs are an attempt to "compartmentalise" an application into manageable yet
loosely-coupled parts. Instead of having to put code in one directory, html
files in another, stylesheets in yet another, and so on for tests, data files,
and who knows what else - with briqs it would all reside in the briq component
which implementents a specific aspect of the application.

The intended benefit is that features could be enabled and disabled at will,
and that exchange and re-use would become trivial. That's the utopian view.

There's an admin interface (reached via the "/admin" client-side route) which
lists all available briqs, and allows installing / uninstalling them. Installed
briqs are called "briq objects" or "bobs".

In software terms, a "briq" is a _class_, a "bob" is an _instance_ of a briq.

## Today

The current way to add a feature to the application is still quite complex, and
depends on whether it is a server-side or client-side feature, or perhaps both.
So right now, in _practice_, files are still all over the place, unfortunately.

Server-side features need to be added as code inside the `server/` directory.
There are no examples of this yet, other than the generic `host.api` RPC code.
The most common use will probably be as middleware, i.e. intercepting incoming
HTTP requests and dealing with them, or modifying them in some way. This is what
the `connect` module in SocketStream is for - see the SS docs for details.
Server-side middleware should be placed in the `server/middleware/` directory,
which does not currently exist, since there _is_ no middleware yet...

Client-side features will often be "a new page in the app with its own UI" -
such a new feature can be added as follows right now:

* pick a short name (e.g. 'jobs') to use application-wide, and as URL prefix

* add a file called `client/templates/jobs.jade`, to contain the HTML structure:

        .row
          .twelve.columns
            h1 Jobs
            p ...

* create a file `client/code/modules/jobs.coffee` with the following contents:

        module.exports = (ng) ->
          ng.controller 'JobsCtrl', [
            '$scope',
            ($scope) ->
              # your code here, using "the Angular way"
          ]
          
* you can also add filters, services, directives, etc. by adding lines such as:

        ng.filter ...
        ng.factory ...
        ng.directive ...

* lastly, create a briq file, i.e. `briqs/jobs.coffee`, with these lines in it:

        exports.info =
          name: 'jobs-menu'
          description: 'This is a briq which enables a menu and a route'
          menus: [
            title: 'Jobs'
            controller: 'JobsCtrl'
          ]

* if you want the briq to also perform some task on the server, add this to it:

        exports.factory = class
          constructor: -> ...
          destroy: -> ...

The constructor will be called when the briq is installed, to create a bob, and
destroy will be called when it's uninstalled. There is a simple mechanism to get
additional parameters into the constructor, see `exports.info.inputs` in the
`rf12demo-serial` briq for an example.

That's it. Save and your browser should now show a new "jobs-menu" briq. When
"installing" it on the admin page, it will create a new "Jobs" menu item, which
in turn leads to the new page defined by the above CoffeeScript and Jade files.
