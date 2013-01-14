# Briqs

Briqs are an attempt to "compartmentalise" an application into manageable yet
loosely-coupled parts. Instead of having to put code in one directory, html
files in another, stylesheets in yet another, and so on for tests, data files,
and who knows what else - with briqs it would all reside in the briq which
implementents a certain aspect of the application.

The intended benefit is that features could be enabled and disabled at will,
and that exchange and re-use would become trivial. That's the utopian view.

In practice, briqs hardly do anything now. There's an admin interface (reached
via the "/admin" client-side route) which lists all available briqs, and allows
installing / uninstalling them. But that process is not yet well-defined.

## Today

So for now, Briqs are just a hand-waving attempt to get modularity implemented.

The current way to add a feature to the application is much more complex, and
depends on whether it is a server-side or client-side feature, or perhaps both.

Server-side features need to be added as code inside the `server/` directory.
There are no examples of this yet, other than the generic `host.api` RPC code.
The most common use will probably be as middleware, i.e. intercepting incoming
HTTP requests and dealing with them, or modifying them in some way. This is what
the `connect` module in SocketStream is for - see the SS docs for details.
Server-side middleware should be placed in the `server/middleware/` directory,
which does not currently exist, since there _is_ no middleware yet...

Client-side features will often be "a new page in the app with its own UI" -
such a new feature can be added as follows right now:

* pick a short name (e.g. 'jobs') to use application-wide

* add a file called `client/templates/jobs.jade`, to contain the HTML structure

* add a file `client/code/app/jobs.coffee` and in it, with the following text:

        exports.controllers = 
          JobsCtrl: [
            '$scope',
            ($scope) ->
            // your code here, using "the Angular way"
          ]
          
* you can also add filters, services, and directives, by adding lines such as:

        exports.filters = ...
        exports.services = ...
        exports.directives = ...

* edit the `client/code/app/routes.coffee` file, and add the following item:

        title: 'Jobs'
        path: '/jobs'
        controller: 'JobsCtrl'

* edit the `client/code/app/entry.coffee` file, and extend the list in there:

        for path in ['/main', '/home', '/admin', '/sandbox', '/jobs]

That's it. Save and your browser should show a new "Jobs" tab in its menu.
