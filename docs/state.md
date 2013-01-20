# State

There's the beginning of a mechanism to share state between the server and all
connected clients. This state consists of a number of objects. The server saves
this state in Redis, for persistence between restarts (this is optional).

## Shared state

This design is modeled on something I (jcw) built and used in a previous life,
called "Tequila". Basically, state is managed in the server, and replicated to
all connected clients on startup. After that, all changes are automatically
sent out to clients, allowing them to dynamicaly adapt to everything that
happens in the server or in any of the other connected clients.

Since all state is sent out to each client on startup, this sharing mechanism
is not intended for large amounts of data. For that, upload and a server-side
REST api should probably be added. Shared state is for the quick/dynamic stuff.

The way shared state is implemented meshes nicely with NG, because all shared
state is kept in the "MainCtrl" scope, which is inherited by all other scopes,
due to the way NG and JavaScript's prototypal inheritance works.

The key point to keep in mind is that clients can easily read all shared state,
but that they have to use `$scope.store hash, key, value` to make any changes.
Such changes will "round-trip" to the server before they end up being updated
in (all!) client scopes.

Lots of details yet to be worked out. For now, it works for the 'briqs'
and 'bobs' objects, and also includes some read-only server information.
